FUNCTION z_cl_del_tmp_dir_by_names.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_CLF_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(I_FILTER) TYPE  STRING OPTIONAL
*"     VALUE(I_TEST) TYPE  CHAR1 DEFAULT 'X'
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*&--------------------------------------------------------------------&*
*& Function Group  : ZPLOT_INTERFACE                                  &*
*& Function Module : Z_CL_DEL_TMP_DIR_BY_NAMES                        &*
*& Author          : Srinivas.Mamillapalli@CIDEON-Software.de         &*
*&--------------------------------------------------------------------&*

  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  DATA : tmp_file_name LIKE rlgrap-filename.

  DATA : tmp_dirname LIKE rlgrap-filename.

  DATA : lv_directory_name(50) TYPE c,
         lv_file_type(3)       TYPE c,
         lv_rc                 TYPE i,
         lv_count              TYPE i,
         lv_dir_length         TYPE i,
         lv_directory          TYPE string,
         lv_del_file           TYPE string,
         lv_deleatable_file    TYPE rlgrap-filename.

  DATA : itab_x_files          TYPE TABLE OF zcl_s_line_256,
         wa_x_files            TYPE zcl_s_line_256.

  DATA : itab_clf_directories  TYPE TABLE OF zcl_s_line_256,
         wa_clf_directories    TYPE zcl_s_line_256.

  DATA : itab_cv04n_dirs       TYPE TABLE OF zcl_s_line_256,
         wa_cv04n_dirs         TYPE zcl_s_line_256.

  DATA : itab_file_table       TYPE TABLE OF filep,
         wa_file_table         TYPE filep.

  DATA : tmp_fname(150) TYPE c,
         tmp_exist      TYPE c.

  IF i_test = 'X'.
    i_clf_down_path =
      '\\Soft-gr-oratest\AutoORG\PlottingSolution\Preprocessor\scan\'.

    i_down_path = '\\Soft-gr-oratest\AutoORG\TEMP\CV04N\'.

    i_filter = '*.*'.
  ELSE.
  ENDIF.

***************************


***************************

  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ENDIF.

* CLF Files that not yet Processed by Preprocessor.
  REFRESH itab_file_table.
  CLEAR lv_count.
  CALL METHOD obj_frontend_services->directory_list_files
    EXPORTING
      directory                   = i_clf_down_path
      filter                      = '*.*'
      files_only                  = 'X'
*     directories_only            = 'X'
    CHANGING
      file_table                  = itab_clf_directories
      count                       = lv_count
    EXCEPTIONS
      cntl_error                  = 1
      directory_list_files_failed = 2
      wrong_parameter             = 3
      error_no_gui                = 4
      OTHERS                      = 5
          .

  IF sy-subrc <> 0.
    MESSAGE e004(zcvn) RAISING error.
  ENDIF.

* Collect the names of the files for which the Temp Directories
* existing in ...\TEMP\CV04N\ directory.
  LOOP AT itab_clf_directories INTO wa_clf_directories.
    SPLIT wa_clf_directories AT '.' INTO lv_directory_name lv_file_type.
    APPEND lv_directory_name TO itab_x_files.
  ENDLOOP.

*Names of directories from '\\Soft-gr-oratest\AutoORG\TEMP\CV04N\'.
  REFRESH itab_file_table.
  CLEAR lv_count.

  CALL METHOD obj_frontend_services->directory_list_files
    EXPORTING
      directory                   = i_down_path
      filter                      = '*.*'
*     files_only                  = 'X'
      directories_only            = 'X'
    CHANGING
      file_table                  = itab_cv04n_dirs
      count                       = lv_count
    EXCEPTIONS
      cntl_error                  = 1
      directory_list_files_failed = 2
      wrong_parameter             = 3
      error_no_gui                = 4
      OTHERS                      = 5
          .
  IF sy-subrc <> 0.
    MESSAGE e004(zcvn) RAISING error.
  ENDIF.

  LOOP AT itab_x_files INTO wa_x_files.
    LOOP AT itab_cv04n_dirs INTO wa_cv04n_dirs.
      IF wa_cv04n_dirs-line EQ wa_x_files .
        DELETE TABLE  itab_cv04n_dirs FROM wa_cv04n_dirs.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT itab_cv04n_dirs INTO wa_cv04n_dirs.

    CONCATENATE i_down_path wa_cv04n_dirs '\' INTO lv_directory.

* Collect the file names of those files existing in a directory.
    CALL METHOD obj_frontend_services->directory_list_files
      EXPORTING
        directory                   = lv_directory
        filter                      = '*.*'
*         FILES_ONLY                  =
*         DIRECTORIES_ONLY            =
      CHANGING
        file_table                  = itab_file_table
        count                       = lv_count
      EXCEPTIONS
        cntl_error                  = 1
        directory_list_files_failed = 2
        wrong_parameter             = 3
        error_no_gui                = 4
        OTHERS                      = 5
            .

*    IF sy-subrc EQ 0.
    IF lv_count NE 0.
