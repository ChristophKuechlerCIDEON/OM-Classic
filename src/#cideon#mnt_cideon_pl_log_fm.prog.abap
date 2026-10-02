*----------------------------------------------------------------------*
*   INCLUDE ZCK_MAINT_ZCL_GRP_CLASS_KL_FM                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SHOW_UPDINS_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_updins_info.
  DATA: wa_insupd LIKE /cideon/insupd.

  MOVE-CORRESPONDING /cideon/pl_log TO wa_insupd.
*  CALL FUNCTION 'Z_CK_SHOW_INS_UPD'
*       EXPORTING
*            i_insupd_data = wa_insupd.

ENDFORM.                               " SHOW_UPDINS_INFO

*&---------------------------------------------------------------------*
*&      Form  READ_MARKED_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_marked_lines.
  REFRESH it_det.
  REFRESH it_selected_rows.
  max_lines = 0.
  CALL METHOD ref_alv->get_selected_rows
     IMPORTING
       et_index_rows = it_selected_rows.

  LOOP AT it_selected_rows INTO wa_selected_rows.
    READ TABLE it INTO wa
               INDEX wa_selected_rows-index.
    APPEND wa TO it_det.
    max_lines = max_lines + 1.
  ENDLOOP.
  READ TABLE it_det INTO /cideon/pl_log INDEX 1.
  READ TABLE it_det INTO /cideon/pl_log INDEX 1.
*  IF NOT zhy3_order_hd-no_order IS INITIAL AND
*         max_lines = 0.
*    max_lines = 1.
*  ENDIF.
  index = 1.
ENDFORM.                               " READ_MARKED_LINES

*&---------------------------------------------------------------------*
*&      Form  READ_MARKED_LINES_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_marked_lines_job.
  DATA: wa_temp LIKE LINE OF it.

  REFRESH it_det.
  REFRESH it_selected_rows.

  max_lines = 0.
  CALL METHOD ref_alv->get_selected_rows
     IMPORTING
       et_index_rows = it_selected_rows.

  LOOP AT it_selected_rows INTO wa_selected_rows.
** Alle Dateien zu JOB ID lesen
    READ TABLE it INTO wa
           INDEX wa_selected_rows-index.
    LOOP AT it INTO wa_temp
      WHERE id_plotjob = wa-id_plotjob.
      READ TABLE it_det TRANSPORTING NO FIELDS
        WITH KEY id = wa_temp-id.
      IF sy-subrc <> 0.
        APPEND wa_temp TO it_det.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*  READ TABLE it_det INTO /cideon/pl_log INDEX 1.
*  READ TABLE it_det INTO /cideon/pl_log INDEX 1.
**  IF NOT zhy3_order_hd-no_order IS INITIAL AND
**         max_lines = 0.
**    max_lines = 1.
**  ENDIF.
*  index = 1.

ENDFORM.                    " READ_MARKED_LINES_JOB

*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data.

  PERFORM make_insupd.

* Modify DB
  MODIFY (tabname) FROM /cideon/pl_log.
  IF sy-subrc NE 0.
    MESSAGE i002(zck_dialog)
      WITH tabname '' '' ''.
  ELSE.
  ENDIF.
* modify internal table
  MODIFY it_det FROM /cideon/pl_log INDEX index.

  PERFORM show_new_data.
  CLEAR wa_save_neccessary.

  LOOP AT it INTO wa
    WHERE
      id = /cideon/pl_log-id
      .

    IF sy-subrc NE 0.
    ELSE.
      index = sy-tabix.
      EXIT.
    ENDIF.
  ENDLOOP.


  PERFORM set_marked_line.

