FUNCTION z_filename_exit_reprocl_scan.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------

  DATA: ini_file LIKE rlgrap-filename,
        dummy.

  DATA: BEGIN OF reproclini OCCURS 50,
          line(200),
        END OF reproclini.

  DATA : file_exist TYPE c.

  CALL FUNCTION 'FILE_GET_NAME'
       EXPORTING
*         CLIENT                  = SY-MANDT
            logical_filename        = 'ZZ_REPROCL_INI'
         operating_system        = sy-opsys
*         PARAMETER_1             = ' '
*         PARAMETER_2             = ' '
*         PARAMETER_3             = ' '
            use_presentation_server = 'X'
*         WITH_FILE_EXTENSION     = ' '
*         USE_BUFFER              = ' '
       IMPORTING
*         EMERGENCY_FLAG          =
*         FILE_FORMAT             =
            file_name               = ini_file
       EXCEPTIONS
            file_not_found          = 1
            OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'WS_UPLOAD'.

  "CALL FUNCTION 'WS_UPLOAD'
  CALL FUNCTION lc_fname
       EXPORTING
*         CODEPAGE                = ' '
            filename                = ini_file
            filetype                = 'ASC'
*         HEADLEN                 = ' '
*         LINE_EXIT               = ' '
*         TRUNCLEN                = ' '
*         USER_FORM               = ' '
*         USER_PROG               = ' '
*         DAT_D_FORMAT            = ' '
*    IMPORTING
*         FILELENGTH              =
       TABLES
            data_tab                = reproclini
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
            OTHERS                  = 10
            .

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF sy-subrc = 0.
    SEARCH reproclini FOR '[ClientScan]'.
    ADD 1 TO sy-tabix.
    SEARCH reproclini FOR 'Pfad=' STARTING AT sy-tabix.
    IF sy-subrc = 0.
      READ TABLE reproclini INDEX sy-tabix.
      SPLIT reproclini-line AT '=' INTO dummy output.
      REFRESH reproclini.
    ELSE.
      CLEAR output.
    ENDIF.
  ENDIF.

ENDFUNCTION.
