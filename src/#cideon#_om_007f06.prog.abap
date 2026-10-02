*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F06 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  change_copy
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_copy.
  data: kopien type zcl_s_plotlist-kopien.

  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  clear f_paste.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
    exit.
  else.
  endif.

  clear kopien.

  call function 'Z_CL_PLINT_TOOLS_ASK_FOR_COPY'
       exporting
            i_kopien = default_data-default_kopien
       importing
            o_kopien = kopien
       exceptions
            error    = 1
            forget   = 2
            others   = 3.
  if sy-subrc <> 0.
    if sy-subrc = 2.
      exit.
    else.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    endif.
  else.
  endif.

  loop at itab_et_index_rows_plotlist
    into wa_et_index_rows_plotlist.
    read table itab_plotjobs into wa_plotjobs
      index wa_et_index_rows_plotlist-index.
    wa_plotjobs-kopien = kopien.
    modify itab_plotjobs from wa_plotjobs
      index wa_et_index_rows_plotlist-index.
  endloop.


endform.                    " change_copy
*&---------------------------------------------------------------------*
*&      Form  change_COPY_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_copy_tree.

  perform sel_tree_to_sel_list.
  perform change_copy.

endform.                    " change_COPY_tree
*&---------------------------------------------------------------------*
*&      Form  change_note
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_note.
  data: notiz type zcl_s_plotlist-notiz.

  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  clear f_paste.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
    exit.
  else.
  endif.

  clear notiz.

  call function 'Z_CL_PLINT_TOOLS_ASK_FOR_NOTIZ'
       importing
            o_notiz = notiz
       exceptions
            error   = 1
            forget  = 2
            others  = 3.
  if sy-subrc <> 0.
    if sy-subrc = 2.
      exit.
    else.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    endif.
  else.
  endif.

  loop at itab_et_index_rows_plotlist
    into wa_et_index_rows_plotlist.
    read table itab_plotjobs into wa_plotjobs
      index wa_et_index_rows_plotlist-index.
    wa_plotjobs-notiz = notiz.
    modify itab_plotjobs from wa_plotjobs
      index wa_et_index_rows_plotlist-index.
  endloop.


endform.                    " change_note
*&---------------------------------------------------------------------*
*&      Form  change_note_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form change_note_tree.

  perform sel_tree_to_sel_list.
  perform change_note.

endform.                    " change_note_tree
*&---------------------------------------------------------------------*
*&      Form  save_fb_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_fb_list.
* Speichert die Fehlblattliste
  data: itab_fehlblatt_list type table of zcl_s_plotlist.
  data: wa_fehlblatt_list type zcl_s_plotlist.

  clear itab_fehlblatt_list.

  loop at itab_plotjobs into wa_fehlblatt_list.
    if wa_fehlblatt_list-knz_fehl_blatt = 'X'.
      append wa_fehlblatt_list to itab_fehlblatt_list.
    else.
    endif.
  endloop.

  call function '/CIDEON/DOWNLOAD_FEHLBLATT_LST'
       exporting
            i_speicher_ort_fb_liste = user_data-speicher_ort_fb_liste
            i_knz_static            = user_data-knz_static_fb_liste
            i_trennzeichen          = user_data-trennzeichen_fb_liste
            i_dialog                = user_data-knz_dialog_fb_liste
       tables
            i_itab_plotjobs         = itab_fehlblatt_list
       exceptions
            error                   = 1
            trennzeichen_initial    = 2
            others                  = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " save_fb_list
*&---------------------------------------------------------------------*
*&      Form  get_class_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_class_data.
* Klassendaten holen und in Stempel Tabelle einfügen
  data: itab_class_data type table of zcl_s_stempel_value.
  data: wa_class_data type zcl_s_stempel_value.
  data: wa_stempel_wert type zcl_s_stempel_value..

  clear itab_class_data.

  call function '/CIDEON/GET_CLASS_DATA'
       exporting
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       tables
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            o_itab_class_data = itab_class_data
       exceptions
            error             = 1
            others            = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


* Anhängen, dann Sortieren
  loop at itab_class_data into wa_class_data.
    clear wa_stempel_wert.
    move-corresponding wa_class_data to wa_stempel_wert.
    append wa_stempel_wert to itab_stempel_wert.
  endloop.

  sort itab_stempel_wert by zeile_plotjob stempel_name ascending.
*  DELETE ADJACENT DUPLICATES FROM itab_class_data.


