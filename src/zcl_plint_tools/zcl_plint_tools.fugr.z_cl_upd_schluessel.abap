FUNCTION z_cl_upd_schluessel.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 16.09.2002 Erstellung
*-----------------------------------------------------------------------
* WA
  DATA: wa_schluessel LIKE zcl_verteiler.
  DATA: wa_repro_cl_ini LIKE zcl_repro_cl_ini.
* NORMAL
  DATA: count TYPE i.
  DATA: tmp_str(10).
  DATA: tmp_keyname(30).


  SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
    WHERE uname = i_uname
    AND sektor = '[Verteiler]'
    AND keyname = 'Zeilen'.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i052(zcl_plint_tools)
      WITH 'zcl_repro_cl_ini' i_uname
      '[Verteiler]' 'Zeilen'
      RAISING error.
  ELSE.
  ENDIF.

  CLEAR count.
  count = wa_repro_cl_ini-keywert.
  CLEAR wa_schluessel.
  wa_schluessel-uname = i_uname.

  DO count TIMES.
    CLEAR tmp_keyname.
    tmp_str = sy-index - 1.
    CONCATENATE 'Wert' tmp_str '/' '0' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_schluessel-verteiler = wa_repro_cl_ini-keywert.
    ENDIF.

*   Beschreibung
    CONCATENATE 'Wert' tmp_str '/' '1' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Verteiler]' tmp_keyname
        RAISING error.
    ELSE.
      wa_schluessel-beschreibung = wa_repro_cl_ini-keywert.
    ENDIF.




*   Info
    wa_schluessel-zclinsname = sy-uname.
    wa_schluessel-zclinsdate = sy-datum.
    wa_schluessel-zclinstime = sy-uzeit.
    wa_schluessel-zclinsprog = sy-repid.
    wa_schluessel-zclupdname  = sy-uname.
    wa_schluessel-zclupddate = sy-datum.
    wa_schluessel-zclupdtime = sy-uzeit.
    wa_schluessel-zclupdprog = sy-repid.

*   Update ZCL_Verteiler
    MODIFY zcl_verteiler FROM wa_schluessel.
    IF sy-subrc NE 0.
      MESSAGE i051(zcl_plint_tools)
        WITH 'zcl_verteiler' i_uname
        wa_schluessel-verteiler ''
        RAISING error.
    ELSE.
    ENDIF.

  ENDDO.

  MESSAGE i054(zcl_plint_tools) WITH '' '' '' ''.

ENDFUNCTION.
