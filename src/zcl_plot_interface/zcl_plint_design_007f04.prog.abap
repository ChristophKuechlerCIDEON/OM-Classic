*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_local_work_path
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_local_work_path.
* holt sich lokalen Arbeitspfad
  data: text(60).

* default_data-view_down_path
  call function 'WS_QUERY'
    exporting
*     ENVIRONMENT          =
*     FILENAME             =
      query                = 'CD'
*     WINID                =
   importing
      return               = default_data-view_down_path
   exceptions
     inv_query            = 1
     no_batch             = 2
     frontend_error       = 3
     others               = 4
            .
  if sy-subrc <> 0.
    clear text.

    case sy-subrc.
      when '1'.
        text = 'inv_query'.
      when '2'.
        text = 'no_batch'.
      when '3'.
        text = 'frontend_error'.
      when '4'.
        text = 'others'.
      when others.
        text = '????????'.
    endcase.

    message w164(zcl_plint_message_01)
      with text 'ZCL_PLINT_DESIGN_007F04' '' ''.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " get_local_work_path
*&---------------------------------------------------------------------*
*&      Form  view_originals_sl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_originals_sl.
* Original aus der Suchliste ansehen

  refresh itab_et_index_rows_searchlist.
  call method grid_searchlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_searchlist lines count_lines.
  if count_lines <> 1.
    refresh itab_et_index_rows_searchlist.
    message e000(zcl_plint_message_01)
      with text-051 count_lines '' ''.
    exit.
  else.
    read table itab_et_index_rows_searchlist
      into wa_et_index_rows_searchlist index 1.
    read table itab_search into wa_search
      index wa_et_index_rows_searchlist-index .
  endif.


* Spoolbehandlung
  if wa_search-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_search-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.


  set parameter id 'CV1' field wa_search-doknr.
  set parameter id 'CV2' field wa_search-dokar.
  set parameter id 'CV3' field wa_search-dokvr.
  set parameter id 'CV4' field wa_search-doktl.


* HOSTNAME holen
  data: hostname(20).
  call function 'CV120_GET_HOSTNAME'
       exporting
            pf_batch          = ' '
       importing
            pfx_host          = hostname
       exceptions
            error             = 1
            no_valid_frontend = 2
            others            = 3.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  call function 'CVAPI_DOC_VIEW'
    exporting
      pf_dokar               = wa_search-dokar
      pf_doknr               = wa_search-doknr
      pf_dokvr               = wa_search-dokvr
      pf_doktl               = wa_search-doktl
      pf_hostname            = hostname
      pf_appl_start          = 'X'
*     PF_GET_URL             = ' '
      pf_apptp               = '1'
*     PF_ASK_FILENAME        = ' '
*     PF_FILENAME            = ' '
*     PS_FILE                =
*     PF_PARENT              =
*     PF_USE_DYNP            = ' '
*     PS_DRAP_AUDIT          =
*   IMPORTING
*     PFX_FILE               =
*     PFX_URL                =
*     PFX_VIEW_INPLACE       =
   exceptions
      error                  = 1
      not_found              = 2
      no_auth                = 3
      no_original            = 4
      others                 = 5
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.



endform.                    " view_originals_sl
*&---------------------------------------------------------------------*
*&      Form  change_fronttype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_fronttype.
  data: lf_text like rseu0_fun-short.
** ---------------------------------------------------------------------

  call function 'CV117_FRONTEND_TYPE_SELECT'
      exporting: pf_hostname           = gs_frontend-hostname
                 pf_frontend_type      = gs_frontend-frontend_type
                 pf_update_db          = 'X'
      importing: pfx_new_frontend_type = gs_frontend-frontend_type
      exceptions: error                 = 1
                  error_update_db       = 2
                  no_change             = 3
                  no_valid_host         = 4
                  not_allowed           = 5
                  others                = 6.
  case sy-subrc.
    when 5.
      perform sys_get_function_text
          using ok_code
          changing lf_text.

      message s163(zcl_plint_message_01) with lf_text.
  endcase.

endform.                    " change_fronttype
*&---------------------------------------------------------------------*
*&      Form  sys_get_function_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*      <--P_LF_TEXT  text
*----------------------------------------------------------------------*
form sys_get_function_text using pf_fcode
                           changing pfx_text.

  data: lt_text  like rseu0_fun occurs 0 with header line,
        lf_repid like sy-repid.