ENDFORM.                               " SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.

  SELECT * FROM (tabname)
    UP TO max_sel ROWS BYPASSING BUFFER
    INTO TABLE it
      WHERE
      id IN s_id
      AND id_plotjob IN s_jid
      AND id_plotjob_32 IN s_jid_32

      AND dokar IN s_dokar
      AND doknr IN s_doknr
      AND doktl IN s_doktl
      AND dokvr IN s_dokvr
      and dokst in s_dokst

      AND wsapplication IN s_dappl
      AND filep IN s_filep
      AND kopien IN s_kopien
      AND verteiler IN s_vertei
      AND vbeln IN s_vbeln
      AND aufnr IN s_aufnr
      AND kostl IN s_kostl
      AND notiz IN s_notiz

      AND lifnr IN  s_lifnr
      AND name1_lifnr IN s_name1
      AND ebeln IN s_ebeln
      AND matnr IN s_matnr

      AND sernr IN s_sernr

      AND status IN s_status

      AND recdate IN s_rcdate
      AND duedate IN s_dudate
      AND senddate IN s_sedate
      AND m1date IN s_m1date
      AND m2date IN s_m2date

      AND pspid IN s_pspid

        AND kunnr_ag IN s_ku_ag
      AND kunnr_we IN s_ku_we

      AND aennr IN s_aennr

         AND zclinsname   IN sinsname
         AND zclinsdate   IN sinsdate
         AND zclinstime   IN sinstime
         AND zclinsprog   IN sinsprog
         AND zclupdname   IN supdname
         AND zclupddate   IN supddate
         AND zclupdtime   IN supdtime
         AND zclupdprog   IN supdprog

      AND print_type IN s_pr_ty
      AND recipient IN s_reci
      AND nr_copies IN s_nr_cop
      AND print_cause IN s_pr_cau
      AND charg IN s_charg

      AND date_exterm IN s_date_x
      AND time_exterm IN s_time_x
      AND user_exterm IN s_user_x
      AND cause_exterm IN s_caus_x

         .

  IF sy-subrc NE 0.
    PERFORM get_data_count.
    IF count_lines EQ 0.
    ELSE.
      MESSAGE i001(zck_dialog) WITH tabname '' '' ''.
    ENDIF.
  ELSE.
  ENDIF.


* Felder in Tabelle setzen frü Visualisierung
  DATA: index TYPE i.

  CLEAR wa-status.
  CLEAR wa-led_due_rec.

  LOOP AT it INTO wa.
    index = sy-tabix.
*   Status LED visualisieren
    CASE wa-status.
      WHEN '00'.
        wa-led_status = icon_create.
      WHEN '10'.
        wa-led_status = icon_locked.
      WHEN '20'.
        wa-led_status = icon_okay.
      WHEN '30'.
        wa-led_status = icon_cancel.
      WHEN '40'.
        wa-led_status = icon_action_success.
      WHEN OTHERS.
    ENDCASE.

*   Status LED für DUE / REC Date
    IF wa-duedate IS INITIAL
    AND wa-recdate IS INITIAL.
      wa-led_due_rec = icon_action_success.
    ELSE.
      "wa-led_due_rec = icon_okay.
    ENDIF.

    IF NOT wa-duedate IS INITIAL
    AND NOT wa-recdate IS INITIAL.
      wa-led_due_rec = icon_okay.
    ELSE.
    ENDIF.

    MODIFY it FROM wa INDEX index.
  ENDLOOP.

ENDFORM.                               " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DELETE_ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_entry.
  DELETE FROM (tabname)
    WHERE
      id = /cideon/pl_log-id
      .

  CLEAR /cideon/pl_log.
  wa_edit_mode = co_show_mode.
  PERFORM show_new_data.
ENDFORM.                               " DELETE_ENTRY

*&---------------------------------------------------------------------*
*&      Form  SHOW_NEW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_new_data.
  CLEAR f_whole_job.
  PERFORM get_data.
  CALL METHOD ref_alv->refresh_table_display.
ENDFORM.                               " SHOW_NEW_DATA

*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_to_confirm.
  IF wa_save_neccessary = 'X' OR NOT sy-datar IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
         EXPORTING
              textline1 = 'Wollen Sie die Bearbeitung beenden?'(001)
              titel     = 'Bearbeitung beenden'(002)
         IMPORTING
              answer    = answer
         EXCEPTIONS
              OTHERS    = 1.
  ELSE.
    answer = 'J'.
  ENDIF.
ENDFORM.                               " POPUP_TO_CONFIRM

*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_field_catalog.

  REFRESH it_field_cat.
