*&---------------------------------------------------------------------*
*& Report  ZCK_MAINT_ZCLUG_CL_N_USE_S                                  *
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

REPORT  zck_maint_zclug_cl_n_use_s    .

INCLUDE zck_maint_zclug_cl_n_use_s_tmp.

* control
CONTROLS tabstr TYPE TABSTRIP.

*********
* Predefine a local class for event handling to allow the
* declaration of a reference variable.
CLASS lcl_event_handler DEFINITION DEFERRED.
*********

* tables
TABLES: zclug_cl_n_use_s.
TABLES sscrfields.


* types
TYPES: BEGIN OF ty_.
        INCLUDE STRUCTURE zclug_cl_n_use_s.
TYPES: END OF ty_.

DATA: tabname TYPE tabname VALUE 'ZCLUG_CL_N_USE_S'.

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

*DATA: ZCL_USR_GRP_KL like ZCL_USR_GRP_KL.


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
  s_user FOR zclug_cl_n_use_s-nutzer,
  s_usrgrp  FOR zclug_cl_n_use_s-nutzer_gruppe.
SELECTION-SCREEN END OF BLOCK bl1.

*WERTE
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-011.
SELECT-OPTIONS:
   s_status FOR zclug_cl_n_use_s-status.
SELECTION-SCREEN END OF BLOCK bl2.

*INFO
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-012.
SELECT-OPTIONS:
   sinsname FOR zclug_cl_n_use_s-zclinsname,
   sinsdate FOR zclug_cl_n_use_s-zclinsdate,
   sinstime FOR zclug_cl_n_use_s-zclinstime,
   sinsprog FOR zclug_cl_n_use_s-zclinsprog,
   supdname FOR zclug_cl_n_use_s-zclupdname,
   supddate FOR zclug_cl_n_use_s-zclupddate,
   supdtime FOR zclug_cl_n_use_s-zclupdtime,
   supdprog FOR zclug_cl_n_use_s-zclupdprog .
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
  INCLUDE zck_maint_zclug_cl_n_use_s_cla.

  INCLUDE zck_maint_zclug_cl_n_use_s_pbo.
  INCLUDE zck_maint_zclug_cl_n_use_s_pai.
  INCLUDE zck_maint_zclug_cl_n_use_s_for.
