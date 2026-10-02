FUNCTION /cideon/note_dir_create.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_STORAGECAT) TYPE  CV_STORAGE_CAT
*"  CHANGING
*"     REFERENCE(WA_DRAW) TYPE  DRAW
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*       CIDEON Software GmbH
*       Peterstraße 1
*       02826 Görlitz
*-----------------------------------------------------------------------
* Anlegen eines DIS nach Vorlage
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           Chris@christoph-kuechler.de
*
* Übernahme großer Teile des Quelltextes von Dr. Peter Rabe
*-----------------------------------------------------------------------
* Journal
* 15.08.2007 - Erstellung
*
*-----------------------------------------------------------------------
* toDo
*  BADI für Änderungen bei der Dokumentenanlage vorsehen
*-----------------------------------------------------------------------

* ITAB
  DATA: lt_char_val TYPE TABLE OF bapi_characteristic_values.
  DATA: lt_class_alloc TYPE TABLE OF bapi_class_allocation.
  DATA: lt_doc_desc TYPE TABLE OF bapi_doc_drat.
  DATA: lt_obj_lnk TYPE TABLE OF bapi_doc_drad.
  DATA: lt_longtexts TYPE TABLE OF bapi_doc_text.
  DATA: lt_documentfiles TYPE TABLE OF bapi_doc_files2.
  DATA: lt_current_files TYPE TABLE OF bapi_doc_files2.

* WA
  DATA: ls_document_data TYPE draw_rfc.
  DATA: ls_tdwa TYPE tdwa.
  DATA: ls_documentdata TYPE bapi_doc_draw2,
        ls_new_document TYPE bapi_doc_aux,
        ls_return TYPE bapiret2.
  DATA: ls_frontend TYPE dms_frontend_data.
  DATA: ls_tdwp TYPE tdwp.
  DATA: ls_documentfiles TYPE bapi_doc_files2.
  DATA: ls_draw TYPE draw.
  DATA: ls_documents TYPE plm_document.
  DATA: ls_doc_file	TYPE	dms_doc_file.
  DATA:  ls_phio	TYPE	dms_phio.
  DATA: lf_create.
  DATA: lf_appltype TYPE  apptp VALUE '2'.
  DATA: lf_dokst	TYPE	draw-dokst.
  DATA: lf_stabk	TYPE	tdwst-stabk.
  DATA: lf_dostx	TYPE	tdwst-dostx.
  DATA: ls_documentdatax TYPE bapi_doc_drawx2.



* NORMAL
  DATA: lc_hostname TYPE ntadr.
  DATA: lc_path     TYPE draw-filep.
  DATA: l_documentnumber(25).
  DATA: lfd_nr VALUE 1.



*  Check ob Dokumentart gepflegt:
  CLEAR ls_document_data.
  CLEAR ls_tdwa.

  ls_document_data-dokar = wa_draw-dokar.


  CALL FUNCTION 'CV200_DB_TDWA_SELECT'
  EXPORTING
    pf_dokar              = ls_document_data-dokar
*       PF_USE_BUFFER         = 'X'
*       PF_LANG               = SY-LANGU
*       PF_READ_TDWS          = ' '
  IMPORTING
    psx_tdwa              = ls_tdwa
*       PFX_DESCRIPTION       =
*     TABLES
*       PTX_TDWS              =
  EXCEPTIONS
    not_found             = 1
    OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE e054(/cideon/note_dir) WITH ls_document_data-dokar.
  ENDIF.
  IF ls_tdwa-def_application IS INITIAL.
    MESSAGE e053(/cideon/note_dir) WITH ls_document_data-dokar.
  ENDIF.

  CLEAR ls_return.
  CLEAR ls_new_document.
  CLEAR lt_char_val.
  CLEAR lt_class_alloc.
  CLEAR lt_doc_desc.
  CLEAR lt_obj_lnk.
  CLEAR lt_longtexts.

  CLEAR ls_documentdata.
  ls_documentdata-documenttype = wa_draw-dokar.
  ls_documentdata-documentnumber = wa_draw-doknr.
  ls_documentdata-documentpart = wa_draw-doktl.
  ls_documentdata-documentversion = wa_draw-dokvr.

  CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
    EXPORTING
      documentdata               = ls_documentdata
*         HOSTNAME                   =
*         DOCBOMCHANGENUMBER         =
*         DOCBOMVALIDFROM            =
*         DOCBOMREVISIONLEVEL        =
*         CAD_MODE                   = ' '
*         PF_FTP_DEST                = ' '
*         PF_HTTP_DEST               = ' '
    IMPORTING
      documenttype               = ls_new_document-doctype
      documentnumber             = ls_new_document-docnumber
      documentpart               = ls_new_document-docpart
      documentversion            = ls_new_document-docversion
      return                     = ls_return
        TABLES
         characteristicvalues       = lt_char_val
         classallocations           = lt_class_alloc
         documentdescriptions       = lt_doc_desc
         objectlinks                = lt_obj_lnk
