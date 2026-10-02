*----------------------------------------------------------------------*
*   INCLUDE ZCL_VARIABLEN_PLOT                                         *
*----------------------------------------------------------------------*
* Änderungen:
*  12.05.2004 HAENSEL  Globale Variable zur Überprüfung, ob das "Langs-
*                      ame Verbindung" Ankreuzfeld im SAP Logon ange-
*                      kreuzt ist (GF_SLOW_CONNECTION).
* 29.01.2005 - f_audit_trail_confirm_no
************************************************************************

TYPE-POOLS szadr.

* define break_point
DEFINE break_point.
  if not gf_debug is initial.
    break-point.                                           "#EC NOBREAK
  endif.
END-OF-DEFINITION.

DATA: gf_debug(1) VALUE ''.
DATA: gf_slow_connection   TYPE   as4flag.
DATA  ok_code(30).
DATA: g_ctx_fcode TYPE sy-ucomm.

TYPES:
  BEGIN OF  t_docsearch,
    dokar LIKE draw-dokar,
  END OF t_docsearch.
TYPES:
  BEGIN OF t_protocol,
    line(50),
  END OF t_protocol.

*Tables
TABLES: draw.
TABLES: drat.
TABLES: tfdir.
TABLES: rsinfdir.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.
CONTROLS tbstcrt_detail_001 TYPE TABSTRIP.
CONTROLS tbstcrt_plotlist TYPE TABSTRIP.

*ITAB
*DATA: itab_docs type table of  t_docsearch.
DATA: itab_search TYPE TABLE OF  zcl_s_docsearch.
DATA: itab_search_tmp TYPE TABLE OF zcl_s_docsearch. "draw.
DATA: itab_plotjobs TYPE TABLE OF  zcl_s_plotlist.
DATA: itab_tmp_plotjobs TYPE TABLE OF  zcl_s_plotlist.
DATA: itab_tmp_plotjobs_2 TYPE TABLE OF  zcl_s_plotlist.
DATA: itab_tmp_plotjobs_3 TYPE TABLE OF  zcl_s_plotlist.
DATA: itab_copy_cut_plotjobs TYPE TABLE OF  zcl_s_plotlist.
DATA: itab_protocol TYPE TABLE OF t_protocol.
DATA: itab_zori_doc_files TYPE TABLE OF zori_doc_files.
DATA: itab_zori_doc_files_detail TYPE TABLE OF bapi_doc_files2.
DATA: itab_plint_usr_tdwp TYPE TABLE OF zplint_usr_tdwp.
DATA: itab_filetype TYPE TABLE OF tdwp.
DATA: itab_node TYPE treemsnota.
DATA: itab_prioritaeten TYPE TABLE OF zcl_prioritaeten.
DATA: itab_fail_document TYPE TABLE OF zcl_s_fail_document.
DATA: itab_draw TYPE TABLE OF draw.
DATA: itab_stempel_wert TYPE TABLE OF zcl_s_stempel_value.
DATA: itab_stempel_default TYPE TABLE OF zcl_stamp_defaul.
DATA: itab_stempel_user TYPE TABLE OF zcl_stamp_user.
DATA: itab_stempel_voreinstellung TYPE TABLE OF zcl_stamp_vorein.
DATA: itab_stempel_verteiler TYPE TABLE OF zcl_stamp_vertei.
DATA: itab_info LIKE TABLE OF zcl_s_line_255.
DATA: itab_info_pa LIKE TABLE OF zcl_s_line_255.
DATA: itab_mat_status_exc TYPE TABLE OF mstae.
DATA: itab_pl_jobs1 TYPE TABLE OF /cideon/pl_jobs1.
DATA: itab_pl_jobs2 TYPE TABLE OF /cideon/pl_jobs2.
DATA: itab_pl_jobsc TYPE TABLE OF /cideon/pl_jobsc.
DATA: itab_pl_jobss TYPE TABLE OF /cideon/pl_jobss.
DATA: it_notiz TYPE TABLE OF zcl_stempel_wert.

DATA: it_sdpartner TYPE TABLE OF /cideon/sdpartner. "sdpartnerlist.
DATA: it_vbpa TYPE TABLE OF vbpa.

