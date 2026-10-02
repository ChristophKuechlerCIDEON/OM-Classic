FUNCTION z_cl_background_job_del_dirs.
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

*  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  DATA : lv_directory_name(50) TYPE c,
         lv_file_type(3)       TYPE c,
         lv_rc                 TYPE i,
         lv_count              TYPE i,
         lv_file_count         TYPE i,
         lv_dir_count          TYPE i,
         lv_dir_length         TYPE i,
         lv_directory          TYPE rlgrap-filename,
         lv_del_file           TYPE rlgrap-filename,
         lv_deleatable_file    TYPE rlgrap-filename.

  DATA : lv_clf_down_path(300) TYPE c,
         lv_down_path(300) TYPE c.

  DATA : itab_clf_file_table TYPE TABLE OF sdokpath,
         wa_clf_file_table   TYPE sdokpath.

  DATA : itab_clf_dir_table TYPE TABLE OF sdokpath,
         wa_clf_dir_table   TYPE sdokpath.

  DATA : itab_cv04n_file_table TYPE TABLE OF sdokpath,
         wa_cv04n_file_table   TYPE sdokpath.

  DATA : itab_cv04n_dir_table TYPE TABLE OF sdokpath,
         wa_cv04n_dir_table   TYPE sdokpath.

  DATA : itab_file_table TYPE TABLE OF sdokpath,
         wa_file_table   TYPE sdokpath.

  DATA : itab_dir_table TYPE TABLE OF sdokpath,
         wa_dir_table   TYPE sdokpath.

  DATA : itab_x_files          TYPE TABLE OF zcl_s_line_256,
         wa_x_files            TYPE zcl_s_line_256.

  IF i_test = 'X'.
    IF i_clf_down_path IS INITIAL.
      i_clf_down_path =
        '\\Soft-gr-oratest\AutoORG\PlottingSolution\Preprocessor\scan\'.
    ENDIF.

    IF i_down_path IS INITIAL.
      i_down_path = '\\Soft-gr-oratest\AutoORG\TEMP\CV04N\'.
    ENDIF.

*    i_filter = '*.*'.

  ELSE.
  ENDIF.

  MOVE i_clf_down_path TO lv_clf_down_path.
  MOVE i_down_path TO lv_down_path.

* CLF Files that not yet Processed by Preprocessor.
  REFRESH itab_clf_file_table.
  REFRESH itab_clf_dir_table.

  CLEAR lv_count.

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
       EXPORTING
            directory  = lv_clf_down_path
            filter     = '*.*'
       IMPORTING
            file_count = lv_file_count
            dir_count  = lv_dir_count
       TABLES
            file_table = itab_clf_file_table
            dir_table  = itab_clf_dir_table
       EXCEPTIONS
            cntl_error = 1
            OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE e004(zcvn) RAISING error.
  ENDIF.

* Collect the names of the files for which the Temp Directories
* existing in ...\TEMP\CV04N\ directory.
  LOOP AT itab_clf_file_table INTO wa_clf_file_table.
    SPLIT wa_clf_file_table AT '.' INTO lv_directory_name lv_file_type.
    APPEND lv_directory_name TO itab_x_files.
  ENDLOOP.

*Names of directories from '\\Soft-gr-oratest\AutoORG\TEMP\CV04N\'.
  REFRESH itab_cv04n_file_table.
  REFRESH itab_cv04n_dir_table.

  CLEAR lv_file_count.
  CLEAR lv_dir_count.

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
       EXPORTING
            directory  = lv_down_path
            filter     = '*.*'
       IMPORTING
            file_count = lv_file_count
            dir_count  = lv_dir_count
       TABLES
            file_table = itab_cv04n_file_table
            dir_table  = itab_cv04n_dir_table
       EXCEPTIONS
            cntl_error = 1
            OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE e004(zcvn) RAISING error.
  ENDIF.

* Collect unnecessary concerned directories for CLF Files.
  LOOP AT itab_x_files INTO wa_x_files.
    LOOP AT itab_cv04n_dir_table INTO wa_cv04n_dir_table
                                      WHERE pathname EQ wa_x_files .
      IF sy-subrc EQ 0.
        DELETE TABLE  itab_cv04n_dir_table FROM wa_cv04n_dir_table.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDLOOP.



  LOOP AT itab_cv04n_dir_table INTO wa_cv04n_dir_table.

    CONCATENATE i_down_path wa_cv04n_dir_table '\' INTO lv_directory.

    REFRESH itab_file_table.
    REFRESH itab_dir_table.
    CLEAR lv_file_count.
    CLEAR lv_dir_count.

    CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
         EXPORTING
              directory  = lv_directory
              filter     = '*.*'
         IMPORTING
              file_count = lv_file_count
              dir_count  = lv_dir_count
         TABLES
              file_table = itab_file_table
              dir_table  = itab_dir_table
         EXCEPTIONS
              cntl_error = 1
              OTHERS     = 2.

    IF sy-subrc EQ 0.
*If files R existing in a directory..collect the names of those files.

      LOOP AT itab_file_table INTO wa_file_table.

        CONCATENATE lv_directory wa_file_table INTO lv_del_file.

        IF lv_del_file CS '.'.

          MOVE lv_del_file TO lv_deleatable_file.

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

        CLEAR lv_rc.

        CALL FUNCTION 'WS_FILE_DELETE'
             EXPORTING
                  file   = lv_del_file
             IMPORTING
                  return = lv_rc.
        IF sy-subrc <> 0.
          MESSAGE e045(zcvn) WITH lv_directory RAISING error.
        ENDIF.

      ENDLOOP.

*      lv_dir_length = strlen( lv_directory ).
*      lv_dir_length = lv_dir_length - 1.
*      lv_directory = lv_directory+0(lv_dir_length).

      CLEAR lv_dir_length.
      CLEAR lv_rc.

      CALL FUNCTION 'TMP_GUI_REMOVE_DIRECTORY'
           EXPORTING
                dirname = lv_directory
           EXCEPTIONS
                failed  = 1
                OTHERS  = 2.
      IF sy-subrc <> 0.
*        MESSAGE e045(zcvn) WITH lv_directory RAISING error.
      ENDIF.
    ELSE.

      CLEAR lv_rc.
      CALL FUNCTION 'TMP_GUI_REMOVE_DIRECTORY'
           EXPORTING
                dirname = lv_directory
           EXCEPTIONS
                failed  = 1
                OTHERS  = 2.
      IF sy-subrc <> 0.
*        MESSAGE e045(zcvn) WITH lv_directory RAISING error.
      ENDIF.

    ENDIF.

    CLEAR lv_rc.
    CLEAR lv_directory.
    REFRESH itab_file_table.

  ENDLOOP.

ENDFUNCTION.