*  wa_field_cat-fieldname  = 'TEST_FIELD'.
*  wa_field_cat-coltext    = 'Testspalte'.
*  wa_field_cat-tooltip    = 'Testspalte'.
*  wa_field_cat-seltext    = 'Testspalte'.
*  wa_field_cat-just       = 'C'.
*  wa_field_cat-outputlen  = 30.
*  wa_field_cat-intlen     = 10.
*  wa_field_cat-inttype    = 'I'.
*  wa_field_cat-col_pos    = 3.
*  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSNAME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSDATE'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSTIME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSPROG'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDNAME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDDATE'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDTIME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDPROG'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

ENDFORM.                               " SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  make_INSUPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_insupd.
*  FIELD-SYMBOLS <wa> TYPE ty_. "ZCL_grp_class_kl.


  ASSIGN /cideon/pl_log TO <wa> .

  IF <wa>-zclinsname IS INITIAL.
    <wa>-zclinsname = sy-uname.
    <wa>-zclinsdate = sy-datum.
    <wa>-zclinstime = sy-uzeit.
    <wa>-zclinsprog = sy-repid.
    <wa>-zclupdname = sy-uname.
    <wa>-zclupddate = sy-datum.
    <wa>-zclupdtime = sy-uzeit.
    <wa>-zclupdprog = sy-repid.
  ELSE.
    <wa>-zclupdname = sy-uname.
    <wa>-zclupddate = sy-datum.
    <wa>-zclupdtime = sy-uzeit.
    <wa>-zclupdprog = sy-repid.
  ENDIF.

ENDFORM.                    " make_INSUPD
*&---------------------------------------------------------------------*
*&      Form  get_data_count
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_count.

  CLEAR count_lines.

  SELECT COUNT( * ) FROM (tabname)
    INTO count_lines
      WHERE
      id IN s_id
      AND id_plotjob IN s_jid
      AND id_plotjob_32 IN s_jid_32

      AND dokar IN s_dokar
      AND doknr IN s_doknr
      AND doktl IN s_doktl
      AND dokvr IN s_dokvr
      and dokst in s_dokst

      AND wsapplication IN s_dappl
      AND filep IN s_filep
      AND kopien IN s_kopien
      AND verteiler IN s_vertei
      AND vbeln IN s_vbeln
      AND aufnr IN s_aufnr
      AND kostl IN s_kostl
      AND notiz IN s_notiz

      AND lifnr IN  s_lifnr
      AND name1_lifnr IN s_name1
      AND ebeln IN s_ebeln
      AND matnr IN s_matnr

      AND sernr IN s_sernr

      AND status IN s_status

      AND recdate IN s_rcdate
      AND duedate IN s_dudate
      AND senddate IN s_sedate
      AND m1date IN s_m1date
      AND m2date IN s_m2date

      AND pspid IN s_pspid

      AND kunnr_ag IN s_ku_ag
      AND kunnr_we IN s_ku_we

      AND aennr IN s_aennr

      AND zclinsname IN sinsname
      AND zclinsdate IN sinsdate
      AND zclinstime IN sinstime
      AND zclinsprog IN sinsprog
      AND zclupdname IN supdname
      AND zclupddate IN supddate
      AND zclupdtime IN supdtime
      AND zclupdprog IN supdprog



      .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
ENDFORM.                    " get_data_count
*&---------------------------------------------------------------------*
*&      Form  set_marked_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_marked_line.

  REFRESH it_selected_rows.
  CLEAR wa_selected_rows.

  wa_selected_rows-index = index.
  APPEND wa_selected_rows TO it_selected_rows.

  CALL METHOD ref_alv->set_selected_rows
    EXPORTING
      it_index_rows = it_selected_rows
*      IT_ROW_NO     =
      .


ENDFORM.                    " set_marked_line
*&---------------------------------------------------------------------*
*&      Form  transport_marked_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transport_marked_lines.

  DATA: i LIKE e071-as4pos,
        korrnum LIKE e070-trkorr VALUE space,
        lt_e071 LIKE e071 OCCURS 0 WITH HEADER LINE,
        lt_e071k LIKE e071k OCCURS 0 WITH HEADER LINE.

  TYPES:
    BEGIN OF t_tabkey,
      mandt TYPE mandt,
*      parameter_name TYPE /cideon/cadm_par-parameter_name,
     END OF t_tabkey.

  DATA: tabkey TYPE t_tabkey.