*         DOCUMENTSTRUCTURE          =
*         DOCUMENTFILES              =
          longtexts                  = lt_longtexts
*         COMPONENTS                 =
            .

  IF NOT ls_return-type CA 'EA'.
    CLEAR ls_return.
    COMMIT WORK AND WAIT.

    MESSAGE s035(/cideon/note_dir)
    WITH ls_new_document-doctype ls_new_document-docnumber
         ls_new_document-docpart ls_new_document-docversion.
  ELSE.
    CLEAR ls_return.
    ROLLBACK WORK.

    MESSAGE e005(/cideon/note_dir).
  ENDIF.

* Office Original anlegen
  CALL FUNCTION 'CV120_GET_FRONTEND_TYPE'
*    EXPORTING
*      PF_CALL_DIALOG          = ' '
*      PF_BATCH                = ' '
*      PF_HOST                 = ' '
   IMPORTING
     pfx_frontend_type       = ls_frontend-frontend_type
     pfx_host                = lc_hostname
*      PFX_WINSYS              =
   EXCEPTIONS
     error                   = 1
     no_valid_frontend       = 2
     OTHERS                  = 3
            .
  IF sy-subrc <> 0.
    MESSAGE e004(/cideon/note_dir).
  ENDIF.

  CLEAR ls_tdwa.
  CALL FUNCTION 'CV200_DB_TDWA_SELECT'
  EXPORTING
    pf_dokar              = ls_documentdata-documenttype
*     PF_USE_BUFFER         = 'X'
*     PF_LANG               = SY-LANGU
*     PF_READ_TDWS          = ' '
  IMPORTING
    psx_tdwa              = ls_tdwa
*     PFX_DESCRIPTION       =
*   TABLES
*     PTX_TDWS              =
  EXCEPTIONS
    not_found             = 1
    OTHERS                = 2
          .
  IF sy-subrc <> 0.
    MESSAGE e004(/cideon/note_dir).
  ENDIF.
  IF ls_tdwa-def_application IS INITIAL.
    MESSAGE e053(/cideon/note_dir) WITH ls_documentdata-documenttype.
  ENDIF.


  CALL FUNCTION 'CV200_DB_TDWP_SELECT'
    EXPORTING
      pf_dappl            = ls_tdwa-def_application
*       PF_USE_BUFFER       = 'X'
   IMPORTING
     psx_tdwp            = ls_tdwp
   EXCEPTIONS
     not_found           = 1
     OTHERS              = 2
            .
  IF sy-subrc <> 0.
    MESSAGE e004(/cideon/note_dir).
  ENDIF.

  CALL FUNCTION 'CV119_APPL_GET_WORKPATH'
       EXPORTING
            pf_dappl    = ls_tdwa-def_application
            pf_user     = sy-uname
            pf_hostname = lc_hostname
       IMPORTING
            pfx_path    = lc_path.

  IF lc_path IS INITIAL.
    CALL FUNCTION 'WS_QUERY'
      EXPORTING
*         ENVIRONMENT          =
*         FILENAME             =
        query                = 'CD'
*         WINID                =
      IMPORTING
        return               = lc_path
      EXCEPTIONS
        inv_query            = 1
        no_batch             = 2
        frontend_error       = 3
        OTHERS               = 4
              .
    IF sy-subrc <> 0.
      MESSAGE e004(/cideon/note_dir).
    ENDIF.
  ENDIF.

  ls_documentdata-documenttype = ls_new_document-doctype.
  ls_documentdata-documentnumber = ls_new_document-docnumber.
  ls_documentdata-documentpart = ls_new_document-docpart.
  ls_documentdata-documentversion = ls_new_document-docversion.

  WRITE ls_documentdata-documentnumber TO l_documentnumber NO-ZERO.
  CONCATENATE  ls_documentdata-documenttype '-'
               l_documentnumber '-'
               ls_documentdata-documentpart '-'
               ls_documentdata-documentversion '_'
               lfd_nr '.' ls_tdwp-appsfx
               INTO ls_documentdata-docfile1.
  CONDENSE ls_documentdata-docfile1 NO-GAPS.

  MOVE: ls_documentdata-docfile1 TO gc_docfile,
        ls_documentdata-docfile1 TO ls_documentfiles-docfile.

  IF lc_path CP '*\'.
    CONCATENATE lc_path ls_documentdata-docfile1
    INTO ls_documentdata-docfile1.
  ELSE.
    CONCATENATE lc_path '\' ls_documentdata-docfile1
    INTO ls_documentdata-docfile1.
  ENDIF.

  CALL FUNCTION 'CV120_DOC_FILE_FROM_TEMPLATE'
    EXPORTING
      pf_check_file           = 'X'
      pf_touch_file           = space
      pf_read_data            = space
      pf_typdt                = ls_frontend-frontend_type
