*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_MDR_TR_FB01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  show_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form show_info.
* Versionsinformationen anzeigen
  data: versionsinfo type ref to /cideon/cl_versionsinfo.
  data: version(20).

  version = text-v00.

  create object versionsinfo.
  call method versionsinfo->get_info_lvc
    exporting
      objtype = 'REPS'
      objname = '/CIDEON/PLOT_MDR_TR'
      version = version
      .

endform.                    " show_info
*&---------------------------------------------------------------------*
*&      Form  read_defaults
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_defaults.
* Einstellungen lesen
  call function '/CIDEON/READ_DEFAULTDATA'
       exporting
            i_batch        = ''
       importing
            o_default_data = default_data.


  clear user_data.
  user_data-uname = sy-uname.


  call function '/CIDEON/READ_USERDATA'
       exporting
            i_default_data = default_data
       importing
            o_user_data    = user_data.


endform.                    " read_defaults
*&---------------------------------------------------------------------*
*&      Form  check_psp_element
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_psp_element.
* Test auf Eingabe in PSP Feld

  if wa_mdr_tr-posid is initial.
    message w001(/cideon/plot_ps) with '&' '&' '&' '&'.
*   Bitte PSP Element eingeben & & & &

  else.
  endif.

endform.                    " check_psp_element
*&---------------------------------------------------------------------*
*&      Form  get_psp_elements
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_psp_elements.
* PSP Elemente holen
  data it_wbs_in type table of bapi_wbs_elements.
  data: wa_wbs_in type bapi_wbs_elements.
  data: return type bapireturn1.

  clear it_wbs_in.
  clear it_wbs.
  clear return.

  clear wa_wbs_in.
  wa_wbs_in = wa_mdr_tr-posid.
  append wa_wbs_in to it_wbs_in .

  call function 'BAPI_PROJECT_GETINFO'
    exporting
*     PROJECT_DEFINITION           =
*     WITH_ACTIVITIES              =
*     WITH_MILESTONES              =
      with_subtree                 = 'X'
    importing
*     E_PROJECT_DEFINITION         =
      return                       = return
    tables
      i_wbs_element_table          = it_wbs_in
      e_wbs_element_table          = it_wbs
*     E_WBS_MILESTONE_TABLE        =
*     E_WBS_HIERARCHIE_TABLE       =
*     E_ACTIVITY_TABLE             =
*     E_MESSAGE_TABLE              =
            .
  if return is initial.
  else.
    message id return-id
      type return-type number return-number
            .

  endif.



endform.                    " get_psp_elements
*&---------------------------------------------------------------------*
*&      Form  read_pspid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_pspid.
* Werte für PSPID und Beschreibung holen.
  data: wa_prps type prps.

  clear wa_prps.
  clear wa_proj.

  call function 'CJDW_SELECT_BASIC_DATA'
    exporting
*     APPEND                        = ' '
*     ENQUEUE                       = ' '
      entry_element                 = wa_mdr_tr-posid
*     FLG_SUBPR                     = ' '
*     MEMID_PROJ                    = CON_MEMID_PROJ
*     MEMID_PRPS                    = CON_MEMID_PRPS
*     NO_SUBITEMS                   = ' '
*     PROJECT                       = ' '
    importing
*     E_INDENT                      =
*      E_INPUT_PROJ                  =
*      E_INPUT_PRPS                  =
*     E_OUTPUT_PROJ                 =
*     E_OUTPUT_PRPS                 =
      e_proj                        = wa_proj
      e_prps                        = wa_prps
*     E_TCJ41                       =
*     E_MEMID_PROJ                  =
*     E_MEMID_PRPS                  =
   exceptions
     entry_element_not_found       = 1
     missing_parameter             = 2
     project_not_found             = 3
     project_inact                 = 4
     ale_distributed               = 5
     others                        = 6
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  wa_mdr_tr-pspnr = wa_prps-pspnr.

  wa_mdr_tr-pspnr_prj = wa_proj-pspnr.
  wa_mdr_tr-pspid = wa_proj-pspid.
  wa_mdr_tr-post1 = wa_proj-post1.

endform.                    " read_pspid
*&---------------------------------------------------------------------*
*&      Form  get_doc_for_psp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_doc_for_psp.
* holt Dokumente für PSP Elemente
  data: key type drad-objky.
  data: doktab type table of drad.

  data: wa_prps type prps.
  data: wa_doktab type drad.


* EasyDMS Dokumente berücksichtigen und aus der Tabelle löschen
* erstes Element wird vermieden

  clear it_drad_psp.

  loop at it_wbs into wa_wbs.
*   erstes Element vermeiden
*   da am ersten Element die Doku zum Projekt hängt
*   un keine Zeichnungen

    if sy-tabix = 1.
      continue.
    else.
    endif.

*    CLEAR wa_prps.
*    SELECT SINGLE * FROM prps INTO wa_prps
*      WHERE posid = wa_wbs-wbs_element
*      .
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.
*
*    "key = wa_wbs-wbs_element.
*    key = wa_prps-pspnr.