** ---------------------------------------------------------------------

  lf_repid = sy-repid.
  clear pfx_text.

  call function 'RS_CUA_GET_TEXTS'
       exporting: language = sy-langu
                  name     = lf_repid
       tables:    texts    = lt_text
       exceptions: cua_not_found     = 01
                   no_texts          = 02
                   program_not_found = 03.
  if sy-subrc = 0.
    read table lt_text with key code = pf_fcode.
    if sy-subrc = 0.
      pfx_text = lt_text-short.
    endif.
  endif.

endform.                    " sys_get_function_text
*&---------------------------------------------------------------------*
*&      Form  add_client_data_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_client_data_2.
* Adds special client data to plotjobs
  data: wa_kna1 like kna1.
  data: mailadresse type ad_smtpadr.
  data: n10(10) type n.

  clear wa_kna1.
  clear mailadresse.


  data: rc type table of bapiret2.
  data: wa_address type bapiaddr3.
  data: wa_company type bapiuscomp.

  data: itab_addtel type table of bapiadtel.
  data: itab_addsmtp type table of bapiadsmtp.

  clear rc.
  clear wa_address.
  clear wa_company.
  clear itab_addtel.
  clear itab_addsmtp.

  call function 'BAPI_USER_GET_DETAIL'
    exporting
      username             = sy-uname
   importing
*     LOGONDATA            =
*     DEFAULTS             =
     address              = wa_address
     company              = wa_company
*     SNC                  =
*     REF_USER             =
*     alias                = wa_alias
    tables
*     PARAMETER            =
*     PROFILES             =
*     ACTIVITYGROUPS       =
      return               = rc
      addtel               = itab_addtel
*     ADDFAX               =
*     ADDTTX               =
*     ADDTLX               =
      addsmtp              = itab_addsmtp
*     ADDRML               =
*     ADDX400              =
*     ADDRFC               =
*     ADDPRT               =
*     ADDSSF               =
*     ADDURI               =
*     ADDPAG               =
*     ADDCOMREM            =
*     GROUPS               =
            .



*  IF user_data-knz_user_dummy = 'X'.
*    IF user_data-user_dummy_kunnr IS INITIAL.
*      MESSAGE i020(zcl_plint_message_01) WITH '' '' '' ''.
*      EXIT.
*    ELSE.
*      n10 = user_data-user_dummy_kunnr.
*      SELECT SINGLE * FROM kna1 INTO wa_kna1
*        WHERE kunnr = n10
*        .
*      IF sy-subrc NE 0.
*        MESSAGE i021(zcl_plint_message_01)
*          WITH user_data-user_dummy_kunnr '' '' ''.
*        EXIT.
*      ELSE.
*        SELECT SINGLE smtp_addr FROM adr6
*          INTO mailadresse
*          WHERE addrnumber = wa_kna1-adrnr.
*        IF sy-subrc NE 0.
*        ELSE.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ELSE.
*  ENDIF.

  loop at itab_tmp_plotjobs into wa_plotjobs.
    wa_plotjobs-name1 = wa_address-firstname.
    wa_plotjobs-name2 = wa_address-lastname.
*    "wa_plotjobs-firma = wa_kna1-
*    "wa_plotjobs-abteilung = wa_kna1-
*    wa_plotjobs-stras = wa_kna1-stras.
*    wa_plotjobs-ort1 = wa_kna1-ort01.
*    wa_plotjobs-pstlz = wa_kna1-pstlz.
    concatenate wa_address-tel1_numbr ' / ' wa_address-tel1_ext
      into wa_plotjobs-telf1.
*    wa_plotjobs-telf1 = .
*    wa_plotjobs-telfx = wa_kna1-telfx.
    wa_plotjobs-smtp_addr = wa_address-e_mail.
*
*
    wa_plotjobs-firma = wa_company-company.

    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.

  endloop.


endform.                    " add_client_data_2
*&---------------------------------------------------------------------*
*&      Form  del_down_files_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form del_down_files_2.
  data: down_path type string.
  data: clf_down_path type string.

  clf_down_path = user_data-clf_down_path.
  down_path = user_data-down_path.


  call function 'SAPGUI_PROGRESS_INDICATOR'
       exporting
            percentage = '20'  " Balkenanzeige
            text       = text-040.


  call function 'Z_CL_DEL_TMP_DIR_BY_NAMES'
       exporting
            i_clf_down_path = clf_down_path
            i_down_path     = down_path
            i_test          = ''
       exceptions
            error           = 1
            others          = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " del_down_files_2
