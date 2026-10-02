*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LAUDIT_TRAILI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'OK'.
*     Aufruf des LOGs vorgefüllt
      SUBMIT /cideon/mnt_cideon_pl_log
        WITH sinsname-low EQ sy-uname
        WITH s_status-low EQ c_plot_log_entry_created
        AND RETURN.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      f_exit = 'X'.
      LEAVE TO SCREEN 0.
    WHEN 'DONT_ASK'.
      f_exit = 'X'.
      f_dont_ask = 'X'.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
