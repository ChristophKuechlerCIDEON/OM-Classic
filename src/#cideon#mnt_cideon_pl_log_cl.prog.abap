*----------------------------------------------------------------------*
*   INCLUDE ZCK_MAINT_ZCL_GRP_CLASS_KL_CL                              *
*----------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: on_double_click FOR EVENT double_click
                                   OF cl_gui_alv_grid
                   IMPORTING e_row,

    handle_toolbar:
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,


    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm
.

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
      CLEAR wa_save_neccessary.
      CLEAR sy-datar.
*      CLEAR ZCL_PLINT_CFG_00.
      wa_edit_mode = co_show_mode.
      READ TABLE it INTO wa INDEX e_row-index.
      index = e_row-index.
*      ZCL_PLINT_CFG_00 = wa.

      "zusätzliche Einträge holen
      CLEAR wa2.
      SELECT SINGLE * FROM /cideon/pl_log2 INTO wa2
        WHERE id = wa-id
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = 'DBLCLICK'.
    ENDIF.
  ENDMETHOD.

  METHOD handle_toolbar.

    DATA: lc_menu    TYPE REF TO cl_ctmenu.
    DATA: ls_menu    TYPE stb_btnmnu.

    CLEAR log_toolbar.
    MOVE 3 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.


    DATA: lc_menu_view TYPE REF TO cl_ctmenu.
    CLEAR log_toolbar.
    MOVE 'DUN1' TO log_toolbar-function.
    MOVE icon_create TO log_toolbar-icon.
    MOVE text-034 TO log_toolbar-quickinfo.
    MOVE text-035 TO log_toolbar-text.
    MOVE ' ' TO log_toolbar-disabled.
    "MOVE 4 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

*    CREATE OBJECT lc_menu_view.
*    CALL METHOD lc_menu_view->add_function
*                EXPORTING fcode   = 'CV03N'
*                text    = text-008.
*    CALL METHOD lc_menu_view->add_function
*                EXPORTING fcode   = 'VIEW_ORIGINALS'
*                          text    = text-039.
*    CALL METHOD lc_menu_view->add_separator.
*    CALL METHOD lc_menu_view->add_function
*                EXPORTING fcode   = 'FRONTTYP'
*                          text    = text-041.
*    ls_menu-ctmenu = lc_menu_view.
*    ls_menu-function = 'VIEW'.
*    APPEND ls_menu TO e_object->mt_btnmnu.

*   Separator
    CLEAR log_toolbar.
    MOVE 3 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

*   REC_TODAY
    CLEAR log_toolbar.
    MOVE 'REC_TODAY_JOB' TO log_toolbar-function.
    MOVE icon_ws_confirm_whse_proc_back TO log_toolbar-icon.
    MOVE text-036 TO log_toolbar-quickinfo.
    MOVE text-037 TO log_toolbar-text.
    MOVE ' ' TO log_toolbar-disabled.
    MOVE 1 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_view.
    CALL METHOD lc_menu_view->add_function
                EXPORTING fcode   = 'REC_TODAY_JOB'
                text    = text-050.
    CALL METHOD lc_menu_view->add_function
                EXPORTING fcode   = 'REC_TODAY'
                text    = text-037.
*    CALL METHOD lc_menu_view->add_separator.
*    CALL METHOD lc_menu_view->add_function
*                EXPORTING fcode   = 'FRONTTYP'
*                          text    = text-041.
    ls_menu-ctmenu = lc_menu_view.
    ls_menu-function = 'REC_TODAY_JOB'.
    APPEND ls_menu TO e_object->mt_btnmnu.



*   REC_DATE
    CLEAR log_toolbar.
    MOVE 'REC_DATE_JOB' TO log_toolbar-function.
    MOVE icon_ws_confirm_whse_proc_fore TO log_toolbar-icon.
    MOVE text-038 TO log_toolbar-quickinfo.
    MOVE text-039 TO log_toolbar-text.
    MOVE ' ' TO log_toolbar-disabled.
    MOVE 1 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

    DATA: lc_menu_rec_date TYPE REF TO cl_ctmenu.

    CREATE OBJECT lc_menu_rec_date.
    CALL METHOD lc_menu_rec_date->add_function
                EXPORTING fcode   = 'REC_DATE_JOB'
                text    = text-052.
    CALL METHOD lc_menu_rec_date->add_function
                EXPORTING fcode   = 'REC_DATE'
                text    = text-039.

    ls_menu-ctmenu = lc_menu_rec_date.
    ls_menu-function = 'REC_DATE_JOB'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*   Separator
    CLEAR log_toolbar.
    MOVE 3 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

