FUNCTION z_cl_delete_files_in_tmp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(PATH) TYPE  C OPTIONAL
*"     REFERENCE(FILE_TYPE) TYPE  C DEFAULT '*.*'
*"  TABLES
*"      TABLE_OF_FILES_DELETED STRUCTURE  SDOKPATH OPTIONAL
*"      TABLE_OF_DIR_OCCURED STRUCTURE  SDOKPATH OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

** NOTICE : Rather than Unsing this function Module, Use the other
**          function Module 'Z_CL_DELETE_TMP_DIRECTORIES'.

  DATA : complete_path LIKE rlgrap-filename .


  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
    EXPORTING
     directory        = path
     filter           = file_type
*   IMPORTING
*     file_count       =
*     dir_count        =
    TABLES
     file_table       = table_of_files_deleted
     dir_table        = table_of_dir_occured
   EXCEPTIONS
     cntl_error       = 1
     OTHERS           = 2
            .
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

  LOOP AT table_of_files_deleted.

    CLEAR complete_path.


    CONCATENATE path table_of_files_deleted-pathname INTO complete_path.

    CALL FUNCTION 'WS_FILE_DELETE'
      EXPORTING
        file          = complete_path
*   IMPORTING
*     RETURN        =
              .

  ENDLOOP.

ENDFUNCTION.
