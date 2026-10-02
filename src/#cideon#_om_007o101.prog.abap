*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_007O101                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* Änderungen:
*  12.05.2004 HAENSEL  Fortschrittsanzeige nur bei schneller Verbindung.
************************************************************************
MODULE status_0101 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  IF grid_searchlist IS INITIAL.

    CLEAR gs_layout_searchlist.
    gs_layout_searchlist-report = sy-repid.
    gs_layout_searchlist-username = sy-uname.

*   Layout setzen
    IF user_data-search_alv_var IS INITIAL.
    ELSE.
*      MOVE user_data-search_alv_var  TO gs_layout_searchlist-variant.
      gs_layout_searchlist-variant = user_data-search_alv_var.
*      gs_layout_searchlist-text = user_data-search_alv_var.

      CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
           EXPORTING
                i_save        = 'A'
           CHANGING
                cs_variant    = gs_layout_searchlist
           EXCEPTIONS
                wrong_input   = 1
                not_found     = 2
                program_error = 3
                OTHERS        = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    IF user_data-knz_alv_patch = 'X'.
      CLEAR gs_layout_searchlist-variant.
    ELSE.
    ENDIF.

    CREATE OBJECT container_grid_searchlist
      EXPORTING container_name = 'CONTAINER_GRID_SEARCHLIST'.
    IF sy-subrc <> 0.
    ENDIF.

*   Dockingcontainer benutzen
*   ref_sl_dock_container
    IF ref_sl_dock_container IS INITIAL.
      CREATE OBJECT ref_sl_dock_container
        EXPORTING
*        PARENT                      =
*        REPID                       =
         dynnr                       = '0110'
*        SIDE                        = DOCK_AT_LEFT
          extension                   = 300
*        STYLE                       =
*        LIFETIME                    = lifetime_default
         caption                     = 'Test'
*        METRIC                      = 0
*        RATIO                       =
*        NO_AUTODEF_PROGID_DYNNR     =
*        NAME                        =
*       EXCEPTIONS
*         CNTL_ERROR                  = 1
*        CNTL_SYSTEM_ERROR           = 2
*        CREATE_ERROR                = 3
*        LIFETIME_ERROR              = 4
*        LIFETIME_DYNPRO_DYNPRO_LINK = 5
*        others                      = 6
          .

      CALL METHOD ref_sl_dock_container->dock_at
        EXPORTING
          side              = cl_gui_docking_container=>dock_at_top
*      EXCEPTIONS
*        CNTL_ERROR        = 1
*        CNTL_SYSTEM_ERROR = 2
*        others            = 3
              .
    ELSE.
    ENDIF.

    CREATE OBJECT   grid_searchlist
      EXPORTING i_parent =
*      ref_sl_dock_container
      container_grid_searchlist
      .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*   fill the EXCLUDE-Table
    CLEAR itab_tb_ex_searchlist.
    REFRESH itab_tb_ex_searchlist.
    "CKR 2008/12/05
    DATA: ls_ex TYPE ui_func.
    CLEAR ls_ex.

    ls_ex = '&AUBTOT'.
    APPEND ls_ex TO itab_tb_ex_searchlist.

    ls_ex = '&AUF'.
    APPEND ls_ex TO itab_tb_ex_searchlist.

    ls_ex = '&INFO'.
    APPEND ls_ex TO itab_tb_ex_searchlist.

    ls_ex = '&MB_SUM'.
    APPEND ls_ex TO itab_tb_ex_searchlist.

    ls_ex = '&SUM'.
    APPEND ls_ex TO itab_tb_ex_searchlist.

    ls_ex = '&GRAPH'.
    APPEND ls_ex TO itab_tb_ex_searchlist.

                                                            " SP 127
    " 2010/06/16 CKR
    DATA: exit TYPE REF TO /cideon/if_ex_pre_main_001.

    CALL METHOD cl_exithandler=>get_instance
      CHANGING
        instance = exit.
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    IF exit IS INITIAL.
    ELSE.
      "
      CALL METHOD exit->chg_sl_excl_bt
         CHANGING
           it_bt_ex = itab_tb_ex_searchlist
          .

    ENDIF.



