*----------------------------------------------------------------------*
***INCLUDE /CIDEON/SEL_TO_MIGRATE_F1 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALL_CV04N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_cv04n.
* Aufruf der Standardsuche

  CALL FUNCTION 'CV100_DOC_SEARCH'
   EXPORTING
      pf_cv04_list_type       = '2'
*     PF_WEB_LIST_TYPE        =
      api_flag                = 'X'
   TABLES
     ptx_draw                = itab_ptx_draw
            .



ENDFORM.                    " CALL_CV04N
*&---------------------------------------------------------------------*
*&      Form  selektion_holen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selektion_holen.
* Selektion aus ALV holen
  DATA: index_itab_ergebnisse TYPE i.


  CLEAR itab_et_index_rows_ergebnisse.

  CALL METHOD alv_ergebnisse->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_ergebnisse
*      ET_ROW_NO     =
      .

  LOOP AT itab_et_index_rows_ergebnisse
    INTO wa_et_index_rows_ergebnisse.
*   get the content of the selected Line
    CLEAR index_itab_ergebnisse.
    index_itab_ergebnisse = wa_et_index_rows_ergebnisse-index.

    READ TABLE itab_ptx_draw INDEX index_itab_ergebnisse
      INTO wa_ptx_draw.

    APPEND wa_ptx_draw TO itab_ptx_draw_sel.

  ENDLOOP.

ENDFORM.                    " selektion_holen
