*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOTINFOI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE ok_code.
    WHEN 'OK'.
*     Selectierte Daten holen
*      PERFORM editor_get_data.

*      CALL FUNCTION 'POPUP_TO_CONFIRM'
*        EXPORTING
*          titlebar                    = text-002
**     DIAGNOSE_OBJECT             = ' '
*          text_question               = text-001
**     TEXT_BUTTON_1               = 'Ja'(001)
**     ICON_BUTTON_1               = ' '
**     TEXT_BUTTON_2               = 'Nein'(002)
**     ICON_BUTTON_2               = ' '
**     DEFAULT_BUTTON              = '1'
*          display_cancel_button       = ''
**     USERDEFINED_F1_HELP         = ' '
**     START_COLUMN                = 25
**     START_ROW                   = 6
**     POPUP_TYPE                  =
**   IMPORTING
**     ANSWER                      =
**   TABLES
**     PARAMETER                   =
**   EXCEPTIONS
**     TEXT_NOT_FOUND              = 1
**     OTHERS                      = 2
*                .
*      IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.


      CLEAR ok_code.
*      PERFORM free_alv.
      g_answer = 'X'.

      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR ok_code.
*      PERFORM free_alv.
      g_answer = 'A'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
