FUNCTION-POOL /cideon/note_dir.             "MESSAGE-ID ..



DATA: gf_debug.

DEFINE break_point.
  if not gf_debug is initial.
    break-point.
  endif.
END-OF-DEFINITION.

FIELD-SYMBOLS: <break_point> TYPE ANY.
FIELD-SYMBOLS: <active_tab> TYPE ANY.
FIELD-SYMBOLS: <t_outtab> TYPE table.
FIELD-SYMBOLS: <gf_doc_tree1> TYPE REF TO cl_gui_column_tree.
FIELD-SYMBOLS: <grid_control_1111> TYPE REF TO cl_gui_alv_grid.

DATA  active_tab TYPE sy-ucomm.

* Globale Tabellen
*DATA: gt_documents TYPE TABLE OF plm_document.
DATA:       gt_draw TYPE TABLE OF draw.

* Sonstige
DATA: index TYPE i.
DATA: f_code TYPE sy-slset,
      gf_hostname TYPE tdwd-ntadr,

*     Container
      gf_oi_cont    TYPE REF TO cl_gui_custom_container,
      gf_fi_cont    TYPE REF TO cl_gui_custom_container,
      gf_fi_grid    TYPE REF TO cl_gui_alv_grid,
      gt_fi_outtab  TYPE TABLE OF bapi_doc_files2,
      gt_fi_fieldcatalog   TYPE lvc_t_fcat,
      gs_fi_layout         TYPE lvc_s_layo,
      gt_checkoutfiles TYPE TABLE OF bapi_doc_files2 ,
      gs_draw TYPE draw,
      ok_code       TYPE sy-ucomm,
      ok_code_300   TYPE sy-ucomm,
      gs_data-display,
      gc_docfile TYPE filep,
      gc_url     TYPE mcdok-url,
      gf_cancel,
      cross VALUE 'X'.

DATA: g_screen_start_column TYPE i,
      g_screen_start_line   TYPE i,
      g_screen_end_column   TYPE i,
      g_screen_end_line     TYPE i.

* Konstanten
CONSTANTS: c_workingdir           TYPE sy-ucomm VALUE 'TSDIR',
           c_insession            TYPE sy-ucomm VALUE 'TSINS',
           c_cadstructure         TYPE sy-ucomm VALUE 'TSCAD',
           c_sapli                TYPE sy-ucomm VALUE 'TSSAPLI',
           c_sapstructure         TYPE sy-ucomm VALUE 'TSSAP',
           c_oi_cont(10)          TYPE c        VALUE 'CTL_OI',
           co_testdatum           TYPE sy-datum VALUE '99991231',
           c_dms_file_display     LIKE tdwx-apptp VALUE '1',
           c_dms_file_change      LIKE tdwx-apptp VALUE '2',
           c_dms_file_print       LIKE tdwx-apptp VALUE '3',
           c_dms_file_display_web LIKE tdwx-apptp VALUE '4',
           c_dms_appl_oi_in(2)    TYPE c VALUE '8',
           c_dms_appl_oi_out(2)   TYPE c VALUE '9',
           c_dms_file_url(10)     TYPE c VALUE 'file://'.

*INCLUDE /cideon/lcdesk_doclcl.

*DATA:  gf_fi_event_receiver TYPE REF TO lcl_gf_fi_event_receiver.
