FUNCTION z_cl_new_plot_list_ppl.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(FILTER) TYPE  C DEFAULT '*.*'
*"     VALUE(I_PPL_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(DEFAULT_USER) TYPE  XUBNAME OPTIONAL
*"  TABLES
*"      ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* Class Variable(s)..............
  DATA : obj_frontend_services     TYPE REF TO cl_gui_frontend_services.

* Internal Table(s)..............
  DATA : reproliste           TYPE TABLE OF zcl_s_line_256,
         itab_zcl_s_plotlist  TYPE TABLE OF zcl_s_plotlist,
         itab_joblist_file    TYPE TABLE OF zcl_s_plotlist,
         itab_ppl_skeleton    TYPE TABLE OF zcl_s_line_256,
         itab_ppl_proc_skel   TYPE TABLE OF zcl_s_line_256,
         itab_ppl_skel_lines  TYPE TABLE OF zcl_s_line_256,
         itab_x_lines         TYPE zcl_s_line_256
                                          OCCURS 0 WITH HEADER LINE.
* Working Area(s)....
  DATA : wa_zcl_s_plotlist         TYPE zcl_s_plotlist,
         wa_joblist_file           TYPE zcl_s_plotlist,
         wa_ppl_skeleton           TYPE zcl_s_line_256,
         wa_ppl_proc_skel          TYPE zcl_s_line_256,
         wa_ppl_skel_lines         TYPE zcl_s_line_256,
         wa_x_lines                TYPE zcl_s_line_256.


* Normal Local Variables...........
  DATA : lv_len_knz_inhalt_vz      TYPE i,
         lv_rc                     TYPE i,
         lv_filelength             TYPE i,
         lv_dir_create             TYPE string,
         lv_ppl_down_filename      TYPE string,
         lv_file_path              LIKE rlgrap-filename,
         lv_x_filename             LIKE rlgrap-filename,
         lv_ppl_filename           LIKE rlgrap-filename,
         lv_stripped_name          LIKE rlgrap-filename,
         lv_stripped_name1         LIKE rlgrap-filename,
         lv_stripped_name2         LIKE rlgrap-filename,
         lv_deck_down_path         LIKE rlgrap-filename,
         lv_ende_down_path         LIKE rlgrap-filename,
         lv_fehl_down_path         LIKE rlgrap-filename,
         lv_inhalts_down_path      LIKE rlgrap-filename.

* Boolean/Flag Variables........
  DATA : flag_ppl_deck_check       TYPE c,
         flag_ppl_ende_check       TYPE c,
         flag_ppl_fehl_check       TYPE c,
         flag_ppl_special_check    TYPE c,
         flag_ppl_inhalts_check    TYPE c,
         flag_rtf_deck_check       TYPE c,
         flag_rtf_ende_check       TYPE c,
         flag_rtf_fehl_check       TYPE c,
         flag_rtf_special_check    TYPE c,
         flag_rtf_inhalts_check    TYPE c.

***********************************************************

  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services .
  ELSE.
  ENDIF.

  CLEAR itab_zcl_s_plotlist.

  SORT itab_test BY doknr.

  LOOP AT itab_test.
    IF sy-tabix = 1.
      APPEND itab_test TO itab_joblist_file.
    ELSE.
    ENDIF.
    APPEND itab_test TO itab_zcl_s_plotlist.
  ENDLOOP.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 45
            text       = text-100.

  CALL METHOD obj_frontend_services->file_exist
    EXPORTING
      file            = i_down_path
    RECEIVING
      result          = lv_rc
    EXCEPTIONS
      cntl_error      = 1
      error_no_gui    = 2
      wrong_parameter = 3
      OTHERS          = 4
          .

  IF sy-subrc <> 0. "\\..\TEMP\CV04N Directory not available.

    CLEAR lv_rc.
    CALL METHOD obj_frontend_services->directory_create
      EXPORTING
        directory                = i_down_path
      CHANGING
        rc                       = lv_rc
      EXCEPTIONS
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        OTHERS                   = 8
            .

    IF sy-subrc <> 0."\\..\TEMP\CV04N Directory could not create.
      MESSAGE e048(zcvn) RAISING error.
    ENDIF.

  ENDIF.

