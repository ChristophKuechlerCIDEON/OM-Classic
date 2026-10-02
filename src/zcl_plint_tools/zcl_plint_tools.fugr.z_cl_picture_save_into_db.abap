FUNCTION z_cl_picture_save_into_db.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(FILE) LIKE  RLGRAP-FILENAME DEFAULT 'C:\TEMP'
*"     VALUE(ID) TYPE  C OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
  TYPES: pict_lines(256) TYPE c.
  DATA: pict_tab TYPE TABLE OF pict_lines.

  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'WS_UPLOAD'.

  CALL FUNCTION lc_fname

"CALL FUNCTION 'WS_UPLOAD'
   EXPORTING
        filename                = file
        filetype                = 'BIN'
   TABLES
        data_tab                = pict_tab
   EXCEPTIONS
        conversion_error        = 1
        file_open_error         = 2
        file_read_error         = 3
        invalid_type            = 4
        no_batch                = 5
        unknown_error           = 6
        invalid_table_width     = 7
        gui_refuse_filetransfer = 8
        customer_error          = 9
        OTHERS                  = 10.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  EXPORT pict_tab = pict_tab TO DATABASE abtree(pi) ID id.



ENDFUNCTION.
