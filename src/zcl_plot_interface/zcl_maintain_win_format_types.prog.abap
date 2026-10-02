*&---------------------------------------------------------------------*
*& Report ZCL_MAINTAIN_WIN_FORMATS                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_maintain_win_formats     .

*CLASSES
CLASS lcl_event_handler_alv DEFINITION DEFERRED.
DATA : alv_event_handler TYPE REF TO lcl_event_handler_alv.

*CONTROLS
DATA: obj_docking_container TYPE REF TO cl_gui_docking_container,
      obj_alv_grid          TYPE REF TO cl_gui_alv_grid.

*LAYOUT
DATA: g_layo_alv TYPE lvc_s_layo.

CONSTANTS : c_spras(2) VALUE 'EN'.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.

*ITAB
DATA : itab_win_formats          TYPE TABLE OF zcl_win_formats,
       itab_selected_win_formats TYPE TABLE OF zcl_win_formats,
       itab_func_exclude          TYPE TABLE OF rsexfcode,
       itab_fieldcat              TYPE TABLE OF lvc_s_fcat.

*WA
DATA: wa_win_formats             TYPE zcl_win_formats,
      wa2_win_formats            TYPE zcl_win_formats,
      wa_selected_win_formats    TYPE zcl_win_formats.

DATA : lv_index_itab_lvc_t_row    TYPE lvc_t_row ,
       lv_index_wa_lvc_s_row      TYPE lvc_s_row ,
       lv_index                   LIKE lvc_s_row-index.




*NORMAL
DATA: lv_index_itab_win_formats TYPE i.

* Containerdefinitionen und ALV-Variablen
DATA: ref_container_101     TYPE REF TO cl_gui_custom_container,
      ref_alv_101           TYPE REF TO cl_gui_alv_grid,
      wa_layout             TYPE lvc_s_layo,
      wa_variant            TYPE disvariant,
      wa_fieldcat           LIKE LINE OF itab_fieldcat,
      wa_func_exclude       LIKE LINE OF itab_func_exclude.

DATA: ok_code LIKE sy-ucomm.
DATA: save_ok_code LIKE ok_code.

* Sri.......
DATA : lv_flag_toggle_edit   TYPE c VALUE '0',
       lv_flag_modifications TYPE c ,
       lv_flag_toggle_sname  TYPE c .

* Berechtigungscheck
AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
         ID 'ZCL_TA' FIELD sy-tcode
         ID 'ACTVT' FIELD '16'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
.
IF sy-subrc > 0.
  MESSAGE s099(zcl_plint_tools)
    WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
  LEAVE PROGRAM.
ELSE.
ENDIF.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_format  FOR wa_win_formats-paper_format.
SELECT-OPTIONS: s_pindex   FOR wa_win_formats-paper_index.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: sinsname   FOR wa_win_formats-zclinsname.
SELECT-OPTIONS: sinsdate   FOR wa_win_formats-zclinsdate.
SELECT-OPTIONS: sinstime   FOR wa_win_formats-zclinstime.
SELECT-OPTIONS: sinsprog   FOR wa_win_formats-zclinsprog.
SELECT-OPTIONS: supdname   FOR wa_win_formats-zclinsname.
SELECT-OPTIONS: supddate   FOR wa_win_formats-zclupddate.
SELECT-OPTIONS: supdtime   FOR wa_win_formats-zclupdtime.
SELECT-OPTIONS: supdprog   FOR wa_win_formats-zclupdprog.
SELECTION-SCREEN END OF BLOCK bl2.

PERFORM get_data.

CALL SCREEN 100.

INCLUDE ZCL_MAINTAIN_WIN_FOR_TYPES_C01.
*INCLUDE zcl_maintain_win_formats_c01.

INCLUDE ZCL_MAINTAIN_WIN_FOR_TYPES_CL1.
*INCLUDE zcl_maintain_win_formats_cl1.

INCLUDE ZCL_MAINTAIN_WIN_FOR_TYPES_F01.
*INCLUDE zcl_maintain_win_formats_f01.

INCLUDE ZCL_MAINTAIN_WIN_FOR_TYPES_O01.
*INCLUDE zcl_maintain_win_formats_o01.

INCLUDE ZCL_MAINTAIN_WIN_FOR_TYPES_I01.
*INCLUDE zcl_maintain_win_formats_i01.
