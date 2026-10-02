*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_001I01                                    *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: return_code TYPE i.
* CL_GUI_CFW=>DISPATCH must be called if events are registered
* that trigger PAI
* this method calls the event handler method of an event
  CALL METHOD cl_gui_cfw=>dispatch
    IMPORTING return_code = return_code.
  IF return_code <> cl_gui_cfw=>rc_noevent.
    " a control event occured => exit PAI
    CASE g_event.
      WHEN 'NODE_DOUBLE_CLICK'.
        ok_code = 'NODE_DOUBLE_CLICK'.
      WHEN 'NODE_MENU_SEL'.
        ok_code = g_ctx_fcode.
      WHEN OTHERS.
        CLEAR ok_code.
        EXIT.
    ENDCASE.
  ENDIF.
*                * Erfolgsmeldung
*                  MESSAGE s000(/cideon/plot_basis)
*                    WITH '' '' '' ''.
*                   Änderung ist erfolgt. & & & &
  break_point.                                             "#EC NOBREAK

  CASE ok_code.
*   normal
    WHEN 'BACK'.
      IF user_data-knz_ask_before_leave = 'X'.
        PERFORM ask_before_leave.
      ELSE.
        PERFORM clean_up.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'CANC'.
      IF user_data-knz_ask_before_leave = 'X'.
        PERFORM ask_before_leave.
      ELSE.
        PERFORM clean_up.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'EXIT'.
      IF user_data-knz_ask_before_leave = 'X'.
        PERFORM ask_before_leave.
      ELSE.
        PERFORM clean_up.
        LEAVE TO SCREEN 0.
      ENDIF.
*  Tabs
    WHEN 'TAB1'.
      tabstripcontrol_001-activetab = 'TAB1'.
    WHEN 'TAB2'.
      tabstripcontrol_001-activetab = 'TAB2'.
      f_alv_plotlist = 'X'.
    WHEN 'TB_DT_01'.
      tbstcrt_detail_001-activetab = 'TB_DT_01'.
    WHEN 'TB_DT_02'.
      tbstcrt_detail_001-activetab = 'TB_DT_02'.
    WHEN 'TB_DT_03'.
      tbstcrt_detail_001-activetab = 'TB_DT_03'.
    WHEN 'TAB1_PL'.
      tbstcrt_plotlist-activetab = 'TAB1_PL'.
    WHEN 'TAB2_PL'.
      tbstcrt_plotlist-activetab = 'TAB2_PL'.
    WHEN 'TAB3_PL'.
      tbstcrt_plotlist-activetab = 'TAB3_PL'.
    WHEN 'TAB4_PL'.
      tbstcrt_plotlist-activetab = 'TAB4_PL'.
    WHEN 'TAB5_PL'.
      tbstcrt_plotlist-activetab = 'TAB5_PL'.
    WHEN 'TAB6_PL'.
      tbstcrt_plotlist-activetab = 'TAB6_PL'.
    WHEN 'TAB7_PL'.
      tbstcrt_plotlist-activetab = 'TAB7_PL'.
    WHEN 'TAB8_PL'.
      tbstcrt_plotlist-activetab = 'TAB8_PL'.
      PERFORM lese_sdpartner.


*   Buttons
    WHEN 'TO_JOBLIST'.
      tabstripcontrol_001-activetab = 'TAB2'.
      f_alv_plotlist = 'X'.
      PERFORM to_joblist.

    WHEN 'DOK_STUECK'.
*     Dokumentensuche durchführen
      PERFORM get_data_for_search_list.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
*      PERFORM clean_up_documents.
      PERFORM refresh_searchlist.
    WHEN 'VORGABE'.
*     Suchliste mit Vorgaben füllen
      PERFORM vorgabe.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
*      PERFORM clean_up_documents.
      PERFORM refresh_searchlist.
      CLEAR ok_code.
    WHEN 'DOK_STL'.
*     Dokumentenstückliste holen
      PERFORM get_data_sl_stueckliste.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
*      PERFORM clean_up_documents.
      PERFORM refresh_searchlist.

    WHEN 'DBLCLICK_SEARCH'.
*      message i999(ZCL_PLINT_MESSAGE_01).
      PERFORM read_akt_line_search.
    WHEN 'SEND_TREE'.
      PERFORM sel_tree_to_sel_list.
      PERFORM send.
      ok_code = 'SEND'.
    WHEN 'SEND'.
*     send to Plot
      PERFORM send.

    WHEN 'HOT_SEND'.
*     Senden mit Überspringen der Plotliste
      IF simple_tree_plotlist IS INITIAL.
        PERFORM create_and_init_tree.
      ELSE.
      ENDIF.

      IF grid_plotlist IS INITIAL.
        PERFORM create_and_init_plotlist.
      ELSE.
      ENDIF.

      PERFORM to_joblist.
      PERFORM send.

    WHEN 'DELETE_SEARCH_ITEM'.