*WA
*DATA: wa_docs type  t_docsearch.
DATA: wa_search TYPE  zcl_s_docsearch.
DATA: wa_search_tmp LIKE zcl_s_docsearch. "draw.
DATA: wa_plotjobs LIKE zcl_s_plotlist.
DATA: wa_akt_plotjobs LIKE zcl_s_plotlist.
DATA: wa_old_plotjobs LIKE zcl_s_plotlist.
DATA: wa_akt_search TYPE  zcl_s_docsearch.
DATA: wa_zori_doc_files TYPE zori_doc_files.
DATA: wa_itab_node TYPE treemsnodt.
DATA: wa_zori_doc_files_detail TYPE bapi_doc_files2. "Sri..
DATA: wa_plint_usr_tdwp TYPE zplint_usr_tdwp.
DATA: wa_tdwp LIKE tdwp.
DATA: wa_view_program LIKE zcl_plint_usr_vw.
DATA: wa_default_verteiler LIKE zcl_voreinstell.
DATA: wa_voreinstellung LIKE zcl_voreinstell.
DATA: wa_verteiler LIKE zcl_verteiler.
DATA: wa_bedingung LIKE zcl_bedingung.
DATA: wa_usr_host_cfg LIKE zcl_usr_host_cfg.
DATA: wa_prioritaeten TYPE zcl_prioritaeten.
DATA: wa_fail_document TYPE zcl_s_fail_document.
DATA: wa_tmp_plotjobs TYPE zcl_s_plotlist.
DATA: wa_draw TYPE draw.
DATA: wa_appl_comp TYPE zcl_appl_comp.
DATA: wa_appl_type TYPE zcl_appl_type.
DATA: wa_stempel_wert TYPE zcl_s_stempel_value.
DATA: wa_stempel_default TYPE zcl_stamp_defaul.
DATA: wa_stempel_user TYPE zcl_stamp_user.
DATA: wa_stempel_voreinstellung TYPE zcl_stamp_vorein.
DATA: wa_stempel_verteiler TYPE zcl_stamp_vertei.
DATA: wa_info TYPE zcl_s_info.
DATA: wa_itab_info TYPE zcl_s_line_255.
DATA: wa_itab_info_pa TYPE zcl_s_line_255.
DATA: wa_prog_info TYPE zcl_prog_info.
DATA: wa_prog_info_pa TYPE zcl_prog_info_pa.
DATA: wa_mat_status_exc TYPE mstae.
DATA: wa_pl_jobs1 TYPE /cideon/pl_jobs1.
DATA: wa_pl_jobs2 TYPE /cideon/pl_jobs2.
DATA: wa_pl_jobs3 TYPE /cideon/pl_jobs3.
DATA: wa_pl_jobsc TYPE /cideon/pl_jobsc.
DATA: wa_pl_jobss TYPE /cideon/pl_jobss.
DATA: wa_notiz TYPE zcl_stempel_wert.

DATA: wa_sdpartner TYPE /cideon/sdpartner. "sdpartnerlist.
DATA: wa_vbpa TYPE vbpa.

*normal
DATA: count_lines TYPE i .
DATA: index_itab_plotjobs TYPE i.
DATA: index_itab_searchlist TYPE i.
DATA: index_itab_plotjobs_tmp TYPE i.
DATA: repid LIKE sy-repid.
DATA: g_repid LIKE sy-repid.
DATA: dynnr LIKE sy-dynnr.

DATA: g_event(30).
DATA: g_node_key TYPE string. "(30) TYPE c.
DATA:  x_save_searchlist VALUE 'A'.
DATA:  gs_layout_searchlist TYPE disvariant.
DATA:  x_save_plotlist VALUE 'A'.
DATA:  gs_layout_plotlist TYPE disvariant.


DATA:  x_save_sdlist VALUE 'A'.
DATA:  gs_layout_sdlist TYPE disvariant.



DATA: user_data TYPE /cideon/plot_userdata. "t_userdata.
DATA: default_data TYPE /cideon/plot_defaultdata. "t_defaultdata.

DATA: init VALUE ''.
DATA: init_aufnr VALUE ''.
DATA: init_vbeln VALUE ''.
DATA: init_firma VALUE ''.
DATA: init_kostl VALUE ''.
DATA: init_id_plotjob VALUE ''.
DATA: init_pspid VALUE ''.
DATA: init_lifnr VALUE ''.
DATA: init_ebeln VALUE ''.

DATA: edit_aufnr VALUE ''.
DATA: edit_vbeln VALUE ''.
DATA: edit_firma VALUE ''.
DATA: edit_kostl VALUE ''.
DATA: edit_id_plotjob VALUE ''.
DATA: edit_pspid VALUE ''.
DATA: edit_lifnr VALUE ''.
DATA: edit_ebeln VALUE ''.

DATA: g_id_plotjob TYPE zcl_s_plotlist-id_plotjob.
DATA: g_id_plotjob_32 TYPE zcl_s_plotlist-id_plotjob_32.

DATA: g_prio LIKE zcl_s_plotlist-prio.

DATA: f_paste VALUE ''.
DATA: f_error VALUE ''.
DATA: f_f4_voreinstellung VALUE ''.
DATA: f_no_auth VALUE ''.

DATA: str_down_path TYPE string.
DATA: str_ppl_down_path TYPE string.

DATA: msgv1 TYPE symsgv.
DATA: msgv2 TYPE symsgv.
DATA: msgv3 TYPE symsgv.
DATA: msgv4 TYPE symsgv.

