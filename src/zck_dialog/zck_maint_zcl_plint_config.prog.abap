*&---------------------------------------------------------------------*
*& Report  ZCK_MAINT_zcl_plint_config                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:
*
*-----------------------------------------------------------------------
* Journal
* xx.xx.2002 -
* 06.10.2004 - Änderungen für Rollenkonzept
* 20.01.2004 - Selektion über Parameterwert
* 03.03.2005 - JavaGUI Anpassung
*&---------------------------------------------------------------------*


report  zck_maint_zcl_plint_config    .

include zck_gen_control.

* control
controls tabstr type tabstrip.

*********
* Predefine a local class for event handling to allow the
* declaration of a reference variable.
class lcl_event_handler definition deferred.
*********

* tables
tables: zcl_plint_config.
tables sscrfields.


* types
types: begin of ty_.
        include structure zcl_plint_config.
types: end of ty_.

data: tabname type tabname value 'ZCL_PLINT_CONFIG'.

data: ok_code like sy-ucomm,
        returncode like bdcmsgcoll,

* Exclude table
      it_excl type table of rsexfcode,
      wa_excl like line of it_excl,

* reference variables
      ref_container     type ref to cl_gui_docking_container,
        "cl_gui_custom_container,
      ref_alv           type ref to cl_gui_alv_grid,

* layout variable of alv grid
      wa_s_layo         type lvc_s_layo,

* variant structure
      wa_s_variant      type disvariant,

* field catalog
      it_field_cat      type table of lvc_s_fcat,
      wa_field_cat      type lvc_s_fcat,

* internal table
      it          type table of ty_,
      it_det      type table of ty_,

* working area
      wa                like line of it,
      index             type i,
      max_lines         type i,
      wa_edit_mode,
      wa_save_neccessary,
      answer,
      dynp(4).
data: count_lines type i. "Anzahl der Einträge

*DATA: zcl_plint_cfg_00 like zcl_plint_cfg_00.


*FIELD SYMBOLS
field-symbols <wa> type ty_.




* authority check
* Berechtigungscheck
authority-check object 'ZCL_PLOT_2'
         id 'ZCL_TA' field sy-tcode
         id 'ACTVT' field '16'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
.
if sy-subrc > 0.
  message s099(zcl_plint_tools)
    with '' '' '' ''.  "Sie haben keine Berechtigung ..
  leave program.
else.
endif.


* selection screen
*KEY
selection-screen begin of block bl1 with frame title text-010.
select-options:
  s_uname for zcl_plint_config-uname default sy-uname
  ,s_pname for zcl_plint_config-pname
  ,s_rolle for zcl_plint_config-rolle
  .
selection-screen end of block bl1.

*WERTE
selection-screen begin of block bl2 with frame title text-011.
select-options:
   s_pwert for zcl_plint_config-pwert
  ,s_pdoku for zcl_plint_config-pdoku
  .
selection-screen end of block bl2.

*INFO
selection-screen begin of block bl3 with frame title text-012.
select-options:
   sinsname for zcl_plint_config-zclinsname
  ,sinsdate for zcl_plint_config-zclinsdate
  ,sinstime for zcl_plint_config-zclinstime
  ,sinsprog for zcl_plint_config-zclinsprog
  ,supdname for zcl_plint_config-zclupdname
  ,supddate for zcl_plint_config-zclupddate
  ,supdtime for zcl_plint_config-zclupdtime
  ,supdprog for zcl_plint_config-zclupdprog .
selection-screen end of block bl3.

*ZUSATZ
selection-screen begin of block bl4 with frame title text-013.
parameters:
list_bre like rseumod-tblistbr default '250' no-display,
max_sel  like rseumod-tbmaxsel default '500'. " NO-DISPLAY.
selection-screen end of block bl4.

selection-screen: function key 1.

initialization.
  sscrfields-functxt_01 = text-020.
*  SET TITLEBAR 'COUNT_LINES'.

start-of-selection.

at selection-screen.
* set edit mode to show (= '0')
  wa_edit_mode = co_show_mode.

  case sscrfields-ucomm.
      when'FC01'.
* Anzahl der Einträge
      perform get_data_count.
      set titlebar 'COUNT_LINES' with count_lines '' '' '' ''.
    when 'ONLI'.
* get selected data
      perform get_data.
* call first screen
*      IF it[] IS INITIAL.
*      ELSE.
      call screen 100.
*      ENDIF.
  endcase.


* Include files
  include zck_config_alv_edit_class.
  include zck_config_alv_edit_pbo.
  include zck_config_alv_edit_pai.
  include zck_config_alv_edit_form.
