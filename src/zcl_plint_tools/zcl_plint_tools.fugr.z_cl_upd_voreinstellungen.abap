FUNCTION z_cl_upd_voreinstellungen.
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
* 30.07.2002 Erstellung
*-----------------------------------------------------------------------
* WA
  DATA: wa_voreinstell LIKE zcl_voreinstell.
  DATA: wa_repro_cl_ini LIKE zcl_repro_cl_ini.
* NORMAL
  DATA: count TYPE i.
  DATA: tmp_str(10).
  DATA: tmp_keyname(30).
  DATA: tmp_split(30).
  DATA: split1(30).
  DATA: split2(30).


  DELETE FROM zcl_voreinstell
    WHERE  uname = i_uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
    WHERE uname = i_uname
    AND sektor = '[Voreinstellung]'
    AND keyname = 'Zeilen'.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i052(zcl_plint_tools)
      WITH 'zcl_repro_cl_ini' i_uname
      '[Voreinstellung]' 'Zeilen'
      RAISING error.
  ELSE.
  ENDIF.

  CLEAR count.
  count = wa_repro_cl_ini-keywert.
  CLEAR wa_voreinstell.
  wa_voreinstell-uname = i_uname.

  DO count TIMES.
    CLEAR tmp_keyname.
    tmp_str = sy-index - 1.
    CONCATENATE 'Wert' tmp_str '/' '0' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-voreinstellung = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '1' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-ausgabegeraet = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '2' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-zielformat = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '3' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-skalieren_x = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '4' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-skalieren_y = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '5' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-medium = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '6' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-drehen = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '7' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-spiegeln = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '8' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-verschiebung = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '9' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
*      tmp_split = wa_repro_cl_ini-keywert.
*      SPLIT wa_repro_cl_ini-keywert AT ',' INTO
*        split1 split2.
      wa_voreinstell-kopien = wa_repro_cl_ini-keywert.
*      wa_voreinstell-kopien = split1.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '10' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-falten = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '11' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-lochen = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '12' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-heftrand = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '13' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-stempel = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '14' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-format_ausgabe = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '15' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-ausrichtung = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '16' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-aufloesung = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '17' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-typ = wa_repro_cl_ini-keywert.
    ENDIF.

    CONCATENATE 'Wert' tmp_str '/' '18' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repro_cl_ini INTO wa_repro_cl_ini
      WHERE uname = i_uname
      AND sektor = '[Voreinstellung]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repro_cl_ini' i_uname
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_voreinstell-stifttabelle = wa_repro_cl_ini-keywert.
    ENDIF.

    REPLACE '°' WITH '' INTO  wa_voreinstell-drehen.

    wa_voreinstell-zclinsname = sy-uname.
    wa_voreinstell-zclinsdate = sy-datum.
    wa_voreinstell-zclinstime = sy-uzeit.
    wa_voreinstell-zclinsprog = sy-repid.
    wa_voreinstell-zclupdname  = sy-uname.
    wa_voreinstell-zclupddate = sy-datum.
    wa_voreinstell-zclupdtime = sy-uzeit.
    wa_voreinstell-zclupdprog = sy-repid.


*   Update ZCL_Voreinstell
    MODIFY zcl_voreinstell FROM wa_voreinstell.
    IF sy-subrc NE 0.
      MESSAGE i051(zcl_plint_tools)
        WITH 'zcl_voreinstell' i_uname
        wa_voreinstell-voreinstellung ''
        RAISING error.
    ELSE.
    ENDIF.

  ENDDO.

  message i053(zcl_plint_tools) with '' '' '' ''.

ENDFUNCTION.
