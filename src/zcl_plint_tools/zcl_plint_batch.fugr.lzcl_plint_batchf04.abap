*----------------------------------------------------------------------*
*   INCLUDE LZCL_PLINT_BATCHF04                                        *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  send_to_preprocessor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_to_preprocessor.


  CLEAR itab_tmp_plotjobs.
  REFRESH itab_tmp_plotjobs.
  itab_tmp_plotjobs = itab_plotjobs.
*       Senden an PreProzessor CLF-Dateien
  LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs.
    REFRESH itab_tmp_plotjobs_2.
    CLEAR wa_tmp_plotjobs_2.
    LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs_2
      WHERE
*          " voreinstellung = wa_tmp_plotjobs-voreinstellung
      verteiler = wa_tmp_plotjobs-verteiler.
      index_itab_tmp_plotjobs_2 = sy-tabix.
      APPEND wa_tmp_plotjobs_2 TO itab_tmp_plotjobs_2.
      DELETE itab_tmp_plotjobs INDEX index_itab_tmp_plotjobs_2.
    ENDLOOP.

    CLEAR wa_tmp_plotjobs_2.
    LOOP AT itab_tmp_plotjobs_2 INTO wa_tmp_plotjobs_2.
      index_itab_tmp_plotjobs_2 = sy-tabix.
      wa_tmp_plotjobs_2-cont = index_itab_tmp_plotjobs_2.
      wa_tmp_plotjobs_2-status = c_status_created_plot.

      MODIFY itab_tmp_plotjobs_2 FROM wa_tmp_plotjobs_2
      INDEX index_itab_tmp_plotjobs_2.
    ENDLOOP.

    str_down_path = wa_user_data-down_path.
    str_ppl_down_path = wa_user_data-clf_down_path.

    PERFORM get_stamp_values.

    PERFORM get_class_data.

    PERFORM get_result_stamp_values.

    IF wa_user_data-knz_use_admin_module = 'X'.
*         auf jeden Fall Job ID erzeugen!!!
      wa_user_data-knz_make_id_plotjob = 'X'.
    ELSE.
    ENDIF.

    IF wa_user_data-knz_make_id_plotjob = 'X'.
      CLEAR g_id_plotjob.
      CALL FUNCTION '/CIDEON/ID_PLOTJOB_GET_NEXT'
           EXPORTING
                i_numrange_object   = '/CIDEON/PJ'
                i_numrange_interval = '01'
           IMPORTING
                e_number            = g_id_plotjob.

      CLEAR wa_tmp_plotjobs_2.
      LOOP AT itab_tmp_plotjobs_2 INTO wa_tmp_plotjobs_2.
        index_itab_tmp_plotjobs_2 = sy-tabix.
        wa_tmp_plotjobs_2-id_plotjob = g_id_plotjob.

        MODIFY itab_tmp_plotjobs_2 FROM wa_tmp_plotjobs_2
          INDEX index_itab_tmp_plotjobs_2.
      ENDLOOP.
    ELSE.
    ENDIF.

*       Verarbeitung mit ADMIN Module
    IF wa_user_data-knz_use_admin_module = 'X'.
*         Daten in Übergabetabelle schreiben
      CLEAR wa_pl_jobs1.
      CLEAR wa_pl_jobs2.
      CLEAR wa_pl_jobs3.
      CLEAR wa_pl_jobss.
      CLEAR wa_pl_jobsc.
