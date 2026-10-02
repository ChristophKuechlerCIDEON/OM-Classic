*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/PLOT_ADMIN_TOOL000_PBO                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100' WITH anzahl_jobs anzahl_items.

  IF alv_plotjobs IS INITIAL.
*   ALV  erstellen
    CREATE OBJECT   alv_plotjobs
      EXPORTING i_parent = custom_control_alv
      .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR gs_layout_alv_plotjobs.
    gs_layout_alv_plotjobs-report = sy-repid.
    gs_layout_alv_plotjobs-username = sy-uname.


    IF user_data-admin_alv_var IS INITIAL.
    ELSE.
      gs_layout_alv_plotjobs-variant = user_data-admin_alv_var.

      CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
           EXPORTING
                i_save        = 'A'
           CHANGING
                cs_variant    = gs_layout_alv_plotjobs
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
      CLEAR gs_layout_alv_plotjobs-variant.
    ELSE.
    ENDIF.

    g_layo_alv_plotjobs-sel_mode = 'A'.
    g_layo_alv_plotjobs-excp_fname = 'LIGHT'.
    g_layo_alv_plotjobs-excp_led = default_data-excp_led.

    CALL METHOD alv_plotjobs->set_ready_for_input
          EXPORTING i_ready_for_input = 0.

*excluding toolbar-buttons for grid alv_plotjobs
*excl. appending and inserting new rows
    PERFORM set_grid_toolbar CHANGING itab_tb_ex_searchlist.

    CALL METHOD alv_plotjobs->set_table_for_first_display
      EXPORTING
        i_structure_name              = '/CIDEON/_S_ADM_01'
      "'/CIDEON/V_ADM_01'
        is_variant                    = gs_layout_alv_plotjobs
        is_layout                     = g_layo_alv_plotjobs
        i_save                        = x_save_alv_plotjobs
        i_default                     = 'X'
        it_toolbar_excluding          = itab_tb_ex_searchlist
      CHANGING
        it_outtab                     = itab_v_adm_01
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

*register ENTER to raise event DATA_CHANGED.

    CALL METHOD alv_plotjobs->register_edit_event
                EXPORTING
                   i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CREATE OBJECT g_event_receiver.
    SET HANDLER g_event_receiver->handle_data_changed FOR alv_plotjobs.


    CALL METHOD alv_plotjobs->get_frontend_layout
      IMPORTING
        es_layout = g_layo_alv_plotjobs
        .
    g_layo_alv_plotjobs-sel_mode = 'A'.

    CALL METHOD alv_plotjobs->set_frontend_layout
      EXPORTING
        is_layout = g_layo_alv_plotjobs
        .
    CALL METHOD alv_plotjobs->refresh_table_display
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

    CLEAR g_fc_grid_plotjobs.
    CALL METHOD alv_plotjobs->get_frontend_fieldcatalog
      IMPORTING
        et_fieldcatalog = g_fc_grid_plotjobs
        .

    LOOP AT g_fc_grid_plotjobs INTO wa_fc_grid_plotjobs.
      CASE wa_fc_grid_plotjobs-fieldname.
        WHEN 'ICON_DISPLAY_DIS'.
          wa_fc_grid_plotjobs-icon = 'X'.
          wa_fc_grid_plotjobs-hotspot = 'X'.

        WHEN 'ICON_DISPLAY'.
          wa_fc_grid_plotjobs-icon = 'X'.
          wa_fc_grid_plotjobs-hotspot = 'X'.

        WHEN 'KOPIEN'.
          wa_fc_grid_plotjobs-edit = 'X'.

        WHEN 'SATZANZAHL'.
          wa_fc_grid_plotjobs-edit = 'X'.

        WHEN 'PARA1'.
          wa_fc_grid_plotjobs-edit = 'X'.
        WHEN 'PARA2'.
          wa_fc_grid_plotjobs-edit = 'X'.
        WHEN 'PARA3'.
          wa_fc_grid_plotjobs-edit = 'X'.
        WHEN 'PARA4'.
          wa_fc_grid_plotjobs-edit = 'X'.
        WHEN 'PARA5'.
          wa_fc_grid_plotjobs-edit = 'X'.
        WHEN 'PARA6'.
          wa_fc_grid_plotjobs-edit = 'X'.
        WHEN 'PARA7'.
          wa_fc_grid_plotjobs-edit = 'X'.
        WHEN 'PARA8'.
          wa_fc_grid_plotjobs-edit = 'X'.
      ENDCASE.

      MODIFY g_fc_grid_plotjobs FROM wa_fc_grid_plotjobs
        INDEX sy-tabix.

    ENDLOOP.

    CALL METHOD alv_plotjobs->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = g_fc_grid_plotjobs
        .



    CALL METHOD alv_plotjobs->refresh_table_display
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
      alv_plot_handler->catch_dblclick FOR alv_plotjobs.
    SET HANDLER
      alv_plot_handler->handle_toolbar FOR alv_plotjobs.
    SET HANDLER
      alv_plot_handler->handle_menu_button FOR alv_plotjobs.
    SET HANDLER
      alv_plot_handler->handle_user_command FOR alv_plotjobs.
    SET HANDLER
      alv_plot_handler->handle_hotspot_click FOR alv_plotjobs.

    CALL METHOD alv_plotjobs->set_toolbar_interactive.



  ELSE.
  ENDIF.

ENDMODULE.                             " STATUS_0100  OUTPUT