*     Eintrag aus der SEARCHLIST löschen
*     Sicherheitsabfrage integrieren
      IF user_data-knz_ask_before_delete = 'X'.
        PERFORM ask_before_delete CHANGING answer.
        IF answer = 'J'.
          PERFORM del_selected_line_search_list.
          PERFORM refresh_searchlist.
          PERFORM clear_search_details.
        ELSE.
        ENDIF.
      ELSE.
        PERFORM del_selected_line_search_list.
        PERFORM refresh_searchlist.
        PERFORM clear_search_details.
      ENDIF.
    WHEN 'DBLCLICK_PLOT'.
*     Anzeige auf TABs
      PERFORM read_akt_line_plotlist.
      PERFORM set_tree_sel_node.
    WHEN 'DELETE_PLOT_ITEM'.
*     Eintrag aus Plottliste löschen
      IF user_data-knz_ask_before_delete = 'X'.
        PERFORM ask_before_delete CHANGING answer.
        IF answer = 'J'.
          PERFORM del_selected_line_plot_list.
          PERFORM refresh_plotlist.
          PERFORM rebuild_tree_plotlist.
          PERFORM clear_plot_details.
        ELSE.
        ENDIF.
      ELSE.
        PERFORM del_selected_line_plot_list.
        PERFORM refresh_plotlist.
        PERFORM rebuild_tree_plotlist.
        PERFORM clear_plot_details.
      ENDIF.
    WHEN 'NODE_DOUBLE_CLICK'.
*     get the selected node
      PERFORM get_dbclk_node.
    WHEN 'DELETE_NOD'.
*     delete Node from Plottree
      IF user_data-knz_ask_before_delete = 'X'.
        PERFORM ask_before_delete CHANGING answer.
        IF answer = 'J'.
          "Änderung wegen Multiselectproblemen
          PERFORM sel_tree_to_sel_list.
          PERFORM del_selected_line_plot_list.
          "PERFORM del_item_tree_plotlist.
          PERFORM refresh_plotlist.
          PERFORM rebuild_tree_plotlist.
          PERFORM clear_plot_details.
        ELSE.
        ENDIF.
      ELSE.
        "Änderung wegen Multiselectproblemen
        PERFORM sel_tree_to_sel_list.
        PERFORM del_selected_line_plot_list.
        "PERFORM del_item_tree_plotlist.
        PERFORM refresh_plotlist.
        PERFORM rebuild_tree_plotlist.
        PERFORM clear_plot_details.
      ENDIF.
    WHEN 'CHG_PRIO_N'.
      CALL FUNCTION 'Z_CL_PLINT_TOOLS_ASK_FOR_PRIO'
           EXPORTING
                i_prio_von = user_data-prio_von             "'00'
                i_prio_bis = user_data-prio_bis             "'10'
           IMPORTING
                o_prio     = g_prio
           EXCEPTIONS
                error      = 1
                forget     = 2
                OTHERS     = 3.
      IF sy-subrc <> 0.
        IF sy-subrc = 2.
        ELSE.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ELSE.
        "Änderung wegen Multiselectproblemen
        PERFORM sel_tree_to_sel_list.
        PERFORM change_priority.
        "PERFORM change_priority_node.
        PERFORM refresh_plotlist.
        PERFORM clear_plot_details.
      ENDIF.
    WHEN 'CHG_PRIO'.
*     Priorität verändern
      CALL FUNCTION 'Z_CL_PLINT_TOOLS_ASK_FOR_PRIO'
           EXPORTING
                i_prio_von = user_data-prio_von             "'00'
                i_prio_bis = user_data-prio_bis             "'10'
           IMPORTING
                o_prio     = g_prio
           EXCEPTIONS
                error      = 1
                OTHERS     = 2.
      IF sy-subrc <> 0.
        IF sy-subrc = 2.
        ELSE.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ELSE.
        PERFORM change_priority.
      ENDIF.
    WHEN 'UP_PLOT'.
*     Reihenfolge ändern
      PERFORM plotlist_up_one_item.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'DOWN_PLOT'.
*     Reihenfolge ändern
      PERFORM plotlist_down_one_item.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'UP_TREE'.
*     Reihenfolge ändern
      "Änderung wegen Multiselectproblemen
      PERFORM sel_tree_to_sel_list.
      PERFORM plotlist_up_one_item.
      "PERFORM plottree_up_one_item.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'DOWN_TREE'.
