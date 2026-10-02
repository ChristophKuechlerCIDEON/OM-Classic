*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOTLISTI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_code = ok_code.
  CLEAR ok_code.

  CASE save_code.
    WHEN 'OK'.
      " Selektionen holen
      PERFORM get_selection.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      PERFORM de_select.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
