*----------------------------------------------------------------------*
*   INCLUDE ZCK_CFG_00_ALV_EDIT_PAI                                    *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: it_selected_rows TYPE lvc_t_row,
        wa_selected_rows LIKE LINE OF it_selected_rows.

* someone changed the data
  IF NOT sy-datar IS INITIAL.
    wa_save_neccessary = 'X'.
  ENDIF.

  CASE ok_code.
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
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        wa_edit_mode = co_show_mode.
        IF ok_code = 'DETAIL'.
          PERFORM read_marked_lines.
        ELSE.
          PERFORM set_marked_line.
          PERFORM read_marked_lines.
*          zcl_plint_cfg_00 = wa.
        ENDIF.
*       Report starten
        IF cursor_field = 'ZCL_STAMP_USER-FM_NAME'
          AND NOT cursor_value IS INITIAL.
          CALL FUNCTION 'RS_TOOL_ACCESS'
            EXPORTING
              operation                 = 'SHOW'
              object_name               = cursor_value
              object_type               = 'FUNC'
*             ENCLOSING_OBJECT          =
*             POSITION                  = ' '
*             DEVCLASS                  =
*             INCLUDE                   =
*             VERSION                   = ' '
*             MONITOR_ACTIVATION        = 'X'
*             WB_MANAGER                =
*             IN_NEW_WINDOW             =
*             WITH_OBJECTLIST           = ' '
*           IMPORTING
*             NEW_NAME                  =
*             WB_TODO_REQUEST           =
*           TABLES
*             OBJLIST                   =
*           CHANGING
*             P_REQUEST                 = ' '
            EXCEPTIONS
              not_executed              = 1
              invalid_object_type       = 2
              OTHERS                    = 3
                    .
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

        ELSE.
        ENDIF.

      ENDIF.
    WHEN 'START'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        READ TABLE it_det INTO zcl_stamp_user INDEX 1.
        index = 1.
      ENDIF.
    WHEN 'END'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        READ TABLE it_det INTO zcl_stamp_user INDEX max_lines.
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
        READ TABLE it_det INTO zcl_stamp_user INDEX index.
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
        READ TABLE it_det INTO zcl_stamp_user INDEX index.
      ENDIF.
    WHEN '0101' OR '0102' OR '0103' OR '0104' OR 'INFO'.
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
  wa = zcl_stamp_user.

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