* Getting the required Skeleton & Skeleton Lines from DB.
* If these values R present with the current user, then they
* will be copied to the internal Tables. Otherwise they will
* be getting with referece of the default user name.
  CALL FUNCTION 'Z_CL_UPLOAD_PPL_SKEL_AND_LINES'
       EXPORTING
            default_user          = 'SAP*'
       TABLES
            o_itab_ppl_skeleton   = itab_ppl_skeleton
            o_itab_ppl_skel_lines = itab_ppl_skel_lines
       EXCEPTIONS
            error                 = 1
            OTHERS                = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CALL FUNCTION 'FILE_GET_NAME'
           EXPORTING
*              CLIENT                  = SY-MANDT
               logical_filename        = 'ZZ_REPRO_LNA_STANDARD'
                operating_system        = sy-opsys
               parameter_1             = 'SAP_DMS_List_'
*              PARAMETER_2             = ' '
*              PARAMETER_3             = ' '
               use_presentation_server = 'X'
*              WITH_FILE_EXTENSION     = ' '
*              USE_BUFFER              = ' '
           IMPORTING
*              EMERGENCY_FLAG          =
*              FILE_FORMAT             =
               file_name               = lv_x_filename
           EXCEPTIONS
               file_not_found          = 1
               OTHERS                  = 2
                .
  IF sy-subrc <> 0.
    MESSAGE e005(zcvn) WITH 'FILE_GET_NAME'
                                          RAISING error.
  ENDIF.

  MOVE lv_x_filename TO lv_ppl_filename.

  CLEAR lv_stripped_name.
  CLEAR lv_file_path.

  CONCATENATE i_ppl_down_path lv_x_filename INTO lv_x_filename.

  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
       EXPORTING
            full_name     = lv_x_filename
       IMPORTING
            stripped_name = lv_stripped_name
            file_path     = lv_file_path
       EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e049(zcvn) WITH lv_x_filename RAISING error.
  ENDIF.

  SPLIT lv_stripped_name AT '.'
                        INTO lv_stripped_name1 lv_stripped_name2.

  CONCATENATE i_down_path lv_stripped_name1 INTO lv_dir_create.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 15
            text       = text-103.


  CLEAR lv_rc.

  CALL METHOD obj_frontend_services->directory_create
    EXPORTING
      directory                = lv_dir_create
    CHANGING
      rc                       = lv_rc
    EXCEPTIONS
      directory_create_failed  = 1
      cntl_error               = 2
      error_no_gui             = 3
      path_not_found           = 4
      directory_access_denied  = 5
      directory_already_exists = 6
      unknown_error            = 7
      OTHERS                   = 8
          .
  IF sy-subrc <> 0.
    MESSAGE e048(zcvn) WITH lv_dir_create RAISING error.
  ENDIF.


* Processing Skeleton lines.
  CALL FUNCTION 'Z_CL_PPL_PROCESS_SKELETON'
       TABLES
            i_itab_joblist_file  = itab_joblist_file
            i_itab_ppl_skeleton  = itab_ppl_skeleton
            o_itab_ppl_proc_skel = itab_ppl_proc_skel
       EXCEPTIONS
            error                = 1
            OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE e005(zcvn) WITH
               'Z_CL_PPL_PROCESS_SKELETON' RAISING error.
  ENDIF.


  LOOP AT itab_zcl_s_plotlist INTO wa_zcl_s_plotlist.

*   Trying to Download or Copying the documents.
    CALL FUNCTION 'Z_CL_PPL_GET_DOC_DETAIL_DLOAD'
         EXPORTING
              i_new_directory_name = lv_dir_create
              wa_zcl_s_plotlist    = wa_zcl_s_plotlist
              i_downloaded_path    = i_down_path
         EXCEPTIONS
              error                = 1
              OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE e005(zcvn) WITH
                 'Z_CL_PPL_GET_DOC_DETAIL_DLOAD' RAISING error.
    ENDIF.


*   Create an unique file name to process the data with
*   the DECK/ENDE/INHALTSBLATT.

*   Begining of Process of Deckblatt RTF file.
    IF wa_zcl_s_plotlist-deckblatt NE space.

      IF flag_rtf_special_check EQ space.

        CALL FUNCTION 'Z_CL_DECKBLATT'
             EXPORTING
                  i_down_deckblatt = lv_x_filename
                  i_strip_name     = lv_ppl_filename
             IMPORTING
                  e_deck_down_path = lv_deck_down_path
             TABLES
                  t_deck_list      = itab_joblist_file
             EXCEPTIONS
                  error            = 1
                  OTHERS           = 2.
        IF sy-subrc <> 0.
          MESSAGE e038(zcvn) RAISING error.
        ENDIF.

      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
*   End of Process of Deckblatt RTF file.

