*&---------------------------------------------------------------------*
*& Include /CIDEON/PLOT_MDR_TR_TOP                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  /cideon/plot_mdr_tr           .

* BADI
DATA: badi_om_ps_01 TYPE REF TO /cideon/if_ex_om_ps_01.


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



*ITAB
DATA: it_wbs TYPE TABLE OF bapi_wbs_element_exp.
DATA: it_drad_psp TYPE TABLE OF drad.
DATA: it_draw_item_tr TYPE TABLE OF /cideon/s_draw_item_tr.
DATA: it_drad_easy TYPE TABLE OF drad.
DATA: it_draw_easy TYPE TABLE OF draw.
DATA: it_objects TYPE TABLE OF zcl_pdm_exp_objects.
DATA: it_wbs_hr TYPE TABLE OF bapi_wbs_hierarchie.

DATA: it_prst TYPE TABLE OF prst.
DATA: it_stb TYPE TABLE OF stpox.
DATA: it_doc TYPE TABLE OF stpox.

*WA
DATA: wa_wbs TYPE bapi_wbs_element_exp.

DATA: wa_mdr_tr TYPE /cideon/s_mdr_tr.

DATA: wa_prps TYPE prps.
DATA: wa_proj TYPE proj.

DATA: user_data TYPE /cideon/plot_userdata. "t_userdata.
DATA: default_data TYPE /cideon/plot_defaultdata. "t_defaultdata.

DATA: wa_drad_psp TYPE drad.
DATA: wa_draw_item_tr TYPE /cideon/s_draw_item_tr.
DATA: wa_drad_easy TYPE drad.
DATA: wa_draw_easy TYPE draw.
DATA: wa_objects TYPE zcl_pdm_exp_objects.

DATA: wa_wbs_hr TYPE bapi_wbs_hierarchie.
DATA: wa_wbs_hr_tmp TYPE bapi_wbs_hierarchie.

DATA: wa_prst TYPE prst.

DATA: wa_stb TYPE stpox.
DATA: wa_doc TYPE stpox.


DATA: rc29l  TYPE rc29l.
DATA: wa_rc29l TYPE rc29l.

*NORMAL
DATA: f_to_init VALUE 'X'.
DATA index_prst TYPE i.
DATA: mdf_filename TYPE filep.


*CL Coustom Controls
DATA: container_grid_prst TYPE REF TO cl_gui_custom_container.
DATA: alv_prst TYPE REF TO cl_gui_alv_grid.



*LAYOUT
*DATA: g_layo_prst TYPE lvc_s_layo.
DATA:  gs_variant_prst TYPE disvariant.
DATA:  x_save_pprst VALUE 'A'.



*FieldKatalog
DATA: g_fc_prst TYPE  lvc_t_fcat.

DATA: wa_fc_prst TYPE lvc_s_fcat.

*LVC_T_ROW
DATA: it_et_index_rows_prst TYPE lvc_t_row.

DATA: wa_et_index_rows_prst TYPE lvc_s_row.

CLASS lcl_event_handler_alv_prst DEFINITION DEFERRED.

DATA: prst_handler TYPE REF TO lcl_event_handler_alv_prst.


* Excel Integration
DATA container TYPE REF TO cl_gui_custom_container.
DATA error TYPE REF TO i_oi_error.
DATA control TYPE REF TO i_oi_container_control.
DATA document TYPE REF TO i_oi_document_proxy.
DATA sheet TYPE REF TO i_oi_spreadsheet.






DATA: lt_ranges TYPE soi_range_list.
DATA: lt_contents TYPE soi_generic_table.

DATA: lc_ranges TYPE soi_range_item.
DATA: lc_contents TYPE soi_generic_item.

DATA: lt_range_def TYPE soi_dimension_table.
DATA: lc_range_def TYPE soi_dimension_item.
