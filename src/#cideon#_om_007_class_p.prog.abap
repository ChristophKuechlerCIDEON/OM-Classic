*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_007_CLASS_P                               *
*----------------------------------------------------------------------*


CLASS lcl_event_handler_alv_plot DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column,

    handle_toolbar:
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

    handle_context_menu
        FOR EVENT context_menu_request OF cl_gui_alv_grid
            IMPORTING e_object,

   handle_after_user_command
        FOR EVENT after_user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

    handle_hotspot_click FOR EVENT hotspot_click
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id

            .


ENDCLASS.                    "lcl_event_handler_alv_plot DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_alv_plot IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_alv_plot IMPLEMENTATION.

  METHOD catch_dblclick.
    index_itab_plotjobs = e_row.
*    clear wa_akt_plotjobs.
*    READ TABLE itab_plotjobs INDEX index_itab_plotjobs INTO
*      wa_akt_plotjobs.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DBLCLICK_PLOT'
*      IMPORTING
*        RC       =
        .
  ENDMETHOD.                    "catch_dblclick

  METHOD handle_toolbar.

    DATA: lc_menu    TYPE REF TO cl_ctmenu.
    DATA: ls_menu    TYPE stb_btnmnu.
    DATA: lc_menu_plot TYPE REF TO cl_ctmenu.
    DATA: lc_menu_ce TYPE REF TO cl_ctmenu.
    DATA: lc_menu_cs TYPE REF TO cl_ctmenu.

**   add an Separator
*    CLEAR searchlist_toolbar.
*    MOVE 3 TO searchlist_toolbar-butn_type.
*    APPEND searchlist_toolbar TO e_object->mt_toolbar.
*
*    CLEAR ls_pl_button.
*    MOVE 'FILTER_1' TO ls_pl_button-function.
*    MOVE icon_filter TO ls_pl_button-icon.
*    MOVE text-060 TO ls_pl_button-quickinfo.
*    MOVE text-061 TO ls_pl_button-text.
*    MOVE ' ' TO ls_pl_button-disabled.
*    APPEND ls_pl_button TO e_object->mt_toolbar.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.
*
*   Verteiler ändern
*   CHG_VERT
    CLEAR ls_pl_button.
    MOVE 'CHG_VERT' TO ls_pl_button-function.
    MOVE '@5Q@' TO ls_pl_button-icon.
    MOVE text-101 TO ls_pl_button-quickinfo.
    MOVE text-102 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    APPEND ls_pl_button TO e_object->mt_toolbar.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

    CLEAR ls_pl_button.
    MOVE 'VIEW_PL' TO ls_pl_button-function.
*    MOVE icon_inspection_method TO ls_pl_button-icon.
    MOVE icon_display TO ls_pl_button-icon.
    MOVE text-034 TO ls_pl_button-quickinfo.
    MOVE text-035 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    MOVE 1 TO ls_pl_button-butn_type.

    "MOVE 'CV03N_L' TO ls_pl_button-function.

    APPEND ls_pl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_plot.
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'CV03N_L'
        text  = text-037.
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'DOK_VIEW'
        text  = text-036.

    ls_menu-ctmenu = lc_menu_plot.
    ls_menu-function = 'VIEW_PL'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.


    CLEAR ls_pl_button.
    MOVE 'OPTION_PL' TO ls_pl_button-function.
    MOVE icon_read_file TO ls_pl_button-icon.
    MOVE text-031 TO ls_pl_button-quickinfo.
    MOVE text-032 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    MOVE 1 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_plot.
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'ONLY_CHECKED_IN'
        text  = text-033.

    CALL METHOD lc_menu_plot->add_separator.

    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'FILTER_1'
        text  = text-061.

    ls_menu-ctmenu = lc_menu_plot.
    ls_menu-function = 'OPTION_PL'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