*     Reihenfolge ändern
      "Änderung wegen Multiselectproblemen
      PERFORM sel_tree_to_sel_list.
      PERFORM plotlist_down_one_item.
      "PERFORM plottree_down_one_item.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'COPY'.
      PERFORM copy_in_plotlist.
      PERFORM clear_plot_details.
    WHEN 'CUT'.
      PERFORM cut_in_plotlist.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'PASTE'.
      PERFORM paste_in_plotlist.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'COPY_TREE'.
      "Änderung wegen Multiselectproblemen
      PERFORM sel_tree_to_sel_list.
      PERFORM copy_in_plotlist.
      "PERFORM copy_in_plottree.
      PERFORM clear_plot_details.
    WHEN 'CUT_TREE'.
      "Änderung wegen Multiselectproblemen
      PERFORM sel_tree_to_sel_list.
      PERFORM cut_in_plotlist.
      "PERFORM cut_in_plottree.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'PASTE_TREE'.
      "Änderung wegen Multiselectproblemen
      PERFORM paste_in_plottree.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'PLINT_CFG0'.
      PERFORM maintain_cfg_00.
    WHEN 'PLINT_CFG'.
      PERFORM maintain_cfg.
    WHEN 'PLINT_TDWP'.
      PERFORM maintain_applictypes.
    WHEN 'GRP_TDWP'.
      PERFORM maintain_groups_appl.
    WHEN 'USER_GRP'.
      PERFORM maintain_user_groups.
    WHEN 'PLINT_LAY'.
      PERFORM maintain_layout.
    WHEN 'PLINT_VWS'.
      PERFORM maintain_views.
    WHEN 'APPLOG'.
      PERFORM view_appl_log.
    WHEN 'PL_LOG'.
      PERFORM view_plot_log.
    WHEN 'MAIL_CFG'.
      PERFORM maintain_mail_cfg.
    WHEN 'USR_GRP'.
      PERFORM maintain_user_group.
    WHEN 'PLINT_PRI'.
      PERFORM maintain_prio.
    WHEN 'GRP_KL'.
      PERFORM maintain_grp_kl.
    WHEN 'USR_GRP_KL'.
      PERFORM maintain_usr_grp_kl.

*   Stempeln bei Ansicht
    WHEN 'GRP_ST_DOK'.
      PERFORM maintain_grp_st_dok.
    WHEN 'USR_GRP_ST'.
      PERFORM maintain_usr_grp_st.
    WHEN 'GRP_ST_WSA'.
      PERFORM maintain_grp_st_wsa.
    WHEN 'USR_GRP_SA'.
      PERFORM maintain_usr_grp_sa.
*   Stempeln nicht bei Merkmal ...
    WHEN 'G_N_STMP'.
      PERFORM maintain_grp_dis_not_stamp.
    WHEN 'UG_N_STMP'.
      PERFORM maintain_usr_grp_dis_not_stamp.
*   resultierende Stempel
    WHEN 'ST_R_USR'.
      PERFORM maintain_st_r_usr.
    WHEN 'ST_R_GRP'.
      PERFORM maintain_st_r_grp.

*   verbotene DIS per Merkmal
    WHEN 'DIS_G_KLAS'.
      PERFORM maintain_ug_cls_n_use.
    WHEN 'DIS_UG_KLS'.
      PERFORM maintain_g_cls_n_use.

*   Eigenschaften setzen
    WHEN 'CHANGE'.
      PERFORM change_job_properties.
      PERFORM refresh_plotlist.
*      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
      PERFORM reselect_plotlist_entries.
    WHEN 'CHG_TREE'.
      PERFORM change_job_properties_tree.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM reselect_plotlist_entries.
      PERFORM clear_plot_details.
      PERFORM reselect_tree_entries.

    WHEN 'DUBLETTEN'.
      MESSAGE i002(zcl_plint_message_01)
         WITH '' '' '' ''.
    WHEN 'ZUSAMMEN'.
      MESSAGE i002(zcl_plint_message_01)
         WITH '' '' '' ''.
    WHEN 'ENTER'.
      PERFORM update_on_enter.
    WHEN 'TIFF_KOMP'.
      PERFORM maintain_tiff_komp.

*   Anzeige DIS / Originale
    WHEN 'CV03N'.
      PERFORM cv03n_view.
    WHEN 'CV03N_L'.
      PERFORM cv03n_view_list.
    WHEN 'VIEW_ORIGINALS'.
      PERFORM view_originals_sl.
    WHEN 'HOT_SPOT_CLICK_DISPLAY'.
      PERFORM view_originals_sl_hot.
    WHEN 'HOT_SPOT_CLICK_DISPLAY_DIS'.
      PERFORM cv03n_view_sl_hot.

    WHEN 'DOK_VIEW'.
*     Dokument in der Plottingliste ansehen
      PERFORM get_selected_line_plotjobs.
      PERFORM get_set_view_program.
      PERFORM check_kapro.
      PERFORM stamp_before_view.
      CASE wa_view_program-programm.
        WHEN 'EAI 2D'.
          PERFORM view_document_02.
        WHEN 'EAI 3D'.
          PERFORM view_document_03.
        WHEN 'OFFICE'.
          PERFORM view_document.
      ENDCASE.
      PERFORM delete_after_view.
    WHEN 'VIEW_NODE'.
