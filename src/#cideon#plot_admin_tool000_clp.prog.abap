*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/PLOT_ADMIN_TOOL000_CLP                             *
*----------------------------------------------------------------------*
CLASS lcl_alv_prepr_event_receiver DEFINITION.

  PUBLIC SECTION.
    DATA: ucomm TYPE sy-ucomm.
*   toolbar
    METHODS handle_toolbar_set
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.
*   user command
    METHODS handle_menu_button
        FOR EVENT menu_button OF cl_gui_alv_grid
            IMPORTING e_object e_ucomm.

    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
*   double click
    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.

    METHODS handle_hotspot_click
      FOR EVENT hotspot_click
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id.

ENDCLASS.

*---------------------------------------------------------------------*
*       CLASS CL_EVENT_RECEIVER IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_alv_prepr_event_receiver IMPLEMENTATION.
* handle user_command for grid alv_preprocessor
  METHOD handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'ENTER'.
        CALL METHOD alv_preprocessor->get_selected_rows
          IMPORTING
            et_index_rows = lt_rows.

        IF lt_rows IS INITIAL.
          MESSAGE i022(/cideon/plot_admin).
        ELSE.
          PERFORM select_preprocessor TABLES lt_rows.
          PERFORM change_itab_new_prepr.
        ENDIF.

      WHEN 'CANCEL'.
        CALL METHOD alv_preprocessor->free.
        FREE alv_preprocessor.
        CALL METHOD dialogbox_container->free.
        FREE dialogbox_container.

    ENDCASE.

  ENDMETHOD.

  METHOD handle_menu_button.
  ENDMETHOD.
* handle double_click for grid alv_preprocessor
  METHOD handle_double_click.
    DATA: lt_rows TYPE lvc_t_row.

    CALL METHOD alv_preprocessor->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    IF lt_rows IS INITIAL.
      MESSAGE i022(/cideon/plot_admin).
    ELSE.
      PERFORM select_preprocessor TABLES lt_rows.
      PERFORM change_itab_new_prepr.

    ENDIF.


  ENDMETHOD.
* handle toolbar for grid alv_preprocessor

  METHOD handle_toolbar_set.
    DATA: gr_toolbar TYPE stb_button.
    DATA: lc_menu    TYPE REF TO cl_ctmenu.
    DATA: ls_menu    TYPE stb_btnmnu.
    DATA: lc_menu_switch TYPE REF TO cl_ctmenu.
*add toolbar-button 'Übernehmen'
    CLEAR gr_toolbar.
    MOVE 3 TO gr_toolbar-butn_type.
    APPEND gr_toolbar TO e_object->mt_toolbar.

    CLEAR gr_toolbar.
    MOVE 'ENTER' TO gr_toolbar-function.
    MOVE icon_checked TO gr_toolbar-icon.
    MOVE text-033 TO gr_toolbar-quickinfo.
    MOVE text-032 TO gr_toolbar-text.
    MOVE ' ' TO gr_toolbar-disabled.
    APPEND gr_toolbar TO e_object->mt_toolbar.
*add toolbar-button 'Abbrechen'
    CLEAR gr_toolbar.
    MOVE 3 TO gr_toolbar-butn_type.
    APPEND gr_toolbar TO e_object->mt_toolbar.

    CLEAR gr_toolbar.
    MOVE 'CANCEL' TO gr_toolbar-function.
    MOVE icon_cancel TO gr_toolbar-icon.
    MOVE text-035 TO gr_toolbar-quickinfo.
    MOVE text-034 TO gr_toolbar-text.
    MOVE ' ' TO gr_toolbar-disabled.
    APPEND gr_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD handle_hotspot_click.
  ENDMETHOD.


ENDCLASS.
