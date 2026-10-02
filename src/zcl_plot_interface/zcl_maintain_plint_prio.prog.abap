*&---------------------------------------------------------------------*
*& Report  ZCL_MAINTAIN_PLINT_CFG_00                                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:
*-----------------------------------------------------------------------
* Journal
* 03.03.2005 - JavaGUIAnpassung
*-----------------------------------------------------------------------

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

*VARI
  DATA: TAB_NAME(30) value 'ZCL_PRIORITAETEN'.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.

*ITAB
DATA: itab TYPE TABLE OF zcl_prioritaeten.
*WA
DATA: wa TYPE zcl_prioritaeten.
*NORMAL
DATA: index_itab TYPE i.

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
       itab2       like itab,
       wa2         like wa,
       flag_toggle_pname  TYPE c .

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
SELECT-OPTIONS: s_1 FOR wa-ID.
SELECT-OPTIONS: s_2 FOR wa-Prio_von.
SELECT-OPTIONS: s_3 FOR wa-prio_bis.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: sinsname FOR wa-zclinsname.
SELECT-OPTIONS: sinsdate FOR wa-zclinsdate.
SELECT-OPTIONS: sinstime FOR wa-zclinstime.
SELECT-OPTIONS: sinsprog FOR wa-zclinsprog.
SELECT-OPTIONS: supdname FOR wa-zclinsname.
SELECT-OPTIONS: supddate FOR wa-zclupddate.
SELECT-OPTIONS: supdtime FOR wa-zclupdtime.
SELECT-OPTIONS: supdprog FOR wa-zclupdprog.
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

CLEAR flag_modifications.

CALL SCREEN 100.



INCLUDE ZCL_MAINTAIN_PLINT_PRIOC01.

INCLUDE ZCL_MAINTAIN_PLINT_PRIOCL1.

INCLUDE ZCL_MAINTAIN_PLINT_PRIOF01.

INCLUDE ZCL_MAINTAIN_PLINT_PRIOO01.

INCLUDE ZCL_MAINTAIN_PLINT_PRIOI01.
