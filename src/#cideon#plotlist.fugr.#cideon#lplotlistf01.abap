*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOTLISTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  free_control
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM free_control.
* ALV löschen

*  CALL METHOD alv_files->free
*    EXCEPTIONS
*      cntl_error        = 1
*      cntl_system_error = 2
*      OTHERS            = 3
*          .
*  IF sy-subrc <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.


ENDFORM.                    " free_control
*&---------------------------------------------------------------------*
*&      Form  get_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selection.
  CLEAR lt_sel_rows.

  CALL METHOD alv_files->get_selected_rows
    IMPORTING
      et_index_rows = lt_sel_rows
*      ET_ROW_NO     =
      .


ENDFORM.                    " get_selection
*&---------------------------------------------------------------------*
*&      Form  sel_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_all.
* Alles selektieren
  DATA: count_lines TYPE i.

  REFRESH lt_sel_rows.
  DESCRIBE TABLE lt_files_internal LINES count_lines.

  DO count_lines TIMES.
    lc_sel_rows-index = sy-index.
    APPEND lc_sel_rows TO
      lt_sel_rows.
  ENDDO.



  CALL METHOD alv_files->set_selected_rows
     EXPORTING
       it_index_rows = lt_sel_rows
*      IT_ROW_NO     =
      .

ENDFORM.                    " sel_all
*&---------------------------------------------------------------------*
*&      Form  de_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM de_select.



ENDFORM.                    " de_select
