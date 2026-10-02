*----------------------------------------------------------------------*
*   INCLUDE Z_PP_CO_MAINTAINANCE_I01                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0999  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0999 INPUT.

  MOVE sy-ucomm TO ok_code.
  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      CALL TRANSACTION 'SESSION_MANAGER'.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'DETAILS'.
      PERFORM get_selected_row1.
      PERFORM get_details_material_pp_order.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0999  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0993  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0993 INPUT.

  CLEAR count_lines.

  MOVE sy-ucomm TO ok_code.
  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'DISP_MODI'.
      PERFORM get_selected_row4.
      PERFORM select_and_display_or_mofify.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0993  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0992  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0992 INPUT.

  MOVE sy-ucomm TO ok_code.
  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SLISTE'.
      PERFORM selection_of_display_or_modify.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0992  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0991  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0991 INPUT.

  MOVE sy-ucomm TO ok_code.
  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0991  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0899  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0899 INPUT.

  MOVE sy-ucomm TO ok_code.

  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'F4_SELECT'.
      PERFORM select_data_from_screen_899.
      CALL SCREEN '0993'.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0899  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0888  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0888 INPUT.

  MOVE sy-ucomm TO ok_code.

  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SELECT_DOC'.
      PERFORM get_selected_row5.
      PERFORM user_doc_bom_decision.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0888  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0887  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0887 INPUT.

  MOVE sy-ucomm TO ok_code.

  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'NEXT_STEP'.
      PERFORM get_selected_row6.
      PERFORM collect_draw_deatils.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0887  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_0995  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0995 INPUT.
  CLEAR ok_code.

  MOVE sy-ucomm TO ok_code.
  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CLOSE'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'TEC_PORDER'.
      PERFORM selection_tech_platz_data.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " user_command_0995  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0996  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0996 INPUT.

  CLEAR ok_code.
  MOVE sy-ucomm TO ok_code.
  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SEND'.
      PERFORM select_tpst_rows.
      PERFORM display_tech_stueckliste.
    WHEN OTHERS.

      CLEAR ok_code.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0996  INPUT
