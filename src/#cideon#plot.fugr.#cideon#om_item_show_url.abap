FUNCTION /cideon/om_item_show_url.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_URL) TYPE  /CIDEON/S_ENHC_TRANSFER_02-URL
*"----------------------------------------------------------------------


  DATA lc_html_control TYPE cntl_handle. " HTML control Referenz

  IF  lc_html_control  IS INITIAL.
    CALL FUNCTION 'CONTROL_INIT'
         EXCEPTIONS
              error_message = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.

    CALL FUNCTION 'HTMLCNTL_CREATE'
         EXPORTING
              owner_repid   = sy-repid
              link_repid    = sy-repid
              dynnr         = sy-dynnr
              container     = 'HTML_CONTAINER'
         CHANGING
              handle        = lc_html_control
         EXCEPTIONS
              error_message = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
    CALL FUNCTION 'HTMLCNTL_INIT'
         EXPORTING
              h_control     = lc_html_control
         EXCEPTIONS
              error_message = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'HTMLCNTL_SHOW_URL_IN_BROWSER'
       EXPORTING
            h_control               = lc_html_control
            url                     = i_url
       EXCEPTIONS
            cntl_system_error       = 1
            cntl_error              = 2
            control_not_initialized = 3
            call_method_error       = 4
            OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.


ENDFUNCTION.