* Set constant values in transport tables
  CLEAR lt_e071k.
  lt_e071k-pgmid = 'R3TR'.
  lt_e071k-object = 'TABU'.
  lt_e071k-objname = tabname.
  lt_e071k-mastertype = 'TABU'.
  lt_e071k-mastername = lt_e071k-objname.
  lt_e071k-objfunc = space.

  CLEAR lt_e071.
  lt_e071-pgmid = 'R3TR'.
  lt_e071-object = 'TABU'.
  lt_e071-obj_name = lt_e071k-objname.
  lt_e071-objfunc = 'K'.

  APPEND lt_e071.

* copy Tabkeys into transport tables.
  IF it_det IS INITIAL.
    CLEAR tabkey.
    tabkey = wa.
    MOVE tabkey TO lt_e071k-tabkey.
    APPEND lt_e071k.
  ELSE.
    LOOP AT it_det INTO wa.
      CLEAR tabkey.
      tabkey = wa.
      MOVE tabkey TO lt_e071k-tabkey.
      APPEND lt_e071k.
    ENDLOOP.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.

* Get task from popup
  IF korrnum IS INITIAL.
    CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
         EXPORTING
              iv_category            = 'SYST'
         IMPORTING
              ev_task                = korrnum
         EXCEPTIONS
              invalid_category       = 1
              no_correction_selected = 2
              OTHERS                 = 3.
    IF sy-subrc = 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING no_correction_selected.
    ELSEIF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING tr_system_error.
    ENDIF.
  ENDIF.

* Append sets to task
  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
       EXPORTING
            wi_trkorr = korrnum
       TABLES
            wt_e071   = lt_e071
            wt_e071k  = lt_e071k
       EXCEPTIONS
            OTHERS    = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING tr_system_error.
  ELSE.
    IF wa_save_neccessary = 'X'.
      PERFORM save_data.
    ENDIF.
    IF ok_code = 'DEL'.
      "PERFORM delete_entry.
    ENDIF.
  ENDIF.
ENDFORM.                    " transport_marked_lines
*&---------------------------------------------------------------------*
*&      Form  popup_to_confirm_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_to_confirm_transaction.

  IF max_lines > 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
              titlebar              = text-030
              text_question         = text-031
              display_cancel_button = ''
         IMPORTING
              answer                = answer.

    IF answer = '1'.
      answer = 'J'.

    ENDIF.
  ENDIF.

ENDFORM.                    " popup_to_confirm_transaction
*&---------------------------------------------------------------------*
*&      Form  dis_view_marked_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dis_view_marked_lines.

  IF it_det IS INITIAL.
*   wa anzeigen
    SET PARAMETER ID 'CV1' FIELD wa-doknr.
    SET PARAMETER ID 'CV2' FIELD wa-dokar.
    SET PARAMETER ID 'CV3' FIELD wa-dokvr.
    SET PARAMETER ID 'CV4' FIELD wa-doktl.

    CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
  ELSE.
    LOOP AT it_det INTO wa.
*   wa anzeigen
      SET PARAMETER ID 'CV1' FIELD wa-doknr.
      SET PARAMETER ID 'CV2' FIELD wa-dokar.
      SET PARAMETER ID 'CV3' FIELD wa-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa-doktl.

      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
    ENDLOOP.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.



ENDFORM.                    " dis_view_marked_lines
*&---------------------------------------------------------------------*
*&      Form  confirm_marked_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_marked_lines.
  IF it_det IS INITIAL.
*   wa Sichern mit Status "confirmed"
    IF wa-status = '00'.
    ELSE.
      MESSAGE w003(zck_dialog)
        WITH wa-dokar wa-doknr
        wa-doktl wa-dokvr.
      EXIT.
    ENDIF.

    wa-status = '20'.
    wa-zclupdname = sy-uname.
    wa-zclupddate = sy-datum.
    wa-zclupdtime = sy-uzeit.
    wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

    MODIFY (tabname) FROM wa.
    IF sy-subrc NE 0.
      MESSAGE i002(zck_dialog)
        WITH tabname '' '' ''.
    ELSE.
    ENDIF.
* modify internal table
    MODIFY it_det FROM wa INDEX index.

    PERFORM show_new_data.
  ELSE.
    LOOP AT it_det INTO wa.
