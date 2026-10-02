FUNCTION z_cl_read_ini_preprozessor.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME
*"     VALUE(I_FILENAME) TYPE  FILEP
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------
  DATA: tmp_filename TYPE rlgrap-filename.

  tmp_filename = i_filename.

  user_name = i_uname.

  CALL FUNCTION 'Z_CL_CHECK_FOR_UNAME'
    EXPORTING
      i_uname = user_name
    IMPORTING
      o_uname = user_name
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  tmp_string = i_filename.

*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      filename                      = tmp_string
*      filetype                      = 'ASC'
**     has_field_separator           = ' '
**     header_length                 = 0
**     read_by_line                  = 'X'
**   IMPORTING
**   FILELENGTH                    =
**   HEADER                        =
*    TABLES
*      data_tab                      = ini_data_tab
*   EXCEPTIONS
*     file_open_error               = 1
*     file_read_error               = 2
*     no_batch                      = 3
*     gui_refuse_filetransfer       = 4
*     invalid_type                  = 5
*     no_authority                  = 6
*     unknown_error                 = 7
*     bad_data_format               = 8
*     header_not_allowed            = 9
*     separator_not_allowed         = 10
*     header_too_long               = 11
*     unknown_dp_error              = 12
*     access_denied                 = 13
*     dp_out_of_memory              = 14
*     disk_full                     = 15
*     dp_timeout                    = 16
*     OTHERS                        = 17
*            .
*  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'UPLOAD'.

  CALL FUNCTION lc_fname

"CALL FUNCTION 'UPLOAD'
EXPORTING
*     CODEPAGE                      = ' '
 filename                      = tmp_filename
*     FILETYPE                      = ' '
*     ITEM                          = ' '
*     FILEMASK_MASK                 = ' '
*     FILEMASK_TEXT                 = ' '
*     FILETYPE_NO_CHANGE            = ' '
*     FILEMASK_ALL                  = ' '
*     FILETYPE_NO_SHOW              = ' '
*     LINE_EXIT                     = ' '
*     USER_FORM                     = ' '
*     USER_PROG                     = ' '
*     SILENT                        = 'S'
*   IMPORTING
*     FILESIZE                      =
*     CANCEL                        =
*     ACT_FILENAME                  =
*     ACT_FILETYPE                  =
TABLES
  data_tab                      = ini_data_tab
EXCEPTIONS
 conversion_error              = 1
 invalid_table_width           = 2
 invalid_type                  = 3
 no_batch                      = 4
 unknown_error                 = 5
 gui_refuse_filetransfer       = 6
 OTHERS                        = 7
        .
  IF sy-subrc <> 0.
    MESSAGE i050(zcl_plint_tools)
      WITH tmp_filename ''
      '' 'Z_CL_READ_INI_PREPROZESSOR' RAISING error.
  ENDIF.


  REFRESH itab_ini.
  CALL FUNCTION 'Z_CL_MAKE_INI_TAB'
       TABLES
            i_itab_ini_data = ini_data_tab
*            o_itab_ini      = itab_ini
       EXCEPTIONS
            error           = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'Z_CL_UPDATE_REPRO_CL_INI'
    EXPORTING
      i_user_name = i_uname
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFUNCTION.
