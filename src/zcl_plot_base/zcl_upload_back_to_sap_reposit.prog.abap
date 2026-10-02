*&---------------------------------------------------------------------*
*& Report  ZCL_UPLOAD_BACK_TO_SAP_REPOSIT                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_upload_back_to_sap_reposit NO STANDARD PAGE HEADING.

DATA : itab_draw                TYPE TABLE OF draw,
       itab_file_table          TYPE TABLE OF sdokpath,
       itab_dir_table           TYPE TABLE OF sdokpath,
       itab_bapi_doc_files2     TYPE TABLE OF bapi_doc_files2,
       itab_final_original_docs TYPE TABLE OF sdokpath.

DATA : itab_uploadable_docs TYPE TABLE OF sdokpath,
       wa_uploadable_docs   TYPE sdokpath.

DATA : itab_CID2_files TYPE TABLE OF sdokpath,
       wa_CID2_files   TYPE sdokpath.

DATA : wa_draw                  TYPE draw,
       wa_file_table            TYPE sdokpath,
       wa_dir_table             TYPE sdokpath,
       wa_bapi_doc_files2       TYPE bapi_doc_files2,
       wa_final_original_docs   TYPE sdokpath.

DATA : itab_bapiret2            TYPE bapiret2.

DATA : itab_intern TYPE  kcde_cells OCCURS 0 WITH HEADER LINE,
       tmp_tab TYPE bapi_doc_files2 OCCURS 0 WITH HEADER LINE,
       itab_bapi_doc_draw2 TYPE TABLE OF bapi_doc_draw2
                                          WITH HEADER LINE.

DATA : lv_file_count      TYPE i,
       lv_dir_count       TYPE i,
       lv_filename        LIKE rlgrap-filename,
       lv_selected_folder LIKE rlgrap-filename,
       lv_file_path       LIKE rlgrap-filename,
       lv_stripped_name   LIKE rlgrap-filename,
       lv_pserver_string  LIKE rlgrap-filename,
       lv_dokar           LIKE bapi_doc_aux-doctype,
       lv_doknr           LIKE bapi_doc_aux-docnumber,
       lv_doktl           LIKE bapi_doc_aux-docpart,
       lv_dokvr           LIKE bapi_doc_aux-docversion.


************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_check AS CHECKBOX.
PARAMETERS: p_list  RADIOBUTTON GROUP prog DEFAULT 'X' .
PARAMETERS: p_up  RADIOBUTTON GROUP prog  .
SELECTION-SCREEN END OF BLOCK bl1.

INITIALIZATION.

AT SELECTION-SCREEN.

START-OF-SELECTION.

  IF p_check = 'X'.
    IF p_list = 'X'.
      EXIT.
    ELSE.
    ENDIF.
  ELSE.
    EXIT.
  ENDIF.



  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
       EXPORTING
            window_title    = text-010
            initial_folder  = '\\Soft-gr-oratest\autoorg\TEMP\'
       IMPORTING
            selected_folder = lv_selected_folder
       EXCEPTIONS
            cntl_error      = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF lv_selected_folder IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

