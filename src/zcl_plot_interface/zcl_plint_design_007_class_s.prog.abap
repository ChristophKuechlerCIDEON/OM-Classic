*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_007_CLASS_S                               *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_alv DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_alv DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column,

    handle_toolbar:
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,

    handle_menu_button
        FOR EVENT menu_button OF cl_gui_alv_grid
            IMPORTING e_object e_ucomm,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

    handle_hotspot_click FOR EVENT hotspot_click
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id

    ,
    handle_selection FOR EVENT delayed_changed_sel_callback
        OF cl_gui_alv_grid
   .


ENDCLASS.




*---------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_alv IMPLEMENTATION.

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

  METHOD handle_toolbar.

    DATA: lc_menu    TYPE REF TO cl_ctmenu.
    DATA: ls_menu    TYPE stb_btnmnu.

    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*    CLEAR ls_sl_button.
*    MOVE 'CV03N' TO ls_sl_button-function.
*    MOVE icon_display TO ls_sl_button-icon.
*    MOVE text-007 TO ls_sl_button-quickinfo.
*    MOVE text-008 TO ls_sl_button-text.
*    MOVE ' ' TO ls_sl_button-disabled.
*    APPEND ls_sl_button TO e_object->mt_toolbar.
*
*    CLEAR ls_sl_button.
*    MOVE 3 TO ls_sl_button-butn_type.
*    APPEND ls_sl_button TO e_object->mt_toolbar.
*
**  Originale anzeigen
*    CLEAR ls_sl_button.
*    MOVE 'VIEW_ORIGINALS' TO ls_sl_button-function.
*    MOVE icon_display TO ls_sl_button-icon.
*    MOVE text-038 TO ls_sl_button-quickinfo.
*    MOVE text-039 TO ls_sl_button-text.
*    MOVE ' ' TO ls_sl_button-disabled.
*    APPEND ls_sl_button TO e_object->mt_toolbar.

    DATA: lc_menu_view TYPE REF TO cl_ctmenu.
    CLEAR ls_sl_button.
    "MOVE 'VIEW' TO ls_sl_button-function.
    MOVE 'CV03N' TO ls_sl_button-function.
    MOVE icon_display TO ls_sl_button-icon.
    MOVE text-034 TO ls_sl_button-quickinfo.
    MOVE text-035 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    MOVE 1 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_view.
    CALL METHOD lc_menu_view->add_function
                EXPORTING fcode   = 'CV03N'
                text    = text-008.
    CALL METHOD lc_menu_view->add_function
                EXPORTING fcode   = 'VIEW_ORIGINALS'
                          text    = text-039.
    CALL METHOD lc_menu_view->add_separator.
    CALL METHOD lc_menu_view->add_function
                EXPORTING fcode   = 'FRONTTYP'
                          text    = text-041.

    ls_menu-ctmenu = lc_menu_view.
    ls_menu-function = 'CV03N'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*
    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*   Menüpunkt OPTIONEN
    CLEAR ls_sl_button.
    "MOVE 'OPTION' TO ls_sl_button-function.
    MOVE 'ONLY_LAST_VERSION' TO ls_sl_button-function.
    MOVE icon_read_file TO ls_sl_button-icon.
    MOVE text-015 TO ls_sl_button-quickinfo.
    MOVE text-016 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    MOVE 1 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.


    CREATE OBJECT lc_menu.
    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'ONLY_LAST_VERSION'
                text    = text-017.
    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'LAST_FREE_VERSION'
                          text    = text-018.
    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'ONLY_FREE_VERSION'
                          text    = text-019.
    CALL METHOD lc_menu->add_separator.

    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'ACTUAL_DIS'
                          text    = text-045.
    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'ACTUAL_RELEASED_DIS'
                          text    = text-046.

    CALL METHOD lc_menu->add_separator.
    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'ONLY_GOOD_MATERIAL'
                          text    = text-026.
    CALL METHOD lc_menu->add_separator.
    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'NO_DUPLICATES_SL'
                          text    = text-020.

    ls_menu-ctmenu = lc_menu.
    ls_menu-function = 'ONLY_LAST_VERSION'.

    APPEND ls_menu TO e_object->mt_btnmnu.

*   Menüpunkt SUCHLISTE
    DATA: lc_menu_search TYPE REF TO cl_ctmenu.
    CLEAR ls_sl_button.
    "MOVE 'SEARCH' TO ls_sl_button-function.
    MOVE 'OPEN_SEARCHLIST' TO ls_sl_button-function.
    MOVE icon_icon_list TO ls_sl_button-icon.
    MOVE text-022 TO ls_sl_button-quickinfo.
    MOVE text-023 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    MOVE 1 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_search.
    CALL METHOD lc_menu_search->add_function
                EXPORTING fcode   = 'OPEN_SEARCHLIST'
                          text    = text-025.

    CALL METHOD lc_menu_search->add_function
                EXPORTING fcode   = 'SAVE_SEARCHLIST'
                text    = text-024.
    ls_menu-ctmenu = lc_menu_search.
    ls_menu-function = 'OPEN_SEARCHLIST'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*    CLEAR ls_sl_button.
*    MOVE 'TEST' TO ls_sl_button-function.
*    MOVE ICON_READ_FILE TO ls_sl_button-icon.
*    MOVE text-015 TO ls_sl_button-quickinfo.
*    MOVE text-016 TO ls_sl_button-text.
*    MOVE ' ' TO ls_sl_button-disabled.
*    MOVE 2 TO ls_sl_button-butn_type.
*    APPEND ls_sl_button TO e_object->mt_toolbar.

    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CLEAR ls_sl_button.
    MOVE 'DELETE_SEARCH_ITEM' TO ls_sl_button-function.
    MOVE icon_delete TO ls_sl_button-icon.
    MOVE text-005 TO ls_sl_button-quickinfo.
    MOVE text-006 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*   Notiz DIS erzeugen
    CLEAR ls_sl_button.
    MOVE 'NOTE_DIR' TO ls_sl_button-function.
    MOVE icon_create_note TO ls_sl_button-icon.
    MOVE text-095 TO ls_sl_button-quickinfo.
    MOVE text-096 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*   globale Selektion setzen
    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*    CLEAR ls_sl_button.
