FUNCTION-POOL zcl_prod_struk_brws MESSAGE-ID c$.

*ITAB
DATA: itab_objects TYPE TABLE OF pdm_exp_objects.
DATA: itab_stored_search TYPE TABLE OF zcl_psb_tmp.
*DATA: itab_drad TYPE TABLE OF drad.
*WA
DATA: wa_objects TYPE pdm_exp_objects.
DATA: wa_objects_2 TYPE pdm_exp_objects.
DATA: wa_stored_search TYPE zcl_psb_tmp.
*DATA: wa_drad TYPE drad.
DATA: wa_capid TYPE rc29l.
DATA: wa_stpos TYPE stpox.



*NORMAL
DATA: text1 TYPE symsgv.
DATA: text2 TYPE symsgv.
DATA: text3 TYPE symsgv.
DATA: text4 TYPE symsgv.

DATA: ok_code LIKE sy-ucomm.

* DECLARATION OF TABLECONTROL 'TAB_CNTRL_01' ITSELF
CONTROLS: tab_cntrl_01 TYPE TABLEVIEW USING SCREEN 0100.

* LINES OF TABLECONTROL 'TAB_CNTRL_01'
DATA:     g_tab_cntrl_01_lines  LIKE sy-loopc.


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

DATA: g_datum TYPE sy-datum.
