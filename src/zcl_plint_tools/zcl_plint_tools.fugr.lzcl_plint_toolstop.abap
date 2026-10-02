function-pool zcl_plint_tools.              "MESSAGE-ID ..


"include z_cl_plint_tools_const.
include /CIDEON/PLOT_TOOLS_CONST.

include <icon>.

include /cideon/_konstanten.
*include zcl_konstanten.


*TYPES
types:
  begin of t_ini_data_tab,
    line(100),
  end of t_ini_data_tab.
types:
  begin of t_itab_ini,
    key(50),
    value(100),
  end of t_itab_ini.
*ITAB
data: ini_data_tab type table of t_ini_data_tab.
data: itab_ini type table of t_itab_ini.
data: itab_fail_document_alv type table of zcl_s_fail_document_alv.
data: itab_tmp_fail_document type table of zcl_s_fail_document.
data: itab_zori_doc_files_alv type table of zori_doc_files.
data: itab_zori_doc_files_detail type table of bapi_doc_files2.
data: itab_tmp_zori_doc_files type table of zori_doc_files.
data: itab_tmp_zori_doc_files_detail type table of bapi_doc_files2.
data: itab_search type table of zcl_s_docsearch.
data: itab_info type table of zcl_s_info.
data: itab_info_pa type table of zcl_s_info.
data: it_draw type table of draw.
*WA
data: wa_plotjobs type zcl_s_plotlist.
data: wa_plotjobs_alt type zcl_s_plotlist.
data: wa_tdwp like tdwp.
data: wa_repro_cl_ini type zcl_repro_cl_ini.
data: wa_stamp_cl_ini type zcl_stamp_cl_ini.
data: wa_fail_document_alv type zcl_s_fail_document_alv.
data: wa_fail_document type zcl_s_fail_document.
data: wa_tmp_fail_document type zcl_s_fail_document.
data: wa_tmp_zori_doc_files type zori_doc_files.
data: wa_tmp_zori_doc_files_detail type bapi_doc_files2.
data: wa_zori_doc_files_alv type zori_doc_files.
data: wa_zori_doc_files type zori_doc_files.
data: wa_search type zcl_s_docsearch.
data: wa_info type zcl_s_info.
data: wa_prog_info type zcl_prog_info.
data: wa_prog_info_pa type zcl_prog_info_pa.
data: wa_ini_data_tab type t_ini_data_tab.
data: wa_draw type draw.

"data: zcl_s_draw01 type zcl_s_draw01.
tables: zcl_s_draw01.

data: wa_zcl_s_draw01 type zcl_s_draw01.

*normal
data: ok_code(20).
data: url(2048).
data: g_mimetype like tdwp-mimetype.
data: g_mimetype_1 like tdwp-mimetype.
data: g_mimetype_2 like tdwp-mimetype. "subtype

data: prio like zcl_s_plotlist-prio.
data: g_prio like zcl_s_plotlist-prio.
data: prio_von like zcl_s_plotlist-prio.
data: prio_bis like zcl_s_plotlist-prio.
data: g_draw_doknr type draw-doknr.
data: g_draw_dokar type draw-dokar.
data: doknr like draw-doknr.
data: dokar type draw-dokar.
data: g_draw_dokvr type draw-dokvr.
data: g_draw_doktl type draw-doktl.
data: dokvr like draw-dokvr.
data: doktl type draw-doktl.


data: default_uname type xubname.
data: user_name type xubname.
data: pwert type pwert.
data: pname type pname.
data: tmp_str(50).
data: tmp_string type string.
data: path_string type string.


data: preprozessor type zcl_name_preprozessor.

types: t_line(256) type c.
data: l_pict_tab type table of t_line.
data: l_url(255) type c.

data: picture_height type i.
data: picture_width type i.

data: g_led_style(1).
data: g_first(1).

data: index_itab_fail_doc type sy-tabix.

data: g_version type string.
data: g_prog_name type string.

*DATA: ask_vbeln TYPE vbeln.
data: ask_vbeln type zcl_s_vbeln-vbeln.
*DATA: ask_aufnr TYPE aufnr.
data: ask_aufnr type zcl_s_aufnr-aufnr.
data: ask_verteiler type zcl_name_verteiler.
data: ask_kopien type zcl_s_plotlist-kopien.
data: ask_notiz type zcl_s_plotlist-notiz.

data: uname type sy-uname.
data: default_nutzer type sy-uname.
data: tmp_sy_repid type sy-repid.