* Konvertierungsexit benutzen
    data: flg_exists_abpsp.
    call function 'FUNCTION_EXISTS'
         exporting
              funcname           = 'CONVERSION_EXIT_KONPR_INPUT'
         exceptions
              function_not_exist = 1.

    if sy-subrc <> 0.
      clear flg_exists_abpsp.
    else.
      flg_exists_abpsp = 'X'.
    endif.

    if flg_exists_abpsp = 'X'.
      data: ps_posnr type ps_posnr.
      clear ps_posnr.
      call function 'CONVERSION_EXIT_KONPR_INPUT'           "#EC EXISTS
                exporting
                     input  = wa_wbs-wbs_element
                importing
                     output = ps_posnr
                exceptions
                     not_found = 1.

      clear key.
      key = ps_posnr.

    else.
      clear wa_prps.
      select single * from prps into wa_prps
        where posid = wa_wbs-wbs_element
        .
      if sy-subrc ne 0.
      else.
      endif.

      clear key.
      "key = wa_wbs-wbs_element.
      key = wa_prps-pspnr.
    endif.



    clear doktab.

    call function 'DOKUMENTE_ZU_OBJEKT'
      exporting
        key                       = key
      objekt                    = 'PRPS'
*     MANDT                     = SY-MANDT
*     CHECK_BUFFER_AND_DB       = ' '
    tables
      doktab                    = doktab
    exceptions
      kein_dokument             = 1
      others                    = 2
            .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.

    loop at doktab into wa_doktab.
      append wa_doktab to it_drad_psp.
    endloop.

  endloop.

endform.                    " get_doc_for_psp
*&---------------------------------------------------------------------*
*&      Form  create_tr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_tr.
* TR Erstellen
* Smartform
*NORMAL
  data: formname type tdsfname.
  data: fm_name type rs38l_fnam.
  data: ls_output_options type ssfcompop,
          ls_control_parameters type ssfctrlop,
          ls_job_output_info type ssfcrescl,
          ls_job_output_options type ssfcresop
          .

  data: wsa type dappl.

  wsa = 'PDF'.

* Spoolauftrag erstellen
* Drucker holen, welcher keine Ausgabe hat DUMMY?
* Mglw. Dummy Drucker noch erstellen


* Formular benutzen
  clear formname.
  formname = wa_mdr_tr-smartform_tr.

  clear fm_name.
  call function 'SSF_FUNCTION_MODULE_NAME'
    exporting
      formname                 = formname
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
    importing
      fm_name                  = fm_name
    exceptions
      no_form                  = 1
      no_function_module       = 2
      others                   = 3
            .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ls_control_parameters-device = 'PRINTER'.
* ls_control_parameters-getotf = 'X'.
  ls_control_parameters-no_dialog = 'X'.
*  ls_control_parameters-PREVIEW = 'X'.
  ls_control_parameters-langu = sy-langu.

* DUMMY Übergabe
  ls_output_options-tddest = wa_mdr_tr-tddest.
  ls_output_options-tdprinter = wa_mdr_tr-tdprinter.


  ls_output_options-tdimmed = space.
  ls_output_options-tddelete = space.
  ls_output_options-tdnewid = 'X'.
  ls_output_options-tdlifetime = '8'.
  ls_output_options-tdfinal = 'X'.

  call function fm_name
    exporting
*        ARCHIVE_INDEX              =
*        ARCHIVE_INDEX_TAB          =
*        ARCHIVE_PARAMETERS         =
         control_parameters         = ls_control_parameters
*        MAIL_APPL_OBJ              =
*        MAIL_RECIPIENT             =
*        MAIL_SENDER                =
         output_options             = ls_output_options
         user_settings              = space
         wa_mdr_tr                  = wa_mdr_tr
         wa_prps                    = wa_prps
         wa_proj                    = wa_proj
       importing
*        DOCUMENT_OUTPUT_INFO       =
         job_output_info            = ls_job_output_info
         job_output_options         = ls_job_output_options
        tables
*          it_components              = et_components
           it_draw_item_tr          = it_draw_item_tr
       exceptions
         formatting_error           = 1
         internal_error             = 2
         send_error                 = 3
         user_canceled              = 4
         others                     = 5.
  if sy-subrc <> 0.
    raise error.
  else.
  endif.

* Spool ID abgreifen
  data: it_spoolids type tsfspoolid.
  data: spoolid type rspoid.
  it_spoolids[] = ls_job_output_info-spoolids[].

  clear spoolid.
  loop at it_spoolids into spoolid.
  endloop.

  if spoolid is initial.
    raise error.
  else.
  endif.


* Spool abschließen
* schon geschehen



* PDF erstellen / innerhalb des TEMP Pfades
* TEMP Pfad holen
  data: fs type ref to cl_gui_frontend_services.

  if fs is initial.
    create object fs
       exceptions
*         not_supported_by_gui = 1
*         cntl_error           = 2
         others               = 3
        .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  else.
  endif.

  data: temp_dir type string.
  clear temp_dir.
  call method cl_gui_frontend_services=>get_temp_directory
    changing
      temp_dir             = temp_dir
    exceptions
      cntl_error           = 1
      error_no_gui         = 2
*      not_supported_by_gui = 3
      others               = 4.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  call method cl_gui_cfw=>flush
    exceptions
      cntl_system_error = 1
      cntl_error        = 2.
  if sy-subrc ne 0.
    raise error.
  else.
  endif.

  data: filep type filep.
  clear filep.

  call function '/CIDEON/OTF_2_PDF'
       exporting
            i_pfad      = temp_dir
            i_tdspoolid = spoolid
            i_tdotftype = 'SPOOL'
       importing
            o_filep     = filep
       exceptions
            error       = 1
            no_spool    = 2
            others      = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


