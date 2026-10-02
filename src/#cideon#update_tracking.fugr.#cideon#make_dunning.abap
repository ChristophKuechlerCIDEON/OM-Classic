FUNCTION /cideon/make_dunning.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(ID_PLOTJOB_32) TYPE  /CIDEON/ID_PLOTJOB_GUID32
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
* Mahnungserstellung
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 15.11.2007 - Erstellung
* 19.11.2007 - DIS Erstellung
*-----------------------------------------------------------------------
* to do
*
*   - Übergabe des Titels der Mahnung
*
*
*-----------------------------------------------------------------------
*ITAB

*ITAB
  DATA: lt_log TYPE TABLE OF /cideon/pl_log.
*WA
  DATA: lc_log TYPE /cideon/pl_log.
*NORMAL
  DATA: formname TYPE tdsfname.
  DATA: fm_name TYPE rs38l_fnam.
  DATA: ls_output_options TYPE ssfcompop,
          ls_control_parameters TYPE ssfctrlop,
          ls_job_output_info TYPE ssfcrescl,
          ls_job_output_options TYPE ssfcresop
          .


  IF  id_plotjob_32 IS INITIAL.
    MESSAGE e005(/cideon/plot_basis)
      WITH  'ID Plotjob' '' '' ''.
*   Feld & ist initial & & &
  ELSE.
  ENDIF.

  CLEAR lt_log.
  SELECT * FROM /cideon/pl_log
    INTO TABLE lt_log
    WHERE id_plotjob_32 = id_plotjob_32
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

* Mahnstufe feststellen
  DATA: str_mahnung TYPE string.
  CLEAR str_mahnung.

  READ TABLE lt_log INTO lc_log INDEX 1.

  IF lc_log-m1date IS INITIAL.
    str_mahnung = text-du1.
  ELSE.
    IF lc_log-m2date IS INITIAL.
      str_mahnung = text-du2.
    ELSE.
      str_mahnung = text-du3.
    ENDIF.
  ENDIF.

* Spool erstellen
  DATA: wsa TYPE dappl.

  wsa = 'PDF'.

* Spoolauftrag erstellen
* Drucker holen, welcher keine Ausgabe hat DUMMY?
* Mglw. Dummy Drucker noch erstellen

* Formular benutzen
  CLEAR formname.
  CLEAR fm_name.
*  formname = wa_mdr_tr-smartform_tr.

  CLEAR ls_output_options.
  CLEAR ls_control_parameters.

*  CLEAR ls_control_parameters.
  ls_control_parameters-device = 'PRINTER'.
* ls_control_parameters-getotf = 'X'.
  ls_control_parameters-no_dialog = 'X'.
*  ls_control_parameters-PREVIEW = 'X'.
  ls_control_parameters-langu = sy-langu.

* DUMMY Übergabe
*  CLEAR ls_output_options.
*  ls_output_options-tddest = wa_mdr_tr-tddest.
*  ls_output_options-tdprinter = wa_mdr_tr-tdprinter.


  ls_output_options-tdimmed = space.
  ls_output_options-tddelete = space.
  ls_output_options-tdnewid = 'X'.
  ls_output_options-tdlifetime = '8'.
  ls_output_options-tdfinal = 'X'.


* BADI für Spooldaten
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CALL METHOD badi_main_pre_001->chg_spool_dunning
      CHANGING
        ls_output_options       = ls_output_options
        ls_control_parameters   =  ls_control_parameters
        formname                = formname
      .
  ENDIF.





  CLEAR fm_name.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname                 = formname
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
    IMPORTING
      fm_name                  = fm_name
    EXCEPTIONS
      no_form                  = 1
      no_function_module       = 2
      OTHERS                   = 3
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CALL FUNCTION fm_name
    EXPORTING
*        ARCHIVE_INDEX              =
*        ARCHIVE_INDEX_TAB          =
*        ARCHIVE_PARAMETERS         =
         control_parameters         = ls_control_parameters
*        MAIL_APPL_OBJ              =
*        MAIL_RECIPIENT             =
*        MAIL_SENDER                =
         output_options             = ls_output_options
         user_settings              = space
*         wa_mdr_tr                  = wa_mdr_tr
*         wa_prps                    = wa_prps
*         wa_proj                    = wa_proj
         str_mahnung                = str_mahnung
       IMPORTING
*        DOCUMENT_OUTPUT_INFO       =
         job_output_info            = ls_job_output_info
         job_output_options         = ls_job_output_options
        TABLES
*          it_components              = et_components
*           it_draw_item_tr          = it_draw_item_tr
           lt_log                    = lt_log
       EXCEPTIONS
         formatting_error           = 1
         internal_error             = 2
         send_error                 = 3
         user_canceled              = 4
         OTHERS                     = 5.
  IF sy-subrc <> 0.
    RAISE error.
  ELSE.
  ENDIF.

* Spool ID abgreifen
  DATA: it_spoolids TYPE tsfspoolid.
  DATA: spoolid TYPE rspoid.
  it_spoolids[] = ls_job_output_info-spoolids[].

  CLEAR spoolid.
  LOOP AT it_spoolids INTO spoolid.
  ENDLOOP.

  IF spoolid IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.


* Spool abschließen
* schon geschehen



* PDF erstellen / innerhalb des TEMP Pfades
* TEMP Pfad holen
  DATA: fs TYPE REF TO cl_gui_frontend_services.

  IF fs IS INITIAL.
    CREATE OBJECT fs
       EXCEPTIONS
