FUNCTION /cideon/ask_matnr_so.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_AENNR) TYPE  AENNR
*"     VALUE(O_CCDAT) TYPE  CCDAT
*"     VALUE(O_LINKS) TYPE  CHAR1
*"     VALUE(O_MATNR) TYPE  MATNR
*"     VALUE(O_CAPID) TYPE  CAPID
*"     VALUE(O_STUFE) TYPE  HISTU
*"     VALUE(O_F_CS03) TYPE  CHAR1
*"     VALUE(O_F_CS11) TYPE  CHAR1
*"     VALUE(O_F_CS12) TYPE  CHAR1
*"     VALUE(O_F_CS13) TYPE  CHAR1
*"     VALUE(O_SMARTFORM_CS02) TYPE  /CIDEON/SMARTFORM_CS02
*"     VALUE(O_SMARTFORM_CS11) TYPE  /CIDEON/SMARTFORM_CS11
*"     VALUE(O_SMARTFORM_CS12) TYPE  /CIDEON/SMARTFORM_CS12
*"     VALUE(O_SMARTFORM_CS13) TYPE  /CIDEON/SMARTFORM_CS13
*"     VALUE(O_SMARTFORM_CS02_SPR) TYPE  /CIDEON/SMARTFORM_CS02_SPR
*"     VALUE(O_SMARTFORM_CS11_SPR) TYPE  /CIDEON/SMARTFORM_CS11_SPR
*"     VALUE(O_SMARTFORM_CS12_SPR) TYPE  /CIDEON/SMARTFORM_CS12_SPR
*"     VALUE(O_SMARTFORM_CS13_SPR) TYPE  /CIDEON/SMARTFORM_CS13_SPR
*"     VALUE(O_WHERE_USED) TYPE  CHAR1
*"     VALUE(O_DELETE_DUPLICATES) TYPE  CHAR1
*"     VALUE(O_F_VALID_DOCS) TYPE  CHAR1
*"  TABLES
*"      IO_SO_DOKAR STRUCTURE  RSDSSELOPT
*"      IO_SO_DOKAR_LINKS STRUCTURE  RSDSSELOPT
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
* 13.06.2005  - Kopie / Anpassung an Materialnummer
* 15.06.2005  - neue SELECT-OPTIONS
* 24.07.2006  - Integration Materialstücklistendruck
* 28.11.2006  - Flags für
*               - where_used
*               - delete_duplicates
*-----------------------------------------------------------------------
* toDo
*   - Stücklistenlayouts integrieren / SmartForms
*-----------------------------------------------------------------------
  DATA: user_data TYPE /cideon/plot_userdata.
  DATA: default_data TYPE /cideon/plot_defaultdata.

  DATA: atinn TYPE atinn.

* Einstellungen lesen
  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = ''
       IMPORTING
            o_default_data = default_data.

  CLEAR user_data.
  user_data-uname = sy-uname.

  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = default_data
       IMPORTING
            o_user_data    = user_data.


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

  CLEAR: matnr.
  CLEAR: g_matnr.
  CLEAR: capid.
  CLEAR: g_capid.
  CLEAR: stufe.
  CLEAR: g_stufe.

  CLEAR: aennr.
  CLEAR: g_aennr.
  CLEAR: ccdat.
  CLEAR: g_ccdat.

  ccdat = sy-datum.
  g_ccdat = sy-datum.

  CLEAR g_smartform_cs02.
  CLEAR g_smartform_cs11.
  CLEAR g_smartform_cs12.
  CLEAR g_smartform_cs13.

  g_smartform_cs02 = user_data-smartform_cs02.
  g_smartform_cs11 = user_data-smartform_cs11.
  g_smartform_cs12 = user_data-smartform_cs12.
  g_smartform_cs13 = user_data-smartform_cs13.

  capid = user_data-mat_capid.
  g_capid = capid.

  stufe = user_data-mat_stpst.
  g_stufe = stufe.

*  set parameter id 'CV1' field doknr.
*  SET PARAMETER ID 'CV2' FIELD dokar.
*  SET PARAMETER ID 'CV3' FIELD dokvr.
*  SET PARAMETER ID 'CV4' FIELD doktl.

  SET PARAMETER ID 'CSA' FIELD capid.

  g_smartform_cs02_spr = sy-langu.
  g_smartform_cs11_spr = sy-langu.
  g_smartform_cs12_spr = sy-langu.
  g_smartform_cs13_spr = sy-langu.

* Übergabe von SO
  CLEAR so_dokar.

  so_dokar[] = io_so_dokar[].

* Dynpro aufrufen
  CALL SCREEN 675 STARTING AT 10 5 ENDING AT 110 26.

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

  IF g_matnr IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.
  IF g_capid IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.

  o_matnr = g_matnr.
  o_capid = g_capid.
  o_stufe = g_stufe.

  o_aennr = g_aennr.
  o_ccdat = g_ccdat.

  o_links = cb_links.
  o_where_used = cb_where_used.
  o_delete_duplicates = cb_delete_duplicates.
  o_f_valid_docs = cb_valid_docs.


  o_f_cs03 = f_cs03.
  o_f_cs11 = f_cs11.
  o_f_cs12 = f_cs12.
  o_f_cs13 = f_cs13.


  o_smartform_cs02 = g_smartform_cs02.
  o_smartform_cs11 = g_smartform_cs11.
  o_smartform_cs12 = g_smartform_cs12.
  o_smartform_cs13 = g_smartform_cs13.

  o_smartform_cs02_spr = g_smartform_cs02_spr.
  o_smartform_cs11_spr = g_smartform_cs11_spr.
  o_smartform_cs12_spr = g_smartform_cs12_spr.
  o_smartform_cs13_spr = g_smartform_cs13_spr.

  "o_f_valid_docs = g_f_valid_docs.

  CLEAR io_so_dokar.

  io_so_dokar[] = so_dokar[].
  io_so_dokar_links[] = so_dokar_links[].


ENDFUNCTION.