* Nachsehen, ob DIS für die Ablage existiert
* falls nicht, so wird erstellt
*
  data: doknr type doknr.
  data: f_dis_erstellen.

  clear f_dis_erstellen.
  clear doknr.
  select single doknr into doknr
    from draw
    where dokar = wa_mdr_tr-dokar
    and doknr = wa_mdr_tr-doknr
    and doktl = wa_mdr_tr-doktl
    and dokvr = wa_mdr_tr-dokvr
    .
  if sy-subrc ne 0.
    f_dis_erstellen = 'X'.
  else.
  endif.

* DIS
  data: return type bapiret2.
  data: documentdata type bapi_doc_draw2.
  data: document type bapi_doc_aux.

* Datei
  data: it_doc_files type table of bapi_doc_files2.
  data: wa_doc_files type bapi_doc_files2.

  if f_dis_erstellen = 'X'.
    clear document.

    clear documentdata.
    documentdata-documenttype = wa_mdr_tr-dokar. "'PRD'.
    documentdata-documentnumber =  wa_mdr_tr-doknr. "'*'.
    documentdata-documentpart = wa_mdr_tr-doktl. "'DE'.
    documentdata-documentversion = wa_mdr_tr-dokvr.         "'00'.

    concatenate text-001
      sy-datum sy-uzeit
      into documentdata-description
      separated by space.

    clear wa_doc_files.
    wa_doc_files-wsapplication = wsa. "'PDF'.
    wa_doc_files-storagecategory = wa_mdr_tr-storage_cat. "'Z_M19X_CS'.
    wa_doc_files-docfile = filep.

    wa_doc_files-description = documentdata-description.

    append wa_doc_files to it_doc_files.

    data: it_char_val type table of bapi_characteristic_values.
    data: it_class_alloc type table of bapi_class_allocation.
    data: it_doc_desc type table of bapi_doc_drat.

    clear it_char_val.
    clear it_class_alloc.
    clear it_doc_desc.

*   BADI für TR DIS erstellen
    if badi_om_ps_01 is initial.
    else.
      call method badi_om_ps_01->chg_tr_dis_data_before_create
        changing
          documentdata   = documentdata
          it_doc_files   = it_doc_files
          it_char_val    = it_char_val
          it_class_alloc = it_class_alloc
          it_doc_desc    = it_doc_desc
          .
    endif.

    clear return.
    call function 'BAPI_DOCUMENT_CREATE2'
      exporting
        documentdata               = documentdata
*     HOSTNAME                   =
*     DOCBOMCHANGENUMBER         =
*     DOCBOMVALIDFROM            =
*     DOCBOMREVISIONLEVEL        =
*     CAD_MODE                   = ' '
*     PF_FTP_DEST                = ' '
*     PF_HTTP_DEST               = ' '
     importing
        documenttype               = document-doctype
        documentnumber             = document-docnumber
        documentpart               = document-docpart
        documentversion            = document-docversion
        return                     = return
      tables
      characteristicvalues       = it_char_val
      classallocations           = it_class_alloc
      documentdescriptions       = it_doc_desc
*     OBJECTLINKS                =
*     DOCUMENTSTRUCTURE          =
        documentfiles              = it_doc_files
*     LONGTEXTS                  =
*     COMPONENTS                 =
              .

    if return-type ca 'EA'.
      message id return-id
        type return-type number return-number
          .
      "RAISE error.
    else.
    endif.

    commit work and wait.

    message s002(/cideon/plot_ps)
      with document-doctype document-docnumber
      document-docpart document-docversion
      .
*   Dokument & & & & erzeugt

*   Übergabe in Struktur
    wa_mdr_tr-dokar_last_tr = document-doctype.
    wa_mdr_tr-doknr_last_tr = document-docnumber.
    wa_mdr_tr-doktl_last_tr = document-docpart.
    wa_mdr_tr-dokvr_last_tr = document-docversion.


*   Einfügen des erstellten Dokumentes in die Ordnerstruktur
    data: wa_doc_struc type bapi_doc_aux.
    data: documentdatax type bapi_doc_drawx2.

    data: it_doc_struc type table of bapi_doc_structure.
    data: wa_it_doc_struc type bapi_doc_structure.

* erst die Struktur holen
    clear it_doc_struc.

*   Änderung der Daten für das Einfügen des TR in die
*   Dokumentenstruktur
*   Änderung des DIS, unter welchem eingefügt wird...
    data: insert_dis type draw.
    clear insert_dis.

    insert_dis-dokar = wa_mdr_tr-root_dokar.
    insert_dis-doknr = wa_mdr_tr-root_doknr.
    insert_dis-doktl = wa_mdr_tr-root_doktl.
    insert_dis-dokvr = wa_mdr_tr-root_dokvr.

    if badi_om_ps_01 is initial.
    else.
