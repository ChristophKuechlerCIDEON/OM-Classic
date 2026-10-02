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
    WHEN 'CREATE'.
      CALL TRANSACTION 'CO01'.
    WHEN 'PP_ORDER_C'.
      PERFORM get_selected_row1.
      IF count_lines EQ 1.
        SET PARAMETER ID 'ANR' FIELD wa_aufk-aufnr.
        CALL TRANSACTION 'CO02' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE i080(zcvn).
        LEAVE TO SCREEN 999.
      ENDIF.
    WHEN 'DETAILS'.
      PERFORM get_selected_row1.
      PERFORM get_details_material_pp_order.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0999  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0996  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0996 INPUT.

  MOVE sy-ucomm TO ok_code.
  CLEAR sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'PROCESS'.
      PERFORM create_new_material_immediate.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0996  INPUT

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
    WHEN 'CHA_MT_BOM'.
      PERFORM get_selected_row4.
      IF count_lines EQ 1.
        PERFORM material_bom_change.
      ELSE.
        MESSAGE i080(zcvn).
        LEAVE TO SCREEN 993.
      ENDIF.

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
    WHEN 'CREATE_SL'.
      PERFORM creation_of_stueckliste.
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
    WHEN 'MODIFY_BOM'.
      PERFORM get_selected_row5.
      SET PARAMETER ID: 'CV1' FIELD wa_draw-doknr,
                        'CV2' FIELD wa_draw-dokar,
                        'CV3' FIELD wa_draw-dokvr,
                        'CV4' FIELD wa_draw-doktl.

      CALL TRANSACTION 'CV13' AND SKIP FIRST SCREEN.

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
*&      Module  USER_COMMAND_0886  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0886 INPUT.

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
    WHEN 'STLAN_SEL'.
      PERFORM get_selected_and_pass_row7.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0886  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0884  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0884 INPUT.

  CLEAR ok_code.

  MOVE sy-ucomm TO ok_code.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'PICK_AUFK'.
      PERFORM select_rows_from_884.
      CALL SCREEN '0885'.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0884  INPUT
