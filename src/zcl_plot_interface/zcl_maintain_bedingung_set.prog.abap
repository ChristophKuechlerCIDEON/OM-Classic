*&---------------------------------------------------------------------*
*& Report ZCL_MAINTAIN_BEDINGUNG_SET                                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_maintain_bedingung_set     .

*Classes / Objects
CLASS lcl_event_handler_alv  DEFINITION DEFERRED.
DATA : alv_event_handler     TYPE REF TO lcl_event_handler_alv.

* Controls
DATA : obj_alv_grid          TYPE REF TO cl_gui_alv_grid,
       obj_docking_container TYPE REF TO cl_gui_docking_container.


*LAYOUT
DATA : lv_layo_alv TYPE lvc_s_layo.

CONSTANTS : c_spras(2) VALUE 'EN'.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.

*ITAB
DATA : itab_beding_set             TYPE TABLE OF zcl_beding_set,
       itab_selected_beding_set    TYPE TABLE OF zcl_beding_set,
       itab_func_exclude           TYPE TABLE OF rsexfcode,
       itab_fieldcat               TYPE TABLE OF lvc_s_fcat.

*WA
DATA : wa_beding_set            TYPE zcl_beding_set,
       wa2_beding_set           TYPE zcl_beding_set,
       wa_selected_beding_set   TYPE zcl_beding_set.

DATA : lv_index_itab_lvc_t_row    TYPE lvc_t_row ,
       lv_index_wa_lvc_s_row      TYPE lvc_s_row ,
       lv_index                   LIKE lvc_s_row-index,
       lv_old_index               LIKE lvc_s_row-index.

*NORMAL
DATA : lv_index_itab_beding_set TYPE i.

* Containerdefinitionen und ALV-Variablen
DATA : ref_container_101     TYPE REF TO cl_gui_custom_container,
       ref_alv_101           TYPE REF TO cl_gui_alv_grid,
       wa_layout             TYPE lvc_s_layo,
       wa_variant            TYPE disvariant,
       wa_fieldcat           LIKE LINE OF itab_fieldcat,
       wa_func_exclude       LIKE LINE OF itab_func_exclude.

DATA : ok_code LIKE sy-ucomm.
DATA : save_ok_code LIKE ok_code.

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
SELECT-OPTIONS: s_uname    FOR wa_beding_set-uname. "DEAULT sy-uname.
SELECT-OPTIONS: s_vertlr   FOR wa_beding_set-verteiler.
SELECT-OPTIONS: s_schlel   FOR wa_beding_set-id_schluessel.
SELECT-OPTIONS: s_beding   FOR wa_beding_set-id_bedingung.
SELECT-OPTIONS: s_bedsub   FOR wa_beding_set-id_bedingung_sub.
SELECT-OPTIONS: s_prio     FOR wa_beding_set-prio.
SELECT-OPTIONS: s_beshri   FOR wa_beding_set-beschreibung.
SELECT-OPTIONS: s_bedfel   FOR wa_beding_set-bedingungsfeld.
SELECT-OPTIONS: s_opetor   FOR wa_beding_set-operator.
SELECT-OPTIONS: s_glewrt   FOR wa_beding_set-vergleichswert.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: sinsname   FOR wa_beding_set-zclinsname.
SELECT-OPTIONS: sinsdate   FOR wa_beding_set-zclinsdate.
SELECT-OPTIONS: sinstime   FOR wa_beding_set-zclinstime.
SELECT-OPTIONS: sinsprog   FOR wa_beding_set-zclinsprog.
SELECT-OPTIONS: supdname   FOR wa_beding_set-zclinsname.
SELECT-OPTIONS: supddate   FOR wa_beding_set-zclupddate.
SELECT-OPTIONS: supdtime   FOR wa_beding_set-zclupdtime.
SELECT-OPTIONS: supdprog   FOR wa_beding_set-zclupdprog.
SELECTION-SCREEN END OF BLOCK bl2.

PERFORM get_data.

CALL SCREEN 100.

INCLUDE zcl_maintain_bedingung_set_c01.

INCLUDE zcl_maintain_bedingung_set_cl1.

INCLUDE zcl_maintain_bedingung_set_f01.

INCLUDE zcl_maintain_bedingung_set_o01.

INCLUDE zcl_maintain_bedingung_set_i01.