*If files R existing in a directory..collect the names of those files.

      LOOP AT itab_file_table INTO wa_file_table.

        CONCATENATE lv_directory wa_file_table INTO lv_del_file.

        IF lv_del_file CS '.'.

          MOVE lv_del_file TO lv_deleatable_file.
          CLEAR lv_del_file.
          CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
               EXPORTING
                    full_name     = lv_deleatable_file
               IMPORTING
                    stripped_name = gv_stripped_name
                    file_path     = gv_file_path
               EXCEPTIONS
                    x_error       = 1
                    OTHERS        = 2.
          IF sy-subrc <> 0.
*               MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

        ENDIF.

*       Delete the files in a directory first...

        CLEAR tmp_file_name.

        MOVE lv_deleatable_file TO tmp_file_name.

        CLEAR lv_deleatable_file.

        CALL FUNCTION 'TMP_GUI_DELETE_FILE'
             EXPORTING
                  file_name = tmp_file_name
             EXCEPTIONS
                  failed    = 1
                  OTHERS    = 2.

        IF sy-subrc NE 0.
          CLEAR tmp_exist.
          CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
            EXPORTING
              fname                = tmp_file_name
           IMPORTING
              exist                = tmp_exist
*           ISDIR                =
*           FILESIZE             =
*         EXCEPTIONS
*           FILEINFO_ERROR       = 1
*           OTHERS               = 2
                    .
          IF NOT ( tmp_exist IS INITIAL ).
            MESSAGE s042(zcvn) WITH gv_stripped_name RAISING error.
            "MESSAGE s042(zcvn) WITH gv_stripped_name.
          ENDIF.
        ENDIF.
        CLEAR tmp_exist.
        CLEAR tmp_file_name.

      ENDLOOP.

** After making the directory empty..delete the directory also.

      CLEAR tmp_dirname.

      MOVE lv_directory TO tmp_dirname.

      CALL FUNCTION 'GUI_REMOVE_DIRECTORY'
           EXPORTING
                dirname = tmp_dirname
           EXCEPTIONS
                failed  = 1
                OTHERS  = 2.
      IF sy-subrc <> 0.

        DATA : tmp_isdir TYPE c.
*               tmp_exist TYPE c.

        CLEAR tmp_exist.

        CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
          EXPORTING
            fname                = tmp_dirname
         IMPORTING
           exist                = tmp_exist
           isdir                = tmp_isdir
*         FILESIZE             =
         EXCEPTIONS
           fileinfo_error       = 1
           OTHERS               = 2
                  .

       IF NOT ( tmp_exist IS INITIAL ) AND NOT ( tmp_isdir IS INITIAL ).
          MESSAGE s046(zcvn) WITH tmp_dirname RAISING error.
        ENDIF.
      ENDIF.

      CLEAR tmp_dirname.
      CLEAR lv_directory.

*      CALL METHOD obj_frontend_services->directory_delete
*        EXPORTING
*          directory               = lv_directory
*        CHANGING
*          rc                      = lv_rc
*        EXCEPTIONS
*          directory_delete_failed = 1
*          cntl_error              = 2
*          error_no_gui            = 3
*          path_not_found          = 4
*          directory_access_denied = 5
*          unknown_error           = 6
*          OTHERS                  = 7
*              .
*      IF sy-subrc <> 0.
*        MESSAGE s046(zcvn) WITH lv_directory RAISING error.
*      ENDIF.



*      lv_dir_length = strlen( lv_directory ).
*      lv_dir_length = lv_dir_length - 1.
*
*      lv_directory = lv_directory+0(lv_dir_length).
*      CLEAR lv_dir_length.
*

      CLEAR tmp_fname.
      CLEAR tmp_exist.

*********** Geändert ende..
    ELSE.
*   If there are no files in a directory..just delete the directory.

*      CALL METHOD obj_frontend_services->directory_delete
*        EXPORTING
*          directory               = lv_directory
*        CHANGING
*          rc                      = lv_rc
*        EXCEPTIONS
*          directory_delete_failed = 1
*          cntl_error              = 2
*          error_no_gui            = 3
*          path_not_found          = 4
*          directory_access_denied = 5
*          unknown_error           = 6
*          OTHERS                  = 7
*              .
*      IF sy-subrc <> 0.
*        MESSAGE s046(zcvn) WITH lv_directory RAISING error.
*      ENDIF.

      CLEAR tmp_dirname.
      MOVE lv_directory TO tmp_dirname.

      CALL FUNCTION 'GUI_REMOVE_DIRECTORY'
           EXPORTING
                dirname = tmp_dirname
           EXCEPTIONS
                failed  = 1
                OTHERS  = 2.

      CLEAR tmp_fname.
      CLEAR tmp_exist.
      MOVE tmp_dirname TO tmp_fname.

      CLEAR tmp_exist.
      CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
        EXPORTING
          fname                = tmp_fname
        IMPORTING
          exist                = tmp_exist
*         ISDIR                =
*         FILESIZE             =
        EXCEPTIONS
          fileinfo_error       = 1
          OTHERS               = 2
                .

      IF tmp_exist NE space.
        MESSAGE s046(zcvn) WITH tmp_dirname RAISING error.
      ENDIF.


    ENDIF.

    CLEAR lv_rc.
    CLEAR lv_directory.
    REFRESH itab_file_table.

  ENDLOOP.

ENDFUNCTION.
