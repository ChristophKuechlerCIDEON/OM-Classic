*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_001O01                                    *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* Änderungen:
*  12.05.2004 HAENSEL  Fortschrittsanzeige nur bei schneller Verbindung.
************************************************************************
MODULE status_0100 OUTPUT.
* aktuell selektierte Werte anzeigen
*  perform read_akt_line_search.

  break_point.                                             "#EC NOBREAK

  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* get INI Values for User
  IF init <> 'X'.
* Berechtigungscheck
    AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '16'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc > 0.
      MESSAGE s099(zcl_plint_tools)
        WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
      LEAVE PROGRAM.
    ELSE.
    ENDIF.

    "clear itab_search.

*   g_dms_max_tmp_files lesen
    PERFORM add_client_data_4.

    CLEAR g_optionen.

*   Lesen, ob BYPASS aktiviert / automatischer Durchlauf.
    CLEAR f_bypass.
    GET PARAMETER ID 'Z_PL_BYPASS' FIELD f_bypass.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
    IF f_bypass = 'X'.
    ELSE.
    ENDIF.

*   BYPASS bis Plotliste
    CLEAR f_bypass_to_plotlist.
    GET PARAMETER ID '/CIDEON/OM_BYPASS_PL' FIELD f_bypass_to_plotlist.
    SET PARAMETER ID '/CIDEON/OM_BYPASS_PL' FIELD ''.

    PERFORM set_data_version_info.
    PERFORM check_date.
    PERFORM check_version_type.
    PERFORM get_user_dependend_functions.

*   Vermessung
    PERFORM vermessung.


*   Fortschrittsanzeige nur bei schneller Verbindung
    IF gf_slow_connection IS INITIAL.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = '15'  " Balkenanzeige
                text       = text-011.
    ENDIF.

*   Konfigurationen lesen
    PERFORM get_default_values.
    PERFORM get_user_values.
    PERFORM get_default_verteiler.
    PERFORM proc_mat_status_exc.

*   Satzanzahl holen
    CLEAR count_satz_c.
    GET PARAMETER ID '/CIDEON/OM_SET' FIELD count_satz_c.
    SET PARAMETER ID '/CIDEON/OM_SET' FIELD ''.
    IF count_satz_c IS INITIAL OR count_satz_c = '0'.
      count_satz_c = user_data-default_satzanzahl.
    ELSE.
    ENDIF.


*   Fortschrittsanzeige nur bei schneller Verbindung
    IF gf_slow_connection IS INITIAL.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = '30'  " Balkenanzeige
                text       = text-011.
    ENDIF.

*   Anmeldung an einem SMB Share
    IF user_data-knz_anmeldung_am_server = 'X'.
      CALL FUNCTION '/CIDEON/ANMELDUNG_AN_SERVER'
           EXPORTING
                i_anmeldestring_server = user_data-anmeldestring_server
                i_anmeldestring_server_voher
                  = user_data-anmeldestring_server_vorher
                i_anmeldestring_server_nachher
                  = user_data-anmeldestring_server_nachher
           EXCEPTIONS
                error                  = 1
                OTHERS                 = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ELSE.
    ENDIF.


*   Lösche nicht mehr benötigte Dateien in den Download Verzeichnissen
*    SUBMIT zcl_batch_clf_down_file_delete AND RETURN.
    PERFORM del_down_files.

*   Lese Such-Queue
    "PERFORM read_stored_search.
    break_point.                                           "#EC NOBREAK
    PERFORM read_stored_search_2.
    PERFORM get_dates_ecn.

*   Bereinigung der Dokumente, für Delta_Update -Lieferant
*   bei gefüllter EBELN / Vergleich mit Plot LOG
*   Selektion wird nach Erstellen des Search Grid vorgenommen
*   falls dies gewünscht ist
    PERFORM delta_update.

*   holen von Kommunikationsdaten für die EBELN / Lieferanten
*   -anbindung
    PERFORM get_lieferanten_daten.

    IF itab_search[] IS INITIAL.
    ELSE.
      "PERFORM get_dok_text.
      "PERFORM get_matnr.
      "PERFORM make_knz_freigabe_led.
      "PERFORM make_mat_status_icon.
      "PERFORM make_display_icon.

      PERFORM get_dok_text_2.
      PERFORM get_matnr_2.

      PERFORM get_dokst.
      PERFORM get_stabk.

      PERFORM make_knz_freigabe_led_2.
      PERFORM make_mat_status_icon_2.
      PERFORM make_display_icon_2.

      PERFORM make_display_version.


