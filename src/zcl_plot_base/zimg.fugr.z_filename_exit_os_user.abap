FUNCTION Z_FILENAME_EXIT_OS_USER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       EXPORTING
*"             VALUE(OUTPUT)
*"----------------------------------------------------------------------

  data: return(20),
        os(20),
        env_user(10).

  CALL FUNCTION 'WS_QUERY'
       EXPORTING
*           ENVIRONMENT    =
*           FILENAME       =
            QUERY          = 'OS'
*           WINID          =
       IMPORTING
            RETURN         = os
       EXCEPTIONS
            INV_QUERY      = 1
            NO_BATCH       = 2
            FRONTEND_ERROR = 3
            OTHERS         = 4
            .
  IF SY-SUBRC <> 0.
  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  case os.
    when 'NT' or 'DOS'.       "ggf. ergänzen für MAC, DEC, ...
      env_user = 'USERNAME'.
    when others.
      env_user = 'USER'.
  endcase.

  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            ENVIRONMENT    = env_user
*         FILENAME       =
            QUERY          = 'EN'
*         WINID          =
       IMPORTING
            RETURN         = return
       EXCEPTIONS
            INV_QUERY      = 1
            NO_BATCH       = 2
            FRONTEND_ERROR = 3
            OTHERS         = 4
            .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    OUTPUT = SY-UNAME.
  else.
    OUTPUT = return.
  ENDIF.

ENDFUNCTION.
