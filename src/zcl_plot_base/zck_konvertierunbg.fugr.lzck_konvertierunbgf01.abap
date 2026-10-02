*----------------------------------------------------------------------*
***INCLUDE LZCK_KONVERTIERUNBGF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_EXCEL_UPLOAD_TO_INTERNAL_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_excel_upload_to_internal_tab.

ENDFORM.                    " F_EXCEL_UPLOAD_TO_INTERNAL_TAB
*&---------------------------------------------------------------------*
*&      Form  f_upload_CID1_DAT_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_upload_cid1_dat_file USING lv_cid1_file_path.


  FIELD-SYMBOLS : <fs>.

  DATA : tmp_rc        LIKE sy-subrc,
         tmp_index     TYPE i,
         tmp_start_col TYPE i VALUE '1',
         tmp_start_row TYPE i VALUE '1',
         tmp_end_col   TYPE i VALUE '256',
         tmp_end_row   TYPE i VALUE '65536'.

  DATA : itab_intern TYPE  kcde_cells OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
       EXPORTING
            filename                = lv_cid1_file_path
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

    ASSIGN COMPONENT tmp_index OF STRUCTURE itab_cid1 TO <fs>.

    MOVE : itab_intern-value TO <fs>.

    AT END OF row.
      APPEND itab_cid1.
      CLEAR itab_cid1.
    ENDAT.

  ENDLOOP.

  SORT itab_cid1 BY documenttype documentnumber
                  documentpart documentversion .

ENDFORM.                    " f_upload_CID1_DAT_file
*&---------------------------------------------------------------------*
*&      Form  f_upload_cid2_dat_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_CID2_FILE_PATH  text
*----------------------------------------------------------------------*
FORM f_upload_cid2_dat_file USING lv_cid2_file_path.


  FIELD-SYMBOLS : <fs>.

  DATA : tmp_rc        LIKE sy-subrc,
         tmp_index     TYPE i,
         tmp_start_col TYPE i VALUE '1',
         tmp_start_row TYPE i VALUE '1',
         tmp_end_col   TYPE i VALUE '256',
         tmp_end_row   TYPE i VALUE '65536'.

  DATA : itab_intern TYPE  kcde_cells OCCURS 0 WITH HEADER LINE.


  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
       EXPORTING
            filename                = lv_cid2_file_path
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

    ASSIGN COMPONENT tmp_index OF STRUCTURE itab_tab_cid2 TO <fs>.

    MOVE : itab_intern-value TO <fs>.

    AT END OF row.
      APPEND itab_tab_cid2.
      CLEAR itab_tab_cid2.
    ENDAT.

  ENDLOOP.

  SORT itab_tab_cid2 BY number filename.

ENDFORM.                    " f_upload_cid2_dat_file