data: versions_typ(20) type c.
data: anzahl_nutzer type i.

data: speicher_ort_fb_liste type filep.
data: knz_static_fb_liste(1).
data: trennzeichen_fb_liste(1).
data: knz_dialog_fb_liste(1).



*Customcontrols
data: view_container type ref to cl_gui_custom_container.
data: viewer type ref to i_oi_document_viewer.
data: cc_picture type ref to cl_gui_custom_container.
data: fail_document_container type ref to cl_gui_custom_container.
data: fail_document_alv type ref to cl_gui_alv_grid.
data: zori_document_container type ref to cl_gui_custom_container.
data: zori_document_alv type ref to cl_gui_alv_grid.
data: info_edit_container type ref to cl_gui_custom_container.
data: info_edit type ref to cl_gui_textedit.

data: info_edit_container_pa type ref to cl_gui_custom_container.
data: info_edit_pa type ref to cl_gui_textedit.

controls tabcontrol_info type tabstrip.



data:  lf_type(3)   type c,
       lf_state     type i,
       lf_alignment type i.


data: gf_view        type ref to cl_gui_ecl_primaryviewer,
      gf_view_cont   type ref to cl_gui_custom_container,
      gf_view_box    type ref to cl_gui_dialogbox_container,
      gf_view_3d     type ref to cl_gui_ecl_3dviewer,
      gf_view_2d     type ref to cl_gui_ecl_2dviewer,
      gf_view_3d_mup type ref to cl_gui_ecl_2dviewer.
data: picture type ref to cl_gui_picture.

data: pf_tools(30)      .
data: lf_result   type i.

data: filename_tmp type file_name.


data: itab_fc_fail_document type lvc_t_fcat .
data: wa_fc_fail_document type alv_s_fcat.

data: g_layo_fail_document_alv type lvc_s_layo.
data: g_layo_zori_alv type lvc_s_layo.

*LVC_T_ROW
data: itab_et_index_rows_fail_doc type lvc_t_row.
data: wa_et_index_rows_fail_doc type lvc_s_row.
data: itab_et_index_rows_zori_doc type lvc_t_row.
data: wa_et_index_rows_zori_doc type lvc_s_row.


data: html_control type ref to cl_gui_html_viewer,
      my_container type ref to cl_gui_custom_container,
      fcode like sy-ucomm,
      myevent_tab type cntl_simple_events,
      myevent type cntl_simple_event,
      edurl(2048),
      alignment type i.


data: html_dock_container type ref to cl_gui_docking_container.



include zcl_plint_tool_classes.

data: evt_receiver type ref to cl_myevent_handler.

data: list_handler type ref to lcl_event_handler_fail_doc_alv .


************************************************************************
************************************************************************


