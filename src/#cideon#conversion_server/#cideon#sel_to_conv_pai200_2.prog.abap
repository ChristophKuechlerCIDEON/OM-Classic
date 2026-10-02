*----------------------------------------------------------------------*
***INCLUDE /CIDEON/SEL_TO_MIGRATE_PAI200 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'SP_SUCHE'.
*     Selektion übernehmen
      PERFORM draw_abfragen.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
