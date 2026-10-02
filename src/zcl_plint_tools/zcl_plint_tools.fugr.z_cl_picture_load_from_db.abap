FUNCTION z_cl_picture_load_from_db.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(ID) TYPE  C DEFAULT 'PLOT_001'
*"  EXPORTING
*"     REFERENCE(O_URL) TYPE  C
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------


  IMPORT pict_tab = l_pict_tab
    FROM DATABASE abtree(pi)
      ID id.

  CALL FUNCTION 'DP_CREATE_URL'
       EXPORTING
            type                 = 'IMAGE'
            subtype              = 'GIF'
       TABLES
            data                 = l_pict_tab
       CHANGING
            url                  = l_url
       EXCEPTIONS
            dp_invalid_parameter = 1
            dp_error_put_table   = 2
            dp_error_general     = 3
            OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  o_url = l_url.


  call screen 400 starting at 10 10 ending at 78 24.

ENDFUNCTION.
