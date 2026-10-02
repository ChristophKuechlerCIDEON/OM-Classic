FUNCTION z_cl_del_tmp_dir_by_dates.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(FILTER) TYPE  STRING OPTIONAL
*"     VALUE(DELETABLE_DAYS) TYPE  C OPTIONAL
*"  EXPORTING
*"     VALUE(COUNT) TYPE  I
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*&--------------------------------------------------------------------&*
*& Function Group  : ZPLOT_INTERFACE                                  &*
*& Function Module : Z_CL_DEL_TMP_DIR_BY_DATES                        &*
*& Author          : Srinivas.Mamillapalli@CIDEON-Software.de         &*
*&--------------------------------------------------------------------&*
*& This Function Module deletes all the down loaded files in          &*
*& \\Soft-gr-oratest\AutoORG\TEMP\CV04N\ by Number of Dates passed by &*
*& User Customization. By Default I used 3 days.This can be changed   &*
*& at Program level 'deletable_days'. If 'deletable_days = 0', then   &*
*& this Function Module deletes all the directories contains User Name&*
*&--------------------------------------------------------------------&*


  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services,
         directory TYPE string,
         rc TYPE i,
         n TYPE i VALUE 1.

  DATA : filename TYPE string.
  DATA : user_name(12)  TYPE c,
         time_stamp(14) TYPE c,
         date        TYPE sy-datum.

  DATA : x_dates TYPE TABLE OF zcl_s_line_256 WITH HEADER LINE.

  DATA : it_file_table TYPE TABLE OF filep,
         wa_file_table TYPE filep.

  DATA : it_delete_table TYPE TABLE OF filep,
         wa_delete_table TYPE filep.

  DATA : table_of_files_deleted TYPE TABLE OF  sdokpath ,
         table_of_dir_occured   TYPE TABLE OF  sdokpath.

  IF filter IS INITIAL.
    filter = '*.*'.
  ELSE.
  ENDIF.

  deletable_days = '3'.


  IF i_down_path IS INITIAL.
    i_down_path = '\\Soft-gr-oratest\AutoORG\TEMP\CV04N\'.
  ELSE.
  ENDIF.

  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ENDIF.

  IF NOT ( deletable_days IS INITIAL ).

    CALL METHOD obj_frontend_services->directory_list_files
      EXPORTING
        directory                   = i_down_path
        filter                      = filter
*       files_only                  = 'X'
        directories_only            = 'X'
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
    IF sy-subrc <> 0.
      MESSAGE e004(zcvn) RAISING error.
    ENDIF.

    IF deletable_days NE '0'.
      DO deletable_days TIMES.
        IF n LE deletable_days.
          date = sy-datum - n.
          APPEND date TO x_dates.
          n = n + 1.
        ENDIF.
      ENDDO.
    ELSE.
*      LOOP AT it_file_table INTO wa_file_table .
*        IF wa_file_table CS user.
*          APPEND wa_file_table TO it_delete_table.
*        ELSE.
*        ENDIF.
*      ENDLOOP.
    ENDIF.


    LOOP AT x_dates.
      LOOP AT it_file_table INTO wa_file_table .

        IF wa_file_table CS x_dates-line.

*          IF user IS INITIAL.
*            user = sy-uname.
*          ENDIF.

*          IF wa_file_table CS user.
*            APPEND wa_file_table TO it_delete_table.
*          ELSE.
*          ENDIF.
        ELSE.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    REFRESH it_file_table.
    CLEAR count.
    CLEAR rc.

    LOOP AT it_delete_table INTO wa_delete_table.

      CONCATENATE i_down_path wa_delete_table INTO directory.

      CALL METHOD obj_frontend_services->directory_list_files
        EXPORTING
          directory                   = directory
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
          CONCATENATE directory '\' wa_file_table INTO filename.

          CALL METHOD obj_frontend_services->file_delete
            EXPORTING
              filename           = filename
            CHANGING
              rc                 = rc
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
            MESSAGE e042(zcvn) WITH filename RAISING error.
          ENDIF.
        ENDLOOP.

      ELSE.
      ENDIF.

      CALL METHOD obj_frontend_services->directory_delete
        EXPORTING
          directory               = directory
        CHANGING
          rc                      = rc
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
        MESSAGE e043(zcvn) WITH directory RAISING error.
      ENDIF.

      CLEAR directory.

    ENDLOOP.

  ELSE.
  ENDIF.


ENDFUNCTION.
