*&---------------------------------------------------------------------*
*& Report  ZCK_MAINT_ZCL_GROUP_TDWP                                  *
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

REPORT  zck_maint_zcl_group_tdwp   .

INCLUDE zck_gen_control.

* control
CONTROLS tabstr TYPE TABSTRIP.

*********
* Predefine a local class for event handling to allow the
* declaration of a reference variable.
CLASS lcl_event_handler DEFINITION DEFERRED.
*********

* tables
TABLES: zcl_group_tdwp.
TABLES sscrfields.


* types
TYPES: BEGIN OF ty_.
        INCLUDE STRUCTURE zcl_group_tdwp.
TYPES: END OF ty_.

DATA: tabname TYPE tabname VALUE 'ZCL_GROUP_TDWP'.

DATA: ok_code LIKE sy-ucomm,
        returncode LIKE bdcmsgcoll,

* Exclude table
      it_excl TYPE TABLE OF rsexfcode,
      wa_excl LIKE LINE OF it_excl,

* reference variables
      ref_container     TYPE REF TO cl_gui_docking_container,
        "cl_gui_custom_container,
      ref_alv           TYPE REF TO cl_gui_alv_grid,

* layout variable of alv grid
      wa_s_layo         TYPE lvc_s_layo,

* variant structure
      wa_s_variant      TYPE disvariant,

* field catalog
      it_field_cat      TYPE TABLE OF lvc_s_fcat,
      wa_field_cat      TYPE lvc_s_fcat,

* internal table
      it          TYPE TABLE OF ty_,
      it_det      TYPE TABLE OF ty_,

* working area
      wa                LIKE LINE OF it,
      index             TYPE i,
      max_lines         TYPE i,
      wa_edit_mode,
      wa_save_neccessary,
      answer,
      dynp(4).
DATA: count_lines TYPE i. "Anzahl der Einträge

*DATA: ZCL_GROUP_TDWP like ZCL_GROUP_TDWP.


*FIELD SYMBOLS
FIELD-SYMBOLS <wa> TYPE ty_.




* authority check
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


* selection screen
*KEY
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-010.
SELECT-OPTIONS:
  s_group FOR zcl_group_tdwp-user_group,
  s_dappl FOR zcl_group_tdwp-dappl
  .
SELECTION-SCREEN END OF BLOCK bl1.
*WERTE
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-011.
SELECT-OPTIONS:
  s_status FOR zcl_group_tdwp-status.
SELECTION-SCREEN END OF BLOCK bl2.

*INFO
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-012.
SELECT-OPTIONS:
   sinsname FOR zcl_group_tdwp-zclinsname
  ,sinsdate FOR zcl_group_tdwp-zclinsdate
  ,sinstime FOR zcl_group_tdwp-zclinstime
  ,sinsprog FOR zcl_group_tdwp-zclinsprog
  ,supdname FOR zcl_group_tdwp-zclupdname
  ,supddate FOR zcl_group_tdwp-zclupddate
  ,supdtime FOR zcl_group_tdwp-zclupdtime
  ,supdprog FOR zcl_group_tdwp-zclupdprog .
SELECTION-SCREEN END OF BLOCK bl3.

*ZUSATZ
SELECTION-SCREEN BEGIN OF BLOCK bl4 WITH FRAME TITLE text-013.
PARAMETERS:
list_bre LIKE rseumod-tblistbr DEFAULT '250' NO-DISPLAY,
max_sel  LIKE rseumod-tbmaxsel DEFAULT '500'. " NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK bl4.

SELECTION-SCREEN: FUNCTION KEY 1.

INITIALIZATION.
  sscrfields-functxt_01 = text-020.
*  SET TITLEBAR 'COUNT_LINES'.

START-OF-SELECTION.

AT SELECTION-SCREEN.
* set edit mode to show (= '0')
  wa_edit_mode = co_show_mode.

  CASE sscrfields-ucomm.
      WHEN'FC01'.
* Anzahl der Einträge
      PERFORM get_data_count.
      SET TITLEBAR 'COUNT_LINES' WITH count_lines '' '' '' ''.
    WHEN 'ONLI'.
* get selected data
      PERFORM get_data.
* call first screen
*      IF it[] IS INITIAL.
*      ELSE.
      CALL SCREEN 100.
*      ENDIF.
  ENDCASE.


* Include files
  INCLUDE zck_group_tdwp_alv_edit_class.
*INCLUDE ZCK_USR_TDWP_ALV_EDIT_CLASS.
  INCLUDE zck_group_tdwp_alv_edit_pbo.
*INCLUDE ZCK_USR_TDWP_ALV_EDIT_PBO.
  INCLUDE zck_group_tdwp_alv_edit_pai.
*INCLUDE ZCK_USR_TDWP_ALV_EDIT_PAI.
  INCLUDE zck_group_tdwp_alv_edit_form.
*INCLUDE ZCK_USR_TDWP_ALV_EDIT_FORM.
