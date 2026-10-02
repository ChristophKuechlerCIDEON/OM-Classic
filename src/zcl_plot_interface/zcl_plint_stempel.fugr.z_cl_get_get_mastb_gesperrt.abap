FUNCTION z_cl_get_get_mastb_gesperrt .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* TYPES
* ITAB
  DATA: itab_mat_status_exc TYPE TABLE OF mstae.
  DATA: itab_objlinks TYPE TABLE OF bapi_doc_drad.
* WA
  DATA: default_data TYPE t_defaultdata.
  DATA: user_data TYPE t_defaultdata.
  DATA: return TYPE bapiret2.
  DATA: wa_objlinks TYPE bapi_doc_drad.
  DATA: wa_mara TYPE mara.
  DATA: wa_mat_status_exc TYPE mstae.
  DATA: wa_t141 TYPE t141.
* NORMAL
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).
  DATA: lines TYPE i.
  DATA: f_exit(1).


  CLEAR f_exit.

* Einstellungen lesen für
* Werksübergreifende Sperrstati
* Trennzeichen
* interne Tabelle dafürerstellen

  CLEAR default_data.
* MAT_STATUS_EXC
  CLEAR tmp_str.
  pname = 'MAT_STATUS_EXC'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE s057(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      'SPACE' ''.
    default_data-mat_status_exc = ''.
*    PERFORM appl_log_write USING
*      'W' '057' 'ZCL_PLINT_TOOLS'
*      'zcl_plint_cfg_00' pname 'SPACE' '' .
  ELSE.
    default_data-mat_status_exc = tmp_str.
  ENDIF.

* TRENNZEICHEN
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE s057(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      'SPACE' ''.
    default_data-trennzeichen = ','.
*    PERFORM appl_log_write USING
*      'W' '057' 'ZCL_PLINT_TOOLS'
*      'zcl_plint_cfg_00' pname ',' '' .
  ELSE.
    default_data-trennzeichen = tmp_str.
  ENDIF.

* MAT_STATUS_EXC
  CLEAR tmp_str.
  pname = 'MAT_STATUS_EXC'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_status_exc =
      default_data-mat_status_exc.
  ELSE.
    user_data-mat_status_exc = tmp_str.
  ENDIF.

* TRENNZEICHEN
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-trennzeichen =
      default_data-trennzeichen.
  ELSE.
    user_data-trennzeichen = tmp_str.
  ENDIF.

* interne Tabelle füllen
  REFRESH itab_mat_status_exc.
  SPLIT user_data-mat_status_exc AT user_data-trennzeichen
    INTO TABLE itab_mat_status_exc.

* Objektverknüpfungen holen
  CALL FUNCTION 'BAPI_DOCUMENT_GETOBJECTLINKS'
       EXPORTING
            documenttype        = i_wa_plotjobs-dokar
            documentnumber      = i_wa_plotjobs-doknr
            documentpart        = i_wa_plotjobs-doktl
            documentversion     = i_wa_plotjobs-dokvr
            getlinkdescriptions = 'X'
       IMPORTING
            return              = return
       TABLES
            objectlinks         = itab_objlinks.



* Testen, ob ein Material existiert, was gesperrt ist
* Objecktverknüpfungen bereinigen
  LOOP AT itab_objlinks INTO wa_objlinks.
    IF wa_objlinks-objecttype = 'MARA'.
    ELSE.
      DELETE itab_objlinks INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE itab_objlinks LINES lines.
  IF lines = 0.
    CLEAR o_stempel_wert.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_objlinks INTO wa_objlinks.
    SELECT SINGLE * FROM mara
      INTO wa_mara
      WHERE matnr = wa_objlinks-objectkey
      .
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

    IF wa_mara-mstde < sy-datum.
    ELSE.
      CONTINUE.
    ENDIF.


    LOOP AT itab_mat_status_exc
      INTO wa_mat_status_exc
      .
      IF wa_mat_status_exc = wa_mara-mstae.
*       gefunden
        SELECT SINGLE mtstb FROM t141t
          INTO o_stempel_wert
          WHERE spras = sy-langu
          AND mmsta = wa_mara-mstae
          .
        IF sy-subrc NE 0.
        ELSE.
          f_exit = 'X'.
          EXIT.
        ENDIF.
      ELSE.
      ENDIF.
    ENDLOOP.
    IF f_exit = 'X'.
      EXIT.
    ELSE.
    ENDIF.

  ENDLOOP.


*  o_stempel_wert = ':-)'.


ENDFUNCTION.