*     Bereinigung, um Dokumente, die nicht geplottet werden sollen
*     Fortschrittsanzeige nur bei schneller Verbindung
      IF gf_slow_connection IS INITIAL.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
             EXPORTING
                  percentage = '45'  " Balkenanzeige
                  text       = text-012.
      ENDIF.
*      PERFORM clean_up_documents.

      "Einbau des ADD_CUSTOMER_FIELDS_SEARCHLIST
      "
      IF badi_main_pre_001 IS INITIAL.
      ELSE.
*    CALL METHOD badi_main_pre_001->chg_dialog_cv04n
*      CHANGING
*        f_skip  = f_skip
*        lt_draw = itab_draw
*        .
        CALL METHOD badi_main_pre_001->add_customer_fields_searchlist
           CHANGING
             lt_searchlist = itab_search
            .
      ENDIF.
    ENDIF.

*   setze Dynpro für Einzelanzeige und Strukturanzeige
    IF user_data-knz_view_draw_detail = 'X'.
      g_show_draw_detail = 'X'.
      g_search_list_dynpro = c_draw_detail_dynpro.
    ELSE.
      CLEAR g_show_draw_detail.
      g_search_list_dynpro = c_draw_no_detail_dynpro.
    ENDIF.

    IF user_data-knz_view_struc_plotlist = 'X'.
      g_show_struktur = 'X'.
      g_plot_list_dynpro = c_plot_struktur_dynpro.
      f_tree_plotlist ='X'.
    ELSE.
      CLEAR g_show_struktur.
      g_plot_list_dynpro = c_plot_no_struktur_dynpro.
    ENDIF.

  ELSE.
  ENDIF.

  CLEAR wa_old_plotjobs.
  wa_old_plotjobs = wa_akt_plotjobs.

  MOVE-CORRESPONDING wa_akt_search TO draw.
  MOVE-CORRESPONDING wa_akt_search TO drat.

*  SET PF-STATUS '/CIDEON/_007_01'.
  IF user_data-modus = 'NORMAL'.
    SET PF-STATUS '/CIDEON/_007_01_N'.
  ELSE.
    SET PF-STATUS '/CIDEON/_007_01'.
  ENDIF.

* check auf DIS, welche für Nutzer nicht erlaubt sind
*  PERFORM check_for_not_allowed_dis.

* TITLEBAR :
* 'AutoORG PreProcessor für SAP/ &  Suchliste &  Plotliste  & &'
  CLEAR titlebar.

  DESCRIBE TABLE itab_search LINES count_search.
  DESCRIBE TABLE itab_plotjobs LINES count_plot.
*  SET TITLEBAR 'ZCL_PLINT_DESIGN_007'
*    WITH count_search count_plot '' ''.

  CLEAR count_search_c.
  count_search_c = count_search.
  CLEAR count_plot_c.
  count_plot_c = count_plot.

  SELECT COUNT( * ) FROM zcl_psb_tmp
    INTO count_queue
    WHERE
    uname = sy-uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
  CLEAR count_queue_c.
  count_queue_c = count_queue.

  "Einbau Satzanzahl
  "clear count_satz_c.
  IF count_satz_c IS INITIAL OR count_satz_c = 0.
    count_satz_c = 1.
  ELSE.
  ENDIF.

  CONCATENATE text-pre count_search_c text-sli count_plot_c text-pli
    count_queue_c text-que count_satz_c text-stz
    INTO titlebar SEPARATED BY space.
  SET TITLEBAR 'ZCL_PLINT_DESIGN_007'
    WITH titlebar.


* Meldung für Audit Trail, ob noch nicht bestätigte Ausgaben vorhanden
* sind
* nicht bei BYPASS
  IF f_bypass = 'X'.
  ELSE.
    IF user_data-knz_audit_trail = 'X'
      AND NOT f_audit_trail_confirm_no = 'X' .
*     Daten recherchieren für Nutzer
      CALL FUNCTION '/CIDEON/CHECK_ITEM_TO_CONFIRM'
           EXPORTING
                i_uname = sy-uname
           EXCEPTIONS
                error   = 1
                exit    = 2
                OTHERS  = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        CASE sy-subrc.
          WHEN '2'.
            f_audit_trail_confirm_no = 'X'.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ELSE.
    ENDIF.
  ENDIF.

* Funktionen ausblenden
* BADI
* /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND


* checks, what the active Tab is then choose the Status
  CASE tabstripcontrol_001-activetab.
    WHEN 'TAB1'.
      IF user_data-modus = 'NORMAL'.
        SET PF-STATUS '/CIDEON/_007_01_N'.

        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->status_change
            EXPORTING
              status = '/CIDEON/_007_01_N'
              .
        ENDIF.

      ELSE.
        SET PF-STATUS '/CIDEON/_007_01'.

        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->status_change
            EXPORTING
              status = '/CIDEON/_007_01'
              .
        ENDIF.

      ENDIF.
    WHEN 'TAB2'.
      IF user_data-modus = 'NORMAL'.
        SET PF-STATUS 'ZCL_PF_PLD_007_02_N'.

        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->status_change
            EXPORTING
              status = 'ZCL_PF_PLD_007_02_N'
              .
        ENDIF.

      ELSE.
        SET PF-STATUS 'ZCL_PF_PLD_007_02'.

        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->status_change
            EXPORTING
              status = 'ZCL_PF_PLD_007_02'
              .
        ENDIF.

      ENDIF.
    WHEN OTHERS.
      IF user_data-modus = 'NORMAL'.
        SET PF-STATUS '/CIDEON/_007_01_N'.

        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->status_change
            EXPORTING
              status = '/CIDEON/_007_01_N'
              .
        ENDIF.

      ELSE.
        SET PF-STATUS '/CIDEON/_007_01'.

        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->status_change
            EXPORTING
              status = '/CIDEON/_007_01'
              .
        ENDIF.

      ENDIF.

  ENDCASE.







ENDMODULE.                 " STATUS_0100  OUTPUT




*&---------------------------------------------------------------------*
*&      Module  STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
* für CLF Modus nicht benötigt TABS ausschalten
  IF user_data-knz_use_post = 'X'.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group3 = 'POS'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF simple_tree_plotlist IS INITIAL.
    IF f_tree_plotlist = 'X'.
      PERFORM create_and_init_tree.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

*Plotlist
  IF grid_plotlist IS INITIAL.
    IF f_alv_plotlist = 'X'.
    ELSE.
      EXIT.
    ENDIF.
*   for Design    PERFORM fill_itab_joblist.


    PERFORM create_and_init_plotlist.