*   DUE_TODAY
    CLEAR log_toolbar.
    MOVE 'DUE_TODAY' TO log_toolbar-function.
    MOVE icon_ws_start_whse_proc_backgr TO log_toolbar-icon.
    MOVE text-040 TO log_toolbar-quickinfo.
    MOVE text-041 TO log_toolbar-text.
    MOVE ' ' TO log_toolbar-disabled.
    "MOVE 4 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

*   DUE_DATE
    CLEAR log_toolbar.
    MOVE 'DUE_DATE' TO log_toolbar-function.
    MOVE icon_ws_start_whse_proc_foregr TO log_toolbar-icon.
    MOVE text-042 TO log_toolbar-quickinfo.
    MOVE text-043 TO log_toolbar-text.
    MOVE ' ' TO log_toolbar-disabled.
    "MOVE 4 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

*   Separator
    CLEAR log_toolbar.
    MOVE 3 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

*   erneutes Starten aus dem LOG
    CLEAR log_toolbar.
    MOVE 'RESTART_FILE' TO log_toolbar-function.
    MOVE icon_print TO log_toolbar-icon.
    MOVE text-048 TO log_toolbar-quickinfo.
    MOVE text-049 TO log_toolbar-text.
    MOVE ' ' TO log_toolbar-disabled.
    MOVE 1 TO log_toolbar-butn_type.
    APPEND log_toolbar TO e_object->mt_toolbar.

    DATA: lc_menu_restart TYPE REF TO cl_ctmenu.

    CREATE OBJECT lc_menu_restart.
    CALL METHOD lc_menu_restart->add_function
                EXPORTING fcode   = 'RESTART_JOB_OCC'
                text    = text-055.
    CALL METHOD lc_menu_restart->add_function
                EXPORTING fcode   = 'RESTART_FILE_OCC'
                text    = text-054.
    CALL METHOD lc_menu_restart->add_function
                  EXPORTING fcode   = 'RESTART_JOB'
                  text    = text-053.




    ls_menu-ctmenu = lc_menu_restart.
    ls_menu-function = 'RESTART_FILE'.
    APPEND ls_menu TO e_object->mt_btnmnu.

  ENDMETHOD.




  METHOD handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'REC_TODAY_JOB'.
        f_whole_job = '1'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'REC_TODAY'
*      IMPORTING
*        RC       =
            .

      WHEN 'REC_DATE_JOB'.
        f_whole_job = '1'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'REC_DATE'
*      IMPORTING
*        RC       =
            .

      WHEN 'DUN1'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DUN1'
*      IMPORTING
*        RC       =
            .

      WHEN 'REC_TODAY'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'REC_TODAY'
*      IMPORTING
*        RC       =
            .

      WHEN 'REC_DATE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'REC_DATE'
*      IMPORTING
*        RC       =
            .

      WHEN 'DUE_TODAY'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DUE_TODAY'
*      IMPORTING
*        RC       =
            .

      WHEN 'DUE_DATE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DUE_DATE'
*      IMPORTING
*        RC       =
            .

*RESTART
      WHEN 'RESTART_FILE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'RESTART_FILE'
*      IMPORTING
*        RC       =
            .

      WHEN 'RESTART_JOB'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'RESTART_JOB'
*      IMPORTING
*        RC       =
            .

      WHEN 'RESTART_FILE_OCC'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'RESTART_FILE_OCC'
*      IMPORTING
*        RC       =
            .

      WHEN 'RESTART_JOB_OCC'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'RESTART_JOB_OCC'
*      IMPORTING
*        RC       =
            .



    ENDCASE.
  ENDMETHOD.

ENDCLASS.
