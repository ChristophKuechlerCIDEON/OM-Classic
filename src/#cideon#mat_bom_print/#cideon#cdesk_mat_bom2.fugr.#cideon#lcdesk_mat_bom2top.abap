FUNCTION-POOL /cideon/cdesk_mat_bom2.    "MESSAGE-ID ..

INCLUDE cp_cs_const.
INCLUDE cs_check.


TYPE-POOLS abap .

TABLES:  mara, draw, object_keyfields, stpo, stpox.

TYPES   field(30).

FIELD-SYMBOLS <break_point> TYPE ANY.
FIELD-SYMBOLS <changeno> TYPE ANY.
FIELD-SYMBOLS <mat_bom> TYPE STANDARD TABLE.
FIELD-SYMBOLS <wa> TYPE ANY.

DATA: gf_debug.
DEFINE break_point.
  if not gf_debug is initial.
    break-point.
  endif.
END-OF-DEFINITION.

DATA:  return TYPE bapiret2.
DATA:  g_head_matnr TYPE mara-matnr.
DATA:  g_plant TYPE stko-wrkan,
       g_usage TYPE rc29k-stlan,
       g_alternative TYPE stko-stlal,
       g_changeno TYPE stko-aennr,
       g_capid TYPE tc04-capid,
       g_datuv TYPE datuv,
       g_spras TYPE spras,

       g_stpst TYPE stpox-stufe,
       g_bomtype TYPE /cideon/bomtype,

       g_msg_dummy(1) TYPE c.
*      UeberlaufKennzeichen
DATA:  ueberl_kz(1) TYPE c VALUE '*'.
*      Kennzeichen 'hat Stueckliste'
DATA:  b_flag(1) TYPE c VALUE 'X'.
*      maximal anzeigbare Menge
DATA:  max_num(7)  TYPE p DECIMALS 3 VALUE '9999999999.999',
*      Mindestmenge
       min_num(7)  TYPE p DECIMALS 3 VALUE '9999999999.999-'.
DATA:  fm_name TYPE rs38l_fnam,
       formname TYPE  tdsfname.
DATA:  gs_head_mat TYPE rc29k,
       gt_head_mat TYPE TABLE OF rc29k,
       gs_bom_print TYPE /cideon/bom_print,
       gt_head_mat_dir TYPE TABLE OF /cideon/mat_dir,
       gt_posi_mat_dir TYPE TABLE OF /cideon/mat_dir.

DATA:  gt_mat_bom TYPE TABLE OF stpox,
       gt_mat_bom_cs03_a TYPE TABLE OF /cideon/stpos_cs03_a,
       gt_mat_bom_cs03_d TYPE TABLE OF /cideon/stpos_cs03_d,
       gt_mat_bom_cs03_m TYPE TABLE OF /cideon/stpos_cs03_m,
       gt_mat_bom_cs11 TYPE TABLE OF /cideon/stpos_cs11,
       gt_mat_bom_cs12 TYPE TABLE OF /cideon/stpos_cs12,
       gt_mat_bom_cs13 TYPE TABLE OF /cideon/stpos_cs13.
*     Verweistabelle auf Koordinaten von Zwischenbaugruppen
DATA: BEGIN OF hd_tab OCCURS 0,
         stufe LIKE stpox-stufe,
         vwegx LIKE stpox-vwegx,
      END OF hd_tab.

DATA mat_bom_print TYPE REF TO /cideon/if_ex_mat_bom_prin.

DATA: tabname TYPE  ddobjname,
      ok_code LIKE sy-ucomm,
      save_ok_code LIKE sy-ucomm,
      g_repid LIKE sy-repid,
      wa_save_neccessary,
      index             TYPE i,
      answer,
      gf_refresh_data VALUE abap_true,

* Exclude table
      it_excl TYPE TABLE OF rsexfcode,
      wa_excl LIKE LINE OF it_excl,
      itab_tb_ex_searchlist TYPE ui_functions,

* reference variables
      ref_container     TYPE REF TO cl_gui_docking_container,
      ref_alv           TYPE REF TO cl_gui_alv_grid,
      gf_versionsinfo   TYPE REF TO /cideon/cl_versionsinfo,

* layout variable of alv grid
      wa_s_layo         TYPE lvc_s_layo,

* variant structure
      wa_s_variant      TYPE disvariant,

* field catalog
      it_field_cat      TYPE TABLE OF lvc_s_fcat,
      wa_field_cat      TYPE lvc_s_fcat,

* Zeilenselektion
      it_selected_rows TYPE lvc_t_row,
      wa_selected_rows LIKE LINE OF it_selected_rows.

DATA: dref TYPE REF TO data,
      dfies_tab TYPE TABLE OF dfies.
DATA:   g_meins TYPE stpo-meins,
        g_menge TYPE stpo-menge,
        gs_fields TYPE field,
        gt_fields TYPE TABLE OF field,
        zp_matnr TYPE mara-matnr,
        stack_available    TYPE   csdata-xfeld,
        init_stack(1)      TYPE c VALUE 'X'.
DATA:   usrobjstack TYPE STANDARD TABLE OF usrobjects WITH HEADER LINE,
        root_object_type   TYPE pdm_tree-object_type.

CONTROLS: browser_tab_strip TYPE TABSTRIP.

CONSTANTS: co_variant_both         VALUE 'A',
           cross TYPE csdata-xfeld VALUE 'X'.
CONSTANTS: document    TYPE pdm_tree-object_type  VALUE 'DOCUMENT',
           material    TYPE pdm_tree-object_type  VALUE 'MATERIAL',
           mat         TYPE pdm_tree-print_type   VALUE 'MAT',
           doc         TYPE pdm_tree-print_type   VALUE 'DOC',
           co_doc VALUE '3',
           co_mat VALUE '1',
           co_insert VALUE 'I',
           co_append VALUE 'A'.
DATA:      gf_ins_app,
           g_posnr TYPE stpox-posnr,
           g_stufe TYPE stpox-stufe.


******************************************************************