*         Verwaltungsdaten schreiben
      wa_pl_jobsc-id_plotjob = g_id_plotjob.
      wa_pl_jobsc-default_user = wa_default_data-default_nutzer.
      wa_pl_jobsc-down_path = str_down_path.
      wa_pl_jobsc-clf_down_path = str_ppl_down_path.
      wa_pl_jobsc-out_proc = wa_user_data-knz_auto_process.
      wa_pl_jobsc-delete_item = wa_user_data-delete_item.
      wa_pl_jobsc-delete_status = wa_user_data-delete_status.
      wa_pl_jobsc-format_checking =
          wa_user_data-knz_format_checking.
      wa_pl_jobsc-knz_use_converte = wa_user_data-knz_use_converte.
      wa_pl_jobsc-converter_name = wa_user_data-converter_name.
      wa_pl_jobsc-converter_number = wa_user_data-converter_number.
      wa_pl_jobsc-ftp_destination = wa_user_data-ftp_destination.
      wa_pl_jobsc-ftp_user = wa_user_data-ftp_user.
      wa_pl_jobsc-ftp_passwd  = wa_user_data-ftp_passwd.
      wa_pl_jobsc-ftp_down = wa_user_data-ftp_down.
      wa_pl_jobsc-knz_use_new_clf
        = wa_user_data-knz_use_new_clf_type.
      wa_pl_jobsc-knz_auto_process
        = wa_user_data-knz_auto_process.
      wa_pl_jobsc-zclinsname = g_user.
      wa_pl_jobsc-zclinsdate = sy-datum.
      wa_pl_jobsc-zclinstime = sy-uzeit.
      wa_pl_jobsc-zclinsprog = 'ZCL_PLINT_DESIGN_007F03'.
      wa_pl_jobsc-zclupdname = g_user.
      wa_pl_jobsc-zclupddate = sy-datum.
      wa_pl_jobsc-zclupdtime = sy-uzeit.
      wa_pl_jobsc-zclupdprog = 'ZCL_PLINT_DESIGN_007F03'.

      MODIFY /cideon/pl_jobsc FROM wa_pl_jobsc.
      IF sy-subrc NE 0.
*            MESSAGE e001(/cideon/plot_admin)
*              WITH '/CIDEON/PL_JOBSC' '' '' ''.
*            ROLLBACK WORK.
*            EXIT.
      ELSE.
      ENDIF.

*         Plotjobsdaten schreiben
      CLEAR wa_tmp_plotjobs_2.
      LOOP AT itab_tmp_plotjobs_2 INTO wa_tmp_plotjobs_2.
        CLEAR wa_pl_jobs1.
        MOVE-CORRESPONDING wa_tmp_plotjobs_2 TO wa_pl_jobs1.
        wa_pl_jobs1-id_plotjob = g_id_plotjob.

        wa_pl_jobs1-zclinsname = g_user.
        wa_pl_jobs1-zclinsdate = sy-datum.
        wa_pl_jobs1-zclinstime = sy-uzeit.
        wa_pl_jobs1-zclinsprog = 'ZCL_PLINT_DESIGN_007F03'.
        wa_pl_jobs1-zclupdname = g_user.
        wa_pl_jobs1-zclupddate = sy-datum.
        wa_pl_jobs1-zclupdtime = sy-uzeit.
        wa_pl_jobs1-zclupdprog = 'ZCL_PLINT_DESIGN_007F03'.

        CLEAR wa_pl_jobs2.
        MOVE-CORRESPONDING wa_tmp_plotjobs_2 TO wa_pl_jobs2.
        wa_pl_jobs2-knz_use_checked_ =
          wa_tmp_plotjobs_2-knz_use_checked_in.
        wa_pl_jobs2-id_plotjob = g_id_plotjob.

        wa_pl_jobs2-zclinsname = g_user.
        wa_pl_jobs2-zclinsdate = sy-datum.
        wa_pl_jobs2-zclinstime = sy-uzeit.
        wa_pl_jobs2-zclinsprog = 'ZCL_PLINT_DESIGN_007F03'.
        wa_pl_jobs2-zclupdname = g_user.
        wa_pl_jobs2-zclupddate = sy-datum.
        wa_pl_jobs2-zclupdtime = sy-uzeit.
        wa_pl_jobs2-zclupdprog = 'ZCL_PLINT_DESIGN_007F03'.

        CLEAR wa_pl_jobs3.
        MOVE-CORRESPONDING wa_tmp_plotjobs_2 TO wa_pl_jobs3.

        wa_pl_jobs3-zclinsname = g_user.
        wa_pl_jobs3-zclinsdate = sy-datum.
        wa_pl_jobs3-zclinstime = sy-uzeit.
        wa_pl_jobs3-zclinsprog = 'ZCL_PLINT_DESIGN_007F03'.
        wa_pl_jobs3-zclupdname = g_user.
        wa_pl_jobs3-zclupddate = sy-datum.
        wa_pl_jobs3-zclupdtime = sy-uzeit.
        wa_pl_jobs3-zclupdprog = 'ZCL_PLINT_DESIGN_007F03'.

        MODIFY /cideon/pl_jobs1 FROM wa_pl_jobs1.
        IF sy-subrc NE 0.
*              MESSAGE e001(/cideon/plot_admin)
*                WITH '/CIDEON/PL_JOBS1' '' '' ''.
*              ROLLBACK WORK.
*              EXIT.
        ELSE.
        ENDIF.

        MODIFY /cideon/pl_jobs2 FROM wa_pl_jobs2.
        IF sy-subrc NE 0.
