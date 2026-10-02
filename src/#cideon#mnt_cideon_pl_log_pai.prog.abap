*----------------------------------------------------------------------*
*   INCLUDE ZCK_MAINT_ZCL_GRP_CLASS_KL_PAI                             *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: c_start_occ(1) TYPE c VALUE 'X',
        c_no_start_occ(1) TYPE c VALUE ' '.

  DATA: it_selected_rows TYPE lvc_t_row,
        wa_selected_rows LIKE LINE OF it_selected_rows.

* someone changed the data
  IF NOT sy-datar IS INITIAL.
    wa_save_neccessary = 'X'.
  ENDIF.

* Selektion merken
*  PERFORM read_marked_lines.

  CASE ok_code.
    WHEN 'INFO_SHOW'.
      PERFORM show_info.


*   Datei erneut ausgeben
    WHEN 'RESTART_FILE'.
      PERFORM read_marked_lines.
      PERFORM reprint_job USING c_no_start_occ.

* Job erneut ausgeben
    WHEN 'RESTART_JOB'.
      PERFORM read_marked_lines_job.
      PERFORM reprint_job USING c_no_start_occ.

* Datei erneut ausgeben mit Start OCC
    WHEN 'RESTART_FILE_OCC'.
      PERFORM read_marked_lines.
      PERFORM reprint_job USING c_start_occ.

* Job erneut ausgeben mit STart OCC
    WHEN 'RESTART_JOB_OCC'.
      PERFORM read_marked_lines_job.
      PERFORM reprint_job USING c_start_occ.


*   Mahnung erstellen
    WHEN 'DUN1'.
      PERFORM read_marked_lines.
      "gesamten Job mahnen
      PERFORM make_dunning.
      PERFORM show_new_data.

*   Ausgabe am heutigen Tag zurückerhalten
    WHEN 'REC_TODAY'.
      PERFORM read_marked_lines.
      "f_whole_job = '1'.
      "PERFORM ask_for_whole_job.
      PERFORM received_back_today.
      PERFORM show_new_data.
*   Ausagabe zurückerhaltem / Eingabe eines Datums
    WHEN 'REC_DATE'.
      PERFORM read_marked_lines.
      "PERFORM ask_for_whole_job.
      PERFORM received_back_date.
      PERFORM show_new_data.

*   Ausgabe am heutigen Tag fällig
    WHEN 'DUE_TODAY'.
      PERFORM read_marked_lines.
      PERFORM due_today.
      PERFORM show_new_data.
*   Ausagabe fällig / Eingabe eines Datums
    WHEN 'DUE_DATE'.
      PERFORM read_marked_lines.
      PERFORM due_date.
      PERFORM show_new_data.

    WHEN 'FAILURE'.
      PERFORM read_marked_lines.
      PERFORM confirm_marked_lines_failure.
      PERFORM show_new_data.
    WHEN 'CONFIRM'.
      PERFORM read_marked_lines.
      PERFORM confirm_marked_lines.
      PERFORM show_new_data.
    WHEN 'REFRESH'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        CLEAR /cideon/pl_log.
        wa_edit_mode = co_show_mode.
        PERFORM show_new_data.
      ENDIF.
    WHEN 'DIS_VIEW'.
      PERFORM read_marked_lines.
      PERFORM dis_view_marked_lines.
    WHEN 'TRAN'.
      PERFORM read_marked_lines.
      PERFORM popup_to_confirm_transaction.
      IF answer = 'J'.
        PERFORM transport_marked_lines.
      ELSE.
        "PERFORM delete_entry.
      ENDIF.
    WHEN 'BACK' OR 'CANC'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'EXIT'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'DEL'.
      IF   wa_edit_mode = co_edit_mode
        OR wa_edit_mode = co_insr_mode.
        CLEAR wa_save_neccessary.
        PERFORM delete_entry.
      ENDIF.
    WHEN 'SAVE'.
      PERFORM save_data.
    WHEN 'USER'.
      PERFORM show_updins_info.
    WHEN 'INSR'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        wa_edit_mode = co_insr_mode.
        PERFORM read_marked_lines.
        max_lines = 1.
      ENDIF.
    WHEN 'EDIT'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        PERFORM read_marked_lines.
        IF max_lines <> 0.
          wa_edit_mode = co_edit_mode.
        ENDIF.
      ENDIF.
    WHEN 'DETAIL' OR 'DBLCLICK'.
      "CKR 03.01.2008
      "Doppelklick selektiert ganzen Job

      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        wa_edit_mode = co_show_mode.
        IF ok_code = 'DETAIL'.
          PERFORM read_marked_lines.
        ELSE.
          PERFORM set_marked_line.
          "PERFORM set_marked_job.
          PERFORM read_marked_lines.
*          zcl_grp_class_kl = wa.
        ENDIF.
*       Änderungsnummer
        IF cursor_field = '/CIDEON/PL_LOG-AENNR'
          AND NOT cursor_value IS INITIAL.
          SET PARAMETER ID 'AEN' FIELD cursor_value.
          CALL TRANSACTION 'CC03' AND SKIP FIRST SCREEN.
        ELSE.
        ENDIF.
*       Kreditor
        IF cursor_field = '/CIDEON/PL_LOG-LIFNR'
          AND NOT cursor_value IS INITIAL.
          SET PARAMETER ID 'LIF' FIELD cursor_value.
          CALL TRANSACTION 'MK03'. "AND SKIP FIRST SCREEN.
        ELSE.
        ENDIF.
      ENDIF.
    WHEN 'START'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        READ TABLE it_det INTO /cideon/pl_log INDEX 1.
        index = 1.
      ENDIF.
    WHEN 'END'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        READ TABLE it_det INTO /cideon/pl_log INDEX max_lines.
        index = max_lines.
      ENDIF.
    WHEN 'PREV'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        IF index > 1.
          index = index - 1.
        ELSE.
          index = 1.
        ENDIF.
        READ TABLE it_det INTO /cideon/pl_log INDEX index.
      ENDIF.
    WHEN 'NEXT'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        IF index < max_lines.
          index = index + 1.
        ELSE.
          index = max_lines.
        ENDIF.
        READ TABLE it_det INTO /cideon/pl_log INDEX index.
      ENDIF.
    WHEN '0101' OR '0102' OR '0103' OR '0104' OR 'INFO'
      OR '0112'.
      dynp = ok_code.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  IF NOT ref_alv IS INITIAL.
    CALL METHOD ref_alv->free.
    CALL METHOD ref_container->free.
    FREE: ref_alv, ref_container.
  ENDIF.

  LEAVE TO SCREEN 0.
ENDMODULE.                             " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_content  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_content INPUT.

  CLEAR wa.
  wa = /cideon/pl_log.

ENDMODULE.                 " get_content  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor INPUT.
  CLEAR : cursor_field, cursor_value.
  GET CURSOR FIELD cursor_field VALUE cursor_value.
ENDMODULE.                 " get_cursor  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0112  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0112 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  LOOP AT SCREEN.
    IF screen-group1 = 'KEY'.
      IF wa_edit_mode = '2'.
        screen-input    = '1'.
*        screen-required = '1'.
      ELSE.
        screen-input = '0'.
      ENDIF.
    ELSEIF screen-group1 = 'DAT'.
      IF wa_edit_mode = '0'.
        screen-input = '0'.
      ELSE.
        screen-input = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " STATUS_0112  OUTPUT
