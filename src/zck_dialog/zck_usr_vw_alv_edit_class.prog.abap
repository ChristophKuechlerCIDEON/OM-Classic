*----------------------------------------------------------------------*
*   INCLUDE ZCK_CFG_00_ALV_EDIT_CLASS                                  *
*----------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: on_double_click FOR EVENT double_click
                                   OF cl_gui_alv_grid
                   IMPORTING e_row.

ENDCLASS.

*---------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD: on_double_click.
    PERFORM popup_to_confirm.
    IF answer = 'J'.
      clear wa_save_neccessary.
      clear sy-datar.
*      CLEAR ZCL_PLINT_CFG_00.
      wa_edit_mode = co_show_mode.
      READ TABLE it INTO wa INDEX e_row-index.
      index = e_row-index.
*      ZCL_PLINT_CFG_00 = wa.

      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = 'DBLCLICK'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
