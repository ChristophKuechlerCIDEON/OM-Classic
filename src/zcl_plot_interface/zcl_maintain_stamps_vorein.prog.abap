*&---------------------------------------------------------------------*
*& Report  ZCL_MAINTAIN_STAMPS_VOREIN                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_maintain_stamps_vorein     .

*CLASSES
CLASS lcl_event_handler_alv DEFINITION DEFERRED.
DATA : alv_event_handler TYPE REF TO lcl_event_handler_alv.

*CONTROLS
DATA : obj_docking_container TYPE REF TO cl_gui_docking_container,
       obj_alv_grid          TYPE REF TO cl_gui_alv_grid.

*LAYOUT
DATA : g_layo_alv TYPE lvc_s_layo.

CONSTANTS : c_spras(2) VALUE 'EN'.


*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.

*ITAB
DATA : itab_stamp_vorein          TYPE TABLE OF zcl_stamp_vorein,
       itab_selected_stamp_vorein TYPE TABLE OF zcl_stamp_vorein,
       itab_func_exclude          TYPE TABLE OF rsexfcode,
       itab_fieldcat              TYPE TABLE OF lvc_s_fcat.

*WA
DATA : wa_stamp_vorein          TYPE zcl_stamp_vorein,
       wa2_stamp_vorein         TYPE zcl_stamp_vorein,
       wa_selected_stamp_vorein TYPE zcl_stamp_vorein.

*NORMAL
DATA : lv_index_itab_stamp_vorein TYPE i,
       lv_index_itab_lvc_t_row TYPE lvc_t_row,
       lv_index_wa_lvc_s_row TYPE lvc_s_row,
       lv_index LIKE lvc_s_row-index.

* Containerdefinitionen und ALV-Variablen
DATA : ref_container_101     TYPE REF TO cl_gui_custom_container,
       ref_alv_101           TYPE REF TO cl_gui_alv_grid,
       wa_layout             TYPE lvc_s_layo,
       wa_variant            TYPE disvariant,
       wa_fieldcat           LIKE LINE OF itab_fieldcat,
       wa_func_exclude       LIKE LINE OF itab_func_exclude.

DATA : ok_code      LIKE sy-ucomm,
       save_ok_code LIKE ok_code.

* Sri.......
DATA : lv_flag_toggle_edit   TYPE c VALUE '0',
       lv_flag_modifications TYPE c ,
       lv_flag_toggle_sname  TYPE c .

* Berechtigungscheck
AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
         ID 'ZCL_TA' FIELD sy-tcode
         ID 'ACTVT' FIELD '16'.

IF sy-subrc > 0.
  MESSAGE s099(zcl_plint_tools)
    WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
  LEAVE PROGRAM.
ELSE.
ENDIF.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_seinst   FOR wa_stamp_vorein-voreinstellung.
SELECT-OPTIONS: s_sname    FOR wa_stamp_vorein-stempel_name.
SELECT-OPTIONS: s_fmname   FOR wa_stamp_vorein-fm_name.
SELECT-OPTIONS: s_status   FOR wa_stamp_vorein-status.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: sinsname   FOR wa_stamp_vorein-zclinsname.
SELECT-OPTIONS: sinsdate   FOR wa_stamp_vorein-zclinsdate.
SELECT-OPTIONS: sinstime   FOR wa_stamp_vorein-zclinstime.
SELECT-OPTIONS: sinsprog   FOR wa_stamp_vorein-zclinsprog.
SELECT-OPTIONS: supdname   FOR wa_stamp_vorein-zclinsname.
SELECT-OPTIONS: supddate   FOR wa_stamp_vorein-zclupddate.
SELECT-OPTIONS: supdtime   FOR wa_stamp_vorein-zclupdtime.
SELECT-OPTIONS: supdprog   FOR wa_stamp_vorein-zclupdprog.
SELECTION-SCREEN END OF BLOCK bl2.

PERFORM get_data.

CALL SCREEN 100.

INCLUDE zcl_maintain_stamp_vorein_c01.

INCLUDE zcl_maintain_stamp_vorein_cl1.

INCLUDE zcl_maintain_stamp_vorein_f01.

INCLUDE zcl_maintain_stamp_vorein_o01.

INCLUDE zcl_maintain_stamp_vorein_i01.
