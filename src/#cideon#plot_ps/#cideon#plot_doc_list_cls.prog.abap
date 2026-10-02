*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/PLOT_DOC_LIST_CLS                                  *
*----------------------------------------------------------------------*
CLASS lcl_event_handler_alv_prst DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column
        .
ENDCLASS.





*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_alv IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_alv_prst IMPLEMENTATION.

  METHOD catch_dblclick.
    CLEAR wa_prst.
    index_prst = e_row.
    READ TABLE it_prst INDEX index_prst INTO wa_prst.

*    CLEAR wa_rc29l.
*    MOVE-CORRESPONDING wa_prst TO wa_rc29l.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DBLCLICK_PRST'
*      IMPORTING
*        RC       =
        .
  ENDMETHOD.

ENDCLASS.
