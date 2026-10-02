*----------------------------------------------------------------------*
***INCLUDE LZCL_PLINT_STEMPELI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      SET PARAMETER ID 'ZCL_STAMP_LANGUAGE' FIELD wa_sprache.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.

      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