*    CLEAR g_layo_grid_plotlist.
*    CLEAR gs_layout_plotlist.
*    gs_layout_plotlist-report = sy-repid.
*
*    IF user_data-plot_alv_var IS INITIAL.
*    ELSE.
*      MOVE user_data-plot_alv_var  TO gs_layout_plotlist-variant.
*      MOVE sy-repid TO gs_layout_plotlist-report.
*
*      CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
*           EXPORTING
*                i_save        = 'X'
*           CHANGING
*                cs_variant    = gs_layout_plotlist
*           EXCEPTIONS
*                wrong_input   = 1
*                not_found     = 2
*                program_error = 3
*                OTHERS        = 4.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
*                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*    ENDIF.
*
*
*    IF user_data-knz_alv_patch = 'X'.
*      CLEAR gs_layout_plotlist-variant.
*    ELSE.
*    ENDIF.
*
*
*    CREATE OBJECT container_grid_plotlist
*      EXPORTING container_name = 'CONTAINER_GRID_PLOTLIST'.
*
**   fill the EXCLUDE-Table
*    CLEAR itab_tb_ex_plotlist.
*    REFRESH itab_tb_ex_plotlist.
*    SELECT exclude_fc FROM zcl_plint_excalv
*      INTO TABLE itab_tb_ex_plotlist
*      WHERE uname = sy-uname
*      AND alvname = 'GRID_PLOTLIST'
*      .
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.
*
*    IF itab_tb_ex_plotlist[] IS INITIAL.
*      SELECT exclude_fc FROM zcl_plint_excalv
*        INTO TABLE itab_tb_ex_plotlist
*        WHERE uname = default_data-default_nutzer
*        AND alvname = 'GRID_PLOTLIST'
*        .
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
*    ELSE.
*    ENDIF.
*
*    CREATE OBJECT   grid_plotlist
*      EXPORTING i_parent = container_grid_plotlist.
*
*    g_layo_grid_plotlist-sel_mode = 'A'.
*    g_layo_grid_plotlist-excp_fname = 'LIGHT'.
*    g_layo_grid_plotlist-excp_led = 'X'.
*
*
*    CALL METHOD grid_plotlist->set_table_for_first_display
*      EXPORTING
*        i_structure_name              = 'ZCL_S_PLOTLIST'
**        i_structure_name              = 'ZORI_DOC_FILES'
*        is_variant                    = gs_layout_plotlist
*        i_save                        = x_save_plotlist
*        i_default                     = ''
*        is_layout                     = g_layo_grid_plotlist
*        it_toolbar_excluding          = itab_tb_ex_plotlist
*      CHANGING
*        it_outtab                     = itab_plotjobs
*      EXCEPTIONS
*        invalid_parameter_combination = 1
*        program_error                 = 2
*        too_many_lines                = 3
*        OTHERS                        = 4
*            .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*
*    CLEAR g_fc_grid_plotlist.
*    CALL METHOD grid_plotlist->get_frontend_fieldcatalog
*      IMPORTING
*        et_fieldcatalog = g_fc_grid_plotlist
*        .
*    LOOP AT g_fc_grid_plotlist INTO wa_fc_grid_plotlist.
*      IF wa_fc_grid_plotlist-fieldname = 'ICON_FEHLBLATT'.
*        wa_fc_grid_plotlist-icon = 'X'.
*        MODIFY g_fc_grid_plotlist FROM wa_fc_grid_plotlist
*          INDEX sy-tabix.
*      ELSE.
*      ENDIF.
*
*      IF wa_fc_grid_plotlist-fieldname = 'ICON_DISPLAY'.
*        wa_fc_grid_plotlist-icon = 'X'.
*        wa_fc_grid_plotlist-hotspot = 'X'.
*        MODIFY g_fc_grid_plotlist FROM wa_fc_grid_plotlist
*          INDEX sy-tabix.
*      ELSE.
*      ENDIF.
*
*      IF wa_fc_grid_plotlist-fieldname = 'ICON_DISPLAY_DIS'.
*        wa_fc_grid_plotlist-icon = 'X'.
*        wa_fc_grid_plotlist-hotspot = 'X'.
*        MODIFY g_fc_grid_plotlist FROM wa_fc_grid_plotlist
*          INDEX sy-tabix.
*      ELSE.
*      ENDIF.
*
*    ENDLOOP.
*    CALL METHOD grid_plotlist->set_frontend_fieldcatalog
*      EXPORTING
*        it_fieldcatalog = g_fc_grid_plotlist
*        .
*    CALL METHOD grid_plotlist->refresh_table_display
**        EXPORTING
**          IS_STABLE      =
**          I_SOFT_REFRESH =
*      EXCEPTIONS
*        finished       = 1
*        OTHERS         = 2
*            .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*
*
**    CALL METHOD grid_plotlist->get_frontend_layout
**      IMPORTING
**        es_layout = g_layo_grid_plotlist
**        .
**    g_layo_grid_plotlist-sel_mode = 'A'.
**
**    g_layo_grid_plotlist-sel_mode = 'A'.
**    g_layo_grid_plotlist-excp_fname = 'LIGHT'.
**    g_layo_grid_plotlist-excp_led = 'X'.
**
**
**    CALL METHOD grid_plotlist->set_frontend_layout
**      EXPORTING
**        is_layout = g_layo_grid_plotlist
**        .
**    CALL METHOD grid_plotlist->refresh_table_display
***        EXPORTING
***          IS_STABLE      =
***          I_SOFT_REFRESH =
**      EXCEPTIONS
**        finished       = 1
**        OTHERS         = 2
**            .
**    IF sy-subrc <> 0.
**      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**    ENDIF.
*
**    SET HANDLER
**      lcl_event_handler_alv=>catch_dblclick FOR grid_plotlist.
**    SET HANDLER
**      lcl_event_handler_alv=>handle_toolbar FOR grid_plotlist.
**    SET HANDLER
**    lcl_event_handler_alv=>handle_user_command FOR grid_plotlist.
*
*    SET HANDLER
*      plot_handler->catch_dblclick FOR grid_plotlist.
*    SET HANDLER
*      plot_handler->handle_toolbar FOR grid_plotlist.
*    SET HANDLER
*      plot_handler->handle_user_command FOR grid_plotlist.
*    SET HANDLER
*      plot_handler->handle_context_menu FOR grid_plotlist.
*
*    SET HANDLER
*      plot_handler->handle_after_user_command FOR grid_plotlist.
*
*    SET HANDLER
*      plot_handler->handle_hotspot_click FOR grid_plotlist.
*
*    CALL METHOD grid_plotlist->set_toolbar_interactive.

  ELSE.
  ENDIF.