*   Begin of Process of Endeblatt RTF file.
    IF wa_zcl_s_plotlist-endeblatt NE space.

      IF flag_rtf_special_check EQ space.

        CALL FUNCTION 'Z_CL_ENDEBLATT'
             EXPORTING
                  i_down_endeblatt = lv_x_filename
                  i_strip_name     = lv_ppl_filename
             IMPORTING
                  e_ende_down_path = lv_ende_down_path
             TABLES
                  t_ende_list      = itab_joblist_file
             EXCEPTIONS
                  error            = 1
                  OTHERS           = 2.
        IF sy-subrc <> 0.
          MESSAGE e039(zcvn) RAISING error.
        ENDIF.

      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
*   End of Process of Endeblatt RTF file.

*** Checking with the length of 'Ja' or 'Nein'. When len_knz_inhalt_vz
*** length is 2 means 'Ja'. Then try to make an INHALTSBLATT.

    CLEAR lv_len_knz_inhalt_vz.

    lv_len_knz_inhalt_vz = strlen( wa_zcl_s_plotlist-knz_inhalt_vz ).

    IF flag_rtf_special_check EQ space.

      IF lv_len_knz_inhalt_vz EQ 2.

        CONCATENATE text-106 ' ' lv_inhalts_down_path INTO tmp_str.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
             EXPORTING
                  percentage = 45
                  text       = tmp_str.

        CALL FUNCTION 'Z_CL_INHALTSBLATT'
             EXPORTING
                  i_down_inhaltsblatt = lv_x_filename
                  i_strip_name        = lv_ppl_filename
             IMPORTING
                  e_inhalts_down_path = lv_inhalts_down_path
             TABLES
                  t_inhalts_list      = itab_joblist_file
             EXCEPTIONS
                  error               = 1
                  OTHERS              = 2.
        IF sy-subrc <> 0.
          MESSAGE e040(zcvn) RAISING error.
        ENDIF.

        flag_rtf_special_check = 'X'.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
*    "End of Inhalts Blatt RTF file.


    LOOP AT itab_ppl_skel_lines INTO wa_ppl_skel_lines.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = 30
                text       = text-082.

      MOVE wa_ppl_skel_lines-line TO itab_x_lines-line.

      IF itab_x_lines-line CS '%DELETE%'.
        REPLACE '%DELETE%' WITH wa_zcl_s_plotlist-lochen INTO
                                          itab_x_lines-line.
        APPEND itab_x_lines.

      ELSEIF itab_x_lines-line CS 'AO$_PATH='.
        CONCATENATE 'AO$_PATH=' wa_zcl_s_plotlist-filep
                INTO itab_x_lines-line+1 .
        APPEND itab_x_lines.

      ELSEIF itab_x_lines-line CS 'SAP$=%DVS%'.  "User-Felder
        CLEAR itab_x_lines-line.

        IF flag_ppl_special_check EQ space.

          LOOP AT itab_joblist_file INTO wa_joblist_file.

*********** Process of DECKBLATT für Plotjob........RTF..Begin.
            IF ( flag_ppl_deck_check EQ space AND
                              wa_joblist_file-deckblatt NE space ) .

              CALL FUNCTION 'Z_CL_DECKBLATT_PROCESS'
                   EXPORTING
                        wa_joblist_file  = wa_zcl_s_plotlist
                        i_deck_down_path = lv_deck_down_path
                   TABLES
                        i_itab_x_lines   = itab_x_lines
                        o_itab_x_lines   = itab_x_lines
                   EXCEPTIONS
                        error            = 1
                        OTHERS           = 2.
              IF sy-subrc <> 0.
                MESSAGE e005(zcvn) WITH
                        'Z_CL_DECKBLATT_PROCESS' RAISING error.
              ENDIF.

              flag_ppl_deck_check = 'X'.
            ENDIF.
************Process of DECKBLATT für Plotjob........RTF..End.


*********** Process of INHALTSVERZEICHNIS........RTF...Begin
            IF ( flag_ppl_inhalts_check EQ space AND
                              wa_joblist_file-knz_inhalt_vz EQ 'JA' ) .

              CALL FUNCTION 'Z_CL_INHALTSBLATT_PROCESS'
                   EXPORTING
                        wa_joblist_file     = wa_zcl_s_plotlist
                        i_inhalts_down_path = lv_inhalts_down_path
                   TABLES
                        o_itab_x_lines      = itab_x_lines
                        i_itab_x_lines      = itab_x_lines
                   EXCEPTIONS
                        error               = 1
                        OTHERS              = 2.
              IF sy-subrc <> 0.
                MESSAGE e005(zcvn) WITH
                        'Z_CL_INHALTSBLATT_PROCESS' RAISING error.
              ENDIF.

              flag_ppl_inhalts_check = 'X'.

            ENDIF.