*     Dokument aus Tree ansehen
      "PERFORM view_item_tree_plotlist.
      "Änderung wegen Multiselectproblemen
      PERFORM sel_tree_to_sel_list.
      PERFORM get_selected_line_plotjobs.
      PERFORM get_set_view_program.
      PERFORM check_kapro.
      PERFORM stamp_before_view.
      CASE wa_view_program-programm.
        WHEN 'EAI 2D'.
          PERFORM view_document_02.
        WHEN 'EAI 3D'.
          PERFORM view_document_03.
        WHEN 'OFFICE'.
          PERFORM view_document.
      ENDCASE.
      PERFORM delete_after_view.

    WHEN 'HOT_SPOT_CLICK_DISPLAY_PL'.
      PERFORM view_originals_pl_hot.
    WHEN 'HOT_SPOT_CLICK_DISPLAY_DIS_PL'.
      PERFORM cv03n_view_pl_hot.
    WHEN 'CV03N_T'.
*     DIS aus Tree ansehen
      PERFORM sel_tree_to_sel_list.
      PERFORM get_selected_line_plotjobs.
      PERFORM cv03n_view_tree.
    WHEN 'FRONTTYP'.
      PERFORM change_fronttype.

    WHEN 'INFO'.
      PERFORM view_info.
    WHEN 'VERS'.
      PERFORM show_versions_info.
    WHEN 'INFO2'.
      PERFORM show_versions_info_2.

*   Menüeintrag OPTIONS
    WHEN 'ONLY_LAST_VERSION'.
      PERFORM only_last_version.
      PERFORM refresh_searchlist.
    WHEN 'LAST_FREE_VERSION'.
      PERFORM last_free_version.
      PERFORM refresh_searchlist.
    WHEN 'ONLY_FREE_VERSION'.
      PERFORM only_free_version.
      PERFORM refresh_searchlist.
    WHEN 'ONLY_GOOD_MATERIAL'.
      PERFORM only_good_material.
      PERFORM refresh_searchlist.

    WHEN 'ACTUAL_DIS'.
      PERFORM get_actual_dis.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
      PERFORM refresh_searchlist.
      PERFORM clear_search_details.
    WHEN 'ACTUAL_RELEASED_DIS'.
      PERFORM get_actual_released_dis.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
      PERFORM refresh_searchlist.
      PERFORM clear_search_details.

    WHEN 'RELOAD'.
      PERFORM reload_properties.
    WHEN 'NO_DUPLICATES_SL'.
      PERFORM delete_duplicates_sl.
      PERFORM refresh_searchlist.
    WHEN 'REFRESH_SL'.
      PERFORM get_dokst.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
      PERFORM refresh_searchlist.

    WHEN 'INI_LESEN'.
      PERFORM read_repro_ini.
    WHEN 'INI_LESEN2'.
      PERFORM read_repro_ini2.

    WHEN 'PREPROZ_US'.
      PERFORM preproz_to_user.

*   Suchliste
    WHEN 'SAVE_SEARCHLIST'.
      PERFORM save_searchlist.
    WHEN 'OPEN_SEARCHLIST'.
      PERFORM open_searchlist.
      PERFORM recalc_searchlist.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
      PERFORM refresh_searchlist.
*   Plotliste
    WHEN 'SAVE_PLOTLIST'.
      PERFORM save_plotlist.
    WHEN 'OPEN_PLOTLIST'.
      PERFORM open_plotlist.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'LOAD_PL'.
      PERFORM open_plotlist.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
*   Fehlblattliste
    WHEN 'SAVE_FB_LIST'.
      PERFORM save_fb_list.
    WHEN 'ONLY_CHECKED_IN'.
      PERFORM only_checked_in_pl.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'DOKU'.
      PERFORM show_dokumentation.
    WHEN 'REFRESH'.
      PERFORM refresh_plotlist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'CLR_DETAIL'.
      PERFORM clear_plot_details.
    WHEN 'FILTER_1'.
      PERFORM ask_for_filter.
    WHEN 'STAMP_DEF'.
      PERFORM maintain_default_stamps.
    WHEN 'STAMP_USR'.
      PERFORM maintain_user_stamps.
    WHEN 'STAMP_VOR'.
      PERFORM maintain_voreinstell_stamps.
    WHEN 'STAMP_VER'.
      PERFORM maintain_verteiler_stamps.
    WHEN 'NEUTR_FILE'.
      PERFORM maintain_neutral_format.