*   Plotliste
    CLEAR ls_pl_button.
    MOVE 'PLOT' TO ls_pl_button-function.
    MOVE icon_icon_list TO ls_pl_button-icon.
    MOVE text-027 TO ls_pl_button-quickinfo.
    MOVE text-028 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.

    MOVE 1 TO ls_pl_button-butn_type.
    "ls_pl_button-function = 'OPEN_PLOTLIST'.

    APPEND ls_pl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_plot.
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'OPEN_PLOTLIST'
        text  = text-030.
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'SAVE_PLOTLIST'
        text  = text-029.
    ls_menu-ctmenu = lc_menu_plot.
    ls_menu-function = 'PLOT'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

*   Fehlblattliste
    CLEAR ls_pl_button.
    MOVE 'FB_LIST' TO ls_pl_button-function.
    MOVE icon_ben_termination TO ls_pl_button-icon.
    MOVE text-042 TO ls_pl_button-quickinfo.
    MOVE text-043 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    MOVE 1 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_plot.
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'SAVE_FB_LIST'
        text  = text-044.

    ls_menu-ctmenu = lc_menu_plot.
    ls_menu-function = 'FB_LIST'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

*   Eintrag Spezial
    CLEAR ls_pl_button.
    MOVE 'SPECIAL' TO ls_pl_button-function.
    MOVE icon_sap TO ls_pl_button-icon.
    MOVE text-047 TO ls_pl_button-quickinfo.
    MOVE text-048 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    MOVE 1 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_plot.
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'DWNL_LOCAL'
        text  = text-049.

    ls_menu-ctmenu = lc_menu_plot.
    ls_menu-function = 'SPECIAL'.
    APPEND ls_menu TO e_object->mt_btnmnu.

    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'DWNL_LOC_S'
        text  = text-103
               .

    ls_menu-ctmenu = lc_menu_plot.
    ls_menu-function = 'SPECIAL'.
    APPEND ls_menu TO e_object->mt_btnmnu.



    CALL METHOD lc_menu_plot->add_separator.

*   Konvertierungen
    "SAP Conversion Framework
    CREATE OBJECT lc_menu_cs.


    CALL METHOD lc_menu_cs->add_function
      EXPORTING
        fcode = 'STR_KONV'
        text  = text-055.

    CALL METHOD lc_menu_cs->add_function
      EXPORTING
        fcode = 'STR_ZKONV'
        text  = text-057.

    CALL METHOD lc_menu_cs->add_function
      EXPORTING
        fcode = 'STR_KONV1'
        text  = text-059.

    CALL METHOD lc_menu_cs->add_separator.

    CALL METHOD lc_menu_cs->add_function
      EXPORTING
        fcode = 'RFR_KONV'
        text  = text-056.

    CALL METHOD lc_menu_plot->add_submenu
      EXPORTING
        menu        =  lc_menu_cs
        text        = text-065
*            ICON        =
        disabled    = ''
        hidden      = ''
*            ACCELERATOR =
        .

    " CE Konvertierungen
    CREATE OBJECT lc_menu_ce.

    "STR_KONV_CE
    CALL METHOD lc_menu_ce->add_function
      EXPORTING
        fcode = 'STR_KONV_CE'
        text  = text-067.

    "STR_KONV_MAN_CE
    CALL METHOD lc_menu_ce->add_function
      EXPORTING
        fcode = 'STR_KONV_MAN_CE'
        text  = text-068.


    CALL METHOD lc_menu_ce->add_separator.

    CALL METHOD lc_menu_ce->add_function
      EXPORTING
        fcode = 'RFR_KONV'
        text  = text-056.

    CALL METHOD lc_menu_plot->add_submenu
      EXPORTING
        menu        =  lc_menu_ce
        text        =  text-066
*            ICON        =
        disabled    = ''
        hidden      = ''
*            ACCELERATOR =
        .





    CALL METHOD lc_menu_plot->add_separator.
*   cFolders
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'CFOLD'
        text  = text-062.

    CALL METHOD lc_menu_plot->add_separator.

