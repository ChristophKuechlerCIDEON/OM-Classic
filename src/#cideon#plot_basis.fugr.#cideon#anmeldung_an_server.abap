FUNCTION /cideon/anmeldung_an_server.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_ANMELDESTRING_SERVER) TYPE  ZCL_PWERT
*"     VALUE(I_ANMELDESTRING_SERVER_VOHER) TYPE  ZCL_PWERT
*"     VALUE(I_ANMELDESTRING_SERVER_NACHHER) TYPE  ZCL_PWERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*           christoph.kuechler@cideon.com
*-----------------------------------------------------------------------
* Hinweise:
*   -  Anmeldung an einem SMB Share
*   -
*-----------------------------------------------------------------------
* Journal
* 03.07.2003
*
* 7.0.169.1  CKR
* 2014/08/04 Sulzer
  " EHP 7 - Ausbau FB DSVAS_DOC_WS_DOWNLOAD_50
  " FB /CIDEON/ANMELDUNG_AN_SERVER
  "
*-----------------------------------------------------------------------

*TYPES
  TYPES: BEGIN OF t_batch,
    line TYPE char600,
    END OF t_batch.
*ITAB
  DATA: itab_batch TYPE TABLE OF t_batch.
  DATA: itab_batch_vorher TYPE TABLE OF t_batch.
  DATA: itab_batch_nachher TYPE TABLE OF t_batch.
*WA
  DATA: wa_batch TYPE t_batch.
*NORMAL
  DATA: return TYPE i.
  DATA: filename TYPE filep.
  DATA: filename_batch TYPE filep.
  DATA: delete_filename TYPE rlgrap-filename.

  DATA: start_verzeichnis TYPE rlgrap-filename.
  DATA: up_verzeichnis TYPE rlgrap-filename.

* Beispiel des Aufrufs
* net use \\enas01\autoorg schulung /user:pcd-01\schulung

  CALL FUNCTION 'WS_ULDL_PATH'
    IMPORTING
      download_path = start_verzeichnis
      upload_path   = up_verzeichnis.


* BATCH-Datei zum Starten schreiben
  CLEAR wa_batch.
  CLEAR itab_batch.

  CLEAR itab_batch_vorher.
  CLEAR itab_batch_nachher.

  SPLIT i_anmeldestring_server_voher AT '/'
    INTO TABLE itab_batch_vorher .

  SPLIT i_anmeldestring_server_nachher AT '/'
    INTO TABLE itab_batch_nachher .

  LOOP AT itab_batch_vorher INTO wa_batch.
    APPEND wa_batch TO itab_batch.
  ENDLOOP.

  wa_batch-line = i_anmeldestring_server.
  APPEND wa_batch TO itab_batch.

  LOOP AT itab_batch_nachher INTO wa_batch.
    APPEND wa_batch TO itab_batch.
  ENDLOOP.

  CONCATENATE start_verzeichnis  'ANMELDUNG_SMB.bat'
    INTO filename_batch.

*  CALL FUNCTION 'DSVAS_DOC_WS_DOWNLOAD_50'
*   EXPORTING
**     BIN_FILESIZE                  = ' '
*      filename                      = filename_batch
*      filetype                      = 'ASC'
**     MODE                          = ' '
**   IMPORTING
**     FILELENGTH                    =
*   TABLES
*      data_tab                      = itab_batch
*   EXCEPTIONS
*     file_open_error               = 1
*     file_write_error              = 2
*     invalid_filesize              = 3
*     invalid_type                  = 4
*     no_batch                      = 5
*     unknown_error                 = 6
*     invalid_table_width           = 7
*     gui_refuse_filetransfer       = 8
*     customer_error                = 9
*     no_authority                  = 10
*     OTHERS                        = 11
*            .

  DATA lc_filename_str TYPE string.
  CLEAR lc_filename_str.
  lc_filename_str = filename_batch.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
*      bin_filesize              =
      filename                  = lc_filename_str
       filetype                  = 'ASC'
*      append                    = SPACE
*      write_field_separator     = SPACE
*      header                    = '00'
*      trunc_trailing_blanks     = SPACE
*      write_lf                  = 'X'
*      col_select                = SPACE
*      col_select_mask           = SPACE
*      dat_mode                  = SPACE
*      confirm_overwrite         = SPACE
*      no_auth_check             = SPACE
*      codepage                  = SPACE
*      ignore_cerr               = ABAP_TRUE
*      replacement               = '#'
*      write_bom                 = SPACE
*      trunc_trailing_blanks_eol = 'X'
*      wk1_n_format              = SPACE
*      wk1_n_size                = SPACE
*      wk1_t_format              = SPACE
*      wk1_t_size                = SPACE
*      show_transfer_status      = 'X'
*      fieldnames                =
*      write_lf_after_last_line  = 'X'
*    IMPORTING
*      filelength                =
    CHANGING
      data_tab                  = itab_batch
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      OTHERS                    = 24
          .

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CALL FUNCTION 'WS_EXECUTE'
   EXPORTING
*   DOCUMENT                 = ' '
    cd                       = ''
*    commandline              = commandline
    inform                   = 'X'
     program                  = filename_batch
*   STAT                     = ' '
*   WINID                    = ' '
*   OSMAC_SCRIPT             = ' '
*   OSMAC_CREATOR            = ' '
*   WIN16_EXT                = ' '
*   EXEC_RC                  = ' '
* IMPORTING
*   RBUFF                    =
   EXCEPTIONS
     frontend_error           = 1
     no_batch                 = 2
     prog_not_found           = 3
     illegal_option           = 4
     gui_refuse_execute       = 5
     OTHERS                   = 6
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  delete_filename = filename_batch.
  CALL FUNCTION 'WS_FILE_DELETE'
       EXPORTING
            file   = delete_filename
*       IMPORTING
*            return = return

      .


ENDFUNCTION.
