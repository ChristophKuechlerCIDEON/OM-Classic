FUNCTION Z_FILENAME_EXIT_REP_PATH_INI.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       EXPORTING
*"             VALUE(OUTPUT)
*"----------------------------------------------------------------------

  data: fileintern like filenameci-fileintern.

  import *tdwe from memory id 'ZZ_TDWE'.
  concatenate 'ZZ_REPROCL_INI_PATH_' *tdwe-typdt into fileintern.

  CALL FUNCTION 'FILE_GET_NAME'
       EXPORTING
*         CLIENT                  = SY-MANDT
            LOGICAL_FILENAME        = fileintern
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
            FILE_NAME               = output
       EXCEPTIONS
            FILE_NOT_FOUND          = 1
            OTHERS                  = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFUNCTION.
