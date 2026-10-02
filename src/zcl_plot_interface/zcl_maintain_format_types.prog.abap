*&---------------------------------------------------------------------*
*& Report ZCL_MAINTAIN_FORMAT_TYPES                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_maintain_format_types     .

*Classes / Objects
CLASS lcl_event_handler_alv  DEFINITION DEFERRED.
DATA : alv_event_handler     TYPE REF TO lcl_event_handler_alv.

* Controls
DATA : obj_alv_grid          TYPE REF TO cl_gui_alv_grid,
       obj_docking_container TYPE REF TO cl_gui_docking_container.


*LAYOUT
DATA: lv_layo_alv TYPE lvc_s_layo.

CONSTANTS : c_spras(2) VALUE 'EN'.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.

*ITAB
DATA : itab_format_types          TYPE TABLE OF zcl_format_types,
       itab_selected_format_types TYPE TABLE OF zcl_format_types,
       itab_func_exclude          TYPE TABLE OF rsexfcode,
       itab_fieldcat              TYPE TABLE OF lvc_s_fcat.

*WA
DATA: wa_format_types             TYPE zcl_format_types,
      wa2_format_types            TYPE zcl_format_types,
      wa_selected_format_types    TYPE zcl_format_types.

DATA : lv_index_itab_lvc_t_row    TYPE lvc_t_row ,
       lv_index_wa_lvc_s_row      TYPE lvc_s_row ,
       lv_index                   LIKE lvc_s_row-index,
       lv_old_index               LIKE lvc_s_row-index.

*NORMAL
DATA: lv_index_itab_format_types TYPE i.

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
SELECT-OPTIONS: s_format  FOR wa_format_types-paper_format.
SELECT-OPTIONS: s_pindex   FOR wa_format_types-paper_index.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: sinsname   FOR wa_format_types-zclinsname.
SELECT-OPTIONS: sinsdate   FOR wa_format_types-zclinsdate.
SELECT-OPTIONS: sinstime   FOR wa_format_types-zclinstime.
SELECT-OPTIONS: sinsprog   FOR wa_format_types-zclinsprog.
SELECT-OPTIONS: supdname   FOR wa_format_types-zclinsname.
SELECT-OPTIONS: supddate   FOR wa_format_types-zclupddate.
SELECT-OPTIONS: supdtime   FOR wa_format_types-zclupdtime.
SELECT-OPTIONS: supdprog   FOR wa_format_types-zclupdprog.
SELECTION-SCREEN END OF BLOCK bl2.

PERFORM get_data.

CALL SCREEN 100.

INCLUDE zcl_maintain_format_types_c01.

INCLUDE zcl_maintain_format_types_cl1.

INCLUDE zcl_maintain_format_types_f01.

INCLUDE zcl_maintain_format_types_o01.

INCLUDE zcl_maintain_format_types_i01.