ENDMODULE.                 " STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_and_INIT_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_and_init_tree.
  DATA: event TYPE cntl_simple_event,
        events TYPE cntl_simple_events.


  IF simple_tree_plotlist IS INITIAL.
  ELSE.
    EXIT.
  ENDIF.

  CREATE OBJECT container_tree_plotlist
    EXPORTING
*        PARENT                      =
      container_name              = 'CONTAINER_TREE_PLOTLIST'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      others                      = 6
      .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CREATE OBJECT simple_tree_plotlist
    EXPORTING
      node_selection_mode         =
*          cl_simple_tree_model=>node_sel_mode_single
          cl_simple_tree_model=>node_sel_mode_multiple
*        hide_selection              = hide_selection
    EXCEPTIONS
      illegal_node_selection_mode = 1
      others                      = 2
      .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD simple_tree_plotlist->create_tree_control
    EXPORTING
      parent          = container_tree_plotlist
    EXCEPTIONS
      lifetime_error               = 1
      cntl_system_error            = 2
      create_error                 = 3
      failed                       = 4
      tree_control_already_created = 5
      OTHERS                       = 6
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* define the events which will be passed to the backend
* node double click
  event-eventid = cl_simple_tree_model=>eventid_node_double_click.
  event-appl_event = 'X'.              " process PAI if event occurs
  APPEND event TO events.
  event-eventid =
    cl_simple_tree_model=>eventid_node_context_menu_req.
  event-appl_event = 'X'.              " process PAI if event occurs
  APPEND event TO events.

  CALL METHOD simple_tree_plotlist->set_ctx_menu_select_event_appl
    EXPORTING
      appl_event = 'X'
      .

  CALL METHOD simple_tree_plotlist->set_registered_events
    EXPORTING
      events = events
    EXCEPTIONS
      illegal_event_combination = 1
      unknown_event             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* assign event handlers in the application class to each desired event
  SET HANDLER tree_handler->handle_node_double_click
    FOR simple_tree_plotlist.
  SET HANDLER tree_handler->handle_node_context_menu_req
    FOR simple_tree_plotlist.
  SET HANDLER tree_handler->handle_node_context_menu_sel
    FOR simple_tree_plotlist.

* add nodes to the tree model
*  PERFORM add_nodes.

* expand the root node
*  CALL METHOD simple_tree_plotlist->expand_node
*    EXPORTING
*      node_key = 'Root' "#EC NOTEXT
*    EXCEPTIONS
*      node_not_found = 1.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.



ENDFORM.                    " create_and_INIT_TREE
*&---------------------------------------------------------------------*
*&      Form  add_nodes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_nodes.
* Node with key 'Root'
  CALL METHOD simple_tree_plotlist->add_node
    EXPORTING
      node_key = 'Root'                                     "#EC NOTEXT
      isfolder = 'X'
      text = 'Root'                                         "#EC NOTEXT
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Node with key 'Child1'
  CALL METHOD simple_tree_plotlist->add_node
    EXPORTING
      node_key = 'Child1'                                   "#EC NOTEXT
      relative_node_key = 'Root'
      relationship = cl_simple_tree_model=>relat_last_child
      isfolder = 'X'
      text     = 'Child1'                                   "#EC NOTEXT
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Node with key 'New1'
  CALL METHOD simple_tree_plotlist->add_node
    EXPORTING
      node_key = 'New1'                                     "#EC NOTEXT
      relative_node_key = 'Child1'                          "#EC NOTEXT
      relationship = cl_simple_tree_model=>relat_last_child
      isfolder = ' '
      text     = 'New1'                                     "#EC NOTEXT
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Node with key 'New2'
  CALL METHOD simple_tree_plotlist->add_node
    EXPORTING
      node_key = 'New2'                                     "#EC NOTEXT
      relative_node_key = 'Child1'                          "#EC NOTEXT
      relationship = cl_simple_tree_model=>relat_last_child
      isfolder = ' '
      image = '@10@'
      text     = 'New2'                                     "#EC NOTEXT
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " add_nodes
*&---------------------------------------------------------------------*
*&      Module  STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0120 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  PERFORM set_screen_attributes.

