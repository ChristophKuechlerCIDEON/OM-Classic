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
      PERFORM popup_to_confirm_transation.
      IF answer = 'J'.
        PERFORM transport_marked_lines.
      ELSE.
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
      ENDIF.
    WHEN 'START'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        READ TABLE it_det INTO zcl_plint_config INDEX 1.
        index = 1.
      ENDIF.
    WHEN 'END'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        READ TABLE it_det INTO zcl_plint_config INDEX max_lines.
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
        READ TABLE it_det INTO zcl_plint_config INDEX index.
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
        READ TABLE it_det INTO zcl_plint_config INDEX index.
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
  wa = zcl_plint_config.

ENDMODULE.                 " get_content  INPUT
