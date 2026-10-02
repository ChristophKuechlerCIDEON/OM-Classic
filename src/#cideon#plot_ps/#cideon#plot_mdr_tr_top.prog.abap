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
DATA  save_ok_code(30).

DATA: g_ctx_fcode TYPE sy-ucomm.



*ITAB
DATA: it_wbs TYPE TABLE OF bapi_wbs_element_exp.
DATA: it_drad_psp TYPE TABLE OF drad.
DATA: it_draw_item_tr TYPE TABLE OF /cideon/s_draw_item_tr.
DATA: it_drad_easy TYPE TABLE OF drad.
DATA: it_draw_easy TYPE TABLE OF draw.
DATA: it_objects TYPE TABLE OF zcl_pdm_exp_objects.


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


*NORMAL
DATA: f_to_init VALUE 'X'.