*      CALL METHOD badi_om_ps_01->chg_tr_dis_data_before_create
*        CHANGING
*          documentdata   = documentdata
*          it_doc_files   = it_doc_files
*          it_char_val    = it_char_val
*          it_class_alloc = it_class_alloc
*          it_doc_desc    = it_doc_desc
      .
      call method badi_om_ps_01->chg_insert_dis_tr
        changing
          wa_mdr_tr  = wa_mdr_tr
          insert_dis = insert_dis
          .
    endif.



    call function 'BAPI_DOCUMENT_GETDETAIL2'
      exporting
        documenttype               = insert_dis-dokar
        "wa_mdr_tr-root_dokar
        documentnumber             = insert_dis-doknr
        "wa_mdr_tr-root_doknr
        documentpart               = insert_dis-doktl
        "wa_mdr_tr-root_doktl
        documentversion            = insert_dis-dokvr
         "wa_mdr_tr-root_dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
*     GETSTATUSLOG               = ' '
*     GETLONGTEXTS               = ' '
*     GETACTIVEFILES             = 'X'
*     GETDOCDESCRIPTIONS         = 'X'
*     GETDOCFILES                = 'X'
*     GETCLASSIFICATION          = ' '
        getstructure               = 'X'
*     GETWHEREUSED               = ' '
*     HOSTNAME                   = ' '
*   IMPORTING
*     DOCUMENTDATA               =
*     RETURN                     =
      tables
*     OBJECTLINKS                =
*     DOCUMENTDESCRIPTIONS       =
*     LONGTEXTS                  =
*     STATUSLOG                  =
*     DOCUMENTFILES              =
*     COMPONENTS                 =
*     CHARACTERISTICVALUES       =
*     CLASSALLOCATIONS           =
        documentstructure          = it_doc_struc
*     WHEREUSEDLIST              =
              .

    clear wa_doc_struc.
*    wa_doc_struc-doctype = wa_mdr_tr-root_dokar.
*    wa_doc_struc-docnumber = wa_mdr_tr-root_doknr.
*    wa_doc_struc-docversion = wa_mdr_tr-root_dokvr.
*    wa_doc_struc-docpart = wa_mdr_tr-root_doktl.
    wa_doc_struc-doctype = insert_dis-dokar.
    wa_doc_struc-docnumber = insert_dis-doknr.
    wa_doc_struc-docversion = insert_dis-dokvr.
    wa_doc_struc-docpart = insert_dis-doktl.

    clear wa_it_doc_struc.
    wa_it_doc_struc-documenttype = document-doctype.
    wa_it_doc_struc-documentnumber = document-docnumber.
    wa_it_doc_struc-documentpart = document-docpart.
    wa_it_doc_struc-documentversion = document-docversion.
    append wa_it_doc_struc to it_doc_struc.

    clear documentdata.
    clear documentdatax.

    clear return.
* in Stückliste integrieren
    call function 'BAPI_DOCUMENT_CHANGE2'
      exporting
        documenttype               = wa_doc_struc-doctype
        documentnumber             = wa_doc_struc-docnumber
        documentpart               = wa_doc_struc-docpart
        documentversion            = wa_doc_struc-docversion
        documentdata               = documentdata
        documentdatax              = documentdatax
*   HOSTNAME                   =
*   DOCBOMCHANGENUMBER         =
*   DOCBOMVALIDFROM            =
*   DOCBOMREVISIONLEVEL        =
*   SENDCOMPLETEBOM            = ' '
*   PF_FTP_DEST                = ' '
*   PF_HTTP_DEST               = ' '
*   CAD_MODE                   = ' '
      importing
        return                     = return
    tables
*   CHARACTERISTICVALUES       =
*   CLASSALLOCATIONS           =
*   DOCUMENTDESCRIPTIONS       =
*   OBJECTLINKS                =
      documentstructure          = it_doc_struc
*   DOCUMENTFILES              =
*   LONGTEXTS                  =
*   COMPONENTS                 =
              .





    commit work and wait.


  else.
*   Ändern des Dokumentes
    clear document.

    clear documentdata.
    clear documentdatax.

    documentdata-documenttype = wa_mdr_tr-dokar. "'PRD'.
    documentdata-documentnumber =  wa_mdr_tr-doknr. "'*'.
    documentdata-documentpart = wa_mdr_tr-doktl. "'DE'.
    documentdata-documentversion = wa_mdr_tr-dokvr.         "'00'.

    concatenate text-001
      sy-datum sy-uzeit
      into documentdata-description
      separated by space.
    documentdatax-description = 'X'.

    clear wa_doc_files.
    wa_doc_files-wsapplication = 'PDF'.
    wa_doc_files-storagecategory = wa_mdr_tr-storage_cat. "'Z_M19X_CS'.
    wa_doc_files-docfile = filep.

    wa_doc_files-description = documentdata-description.

    append wa_doc_files to it_doc_files.

*   alte WSA löschen
    if wa_mdr_tr-f_del_wsa = 'X'.

      data: wa_draw type draw.

      clear wa_draw.
      wa_draw-dokar = documentdata-documenttype.
      wa_draw-doknr = documentdata-documentnumber.
      wa_draw-doktl = documentdata-documentpart.
      wa_draw-dokvr = documentdata-documentversion.

      call function '/CIDEON/DEL_WSA'
           exporting
                draw   = wa_draw
                wsa    = wsa
           exceptions
                error  = 1
                others = 2.
      if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      endif.


    else.
    endif.

    clear return.
    call function 'BAPI_DOCUMENT_CHANGE2'
      exporting
        documenttype               = documentdata-documenttype
        documentnumber             = documentdata-documentnumber
        documentpart               = documentdata-documentpart
        documentversion            = documentdata-documentversion
        documentdata               = documentdata
        documentdatax              = documentdatax
