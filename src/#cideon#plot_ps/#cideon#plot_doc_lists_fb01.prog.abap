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

  clear it_wbs_hr.

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
      e_wbs_hierarchie_table       = it_wbs_hr
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

  data: index_wbs type i.

* EasyDMS Dokumente berücksichtigen und aus der Tabelle löschen
* erstes Element wird vermieden

  clear it_drad_psp.

  loop at it_wbs into wa_wbs.
    index_wbs = sy-tabix.
*    clear wa_prps.
*    select single * from prps into wa_prps
*      where posid = wa_wbs-wbs_element
*      .
*    if sy-subrc ne 0.
*    else.
*    endif.
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

      clear wa_prps.
      select single * from prps into wa_prps
        where pspnr = ps_posnr
        .
      if sy-subrc ne 0.
      else.
      endif.

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

*   Hierachie lesen und zusammenbauen
    read table it_wbs_hr into wa_wbs_hr index index_wbs.
    data: tmp_hr(150).
    clear tmp_hr.

    do.
      if wa_wbs_hr-up is initial.
        exit.
      else.
        loop at it_wbs_hr into wa_wbs_hr_tmp
          where wbs_element = wa_wbs_hr-up
          .
        endloop.
        concatenate  wa_wbs_hr_tmp-wbs_element';' tmp_hr
          into tmp_hr.
        wa_wbs_hr = wa_wbs_hr_tmp.
      endif.
    enddo.

*   Übergabetabelle
    loop at doktab into wa_doktab.
      clear wa_objects.
      move-corresponding wa_doktab to wa_objects.

      wa_objects-pspnr = wa_prps-pspnr.
      wa_objects-projn = wa_prps-psphi.

      wa_objects-object_type = 'DOCUMENT'.

      wa_objects-psp_hierachy = tmp_hr.

      append wa_objects to it_objects.
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
*      characteristicvalues       = it_char_val
*      classallocations           = it_class_alloc
*     DOCUMENTDESCRIPTIONS       =
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

  else.
*   Ändern des Dokumentes
    data: documentdatax type bapi_doc_drawx2.

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

** BADI beachten zum Setzen der Daten für die jeweiligen System
** Möglichkeit der Anpassungen für den Kunden
*  IF badi_om_ps_01 IS INITIAL.
*  ELSE.
*    CALL METHOD badi_om_ps_01->chg_wa_mdr_tr_data_init
*      CHANGING
*        wa_mdr_tr = wa_mdr_tr
*        .
*  ENDIF.

* Smartform
  wa_mdr_tr-smartform_matlist = user_data-smartform_matlist.
  wa_mdr_tr-smartform_doclist = user_data-smartform_doclist.

* MDF
  wa_mdr_tr-f_wbs_bom = 'X'.
  wa_mdr_tr-mdf_template = 'c:\CONCAST Template.xls'.


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

  clear wa_prps.
  select single * from prps into wa_prps
    where posid = wa_wbs-wbs_element
    .
  if sy-subrc ne 0.
  else.
  endif.

  "key = wa_wbs-wbs_element.
  key = wa_prps-pspnr.

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
* Erstellung der Materialliste und der Dokumentenliste

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

  call function 'Z_CL_PSBRW_WRT_PSB_TMP_SD_CS'
       exporting
            i_dateiname_ziel   = ''
            i_knz_start_output = 'X'
            i_knz_merge        = 'X'
            i_knz_merge_group  = 'X'
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
