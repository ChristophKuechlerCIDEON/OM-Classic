*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_DOC_LISTS_FB03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_prst_bom
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_prst_bom.
* Stückliste für PSP BOM holen
  DATA: wa_topmat TYPE cstmat.

  CLEAR it_stb.

  CALL FUNCTION 'CS_BOM_EXPL_PSP_V1'
    EXPORTING
*   ALTVO                       = ' '
*   AMIND                       = ' '
*   AUFSW                       = ' '
*   AUMGB                       = ' '
*   AUMNG                       =
*   AUSKZ                       = ' '
*   BAGRP                       = ' '
*   BEIKZ                       = ' '
*   BESSL                       = ' '
*   BGIXO                       = ' '
*   BREMS                       = ' '
      capid                       = 'PP01'
*   CHLST                       = ' '
*   COSPR                       = ' '
*   CUOBJ                       = 000000000000000
*   CUOVS                       = 0
*   CUOLS                       = ' '
    datuv                       = sy-datum
*   DELNL                       = ' '
*   DRLDT                       = ' '
*   DRSTP                       = ' '
*   EHNDL                       = ' '
*   EMENG                       = 0
*   ERSKZ                       = ' '
*   ERSSL                       = ' '
*   FBSTP                       = ' '
*   FTREL                       = ' '
*   KNFBA                       = ' '
*   KSBVO                       = ' '
*   MBWLS                       = ' '
*   MDMPS                       = ' '
*   MDNOT                       = ' '
    mehrs                       = 'X'
*   MKMAT                       = ' '
*   MKTLS                       = 'X'
*   MMAPS                       = ' '
*   MMORY                       = ' '
      mtnrv                       = wa_rc29l-matnr
*   NESTP                       = ' '
*   NLINK                       = ' '
*   NPSTP                       = ' '
*   PANOT                       = ' '
*   PBSTP                       = ' '
*   POSTP                       = ' '
      pspnr                       = wa_rc29l-pspnr
*   QVERW                       = ' '
*   RNDKZ                       = ' '
*   RVREL                       = ' '
*   SANFR                       = ' '
*   SANIN                       = ' '
*   SANKA                       = ' '
*   SANKO                       = ' '
*   SANVS                       = ' '
*   SCHGT                       = ' '
*   SALWW                       = ' '
*   SPLWW                       = ' '
*   STKKZ                       = ' '
*   STLAL                       = ' '
*      stlan                       = wa_rc29l-stlan
*   STPST                       = 0
*   SVWVO                       = 'X'
*   VERID                       = ' '
*   VRSVO                       = 'X'
     werks                       = wa_rc29l-werks
*   NORVL                       = ' '
*  importing
*    topmat                      = wa_topmat
*   DSTST                       =
    TABLES
      stb                         = it_stb
*   MATCAT                      =
   EXCEPTIONS
     alt_not_found               = 1
     call_invalid                = 2
     material_not_found          = 3
     missing_authorization       = 4
     no_bom_found                = 5
     no_plant_data               = 6
     no_suitable_bom_found       = 7
     conversion_error            = 8
     OTHERS                      = 9
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " get_prst_bom
*&---------------------------------------------------------------------*
*&      Form  fill_xls
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM
fill_xls.
* Excel Datei ausfüllen
* Excel aufrufen
  CLEAR error.
  CALL METHOD c_oi_container_control_creator=>get_container_control
                     IMPORTING control = control
                               error = error.

  CALL METHOD control->init_control
                      EXPORTING r3_application_name =
                                           'Basis'          "#EC NOTEXT
                                inplace_enabled = ''
                                inplace_scroll_documents = 'X'
                                parent = container
                                register_on_close_event = 'X'
                                register_on_custom_event = 'X'
                                no_flush = 'X'
                      IMPORTING error = error.

  CLEAR document.
  CLEAR error.
  CALL METHOD control->get_document_proxy
             EXPORTING document_type = 'Excel.Sheet'
             IMPORTING document_proxy = document
                       error = error.
* Datei laden

  DATA file TYPE filep.
  CLEAR file.
  CONCATENATE 'file://'  wa_mdr_tr-mdf_template
    INTO file.

  CLEAR error.
  CALL METHOD document->open_document
    EXPORTING
*    DOCUMENT_TITLE   = ' '
      document_url     = file

*    NO_FLUSH         = ' '
*    OPEN_INPLACE     = ' '
*    OPEN_READONLY    = ' '
*    PROTECT_DOCUMENT = ' '
*    STARTUP_MACRO    = ''
*    USER_INFO        =
*    ONSAVE_MACRO     =
     IMPORTING
       error            = error
*     RETCODE          =
      .
*

  CLEAR sheet.
  CALL METHOD document->get_spreadsheet_interface
        IMPORTING
               sheet_interface = sheet.


  DATA sheets TYPE soi_sheets_table.

* GET_ACTIVE_SHEET
  CLEAR error.
  CLEAR sheets.
* GET_SHEETS
  CALL METHOD sheet->get_sheets
    EXPORTING
      no_flush = ' '
      updating = -1
    IMPORTING
      sheets   = sheets
      error    = error
*      RETCODE  =
      .

  CLEAR error.
  CALL METHOD sheet->select_sheet
    EXPORTING
      name     = 'Header Input'