*   HOSTNAME                   =
*   DOCBOMCHANGENUMBER         =
*   DOCBOMVALIDFROM            =
*   DOCBOMREVISIONLEVEL        =
*   SENDCOMPLETEBOM            = ' '
*   PF_FTP_DEST                = ' '
*   PF_HTTP_DEST               = ' '
*   CAD_MODE                   = ' '
      importing
        return                     = return
      tables
*   CHARACTERISTICVALUES       =
*   CLASSALLOCATIONS           =
*   DOCUMENTDESCRIPTIONS       =
*   OBJECTLINKS                =
*   DOCUMENTSTRUCTURE          =
        documentfiles              = it_doc_files
*   LONGTEXTS                  =
*   COMPONENTS                 =
              .

    if return-type ca 'EA'.
      message id return-id
        type return-type number return-number.
      "RAISE error.
    else.
    endif.

    commit work and wait.

    message s003(/cideon/plot_ps)
      with documentdata-documenttype documentdata-documentnumber
      documentdata-documentpart documentdata-documentversion.
*   Dokument & & & & wurde geändert

*   Übergabe in Struktur
    wa_mdr_tr-dokar_last_tr = documentdata-documenttype.
    wa_mdr_tr-doknr_last_tr = documentdata-documentnumber.
    wa_mdr_tr-doktl_last_tr = documentdata-documentpart.
    wa_mdr_tr-dokvr_last_tr = documentdata-documentversion.


  endif.




endform.                    " create_tr

*&---------------------------------------------------------------------*
*&      Form  map_default_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form map_default_data.
* gelesene Defaultdaten mappen

* Drucker
  wa_mdr_tr-tddest = user_data-mat_tddest.
  wa_mdr_tr-tdprinter = user_data-mat_tdprinter.

* Separator
  data: separator_tmp(35).
  separator_tmp = user_data-separator_dis.
  split separator_tmp at ',' into
    wa_mdr_tr-sep_dokar
    wa_mdr_tr-sep_doknr
    wa_mdr_tr-sep_doktl
    wa_mdr_tr-sep_dokvr
    .

* Merkmale MDR
  wa_mdr_tr-mdr_flag_name = user_data-mdr_flag_name.
  wa_mdr_tr-mdr_flag_val = user_data-mdr_flag_val.

* Merkmal TR
  wa_mdr_tr-tr_flag_name = user_data-tr_flag_name.
  wa_mdr_tr-tr_flag_val = user_data-tr_flag_val.

* Smartform
  wa_mdr_tr-smartform_mdr = user_data-smartform_mdr.
  wa_mdr_tr-smartform_tr = user_data-smartform_tr.

* TOC_DIS
  data: toc_tmp(35).
  toc_tmp = user_data-toc_dis.
  split toc_tmp at ',' into
    wa_mdr_tr-toc_dokar
    wa_mdr_tr-toc_doknr
    wa_mdr_tr-toc_doktl
    wa_mdr_tr-toc_dokvr
    .

* F_DEL_WSA
  wa_mdr_tr-f_del_wsa = 'X'.

* STORAGE_DIS_TR
  data: dis_tr_tmp(35).
  dis_tr_tmp = user_data-storage_dis_tr.
  split dis_tr_tmp at ',' into
    wa_mdr_tr-dokar
    wa_mdr_tr-doknr
    wa_mdr_tr-doktl
    wa_mdr_tr-dokvr
    .

* STORAGE_CAT_TR
  wa_mdr_tr-storage_cat = user_data-storage_cat_tr.


* MDR_DIS
  data: dis_mdr_tmp(35).
  dis_mdr_tmp = user_data-mdr_dis.
  split dis_mdr_tmp at ',' into
    wa_mdr_tr-mdr_dokar
    wa_mdr_tr-mdr_doknr
    wa_mdr_tr-mdr_doktl
    wa_mdr_tr-mdr_dokvr
    .

* F_DYN_TOC
* Erstellung des dynamischen Inhaltsverzeichnisses
  wa_mdr_tr-f_dyn_toc = 'X'.

* f_merge
  wa_mdr_tr-f_merge = 'X'.

* F_DYN_COV
* dynamische Startseite
  wa_mdr_tr-f_dyn_cov = 'X'.


* BADI beachten zum Setzen der Daten für die jeweiligen System
* Möglichkeit der Anpassungen für den Kunden
  if badi_om_ps_01 is initial.
  else.
    call method badi_om_ps_01->chg_wa_mdr_tr_data_init
      changing
        wa_mdr_tr = wa_mdr_tr
        .
  endif.

endform.                    " map_default_data

*&---------------------------------------------------------------------*
*&      Form  make_tr_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_tr_pdf.
* erstellt das PDF aus dem TR

endform.                    " make_tr_PDF

