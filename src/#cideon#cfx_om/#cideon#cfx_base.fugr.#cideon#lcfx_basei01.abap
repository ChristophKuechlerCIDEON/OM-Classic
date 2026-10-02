*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LCFX_BASEI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1400 INPUT.

  CASE ok_code.
    WHEN 'CANCEL1200'.
      LEAVE SCREEN.
    WHEN OTHERS.
      IF cfol_field01 IS INITIAL AND radio_1 = 'X'.
        MESSAGE i110(26).
        LEAVE TO SCREEN 1400.
      ENDIF.
*      PERFORM export_cfolders.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1400  INPUT
