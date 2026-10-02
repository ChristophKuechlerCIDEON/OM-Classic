*&---------------------------------------------------------------------*
*& Report  ZCL_MAINTAIN_PLINT_CFG_00                                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_maintain_plint_cfg_00     .

*CLASSES
CLASS lcl_event_handler_alv DEFINITION DEFERRED.
DATA: alv_event_handler TYPE REF TO lcl_event_handler_alv.

*CONTROLS
DATA: docking_container TYPE REF TO cl_gui_docking_container.
DATA: alv TYPE REF TO cl_gui_alv_grid.

*LAYOUT
DATA: g_layo_alv TYPE lvc_s_layo.

CONSTANTS: c_spras(2) VALUE 'EN'.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.

*ITAB
DATA: itab_cfg_00 TYPE TABLE OF zcl_plint_cfg_00.
*WA
DATA: wa_cfg_00 TYPE zcl_plint_cfg_00.
*NORMAL
DATA: index_itab_cfg_00 TYPE i.

* Containerdefinitionen und ALV-Variablen
DATA: ref_container_101     TYPE REF TO cl_gui_custom_container,
      ref_alv_101           TYPE REF TO cl_gui_alv_grid,
      wa_layout             TYPE lvc_s_layo,
      wa_variant            TYPE disvariant,
      itab_fieldcat         TYPE TABLE OF lvc_s_fcat,
      wa_fieldcat           LIKE LINE OF itab_fieldcat.

DATA: itab_func_exclude TYPE TABLE OF rsexfcode.
DATA: wa_func_exclude LIKE LINE OF itab_func_exclude.

DATA: ok_code LIKE sy-ucomm.
DATA: save_ok_code LIKE ok_code.

* Sri.......
DATA : flag_toggle_edit   TYPE c VALUE '0',
       flag_modifications TYPE c ,
       itab2_cfg_00       TYPE TABLE OF zcl_plint_cfg_00,
       wa2_cfg_00         TYPE zcl_plint_cfg_00,
       flag_toggle_pname  TYPE c .

DATA : lv_index_itab_lvc_t_row    TYPE lvc_t_row ,
       lv_index_wa_lvc_s_row      TYPE lvc_s_row ,
       lv_index                   LIKE lvc_s_row-index.

data : itab_selected_cfg_00 type table of zcl_plint_cfg_00,
       wa_selected_cfg_00   type zcl_plint_cfg_00.





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
SELECT-OPTIONS: s_pname FOR wa_cfg_00-pname.
SELECT-OPTIONS: s_wert FOR wa_cfg_00-pwert.
SELECT-OPTIONS: s_doku FOR wa_cfg_00-pdoku.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: sinsname FOR wa_cfg_00-zclinsname.
SELECT-OPTIONS: sinsdate FOR wa_cfg_00-zclinsdate.
SELECT-OPTIONS: sinstime FOR wa_cfg_00-zclinstime.
SELECT-OPTIONS: sinsprog FOR wa_cfg_00-zclinsprog.
SELECT-OPTIONS: supdname FOR wa_cfg_00-zclupdname.
SELECT-OPTIONS: supddate FOR wa_cfg_00-zclupddate.
SELECT-OPTIONS: supdtime FOR wa_cfg_00-zclupdtime.
SELECT-OPTIONS: supdprog FOR wa_cfg_00-zclupdprog.
SELECTION-SCREEN END OF BLOCK bl2.

** Berechtigungscheck
*AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
*         ID 'ZCL_TA' FIELD sy-repid
*         ID 'ACTVT' FIELD '16'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*.
*IF sy-subrc > 0.
*  MESSAGE s099(zcl_plint_tools)
*    WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
*  LEAVE PROGRAM.
*ELSE.
*ENDIF.
** authority check für Bearbeiten
*AUTHORITY-CHECK OBJECT 'ZLVS_DIS'
*    ID 'ZLVS_TA' FIELD sy-tcode
*    ID 'ACTVT' FIELD '02'
*    ID 'ZLVS_KL' DUMMY
*    ID 'ZLVS_LAGER' FIELD zlvs_pickkopf-lager.
*IF sy-subrc NE 0.
*  edit_authority = 0.
*ELSE.
*  edit_authority = 1.
*ENDIF.


PERFORM get_data.

CALL SCREEN 100.



INCLUDE zcl_maintain_plint_cfg_00c01.

INCLUDE zcl_maintain_plint_cfg_00cl1.

INCLUDE zcl_maintain_plint_cfg_00f01.

INCLUDE zcl_maintain_plint_cfg_00o01.

INCLUDE zcl_maintain_plint_cfg_00i01.