*&---------------------------------------------------------------------*
*&      Form  create_tr_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_tr_table.
* Erstelle Übergabetabelle für TR

  clear it_draw_item_tr.
  loop at it_drad_psp into wa_drad_psp.
    select single * from draw into
      corresponding fields of wa_draw_item_tr
      where dokar = wa_drad_psp-dokar
      and doknr = wa_drad_psp-doknr
      and doktl = wa_drad_psp-doktl
      and dokvr = wa_drad_psp-dokvr
      .
    if sy-subrc ne 0.
    else.
    endif.

    select single * from prps into
      corresponding fields of wa_draw_item_tr
      where pspnr = wa_drad_psp-objky
      .
    if sy-subrc ne 0.
    else.
    endif.

    append wa_draw_item_tr to it_draw_item_tr.

  endloop.

* Daten bereinigen entsprechend der angegebenen
* Merkmalswerte
  perform clean_out_with_class_tr.


* Klassifikationsdaten holen und einfügen
  if badi_om_ps_01 is initial.
  else.
    call method badi_om_ps_01->chg_tr_classdata
      changing
        it_draw_item_tr = it_draw_item_tr
        .
  endif.

endform.                    " create_tr_table
*&---------------------------------------------------------------------*
*&      Form  get_doc_easyDMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_doc_easydms.
* hole Dokumente aus dem EasyDMS
* Kapitel berücksichtigen
* Seperatoren einfügen

* holt Dokumente für PSP Elemente
  data: key type drad-objky.
  data: doktab type table of drad.

  data: wa_prps type prps.
  data: wa_doktab type drad.

  read table it_wbs into wa_wbs index 1.
  if sy-subrc ne 0.
    exit.
  else.
  endif.

  clear it_drad_easy.

*  CLEAR wa_prps.
*  SELECT SINGLE * FROM prps INTO wa_prps
*    WHERE posid = wa_wbs-wbs_element
*    .
*  IF sy-subrc NE 0.
*  ELSE.
*  ENDIF.
*
*  "key = wa_wbs-wbs_element.
*  key = wa_prps-pspnr.


* Konvertierungsexit benutzen
  data: flg_exists_abpsp.
  call function 'FUNCTION_EXISTS'
       exporting
            funcname           = 'CONVERSION_EXIT_KONPR_INPUT'
       exceptions
            function_not_exist = 1.

  if sy-subrc <> 0.
    clear flg_exists_abpsp.
  else.
    flg_exists_abpsp = 'X'.
  endif.

  if flg_exists_abpsp = 'X'.
    data: ps_posnr type ps_posnr.
    clear ps_posnr.
    call function 'CONVERSION_EXIT_KONPR_INPUT'             "#EC EXISTS
           exporting
                input  = wa_wbs-wbs_element
           importing
                output = ps_posnr
           exceptions
                not_found = 1.

    clear key.
    key = ps_posnr.

  else.
    clear wa_prps.
    select single * from prps into wa_prps
      where posid = wa_wbs-wbs_element
      .
    if sy-subrc ne 0.
    else.
    endif.

    clear key.
    "key = wa_wbs-wbs_element.
    key = wa_prps-pspnr.
  endif.


  clear doktab.

  call function 'DOKUMENTE_ZU_OBJEKT'
    exporting
      key                       = key
    objekt                    = 'PRPS'
*     MANDT                     = SY-MANDT
*     CHECK_BUFFER_AND_DB       = ' '
  tables
    doktab                    = doktab
  exceptions
    kein_dokument             = 1
    others                    = 2
          .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  loop at doktab into wa_doktab.
    append wa_doktab to it_drad_easy.
  endloop.

* erste Verknüpfung lesen
  read table it_drad_easy into wa_drad_easy index 1.
  if sy-subrc ne  0.
    exit.
  else.
  endif.

  clear wa_draw_easy.
  move-corresponding wa_drad_easy to wa_draw_easy.


* erste Seit einfügen
* Doku für das Projekt
  perform set_chapter.

* Dokumente holen
* Kapitel lesen
*   Kapitel mit Beschreibung lesen
* Separatoren einfügen
*

* Struktur lesen.
  data: return type bapiret2.
  data: it_struc type table of bapi_doc_structure.
  data: it_struc_chapter type table of bapi_doc_structure.
  data: wa_struc type bapi_doc_structure.
  data: wa_struc_chapter type bapi_doc_structure.

  clear return.
  clear it_struc.
  call function 'BAPI_DOCUMENT_GETSTRUCTURE'
    exporting
      documenttype              = wa_draw_easy-dokar
      documentnumber            = wa_draw_easy-doknr
      documentpart              = wa_draw_easy-doktl
      documentversion           = wa_draw_easy-dokvr
*     MULTILEVELEXPLOSION       = ''
*     DOCBOMCHANGENUMBER        =
*     DOCBOMVALIDFROM           =
*     DOCBOMREVISIONLEVEL       =
  importing
    return                    = return
  tables
    documentstructure         = it_struc
        .
  if return is initial.
  else.
  endif.

* it_struc bereinigen
* keine normalen Dokumente, nur Folder auf oberster
* Ebene zugelassen
  loop at it_struc into wa_struc.
    if wa_struc-documenttype = user_data-easydms_folder_type.
    else.
      delete it_struc index sy-tabix.
    endif.
  endloop.

  loop at it_struc into wa_struc.