* Verteiler etc. ändern
    WHEN 'CHG_VBELN'.
      PERFORM clear_plot_details.
      PERFORM change_vbeln.
      PERFORM refresh_joblist.
    WHEN 'CHG_VBELNT'.
      PERFORM clear_plot_details.
      PERFORM change_vbeln_tree.
      PERFORM refresh_joblist.
    WHEN 'CHG_AUFNR'.
      PERFORM clear_plot_details.
      PERFORM change_aufnr.
      PERFORM refresh_joblist.
    WHEN 'CHG_AUFNRT'.
      PERFORM clear_plot_details.
      PERFORM change_aufnr_tree.
      PERFORM refresh_joblist.

*   Einkaufsbelegnummer / etc.
    WHEN 'CHG_EBELN'.
      PERFORM clear_plot_details.
      PERFORM change_ebeln.
      PERFORM refresh_joblist.
    WHEN 'CHG_VENDOR'.
      PERFORM clear_plot_details.
      PERFORM change_vendor.
      PERFORM refresh_joblist.
    WHEN 'CHG_V_TEL'.
      PERFORM clear_plot_details.
      PERFORM change_lif_telnr_long.
      PERFORM refresh_joblist.
    WHEN 'CHG_V_FAX'.
      PERFORM clear_plot_details.
      PERFORM change_lif_faxnr_long.
      PERFORM refresh_joblist.
    WHEN 'CHG_V_EMAI'.
      PERFORM clear_plot_details.
      PERFORM change_lif_smtp_addr.
      PERFORM refresh_joblist.
    WHEN 'CHG_EBELNT'.
      PERFORM clear_plot_details.
      PERFORM change_ebeln_tree.
      PERFORM refresh_joblist.
    WHEN 'CHG_VENDRT'.
      PERFORM clear_plot_details.
      PERFORM change_vendor_tree.
      PERFORM refresh_joblist.
    WHEN 'CHG_V_TELT'.
      PERFORM clear_plot_details.
      PERFORM change_lif_telnr_long_tree.
      PERFORM refresh_joblist.
    WHEN 'CHG_V_FAXT'.
      PERFORM clear_plot_details.
      PERFORM change_lif_faxnr_long_tree.
      PERFORM refresh_joblist.
    WHEN 'CHG_V_EMAT'.
      PERFORM clear_plot_details.
      PERFORM change_lif_smtp_addr_tree.
      PERFORM refresh_joblist.

    WHEN 'CHG_VERT' .
      PERFORM clear_plot_details.
      PERFORM change_verteiler.
      PERFORM refresh_joblist.
    WHEN 'CHG_VERT_T' .
      PERFORM clear_plot_details.
      PERFORM change_verteiler_tree.
      PERFORM refresh_joblist.

    WHEN 'CHG_COPY' .
      PERFORM clear_plot_details.
      PERFORM change_copy.
      PERFORM refresh_joblist.
    WHEN 'CHG_COPY_T' .
      PERFORM clear_plot_details.
      PERFORM change_copy_tree.
      PERFORM refresh_joblist.

    WHEN 'CHG_NOTE' .
      PERFORM clear_plot_details.
      PERFORM change_note.
    WHEN 'CHG_NOTE_T' .
      PERFORM clear_plot_details.
      PERFORM change_note_tree.

*   Dokumente spezial
    WHEN 'LOAD_DRAW'.
      PERFORM get_drawing_from_bom.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
*      PERFORM clean_up_documents.
      PERFORM refresh_searchlist.
*   Zeichnungen laden mit variabler Zuordnung
*   Zeichungen nicht über Standard spezifizierbar
    WHEN 'LOAD_DRAW2'.
      PERFORM get_drawing_from_bom2.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
*      PERFORM clean_up_documents.
      PERFORM refresh_searchlist.
    WHEN 'LOAD_DRAW3'.
*     Zeichnungen laden mit variabler Zuordnung
*     Zeichungen nicht über Standard spezifizierbar
*     Start über Materialnummer
      PERFORM get_drawing_from_bom3.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
*      PERFORM clean_up_documents.
      PERFORM refresh_searchlist.
    WHEN 'LOAD_MAT'.
      PERFORM get_do_from_materliallist.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
      PERFORM refresh_searchlist.
*   Inhaltsverzeichnis: Beziehung zwischen Zeichnung/Modell
    WHEN 'DRAW_MODEL'.
      PERFORM get_relation_drawing_model.
*   Plotanforderunge ohne existierenden DIS
    WHEN 'NO_DIS'.
      PERFORM get_special_dis.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
      PERFORM refresh_searchlist.
    WHEN 'NOTE_DIR'.
      PERFORM add_note_dir.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
      PERFORM refresh_searchlist.
    WHEN 'SET_SEARCH_GL'.
*     Selektion setzen
      PERFORM set_selection_search_gl.
    WHEN 'READ_SEARCH_GL'.
*     Selektion setzen
      PERFORM read_selection_search_gl.

