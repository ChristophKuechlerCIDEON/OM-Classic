*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_005_CLASSES                               *
*----------------------------------------------------------------------*
* Klassendefinitioen usw.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column.
endclass.



*---------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD catch_dblclick.
    index_itab_searchlist = e_row.
    READ TABLE itab_search INDEX index_itab_searchlist INTO
      wa_akt_search.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DBLCLICK_SEARCH'
*      IMPORTING
*        RC       =
        .

  ENDMETHOD.
ENDCLASS.