*    SELECT exclude_fc FROM zcl_plint_excalv
*      INTO TABLE itab_tb_ex_searchlist
*      WHERE uname = sy-uname
*      AND alvname = 'GRID_SEARCHLIST'
*      .
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.
*
*    IF itab_tb_ex_searchlist[] IS INITIAL.
*      SELECT exclude_fc FROM zcl_plint_excalv
*        INTO TABLE itab_tb_ex_searchlist
*        WHERE uname = default_data-default_nutzer
*        AND alvname = 'GRID_SEARCHLIST'
*        .
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
*    ELSE.
*    ENDIF.

    g_layo_grid_searchlist-sel_mode = 'A'.
    g_layo_grid_searchlist-excp_fname = 'KNZ_FREIGABE'.
    g_layo_grid_searchlist-excp_led = default_data-excp_led.

    CALL METHOD grid_searchlist->set_table_for_first_display
      EXPORTING
        i_structure_name              = 'ZCL_S_DOCSEARCH'
        is_variant                    = gs_layout_searchlist
        is_layout                     = g_layo_grid_searchlist
        i_save                        = x_save_searchlist
        i_default                     = 'X'
        it_toolbar_excluding          = itab_tb_ex_searchlist
      CHANGING
        it_outtab                     = itab_search
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD grid_searchlist->get_frontend_layout
      IMPORTING
        es_layout = g_layo_grid_searchlist
        .
    g_layo_grid_searchlist-sel_mode = 'A'.

    CALL METHOD grid_searchlist->set_frontend_layout
      EXPORTING
        is_layout = g_layo_grid_searchlist
        .
    CALL METHOD grid_searchlist->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

**   EventHandler erzeugen und setzen
*    clear wa_events.
**    wa_events-eventid = cl_gui_alv_grid=>eventid_double.
*    wa_events-appl_event = 'X'.
*    append wa_events to itab_events.

    CLEAR g_fc_grid_searchlist.
    CALL METHOD grid_searchlist->get_frontend_fieldcatalog
      IMPORTING
        et_fieldcatalog = g_fc_grid_searchlist
        .
    LOOP AT g_fc_grid_searchlist INTO wa_fc_grid_searchlist.
      IF wa_fc_grid_searchlist-fieldname = 'MAT_STATUS'.
        wa_fc_grid_searchlist-icon = 'X'.
        MODIFY g_fc_grid_searchlist FROM wa_fc_grid_searchlist
          INDEX sy-tabix.
      ELSE.
      ENDIF.

      IF wa_fc_grid_searchlist-fieldname = 'ICON_DISPLAY'.
        wa_fc_grid_searchlist-icon = 'X'.
        wa_fc_grid_searchlist-hotspot = 'X'.
        MODIFY g_fc_grid_searchlist FROM wa_fc_grid_searchlist
          INDEX sy-tabix.
      ELSE.
      ENDIF.

      IF wa_fc_grid_searchlist-fieldname = 'ICON_DISPLAY_DIS'.
        wa_fc_grid_searchlist-icon = 'X'.
        wa_fc_grid_searchlist-hotspot = 'X'.
        MODIFY g_fc_grid_searchlist FROM wa_fc_grid_searchlist
          INDEX sy-tabix.
      ELSE.
      ENDIF.

*     DIR_STAT_VERS / Anzeige existente Version siehe CDESK
      IF wa_fc_grid_searchlist-fieldname = 'DIR_STAT_VERS'.
        wa_fc_grid_searchlist-icon = 'X'.
        wa_fc_grid_searchlist-hotspot = ''.
        MODIFY g_fc_grid_searchlist FROM wa_fc_grid_searchlist
          INDEX sy-tabix.
      ELSE.
      ENDIF.

    ENDLOOP.
    CALL METHOD grid_searchlist->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = g_fc_grid_searchlist
        .
    CALL METHOD grid_searchlist->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    SET HANDLER
      search_handler->catch_dblclick FOR grid_searchlist.
    SET HANDLER
      search_handler->handle_toolbar FOR grid_searchlist.
    SET HANDLER
      search_handler->handle_menu_button FOR grid_searchlist.
    SET HANDLER
      search_handler->handle_user_command FOR grid_searchlist.
    SET HANDLER
      search_handler->handle_hotspot_click FOR grid_searchlist.

    CALL METHOD grid_searchlist->register_delayed_event
       EXPORTING
         i_event_id  =   cl_gui_alv_grid=>mc_evt_delayed_change_select
.


    SET HANDLER
    search_handler->handle_selection FOR grid_searchlist.




    CALL METHOD grid_searchlist->set_toolbar_interactive.

*   Fortschrittsanzeige nur bei schneller Verbindung
    IF gf_slow_connection IS INITIAL.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = '45'  " Balkenanzeige
                text       = text-011.
    ENDIF.

*   Selektion setzen bei Übernahme aus Bestellung etc.
    PERFORM set_ebeln_selection.

*   Setzen von Selektionen
    PERFORM set_selection.

*   Selektion merken
    PERFORM read_selection_search_gl.

  ELSE.

  ENDIF.
ENDMODULE.                 " STATUS_0101  OUTPUT