*   Spezial -> Kontextmenüs
    WHEN 'DWNL_LOCAL'.
      PERFORM clear_plot_details.
      PERFORM download_to_local.
    WHEN 'DWNL_LCL_T'.
      PERFORM clear_plot_details.
      PERFORM sel_tree_to_sel_list.
      PERFORM download_to_local.
    WHEN 'AO_MERGE'.
*     Zusammenfügen der Einträge
*     Setzen von AO_MERGE
      PERFORM clear_plot_details.
      PERFORM set_ao_merge.

*   Spezial / Plotliste / Konvertierungen
    WHEN 'STR_KONV'.
      PERFORM clear_plot_details.
      PERFORM start_konverting.
    WHEN 'RFR_KONV'.
      PERFORM refresh_after_converting.
      PERFORM refresh_joblist.
      PERFORM rebuild_tree_plotlist.
      PERFORM clear_plot_details.
    WHEN 'STR_ZKONV'.
      PERFORM clear_plot_details.
      PERFORM start_zkonverting.
    WHEN 'STR_KONV1'.
      "Start einer Konvertierung nach Eingabe einer Konvertierungs
      "regel
      PERFORM clear_plot_details.
      PERFORM start_conversion_by_rule.

*   spezial
    WHEN 'STAMP_LANG'.
      PERFORM set_stamp_language.
    WHEN 'DEL_OLD_JB'.
      PERFORM delete_old_jobs.

*   DEBUG-Anbindung
    WHEN 'DEBUG'.
      gf_debug = 'X'.
    WHEN 'NODEBUG'.
      CLEAR gf_debug.
    WHEN 'DEBUGON'.
      gf_debug = 'X'.
    WHEN 'DEBUGOFF'.
      CLEAR gf_debug.

*   LOG Anbindung
    WHEN 'PLOT_LOG'.
      SET PARAMETER ID 'Z_KNZ_PLOT_LOG' FIELD 'X'.
    WHEN 'PLOT_LOG_OFF'.
      SET PARAMETER ID 'Z_KNZ_PLOT_LOG' FIELD ''.


*   Editor
    WHEN 'EDITOR'.
      PERFORM editor_suchliste.

*   Einzelanzeige der DIS Daten einblenden / ausblenden
*   bzw. den ALV exorbitant vergrößern
    WHEN 'TOG_DRAW'.
      IF g_show_draw_detail = 'X'.
        CLEAR g_show_draw_detail.
        g_search_list_dynpro = c_draw_no_detail_dynpro.
      ELSE.
        g_show_draw_detail = 'X'.
        g_search_list_dynpro = c_draw_detail_dynpro.
      ENDIF.
      PERFORM set_knz_view_draw_detail.

*   Hierachieanzeige in Plotliste einblenden / ausblenden
    WHEN 'TOG_STRUKT'.
      IF g_show_struktur = 'X'.
        CLEAR g_show_struktur.
        g_plot_list_dynpro = c_plot_no_struktur_dynpro.
      ELSE.
        g_show_struktur = 'X'.
        g_plot_list_dynpro = c_plot_struktur_dynpro.
        f_tree_plotlist ='X'.
        PERFORM create_and_init_tree.
        PERFORM rebuild_tree_plotlist.
      ENDIF.
      PERFORM set_knz_view_struc_plotlist.
*   Einzelanzeige in Plotliste einblenden / ausblenden

*   Ausgabe der Dateien als einzelne Jobs
    WHEN 'SNGL_J_ON'.
      user_data-knz_single_entry = 'X'.
      PERFORM set_knz_single_entry_on.
    WHEN 'SNGL_J_OFF'.
      user_data-knz_single_entry = ''.
      PERFORM set_knz_single_entry_off.

*   Anbindung Inhaltsverzeichnis
    WHEN 'TOC_CREATE'.
      PERFORM create_toc.
    WHEN 'TOC_SEND'.
      PERFORM send_toc.
    WHEN 'TOC_N_CREA'.
      PERFORM dont_create_toc.
    WHEN 'TOC_N_SEND'.
      PERFORM dont_send_toc.

    WHEN 'PLO_ON'.
      user_data-knz_use_admin_module = 'X'.
    WHEN 'PLO_OFF'.
      user_data-knz_use_admin_module = ''.

    WHEN 'MP_ON'.
      user_data-knz_use_multipage = 'X'.
    WHEN 'MP_OFF'.
      user_data-knz_use_multipage = ''.

*   Übergabe Queue lesen
    WHEN 'READ_SEARC'.
      PERFORM read_queue.
      PERFORM get_dok_text.
      PERFORM get_matnr.
      PERFORM get_stabk.
      PERFORM get_dates_ecn.
*      PERFORM clean_up_documents.

      PERFORM get_lieferanten_daten.

      PERFORM refresh_searchlist.

