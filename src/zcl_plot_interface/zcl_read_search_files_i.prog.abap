*----------------------------------------------------------------------*
***INCLUDE ZCL_UPDAE_INI_FILES_I .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'INI_EINLESEN'.
      username = wa_work_normal-bname.
      CALL FUNCTION 'Z_CL_READ_INI_PREPROZESSOR'
           EXPORTING
                i_uname    = username
                i_filename = filename
           EXCEPTIONS
                error      = 1
                OTHERS     = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN 'VOREINSTELLUNGEN'.
      username = wa_work_normal-bname.
      CALL FUNCTION 'Z_CL_UPD_VOREINSTELLUNGEN'
           EXPORTING
                i_uname = username
           EXCEPTIONS
                error   = 1
                OTHERS  = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN 'VERTEILER'.
      username = wa_work_normal-bname.
      CALL FUNCTION 'Z_CL_UPD_VERTEILER'
           EXPORTING
                i_uname = username
           EXCEPTIONS
                error   = 1
                OTHERS  = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN 'INI_STAMP_EINLESEN'.
      username = wa_work_normal-bname.
      CALL FUNCTION 'Z_CL_READ_INI_STAMPS'
           EXPORTING
                i_uname    = username
                i_filename = filename
           EXCEPTIONS
                error      = 1
                OTHERS     = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN 'STEMPEL'.
      username = wa_work_normal-bname.
      CALL FUNCTION 'Z_CL_UPD_STEMPEL_KLASSEN'
           EXPORTING
                i_uname = username
           EXCEPTIONS
                error   = 1
                OTHERS  = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
