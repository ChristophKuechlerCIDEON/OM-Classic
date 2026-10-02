FUNCTION /cideon/download_fehlblatt_lst.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_SPEICHER_ORT_FB_LISTE) TYPE  FILEP
*"     VALUE(I_KNZ_STATIC) TYPE  CHAR1
*"     VALUE(I_TRENNZEICHEN) TYPE  CHAR1
*"     VALUE(I_DIALOG) TYPE  CHAR1
*"  TABLES
*"      I_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"      TRENNZEICHEN_INITIAL
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   -
*   -
*-----------------------------------------------------------------------
* Journal
* 24.06.2003
* 27.06.2006 - Änderungen wegen UNICODE
*              DOWNLOAD
*-----------------------------------------------------------------------
* TYPE
  TYPES: BEGIN OF t_fb_list,
    dokar TYPE draw-dokar,
    doknr TYPE draw-doknr,
    dokvr TYPE draw-dokvr,
    doktl TYPE draw-doktl,
  END OF t_fb_list.
  TYPES: BEGIN OF t_fb_list_2,
    line TYPE char255,
  END OF t_fb_list_2.
* ITAB
  DATA: itab_fb_list TYPE TABLE OF t_fb_list_2.
  DATA: itab_fb_list_2 TYPE TABLE OF t_fb_list_2.
* WA
  DATA: wa_fb_list TYPE t_fb_list.
  DATA: wa_fb_list_2 TYPE t_fb_list_2.
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
* NORMAL
  DATA: filename TYPE rlgrap-filename.
  DATA: filename_str TYPE string.

* Tests
  IF i_knz_static = 'X'.
*   statische Trennung

  ELSE.
*   Trennung mit Trennzeichen
    IF i_trennzeichen IS INITIAL.
      MESSAGE e100(/cideon/plot_basis) WITH
        '' '' '' ''
        RAISING trennzeichen_initial.
    ELSE.
    ENDIF.
  ENDIF.


* Verarbeitung
  IF i_knz_static = 'X'.
*   statische Trennung
    CLEAR itab_fb_list.
    CLEAR wa_fb_list.
    LOOP AT i_itab_plotjobs INTO wa_plotjobs.

      MOVE-CORRESPONDING wa_plotjobs TO wa_fb_list.
      APPEND wa_fb_list TO itab_fb_list.

    ENDLOOP.
  ELSE.
*   Trennung mit Trennzeichen
    CLEAR itab_fb_list_2.
    CLEAR itab_fb_list.
    CLEAR wa_fb_list_2.
    LOOP AT i_itab_plotjobs INTO wa_plotjobs.
      CLEAR wa_fb_list_2.

      CONCATENATE wa_plotjobs-dokar i_trennzeichen
        wa_plotjobs-doknr i_trennzeichen
        wa_plotjobs-dokvr i_trennzeichen
        wa_plotjobs-doktl
        INTO wa_fb_list_2.
      APPEND wa_fb_list_2 TO itab_fb_list.

    ENDLOOP.

  ENDIF.

* Fronstend Service
  DATA: service TYPE REF TO cl_gui_frontend_services.
  CREATE OBJECT service
*    EXPORTING
*      TITLE  =
*      INIT_DIRECTORY =
      .



* Download
  IF i_dialog = 'X'.
    filename  = i_speicher_ort_fb_liste.

*   Dialog hochbringen
    CLEAR filename_str.
    filename_str = filename.

*   Splitten
    DATA: pf_path TYPE char255.
    DATA: pfx_path TYPE draw-filep.
    DATA: pfx_file TYPE draw-filep.

    pf_path = filename.

    CALL FUNCTION 'CV120_SPLIT_PATH'
         EXPORTING
              pf_path  = pf_path
         IMPORTING
              pfx_path = pfx_path
              pfx_file = pfx_file.

    DATA: fs_filename TYPE string.
    DATA: fs_path TYPE string.
    DATA: fs_fullpath TYPE string.

    fs_fullpath = pf_path.
    fs_filename = pfx_file.
    fs_path = pfx_path.

    CALL METHOD cl_gui_frontend_services=>file_save_dialog
       EXPORTING
*        WINDOW_TITLE      =
         default_extension = 'TXT'
         default_file_name = fs_filename
*        file_filter       = '*.txt'
         initial_directory = fs_path
      CHANGING
        filename          = fs_filename
        path              = fs_path
        fullpath          = fs_fullpath
