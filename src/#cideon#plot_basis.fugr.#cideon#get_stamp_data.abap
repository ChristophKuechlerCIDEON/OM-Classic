FUNCTION /cideon/get_stamp_data.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NUTZER) TYPE  XUBNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  XUBNAME
*"  TABLES
*"      I_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
*   -  holt sich die Stempeldaten für ein PlotItem
*   -
*-----------------------------------------------------------------------
* Journal
* 03.07.2003
*-----------------------------------------------------------------------

* TABLES
*  TABLES: rsinfdir, tfdir.
*TYPES
*  TYPES: BEGIN OF t_gruppe,
*      nutzer_gruppe LIKE zcl_grp_class_kl-nutzer_gruppe,
*    END OF t_gruppe.
*ITAB
  DATA: itab_stamp_data TYPE TABLE OF zcl_s_stempel_value.

  DATA: itab_stempel_wert TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_stempel_default TYPE TABLE OF zcl_stamp_defaul.
  DATA: itab_stempel_user TYPE TABLE OF zcl_stamp_user.
  DATA: itab_stempel_voreinstellung TYPE TABLE OF zcl_stamp_vorein.
  DATA: itab_stempel_verteiler TYPE TABLE OF zcl_stamp_vertei.

*WA
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
  DATA: index_plotjobs TYPE i.

  DATA: wa_stempel_wert TYPE zcl_s_stempel_value.
  DATA: wa_stempel_default TYPE zcl_stamp_defaul.
  DATA: wa_stempel_user TYPE zcl_stamp_user.
  DATA: wa_stempel_voreinstellung TYPE zcl_stamp_vorein.
  DATA: wa_stempel_verteiler TYPE zcl_stamp_vertei.
*NORMAL





  REFRESH itab_stempel_default.
  SELECT * FROM zcl_stamp_defaul
    INTO TABLE itab_stempel_default
    WHERE status = c_status_aktiv
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  REFRESH itab_stempel_user.
  SELECT * FROM zcl_stamp_user
    INTO TABLE itab_stempel_user
    WHERE status = c_status_aktiv
    AND uname = sy-uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  REFRESH itab_stempel_wert.

  LOOP AT i_itab_plotjobs INTO wa_plotjobs.
    REFRESH itab_stempel_voreinstellung.
    SELECT * FROM zcl_stamp_vorein
      INTO TABLE itab_stempel_voreinstellung
      WHERE status = c_status_aktiv
      AND voreinstellung = wa_plotjobs-voreinstellung
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    REFRESH itab_stempel_verteiler.
    SELECT * FROM zcl_stamp_vertei
      INTO TABLE itab_stempel_verteiler
      WHERE status = c_status_aktiv
      AND verteiler = wa_plotjobs-verteiler
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.


    index_plotjobs = sy-tabix.

*   default stamps
    LOOP AT itab_stempel_default INTO wa_stempel_default.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_default-fm_name
        .
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_default-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_default-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_plotjobs.
        wa_stempel_wert-stempel_name = wa_stempel_default-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   user stamps
    LOOP AT itab_stempel_user INTO wa_stempel_user.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_user-fm_name
        .
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_user-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_plotjobs.
        wa_stempel_wert-stempel_name = wa_stempel_user-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   Voreinstellung stamps
    LOOP AT itab_stempel_voreinstellung INTO wa_stempel_voreinstellung.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_voreinstellung-fm_name
        .
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_voreinstellung-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_plotjobs.
        wa_stempel_wert-stempel_name =
          wa_stempel_voreinstellung-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   Verteiler stamps
    LOOP AT itab_stempel_verteiler INTO wa_stempel_verteiler.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_verteiler-fm_name
        .
      IF sy-subrc NE 0.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_verteiler-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_plotjobs.
        wa_stempel_wert-stempel_name =
          wa_stempel_verteiler-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.
  ENDLOOP.


  CLEAR itab_stamp_data.
  itab_stamp_data[] = itab_stempel_wert[].


* Falls Zuordnung zu mehreren Gruppen mit überschneidenen Merkmalen
* dann Bereinigung der Tabelle
  SORT itab_stamp_data BY zeile_plotjob stempel_name ASCENDING.
  DELETE ADJACENT DUPLICATES FROM itab_stamp_data.



  o_itab_stamp_data[] = itab_stamp_data[].

ENDFUNCTION.
