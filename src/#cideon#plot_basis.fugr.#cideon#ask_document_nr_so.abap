FUNCTION /cideon/ask_document_nr_so.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_DOKNR) TYPE  DOKNR
*"     VALUE(O_DOKAR) TYPE  DOKAR
*"     VALUE(O_DOKVR) TYPE  DOKVR
*"     VALUE(O_DOKTL) TYPE  DOKTL_D
*"     VALUE(O_AENNR) TYPE  AENNR
*"     VALUE(O_CCDAT) TYPE  CCDAT
*"     VALUE(O_LINKS) TYPE  CHAR1
*"  TABLES
*"      IO_SO_DOKAR STRUCTURE  RSDSSELOPT
*"      IO_CHARVAL STRUCTURE  BAPI_CHARACTERISTIC_VALUES OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 02.02.2004  - creation / copy
* 29.01.2005  - Einbindung EXIT / Abbrechen ohne Bildschirmprüfung
* 26.04.2005  - Kopie
* 06.08.2007 - SP 45
*            - Eingabe Klassifikationswerte
*            - Auslesen von Klassendaten
*            - Suchdialog für Dokumente über CV04N
*-----------------------------------------------------------------------
* toDo
*
* Beschreibung für Klassifikationsmerkmal einbinden
*-----------------------------------------------------------------------
  DATA: atinn TYPE atinn.

  CLEAR wa_zcl_s_draw01.

* Klassifikationsinformationen mappen
  DATA: wa_charval TYPE bapi_characteristic_values.

  CLEAR wa_charval.
  READ TABLE io_charval INTO wa_charval INDEX 1.
  IF sy-subrc NE 0.
  ELSE.
    wa_zcl_s_draw01-classtype = wa_charval-classtype.
    wa_zcl_s_draw01-classname = wa_charval-classname.
    wa_zcl_s_draw01-charname = wa_charval-charname.
    wa_zcl_s_draw01-charvalue = wa_charval-charvalue.

    CLEAR atinn.
    SELECT SINGLE atinn FROM cabn
      INTO atinn
      WHERE atnam = wa_charval-charname
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE atbez FROM cabnt
      INTO wa_zcl_s_draw01-charbez
      WHERE atinn = atinn
      AND spras = sy-langu
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDIF.

  CLEAR wa_charval.
  READ TABLE io_charval INTO wa_charval INDEX 2.
  IF sy-subrc NE 0.
  ELSE.
    wa_zcl_s_draw01-classtype_2 = wa_charval-classtype.
    wa_zcl_s_draw01-classname_2 = wa_charval-classname.
    wa_zcl_s_draw01-charname_2 = wa_charval-charname.
    wa_zcl_s_draw01-charvalue_2 = wa_charval-charvalue.

    CLEAR atinn.
    SELECT SINGLE atinn FROM cabn
      INTO atinn
      WHERE atnam = wa_charval-charname
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE atbez FROM cabnt
      INTO wa_zcl_s_draw01-charbez_2
      WHERE atinn = atinn
      AND spras = sy-langu
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDIF.

  CLEAR: doknr.
  CLEAR: g_draw_doknr.
  CLEAR: dokar.
  CLEAR: g_draw_dokar.
  CLEAR: doktl.
  CLEAR: g_draw_doktl.
  CLEAR: dokvr.
  CLEAR: g_draw_dokvr.

  CLEAR: aennr.
  CLEAR: g_aennr.
  CLEAR: ccdat.
  CLEAR: g_ccdat.

*  set parameter id 'CV1' field doknr.
*  SET PARAMETER ID 'CV2' FIELD dokar.
*  SET PARAMETER ID 'CV3' FIELD dokvr.
*  SET PARAMETER ID 'CV4' FIELD doktl.

* Übergabe von SO
  CLEAR so_dokar.

  so_dokar[] = io_so_dokar[].


  CALL SCREEN 650 STARTING AT 10 10 ENDING AT 113 22.

  IF ok_code = 'OK'.
*   Klassifikation zurückgeben
    REFRESH io_charval.
    CLEAR wa_charval.

    wa_charval-charname = wa_zcl_s_draw01-charname.
    wa_charval-charvalue = wa_zcl_s_draw01-charvalue.
    APPEND wa_charval TO io_charval.

    CLEAR wa_charval.
    wa_charval-charname = wa_zcl_s_draw01-charname_2.
    wa_charval-charvalue = wa_zcl_s_draw01-charvalue_2.
    APPEND wa_charval TO io_charval.
  ELSE.
  ENDIF.


  IF g_draw_doknr IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.
  IF g_draw_dokar IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.
  IF g_draw_dokvr IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.
  IF g_draw_doktl IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.


  o_doknr = g_draw_doknr.
  o_dokar = g_draw_dokar.
  o_doktl = g_draw_doktl.
  o_dokvr = g_draw_dokvr.

  o_aennr = g_aennr.
  o_ccdat = g_ccdat.

  o_links = cb_links.

  CLEAR io_so_dokar.

  io_so_dokar[] = so_dokar[].


ENDFUNCTION.
