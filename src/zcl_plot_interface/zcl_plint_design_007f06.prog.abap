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
FORM change_copy.
  DATA: kopien TYPE zcl_s_plotlist-kopien.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR kopien.

  CALL FUNCTION 'Z_CL_PLINT_TOOLS_ASK_FOR_COPY'
       EXPORTING
            i_kopien = default_data-default_kopien
       IMPORTING
            o_kopien = kopien
       EXCEPTIONS
            error    = 1
            forget   = 2
            OTHERS   = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.

  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-kopien = kopien.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.


ENDFORM.                    " change_copy
*&---------------------------------------------------------------------*
*&      Form  change_COPY_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_copy_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_copy.

ENDFORM.                    " change_COPY_tree
*&---------------------------------------------------------------------*
*&      Form  change_note
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_note.
  DATA: notiz TYPE zcl_s_plotlist-notiz.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR notiz.

  CALL FUNCTION 'Z_CL_PLINT_TOOLS_ASK_FOR_NOTIZ'
       IMPORTING
            o_notiz = notiz
       EXCEPTIONS
            error   = 1
            forget  = 2
            OTHERS  = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.

  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-notiz = notiz.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.


ENDFORM.                    " change_note
*&---------------------------------------------------------------------*
*&      Form  change_note_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_note_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_note.

ENDFORM.                    " change_note_tree
*&---------------------------------------------------------------------*
*&      Form  save_fb_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_fb_list.
* Speichert die Fehlblattliste
  DATA: itab_fehlblatt_list TYPE TABLE OF zcl_s_plotlist.
  DATA: wa_fehlblatt_list TYPE zcl_s_plotlist.

  CLEAR itab_fehlblatt_list.

  LOOP AT itab_tmp_plotjobs INTO wa_fehlblatt_list.
    IF wa_fehlblatt_list-knz_fehl_blatt = 'X'.
      APPEND wa_fehlblatt_list TO itab_fehlblatt_list.
    ELSE.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION '/CIDEON/DOWNLOAD_FEHLBLATT_LST'
       EXPORTING
            i_speicher_ort_fb_liste = user_data-speicher_ort_fb_liste
            i_knz_static            = user_data-knz_static_fb_liste
            i_trennzeichen          = user_data-trennzeichen_fb_liste
            i_dialog                = user_data-knz_dialog_fb_liste
       TABLES
            i_itab_plotjobs         = itab_fehlblatt_list
       EXCEPTIONS
            error                   = 1
            trennzeichen_initial    = 2
            OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " save_fb_list
*&---------------------------------------------------------------------*
*&      Form  get_class_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_class_data.
* Klassendaten holen und in Stempel Tabelle einfügen
  DATA: itab_class_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: wa_class_data TYPE zcl_s_stempel_value.
  DATA: wa_stempel_wert TYPE zcl_s_stempel_value..

  CLEAR itab_class_data.

  CALL FUNCTION '/CIDEON/GET_CLASS_DATA'
       EXPORTING
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            o_itab_class_data = itab_class_data
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Anhängen, dann Sortieren
  LOOP AT itab_class_data INTO wa_class_data.
    CLEAR wa_stempel_wert.
    MOVE-CORRESPONDING wa_class_data TO wa_stempel_wert.
    APPEND wa_stempel_wert TO itab_stempel_wert.
  ENDLOOP.

  SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.
*  DELETE ADJACENT DUPLICATES FROM itab_class_data.


ENDFORM.                    " get_class_data
*&---------------------------------------------------------------------*
*&      Form  make_auth_check_WS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_auth_check_ws.
* macht einen Check, ob der Nutzer überhaupt die Originaldatei ansehen
* darf! kein Ansehen -> kein Drucken

  CALL FUNCTION '/CIDEON/MAKE_AUTH_CHECK_WS'
       EXPORTING
            i_batch       = ''
       IMPORTING
            f_no_auth     = f_no_auth
       TABLES
            itab_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

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

ENDFORM.                    " make_auth_check_WS
*&---------------------------------------------------------------------*
*&      Form  maintain_grp_kl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_grp_kl.

  CALL TRANSACTION 'Z_CL_MNTN_GRP_CL_KL'.

ENDFORM.                    " maintain_grp_kl
*&---------------------------------------------------------------------*
*&      Form  maintain_usr_grp_kl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_usr_grp_kl.

  CALL TRANSACTION 'Z_CL_MNTN_USR_GRP_KL'.

ENDFORM.                    " maintain_usr_grp_kl
*&---------------------------------------------------------------------*
*&      Form  maintain_grp_st_dok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_grp_st_dok.

  CALL TRANSACTION 'Z_CL_MNTN_GRP_ST_DOK'.

ENDFORM.                    " maintain_grp_st_dok
*&---------------------------------------------------------------------*
*&      Form  maintain_usr_grp_st
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_usr_grp_st.

  CALL TRANSACTION 'Z_CL_MNTN_USR_GRP_ST'.

ENDFORM.                    " maintain_usr_grp_st
*&---------------------------------------------------------------------*
*&      Form  maintain_grp_st_wsa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_grp_st_wsa.

  CALL TRANSACTION 'Z_CL_MNTN_GRP_ST_WSA'.

ENDFORM.                    " maintain_grp_st_wsa
*&---------------------------------------------------------------------*
*&      Form  maintain_usr_grp_sa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_usr_grp_sa.

  CALL TRANSACTION 'Z_CL_MNTN_USR_GRP_SA'.

ENDFORM.                    " maintain_usr_grp_sa
*&---------------------------------------------------------------------*
*&      Form  stamp_before_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM stamp_before_view.
* ruft Stempeltool vor der Anzeige auf
  DATA: i_appl_type TYPE tdwx-apptp.
  DATA: i_draw TYPE draw.
  DATA: i_target_file TYPE dms_doc_file.
  DATA: i_docfile TYPE dms_rec_file.
  DATA: i_draz TYPE dms_tbl_draz.

  MOVE-CORRESPONDING wa_plotjobs TO i_draw.
  MOVE-CORRESPONDING wa_plotjobs TO i_target_file.
  MOVE-CORRESPONDING wa_plotjobs TO i_docfile.
  i_target_file-filename = wa_plotjobs-filep.
  i_target_file-dappl = wa_plotjobs-wsapplication.
  i_docfile-dappl = wa_plotjobs-wsapplication.


  CALL FUNCTION '/CIDEON/STAMP_BEFORE_VIEW'
       EXPORTING
            i_appl_type   = i_appl_type
            i_draw        = i_draw
            i_target_file = i_target_file
            i_docfile     = i_docfile
            i_draz        = i_draz
       EXCEPTIONS
            error         = 1
            do_not_stamp  = 2
            OTHERS        = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    IF sy-subrc NE 2.
      PERFORM delete_after_view.
      MESSAGE e250(zcl_plint_message_01) WITH '' '' '' ''.
*   Konnte Dokument nicht stempeln -> kein Anzeige möglich. & & & &
      EXIT.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.



ENDFORM.                    " stamp_before_view