*   Kapitel Einfügen
    clear wa_draw_easy.
    wa_draw_easy-dokar = wa_struc-documenttype.
    wa_draw_easy-doknr = wa_struc-documentnumber.
    wa_draw_easy-doktl = wa_struc-documentpart.
    wa_draw_easy-dokvr = wa_struc-documentversion.
    perform set_chapter.

*   Dokumente recherchieren
*   Folder rauswerfen
*   alles rauswerfen, was nicht MDR Flag hat.
    clear return.

    clear return.
    clear it_struc_chapter.
    call function 'BAPI_DOCUMENT_GETSTRUCTURE'
    exporting
    documenttype              = wa_draw_easy-dokar
    documentnumber            = wa_draw_easy-doknr
    documentpart              = wa_draw_easy-doktl
    documentversion           = wa_draw_easy-dokvr
    multilevelexplosion       = 'X'
*     DOCBOMCHANGENUMBER        =
*     DOCBOMVALIDFROM           =
*     DOCBOMREVISIONLEVEL       =
    importing
    return                    = return
    tables
    documentstructure         = it_struc_chapter
          .
    if return is initial.
    else.
      continue.
    endif.

    loop at it_struc_chapter into wa_struc_chapter.
      if wa_struc_chapter-documenttype = user_data-easydms_folder_type.
*       nicht übernehmen
        continue.
      else.
      endif.

      data: it_charval type table of bapi_characteristic_values.
      data: wa_charval type bapi_characteristic_values.
      data: index type i.

*   Klassifikation lesen
*   Felder Füllen
      index = sy-tabix.

      clear it_charval.
      clear return.

      call function 'BAPI_DOCUMENT_GETDETAIL2'
        exporting
          documenttype               = wa_struc_chapter-documenttype
          documentnumber             = wa_struc_chapter-documentnumber
          documentpart               = wa_struc_chapter-documentpart
          documentversion            = wa_struc_chapter-documentversion
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
          getactivefiles             = ' '
          getdocdescriptions         = ' '
          getdocfiles                = ' '
          getclassification          = 'X'
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
        importing
*       DOCUMENTDATA               =
          return                     = return
        tables
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
*       DOCUMENTFILES              =
*       COMPONENTS                 =
          characteristicvalues       = it_charval
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
                .
      if return is initial.
      else.
        continue.
      endif.

      loop at it_charval into wa_charval
        where charname = wa_mdr_tr-mdr_flag_name
        .
      endloop.
      if sy-subrc ne 0.
        continue.
      else.
        if wa_charval-charvalue = wa_mdr_tr-mdr_flag_val.
        else.
          continue.
        endif.
      endif.

      clear wa_objects.

      wa_objects-object_type = 'DOCUMENT'.
      wa_objects-dokar = wa_struc_chapter-documenttype.
      wa_objects-doknr = wa_struc_chapter-documentnumber.
      wa_objects-doktl = wa_struc_chapter-documentpart.
      wa_objects-dokvr = wa_struc_chapter-documentversion.

      append wa_objects to it_objects.

    endloop.
  endloop.

* BADI Bereinigung der Dokumente
* Beispielsweise -> Entfernen der vorhandenen TR und MDR
  if badi_om_ps_01 is initial.
  else.
    call method badi_om_ps_01->chg_mdr_it_objects
      changing
        it_objects = it_objects
        wa_mdr_tr  = wa_mdr_tr
        .

  endif.



endform.                    " get_doc_easyDMS
*&---------------------------------------------------------------------*
*&      Form  clean_out_with_class_MDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clean_out_with_class_mdr.
* Dokumente bereinigen auf Grundlage der Klassifikationsangabe
* gilt nur für EasyDMS Dokumente

endform.                    " clean_out_with_class_MDR
*&---------------------------------------------------------------------*
*&      Form  clean_out_with_class_tr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clean_out_with_class_tr.
* Daten bereinigen
  if wa_mdr_tr-tr_flag_name is initial.
    exit.
  else.
  endif.

  if wa_mdr_tr-tr_flag_val is initial.
    exit.
  else.
  endif.

  data: it_charval type table of bapi_characteristic_values.

  data: wa_draw_item_tr type /cideon/s_draw_item_tr.
  data: return type bapiret2.
  data: wa_charval type bapi_characteristic_values.

  data: index type i.


  loop at it_draw_item_tr into wa_draw_item_tr.
*   Klassifikation lesen
*   Felder Füllen
    index = sy-tabix.

    clear it_charval.
    clear return.

    call function 'BAPI_DOCUMENT_GETDETAIL2'
      exporting
        documenttype               = wa_draw_item_tr-dokar
        documentnumber             = wa_draw_item_tr-doknr
        documentpart               = wa_draw_item_tr-doktl
        documentversion            = wa_draw_item_tr-dokvr
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
        getactivefiles             = ' '
        getdocdescriptions         = ' '
        getdocfiles                = ' '
        getclassification          = 'X'
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
      importing
*       DOCUMENTDATA               =
        return                     = return
      tables
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
*       DOCUMENTFILES              =
*       COMPONENTS                 =
        characteristicvalues       = it_charval
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
              .
    if return is initial.
    else.
      continue.
    endif.

