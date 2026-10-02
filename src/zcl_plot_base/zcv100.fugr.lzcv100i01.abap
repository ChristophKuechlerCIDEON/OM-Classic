*----------------------------------------------------------------------*
***INCLUDE lzcv100i01 .
*----------------------------------------------------------------------*

* INPUT MODULE FOR TABLECONTROL 'Z602': MODIFY TABLE
MODULE z602_modify INPUT.
  MOVE-CORRESPONDING tdwp TO g_z602_wa.
  MODIFY g_z602_itab
    FROM g_z602_wa
    INDEX z602-current_line.
ENDMODULE.

* INPUT MODULE FOR TABLECONTROL 'Z602': MARK TABLE
MODULE z602_mark INPUT.
  MODIFY g_z602_itab
    FROM g_z602_wa
    INDEX z602-current_line
    TRANSPORTING flag.

  MOVE g_z602_wa TO it_tdwp.
  APPEND it_tdwp.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0602  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0602 INPUT.

  CASE sy-ucomm.
    WHEN 'CAPTURE'.
      IF it_tdwp IS INITIAL.
        MESSAGE ID 'ZCVN'  TYPE 'W' NUMBER  '001'.
*        MESSAGE ID 'ZCVN'  TYPE 'A' NUMBER  '001'.
        LEAVE TO SCREEN 0602.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN '%EX'.
      LEAVE PROGRAM.
    WHEN 'CLOSE'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0602  INPUT

*---------------------------------------------------------------------*
*       MODULE user_command_0902 INPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*CLEAR ok_code.

*---------------------------------------------------------------------*
*       MODULE user_command_0902 INPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE user_command_0902 INPUT.

  REFRESH itab_index_rows_searchlist_z  .
  CALL METHOD grid_suchen_z->get_selected_rows
    IMPORTING
      et_index_rows = itab_index_rows_searchlist_z.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0902  INPUT

* INPUT MODULE FOR TABLECONTROL 'Z100': MODIFY TABLE
MODULE z100_modify INPUT.
  MOVE-CORRESPONDING tdwp TO g_z100_wa.
  MODIFY g_z100_itab
    FROM g_z100_wa
    INDEX z100-current_line.
ENDMODULE.

* INPUT MODULE FOR TABLECONTROL 'Z100': MARK TABLE
MODULE z100_mark INPUT.
*  g_z100_wa-flag = 'X'.
  MODIFY g_z100_itab
    FROM g_z100_wa
    INDEX z100-current_line
    TRANSPORTING flag.


  MOVE g_z100_wa TO it_tdwp.
  APPEND it_tdwp.

ENDMODULE.

* INPUT MODULE FOR TABLECONTROL 'Z100': PROCESS USER COMMAND
MODULE z100_user_command INPUT.
  CLEAR g_flag_exit.
  PERFORM user_ok_tc USING    'Z100'
                              'G_Z100_ITAB'
                              'FLAG'
                     CHANGING ok_code.


  CASE ok_code.
    WHEN 'CAPTURE'.
      REFRESH it_tdwp.
      LOOP AT g_z100_itab INTO g_z100_wa.
        IF g_z100_wa-flag = 'X'.
          MOVE g_z100_wa TO it_tdwp.
          APPEND it_tdwp.
        ELSE.
        ENDIF.
      ENDLOOP.
      IF it_tdwp[] IS INITIAL.
        MESSAGE ID 'ZCVN'  TYPE 'W' NUMBER  '001'.
        LEAVE TO SCREEN 0100.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN 'BACK'.
      REFRESH it_tdwp.
      g_flag_exit = 'X'.
      LEAVE TO SCREEN 0.
    WHEN 'OTHERS'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR g_z100_wa-flag.
  CLEAR ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

*  CASE ok_code.
*    WHEN 'CAPTURE'.
*      IF g_z100_itab IS INITIAL.
*        MESSAGE ID 'ZCVN'  TYPE 'W' NUMBER  '001'.
*        LEAVE TO SCREEN 0100.
*      ELSE.
*        LEAVE TO SCREEN 0.
*      ENDIF.
*
*    WHEN 'OTHERS'.
*      LEAVE PROGRAM.
*  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