**   Reihenfolge invertieren
*    clear ls_pl_button.
*    move 'INVERT_ORDER_PL' to ls_pl_button-function.
*    move icon_invert_line to ls_pl_button-icon.
*    move text-072 to ls_pl_button-quickinfo.
*    move text-073 to ls_pl_button-text.
*    move ' ' to ls_pl_button-disabled.
*    append ls_pl_button to e_object->mt_toolbar.
*
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'INVERT_ORDER_PL'
        text  = text-073.

**   SW_OP_MODE Operationsmodus umschalten
*    clear ls_pl_button.
*    move 'SW_OP_MODE' to ls_pl_button-function.
*    move icon_pdir_foreward_switch to ls_pl_button-icon.
*    move text-076 to ls_pl_button-quickinfo.
*    move text-078 to ls_pl_button-text.
*    move ' ' to ls_pl_button-disabled.
*    append ls_pl_button to e_object->mt_toolbar.

    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'SW_OP_MODE'
        text  = text-078.

    CALL METHOD lc_menu_plot->add_separator.
*   Zuordnung zu OM Ändern
    CALL METHOD lc_menu_plot->add_function
      EXPORTING
        fcode = 'LINK_OM'
        text  = text-079.






*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

*   Eigenschaften setzen
    MOVE 'CHANGE' TO ls_pl_button-function.
    MOVE icon_change TO ls_pl_button-icon.
    MOVE text-003 TO ls_pl_button-quickinfo.
    MOVE text-004 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    APPEND ls_pl_button TO e_object->mt_toolbar.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

*   Eintrag löschen
    CLEAR ls_pl_button.
    MOVE 'DELETE_PLOT_ITEM' TO ls_pl_button-function.
    MOVE icon_delete TO ls_pl_button-icon.
    MOVE text-001 TO ls_pl_button-quickinfo.
    MOVE text-002 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    APPEND ls_pl_button TO e_object->mt_toolbar.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

*   doppelte Einträge löschen
    CLEAR ls_pl_button.
    MOVE 'DELETE_DUBLICATES_PL' TO ls_pl_button-function.
    MOVE icon_delete TO ls_pl_button-icon.
    MOVE text-063 TO ls_pl_button-quickinfo.
    MOVE text-064 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    APPEND ls_pl_button TO e_object->mt_toolbar.

*   add an Separator
    CLEAR ls_pl_button.
    MOVE 3 TO ls_pl_button-butn_type.
    APPEND ls_pl_button TO e_object->mt_toolbar.
    CLEAR ls_pl_button.

**   Reihenfolge invertieren
*    clear ls_pl_button.
*    move 'INVERT_ORDER_PL' to ls_pl_button-function.
*    move icon_invert_line to ls_pl_button-icon.
*    move text-072 to ls_pl_button-quickinfo.
*    move text-073 to ls_pl_button-text.
*    move ' ' to ls_pl_button-disabled.
*    append ls_pl_button to e_object->mt_toolbar.
*
**   SW_OP_MODE Operationsmodus umschalten
*    clear ls_pl_button.
*    move 'SW_OP_MODE' to ls_pl_button-function.
*    move icon_pdir_foreward_switch to ls_pl_button-icon.
*    move text-076 to ls_pl_button-quickinfo.
*    move text-078 to ls_pl_button-text.
*    move ' ' to ls_pl_button-disabled.
*    append ls_pl_button to e_object->mt_toolbar.

*   Satzanzahl setzen
*   CHG_SATZ
    CLEAR ls_pl_button.
    MOVE 'CHG_SATZ' TO ls_pl_button-function.
    MOVE icon_stack TO ls_pl_button-icon.
    MOVE text-082 TO ls_pl_button-quickinfo.
    MOVE text-083 TO ls_pl_button-text.
    MOVE ' ' TO ls_pl_button-disabled.
    APPEND ls_pl_button TO e_object->mt_toolbar.
  ENDMETHOD.                    "handle_toolbar