*     wa Sichern mit Status "confirmed"
      IF wa-status = '00'.
      ELSE.
        MESSAGE w003(zck_dialog)
          WITH wa-dokar wa-doknr
          wa-doktl wa-dokvr.
        EXIT.
      ENDIF.

      wa-status = '20'.
      wa-zclupdname = sy-uname.
      wa-zclupddate = sy-datum.
      wa-zclupdtime = sy-uzeit.
      wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

      MODIFY (tabname) FROM wa.
      IF sy-subrc NE 0.
        MESSAGE i002(zck_dialog)
          WITH tabname '' '' ''.
      ELSE.
      ENDIF.
*     modify internal table
      MODIFY it_det FROM wa INDEX index.

    ENDLOOP.
    IF sy-subrc <> 0.
      PERFORM show_new_data.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " confirm_marked_lines
*&---------------------------------------------------------------------*
*&      Form  confirm_marked_lines_failure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_marked_lines_failure.
  IF it_det IS INITIAL.
*   wa Sichern mit Status "confirmed"
    IF wa-status = '00'.
    ELSE.
      MESSAGE w003(zck_dialog)
        WITH wa-dokar wa-doknr
        wa-doktl wa-dokvr.
      EXIT.
    ENDIF.

    wa-status = '30'.
    wa-zclupdname = sy-uname.
    wa-zclupddate = sy-datum.
    wa-zclupdtime = sy-uzeit.
    wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

    MODIFY (tabname) FROM wa.
    IF sy-subrc NE 0.
      MESSAGE i002(zck_dialog)
        WITH tabname '' '' ''.
    ELSE.
    ENDIF.
* modify internal table
    MODIFY it_det FROM wa INDEX index.

    PERFORM show_new_data.
  ELSE.
    LOOP AT it_det INTO wa.
*     wa Sichern mit Status "confirmed"
      IF wa-status = '00'.
      ELSE.
        MESSAGE w003(zck_dialog)
          WITH wa-dokar wa-doknr
          wa-doktl wa-dokvr.
        EXIT.
      ENDIF.

      wa-status = '30'.
      wa-zclupdname = sy-uname.
      wa-zclupddate = sy-datum.
      wa-zclupdtime = sy-uzeit.
      wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

      MODIFY (tabname) FROM wa.
      IF sy-subrc NE 0.
        MESSAGE i002(zck_dialog)
          WITH tabname '' '' ''.
      ELSE.
      ENDIF.
*     modify internal table
      MODIFY it_det FROM wa INDEX index.

    ENDLOOP.
    IF sy-subrc <> 0.
      PERFORM show_new_data.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " confirm_marked_lines_failure
*&---------------------------------------------------------------------*
*&      Form  received_back_today
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM received_back_today.
* Ausgabe heute zurückerhalten
  IF it_det IS INITIAL.
*   wa Sichern mit Status "confirmed"
    IF wa-status = '00'.
    ELSE.
      MESSAGE w003(zck_dialog)
        WITH wa-dokar wa-doknr
        wa-doktl wa-dokvr.
      EXIT.
    ENDIF.

    wa-status = '40'.
    wa-zclupdname = sy-uname.
    wa-zclupddate = sy-datum.
    wa-zclupdtime = sy-uzeit.
    wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

*   Datum der Retour
    wa-recdate = sy-datum.
    wa-recuser = sy-uname.

    MODIFY (tabname) FROM wa.
    IF sy-subrc NE 0.
      MESSAGE i002(zck_dialog)
        WITH tabname '' '' ''.
    ELSE.
    ENDIF.
* modify internal table
    MODIFY it_det FROM wa INDEX index.

*   Aktion für gesamten Job
    IF f_whole_job = '1'.
      UPDATE /cideon/pl_log
        SET status = '40'
        "Datum der Retour
        recdate = sy-datum
        recuser = sy-uname

      zclupdname = sy-uname
      zclupddate = sy-datum
      zclupdtime = sy-uzeit
      zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'
      WHERE id_plotjob = wa-id_plotjob
      .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.


    PERFORM show_new_data.
  ELSE.
    LOOP AT it_det INTO wa.
