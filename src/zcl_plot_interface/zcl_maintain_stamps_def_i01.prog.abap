*----------------------------------------------------------------------*
*   INCLUDE ZCL_MAINTAIN_PLINT_CFG_00I01                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'TAB1'.
      tabstripcontrol_001-activetab = 'TAB1'.
    WHEN 'TAB2'.
      tabstripcontrol_001-activetab = 'TAB2'.
    WHEN 'DBLCLICK_ALV'.
      PERFORM read_akt_line_alv.
    WHEN 'SAVE'.
      PERFORM check_for_modifications.
      PERFORM save_to_db.
      PERFORM get_data.
      PERFORM refresh_alv.
    WHEN 'CREATE'.
      PERFORM create_new_table_row.
    WHEN 'MODIFY'.
      PERFORM get_selected_rows_from_alv.
      PERFORM modify_table_row.
    WHEN 'REFRESH'.
      PERFORM refresh_alv.
    WHEN 'DELETE'.
      PERFORM get_selected_rows_from_alv.
      PERFORM delete_row_from_table.
      PERFORM get_data.
      PERFORM refresh_alv.
    WHEN 'COPY'.
      PERFORM get_selected_rows_from_alv.
      PERFORM copy_the_row_as_diffrent_row.
    WHEN OTHERS.
  ENDCASE.

  PERFORM save_wa_alv.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