** for BAPI_DOC_CHECKOUTVIEW2
*TABLES: drad,
*        drat,
*        draw,
*        mcdokob,
*        tdwst,
*        tdwa,
*        tdwat,
*        t002.
*
*CONSTANTS:
*  c_message_id_26   LIKE t100-arbgb  VALUE '26',
*  c_msg_create      LIKE syst-msgno  VALUE '001',
*  c_msg_change      LIKE syst-msgno  VALUE '041',
*  c_cv01            LIKE syst-tcode  VALUE 'CV01',
*  c_cv02            LIKE syst-tcode  VALUE 'CV02',
*  c_copy_class_data LIKE mcdok-maraf VALUE 'X',
*  c_draw_type       LIKE tcla-obtab  VALUE 'DRAW',
*  c_bapi_doc_draw   LIKE dntab-tabname  VALUE 'BAPI_DOC_DRAW',
*  c_bapi_doc_drawx  LIKE dntab-tabname  VALUE 'BAPI_DOC_DRAWX',
*  c_bapi_doc_draw2  LIKE dntab-tabname  VALUE 'BAPI_DOC_DRAW2',
*  c_bapi_doc_drawx2 LIKE dntab-tabname  VALUE 'BAPI_DOC_DRAWX2',
*  c_fkt_delete(3)   TYPE c VALUE '003',
*  c_fkt_change(3)   TYPE c VALUE '002',
*  c_fkt_new(3)      TYPE c VALUE '001',
*  c_doc_delete      TYPE c VALUE 'D'.
*
*CONSTANTS:
*  c_vault      LIKE draw-dttrg VALUE 'VAULT',
*  c_dvault     LIKE draw-dttrg VALUE 'DVA-VAULT',
*  c_sapdb      LIKE draw-dttrg VALUE 'SAP-SYSTEM',
*  c_archive    LIKE draw-dttrg VALUE 'ARCHIV',
*  c_filesystem LIKE draw-dttrg VALUE 'FILESYS',
*  c_thirdparty LIKE draw-dttrg VALUE 'THIRDP',
*  c_printer    LIKE draw-dttrg VALUE 'PRINTER'.
*
*
***
*---------------------------------------------------------------------
*** Global data
***
*---------------------------------------------------------------------
*** Bapi-Messages (Bapi-Return)
*DATA: bapi_message LIKE messages.
*
*TYPES: BEGIN OF tp_bapi_drad,
*         function LIKE bapi_doc_drad-deletevalue.
*INCLUDE  STRUCTURE drad.
*TYPES: END OF tp_bapi_drad.
*
*** Data for Up- & Download
*TYPES: BEGIN OF ts_data,
*          line(2550) TYPE x.
*TYPES: END OF ts_data.
*
*** Key-structure for Lontexts
*TYPES:BEGIN OF ts_drawkey,
*          mandt LIKE sy-mandt,
*          dokar LIKE draw-dokar,
*          doknr LIKE draw-doknr,
*          dokvr LIKE draw-dokvr,
*          doktl LIKE draw-doktl.
*TYPES: END OF ts_drawkey.
*
*
*DATA:  gf_destination    LIKE rfcdes-rfcdest,
*       gf_hostname       LIKE tdwd-ntadr,
*       gf_frontend_type  LIKE tdwd-typdt,
*       gf_gui_exist(1)   TYPE c,
*       gf_gui_checked(1) TYPE c,
*
*** call in update task
*       gf_no_update_task(1) TYPE c.
*
*
***
*---------------------------------------------------------------------
***
*---------------------------------------------------------------------
*DATA: BEGIN OF aux_bapi_drad OCCURS 20,
*        dokob LIKE drad-dokob.
*        INCLUDE STRUCTURE mcdokob.
*DATA: END   OF aux_bapi_drad.
*
*
*TYPES: BEGIN OF lt_doc_keys,
*         documentnumber TYPE bapi_doc_keys-documentnumber,
*         documenttype TYPE bapi_doc_keys-documenttype,
*         documentpart TYPE bapi_doc_keys-documentpart,
*         documentversion TYPE bapi_doc_keys-documentversion,
*         tab_index TYPE sy-tabix,
*         END OF lt_doc_keys.
*
*TYPES ht_doc_keys TYPE
*     HASHED TABLE OF lt_doc_keys
*     WITH UNIQUE KEY documentnumber documenttype
*                     documentpart.
*
*TYPES st_doc_keys TYPE
*     STANDARD TABLE OF lt_doc_keys.
*
***********************************************************************
*INCLUDE: cv_constants,
*         cv_data_definitions.
*
*** content of the documents
*DATA: gt_drao      LIKE drao OCCURS 0 WITH HEADER LINE,
*      gt_draoz     LIKE drao OCCURS 0 WITH HEADER LINE,
*      gt_toav0     LIKE drao OCCURS 0 WITH HEADER LINE,
*      gt_draz      LIKE draz OCCURS 0 WITH HEADER LINE,
*      gs_audits    LIKE dms_audits,
*      gt_kpro_data TYPE dms_tbl_file.
*
*** Messages
*DATA: gs_message LIKE messages.
*
*** Global data
** Documenttype-defintions
*DATA: gs_tdwa LIKE tdwa.
*
*DATA:
*** Status-management active ?
*  gf_status_management(1) TYPE c,
*
*** Create or Change
*  gf_transaction LIKE sy-tcode,
*
*** ALE-flag
*  gf_ale_active(1) TYPE c,
*
*** FTP-destination registered
*  gf_reg_ftp_dest TYPE rfcdest,
*
*** Checklevel:
**  0: no check of status, fields
*  gf_check_level(1) TYPE c,
*
*** Loadflag: loading of data (BDBR) active
*  gf_load_flag(1) TYPE c.
*
*** Inline-viewing EAI
*DATA: gf_first_eai_inst(1) TYPE c,
*      gf_first_oi_inst(1)  TYPE c.
*
*
*
** Test ab 4.6c PATCH 50
*DATA: gf_auto_commit TYPE c VALUE ' '.