*     wa Sichern mit Status "confirmed"
      IF wa-status = '00'.
      ELSE.
        MESSAGE w003(zck_dialog)
          WITH wa-dokar wa-doknr
          wa-doktl wa-dokvr.
        EXIT.
      ENDIF.

      wa-status = '40'.
      wa-zclupdname = sy-uname.
      wa-zclupddate = sy-datum.
      wa-zclupdtime = sy-uzeit.
      wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

*     Datum der Retour
      wa-recdate = sy-datum.
      wa-recuser = sy-uname.

      MODIFY (tabname) FROM wa.
      IF sy-subrc NE 0.
        MESSAGE i002(zck_dialog)
          WITH tabname '' '' ''.
      ELSE.
      ENDIF.
*     modify internal table
      MODIFY it_det FROM wa INDEX index.

*   Aktion für gesamten Job
      IF f_whole_job = '1'.
        UPDATE /cideon/pl_log
          SET status = '40'
          "Datum der Retour
          recdate = sy-datum
          recuser = sy-uname

          zclupdname = sy-uname
          zclupddate = sy-datum
          zclupdtime = sy-uzeit
          zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'
          WHERE id_plotjob = wa-id_plotjob
          .
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.

    ENDLOOP.
    IF f_whole_job = '1'.
      PERFORM show_new_data.
      EXIT.
    ELSE.
    ENDIF.
    IF sy-subrc <> 0.
      PERFORM show_new_data.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " received_back_today
*&---------------------------------------------------------------------*
*&      Form  received_back_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM received_back_date.
* Ausgabe an einem bestimmten Tag zurückerhalten

* Datum erfragen
  DATA: wa_help_info TYPE help_info.
  DATA: selection.
  DATA: select_value TYPE help_info-fldvalue.

  DATA: dynpselect TYPE TABLE OF dselc.
  DATA: dynpvaluetab TYPE TABLE OF dval.

  CLEAR wa_help_info.
  CLEAR selection.
  CLEAR select_value.

  wa_help_info-call = 'V'.
  wa_help_info-object = 'F'.
  wa_help_info-dynpro = '1000'.
  wa_help_info-tabname = '/CIDEON/PL_LOG'.
  wa_help_info-fieldname = 'RECDATE'.
  wa_help_info-fieldtype = 'DATE'.

*"     VALUE(SELECTION)
*"     VALUE(SELECT_VALUE) LIKE  HELP_INFO-FLDVALUE
*"     VALUE(RSMDY_RET) LIKE  RSMDY STRUCTURE  RSMDY
*"  TABLES
*"      DYNPSELECT STRUCTURE  DSELC
*"      DYNPVALUETAB STRUCTURE  DVAL

  CLEAR dynpselect.
  CLEAR dynpvaluetab.


  CALL FUNCTION 'HELP_START'
    EXPORTING
      help_infos         = wa_help_info
    IMPORTING
      selection          = selection
      select_value       = select_value
*     RSMDY_RET          =
    TABLES
      dynpselect         = dynpselect
      dynpvaluetab       = dynpvaluetab
            .
  IF selection = 'X'.
  ELSE.
    EXIT.
  ENDIF.

* Datum der Retour
  DATA: recdate TYPE sy-datum.
  CLEAR recdate.
  CALL FUNCTION 'CONVERT_DATE_TO_INTERN_FORMAT'
    EXPORTING
      datum         = select_value
      dtype         = 'DATS'
    IMPORTING
*     ERROR         =
      idate         = recdate
*     MESSG         =
*     MSGLN         =
            .

*  wa-recdate = select_value.

  IF it_det IS INITIAL.
*   wa Sichern mit Status "confirmed"
    IF wa-status = '00'.
    ELSE.
      MESSAGE w003(zck_dialog)
        WITH wa-dokar wa-doknr
        wa-doktl wa-dokvr.
      EXIT.
    ENDIF.

    wa-status = '40'.
    wa-zclupdname = sy-uname.
    wa-zclupddate = sy-datum.
    wa-zclupdtime = sy-uzeit.
    wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

    wa-recdate = recdate.
    wa-recuser = sy-uname.

    MODIFY (tabname) FROM wa.
    IF sy-subrc NE 0.
      MESSAGE i002(zck_dialog)
        WITH tabname '' '' ''.
    ELSE.
    ENDIF.
