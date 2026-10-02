*&---------------------------------------------------------------------*
*& Include ZCL_PLOT_FERTIGUNGSAUFTRAG_TOP                              *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  zcl_plot_fertigungsauftrag    .

INCLUDE zcl_plot_fertigungsauftrag_con.


* TYPES
* ITAB
DATA: itab_drad TYPE TABLE OF zcl_s_drad.
DATA: itab_mara TYPE TABLE OF mara.
DATA: itab_stpo TYPE TABLE OF stpo.
DATA: itab_dok TYPE TABLE OF stpox.
DATA: itab_txt TYPE TABLE OF stpox.
DATA: itab_mast TYPE TABLE OF mast.
DATA: itab_zcl_sl_tmp TYPE TABLE OF zcl_sl_tmp.

DATA: itab_afpo TYPE TABLE OF afpo.

DATA: itab_drad_to_plot TYPE TABLE OF zcl_s_drad.

* WA
DATA: wa_fertigung TYPE zcl_s_fertigungauftrag.
DATA: wa_drad TYPE zcl_s_drad.
DATA: wa_mara TYPE mara.
DATA: wa_stpo TYPE stpo.
DATA: wa_stpox TYPE stpox.
DATA: wa_mast TYPE mast.
DATA: wa_zcl_sl_tmp TYPE zcl_sl_tmp.

DATA: wa_aufk TYPE aufk.
DATA: wa_afko TYPE afko.
DATA: wa_afpo TYPE afpo.

DATA: wa_capid TYPE rc29l.
DATA: wa_stpos TYPE stpox.

* NORMAL
DATA: ok_code LIKE sy-ucomm.
DATA: save_ok_code LIKE sy-ucomm.
DATA: g_init(1).
DATA: g_exit(1).
DATA: count_lines TYPE i.
DATA: index_itab_drad TYPE i.

* CHECKBOXEN
DATA: cb_knz_sofort_plotten(1).
DATA: cb_knz_no_bypass(1).
DATA: cb_knz_dok_link(1).
DATA: cb_knz_mat_link(1).
DATA: cb_knz_txt_link(1).
DATA: cb_knz_aufpl_vorgaenge(1).
DATA: cb_knz_aufpl_folgen(1).
DATA: cb_knz_stl_aufl(1).
DATA: cb_knz_dok_stl_aufl(1).
DATA: cb_knz_dok_link_aufl(1).
DATA: cb_knz_dok_hier_aufl(1).
DATA: cb_knz_dok_stl_aufl_mehrst(1).
DATA: cb_knz_dok_link_aufl_mehrst(1).
DATA: cb_knz_dok_hier_aufl_mehrst(1).

* CUSTOM CONTROL
DATA: alv_drad TYPE REF TO cl_gui_alv_grid.
DATA: container_alv_drad TYPE REF TO cl_gui_custom_container.

*LAYOUT
DATA: g_layo_alv_drad TYPE lvc_s_layo.

*FieldKatalog
DATA: g_fc_alv_drad TYPE  lvc_t_fcat.

*LVC_T_ROW
DATA: itab_et_index_rows_drad TYPE lvc_t_row.

DATA: wa_et_index_rows_drad TYPE lvc_s_row.

*TABS
CONTROLS TAB_STRP_CONTROL_001 TYPE TABSTRIP.
