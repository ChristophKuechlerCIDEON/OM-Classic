FUNCTION /cideon/stamp_call_stamp_tool.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP
*"     VALUE(I_FILENAME_ZIEL) TYPE  FILEP
*"     VALUE(I_FILENAME_STEMPEL) TYPE  FILEP
*"     VALUE(I_STAMP_PROGRAM) TYPE  FILEP
*"     VALUE(I_START_VERZEICHNIS) TYPE  DSVASDOCID
*"     VALUE(I_ARBEITS_VERZEICHNIS) TYPE  DSVASDOCID
*"     VALUE(I_KONVERTER) TYPE  CHAR10
*"     VALUE(I_STAMP_PARAMETER) TYPE  ZCL_PWERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 15.07.2002 creation
*
* 7.0.169.1  CKR
* 2014/08/04 Sulzer
  " EHP 7 - Ausbau FB DSVAS_DOC_WS_DOWNLOAD_50
  " FB /CIDEON/STAMP_CALL_STAMP_TOOL
  "
*-----------------------------------------------------------------------
*TYPES
  TYPES: BEGIN OF t_batch,
    line TYPE char600,
    END OF t_batch.
*ITAB
  DATA: itab_batch TYPE TABLE OF t_batch.
*WA
  DATA: wa_batch TYPE t_batch.
*NORMAL
  DATA: return TYPE i.
  DATA: filename TYPE filep.
  DATA: filename_out TYPE filep.
  DATA: filename_stempel TYPE filep.
  DATA: commandline TYPE char600.
  DATA: len TYPE i.
  DATA: filename_batch TYPE filep.
  DATA: docid TYPE dsvasdocid.
*  DATA: verzeichnis TYPE dsvasdocid.
*  DATA: dateiname TYPE dsvasdocid.
*  DATA: extension TYPE dsvasdocid.


* Beispiel des Aufrufs
* ConvertClient in="C:\temp\convert\test.tif"
* out="C:\temp\convert\test_2.tif" convparam="DPI=300"
* stampfile="c:\stamp.txt"

  CONCATENATE 'in=' '"' i_filename '"'
    INTO filename.
  CONCATENATE 'out=' '"' i_filename_ziel '"'
    INTO filename_out.

  CONCATENATE 'stampfile=' '"' i_filename_stempel '"'
    INTO filename_stempel.

  CONCATENATE filename ' ' filename_out  "  ' ' filename_stempel
    INTO commandline SEPARATED BY space.
  CONCATENATE commandline '' INTO commandline .
  len = STRLEN( commandline ).

  CONCATENATE commandline  ' ' filename_stempel
    INTO commandline SEPARATED BY space.
  len = STRLEN( filename_stempel ) .
  CONCATENATE commandline '' INTO commandline .

  CONCATENATE commandline  ' ' 'converter='
    INTO commandline SEPARATED BY space.
  len = STRLEN( filename_stempel ) .

  CONCATENATE commandline  i_konverter
    INTO commandline .
  len = STRLEN( filename_stempel ) .

  len = STRLEN( commandline ).

* BATCH-Datei zum Starten schreiben
  CLEAR wa_batch.
  CLEAR itab_batch.

* Problemen mit UNC Pfaden
*  CONCATENATE 'CD' ' ' i_arbeits_verzeichnis
*    INTO wa_batch-line SEPARATED BY space.
*  APPEND wa_batch TO itab_batch.

  CONCATENATE i_stamp_program
    commandline
    i_stamp_parameter
    INTO wa_batch-line SEPARATED BY space.
  APPEND wa_batch TO itab_batch.

* Dateiname zerlegen
  "docid = i_filename.

*  CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
*    EXPORTING
*      pf_docid     = docid
*    IMPORTING
*      pf_directory = verzeichnis
*      pf_filename  = dateiname
*      pf_extension = extension.

  DATA pfx_path TYPE draw-filep.
  DATA pfx_file TYPE draw-filep.
  CLEAR pfx_path.
  CLEAR pfx_file.

  CALL FUNCTION 'CV120_SPLIT_PATH'
    EXPORTING
      pf_path  = i_filename
    IMPORTING
      pfx_path = pfx_path
      pfx_file = pfx_file.



*  CONCATENATE i_start_verzeichnis  'start.bat' INTO filename_batch.
  CONCATENATE i_start_verzeichnis  pfx_file '_start.bat'
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
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

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
     program                  = filename_batch "i_stamp_program
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



*CALL FUNCTION 'GUI_EXEC'
*  EXPORTING
*    command          = '\\hamlet\stamp before view\stamp.bat'
**   PARAMETER        =
* IMPORTING
*   RETURNCODE       = return
*         .


* per RFC starten

* temporäre Dateien löschen
* Stempeldateien
* Startdateien
  DATA: file_to_delete TYPE rlgrap-filename.

  file_to_delete = filename_batch.
  CALL FUNCTION 'GUI_DELETE_FILE'
    EXPORTING
      file_name = file_to_delete
    EXCEPTIONS
      failed    = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFUNCTION.
