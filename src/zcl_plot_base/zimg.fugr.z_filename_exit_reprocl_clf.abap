FUNCTION Z_FILENAME_EXIT_REPROCL_CLF.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       EXPORTING
*"             VALUE(OUTPUT)
*"----------------------------------------------------------------------

  data: ini_path like rlgrap-filename.

  data: begin of reproclini occurs 50,
          line(200),
        end of reproclini.

  CALL FUNCTION 'FILE_GET_NAME'
       EXPORTING
*         CLIENT                  = SY-MANDT
            LOGICAL_FILENAME        = 'ZZ_REPROCL_INI_PATH'
*         OPERATING_SYSTEM        = SY-OPSYS
*         PARAMETER_1             = ' '
*         PARAMETER_2             = ' '
*         PARAMETER_3             = ' '
            USE_PRESENTATION_SERVER = 'X'
*         WITH_FILE_EXTENSION     = ' '
*         USE_BUFFER              = ' '
       IMPORTING
*         EMERGENCY_FLAG          =
*         FILE_FORMAT             =
            FILE_NAME               = ini_path
       EXCEPTIONS
            FILE_NOT_FOUND          = 1
            OTHERS                  = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  output = ini_path.

ENDFUNCTION.