*   globale Notiz setzen
    WHEN 'NOTIZ'.
      PERFORM get_note.

*   Pflegedialoge 3
*   Zuordnugn Verteiler/Werk für Fertigungsauftrag
    WHEN 'VERT_WERK'.
      CALL TRANSACTION 'Z_MAINT_ZCL_FAUF_WER'.
*   Download ganzer Strukturen (Konvertierung vor Ausgabe)
*   Borealis
    WHEN 'STRUC_DOWN'.
      CALL TRANSACTION  '/CIDEON/MAINT_WSA_DO'.
    WHEN OTHERS.
*      call method CL_GUI_CFW=>dispatch.
  ENDCASE.

  break_point.                                             "#EC NOBREAK
*  SET parameter id 'ZCL_UNAME_GET' field wa_akt_plotjobs-uname.
*  SET parameter id 'ZCL_UNAME_GET' field default_data-default_nutzer.
  PERFORM save_wa_akt_plotjobs.
  CLEAR ok_code.

* Parameter für Log Ansehen setzen
* Meldung absetzen
  GET PARAMETER ID 'Z_PL_VIEW_APPL_LOG' FIELD f_view_log.
  SET PARAMETER ID 'Z_PL_VIEW_APPL_LOG' FIELD ''.
  IF f_view_log = 'X'.
*   Meldung absetzen
    MESSAGE i005(zcl_plint_message_01) WITH '' '' '' ''.
*   Bitte Appl. Log. ansehen! & & & &
  ELSE.
  ENDIF.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  voreinstellung  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE voreinstellung INPUT.
  DATA: wa_tmp_voreinstellung TYPE zcl_voreinstell.
* F4 Help.
  DATA: tmp_sy_repid LIKE sy-repid.

  SELECT SINGLE * FROM zcl_voreinstell INTO wa_tmp_voreinstellung
    WHERE uname = wa_akt_plotjobs-uname
    .
  IF sy-subrc NE 0.
    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_data-default_nutzer.
  ELSE.
    IF wa_akt_plotjobs-uname IS INITIAL.
     SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_data-default_nutzer.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD wa_akt_plotjobs-uname.
    ENDIF.
  ENDIF.

  tmp_sy_repid = sy-repid.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
       EXPORTING
            tabname     = 'ZCL_S_PLOTLIST'
            fieldname   = 'VOREINSTELLUNG'
            dynpprog    = tmp_sy_repid
            dynpnr      = sy-dynnr
            dynprofield = 'WA_PLOTJOBS-VOREINSTELL'.

  f_f4_voreinstellung = 'X'.


ENDMODULE.                 " voreinstellung  INPUT
*&---------------------------------------------------------------------*
*&      Module  VERTEILER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verteiler INPUT.
  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
  DATA: wa_tmp_preproz_user TYPE zcl_preproz_user.
  DATA: uname_prepro TYPE xubname.
* F4 Help.


  IF wa_akt_plotjobs-uname IS INITIAL.
    SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
      WHERE uname = sy-uname
      AND status = c_status_aktiv
      .
    IF sy-subrc NE 0.
*     Testen, ob eine Zuordnung über eine Rolle vorliegt
      CLEAR uname_prepro.
      CALL FUNCTION '/CIDEON/CHECK_ROLES_FOR_USER'
           EXPORTING
                i_uname        = sy-uname
           IMPORTING
                o_uname_prepro = uname_prepro
           EXCEPTIONS
                no_role        = 1
                error          = 2
                OTHERS         = 3.
      IF sy-subrc <> 0.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD default_data-default_nutzer.
      ELSE.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD uname_prepro.
      ENDIF.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD sy-uname.
    ENDIF.
  ELSE.
    SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
      WHERE uname = wa_akt_plotjobs-uname
      AND status = c_status_aktiv
      .
    IF sy-subrc NE 0.
*     Testen, ob eine Zuordnung über eine Rolle vorliegt
      CLEAR uname_prepro.
      CALL FUNCTION '/CIDEON/CHECK_ROLES_FOR_USER'
           EXPORTING
                i_uname        = sy-uname
           IMPORTING
                o_uname_prepro = uname_prepro
           EXCEPTIONS
                no_role        = 1
                error          = 2
                OTHERS         = 3.
      IF sy-subrc <> 0.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD default_data-default_nutzer.
      ELSE.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD uname_prepro.
      ENDIF.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD wa_akt_plotjobs-uname.
    ENDIF.
  ENDIF.

  tmp_sy_repid = sy-repid.


