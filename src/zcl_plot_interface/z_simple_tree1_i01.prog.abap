*----------------------------------------------------------------------*
*   INCLUDE Z_SIMPLE_TREE1_I01                                         *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CALL METHOD cl_gui_cfw=>dispatch
    IMPORTING
      return_code = return_code
      .

  IF return_code <> cl_gui_cfw=>rc_noevent.
    CLEAR g_ok_code.
    EXIT.
  ENDIF.


  CLEAR g_ok_code.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