* EVENT HANDLER
  METHOD handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.
    CASE e_ucomm.
      WHEN 'DOK_VIEW'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DOK_VIEW'.
      WHEN 'DELETE_PLOT_ITEM'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DELETE_PLOT_ITEM'.
      WHEN 'CHG_PRIO'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_PRIO'.

      WHEN 'CHG_SATZ'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_SATZ'.

      WHEN 'DEL_PL_ITM'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DELETE_PLOT_ITEM'.
      WHEN 'UP_PLOT'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'UP_PLOT'.
      WHEN 'DOWN_PLOT'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DOWN_PLOT'.
      WHEN 'COPY'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'COPY'.
      WHEN 'CUT'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CUT'.
      WHEN 'PASTE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'PASTE'.
      WHEN 'CHANGE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHANGE'.
      WHEN 'FILTER_1'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'FILTER_1'.
      WHEN 'CHG_VBELN'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_VBELN'.
      WHEN 'CHG_AUFNR'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_AUFNR'.
      WHEN 'CHG_VERT'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_VERT'.
      WHEN 'SAVE_PLOTLIST'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'SAVE_PLOTLIST'
*      IMPORTING
*        RC       =
            .
      WHEN 'OPEN_PLOTLIST'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'OPEN_PLOTLIST'
*      IMPORTING
*        RC       =
            .
      WHEN 'SAVE_FB_LIST'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'SAVE_FB_LIST'
*      IMPORTING
*        RC       =
            .
      WHEN 'ONLY_CHECKED_IN'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ONLY_CHECKED_IN'
*      IMPORTING
*        RC       =
            .
      WHEN 'CV03N_L'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CV03N_L'
*      IMPORTING
*        RC       =
            .
      WHEN 'SEND'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'SEND'
*      IMPORTING
*        RC       =
            .
      WHEN 'CHG_COPY'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_COPY'
*      IMPORTING
*        RC       =
            .
      WHEN 'CHG_NOTE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_NOTE'
*      IMPORTING
*        RC       =
            .
      WHEN 'DWNL_LOCAL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DWNL_LOCAL'
*      IMPORTING
*        RC       =
            .

        "DWNL_LOC_S
      WHEN 'DWNL_LOC_S'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DWNL_LOC_S'
*      IMPORTING
*        RC       =
            .


      WHEN 'AO_MERGE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'AO_MERGE'
*      IMPORTING
*        RC       =
            .

*     Spezial / Konvertierungen
      WHEN 'STR_KONV'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'STR_KONV'
*      IMPORTING
*        RC       =
            .
      WHEN 'STR_ZKONV'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'STR_ZKONV'
*      IMPORTING
*        RC       =
            .
      WHEN 'RFR_KONV'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'RFR_KONV'
*      IMPORTING
*        RC       =
            .

      WHEN 'STR_KONV1'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'STR_KONV1'
*      IMPORTING
*        RC       =
            .

        "CE Konvertierungen
        "STR_KONV_CE
      WHEN 'STR_KONV_CE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'STR_KONV_CE'
*      IMPORTING
*        RC       =
            .
        " STR_KONV_MAN_CE
      WHEN 'STR_KONV_MAN_CE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'STR_KONV_MAN_CE'
*      IMPORTING
*        RC       =
            .


* cFolders
      WHEN 'CFOLD'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CFOLD'
*      IMPORTING
*        RC       =
            .
* OM Zuordnung ändern
* LINK_OM
      WHEN 'LINK_OM'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'LINK_OM'
*      IMPORTING
*        RC       =
            .


*     Lieferanten
      WHEN 'CHG_EBELN'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_EBELN'
*      IMPORTING
*        RC       =
            .

      WHEN 'CHG_VENDOR'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_VENDOR'
*      IMPORTING
*        RC       =
            .

      WHEN 'CHG_V_TEL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_V_TEL '