*$$$$$$$$ List Of Files & Directories $$$$$$$$$$
  PERFORM list_of_directories_and_files.

  IF ( lv_selected_folder CS '\\' ) AND ( lv_selected_folder CS '\'  ).

    LOOP AT itab_cid2_files INTO wa_cid2_files.

      CLEAR lv_pserver_string.

      MOVE wa_cid2_files-pathname TO lv_pserver_string.

      CLEAR lv_stripped_name.
      CLEAR lv_file_path.

      CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
           EXPORTING
                full_name     = lv_pserver_string
           IMPORTING
                stripped_name = lv_stripped_name
                file_path     = lv_file_path
           EXCEPTIONS
                x_error       = 1
                OTHERS        = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      DATA : tmp_file_name TYPE rlgrap-filename,
             tmp_file_extn TYPE rlgrap-filename.

      SPLIT lv_stripped_name AT '.' INTO tmp_file_name tmp_file_extn.

      PERFORM f_excel_upload .

      PERFORM document_checkin_and_replace.

    ENDLOOP.

  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_excel_upload
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_excel_upload.

  FIELD-SYMBOLS : <fs>.

  DATA : tmp_rc        LIKE sy-subrc,
         tmp_index     TYPE i,
         tmp_start_col TYPE i VALUE '1',
         tmp_start_row TYPE i VALUE '1',
         tmp_end_col   TYPE i VALUE '256',
         tmp_end_row   TYPE i VALUE '65536'.

  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
       EXPORTING
            filename                = lv_pserver_string
            i_begin_col             = tmp_start_col
            i_begin_row             = tmp_start_row
            i_end_col               = tmp_end_col
            i_end_row               = tmp_end_row
       TABLES
            intern                  = itab_intern
       EXCEPTIONS
            inconsistent_parameters = 1
            upload_ole              = 2.

  MOVE sy-subrc TO tmp_rc.

  CHECK NOT itab_intern[] IS INITIAL.

  SORT itab_intern BY row col.

  LOOP AT itab_intern.

    MOVE : itab_intern-col TO tmp_index.

    ASSIGN COMPONENT tmp_index OF STRUCTURE tmp_tab TO <fs>.

    MOVE : itab_intern-value TO <fs>.

    AT END OF row.
      APPEND tmp_tab.
      CLEAR tmp_tab.
    ENDAT.

  ENDLOOP.

  SORT tmp_tab BY documenttype documentnumber
                  documentpart documentversion .

ENDFORM.                    " f_excel_upload

*&---------------------------------------------------------------------*
*&      Form  list_of_directories_and_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_of_directories_and_files.

  DATA : tmp_chosen_folder  TYPE rlgrap-filename,
         tmp_sub_folder1    TYPE rlgrap-filename,
         tmp_path           LIKE sdokpath-pathname.

  DATA : tmp_itab_sub_file_table TYPE TABLE OF sdokpath,
         tmp_itab_sub_dir_table  TYPE TABLE OF sdokpath.

  DATA : tmp_wa_sub_file_table TYPE sdokpath,
         tmp_wa_sub_dir_table  TYPE sdokpath.

  CONCATENATE lv_selected_folder '\' INTO tmp_chosen_folder.

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
       EXPORTING
            directory  = tmp_chosen_folder
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

  IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF NOT ( itab_file_table IS INITIAL ) .
    LOOP AT itab_file_table INTO wa_file_table.

      CONCATENATE tmp_chosen_folder wa_file_table-pathname
      INTO tmp_path.

      MOVE tmp_path TO wa_final_original_docs-pathname.
      APPEND wa_final_original_docs TO itab_final_original_docs.
    ENDLOOP.
  ENDIF.



  IF NOT ( itab_dir_table IS INITIAL ).

    LOOP AT itab_dir_table INTO wa_dir_table.

      CONCATENATE tmp_chosen_folder wa_dir_table-pathname
                                    '\' INTO tmp_sub_folder1.

      CLEAR lv_file_count.
      CLEAR lv_dir_count.

      CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
           EXPORTING
                directory  = tmp_sub_folder1
                filter     = '*.*'
           IMPORTING
                file_count = lv_file_count
                dir_count  = lv_dir_count
           TABLES
                file_table = tmp_itab_sub_file_table
                dir_table  = tmp_itab_sub_dir_table
           EXCEPTIONS
                cntl_error = 1
                OTHERS     = 2.

      IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF NOT ( tmp_itab_sub_file_table IS INITIAL ) .
        LOOP AT tmp_itab_sub_file_table INTO tmp_wa_sub_file_table.
          CONCATENATE tmp_sub_folder1
                 tmp_wa_sub_file_table-pathname INTO tmp_path.

          IF tmp_path CS '.CID1'.
            MOVE tmp_path TO wa_cid2_files-pathname.
            APPEND wa_cid2_files TO itab_cid2_files.
          ELSE.
            MOVE tmp_path TO wa_final_original_docs-pathname.
            APPEND wa_final_original_docs TO itab_final_original_docs.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.
  ENDIF.

  SORT itab_cid2_files.
  SORT itab_final_original_docs.

ENDFORM.                    " list_of_directories_and_files


*&---------------------------------------------------------------------*
*&      Form  document_checkin_and_replace
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM document_checkin_and_replace.

  DATA : tmp_itab_documentfiles TYPE TABLE OF bapi_doc_files2 ,
         tmp_wa_documentfiles TYPE bapi_doc_files2 .

  DATA : tmp_itab_local_data TYPE bapi_doc_files2
                              OCCURS 0 WITH HEADER LINE.

  DATA : tmp_wa          TYPE bapi_doc_files2 .
  DATA : tmp_dokvr_i     TYPE i,
         tmp_doktl_i     TYPE i,
         tmp_dokvr_n(2)  TYPE n,
         tmp_doktl_n(3)  TYPE n.

  DATA : tmp_only_flag TYPE c,
         tmp_count      TYPE c VALUE 1.


  CLEAR tmp_only_flag.

  LOOP AT itab_final_original_docs INTO wa_final_original_docs
  WHERE pathname CS tmp_file_name .
    LOOP AT tmp_tab INTO tmp_wa .

      MOVE wa_final_original_docs-pathname TO tmp_wa-docfile.

      tmp_dokvr_i = tmp_wa-documentversion.
      tmp_dokvr_n = tmp_dokvr_i.
      tmp_wa-documentversion = tmp_dokvr_n.

      tmp_doktl_i = tmp_wa-documentversion.
      tmp_doktl_n = tmp_doktl_i.
      tmp_wa-documentpart = tmp_doktl_n.

      IF tmp_only_flag IS INITIAL.
        APPEND tmp_wa TO tmp_itab_local_data.
        tmp_only_flag = 'X'.
      ENDIF.

      CLEAR tmp_wa-documenttype.
      CLEAR tmp_wa-documentnumber.
      CLEAR tmp_wa-documentversion.
      CLEAR tmp_wa-documentpart.

      APPEND tmp_wa TO tmp_itab_documentfiles.

      DELETE TABLE tmp_tab FROM tmp_wa.
      CONTINUE.

    ENDLOOP.

  ENDLOOP.

*  SORT tmp_itab_documentfiles BY originaltype.

  DELETE ADJACENT DUPLICATES FROM tmp_itab_documentfiles
                    COMPARING originaltype.

  LOOP AT tmp_itab_local_data.

    CALL FUNCTION 'BAPI_DOCUMENT_CHECKIN_REPLACE2'
      EXPORTING
        documenttype            = tmp_itab_local_data-documenttype
        documentnumber          = tmp_itab_local_data-documentnumber
        documentpart            = tmp_itab_local_data-documentpart
        documentversion         = tmp_itab_local_data-documentversion
*   HOSTNAME                = ' '
*   STATUSINTERN            = ' '
*   STATUSEXTERN            = ' '
*   STATUSLOG               = ' '
*   REVLEVEL                = ' '
*   AENNR                   = ' '
* IMPORTING
*   RETURN                  =
      TABLES
        documentfiles           = tmp_itab_documentfiles
*   COMPONENTS              =
*   DOCUMENTSTRUCTURE       =
                    .
  ENDLOOP.


  IF sy-subrc <> 0.
  ELSE.
  ENDIF.

ENDFORM.                    " document_checkin_and_replace