*              MESSAGE e001(/cideon/plot_admin)
*                WITH '/CIDEON/PL_JOBS2' '' '' ''.
*              ROLLBACK WORK.
*              EXIT.
        ELSE.
        ENDIF.

        MODIFY /cideon/pl_jobs3 FROM wa_pl_jobs3.
        IF sy-subrc NE 0.
*              MESSAGE e001(/cideon/plot_admin)
*                WITH '/CIDEON/PL_JOBS3' '' '' ''.
*              ROLLBACK WORK.
*              EXIT.
        ELSE.
        ENDIF.

      ENDLOOP.

*         Stempeldaten schreiben
      LOOP AT itab_stempel_wert INTO wa_stempel_wert.
        CLEAR wa_pl_jobss.
        MOVE-CORRESPONDING wa_stempel_wert TO wa_pl_jobss.
        wa_pl_jobss-id_plotjob = g_id_plotjob.
        wa_pl_jobss-pos = sy-tabix.

        wa_pl_jobss-zclinsname = g_user.
        wa_pl_jobss-zclinsdate = sy-datum.
        wa_pl_jobss-zclinstime = sy-uzeit.
        wa_pl_jobss-zclinsprog = 'ZCL_PLINT_DESIGN_007F03'.
        wa_pl_jobss-zclupdname = g_user.
        wa_pl_jobss-zclupddate = sy-datum.
        wa_pl_jobss-zclupdtime = sy-uzeit.
        wa_pl_jobss-zclupdprog = 'ZCL_PLINT_DESIGN_007F03'.

        MODIFY /cideon/pl_jobss FROM wa_pl_jobss.
        IF sy-subrc NE 0.
*              MESSAGE e001(/cideon/plot_admin)
*                WITH '/CIDEON/PL_JOBSS' '' '' ''.
*              ROLLBACK WORK.
*              EXIT.
        ELSE.
        ENDIF.
      ENDLOOP.

*         mit nächstem Datensatz fortfahren
      CONTINUE.
    ELSE.
    ENDIF.

  ENDLOOP.

  COMMIT WORK AND WAIT.
  REFRESH itab_tmp_plotjobs_2.

ENDFORM.                    " send_to_preprocessor
*&---------------------------------------------------------------------*
*&      Form  get_stamp_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stamp_values.
* get the values for the stamps
  DATA: index_itab_plotjobs_2 TYPE sy-tabix.
* itab_tmp_plotjobs_2
* itab_stempel_wert

  REFRESH itab_stempel_default.
  SELECT * FROM zcl_stamp_defaul
    INTO TABLE itab_stempel_default
    WHERE status = c_status_aktiv
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  REFRESH itab_stempel_user.
  SELECT * FROM zcl_stamp_user
    INTO TABLE itab_stempel_user
    WHERE status = c_status_aktiv
    AND uname = g_user
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


  REFRESH itab_stempel_wert.

  LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
    REFRESH itab_stempel_voreinstellung.
    SELECT * FROM zcl_stamp_vorein
      INTO TABLE itab_stempel_voreinstellung
      WHERE status = c_status_aktiv
      AND voreinstellung = wa_plotjobs-voreinstellung
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
    IF wa_user_data-knz_use_post = 'X'.
    ELSE.
      "bei CLF bei Voreinstellungen
      REFRESH itab_stempel_voreinstellung.
    ENDIF.

    REFRESH itab_stempel_verteiler.
    SELECT * FROM zcl_stamp_vertei
      INTO TABLE itab_stempel_verteiler
      WHERE status = c_status_aktiv
      AND verteiler = wa_plotjobs-verteiler
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.


    index_itab_plotjobs_2 = sy-tabix.

*   default stamps
    LOOP AT itab_stempel_default INTO wa_stempel_default.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_default-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_default-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        CONTINUE.
      ENDIF.

      CALL FUNCTION wa_stempel_default-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_default-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   user stamps
    LOOP AT itab_stempel_user INTO wa_stempel_user.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_user-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_user-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_user-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   Voreinstellung stamps
    LOOP AT itab_stempel_voreinstellung INTO wa_stempel_voreinstellung.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_voreinstellung-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_vor'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_voreinstellung-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_voreinstellung-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   Verteiler stamps
    LOOP AT itab_stempel_verteiler INTO wa_stempel_verteiler.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_verteiler-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_vert'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_verteiler-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_verteiler-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " get_stamp_values
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
            i_nutzer          = g_user
            i_default_nutzer  = wa_default_data-default_nutzer
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
*&      Form  get_result_stamp_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_result_stamp_values.
* besorgt die resultierenden Stempeldaten, welche aus den normalen
* Stempelwerten und den Klassifizierungswerten gebildet werden können

  DATA: itab_res_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: wa_res_data TYPE zcl_s_stempel_value.
  DATA: wa_stempel_wert TYPE zcl_s_stempel_value..
