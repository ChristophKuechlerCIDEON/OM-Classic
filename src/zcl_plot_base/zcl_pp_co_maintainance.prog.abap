*&---------------------------------------------------------------------*
*& Report  ZCL_PP_CO_MAINTAINANCE                                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_pp_co_maintainance.

* DDIC Structures
TABLES : usr02, aufk, mara, tpst.

* §§ Class Variables..
* ALV_GRIDS..
DATA : obj_alv_grid1         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid2         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid4         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid5         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid6         TYPE REF TO cl_gui_alv_grid.

* CUSTOM_CONTAINERS..
DATA : obj_custom_container1 TYPE REF TO cl_gui_custom_container,
       obj_custom_container2 TYPE REF TO cl_gui_custom_container,
       obj_custom_container4 TYPE REF TO cl_gui_custom_container,
       obj_custom_container5 TYPE REF TO cl_gui_custom_container,
       obj_custom_container6 TYPE REF TO cl_gui_custom_container.

* Internal Table & Work Area for index of the ALV Grid.
DATA : itab_index_rows_alv_grid  TYPE lvc_t_row,
       wa_index_one_alv_grid_row TYPE lvc_s_row.

* Layouts for the ALV
DATA : layo_alv_grida TYPE lvc_s_layo.

* Table Variables..
DATA : itab_aufk   TYPE TABLE OF aufk,
       wa_aufk     TYPE          aufk.

DATA : itab_tpst   TYPE TABLE OF tpst,
       wa_tpst     TYPE          tpst.

DATA : itab_selected_tpst   TYPE TABLE OF tpst,
       wa_selected_tpst     TYPE          tpst.

DATA : itab_aufk_porders   TYPE TABLE OF aufk,
       wa_aufk_porders     TYPE          aufk.

DATA : itab_afpo   TYPE TABLE OF afpo,
       wa_afpo     TYPE          afpo.

DATA : itab_mara             TYPE TABLE OF mara,
       wa_mara               TYPE          mara.

DATA : itab_mara_materials   TYPE TABLE OF mara.
*       wa_mara_materials     TYPE mara.

DATA : itab_mast   TYPE TABLE OF mast,
       wa_mast     TYPE          mast.

DATA : itab_draw   TYPE TABLE OF draw,
       wa_draw     TYPE          draw.

DATA : itab_draw_documents   TYPE TABLE OF draw,
       wa_draw_documents     TYPE          draw.

DATA : itab_draw_autoorg   TYPE TABLE OF draw,
       wa_draw_autoorg     TYPE          draw.

DATA : itab_dost   TYPE TABLE OF dost,
       wa_dost     TYPE          dost.

DATA : itab_stpo   TYPE TABLE OF stpo,
       wa_stpo     TYPE          stpo.

DATA : itab_stpo1   TYPE TABLE OF stpo,
       wa_stpo1     TYPE          stpo.

DATA : itab_caufv   TYPE TABLE OF caufv,
       wa_caufv     TYPE          caufv.

DATA : itab_resb   TYPE TABLE OF resb,
       wa_resb     TYPE          resb.

DATA : itab_stpo_positions TYPE TABLE OF stpo,
       wa_stpo_positions   TYPE          stpo.

DATA : itab_search   TYPE  TABLE OF zcl_s_docsearch,
       wa_search     TYPE           zcl_s_docsearch.

* General Global Variables...
DATA : index_itab_searchlist TYPE i,
       bom_flag              TYPE c,
       count_lines           TYPE n,
       ok_code               TYPE sy-ucomm.

* Global Variables for the Dyn-Pro '0992'.
DATA : dok_sl TYPE c,
       mat_sl TYPE c,
       eqp_sl TYPE c,
       tec_sl TYPE c,
       auf_sl TYPE c,
       pro_sl TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK block_frame1 WITH FRAME TITLE text-001.
SELECT-OPTIONS : s_aufnr FOR aufk-aufnr.
SELECT-OPTIONS : s_auart FOR aufk-auart.
SELECT-OPTIONS : s_autyp FOR aufk-autyp.
SELECT-OPTIONS : s_refnr FOR aufk-refnr.
SELECT-OPTIONS : s_ernam FOR usr02-bname.
SELECT-OPTIONS : s_erdat FOR aufk-erdat.
SELECT-OPTIONS : s_aenam FOR aufk-aenam.
SELECT-OPTIONS : s_aedat FOR aufk-aedat.
SELECT-OPTIONS : s_ktext FOR aufk-ktext.
SELECT-OPTIONS : s_ltext FOR aufk-ltext.
SELECT-OPTIONS : s_bukrs FOR aufk-bukrs.
SELECT-OPTIONS : s_werks FOR aufk-werks.
SELECT-OPTIONS : s_stort FOR aufk-stort.
SELECTION-SCREEN END OF BLOCK block_frame1.

SELECTION-SCREEN BEGIN OF BLOCK block_frame2 WITH FRAME TITLE text-002.
PARAMETERS p_bom   AS CHECKBOX.
PARAMETERS p_ltext AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK block_frame2.


* Screen '0990' display as a Subscreen in Screen '0899'.
SELECTION-SCREEN BEGIN OF SCREEN 0990 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK block_frame4 WITH FRAME TITLE text-004.
SELECT-OPTIONS : s_matnr FOR mara-matnr.
SELECT-OPTIONS : s_mtype FOR mara-mtart.
SELECT-OPTIONS : s_cname FOR usr02-bname.
SELECT-OPTIONS : s_modby FOR usr02-bname.
SELECT-OPTIONS : s_cdate FOR mara-ersda.
SELECT-OPTIONS : s_mdate FOR mara-laeda.
SELECTION-SCREEN END OF BLOCK block_frame4.
SELECTION-SCREEN END OF SCREEN 0990 .

* Screen '0994' display as a Subscreen in Screen '0995'.
SELECTION-SCREEN BEGIN OF SCREEN 0994 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK block_frame5 WITH FRAME TITLE text-005.
SELECT-OPTIONS : s_tplnr FOR tpst-tplnr.
SELECT-OPTIONS : s_tpwrs FOR tpst-werks.
SELECT-OPTIONS : s_stlnr FOR tpst-stlnr.
SELECT-OPTIONS : s_stlal FOR tpst-stlal.
SELECTION-SCREEN END OF BLOCK block_frame5.
SELECTION-SCREEN END OF SCREEN 0994.


**** §§ ALV_GRID Layouts.........
* Layout with possibility of Multiple Row Selection.
layo_alv_grida-sel_mode = 'A'.
layo_alv_grida-excp_led = 'X'.

* Layout with possibility of only one Row Selection.
*layo_alv_gridb-sel_mode = 'B'.
*layo_alv_gridb-excp_led = 'X'.

IF NOT ( p_bom IS INITIAL ).
*   Display BOM(Stückliste).
  CALL SCREEN '0992' STARTING AT 1 1 ENDING AT 33 9.
ELSEIF NOT ( p_ltext IS INITIAL ).
*   Display Long Text.
ELSE.
  PERFORM select_aufk_from_sel_screen.
ENDIF.

INCLUDE zcl_pp_co_maintainance_f01. " Sub Routines..
INCLUDE zcl_pp_co_maintainance_o01. " PBO Modules...
INCLUDE zcl_pp_co_maintainance_i01. " PAI Modules...