DATA: index_itab_tmp_plotjobs_2 TYPE sy-tabix.

DATA: titlebar(70).
DATA: count_search TYPE i.
DATA: count_plot TYPE i.
DATA: count_queue TYPE i.

DATA: count_search_c(5).
DATA: count_plot_c(5).
DATA: count_queue_c(5).

DATA: answer(1).

DATA: g_version TYPE string.
DATA: g_prog_name TYPE string.
DATA: g_use_till TYPE sy-datum.
DATA: g_versions_typ TYPE string.

DATA: gs_frontend LIKE dms_frontend_data.

DATA: g_dms_max_tmp_files(10).
DATA: g_show_draw_detail VALUE 'X'.
DATA: g_search_list_dynpro(4) VALUE '0101'.

DATA: g_show_struktur VALUE 'X'.
DATA: g_plot_list_dynpro(4) VALUE '0102'.

DATA: f_audit_trail_confirm_no VALUE ''.

* Flags
DATA: f_bypass(1).
DATA: f_update_itab_search(1).
DATA: f_view_log(1).
DATA: f_cancel_send(1).


*CHECKBOXES
DATA: cb_spiegeln.
DATA: cb_falten.
DATA: cb_lochen.
DATA: cb_knz_inhalt_vz.



*CL Coustom Controls
DATA: grid_searchlist TYPE REF TO cl_gui_alv_grid.
DATA: container_grid_searchlist TYPE REF TO cl_gui_custom_container.
DATA: ref_sl_dock_container TYPE REF TO cl_gui_docking_container.


DATA: grid_plotlist TYPE REF TO cl_gui_alv_grid.
DATA: container_grid_plotlist TYPE REF TO cl_gui_custom_container.

*DATA: splitter_plotlist TYPE REF TO cl_gui_splitter_container.
*DATA: container_alv_plotlist TYPE REF TO cl_gui_container.
*DATA: container_tree_plotlist TYPE REF TO cl_gui_container.
DATA: container_tree_plotlist TYPE REF TO cl_gui_custom_container.

DATA: simple_tree_plotlist TYPE REF TO cl_simple_tree_model.

*DATA: docking_searchlist type ref to cl_gui_docking_container.

DATA: grid_sdpartner TYPE REF TO cl_gui_alv_grid.
DATA: cc_sdpartner TYPE REF TO cl_gui_custom_container.


*LAYOUT
DATA: g_layo_grid_searchlist TYPE lvc_s_layo.
DATA: g_layo_grid_plotlist TYPE lvc_s_layo.

*FieldKatalog
DATA: g_fc_grid_searchlist TYPE  lvc_t_fcat.
DATA: g_fc_grid_plotlist TYPE  lvc_t_fcat.
DATA: wa_fc_grid_searchlist TYPE lvc_s_fcat.
DATA: wa_fc_grid_plotlist TYPE  lvc_s_fcat.


*LVC_T_ROW
DATA: itab_et_index_rows_plotlist TYPE lvc_t_row.
DATA: itab_et_index_rows_searchlist  TYPE lvc_t_row.
DATA: itab_et_index_rows_plotlist_o TYPE lvc_t_row.

DATA: lt_sel_searchlist_gl  TYPE lvc_t_row.
DATA: lc_sel_searchlist_gl  TYPE lvc_s_row.

DATA: wa_et_index_rows_plotlist TYPE lvc_s_row.
DATA: wa_et_index_rows_searchlist TYPE lvc_s_row.

*Toolbars
DATA: searchlist_toolbar  TYPE stb_button.
DATA: plotlist_toolbar  TYPE stb_button.
DATA: g_searchlist_toolbar TYPE REF TO cl_gui_toolbar.
DATA: g_plotlist_toolbar TYPE REF TO cl_gui_toolbar.

DATA: itab_tb_ex_searchlist TYPE ui_functions.
DATA: itab_tb_ex_plotlist TYPE ui_functions.

*Events
DATA: itab_events TYPE cntl_simple_events.
DATA: wa_events TYPE LINE OF cntl_simple_events.

*Menü
DATA: l_disable TYPE ui_functions.
DATA: menu_plotlist TYPE REF TO cl_ctmenu.



*Dynamisches TOC
DATA: f_dyn_toc VALUE ''.
DATA: f_dyn_COV VALUE ''.

LOAD-OF-PROGRAM.
************************************************************************
* Initialisierung von globalen Variable zu Programmstart

* Abfrage "Langsame Verbindung"
  CALL FUNCTION 'SAPGUI_GET_WAN_FLAG'
       IMPORTING
            wan_flag = gf_slow_connection.


  DATA: f_alv_plotlist VALUE ''.
  DATA: f_tree_plotlist VALUE ''.