*   wa_mdr_tr-tr_flag_name
    loop at it_charval into wa_charval
      where charname = wa_mdr_tr-tr_flag_name
      .
    endloop.
    if sy-subrc ne 0.
      delete it_draw_item_tr index index.
    else.
      if wa_charval-charvalue = wa_mdr_tr-tr_flag_val.
      else.
        delete it_draw_item_tr index index.
      endif.
    endif.

  endloop.

endform.                    " clean_out_with_class_tr
*&---------------------------------------------------------------------*
*&      Form  make_TOC_TR_MDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_toc_tr_mdr.
* Erstellung des Ziechnungsverzeichnisses für den MDR
* Zur Zeit Smartform des TR benutzen

* TR Erstellen
* Smartform
*NORMAL
  data: formname type tdsfname.
  data: fm_name type rs38l_fnam.
  data: ls_output_options type ssfcompop,
          ls_control_parameters type ssfctrlop,
          ls_job_output_info type ssfcrescl,
          ls_job_output_options type ssfcresop
          .

* Spoolauftrag erstellen
* Drucker holen, welcher keine Ausgabe hat DUMMY?
* Mglw. Dummy Drucker noch erstellen


* Formular benutzen
  clear formname.
  formname = wa_mdr_tr-smartform_tr.

  clear fm_name.
  call function 'SSF_FUNCTION_MODULE_NAME'
    exporting
      formname                 = formname
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
    importing
      fm_name                  = fm_name
    exceptions
      no_form                  = 1
      no_function_module       = 2
      others                   = 3
            .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ls_control_parameters-device = 'PRINTER'.
* ls_control_parameters-getotf = 'X'.
  ls_control_parameters-no_dialog = 'X'.
*  ls_control_parameters-PREVIEW = 'X'.
  ls_control_parameters-langu = sy-langu.

* DUMMY Übergabe
  ls_output_options-tddest = wa_mdr_tr-tddest.
  ls_output_options-tdprinter = wa_mdr_tr-tdprinter.


  ls_output_options-tdimmed = space.
  ls_output_options-tddelete = space.
  ls_output_options-tdnewid = 'X'.
  ls_output_options-tdlifetime = '8'.
  ls_output_options-tdfinal = 'X'.

  call function fm_name
    exporting
*        ARCHIVE_INDEX              =
*        ARCHIVE_INDEX_TAB          =
*        ARCHIVE_PARAMETERS         =
         control_parameters         = ls_control_parameters
*        MAIL_APPL_OBJ              =
*        MAIL_RECIPIENT             =
*        MAIL_SENDER                =
         output_options             = ls_output_options
         user_settings              = space
         wa_mdr_tr                  = wa_mdr_tr
         wa_prps                    = wa_prps
         wa_proj                    = wa_proj
       importing
*        DOCUMENT_OUTPUT_INFO       =
         job_output_info            = ls_job_output_info
         job_output_options         = ls_job_output_options
        tables
*          it_components              = et_components
           it_draw_item_tr          = it_draw_item_tr
       exceptions
         formatting_error           = 1
         internal_error             = 2
         send_error                 = 3
         user_canceled              = 4
         others                     = 5.
  if sy-subrc <> 0.
    raise error.
  else.
  endif.

* Spool ID abgreifen
  data: it_spoolids type tsfspoolid.
  data: spoolid type rspoid.
  it_spoolids[] = ls_job_output_info-spoolids[].

  clear spoolid.
  loop at it_spoolids into spoolid.
  endloop.

  if spoolid is initial.
    raise error.
  else.
  endif.

* Hinzufügen zu IT_OBJECTS
  clear wa_objects.
  wa_objects-object_type = 'SPOOL'.
  wa_objects-tdspoolid = spoolid.
  wa_objects-tcode = '/CIDEON/PLOT_MDR_TR'.

  append wa_objects to it_objects.

endform.                    " make_TOC_TR_MDR
*&---------------------------------------------------------------------*
*&      Form  send_objects_to_OM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form send_objects_to_om.
* Objekte ins OM senden

  clear wa_objects.
  loop at it_objects into wa_objects.
    wa_objects-mdr_dokar = wa_mdr_tr-mdr_dokar.
    wa_objects-mdr_doknr = wa_mdr_tr-mdr_doknr.
    wa_objects-mdr_doktl = wa_mdr_tr-mdr_doktl.
    wa_objects-mdr_dokvr = wa_mdr_tr-mdr_dokvr.

    wa_objects-root_dokar = wa_mdr_tr-root_dokar.
    wa_objects-root_doknr = wa_mdr_tr-root_doknr.
    wa_objects-root_doktl = wa_mdr_tr-root_doktl.
    wa_objects-root_dokvr = wa_mdr_tr-root_dokvr.

    modify it_objects from wa_objects index sy-tabix.
  endloop.

  call function 'Z_CL_PSBRW_WRT_PSB_TMP_SD_CS'
       exporting
            i_dateiname_ziel   = ''
            i_knz_start_output = 'X'
            i_knz_merge        = wa_mdr_tr-f_merge
            i_knz_merge_group  = wa_mdr_tr-f_dyn_toc
            i_knz_dyn_cov      = wa_mdr_tr-f_dyn_cov
       tables
            i_itab_objects     = it_objects
       exceptions
            error              = 1
            others             = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " send_objects_to_OM
