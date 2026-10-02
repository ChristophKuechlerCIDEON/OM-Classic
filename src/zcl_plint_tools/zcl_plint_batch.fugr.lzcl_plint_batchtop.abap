function-pool zcl_plint_batch.              "MESSAGE-ID ..

include <cntn01>.
include /CIDEON/_KONSTANTEN.
*include zcl_konstanten.
include <icon>.

*Tables
tables: draw.
tables: drat.
tables: tfdir.
tables: rsinfdir.

*ITAB
data: itab_items_fauf type table of zcl_pdm_objects_fa_int,
*      itab_documents TYPE TABLE OF plm_document WITH HEADER LINE,
*      itab_documents_add  TYPE TABLE OF plm_document,
* bereitet bei einem Kunden ohne PLM Probleme ...
      itab_draw type table of draw,
      itab_mat_status_exc type table of mstae,
      itab_search type table of  zcl_s_docsearch,
      itab_plint_usr_tdwp type table of zplint_usr_tdwp,
      itab_filetype type table of tdwp.
data: itab_draw_2 type table of draw.
data: itab_zori_doc_files_3 type table of zori_doc_files.
data: itab_zori_doc_files_detail_3 type table of bapi_doc_files2.
data: itab_fail_document_3 type table of zcl_s_fail_document.
data: itab_zori_doc_files type table of zori_doc_files.
data: itab_zori_doc_files_detail type table of bapi_doc_files2.
data: itab_fail_document type table of zcl_s_fail_document.
data : begin of it_tdwp occurs 0,
         dappl like tdwp-dappl,
         cvtext like tdwp-cvtext,
         dateifrmt like tdwp-dateifrmt,
         flag,       "flag for mark column
       end of it_tdwp.
data: itab_plotjobs type table of  zcl_s_plotlist.
data: itab_tmp_plotjobs type table of  zcl_s_plotlist.
data: itab_tmp_plotjobs_2 type table of  zcl_s_plotlist.
data: itab_tmp_plotjobs_3 type table of  zcl_s_plotlist.
data: itab_stempel_wert type table of zcl_s_stempel_value.
data: itab_stempel_default type table of zcl_stamp_defaul.
data: itab_stempel_user type table of zcl_stamp_user.
data: itab_stempel_voreinstellung type table of zcl_stamp_vorein.
data: itab_stempel_verteiler type table of zcl_stamp_vertei.

*WA
data: wa_default_data type /cideon/plot_defaultdata,
      wa_user_data type /cideon/plot_userdata,
      wa_item_fauf type zcl_pdm_objects_fa_int,
      wa_draw type draw,
      wa_stored_search type zcl_psb_tmp,
      wa_default_verteiler like zcl_voreinstell,
      wa_mat_status_exc type mstae,
      wa_search type zcl_s_docsearch,
      wa_plint_usr_tdwp type zplint_usr_tdwp,
      wa_tdwp like tdwp,
      wa_filetype type tdwp.
data: wa_draw_2 type draw.
data: wa_zori_doc_files type zori_doc_files.
data: wa_zori_doc_files_detail type bapi_doc_files2. "Sri..
data: wa_fail_document type zcl_s_fail_document.
data: wa_tmp_plotjobs type zcl_s_plotlist.
data: wa_tmp_plotjobs_2 type zcl_s_plotlist.
data: wa_plotjobs like zcl_s_plotlist.
data: wa_voreinstellung like zcl_voreinstell.
data: wa_verteiler like zcl_verteiler.
data: wa_bedingung like zcl_bedingung.
data: wa_pl_jobs1 type /cideon/pl_jobs1.
data: wa_pl_jobs2 type /cideon/pl_jobs2.
data: wa_pl_jobs3 type /cideon/pl_jobs3.
data: wa_pl_jobsc type /cideon/pl_jobsc.
data: wa_pl_jobss type /cideon/pl_jobss.
data: wa_stempel_wert type zcl_s_stempel_value.
data: wa_stempel_default type zcl_stamp_defaul.
data: wa_stempel_user type zcl_stamp_user.
data: wa_stempel_voreinstellung type zcl_stamp_vorein.
data: wa_stempel_verteiler type zcl_stamp_vertei.

*VARIABLE
data:  g_user type xubname,
       g_draw_key type cvdidrawkey,
       g_documentstatus type draw-dokst,
       g_documentstatus_old type draw-dokst.
data:  g_id_plotjob type zcl_s_plotlist-id_plotjob.

data: index_itab_draw_2 type sy-tabix.
data: index_itab_tmp_plotjobs_2 type sy-tabix.
data: str_down_path type string.
data: str_ppl_down_path type string.

data: g_dms_max_tmp_files(10).
data: count_lines type i .

data: text1 type symsgv.
data: text2 type symsgv.
data: text3 type symsgv.
data: text4 type symsgv.
data: f_new_head type c.
data: f_first type c.
