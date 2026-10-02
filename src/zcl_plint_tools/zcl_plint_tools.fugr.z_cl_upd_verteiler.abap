FUNCTION z_cl_upd_verteiler.
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
* 01.08.2002 Erstellung
*-----------------------------------------------------------------------
* WA
  DATA: wa_verteiler LIKE zcl_verteiler.
  DATA: wa_repro_cl_ini LIKE zcl_repro_cl_ini.
* NORMAL
  DATA: count TYPE i.
  DATA: tmp_str(10).
  DATA: tmp_keyname(30).

* Verteiler bereinigen
  DELETE FROM zcl_verteiler
    WHERE uname = i_uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


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
  CLEAR wa_verteiler.
  wa_verteiler-uname = i_uname.

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
      wa_verteiler-verteiler = wa_repro_cl_ini-keywert.
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
      wa_verteiler-beschreibung = wa_repro_cl_ini-keywert.
    ENDIF.

*   Satzanzahl
    CONCATENATE 'Wert' tmp_str '/' '2' INTO tmp_keyname.
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
      wa_verteiler-satzanzahl = wa_repro_cl_ini-keywert.
    ENDIF.

*   Deckblatt
    CONCATENATE 'Wert' tmp_str '/' '3' INTO tmp_keyname.
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
      wa_verteiler-deckblatt = wa_repro_cl_ini-keywert.
    ENDIF.

*   Endelatt
    CONCATENATE 'Wert' tmp_str '/' '4' INTO tmp_keyname.
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
      wa_verteiler-endeblatt = wa_repro_cl_ini-keywert.
    ENDIF.

*   Kennzeichen Inhaltsverzeichnis
    CONCATENATE 'Wert' tmp_str '/' '5' INTO tmp_keyname.
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
      wa_verteiler-knz_inhalt_vz = wa_repro_cl_ini-keywert.
    ENDIF.

*   Info
    wa_verteiler-zclinsname = sy-uname.
    wa_verteiler-zclinsdate = sy-datum.
    wa_verteiler-zclinstime = sy-uzeit.
    wa_verteiler-zclinsprog = sy-repid.
    wa_verteiler-zclupdname  = sy-uname.
    wa_verteiler-zclupddate = sy-datum.
    wa_verteiler-zclupdtime = sy-uzeit.
    wa_verteiler-zclupdprog = sy-repid.

*   Update ZCL_Verteiler
    MODIFY zcl_verteiler FROM wa_verteiler.
    IF sy-subrc NE 0.
      MESSAGE i051(zcl_plint_tools)
        WITH 'zcl_verteiler' i_uname
        wa_verteiler-verteiler ''
        RAISING error.
    ELSE.
    ENDIF.

  ENDDO.

  MESSAGE i054(zcl_plint_tools) WITH '' '' '' ''.

ENDFUNCTION.