* modify internal table
    MODIFY it_det FROM wa INDEX index.

*   Aktion für gesamten Job
    IF f_whole_job = '1'.
      UPDATE /cideon/pl_log
        SET status = '40'
        "Datum der Retour
        recdate = recdate
        recuser = sy-uname

      zclupdname = sy-uname
      zclupddate = sy-datum
      zclupdtime = sy-uzeit
      zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'
      WHERE id_plotjob = wa-id_plotjob
      .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.


    PERFORM show_new_data.
  ELSE.
    LOOP AT it_det INTO wa.
*     wa Sichern mit Status "confirmed"
      IF wa-status = '00'.
      ELSE.
        MESSAGE w003(zck_dialog)
          WITH wa-dokar wa-doknr
          wa-doktl wa-dokvr.
        EXIT.
      ENDIF.

      wa-status = '40'.
      wa-zclupdname = sy-uname.
      wa-zclupddate = sy-datum.
      wa-zclupdtime = sy-uzeit.
      wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

      wa-recdate = recdate.
      wa-recuser = sy-uname.

      MODIFY (tabname) FROM wa.
      IF sy-subrc NE 0.
        MESSAGE i002(zck_dialog)
          WITH tabname '' '' ''.
      ELSE.
      ENDIF.
*     modify internal table
      MODIFY it_det FROM wa INDEX index.

*   Aktion für gesamten Job
      IF f_whole_job = '1'.
        UPDATE /cideon/pl_log
          SET status = '40'
          "Datum der Retour
          recdate = recdate
          recuser = sy-uname

        zclupdname = sy-uname
        zclupddate = sy-datum
        zclupdtime = sy-uzeit
        zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'
        WHERE id_plotjob = wa-id_plotjob
        .
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.


    ENDLOOP.
    IF f_whole_job = '1'.
      PERFORM show_new_data.
      EXIT.
    ELSE.
    ENDIF.
    IF sy-subrc <> 0.
      PERFORM show_new_data.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " received_back_date
*&---------------------------------------------------------------------*
*&      Form  due_today
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_today.
* Ausgabe heute fällig
  IF it_det IS INITIAL.
**   wa Sichern mit Status "confirmed"
*    IF wa-status = '00'.
*    ELSE.
*      MESSAGE w003(zck_dialog)
*        WITH wa-dokar wa-doknr
*        wa-doktl wa-dokvr.
*      EXIT.
*    ENDIF.

*    wa-status = '40'.
    wa-zclupdname = sy-uname.
    wa-zclupddate = sy-datum.
    wa-zclupdtime = sy-uzeit.
    wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

*   Datum der Fälligkeit
    wa-duedate = sy-datum.

    MODIFY (tabname) FROM wa.
    IF sy-subrc NE 0.
      MESSAGE i002(zck_dialog)
        WITH tabname '' '' ''.
    ELSE.
    ENDIF.
* modify internal table
    MODIFY it_det FROM wa INDEX index.

    PERFORM show_new_data.
  ELSE.
    LOOP AT it_det INTO wa.
*     wa Sichern mit Status "confirmed"
*      IF wa-status = '00'.
*      ELSE.
*        MESSAGE w003(zck_dialog)
*          WITH wa-dokar wa-doknr
*          wa-doktl wa-dokvr.
*        EXIT.
*      ENDIF.

*      wa-status = '40'.
      wa-zclupdname = sy-uname.
      wa-zclupddate = sy-datum.
      wa-zclupdtime = sy-uzeit.
      wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

*     Datum der Fälligkeit
      wa-duedate = sy-datum.

      MODIFY (tabname) FROM wa.
      IF sy-subrc NE 0.
        MESSAGE i002(zck_dialog)
          WITH tabname '' '' ''.
      ELSE.
      ENDIF.
*     modify internal table
      MODIFY it_det FROM wa INDEX index.

    ENDLOOP.
    IF sy-subrc <> 0.
      PERFORM show_new_data.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " due_today
*&---------------------------------------------------------------------*
*&      Form  due_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM due_date.
* Ausgabe fällig zu einem bestimmten Datum

