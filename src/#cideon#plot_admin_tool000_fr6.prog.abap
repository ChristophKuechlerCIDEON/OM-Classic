*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/PLOT_ADMIN_TOOL000_FR6                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  change_preprocessor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*----------------------------------------------------------------------*
FORM change_preprocessor TABLES   p_lt_rows STRUCTURE lvc_s_row.

  DATA: ls_selected_line LIKE lvc_s_row,
        lf_row_index TYPE lvc_index,
        ls_plotjobs LIKE LINE OF itab_v_adm_01.

  PERFORM get_sel_items.
  PERFORM get_sel_jobs.


  SELECT * FROM zcl_preprozessor INTO TABLE itab_preprocessor.

  IF dialogbox_container IS INITIAL.
    CREATE OBJECT dialogbox_container
        EXPORTING
          top = 60
          left = 200
          lifetime = cntl_lifetime_dynpro
          caption = text-075 "'Änderung PreProzessor/Verteiler'
          width = 550
          height = 300.

  ENDIF.

  IF alv_preprocessor IS INITIAL.


    CREATE OBJECT alv_preprocessor
        EXPORTING i_parent = dialogbox_container.

    CALL METHOD alv_preprocessor->set_ready_for_input
          EXPORTING i_ready_for_input = 0.

*    CREATE OBJECT g_event_receiver.
    SET HANDLER g_event_receiver->handle_close FOR dialogbox_container.

    ch_layout_prepr-no_toolbar = ' '.
    APPEND cl_gui_alv_grid=>mc_fc_excl_all TO lt_excl_func.

    PERFORM fill_fc_alv_preprocessor CHANGING fc_alv_preprocessor.

    CALL METHOD alv_preprocessor->set_table_for_first_display
         EXPORTING
                   i_structure_name = 'ZCL_PREPROZESSOR'
                   is_layout        = ch_layout_prepr
                   it_toolbar_excluding = lt_excl_func

         CHANGING  it_outtab        = itab_preprocessor
                   it_fieldcatalog  = fc_alv_preprocessor.

    CREATE OBJECT prepr_event_receiver.

    SET HANDLER
       prepr_event_receiver->handle_toolbar_set FOR alv_preprocessor.
    SET HANDLER
      prepr_event_receiver->handle_menu_button FOR alv_preprocessor.
    SET HANDLER
      prepr_event_receiver->handle_double_click FOR alv_preprocessor.
    SET HANDLER
      prepr_event_receiver->handle_user_command FOR alv_preprocessor.
    SET HANDLER
      prepr_event_receiver->handle_hotspot_click FOR alv_preprocessor.

    CALL METHOD alv_preprocessor->set_toolbar_interactive.

    CALL METHOD cl_gui_control=>set_focus
                EXPORTING control = alv_preprocessor.
    CALL METHOD cl_gui_cfw=>flush.

  ELSE.

    CLEAR wa_preprocessor.

    CALL METHOD alv_preprocessor->set_frontend_layout
         EXPORTING is_layout = ch_layout_prepr.
    CALL METHOD alv_preprocessor->set_ready_for_input
          EXPORTING i_ready_for_input = 0.

    CALL METHOD alv_preprocessor->refresh_table_display.

    CALL METHOD cl_gui_control=>set_focus
          EXPORTING control = alv_preprocessor.
    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.

ENDFORM.                    " change_preprozessor
*&---------------------------------------------------------------------*
*&      Form  fill_fc_alv_preprocessor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_fc_alv_preprocessor CHANGING p_fieldcatalog  TYPE lvc_t_fcat.
  DATA:  gs_fieldcatalog TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
            i_structure_name       = 'ZCL_PREPROZESSOR'
       CHANGING
            ct_fieldcat            = p_fieldcatalog
       EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT p_fieldcatalog INTO gs_fieldcatalog.
    CASE gs_fieldcatalog-fieldname.
      WHEN 'PREPROZESSOR' OR 'VERTEILER'.
      WHEN OTHERS.
        gs_fieldcatalog-no_out = 'X'.

    ENDCASE.
    MODIFY p_fieldcatalog FROM gs_fieldcatalog.
  ENDLOOP.


ENDFORM.                    " fill_fc_alv_preprocessor
*&---------------------------------------------------------------------*
*&      Form  select_preprocessor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*----------------------------------------------------------------------*
FORM select_preprocessor TABLES   p_lt_rows STRUCTURE lvc_s_row.

  DATA: ls_selected_line LIKE lvc_s_row,
        lf_row_index TYPE lvc_index.

  CLEAR: wa_preprocessor.

  LOOP AT p_lt_rows INTO ls_selected_line.
    lf_row_index = ls_selected_line-index.
* read selected row from internal table
   READ TABLE itab_preprocessor INDEX lf_row_index INTO wa_preprocessor.


  ENDLOOP.