ENDMODULE.                 " STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0121  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0121 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  PERFORM set_screen_attributes.
ENDMODULE.                 " STATUS_0121  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0122  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0122 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  PERFORM set_screen_attributes.
ENDMODULE.                 " STATUS_0122  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0123  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0123 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  PERFORM set_screen_attributes.
ENDMODULE.                 " STATUS_0123  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0124  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0124 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  PERFORM set_screen_attributes.
ENDMODULE.                 " STATUS_0124  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_0121  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_0121 OUTPUT.
* set checkboxes
*  TRANSLATE wa_akt_plotjobs-spiegeln TO UPPER CASE.
  CALL FUNCTION 'TERM_TRANSLATE_TO_UPPER_CASE'
       EXPORTING
            langu               = sy-langu
            text                = wa_akt_plotjobs-spiegeln
       IMPORTING
            text_uc             = wa_akt_plotjobs-spiegeln
       EXCEPTIONS
            no_locale_available = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CASE wa_akt_plotjobs-spiegeln.
    WHEN c_ein.
      cb_spiegeln = 'X'.
    WHEN c_aus.
      CLEAR cb_spiegeln.
    WHEN OTHERS.
      CLEAR cb_spiegeln.
  ENDCASE.

ENDMODULE.                 " set_cb_0121  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_0123  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_0123 OUTPUT.
* set checkboxes
*  TRANSLATE wa_akt_plotjobs-falten TO UPPER CASE.
  CALL FUNCTION 'TERM_TRANSLATE_TO_UPPER_CASE'
       EXPORTING
            langu               = sy-langu
            text                = wa_akt_plotjobs-falten
       IMPORTING
            text_uc             = wa_akt_plotjobs-falten
       EXCEPTIONS
            no_locale_available = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CASE wa_akt_plotjobs-falten.
    WHEN c_ja.
      cb_falten = 'X'.
    WHEN c_nein.
      CLEAR cb_falten.
    WHEN OTHERS.
      CLEAR cb_falten.
  ENDCASE.

*  TRANSLATE wa_akt_plotjobs-lochen TO UPPER CASE.
  CALL FUNCTION 'TERM_TRANSLATE_TO_UPPER_CASE'
       EXPORTING
            langu               = sy-langu
            text                = wa_akt_plotjobs-lochen
       IMPORTING
            text_uc             = wa_akt_plotjobs-lochen
       EXCEPTIONS
            no_locale_available = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CASE wa_akt_plotjobs-lochen.
    WHEN c_ja.
      cb_lochen = 'X'.
    WHEN c_nein.
      CLEAR cb_lochen.
    WHEN OTHERS.
      CLEAR cb_lochen.
  ENDCASE.
ENDMODULE.                 " set_cb_0123  OUTPUT

*---------------------------------------------------------------------*
*       MODULE set_cb_0124 OUTPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE set_cb_0124 OUTPUT.
* set checkboxes
*  TRANSLATE wa_akt_plotjobs-knz_inhalt_vz TO UPPER CASE.
  CALL FUNCTION 'TERM_TRANSLATE_TO_UPPER_CASE'
       EXPORTING
            langu               = sy-langu
            text                = wa_akt_plotjobs-knz_inhalt_vz
       IMPORTING
            text_uc             = wa_akt_plotjobs-knz_inhalt_vz
       EXCEPTIONS
            no_locale_available = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CASE wa_akt_plotjobs-knz_inhalt_vz.
    WHEN c_ja.
      cb_knz_inhalt_vz = 'X'.
    WHEN c_nein.
      CLEAR cb_knz_inhalt_vz.
    WHEN OTHERS.
      CLEAR cb_knz_inhalt_vz.
  ENDCASE.

ENDMODULE.                 " set_cb_0124  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_0125  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_0125 OUTPUT.
* set checkboxes
*  TRANSLATE wa_akt_plotjobs-knz_inhalt_vz TO UPPER CASE.
*  CASE wa_akt_plotjobs-knz_inhalt_vz.
*    WHEN c_ja.
*      cb_knz_inhalt_vz = 'X'.
*    WHEN c_nein.
*      CLEAR cb_knz_inhalt_vz.
*    WHEN OTHERS.
*      CLEAR cb_knz_inhalt_vz.
*  ENDCASE.

ENDMODULE.                 " set_cb_0125  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0125  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0125 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  PERFORM set_screen_attributes.
  PERFORM set_scr_attr_aufnr.
  PERFORM set_scr_attr_vbeln.
  PERFORM set_scr_attr_firma.
  PERFORM set_scr_attr_kostl.
  PERFORM set_scr_attr_id_plotjob.
  PERFORM set_scr_attr_pspid.
  PERFORM set_scr_attr_lifnr.
  PERFORM set_scr_attr_ebeln.
ENDMODULE.                 " STATUS_0125  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_0126  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_0126 OUTPUT.

ENDMODULE.                 " set_cb_0126  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0126  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0126 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0126  OUTPUT