* ZCL_V_PRE_US_VER
  DATA: itab_data TYPE TABLE OF zcl_v_pre_us_ver.
  DATA: itab_ret TYPE TABLE OF ddshretval.
  DATA: wa_ret TYPE ddshretval.
  DATA: wa_data TYPE zcl_v_pre_us_ver.
  DATA: tmp_get_uname TYPE xubname.

  CLEAR tmp_get_uname.
  GET PARAMETER ID 'ZCL_UNAME_GET' FIELD tmp_get_uname.

  SELECT * FROM zcl_v_pre_us_ver INTO TABLE itab_data
    WHERE uname = tmp_get_uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Testen, ob für die Verteiler überhaupt die Berechtigungen
* vorliegen
* Parameter: KNZ_USE_VERT_RIGHTS
  IF user_data-knz_use_vert_rights = 'X'.
    DATA: index_data TYPE i.
    CLEAR index_data.
    LOOP AT itab_data INTO wa_data.
      index_data = sy-tabix.

      AUTHORITY-CHECK OBJECT 'ZCL_PLOTVT'
               ID 'ZCL_TA' FIELD 'ZCL_PLOT_INTERFACE'
               ID 'ZCL_NAMEVT' FIELD wa_data-verteiler.
      IF sy-subrc NE 0.
        DELETE itab_data INDEX index_data.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      ddic_structure         = 'ZCL_V_PRE_US_VER'
      retfield               = 'VERTEILER'
*           PVALKEY                = ' '
*           DYNPPROG               = ' '
*           DYNPNR                 = ' '
*           DYNPROFIELD            = ' '
*           STEPL                  = 0
*           WINDOW_TITLE           =
*           VALUE                  = ' '
      value_org              = 'S'
*           MULTIPLE_CHOICE        = ' '
*           DISPLAY                = ' '
*           CALLBACK_PROGRAM       = ' '
*           CALLBACK_FORM          = ' '
    TABLES
      value_tab              = itab_data
*           FIELD_TAB              =
      return_tab             = itab_ret
*           DYNPFLD_MAPPING        =
    EXCEPTIONS
      parameter_error        = 1
      no_values_found        = 2
      OTHERS                 = 3
            .

  IF itab_ret[] IS INITIAL.
  ELSE.
    LOOP AT itab_ret INTO wa_ret.
    ENDLOOP.

*   saves the wa
    IF wa_akt_plotjobs IS INITIAL.
      EXIT.
    ELSE.
      IF NOT wa_akt_plotjobs-dokar IS INITIAL
        AND NOT wa_akt_plotjobs-doknr IS INITIAL
        AND NOT wa_akt_plotjobs-dokvr IS INITIAL
        AND NOT wa_akt_plotjobs-doktl IS INITIAL
        .

        wa_akt_plotjobs-verteiler = wa_ret-fieldval.

        PERFORM change_kompression.

        MODIFY itab_plotjobs FROM wa_akt_plotjobs
          INDEX index_itab_plotjobs.
      ELSE.
      ENDIF.
    ENDIF.
  ENDIF.

*  PERFORM save_wa_akt_plotjobs.
*  CLEAR ok_code.


ENDMODULE.                 " VERTEILER  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_0121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_0121 INPUT.
* get checkbox value and set to wa

  CASE cb_spiegeln.
    WHEN 'X'.
      wa_akt_plotjobs-spiegeln = c_ein.
    WHEN OTHERS.
      wa_akt_plotjobs-spiegeln = c_aus.
  ENDCASE.

ENDMODULE.                 " get_cb_0121  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_0123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_0123 INPUT.
* get checkbox value and set to wa

  CASE cb_lochen.
    WHEN 'X'.
      wa_akt_plotjobs-lochen = c_ja.
    WHEN OTHERS.
      wa_akt_plotjobs-lochen = c_nein.
  ENDCASE.

  CASE cb_falten.
    WHEN 'X'.
      wa_akt_plotjobs-falten = c_ja.
    WHEN OTHERS.
      wa_akt_plotjobs-falten = c_nein.
  ENDCASE.

ENDMODULE.                 " get_cb_0123  INPUT

*---------------------------------------------------------------------*
*       MODULE get_cb_0124 INPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE get_cb_0124 INPUT.
* get checkbox value and set to wa

  CASE cb_knz_inhalt_vz.
    WHEN 'X'.
      wa_akt_plotjobs-knz_inhalt_vz = c_ja.
    WHEN OTHERS.
      wa_akt_plotjobs-knz_inhalt_vz = c_nein.
  ENDCASE.

ENDMODULE.                 " get_cb_0124  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_0125  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_0125 INPUT.
* get checkbox value and set to wa
*
*  CASE cb_knz_inhalt_vz.
*    WHEN 'X'.
*      wa_akt_plotjobs-knz_inhalt_vz = c_ja.
*    WHEN OTHERS.
*      wa_akt_plotjobs-knz_inhalt_vz = c_nein.
*  ENDCASE.
*
ENDMODULE.                 " get_cb_0125  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_0126  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_0126 INPUT.

ENDMODULE.                 " get_cb_0126  INPUT
