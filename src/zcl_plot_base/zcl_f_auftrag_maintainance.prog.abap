*&---------------------------------------------------------------------*
*& Report  ZCL_F_AUFTRAG_MAINTAINANCE                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  ZCL_F_AUFTRAG_MAINTAINANCE.

* DDIC Structures
TABLES : mara, usr02, aufk, sscrfields.


* §§ Class Variables..
* ALV_GRIDS..
DATA : obj_alv_grid1         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid4         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid5         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid6         TYPE REF TO cl_gui_alv_grid,
       obj_alv_grid7         TYPE REF TO cl_gui_alv_grid.

* CUSTOM_CONTAINERS..
DATA : obj_custom_container1 TYPE REF TO cl_gui_custom_container,
       obj_custom_container4 TYPE REF TO cl_gui_custom_container,
       obj_custom_container5 TYPE REF TO cl_gui_custom_container,
       obj_custom_container6 TYPE REF TO cl_gui_custom_container,
       obj_custom_container7 TYPE REF TO cl_gui_custom_container.

* Internal Table & Work Area for index of the ALV Grid.
DATA : itab_index_rows_alv_grid  TYPE lvc_t_row,
       wa_index_one_alv_grid_row TYPE lvc_s_row.

* Layouts for the ALV
DATA : layo_alv_grida TYPE lvc_s_layo,
       layo_alv_gridb TYPE lvc_s_layo.

* Table Variables..
DATA : itab_aufk   TYPE TABLE OF aufk,
       wa_aufk     TYPE aufk.

DATA : itab_aufk_porders   TYPE TABLE OF aufk,
       wa_aufk_porders     TYPE aufk.

DATA : itab_afpo   TYPE TABLE OF afpo,
       wa_afpo     TYPE afpo.

DATA : itab_mara             TYPE TABLE OF mara,
       wa_mara               TYPE mara.

DATA : itab_mara_materials   TYPE TABLE OF mara.
*       wa_mara_materials     TYPE mara.

DATA : itab_mast   TYPE TABLE OF mast,
       wa_mast     TYPE mast.

DATA : itab_draw   TYPE TABLE OF draw,
       wa_draw     TYPE draw.

DATA : itab_draw_documents   TYPE TABLE OF draw,
       wa_draw_documents     TYPE draw.

DATA : itab_draw_autoorg   TYPE TABLE OF draw,
       wa_draw_autoorg     TYPE draw.

DATA : itab_dost   TYPE TABLE OF dost,
       wa_dost     TYPE dost.

DATA : itab_stpo   TYPE TABLE OF stpo,
       wa_stpo     TYPE stpo.

DATA : itab_stpo_positions    TYPE TABLE OF stpo,
       wa_stpo_positions    TYPE stpo.

DATA : itab_search   TYPE TABLE OF zcl_s_docsearch,
       wa_search     TYPE zcl_s_docsearch.

* General Global Variables...
DATA : index_itab_searchlist TYPE i,
       gl_flag               TYPE c,
       bom_flag              TYPE c,
       count_lines           TYPE i,
       aufk_sel_flag         TYPE c,
       ok_code               TYPE sy-ucomm.

* Global Variables for the Dyn-Pro '0996' as Radio Buttons.
DATA : mm_im    TYPE c VALUE 'X',
       mm_sp    TYPE c.

* Global Variables for the Dyn-Pro '0992'.
DATA : dok_sl TYPE c,
       mat_sl TYPE c,
       eqp_sl TYPE c,
       tec_sl TYPE c,
       auf_sl TYPE c,
       pro_sl TYPE c.
DATA  sel_flag TYPE c.

* Global Variables for the Dyn-Pro '0992'.
*DATA : s_aufnr TYPE c,
*       s_auart TYPE c,
*       s_autyp TYPE c,
*       s_refnr TYPE c,
*       s_ernam TYPE c,
*       s_werks TYPE c.


SELECTION-SCREEN BEGIN OF BLOCK block_frame1 WITH FRAME TITLE text-001.
PARAMETERS : pp_order TYPE aufk-aufnr .
PARAMETERS : pp_all   AS CHECKBOX.
SELECTION-SCREEN PUSHBUTTON /1(30) name USER-COMMAND select.
SELECTION-SCREEN END OF BLOCK block_frame1.


*SELECTION-SCREEN PUSHBUTTON /1(40) name USER-COMMAND ucom.

SELECTION-SCREEN BEGIN OF BLOCK block_frame2 WITH FRAME TITLE text-002.
PARAMETERS: p_bom     RADIOBUTTON GROUP pro1.
PARAMETERS: p_allm    RADIOBUTTON GROUP pro1.
PARAMETERS: p_order   RADIOBUTTON GROUP pro1.
PARAMETERS: p_ltext   RADIOBUTTON GROUP pro1.
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

SELECTION-SCREEN BEGIN OF SCREEN 0885 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK block_frame5 WITH FRAME TITLE text-005.
SELECT-OPTIONS : s_aufnr FOR aufk-aufnr.
SELECT-OPTIONS : s_auart FOR aufk-auart.
SELECT-OPTIONS : s_autyp FOR aufk-autyp.
SELECT-OPTIONS : s_refnr FOR aufk-refnr.
SELECT-OPTIONS : s_ernam FOR usr02-bname.
SELECT-OPTIONS : s_werks FOR aufk-werks.
SELECTION-SCREEN END OF BLOCK block_frame5.
SELECTION-SCREEN END OF SCREEN 0885 .


INITIALIZATION.
  MOVE 'Go to Selection Screen' TO name.

AT SELECTION-SCREEN.
  IF sel_flag IS INITIAL.
    IF sscrfields-ucomm = 'SELECT'.
      CALL SCREEN '0884'.
      sel_flag = 'X'.
    ENDIF.
  ENDIF.

**** §§ ALV_GRID Layouts.........
* Layout with possibility of Multiple Row Selection.
  layo_alv_grida-sel_mode = 'A'.
  layo_alv_grida-excp_led = 'X'.

* Layout with possibility of only one Row Selection.
  layo_alv_gridb-sel_mode = 'B'.
  layo_alv_gridb-excp_led = 'X'.


  IF NOT ( pp_order IS INITIAL ).
* Display the details for the Production Order.
    CALL SCREEN '0999'.
    EXIT.

  ELSEIF NOT ( pp_all IS INITIAL ).
* Display all Production Orders.
    CALL SCREEN '0999'.
    EXIT.

  ELSEIF NOT ( p_allm IS INITIAL ).
*   Display all Materials in MARA table.
    CALL SCREEN '0899' STARTING AT 1 1 ENDING AT 100 11.

  ELSEIF NOT ( p_bom IS INITIAL ).
*   Display BOM(Stückliste).
    CALL SCREEN '0992' STARTING AT 17 4 ENDING AT 50 11.

  ELSEIF NOT ( p_order IS INITIAL ).
*   Display Production Orders.
    CALL SCREEN '0999'.

  ELSEIF NOT ( p_ltext IS INITIAL ).
*   Display Long Text.
  ENDIF.

  INCLUDE zcl_f_auftrag_maintainance_f01.
*  INCLUDE z_pp_co_maintainance_f01. " Unterprogramme
  INCLUDE zcl_f_auftrag_maintainance_o01.
*  INCLUDE z_pp_co_maintainance_o01. " PBO Modules...
  INCLUDE zcl_f_auftrag_maintainance_i01.
*  INCLUDE z_pp_co_maintainance_i01. " PAI Modules...