*         not_supported_by_gui = 1
*         cntl_error           = 2
         others               = 3
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
  ENDIF.

  DATA: temp_dir TYPE string.
  CLEAR temp_dir.
  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir             = temp_dir
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
*      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2.
  IF sy-subrc NE 0.
    RAISE error.
  ELSE.
  ENDIF.

  DATA: filep TYPE filep.
  CLEAR filep.

  CALL FUNCTION '/CIDEON/OTF_2_PDF'
       EXPORTING
            i_pfad      = temp_dir
            i_tdspoolid = spoolid
            i_tdotftype = 'SPOOL'
       IMPORTING
            o_filep     = filep
       EXCEPTIONS
            error       = 1
            no_spool    = 2
            OTHERS      = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



* DIS erstellen
* Dokumente zum DIS verknüpfen

* DIS
*  DATA: return TYPE bapiret2.
  DATA: documentdata TYPE bapi_doc_draw2.
  DATA: document TYPE bapi_doc_aux.

* Datei
  DATA: it_doc_files TYPE TABLE OF bapi_doc_files2.
  DATA: wa_doc_files TYPE bapi_doc_files2.


* BADI?




  CLEAR document.

  CLEAR documentdata.
*  documentdata-documenttype = wa_mdr_tr-dokar. "'PRD'.
*  documentdata-documentnumber =  wa_mdr_tr-doknr. "'*'.
*  documentdata-documentpart = wa_mdr_tr-doktl. "'DE'.
*  documentdata-documentversion = wa_mdr_tr-dokvr.           "'00'.

  CONCATENATE text-001
    sy-datum sy-uzeit
    INTO documentdata-description
    SEPARATED BY space.

  CLEAR wa_doc_files.
  wa_doc_files-wsapplication = wsa. "'PDF'.
  "wa_doc_files-storagecategory =
  wa_doc_files-docfile = filep.

  wa_doc_files-description = documentdata-description.

  APPEND wa_doc_files TO it_doc_files.

  DATA: it_char_val TYPE TABLE OF bapi_characteristic_values.
  DATA: it_class_alloc TYPE TABLE OF bapi_class_allocation.
  DATA: it_doc_desc TYPE TABLE OF bapi_doc_drat.
  DATA: it_object_links TYPE TABLE OF bapi_doc_drad.

  CLEAR it_char_val.
  CLEAR it_class_alloc.
  CLEAR it_doc_desc.
  CLEAR it_object_links.

*   BADI für TR DIS erstellen
  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CALL METHOD badi_main_pre_001->chg_dis_data_before_create
      CHANGING
        documentdata   = documentdata
        it_doc_files   = it_doc_files
        it_char_val    = it_char_val
        it_class_alloc = it_class_alloc
        it_doc_desc    = it_doc_desc
        it_object_links = it_object_links
        id_plotjob_32  = id_plotjob_32
        .
  ENDIF.

  CLEAR return.
  CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
    EXPORTING
      documentdata               = documentdata
*     HOSTNAME                   =
*     DOCBOMCHANGENUMBER         =
*     DOCBOMVALIDFROM            =
*     DOCBOMREVISIONLEVEL        =
*     CAD_MODE                   = ' '
*     PF_FTP_DEST                = ' '
*     PF_HTTP_DEST               = ' '
   IMPORTING
      documenttype               = document-doctype
      documentnumber             = document-docnumber
      documentpart               = document-docpart
      documentversion            = document-docversion
      return                     = return
    TABLES
    characteristicvalues       = it_char_val
    classallocations           = it_class_alloc
    documentdescriptions       = it_doc_desc
      objectlinks                = it_object_links
*     DOCUMENTSTRUCTURE          =
      documentfiles              = it_doc_files
*     LONGTEXTS                  =
*     COMPONENTS                 =
            .

  IF return-type CA 'EA'.
    MESSAGE ID return-id
      TYPE return-type NUMBER return-number
        .
    "RAISE error.
  ELSE.
  ENDIF.

  COMMIT WORK AND WAIT.


* Daten für die Übergabe an OM lesen
* Lieferantendaten

*    wa_stored_search-lifnr = wa_objects-lifnr.
*    wa_stored_search-name1_lifnr = wa_objects-name1_lifnr.
*    wa_stored_search-ebeln = wa_objects-ebeln.
*    wa_stored_search-matnr = wa_objects-matnr.

  CLEAR lc_log.
  READ TABLE lt_log INTO lc_log INDEX 1.


  DATA: lt_sel_objects TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: lc_sel_objects TYPE zcl_pdm_exp_objects.

  CLEAR lt_sel_objects.

  CLEAR lc_sel_objects.

  MOVE-CORRESPONDING lc_log TO lc_sel_objects.

  lc_sel_objects-object_type = 'DOCUMENT'.
  lc_sel_objects-dokar = document-doctype.
  lc_sel_objects-doknr = document-docnumber.
  lc_sel_objects-doktl = document-docpart.
  lc_sel_objects-dokvr = document-docversion.

  APPEND lc_sel_objects TO lt_sel_objects.

  CALL FUNCTION '/CIDEON/PSBRW_WRT_PSB_TMP_FRTA'
       TABLES
            i_itab_objects = lt_sel_objects
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


* Übergabe an OM

*   Aufruf des PlotInterfaces
  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
  CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.

*   Einstellungen zurücksetzen
  SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.


* Setzen der Felder für LOG
* Mahnungsdatum

  LOOP AT lt_log INTO lc_log.
    IF lc_log-m1date IS INITIAL.
      lc_log-m1date = sy-datum.
    ELSE.
      IF lc_log-m2date IS INITIAL.
        lc_log-m2date = sy-datum.
      ELSE.
      ENDIF.
    ENDIF.

    MODIFY /cideon/pl_log FROM lc_log.
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDLOOP.

  COMMIT WORK AND WAIT.


ENDFUNCTION.
