FUNCTION z_cl_del_cv04n_tmp_directories.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(FILTER) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(COUNT) TYPE  I
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*&--------------------------------------------------------------------&*
*& Function Group  : ZPLOT_INTERFACE                                  &*
*& Function Module : Z_CL_DEL_CV04N_TMP_DIRECTORIES                   &*
*& Author          : Srinivas.Mamillapalli@CIDEON.de                  &*
*&--------------------------------------------------------------------&*
*& This Function Module deletes all the down loaded files in          &*
*& \\Soft-gr-oratest\AutoORG\TEMP\CV04N\ by Number of Dates passed by &*
*& User Customization.                                                &*
*&--------------------------------------------------------------------&*

  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services,
         gv_directory          TYPE string,
         lv_rc                 TYPE i,
         lv_n_simple_counter   TYPE i VALUE 1.

  DATA : lv_date        TYPE sy-datum.

  DATA : it_file_table TYPE TABLE OF filep,
         wa_file_table TYPE filep.

  DATA : it_delete_table TYPE TABLE OF filep,
         wa_delete_table TYPE filep.

  DATA : lv_answer.

*******************************************************
  IF filter IS INITIAL.
    filter = '*.*'.
  ELSE.
  ENDIF.

  IF i_down_path IS INITIAL.
    i_down_path = '\\Soft-gr-oratest\AutoORG\TEMP\CV04N\'.
  ELSE.
  ENDIF.

  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ENDIF.

  CALL METHOD obj_frontend_services->directory_list_files
    EXPORTING
      directory                   = i_down_path
      filter                      = filter
*      files_only                  = 'X'
      directories_only            = 'X'
    CHANGING
      file_table                  = it_delete_table
      count                       = count
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


  LOOP AT it_delete_table INTO wa_delete_table.
    IF wa_delete_table CS sy-uname.

      REFRESH it_file_table.
      CLEAR gv_directory.

      CONCATENATE i_down_path wa_delete_table INTO gv_directory.

      CALL METHOD obj_frontend_services->directory_list_files
        EXPORTING
          directory                   = gv_directory
          filter                      = '*.*'
*         FILES_ONLY                  =
*         DIRECTORIES_ONLY            =
        CHANGING
          file_table                  = it_file_table
          count                       = count
        EXCEPTIONS
          cntl_error                  = 1
          directory_list_files_failed = 2
          wrong_parameter             = 3
          error_no_gui                = 4
          OTHERS                      = 5
              .

      IF sy-subrc EQ 0.
        LOOP AT it_file_table INTO wa_file_table.

          CLEAR gv_filename.

          CONCATENATE gv_directory '\' wa_file_table INTO gv_filename.

          CALL METHOD obj_frontend_services->file_delete
            EXPORTING
              filename           = gv_filename
            CHANGING
              rc                 = lv_rc
          EXCEPTIONS
            file_delete_failed = 1
            cntl_error         = 2
            error_no_gui       = 3
            file_not_found     = 4
            access_denied      = 5
            unknown_error      = 6
            OTHERS             = 7
                         .

          IF sy-subrc <> 0.
            MESSAGE e042(zcvn) WITH gv_filename RAISING error.
          ENDIF.
        ENDLOOP.

      ELSE.
      ENDIF.

      CALL METHOD obj_frontend_services->directory_delete
        EXPORTING
          directory               = gv_directory
        CHANGING
          rc                      = lv_rc
      EXCEPTIONS
        directory_delete_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        path_not_found          = 4
        directory_access_denied = 5
        unknown_error           = 6
        OTHERS                  = 7
              .
      IF sy-subrc <> 0.
        MESSAGE e043(zcvn) WITH gv_directory RAISING error.
      ENDIF.

      CLEAR gv_directory.

    ELSE.
    ENDIF.

  ENDLOOP.
ENDFUNCTION.
