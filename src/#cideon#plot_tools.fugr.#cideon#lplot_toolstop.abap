FUNCTION-POOL /cideon/plot_tools.           "MESSAGE-ID ..

"INCLUDE /cideon/plot_tools_const.

INCLUDE <icon>.

INCLUDE /cideon/_konstanten.


*TYPES
TYPES:
  BEGIN OF t_ini_data_tab,
    line(100),
  END OF t_ini_data_tab.
TYPES:
  BEGIN OF t_itab_ini,
    key(50),
    value(100),
  END OF t_itab_ini.
*ITAB
DATA: ini_data_tab TYPE TABLE OF t_ini_data_tab.
DATA: itab_ini TYPE TABLE OF t_itab_ini.
DATA: itab_fail_document_alv TYPE TABLE OF zcl_s_fail_document_alv.
DATA: itab_tmp_fail_document TYPE TABLE OF zcl_s_fail_document.
DATA: itab_zori_doc_files_alv TYPE TABLE OF zori_doc_files.
DATA: itab_zori_doc_files_detail TYPE TABLE OF bapi_doc_files2.
DATA: itab_tmp_zori_doc_files TYPE TABLE OF zori_doc_files.
DATA: itab_tmp_zori_doc_files_detail TYPE TABLE OF bapi_doc_files2.
DATA: itab_search TYPE TABLE OF zcl_s_docsearch.
DATA: itab_info TYPE TABLE OF zcl_s_info.
DATA: itab_info_pa TYPE TABLE OF zcl_s_info.
DATA: it_draw TYPE TABLE OF draw.
*WA
DATA: wa_plotjobs TYPE zcl_s_plotlist.
DATA: wa_plotjobs_alt TYPE zcl_s_plotlist.
DATA: wa_tdwp LIKE tdwp.
DATA: wa_repro_cl_ini TYPE zcl_repro_cl_ini.
DATA: wa_stamp_cl_ini TYPE zcl_stamp_cl_ini.
DATA: wa_fail_document_alv TYPE zcl_s_fail_document_alv.
DATA: wa_fail_document TYPE zcl_s_fail_document.
DATA: wa_tmp_fail_document TYPE zcl_s_fail_document.
DATA: wa_tmp_zori_doc_files TYPE zori_doc_files.
DATA: wa_tmp_zori_doc_files_detail TYPE bapi_doc_files2.
DATA: wa_zori_doc_files_alv TYPE zori_doc_files.
DATA: wa_zori_doc_files TYPE zori_doc_files.
DATA: wa_search TYPE zcl_s_docsearch.
DATA: wa_info TYPE zcl_s_info.
DATA: wa_prog_info TYPE zcl_prog_info.
DATA: wa_prog_info_pa TYPE zcl_prog_info_pa.
DATA: wa_ini_data_tab TYPE t_ini_data_tab.
DATA: wa_draw TYPE draw.

"data: zcl_s_draw01 type zcl_s_draw01.
TABLES: zcl_s_draw01.

DATA: wa_zcl_s_draw01 TYPE zcl_s_draw01.

*normal
DATA: ok_code(20).
DATA: url(2048).
DATA: g_mimetype LIKE tdwp-mimetype.
DATA: g_mimetype_1 LIKE tdwp-mimetype.
DATA: g_mimetype_2 LIKE tdwp-mimetype. "subtype

DATA: prio LIKE zcl_s_plotlist-prio.
DATA: g_prio LIKE zcl_s_plotlist-prio.
DATA: prio_von LIKE zcl_s_plotlist-prio.
DATA: prio_bis LIKE zcl_s_plotlist-prio.
DATA: g_draw_doknr TYPE draw-doknr.
DATA: g_draw_dokar TYPE draw-dokar.
DATA: doknr LIKE draw-doknr.
DATA: dokar TYPE draw-dokar.
DATA: g_draw_dokvr TYPE draw-dokvr.
DATA: g_draw_doktl TYPE draw-doktl.
DATA: dokvr LIKE draw-dokvr.
DATA: doktl TYPE draw-doktl.


DATA: default_uname TYPE xubname.
DATA: user_name TYPE xubname.
DATA: pwert TYPE pwert.
DATA: pname TYPE pname.
DATA: tmp_str(50).
DATA: tmp_string TYPE string.
DATA: path_string TYPE string.


DATA: preprozessor TYPE zcl_name_preprozessor.

TYPES: t_line(256) TYPE c.
DATA: l_pict_tab TYPE TABLE OF t_line.
DATA: l_url(255) TYPE c.

DATA: picture_height TYPE i.
DATA: picture_width TYPE i.

DATA: g_led_style(1).
DATA: g_first(1).

DATA: index_itab_fail_doc TYPE sy-tabix.

DATA: g_version TYPE string.
DATA: g_prog_name TYPE string.

*DATA: ask_vbeln TYPE vbeln.
DATA: ask_vbeln TYPE zcl_s_vbeln-vbeln.
*DATA: ask_aufnr TYPE aufnr.
DATA: ask_aufnr TYPE zcl_s_aufnr-aufnr.
DATA: ask_verteiler TYPE zcl_name_verteiler.
DATA: ask_kopien TYPE zcl_s_plotlist-kopien.
DATA: ask_notiz TYPE zcl_s_plotlist-notiz.

DATA: uname TYPE sy-uname.
DATA: default_nutzer TYPE sy-uname.
DATA: tmp_sy_repid TYPE sy-repid.

DATA: versions_typ(20) TYPE c.
DATA: anzahl_nutzer TYPE i.

DATA: speicher_ort_fb_liste TYPE filep.
DATA: knz_static_fb_liste(1).
DATA: trennzeichen_fb_liste(1).
DATA: knz_dialog_fb_liste(1).

*TYPES
TYPES:
  BEGIN OF t_default_data,
    mat_capid TYPE tc04-capid,
    mat_stpst TYPE stpox-stufe,
  END OF t_default_data.
TYPES:
  BEGIN OF t_user_data,
    mat_capid TYPE tc04-capid,
    uname TYPE sy-uname,
    mat_stpst TYPE stpox-stufe,
  END OF t_user_data.


*WA
DATA: default_data TYPE t_default_data.
DATA: user_data TYPE t_user_data.
