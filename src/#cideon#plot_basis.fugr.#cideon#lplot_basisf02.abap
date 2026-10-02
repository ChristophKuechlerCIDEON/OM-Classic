*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/LPLOT_BASISF02                                     *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_sel_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sel_items.
* holt ausgewählte items
  DATA: index TYPE i.

  CLEAR itab_et_index_rows_plotjobs .
  CLEAR wa_et_index_rows_plotjobs .

  CALL METHOD alv_originals->get_selected_rows
     IMPORTING
       et_index_rows = itab_et_index_rows_plotjobs
*       ET_ROW_NO     =
      .

  CLEAR wa_documentfiles.

  LOOP AT itab_et_index_rows_plotjobs INTO
    wa_et_index_rows_plotjobs.
    index = wa_et_index_rows_plotjobs-index.
    READ TABLE itab_documentfiles
      INTO wa_documentfiles INDEX index.
  ENDLOOP.


ENDFORM.                    " get_sel_items
*&---------------------------------------------------------------------*
*&      Form  FREE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM free_alv.
  CALL METHOD alv_originals->free
         EXCEPTIONS
           cntl_error        = 1
           cntl_system_error = 2
           OTHERS            = 3
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " FREE_ALV
*&---------------------------------------------------------------------*
*&      Form  get_sel_items_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sel_items_2.
* holt ausgewählte items
  DATA: index TYPE i.

  CLEAR itab_et_index_rows_plotjobs .
  CLEAR wa_et_index_rows_plotjobs .

  CALL METHOD alv_originals_2->get_selected_rows
     IMPORTING
       et_index_rows = itab_et_index_rows_plotjobs
*       ET_ROW_NO     =
      .

  CLEAR wa_documentfiles.
  CLEAR itab_documentfiles_tmp.

  LOOP AT itab_et_index_rows_plotjobs INTO
    wa_et_index_rows_plotjobs.
    index = wa_et_index_rows_plotjobs-index.
    READ TABLE itab_documentfiles
      INTO wa_documentfiles INDEX index.
    APPEND wa_documentfiles TO itab_documentfiles_tmp .
  ENDLOOP.

ENDFORM.                    " get_sel_items_2
*&---------------------------------------------------------------------*
*&      Form  editor_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM editor_get_data.
* Daten des Editor holen als interne Tabelle
  CLEAR it_text.
  CALL METHOD editor->get_text_as_r3table
*     EXPORTING
*       only_when_modified     = false
     IMPORTING
       table                  = it_text
*    IS_MODIFIED            =
     EXCEPTIONS
       error_dp               = 1
       error_cntl_call_method = 2
       error_dp_create        = 3
       potential_data_loss    = 4
       OTHERS                 = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Daten als Stream holen
  CLEAR it_text_stream.
  CALL METHOD editor->get_text_as_stream
*     EXPORTING
*       only_when_modified     = false
     IMPORTING
       text                   = it_text_stream
*      IS_MODIFIED            =
     EXCEPTIONS
       error_dp               = 1
       error_cntl_call_method = 2
       OTHERS                 = 3
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " editor_get_data