*      IMPORTING
*        RC       =
            .

      WHEN 'CHG_V_FAX'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_V_FAX'
*      IMPORTING
*        RC       =
            .

      WHEN 'CHG_V_EMAI'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'CHG_V_EMAI'
*      IMPORTING
*        RC       =
            .

*     TOC
      WHEN 'TOC_CREATE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'TOC_CREATE'
*      IMPORTING
*        RC       =
            .
      WHEN 'TOC_SEND'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'TOC_SEND'
*      IMPORTING
*        RC       =
            .
      WHEN 'TOC_N_CREA'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'TOC_N_CREA'
*      IMPORTING
*        RC       =
            .
      WHEN 'TOC_N_SEND'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'TOC_N_SEND'
*      IMPORTING
*        RC       =
            .

        "
      WHEN 'DELETE_DUBLICATES_PL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DELETE_DUBLICATES_PL'
*      IMPORTING
*        RC       =
            .

*    INVERT_ORDER_PL
      WHEN 'INVERT_ORDER_PL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'INVERT_ORDER_PL'
*      IMPORTING
*        RC       =
            .

*   SW_OP_MODE Operationsmodus umschalten
      WHEN 'SW_OP_MODE'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'SW_OP_MODE'
*      IMPORTING
*        RC       =
            .

**   CHG_SATZ
**   Satzanzahl ändern
*      when 'CHG_SATZ'.
*        call method cl_gui_cfw=>set_new_ok_code
*          exporting
*            new_code = 'CHG_SATZ'
**      IMPORTING
**        RC       =
*            .

* CHG_VERT
* Verteiler ändern

*      when 'CHG_VERT'.
*        call method cl_gui_cfw=>set_new_ok_code
*          exporting
*            new_code = 'CHG_VERT'
**      IMPORTING
**        RC       =
*            .

    ENDCASE.
  ENDMETHOD.                    "handle_user_command


* Context Menu Handler
  METHOD handle_context_menu.

    IF menu_plotlist IS INITIAL.
      CREATE OBJECT menu_plotlist.
    ENDIF.
    CALL METHOD menu_plotlist->load_gui_status
    EXPORTING
      program    = g_repid
      status     = 'ZCL_CTMENU_PLOTLIST'
*        DISABLE    =
      menu       = e_object
    EXCEPTIONS
      read_error = 1
      OTHERS     = 2
          .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    IF f_paste IS INITIAL.
      REFRESH l_disable.
      APPEND 'PASTE' TO l_disable.
      CALL METHOD menu_plotlist->disable_functions
        EXPORTING
          fcodes = l_disable.
      IF sy-subrc NE 0.
      ENDIF.
    ELSE.
      REFRESH l_disable.
      APPEND 'PASTE' TO l_disable.
      CALL METHOD menu_plotlist->enable_functions
        EXPORTING
          fcodes = l_disable.
    ENDIF.

  ENDMETHOD.                    "handle_context_menu

  METHOD handle_after_user_command.
    CASE e_ucomm.
      WHEN '&SORT_ASC' OR '&SORT_DSC'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'REFRESH'.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "handle_after_user_command

  METHOD handle_hotspot_click.
*    index_itab_searchlist = e_row_id.
*    READ TABLE itab_search INDEX index_itab_searchlist INTO
*      wa_akt_search.
*
*    "data: zeile type LVC_S_COL.
*
    CASE e_column_id-fieldname.
      WHEN 'ICON_DISPLAY'.
        index_itab_plotjobs = e_row_id.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'HOT_SPOT_CLICK_DISPLAY_PL'
*      IMPORTING
*        RC       =
            .
      WHEN 'ICON_DISPLAY_DIS'.
        index_itab_plotjobs = e_row_id.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'HOT_SPOT_CLICK_DISPLAY_DIS_PL'
*      IMPORTING
*        RC       =
            .
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.                    "handle_hotspot_click

ENDCLASS.                    "lcl_event_handler_alv_plot IMPLEMENTATION
