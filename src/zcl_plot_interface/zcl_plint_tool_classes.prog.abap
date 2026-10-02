*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_TOOL_CLASSES                                     *
*----------------------------------------------------------------------*


CLASS lcl_event_handler_fail_doc_alv DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column
*        ,
*
*    handle_toolbar:
*        FOR EVENT toolbar OF cl_gui_alv_grid
*            IMPORTING e_object e_interactive,
*
*    handle_menu_button
*        FOR EVENT menu_button OF cl_gui_alv_grid
*            IMPORTING e_object e_ucomm,
*
*    handle_user_command
*        FOR EVENT user_command OF cl_gui_alv_grid
*            IMPORTING e_ucomm
   .

ENDCLASS.

*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_alv IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_fail_doc_alv  IMPLEMENTATION.

  METHOD catch_dblclick.
    index_itab_fail_doc = e_row.
    READ TABLE itab_fail_document_alv INDEX index_itab_fail_doc INTO
      wa_fail_document_alv.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DBLCLICK_LIST'
*      IMPORTING
*        RC       =
        .
  ENDMETHOD.
ENDCLASS.

CLASS cl_myevent_handler DEFINITION.

  PUBLIC SECTION.
    METHODS: on_navigate_complete
               FOR EVENT navigate_complete OF cl_gui_html_viewer
               IMPORTING url.
ENDCLASS.

CLASS cl_myevent_handler IMPLEMENTATION.

  METHOD on_navigate_complete.
    edurl = url.
  ENDMETHOD.

ENDCLASS.