*    MOVE 'SET_SEARCH_GL' TO ls_sl_button-function.
*    MOVE 1 TO ls_sl_button-butn_type.
*    MOVE icon_select_block TO ls_sl_button-icon.
*    MOVE text-097 TO ls_sl_button-quickinfo.
*    MOVE text-098 TO ls_sl_button-text.
*    MOVE ' ' TO ls_sl_button-disabled.
*    APPEND ls_sl_button TO e_object->mt_toolbar.

    DATA: lc_menu_sel TYPE REF TO cl_ctmenu.
    clear lc_menu_sel.
    CLEAR ls_sl_button.
    MOVE 'SET_SEARCH_GL' TO ls_sl_button-function.
    MOVE 1 TO ls_sl_button-butn_type.
    MOVE icon_select_block TO ls_sl_button-icon.
    MOVE text-097 TO ls_sl_button-quickinfo.
    MOVE text-098 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_sel.
    CALL METHOD lc_menu_sel->add_function
                EXPORTING fcode   = 'SET_SEARCH_GL'
                text    = text-097.

    CALL METHOD lc_menu_sel->add_function
                EXPORTING fcode   = 'READ_SEARCH_GL'
                text    = text-099.

    ls_menu-ctmenu = lc_menu_sel.
    ls_menu-function = 'SET_SEARCH_GL'.
    APPEND ls_menu TO e_object->mt_btnmnu.

  ENDMETHOD.

  METHOD handle_menu_button.
*    IF e_ucomm = 'OPTION'.
*      CALL METHOD e_object->add_function
*                  EXPORTING fcode   = 'ONLY_LAST_VERSION'
*                            text    = text-017.
*      CALL METHOD e_object->add_function
*                  EXPORTING fcode   = 'LAST_FREE_VERSION'
*                            text    = text-018.
*      CALL METHOD e_object->add_function
*                  EXPORTING fcode   = 'ONLY_FREE_VERSION'
*                            text    = text-019.
*    ENDIF.
  ENDMETHOD.


  METHOD handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'DELETE_SEARCH_ITEM'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DELETE_SEARCH_ITEM'
*      IMPORTING
*        RC       =
            .
      WHEN 'CV03N'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CV03N'
*      IMPORTING
*        RC       =
            .
      WHEN 'ONLY_LAST_VERSION'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ONLY_LAST_VERSION'
*      IMPORTING
*        RC       =
            .
      WHEN 'LAST_FREE_VERSION'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'LAST_FREE_VERSION'
*      IMPORTING
*        RC       =
            .
      WHEN 'ONLY_FREE_VERSION'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ONLY_FREE_VERSION'
*      IMPORTING
*        RC       =
            .

      WHEN 'ACTUAL_DIS'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ACTUAL_DIS'
*      IMPORTING
*        RC       =
            .
      WHEN 'ACTUAL_RELEASED_DIS'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ACTUAL_RELEASED_DIS'
*      IMPORTING
*        RC       =
            .


      WHEN 'ONLY_GOOD_MATERIAL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ONLY_GOOD_MATERIAL'
*      IMPORTING
*        RC       =
            .
      WHEN 'NO_DUPLICATES_SL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'NO_DUPLICATES_SL'
*      IMPORTING
*        RC       =
            .
      WHEN 'SAVE_SEARCHLIST'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'SAVE_SEARCHLIST'
*      IMPORTING
*        RC       =
            .
      WHEN 'OPEN_SEARCHLIST'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'OPEN_SEARCHLIST'
*      IMPORTING
*        RC       =
            .
      WHEN 'VIEW_ORIGINALS'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'VIEW_ORIGINALS'
*      IMPORTING
*        RC       =
            .
      WHEN 'FRONTTYP'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'FRONTTYP'
*      IMPORTING
*        RC       =
            .

      WHEN 'NOTE_DIR'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'NOTE_DIR'
*      IMPORTING
*        RC       =
            .

* SET_SEARCH_GL
      WHEN 'SET_SEARCH_GL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'SET_SEARCH_GL'
*      IMPORTING
*        RC       =
            .

*READ_SEARCH_GL
      WHEN 'READ_SEARCH_GL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'READ_SEARCH_GL'
*      IMPORTING
*        RC       =
            .

    ENDCASE.
  ENDMETHOD.

  METHOD handle_hotspot_click.
    index_itab_searchlist = e_row_id.
    READ TABLE itab_search INDEX index_itab_searchlist INTO
      wa_akt_search.

    "data: zeile type LVC_S_COL.

    CASE e_column_id-fieldname.
      WHEN 'ICON_DISPLAY'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'HOT_SPOT_CLICK_DISPLAY'
*      IMPORTING
*        RC       =
            .
      WHEN 'ICON_DISPLAY_DIS'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'HOT_SPOT_CLICK_DISPLAY_DIS'
*      IMPORTING
*        RC       =
            .
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD handle_selection.
*    break kuechler.
*    REFRESH itab_et_index_rows_searchlist.
*    CALL METHOD grid_searchlist->get_selected_rows
*      IMPORTING
*        et_index_rows = itab_et_index_rows_searchlist.
**      ET_ROW_NO     =
*    .
  ENDMETHOD.

ENDCLASS.