* Datum erfragen
  DATA: wa_help_info TYPE help_info.
  DATA: selection.
  DATA: select_value TYPE help_info-fldvalue.

  DATA: dynpselect TYPE TABLE OF dselc.
  DATA: dynpvaluetab TYPE TABLE OF dval.

  CLEAR wa_help_info.
  CLEAR selection.
  CLEAR select_value.

  wa_help_info-call = 'V'.
  wa_help_info-object = 'F'.
  wa_help_info-dynpro = '1000'.
  wa_help_info-tabname = '/CIDEON/PL_LOG'.
  wa_help_info-fieldname = 'RECDATE'.
  wa_help_info-fieldtype = 'DATE'.

*"     VALUE(SELECTION)
*"     VALUE(SELECT_VALUE) LIKE  HELP_INFO-FLDVALUE
*"     VALUE(RSMDY_RET) LIKE  RSMDY STRUCTURE  RSMDY
*"  TABLES
*"      DYNPSELECT STRUCTURE  DSELC
*"      DYNPVALUETAB STRUCTURE  DVAL

  CLEAR dynpselect.
  CLEAR dynpvaluetab.


  CALL FUNCTION 'HELP_START'
    EXPORTING
      help_infos         = wa_help_info
    IMPORTING
      selection          = selection
      select_value       = select_value
*     RSMDY_RET          =
    TABLES
      dynpselect         = dynpselect
      dynpvaluetab       = dynpvaluetab
            .
  IF selection = 'X'.
  ELSE.
    EXIT.
  ENDIF.

* Datum der Fälligkeit
  DATA: duedate TYPE sy-datum.
  CLEAR duedate.
  CALL FUNCTION 'CONVERT_DATE_TO_INTERN_FORMAT'
    EXPORTING
      datum         = select_value
      dtype         = 'DATS'
    IMPORTING
*     ERROR         =
      idate         = duedate
*     MESSG         =
*     MSGLN         =
            .

*  wa-recdate = select_value.

  IF it_det IS INITIAL.
*   wa Sichern mit Status "confirmed"
*    IF wa-status = '00'.
*    ELSE.
*      MESSAGE w003(zck_dialog)
*        WITH wa-dokar wa-doknr
*        wa-doktl wa-dokvr.
*      EXIT.
*    ENDIF.

*    wa-status = '40'.
    wa-zclupdname = sy-uname.
    wa-zclupddate = sy-datum.
    wa-zclupdtime = sy-uzeit.
    wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

    wa-duedate = duedate.

    MODIFY (tabname) FROM wa.
    IF sy-subrc NE 0.
      MESSAGE i002(zck_dialog)
        WITH tabname '' '' ''.
    ELSE.
    ENDIF.
* modify internal table
    MODIFY it_det FROM wa INDEX index.

    PERFORM show_new_data.
  ELSE.
    LOOP AT it_det INTO wa.
*     wa Sichern mit Status "confirmed"
*      IF wa-status = '00'.
*      ELSE.
*        MESSAGE w003(zck_dialog)
*          WITH wa-dokar wa-doknr
*          wa-doktl wa-dokvr.
*        EXIT.
*      ENDIF.

*      wa-status = '40'.
      wa-zclupdname = sy-uname.
      wa-zclupddate = sy-datum.
      wa-zclupdtime = sy-uzeit.
      wa-zclupdprog = '/CIDEON/MNT_CIDEON_PL_LOG_FM'.

      wa-duedate = duedate.

      MODIFY (tabname) FROM wa.
      IF sy-subrc NE 0.
        MESSAGE i002(zck_dialog)
          WITH tabname '' '' ''.
      ELSE.
      ENDIF.
*     modify internal table
      MODIFY it_det FROM wa INDEX index.

    ENDLOOP.
    IF sy-subrc <> 0.
      PERFORM show_new_data.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " due_date
*&---------------------------------------------------------------------*
*&      Form  set_field_catalog_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_field_catalog_cust.
* Feldkatalog für Kunden setzen

* LED für normalen Status
  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'LED_STATUS'.
  wa_field_cat-icon  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

* LED für Visualisierung DUE / REC Date
  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'LED_DUE_REC'.
  wa_field_cat-icon  = 'X'.
  APPEND wa_field_cat TO it_field_cat.




ENDFORM.                    " set_field_catalog_cust
