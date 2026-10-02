FUNCTION /cideon/get_result_stamp_data.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NUTZER) TYPE  XUBNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  XUBNAME
*"  TABLES
*"      I_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"      I_ITAB_STAMP_DATA STRUCTURE  ZCL_S_STEMPEL_VALUE
*"      O_ITAB_STAMP_DATA STRUCTURE  ZCL_S_STEMPEL_VALUE
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   -  holt sich die resultierenden Stempeldaten für ein PlotItem
*   -
*-----------------------------------------------------------------------
* Journal
* 03.07.2003
*-----------------------------------------------------------------------

*TYPES
  TYPES: BEGIN OF t_gruppe,
      nutzer_gruppe LIKE zcl_v_usr_grp_rs-nutzer_gruppe,
    END OF t_gruppe.
*ITAB
  DATA: itab_res_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_stamps TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_class TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_gruppen TYPE TABLE OF zcl_v_usr_grp_rs.
*WA
  DATA: wa_res_data TYPE zcl_s_stempel_value.
  DATA: wa_i_itab_stamp_data TYPE zcl_s_stempel_value.
  DATA: wa_gruppe TYPE zcl_v_usr_grp_rs.
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
  DATA: tmp_atwrt LIKE ausp-atwrt.
  DATA: index_plotjobs TYPE i.
*NORMAL
  DATA: stempel_wert TYPE zcl_s_stempel_value-stempel_wert.


* Stempel für Nutzer holen
* Nutzer -> Nutzergruppe -> resultierende Stempeldaten
* ZCL_V_USR_GRP_RS

  SELECT * FROM zcl_v_usr_grp_rs INTO TABLE itab_gruppen
    WHERE nutzer = i_nutzer.
  IF sy-subrc NE 0.
    SELECT * FROM zcl_v_usr_grp_rs INTO TABLE itab_gruppen
      WHERE nutzer = i_default_nutzer.
    IF sy-subrc NE 0.

    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


* Daten erfragen
  LOOP AT i_itab_plotjobs INTO wa_plotjobs.
    index_plotjobs = sy-tabix.

*   Tabellen mappen
    CLEAR itab_stamps.
    CLEAR itab_class.
    LOOP AT i_itab_stamp_data INTO wa_i_itab_stamp_data
      WHERE zeile_plotjob = index_plotjobs.
      APPEND wa_i_itab_stamp_data TO itab_stamps.
      APPEND wa_i_itab_stamp_data TO itab_class.
    ENDLOOP.

    LOOP AT itab_gruppen INTO wa_gruppe.
*     Testen, ob der Funktionsbaustein überhaupt vorhanden ist
*     entsprechende Meldung an die Oberfläche / oder APPL-LOG Eintrag
*     mglw. Nachrüsten
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_gruppe-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
*        PERFORM appl_log_write USING
*          'E' '080' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_gruppe-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
*        PERFORM appl_log_write USING
*          'E' '081' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        CONTINUE.
      ENDIF.

*     Aufruf der Funktionsbausteine
      MOVE-CORRESPONDING wa_gruppe TO wa_res_data.

      CALL FUNCTION wa_gruppe-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = stempel_wert
           TABLES
                i_itab_stamps  = itab_stamps
                i_itab_class   = itab_class
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        CONTINUE.
      ELSE.
      ENDIF.

      wa_res_data-zeile_plotjob = index_plotjobs.
      wa_res_data-stempel_wert = stempel_wert.
      APPEND wa_res_data TO itab_res_data.

      APPEND wa_res_data TO itab_stamps.
      APPEND wa_res_data TO itab_class.



*      CLEAR tmp_atwrt.
*      SELECT SINGLE atwrt FROM ausp
*        INTO tmp_atwrt
*        WHERE objek = wa_plotjobs-objky
*        AND atinn = wa_gruppe-atinn
*        AND klart = wa_gruppe-klart
*        .
*      IF sy-subrc NE 0.
*        PERFORM appl_log_write USING
*          'W' '050' '/CIDEON/PLOT_BASIS'
*           wa_plotjobs-objky wa_gruppe-klart
*           wa_gruppe-atinn '' .
*      ELSE.
*        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
*        wa_class_data-zeile_plotjob = index_plotjobs.
*        wa_class_data-stempel_wert = tmp_atwrt.
*        APPEND wa_class_data TO itab_class_data.
*      ENDIF.
    ENDLOOP.

  ENDLOOP.

* Falls Zuordnung zu mehreren Gruppen mit überschneidenen Merkmalen
* dann Bereinigung der Tabelle
  SORT itab_res_data BY zeile_plotjob stempel_name ASCENDING.
  DELETE ADJACENT DUPLICATES FROM itab_res_data.



  o_itab_stamp_data[] = itab_res_data[].

ENDFUNCTION.
