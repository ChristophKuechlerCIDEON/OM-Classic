*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F15 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  read_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_selection.



ENDFORM.                    " read_selection
*&---------------------------------------------------------------------*
*&      Form  read_selection_search_gl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_selection_search_gl.
  CLEAR lt_sel_searchlist_gl.

  CALL METHOD grid_searchlist->get_selected_rows
    IMPORTING
      et_index_rows = lt_sel_searchlist_gl
*      ET_ROW_NO     =
      .

ENDFORM.                    " read_selection_search_gl
*&---------------------------------------------------------------------*
*&      Form  set_selection_search_gl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_selection_search_gl.
* Globale Selektion für Suchliste setzen

  IF lt_sel_searchlist_gl[] IS INITIAL.
  ELSE.
    CALL METHOD grid_searchlist->set_selected_rows
      EXPORTING
        it_index_rows = lt_sel_searchlist_gl[]
*        IT_ROW_NO     =
        .
  ENDIF.


ENDFORM.                    " set_selection_search_gl