*       PS_TCZ02                =
      pf_dokar                = ls_documentdata-documenttype
      pf_dappl                = ls_tdwa-def_application
      pf_file                 = ls_documentdata-docfile1
*     IMPORTING
*       PFX_TEMPLATE            =
*       PFX_FILE_EXIST          =
*       PFX_TEMPLATE_DESC       =
    EXCEPTIONS
      error                   = 1
      OTHERS                  = 2
      .


  ls_documents-docfile1 = ls_documentdata-docfile1.

  MOVE: ls_documents-docfile1 TO ls_doc_file-filename,
        sy-langu              TO ls_doc_file-langu,
        ls_tdwa-def_application TO ls_doc_file-dappl,

        lfd_nr TO ls_phio-lo_index,
        lfd_nr TO ls_phio-ph_index,
        sy-langu TO ls_phio-langu,
        lf_dokst TO ls_phio-status,
        ls_documents-docfile1 TO ls_phio-filename.



** ---------------------------------------------------------------------
** Create container
** ---------------------------------------------------------------------
  IF gf_oi_cont IS INITIAL.
    CREATE OBJECT gf_oi_cont
             EXPORTING
                 container_name = c_oi_cont
             EXCEPTIONS
                 cntl_error                  = 1
                 cntl_system_error           = 2
                 create_error                = 3
                 lifetime_error              = 4
                 lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc <> 0.
      MESSAGE e006(/cideon/note_dir).
    ENDIF.
  ELSE.
    CALL METHOD gf_oi_cont->set_visible
      EXPORTING
        visible           = 'X'
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.


** ---------------------------------------------------------------------
** open document
** ---------------------------------------------------------------------

  CONCATENATE c_dms_file_url ls_documents-docfile1
    INTO gc_url.
  MOVE 'X' TO lf_create.

  CALL FUNCTION 'CV150_GENERIC_OPEN_OFFICE_DOC'
       EXPORTING
            im_create_flag      = lf_create
            im_draw             = ls_draw
            im_application_type = lf_appltype
            im_doc_url          = gc_url
            im_ws_application   = ls_tdwa-def_application
            im_call_mode        = 'A'
            im_parent_container = gf_oi_cont
       EXCEPTIONS
            error               = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
    MESSAGE e006(/cideon/note_dir).
  ENDIF.


** ---------------------------------------------------------------------
** set screen-data & call screen
** ---------------------------------------------------------------------

  CALL SCREEN '0200'.

*    Ändern Dokument:
  ls_documents-documenttype = ls_documentdata-documenttype.
  ls_documents-documentnumber = ls_documentdata-documentnumber.
  ls_documents-documentpart = ls_documentdata-documentpart.
  ls_documents-documentversion = ls_documentdata-documentversion.


  ls_documentfiles-documenttype    = ls_documents-documenttype.
  ls_documentfiles-documentnumber  = ls_documents-documentnumber.
  ls_documentfiles-documentpart    = ls_documents-documentpart.
  ls_documentfiles-documentversion = ls_documents-documentversion.
  ls_documentfiles-docfile = ls_documents-docfile1.
  ls_documentfiles-wsapplication =  ls_tdwa-def_application.

  ls_documentfiles-storagecategory = I_STORAGECAT.

  APPEND ls_documentfiles TO lt_documentfiles.

  CALL FUNCTION 'BAPI_DOCUMENT_CHANGE2'
  EXPORTING
    documenttype              = ls_documents-documenttype
    documentnumber            = ls_documents-documentnumber
    documentpart              = ls_documents-documentpart
    documentversion           = ls_documents-documentversion
    documentdata              = ls_documentdata
    documentdatax             = ls_documentdatax
*           HOSTNAME                  =
*           DOCBOMCHANGENUMBER        =
*           DOCBOMVALIDFROM           =
*           DOCBOMREVISIONLEVEL       =
*           SENDCOMPLETEBOM           = ' '
*           PF_FTP_DEST               = ' '
*           PF_HTTP_DEST              = ' '
*           CAD_MODE                  = ' '
  IMPORTING
    return                     = ls_return
  TABLES
*           CHARACTERISTICVALUES      =
*           CLASSALLOCATIONS          =
*           DOCUMENTDESCRIPTIONS      =
*           OBJECTLINKS               =
*           DOCUMENTSTRUCTURE         =
    documentfiles              = lt_documentfiles
*           LONGTEXTS                 =
*           COMPONENTS                =
            .
  IF NOT ls_return-type CA 'EA'.
    CLEAR ls_return.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
              wait   = 'X'
         IMPORTING
              return = ls_return.
  ELSE.
    CLEAR ls_return.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE e007(/cideon/note_dir).
  ENDIF.



* Daten übergeben
  wa_draw-dokar = ls_new_document-doctype.
  wa_draw-doknr = ls_new_document-docnumber.
  wa_draw-doktl = ls_new_document-docpart.
  wa_draw-dokvr = ls_new_document-docversion.


* Original einchecken




ENDFUNCTION.
