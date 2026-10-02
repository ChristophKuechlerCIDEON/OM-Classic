FUNCTION z_cl_upd_preprozessor_verteile.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PREPROZESSOR) TYPE  ZCL_NAME_PREPROZESSOR
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
* 02.12.2005 - COMIT Problem / SAP DB
*-----------------------------------------------------------------------
* WA
  DATA: wa_preprozessor LIKE zcl_preprozessor.
  DATA: wa_repcl_ini_pr LIKE zcl_repcl_ini_pr.
  DATA: wa_preprozessor_2 LIKE zcl_preprozessor.
* NORMAL
  DATA: count TYPE i.
  DATA: tmp_str(10).
  DATA: tmp_keyname(30).


  CLEAR wa_preprozessor_2.
  SELECT * FROM zcl_preprozessor
    INTO wa_preprozessor_2
    WHERE preprozessor = i_preprozessor
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR wa_preprozessor_2.
  ELSE.
  ENDIF.


* PreProzessoren bereinigen
  DELETE FROM zcl_preprozessor
    WHERE preprozessor = i_preprozessor
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


  SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
    WHERE preprozessor = i_preprozessor
    AND sektor = '[Verteiler]'
    AND keyname = 'Zeilen'.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i052(zcl_plint_tools)
      WITH 'zcl_repcl_ini_pr' i_preprozessor
      '[Verteiler]' 'Zeilen'
      RAISING error.
  ELSE.
  ENDIF.

  CLEAR count.
  count = wa_repcl_ini_pr-keywert.
  CLEAR wa_preprozessor.
  wa_preprozessor-preprozessor = i_preprozessor.

  DO count TIMES.
    CLEAR tmp_keyname.
    tmp_str = sy-index - 1.
    CONCATENATE 'Wert' tmp_str '/' '0' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
      WHERE preprozessor = i_preprozessor
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repcl_ini_pr' i_preprozessor
        '[Voreinstellung]' tmp_keyname
        RAISING error.
    ELSE.
      wa_preprozessor-verteiler = wa_repcl_ini_pr-keywert.
    ENDIF.

*   Beschreibung
    CONCATENATE 'Wert' tmp_str '/' '1' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
      WHERE preprozessor = i_preprozessor
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repcl_ini_pr' i_preprozessor
        '[Verteiler]' tmp_keyname
        RAISING error.
    ELSE.
      wa_preprozessor-beschreibung = wa_repcl_ini_pr-keywert.
    ENDIF.

*   Satzanzahl
    CONCATENATE 'Wert' tmp_str '/' '2' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
      WHERE preprozessor = i_preprozessor
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repcl_ini_pr' i_preprozessor
        '[Verteiler]' tmp_keyname
        RAISING error.
    ELSE.
      wa_preprozessor-satzanzahl = wa_repcl_ini_pr-keywert.
    ENDIF.

*   Deckblatt
    CONCATENATE 'Wert' tmp_str '/' '3' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
      WHERE preprozessor = i_preprozessor
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repcl_ini_pr' i_preprozessor
        '[Verteiler]' tmp_keyname
        RAISING error.
    ELSE.
      wa_preprozessor-deckblatt = wa_repcl_ini_pr-keywert.
    ENDIF.

*   Endelatt
    CONCATENATE 'Wert' tmp_str '/' '4' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
      WHERE preprozessor = i_preprozessor
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repcl_ini_pr' i_preprozessor
        '[Verteiler]' tmp_keyname
        RAISING error.
    ELSE.
      wa_preprozessor-endeblatt = wa_repcl_ini_pr-keywert.
    ENDIF.

*   Kennzeichen Inhaltsverzeichnis
    CONCATENATE 'Wert' tmp_str '/' '5' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
      WHERE preprozessor = i_preprozessor
      AND sektor = '[Verteiler]'
      AND keyname = tmp_keyname.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_repcl_ini_pr' i_preprozessor
        '[Verteiler]' tmp_keyname
        RAISING error.
    ELSE.
      wa_preprozessor-knz_inhalt_vz = wa_repcl_ini_pr-keywert.
    ENDIF.

**   Scanpfad für PreProzessor
*    SELECT * FROM zcl_repcl_ini_pr INTO wa_repcl_ini_pr
*      WHERE preprozessor = i_preprozessor
*      AND sektor = '[ClientScan]'
*      AND keyname = 'PfadCV'.
*    ENDSELECT.
*    IF sy-subrc NE 0.
*      MESSAGE i052(zcl_plint_tools)
*        WITH 'zcl_repcl_ini_pr' i_preprozessor
*        '[ClientScan]' 'PfadCV'
*        RAISING error.
*    ELSE.
*      wa_preprozessor-klient_scan_pfad = wa_repcl_ini_pr-keywert.
*    ENDIF.


*   Info
    wa_preprozessor-zclinsname = sy-uname.
    wa_preprozessor-zclinsdate = sy-datum.
    wa_preprozessor-zclinstime = sy-uzeit.
    wa_preprozessor-zclinsprog = sy-repid.
    wa_preprozessor-zclupdname  = sy-uname.
    wa_preprozessor-zclupddate = sy-datum.
    wa_preprozessor-zclupdtime = sy-uzeit.
    wa_preprozessor-zclupdprog = sy-repid.

*   alte Scanpfade etc. bei schon vorhandenem PreProzessor
    wa_preprozessor-klient_scan_pfad =
      wa_preprozessor_2-klient_scan_pfad.
    wa_preprozessor-klient_down_pfad =
      wa_preprozessor_2-klient_down_pfad.

*   Update zcl_preprozessor
    MODIFY zcl_preprozessor FROM wa_preprozessor.
    IF sy-subrc NE 0.
      MESSAGE i051(zcl_plint_tools)
        WITH 'zcl_preprozessor' i_preprozessor
        wa_preprozessor-verteiler ''
        RAISING error.
    ELSE.
    ENDIF.

  ENDDO.

  COMMIT WORK AND WAIT.
  MESSAGE i054(zcl_plint_tools) WITH '' '' '' ''.

ENDFUNCTION.