*        USER_ACTION       =
       EXCEPTIONS
         cntl_error        = 1
         error_no_gui      = 2
         OTHERS            = 3
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      MESSAGE e026(/cideon/plot_basis)
        WITH
        fs_fullpath ' '
        ' ' ''.
*   Fehler beim Speichern der Datei & & & &

      EXIT.
    ENDIF.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
*        BIN_FILESIZE            =
        filename                = fs_fullpath
*        FILETYPE                = 'ASC'
*        APPEND                  = SPACE
*        WRITE_FIELD_SEPARATOR   = SPACE
*        HEADER                  = '00'
*        TRUNC_TRAILING_BLANKS   = SPACE
*        WRITE_LF                = 'X'
*        COL_SELECT              = SPACE
*        COL_SELECT_MASK         = SPACE
*      IMPORTING
*        FILELENGTH              =
      CHANGING
        data_tab                = itab_fb_list
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      MESSAGE e026(/cideon/plot_basis)
        WITH
        fs_fullpath ' '
        ' ' ''.
      EXIT.
    ENDIF.


*    CALL FUNCTION 'DOWNLOAD'
*     EXPORTING
**       BIN_FILESIZE                  = ' '
**       CODEPAGE                      = ' '
*        filename                      = filename
*        filetype                      = 'ASC'
**       ITEM                          = ' '
**       MODE                          = ' '
**       WK1_N_FORMAT                  = ' '
**       WK1_N_SIZE                    = ' '
**       WK1_T_FORMAT                  = ' '
**       WK1_T_SIZE                    = ' '
**       FILEMASK_MASK                 = ' '
**       FILEMASK_TEXT                 = ' '
**       FILETYPE_NO_CHANGE            = ' '
**       FILEMASK_ALL                  = ' '
**       FILETYPE_NO_SHOW              = ' '
**       SILENT                        = 'S'
**       COL_SELECT                    = ' '
**       COL_SELECTMASK                = ' '
**       NO_AUTH_CHECK                 = ' '
**     IMPORTING
**       ACT_FILENAME                  =
**       ACT_FILETYPE                  =
**       FILESIZE                      =
**       CANCEL                        =
*      TABLES
*        data_tab                      = itab_fb_list
**       FIELDNAMES                    =
*     EXCEPTIONS
*       invalid_filesize              = 1
*       invalid_table_width           = 2
*       invalid_type                  = 3
*       no_batch                      = 4
*       unknown_error                 = 5
*       gui_refuse_filetransfer       = 6
*       customer_error                = 7
*       OTHERS                        = 8
*              .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.

  ELSE.
    filename  = i_speicher_ort_fb_liste.

    filename_str = filename.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
*        BIN_FILESIZE            =
        filename                = filename_str
*        FILETYPE                = 'ASC'
*        APPEND                  = SPACE
*        WRITE_FIELD_SEPARATOR   = SPACE
*        HEADER                  = '00'
*        TRUNC_TRAILING_BLANKS   = SPACE
*        WRITE_LF                = 'X'
*        COL_SELECT              = SPACE
*        COL_SELECT_MASK         = SPACE
*      IMPORTING
*        FILELENGTH              =
      CHANGING
        data_tab                = itab_fb_list
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      MESSAGE e026(/cideon/plot_basis)
        WITH
        fs_fullpath ' '
        ' ' ''.
      EXIT.
    ENDIF.


*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**     BIN_FILESIZE                  = ' '
**     CODEPAGE                      = ' '
*        filename                      = filename
*        filetype                      = 'ASC'
**     MODE                          = ' '
**     WK1_N_FORMAT                  = ' '
**     WK1_N_SIZE                    = ' '
**     WK1_T_FORMAT                  = ' '
**     WK1_T_SIZE                    = ' '
**     COL_SELECT                    = ' '
**     COL_SELECTMASK                = ' '
**     NO_AUTH_CHECK                 = ' '
**   IMPORTING
**     FILELENGTH                    =
*      TABLES
*        data_tab                      = itab_fb_list
**     FIELDNAMES                    =
*     EXCEPTIONS
*       file_open_error               = 1
*       file_write_error              = 2
*       invalid_filesize              = 3
*       invalid_type                  = 4
*       no_batch                      = 5
*       unknown_error                 = 6
*       invalid_table_width           = 7
*       gui_refuse_filetransfer       = 8
*       customer_error                = 9
*       OTHERS                        = 10
*              .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.

  ENDIF.

  MESSAGE s025(/cideon/plot_basis)
    WITH
    fs_fullpath ' '
    ' ' ''.



ENDFUNCTION.