endform.                    " get_class_data
*&---------------------------------------------------------------------*
*&      Form  make_auth_check_WS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_auth_check_ws.
* macht einen Check, ob der Nutzer überhaupt die Originaldatei ansehen
* darf! kein Ansehen -> kein Drucken

  call function '/CIDEON/MAKE_AUTH_CHECK_WS'
       exporting
            i_batch       = ''
       importing
            f_no_auth     = f_no_auth
       tables
            itab_plotjobs = itab_tmp_plotjobs
       exceptions
            error         = 1
            others        = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

*  DATA: wa_plotjobs_auth LIKE zcl_s_plotlist.
*
*  CLEAR f_no_auth.
*
*  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs_auth.
**   Berechtigungscheck
**   Aktivitäten zu Dokumenten
*    AUTHORITY-CHECK OBJECT 'C_DRAW_DOK'
*             ID 'DOKAR' FIELD wa_plotjobs_auth-dokar
*             ID 'ACTVT' FIELD '53'
*    .
*    IF sy-subrc > 0.
*      MESSAGE e099(zcl_plint_tools)
*        WITH 'C_DRAW_DOK' '53' wa_plotjobs_auth-dokar ''.
*      "Sie haben keine Berechtigung ..
*      f_no_auth = 'X'.
*      EXIT.
*    ELSE.
*    ENDIF.
*
**   Statusabhängige Berechtigung
*    AUTHORITY-CHECK OBJECT 'C_DRAW_TCS'
*             ID 'DOKAR' FIELD wa_plotjobs_auth-dokar
*             ID 'DOKST' FIELD wa_plotjobs_auth-dokst
*             ID 'ACTVT' FIELD '03'
*    .
*    IF sy-subrc > 0.
*      MESSAGE e099(zcl_plint_tools)
*        WITH 'C_DRAW_TCS' '03'
*        wa_plotjobs_auth-dokar wa_plotjobs_auth-dokst.
*      "Sie haben keine Berechtigung ..
*      f_no_auth = 'X'.
*      EXIT.
*    ELSE.
*    ENDIF.
*
*  ENDLOOP.

endform.                    " make_auth_check_WS
*&---------------------------------------------------------------------*
*&      Form  maintain_grp_kl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_grp_kl.

  call transaction 'Z_CL_MNTN_GRP_CL_KL'.

endform.                    " maintain_grp_kl
*&---------------------------------------------------------------------*
*&      Form  maintain_usr_grp_kl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_usr_grp_kl.

  call transaction 'Z_CL_MNTN_USR_GRP_KL'.

endform.                    " maintain_usr_grp_kl
*&---------------------------------------------------------------------*
*&      Form  maintain_grp_st_dok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_grp_st_dok.

  call transaction 'Z_CL_MNTN_GRP_ST_DOK'.

endform.                    " maintain_grp_st_dok
*&---------------------------------------------------------------------*
*&      Form  maintain_usr_grp_st
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_usr_grp_st.

  call transaction 'Z_CL_MNTN_USR_GRP_ST'.

endform.                    " maintain_usr_grp_st
*&---------------------------------------------------------------------*
*&      Form  maintain_grp_st_wsa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_grp_st_wsa.

  call transaction 'Z_CL_MNTN_GRP_ST_WSA'.

endform.                    " maintain_grp_st_wsa
*&---------------------------------------------------------------------*
*&      Form  maintain_usr_grp_sa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_usr_grp_sa.

  call transaction 'Z_CL_MNTN_USR_GRP_SA'.

endform.                    " maintain_usr_grp_sa
*&---------------------------------------------------------------------*
*&      Form  stamp_before_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form stamp_before_view.
* ruft Stempeltool vor der Anzeige auf
  data: i_appl_type type tdwx-apptp.
  data: i_draw type draw.
  data: i_target_file type dms_doc_file.
  data: i_docfile type dms_rec_file.
  data: i_draz type dms_tbl_draz.

  move-corresponding wa_plotjobs to i_draw.
  move-corresponding wa_plotjobs to i_target_file.
  move-corresponding wa_plotjobs to i_docfile.
  i_target_file-filename = wa_plotjobs-filep.
  i_target_file-dappl = wa_plotjobs-wsapplication.
  i_docfile-dappl = wa_plotjobs-wsapplication.


  call function '/CIDEON/STAMP_BEFORE_VIEW'
       exporting
            i_appl_type   = i_appl_type
            i_draw        = i_draw
            i_target_file = i_target_file
            i_docfile     = i_docfile
            i_draz        = i_draz
       exceptions
            error         = 1
            do_not_stamp  = 2
            others        = 3.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    if sy-subrc ne 2.
      perform delete_after_view.
      message e250(zcl_plint_message_01) with '' '' '' ''.
*   Konnte Dokument nicht stempeln -> kein Anzeige möglich. & & & &
      exit.
    else.
    endif.
  else.
  endif.



endform.                    " stamp_before_view
