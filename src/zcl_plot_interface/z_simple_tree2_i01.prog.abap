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

*  CASE g_ok_code.

      IF NOT ( g_docking_container IS INITIAL ).

        CALL METHOD g_docking_container->free
          EXCEPTIONS
            cntl_error        = 1
            cntl_system_error = 2
            OTHERS            = 3
                .

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CLEAR g_docking_container.
        CLEAR g_tree.

      ENDIF.

      LEAVE PROGRAM.
*  ENDCASE.
  CLEAR g_ok_code.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