*    NO_FLUSH = ' '
     IMPORTING
       error    = error
*    RETCODE  =
      .

*  PERFORM fill_range.
*  PERFORM fill_range_def USING '7' '2' '1' '1'.
*  PERFORM fill_content USING '1' '1' ':-)'.
*
*  PERFORM set_data.


*  BADI Aufruf
  IF badi_om_ps_01 IS INITIAL.
*    CALL METHOD cl_exithandler=>get_instance
*      CHANGING
*        instance = badi_om_ps_01.
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.
  ELSE.
    CALL METHOD badi_om_ps_01->chg_mdf_data
      CHANGING
        sheet        = sheet
        document     = document
        lt_range_def = lt_range_def
        lt_contents  = lt_contents
        wa_mdr_tr    = wa_mdr_tr
        it_doc       = it_doc
        .

  ENDIF.






* Meldung wegen Speichern
  MESSAGE i004(/cideon/plot_ps) WITH '' '' '' ''.
*   Bitte speichern Sie das MFR. & & & &




* Excel schließen
  IF NOT document IS INITIAL.
    CALL METHOD document->release_document.
    FREE document.
  ENDIF.
  IF NOT control IS INITIAL.
    CALL METHOD control->destroy_control.
    FREE control.
  ENDIF.

ENDFORM.                    " fill_xls
*&---------------------------------------------------------------------*
*&      Form  fill_range
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_range.

ENDFORM.                    " fill_range
*&---------------------------------------------------------------------*
*&      Form  fill_range_def
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_range_def USING row column rows columns.
  CLEAR lt_range_def.
  CLEAR lc_range_def.

  lc_range_def-row = row.
  lc_range_def-column = column.
  lc_range_def-rows = rows.
  lc_range_def-columns = columns.

  APPEND lc_range_def TO lt_range_def.

ENDFORM.                    " fill_range_def
*&---------------------------------------------------------------------*
*&      Form  fill_content
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_content USING row column value.
  CLEAR lt_contents.
  CLEAR lc_contents.
  lc_contents-row =  row.
  lc_contents-column = column.
  lc_contents-value = value.

  APPEND lc_contents TO lt_contents.



ENDFORM.                    " fill_content
*&---------------------------------------------------------------------*
*&      Form  set_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_data.
  CLEAR error.
  CALL METHOD sheet->set_ranges_data
    EXPORTING
*    NO_FLUSH  = ' '
      ranges    = lt_ranges
      contents  = lt_contents
       updating  = '-1'
      rangesdef = lt_range_def
    IMPORTING
      error     = error
*    RETCODE   =
      .

ENDFORM.                    " set_data
*&---------------------------------------------------------------------*
*&      Form  get_doc_for_bom
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_doc_for_bom.
* Dokumente für die BOM holen
* PSP Stückliste

  IF it_stb[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR it_doc.

  LOOP AT it_stb INTO wa_stb.
    CASE wa_stb-postp.
      WHEN 'P'.
        PERFORM get_doc_links.
      WHEN 'N'.
        PERFORM get_doc_links.
      WHEN 'L'.
        PERFORM get_doc_links.
      WHEN 'D'.
        APPEND wa_stb TO it_doc.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " get_doc_for_bom
*&---------------------------------------------------------------------*
*&      Form  get_doc_links
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_doc_links.
* Dokumentenverknüpfungen holen
  DATA: lt_drad TYPE TABLE OF drad.
  DATA: lc_drad TYPE drad.

  CLEAR lt_drad.
  SELECT * FROM drad INTO TABLE lt_drad
           WHERE dokob = 'MARA'
           AND objky = wa_stb-idnrk
           .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT lt_drad INTO lc_drad.
    wa_stb-dokar = lc_drad-dokar.
    wa_stb-doknr = lc_drad-doknr.
    wa_stb-doktl = lc_drad-doktl.
    wa_stb-dokvr = lc_drad-dokvr.
    APPEND wa_stb TO it_doc.
  ENDLOOP.


ENDFORM.                    " get_doc_links
*&---------------------------------------------------------------------*
*&      Form  make_doctab_from_bom
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_doctab_from_bom.
* aus it_doc it_objects machen

  CLEAR it_objects.
  CLEAR wa_objects.

  LOOP AT it_doc INTO wa_doc.
    CLEAR wa_objects.

    MOVE-CORRESPONDING wa_doc TO wa_objects.

    wa_objects-matnr = wa_doc-idnrk.

    wa_objects-pspnr = wa_prps-pspnr.
    wa_objects-projn = wa_prps-psphi.

    wa_objects-object_type = 'DOCUMENT'.

    wa_objects-psp_hierachy = wa_mdr_tr-posid..
    APPEND wa_objects TO it_objects.

  ENDLOOP.
*  MOVE-CORRESPONDING wa_doktab TO wa_objects.
*
*  wa_objects-pspnr = wa_prps-pspnr.
*  wa_objects-projn = wa_prps-psphi.
*
*  wa_objects-object_type = 'DOCUMENT'.
*
*  wa_objects-psp_hierachy = tmp_hr.
*
*  APPEND wa_objects TO it_objects.
ENDFORM.                    " make_doctab_from_bom
