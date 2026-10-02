FUNCTION-POOL /cideon/plot_basis MESSAGE-ID c$.

*TYPES
TYPES: BEGIN OF range_t,
         sign LIKE ddshselopt-sign,
         option LIKE ddshselopt-option,
         low LIKE ddshselopt-low,
         high LIKE ddshselopt-high,
       END OF range_t.

*RANGES
DATA:  range_tab TYPE range_t OCCURS 0,
       ls_tab_field    TYPE rstabfield.

*DATA: so_dokar TYPE range_t OCCURS 0.
DATA: so_dokar TYPE rsdsselopt OCCURS 0.
DATA: so_doknr TYPE rsdsselopt OCCURS 0.
DATA: so_doktl TYPE rsdsselopt OCCURS 0.
DATA: so_dokvr TYPE rsdsselopt OCCURS 0.
DATA: so_dokar_links TYPE rsdsselopt OCCURS 0.


*TABLES:
TABLES: tfdir.
TABLES: rsinfdir.
TABLES: draw.

DATA: c_status_aktiv(2) VALUE '10'.

DATA: c_ja(2) VALUE 'JA'.
DATA: c_nein(4) VALUE 'NEIN'.
DATA: c_aus(3) VALUE 'AUS'.
DATA: c_ein(3) VALUE 'EIN'.


CONSTANTS: c_sl_object_type TYPE object_type VALUE 'STUECKLIST'.
CONSTANTS: c_lk_object_type TYPE object_type VALUE 'LINK'.
CONSTANTS: c_hr_object_type TYPE object_type VALUE 'HIERACHIE'.
CONSTANTS: c_fg_object_type TYPE object_type VALUE 'FOLGE'.
CONSTANTS: c_vg_object_type TYPE object_type VALUE 'VORGANG'.

CONSTANTS: c_user_group_wsapp_selection TYPE zcl_usr_grp VALUE 'SELECT'.


DATA: ok_code LIKE sy-ucomm.

* ITAB
DATA: itab_documentfiles TYPE TABLE OF bapi_doc_files2.
DATA: itab_documentfiles_tmp TYPE TABLE OF bapi_doc_files2.
DATA: itab_mast TYPE TABLE OF mast.
DATA: it_text TYPE TABLE OF zcl_stempel_wert.
DATA: it_text_stream TYPE TABLE OF string.


* WA
DATA: wa_documentfiles TYPE bapi_doc_files2.
DATA: wa_mast TYPE mast.
DATA: wa_text TYPE zcl_stempel_wert.


DATA: doknr LIKE draw-doknr.
DATA: dokar TYPE draw-dokar.
DATA: dokvr LIKE draw-dokvr.
DATA: doktl TYPE draw-doktl.
DATA: aennr TYPE draw-aennr.
DATA: ccdat TYPE ccdat.
DATA: matnr TYPE matnr.
DATA: capid TYPE capid.
DATA: stufe TYPE histu.

DATA: g_draw_doknr TYPE draw-doknr.
DATA: g_draw_dokar TYPE draw-dokar.
DATA: g_draw_dokvr TYPE draw-dokvr.
DATA: g_draw_doktl TYPE draw-doktl.
DATA: g_aennr TYPE draw-aennr.
DATA: g_ccdat TYPE ccdat.
DATA: g_matnr TYPE matnr.
DATA: g_capid TYPE capid.
DATA: g_stufe TYPE histu.

DATA: f_cs03.
DATA: f_cs11.
DATA: f_cs12.
DATA: f_cs13.

DATA: g_smartform_cs02 TYPE /cideon/smartform_cs02.
DATA: g_smartform_cs11 TYPE /cideon/smartform_cs11.
DATA: g_smartform_cs12 TYPE /cideon/smartform_cs12.
DATA: g_smartform_cs13 TYPE /cideon/smartform_cs13.

DATA: g_smartform_cs02_spr TYPE /cideon/smartform_cs02_spr.
DATA: g_smartform_cs11_spr TYPE /cideon/smartform_cs11_spr.
DATA: g_smartform_cs12_spr TYPE /cideon/smartform_cs12_spr.
DATA: g_smartform_cs13_spr TYPE /cideon/smartform_cs13_spr.


DATA: g_f_valid_docs TYPE char1.


DATA: g_converter_spec_name TYPE converter_spec_name.


DATA: zcl_s_draw01 TYPE zcl_s_draw01.
DATA: wa_zcl_s_draw01 TYPE zcl_s_draw01.

*CL Coustom Controls
DATA: alv_originals TYPE REF TO cl_gui_alv_grid.
DATA: container_originals TYPE REF TO cl_gui_custom_container.

DATA: alv_originals_2 TYPE REF TO cl_gui_alv_grid.
DATA: container_originals_2 TYPE REF TO cl_gui_custom_container.

DATA: alv_mast TYPE REF TO cl_gui_alv_grid.
DATA: cc_mast TYPE REF TO cl_gui_custom_container.

DATA: cc_editor TYPE REF TO cl_gui_custom_container.
DATA: editor TYPE REF TO cl_gui_textedit.               .

*LAYOUT
DATA: g_layo_alv_originals_2 TYPE lvc_s_layo.

DATA:  gs_layout_alv_originals TYPE disvariant.
DATA:  gs_layout_alv_originals_2 TYPE disvariant.

DATA: g_layout_alv_mast TYPE lvc_s_layo.


*LVC_T_ROW
DATA: itab_et_index_rows_plotjobs TYPE lvc_t_row.

DATA: wa_et_index_rows_plotjobs TYPE lvc_s_row.

DATA: itab_et_index_rows_plotjobs_2 TYPE lvc_t_row.

DATA: wa_et_index_rows_plotjobs_2 TYPE lvc_s_row.

DATA: cb_links VALUE ''.
DATA: cb_where_used VALUE 'X'.
DATA: cb_delete_duplicates VALUE ''.
DATA: cb_valid_docs VALUE ''.

DATA: ask_lif_telnr_long LIKE zcl_s_plotlist-lif_telnr_long.
DATA: ask_lif_faxnr_long LIKE zcl_s_plotlist-lif_faxnr_long.
DATA: ask_lif_smtp_addr LIKE zcl_s_plotlist-lif_smtp_addr.


DATA: g_answer(1).



CLASS lcl_event_receiver_psrb_select DEFINITION DEFERRED.

DATA: gs_stored_search            TYPE zcl_psb_tmp,
      gc_sname_stored_search      TYPE tabname VALUE 'ZCL_PSB_TMP',
      gt_stored_search            LIKE TABLE OF gs_stored_search,
      gt_fields_stored_search     TYPE slis_t_fieldcat_alv,
      gt_stored_search_tmp        LIKE TABLE OF gs_stored_search,

      go_custom_container         TYPE REF TO cl_gui_custom_container,
      go_alv                      TYPE REF TO cl_gui_alv_grid,
      gs_layout                   TYPE lvc_s_layo,
      go_handler_alv
        TYPE REF TO lcl_event_receiver_psrb_select,
      gi_row                      TYPE i,
      gi_col                      TYPE i.