*********** Process of INHALTSVERZEICHNIS........RTF...End

*********** Processing Failed Documents...Begin.
            IF NOT ( wa_zcl_s_plotlist-knz_fehl_blatt IS INITIAL ).

              CALL FUNCTION 'Z_CL_PROCESS_FAILED_DOCS'
                   EXPORTING
                        wa_zcl_s_plotlist = wa_zcl_s_plotlist
                   TABLES
                        i_itab_x_lines    = itab_x_lines
                        o_itab_x_lines    = itab_x_lines
                   EXCEPTIONS
                        error             = 1
                        OTHERS            = 2.
              IF sy-subrc <> 0.
                MESSAGE e005(zcvn) WITH 'Z_CL_PROCESS_FAILED_DOCS'
                                                          RAISING error.
              ENDIF.

            ENDIF.
*********** Processing Failed Documents...End.

************ PROCESS EXIST DOCS...START
            IF wa_zcl_s_plotlist-knz_fehl_blatt IS INITIAL.

              CALL FUNCTION 'Z_CL_PROCESS_EXISTING_DOCS'
                   EXPORTING
                        wa_exist_files = wa_zcl_s_plotlist
                        i_dir_create   = lv_dir_create
                   TABLES
                        o_itab_x_lines = itab_x_lines
                        i_itab_x_lines = itab_x_lines
                   EXCEPTIONS
                        error          = 1
                        OTHERS         = 2.
              IF sy-subrc <> 0.
                MESSAGE e005(zcvn) WITH 'Z_CL_PROCESS_EXISTING_DOCS'
                                                          RAISING error.
              ENDIF.
            ELSE.
            ENDIF.
************ PROCESS EXIST DOCS...END

          ENDLOOP. " End of itab_joblist_file.

        ENDIF.   " End of flag_ppl_special_check

      ENDIF.   " End of itab_x_lines

    ENDLOOP. " End of itab_ppl_skel_lines

  ENDLOOP. " End of itab_zcl_s_plotlist


*********** Process of ENDEBLATT........RTF...Begin
  LOOP AT itab_joblist_file INTO wa_joblist_file.

    IF ( flag_ppl_ende_check EQ space
                             AND
                         wa_joblist_file-endeblatt NE space ).

      CALL FUNCTION 'Z_CL_ENDEBLATT_PROCESS'
           EXPORTING
                wa_joblist_file  = wa_joblist_file
                i_ende_down_path = lv_ende_down_path
           TABLES
                o_itab_x_lines   = itab_x_lines
                i_itab_x_lines   = itab_x_lines
           EXCEPTIONS
                error            = 1
                OTHERS           = 2.
      IF sy-subrc <> 0.
        MESSAGE e005(zcvn) WITH 'Z_CL_ENDEBLATT_PROCESS'
                                              RAISING error.
      ENDIF.
    ENDIF.
  ENDLOOP.
*********** Process of ENDEBLATT........RTF...End.

  LOOP AT itab_ppl_proc_skel INTO wa_ppl_proc_skel .
    IF wa_ppl_proc_skel CS '%LINES.CLF%'.
      LOOP AT itab_x_lines INTO wa_x_lines.
        APPEND wa_x_lines TO reproliste.
      ENDLOOP.
    ELSE.
      APPEND wa_ppl_proc_skel TO reproliste.
    ENDIF.
  ENDLOOP.


* Temporariry "STRING" Variable.
  DATA : tmp_ppl_down_path TYPE string.
  MOVE lv_x_filename TO tmp_ppl_down_path.


  CALL METHOD obj_frontend_services->gui_download
    EXPORTING
*     BIN_FILESIZE            =
      filename                = tmp_ppl_down_path
      filetype                = 'ASC'
      append                  = space
      write_field_separator   = space
      header                  = '00'
      trunc_trailing_blanks   = space
      write_lf                = 'X'
      col_select              = space
      col_select_mask         = space
    IMPORTING
      filelength              = lv_filelength
    CHANGING
      data_tab                = reproliste
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
    MESSAGE e054(zcvn) WITH tmp_ppl_down_path RAISING error.
  ENDIF.

ENDFUNCTION.