*
*  CLEAR itab_class_data.

  CALL FUNCTION '/CIDEON/GET_RESULT_STAMP_DATA'
       EXPORTING
            i_nutzer          = g_user
            i_default_nutzer  = wa_default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            i_itab_stamp_data = itab_stempel_wert
            o_itab_stamp_data = itab_res_data
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Anhängen, dann Sortieren
  LOOP AT itab_res_data INTO wa_res_data.
    CLEAR wa_stempel_wert.
    MOVE-CORRESPONDING wa_res_data TO wa_stempel_wert.
    APPEND wa_stempel_wert TO itab_stempel_wert.
  ENDLOOP.

  SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.
*  DELETE ADJACENT DUPLICATES FROM itab_class_data.

* /CIDEON/GET_RESULT_STAMP_DATA
* View ZCL_V_USR_GRP_RS


ENDFORM.                    " get_result_stamp_values
*&---------------------------------------------------------------------*
*&      Form  update_copies
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DRZOC_TAB_NUM_COPIES  text
*----------------------------------------------------------------------*
FORM update_copies USING    p_drzoc_tab_num_copies.

  IF NOT p_drzoc_tab_num_copies IS INITIAL.
    LOOP AT itab_plotjobs INTO wa_plotjobs.
      wa_plotjobs-kopien = p_drzoc_tab_num_copies.
      MODIFY itab_plotjobs FROM wa_plotjobs.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " update_copies
*&---------------------------------------------------------------------*
*&      Form  initialize_itabs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_itabs.

  CLEAR: itab_items_fauf,
*        itab_documents,
*        itab_documents_add,
        itab_draw,
        itab_mat_status_exc,
        itab_search,
        itab_plint_usr_tdwp,
        itab_filetype,
        itab_draw_2,
        itab_zori_doc_files_3,
        itab_zori_doc_files_detail_3,
        itab_fail_document_3,
        itab_zori_doc_files,
        itab_zori_doc_files_detail,
        itab_fail_document,
        it_tdwp,
        itab_plotjobs,
        itab_tmp_plotjobs,
        itab_tmp_plotjobs_2,
        itab_tmp_plotjobs_3,
        itab_stempel_wert,
        itab_stempel_default,
        itab_stempel_user,
        itab_stempel_voreinstellung,
        itab_stempel_verteiler.

ENDFORM.                    " initialize_itabs
*&---------------------------------------------------------------------*
*&      Form  get_file_types_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file_types_2.
  CALL FUNCTION '/CIDEON/GET_FILE_TYPES'
       EXPORTING
            i_wa_default_data   = wa_default_data
            i_wa_user_data      = wa_user_data
            i_uname             = g_user  "sy-uname
       TABLES
            itab_plint_usr_tdwp = itab_plint_usr_tdwp
            itab_filetype       = itab_filetype
       EXCEPTIONS
            error               = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " get_file_types_2
*&---------------------------------------------------------------------*
*&      Form  set_knz_use_checked_in_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_knz_use_checked_in_2.
  CALL FUNCTION '/CIDEON/SET_KNZ_USE_CHECKED_IN'
       EXPORTING
            i_wa_user_data = wa_user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " set_knz_use_checked_in_2
*&---------------------------------------------------------------------*
*&      Form  add_client_data_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_client_data_4.
  CALL FUNCTION '/CIDEON/ADD_CLIENT_DATA_3'
       EXPORTING
            i_batch       = 'X'
            i_user        = g_user
       IMPORTING
            o_g_dms_max_tmp_files = g_dms_max_tmp_files
       TABLES
            itab_plotjobs = itab_plotjobs
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " add_client_data_4
*&---------------------------------------------------------------------*
*&      Form  add_cost_center_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cost_center_3.
  CALL FUNCTION '/CIDEON/ADD_COST_CENTER_2'
       EXPORTING
            i_wa_user_data = wa_user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " add_cost_center_3
