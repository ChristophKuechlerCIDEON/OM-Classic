FUNCTION /cideon/get_class_data.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NUTZER) TYPE  XUBNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  XUBNAME
*"  TABLES
*"      I_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"      O_ITAB_CLASS_DATA STRUCTURE  ZCL_S_STEMPEL_VALUE
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
*   -  holt sich die Klassifikationsdaten für ein PlotItem
*   -
*-----------------------------------------------------------------------
* Journal
* 03.07.2003
* 18.08.2003  Daten über BAPI holen
* 24.03.2005 - Kennzeichen für Bezeichnung des Merkmalswerts
*              bei gesetzten Kennzeichen direkt in der AUSP nachsehen
*              sonst BAPI benutzen
*-----------------------------------------------------------------------

*TYPES
  TYPES: BEGIN OF t_gruppe,
      nutzer_gruppe LIKE zcl_grp_class_kl-nutzer_gruppe,
    END OF t_gruppe.
*ITAB
  DATA: itab_class_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_gruppen TYPE TABLE OF zcl_v_usr_grp_ak.
  DATA: itab_char_values TYPE TABLE OF bapi_characteristic_values.
*WA
  DATA: wa_class_data TYPE zcl_s_stempel_value.
  DATA: wa_gruppe TYPE zcl_v_usr_grp_ak.
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
  DATA: wa_char_values TYPE bapi_characteristic_values.
*NORMAL
  DATA: tmp_atwrt LIKE ausp-atwrt.
  DATA: index_plotjobs TYPE i.
  DATA: return TYPE bapiret2.


* Stempel für Nutzer holen
* Nutzer -> Nutzergruppe -> Klassendaten
* ZCL_V_USR_GRP_AK

* Daten über BAPI holen
  SELECT * FROM zcl_v_usr_grp_ak INTO TABLE itab_gruppen
    WHERE nutzer = i_nutzer
    AND knz_wert_merkmal NE 'X'.
  IF sy-subrc NE 0.
    SELECT * FROM zcl_v_usr_grp_ak INTO TABLE itab_gruppen
      WHERE nutzer = i_default_nutzer
      AND knz_wert_merkmal NE 'X'.
    IF sy-subrc NE 0.

    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


* Daten erfragen
*  LOOP AT i_itab_plotjobs INTO wa_plotjobs.
*    index_plotjobs = sy-tabix.
*
*    LOOP AT itab_gruppen INTO wa_gruppe.
*      CLEAR tmp_atwrt.
*      SELECT SINGLE atwrt FROM ausp
*        INTO tmp_atwrt
*        WHERE objek = wa_plotjobs-objky
*        AND atinn = wa_gruppe-atinn
*        AND klart = wa_gruppe-klart
*        .
*      IF sy-subrc NE 0.
*        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
*        wa_class_data-zeile_plotjob = index_plotjobs.
*        wa_class_data-stempel_wert = tmp_atwrt.
*        APPEND wa_class_data TO itab_class_data.
**       keinen Wert gefunden, da wahrscheinlich leer.....
**        PERFORM appl_log_write USING
**          'W' '050' '/CIDEON/PLOT_BASIS'
**           wa_plotjobs-objky wa_gruppe-klart
**           wa_gruppe-atinn '' .
*      ELSE.
*        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
*        wa_class_data-zeile_plotjob = index_plotjobs.
*        wa_class_data-stempel_wert = tmp_atwrt.
*        APPEND wa_class_data TO itab_class_data.
*      ENDIF.
*    ENDLOOP.
*
*  ENDLOOP.

* neue Implementierung über BAPI
  LOOP AT i_itab_plotjobs INTO wa_plotjobs.
    index_plotjobs = sy-tabix.

    CLEAR itab_char_values.

    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_plotjobs-dokar
        documentnumber             = wa_plotjobs-doknr
        documentpart               = wa_plotjobs-doktl
        documentversion            = wa_plotjobs-dokvr
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
*       GETACTIVEFILES             = 'X'
        getclassification          = 'X'
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
*     IMPORTING
*       DOCUMENTDATA               =
*       RETURN                     =
      TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
*       DOCUMENTFILES              =
*       COMPONENTS                 =
        characteristicvalues       = itab_char_values
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
              .
    IF return IS INITIAL.
*     alles ok

    ELSE.
      PERFORM appl_log_write USING
        'W' '050' '/CIDEON/PLOT_BASIS'
         wa_plotjobs-objky wa_gruppe-klart
         wa_gruppe-atinn '' .
    ENDIF.


    LOOP AT itab_gruppen INTO wa_gruppe.
      CLEAR wa_char_values.
      LOOP AT itab_char_values INTO wa_char_values
        WHERE
        charname = wa_gruppe-atnam
        .
      ENDLOOP.
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
        wa_class_data-zeile_plotjob = index_plotjobs.
        CLEAR wa_class_data-stempel_wert.
        APPEND wa_class_data TO itab_class_data.
      ELSE.
        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
        wa_class_data-zeile_plotjob = index_plotjobs.
        wa_class_data-stempel_wert = wa_char_values-charvalue.
        APPEND wa_class_data TO itab_class_data.
      ENDIF.


    ENDLOOP.

*        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
*        wa_class_data-zeile_plotjob = index_plotjobs.
*        wa_class_data-stempel_wert = tmp_atwrt.
*        APPEND wa_class_data TO itab_class_data.


  ENDLOOP.



* Daten über direktes Auslesen aus AUSP holen
  SELECT * FROM zcl_v_usr_grp_ak INTO TABLE itab_gruppen
    WHERE nutzer = i_nutzer
    AND knz_wert_merkmal EQ 'X'.
  IF sy-subrc NE 0.
    SELECT * FROM zcl_v_usr_grp_ak INTO TABLE itab_gruppen
      WHERE nutzer = i_default_nutzer
      AND knz_wert_merkmal EQ 'X'.
    IF sy-subrc NE 0.

    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

* Daten erfragen
  LOOP AT i_itab_plotjobs INTO wa_plotjobs.
    index_plotjobs = sy-tabix.

    LOOP AT itab_gruppen INTO wa_gruppe.
      CLEAR tmp_atwrt.
      SELECT SINGLE atwrt FROM ausp
        INTO tmp_atwrt
        WHERE objek = wa_plotjobs-objky
        AND atinn = wa_gruppe-atinn
        AND klart = wa_gruppe-klart
        .
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
        wa_class_data-zeile_plotjob = index_plotjobs.
        wa_class_data-stempel_wert = tmp_atwrt.
        APPEND wa_class_data TO itab_class_data.
*       keinen Wert gefunden, da wahrscheinlich leer.....
*        PERFORM appl_log_write USING
*          'W' '050' '/CIDEON/PLOT_BASIS'
*           wa_plotjobs-objky wa_gruppe-klart
*           wa_gruppe-atinn '' .
      ELSE.
        MOVE-CORRESPONDING wa_gruppe TO wa_class_data.
        wa_class_data-zeile_plotjob = index_plotjobs.
        wa_class_data-stempel_wert = tmp_atwrt.
        APPEND wa_class_data TO itab_class_data.
      ENDIF.
    ENDLOOP.

  ENDLOOP.




* Falls Zuordnung zu mehreren Gruppen mit überschneidenen Merkmalen
* dann Bereinigung der Tabelle
  SORT itab_class_data BY zeile_plotjob stempel_name ASCENDING.
  DELETE ADJACENT DUPLICATES FROM itab_class_data.



  o_itab_class_data[] = itab_class_data[].

ENDFUNCTION.