ENDFORM.                    " select_preprocessor
*&---------------------------------------------------------------------*
*&      Form  change_itab_new_prepr
*&---------------------------------------------------------------------*
*       change itab and DB-Tab pl_jobs1 and pl_jobs2
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_itab_new_prepr.
* PreProcessor ändern
* weitere Felder des PreProcessors ändern
* DOWN_PATH, CLF_DOWN, KNZ_USE_CONVERTE, CONVERTER_NAME,CONVERTER_NUMBER
* FTP_DESTINATION, FTP_USER, FTP_PASSWD, FTP_DOWN

  LOOP AT itab_plot_item INTO wa_plot_item.
    wa_plot_item-preprocessor = wa_preprocessor-preprozessor.
    wa_plot_item-verteiler = wa_preprocessor-verteiler.
    MODIFY itab_v_adm_01 FROM wa_plot_item
          TRANSPORTING preprocessor verteiler

          WHERE id_plotjob = wa_plot_item-id_plotjob
          AND cont = wa_plot_item-cont.

    SELECT SINGLE * FROM /cideon/pl_jobs1 INTO wa_pl_jobs1
        WHERE id_plotjob = wa_plot_item-id_plotjob
        AND   cont = wa_plot_item-cont.

    wa_pl_jobs1-verteiler  = wa_preprocessor-verteiler.
    wa_pl_jobs1-zclupdname = sy-uname.
    wa_pl_jobs1-zclupddate = sy-datum.
    wa_pl_jobs1-zclupdtime = sy-uzeit.
    wa_pl_jobs1-zclupdprog = '/CIDEON/PLOT_ADMIN_TOOL000_FR6'.


    SELECT SINGLE * FROM /cideon/pl_jobs2 INTO wa_pl_jobs2
        WHERE id_plotjob = wa_plot_item-id_plotjob
        AND   cont = wa_plot_item-cont.

    wa_pl_jobs2-preprocessor  = wa_preprocessor-preprozessor.
    wa_pl_jobs2-zclupdname = sy-uname.
    wa_pl_jobs2-zclupddate = sy-datum.
    wa_pl_jobs2-zclupdtime = sy-uzeit.
    wa_pl_jobs2-zclupdprog = '/CIDEON/PLOT_ADMIN_TOOL000_FR6'.

*   Verwaltungsdaten
    SELECT SINGLE * FROM /cideon/pl_jobsc INTO wa_pl_jobsc
        WHERE id_plotjob = wa_plot_item-id_plotjob
        .

    wa_pl_jobsc-down_path  = wa_preprocessor-klient_down_pfad.
    wa_pl_jobsc-clf_down_path  = wa_preprocessor-klient_scan_pfad.
    wa_pl_jobsc-knz_use_converte  = wa_preprocessor-knz_use_converte.
    wa_pl_jobsc-converter_name  = wa_preprocessor-converter_name.
    wa_pl_jobsc-converter_number  = wa_preprocessor-converter_number.
    wa_pl_jobsc-ftp_destination  = wa_preprocessor-ftp_destination.
    wa_pl_jobsc-ftp_user  = wa_preprocessor-ftp_user.
    wa_pl_jobsc-ftp_passwd  = wa_preprocessor-ftp_passwd.
    wa_pl_jobsc-ftp_down  = wa_preprocessor-ftp_down.
    wa_pl_jobsc-zclupdname = sy-uname.
    wa_pl_jobsc-zclupddate = sy-datum.
    wa_pl_jobsc-zclupdtime = sy-uzeit.
    wa_pl_jobsc-zclupdprog = '/CIDEON/PLOT_ADMIN_TOOL000_FR6'.


    UPDATE /cideon/pl_jobs1 FROM wa_pl_jobs1.
    UPDATE /cideon/pl_jobs2 FROM wa_pl_jobs2.
    UPDATE /cideon/pl_jobsc FROM wa_pl_jobsc.

    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.

  ENDLOOP.

  CALL METHOD alv_plotjobs->refresh_table_display.
  CALL METHOD alv_preprocessor->free.
  FREE alv_preprocessor.
  CALL METHOD dialogbox_container->free.
  FREE dialogbox_container.

ENDFORM.                    " change_itab_new_prepr
*&---------------------------------------------------------------------*
*&      Form  set_grid_toolbar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_EXCL_FUNC  text
*----------------------------------------------------------------------*
FORM set_grid_toolbar CHANGING ct_excl_func TYPE ui_functions.

*  append cl_gui_alv_grid=>mc_mb_variant        to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_filter         to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_sum            to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_export         to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_view           to ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_print          to ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_graph          to ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_info           to ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_find           to ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_detail         to ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_check          TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_refresh        TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy       TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_mb_paste          TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row   TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO ct_excl_func.

ENDFORM.                    " set_grid_toolbar
