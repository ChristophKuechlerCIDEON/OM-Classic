FUNCTION-POOL /cideon/plotinfo.             "MESSAGE-ID ..


DATA: wa_logon TYPE /cideon/_s_pli.

DATA: ok_code TYPE sy-ucomm.


DATA: cc_editor TYPE REF TO cl_gui_custom_container.
DATA: editor TYPE REF TO cl_gui_textedit.


** CHG CIDEON MBH - Pflege Verteiler auf ALV

DATA: g_alv_grid TYPE REF TO cl_gui_alv_grid,
      g_layout TYPE lvc_s_layo,
      g_variant TYPE disvariant,
      gt_fieldcat TYPE lvc_t_fcat,
      gt_outtab TYPE TABLE OF /cideon/s_verteiler.

DATA: g_preprocessor TYPE zcl_name_preprozessor.

* ITAB
DATA: it_text TYPE TABLE OF zcl_stempel_wert.
DATA: it_text_stream TYPE TABLE OF string.


* WA
DATA: wa_text TYPE zcl_stempel_wert.

DATA: g_answer(1).