*&---------------------------------------------------------------------*
*&      Form  delete_sl_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form delete_sl_items.
* alte Einträge aus der Tabelle ZCL_SL_TMP löschen.

  delete  from  zcl_sl_tmp
    where uname = sy-uname
    .
  if sy-subrc ne 0.
  else.
  endif.


endform.                    " delete_sl_items
*&---------------------------------------------------------------------*
*&      Form  make_display_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_display_icon.
* updates the DISPLAY_ICON in the searchlist
  loop at itab_search into wa_search.
    wa_search-icon_display = icon_doc_item_detail.

    wa_search-icon_display_dis = icon_doc_header_detail.

    modify itab_search from wa_search index sy-tabix.
  endloop.

endform.                    " make_display_icon
*&---------------------------------------------------------------------*
*&      Form  view_originals_sl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_originals_sl_hot.
* Originale in der Suchliste per HOTSPOT ansehen

* Spoolbehandlung
  if wa_akt_search-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_akt_search-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.


  set parameter id 'CV1' field wa_akt_search-doknr.
  set parameter id 'CV2' field wa_akt_search-dokar.
  set parameter id 'CV3' field wa_akt_search-dokvr.
  set parameter id 'CV4' field wa_akt_search-doktl.


* HOSTNAME holen
  data: hostname(20).
  call function 'CV120_GET_HOSTNAME'
       exporting
            pf_batch          = ' '
       importing
            pfx_host          = hostname
       exceptions
            error             = 1
            no_valid_frontend = 2
            others            = 3.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  call function 'CVAPI_DOC_VIEW'
    exporting
      pf_dokar               = wa_akt_search-dokar
      pf_doknr               = wa_akt_search-doknr
      pf_dokvr               = wa_akt_search-dokvr
      pf_doktl               = wa_akt_search-doktl
      pf_hostname            = hostname
      pf_appl_start          = 'X'
*     PF_GET_URL             = ' '
      pf_apptp               = '1'
*     PF_ASK_FILENAME        = ' '
*     PF_FILENAME            = ' '
*     PS_FILE                =
*     PF_PARENT              =
*     PF_USE_DYNP            = ' '
*     PS_DRAP_AUDIT          =
*   IMPORTING
*     PFX_FILE               =
*     PFX_URL                =
*     PFX_VIEW_INPLACE       =
   exceptions
      error                  = 1
      not_found              = 2
      no_auth                = 3
      no_original            = 4
      others                 = 5
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.



endform.                    " view_originals_sl_hot
*&---------------------------------------------------------------------*
*&      Form  cv03n_view_sl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form cv03n_view_sl_hot.
* DIS aus HOTSPOT ansehen

* Spoolbehandlung
  if wa_akt_search-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_akt_search-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.

  set parameter id 'CV1' field wa_akt_search-doknr.
  set parameter id 'CV2' field wa_akt_search-dokar.
  set parameter id 'CV3' field wa_akt_search-dokvr.
  set parameter id 'CV4' field wa_akt_search-doktl.

  call transaction 'CV03N' and skip first screen.

endform.                    " cv03n_view_sl_hot
*&---------------------------------------------------------------------*
*&      Form  view_originals_pl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_originals_pl_hot.

  perform read_akt_line_plotlist.
  perform set_tree_sel_node.

  wa_plotjobs = wa_akt_plotjobs.

* Spoolbehandlung
  if wa_plotjobs-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_plotjobs-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.

*     Dokument in der Plottingliste ansehen
*  PERFORM get_selected_line_plotjobs.
  perform get_set_view_program.
  perform check_kapro.

  perform stamp_before_view.

  case wa_view_program-programm.
    when 'EAI 2D'.
      perform view_document_02.
    when 'EAI 3D'.
      perform view_document_03.
    when 'OFFICE'.
      perform view_document.
  endcase.
  perform delete_after_view.


endform.                    " view_originals_pl_hot
*&---------------------------------------------------------------------*
*&      Form  cv03n_view_pl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form cv03n_view_pl_hot.
  perform read_akt_line_plotlist.
  perform set_tree_sel_node.

* Spoolbehandlung
  if wa_akt_plotjobs-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_akt_plotjobs-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.

  set parameter id 'CV1' field wa_akt_plotjobs-doknr.
  set parameter id 'CV2' field wa_akt_plotjobs-dokar.
  set parameter id 'CV3' field wa_akt_plotjobs-dokvr.
  set parameter id 'CV4' field wa_akt_plotjobs-doktl.

  call transaction 'CV03N' and skip first screen.


endform.                    " cv03n_view_pl_hot
