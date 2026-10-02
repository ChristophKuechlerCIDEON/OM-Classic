*&---------------------------------------------------------------------*
*& Report  /CIDEON/MAINT_WSA_DOWN                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:
*-----------------------------------------------------------------------
* Journal
* 12.02.2007 - Kopie
* 28.02.2007 - Erweiterung um Flag "Alle WSA Downloaden"
*-----------------------------------------------------------------------

report  /cideon/maint_wsa_down .

include /cideon/_maint_wsa_down_ctrl.
*include z_maint_zcl_fauf_werk_ve_ctrl.
*INCLUDE zck_maint_zcl_grp_clas_kl_ctrl.
*INCLUDE zck_gen_control.

* control
controls tabstr type tabstrip.

*********
* Predefine a local class for event handling to allow the
* declaration of a reference variable.
class lcl_event_handler definition deferred.
*********

* tables
tables: /cideon/wsa_down.
tables sscrfields.


* types
types: begin of ty_.
        include structure /cideon/wsa_down.
types: end of ty_.

data: tabname type tabname value '/CIDEON/WSA_DOWN'.

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

*DATA: zcl_grp_class_kl like zcl_grp_class_kl.


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
  s_dokar for /cideon/wsa_down-dokar,
  s_dappl for /cideon/wsa_down-dappl

  .
selection-screen end of block bl1.

*WERTE
selection-screen begin of block bl2 with frame title text-011.
select-options:
     s_getstr for /cideon/wsa_down-getstructure,
  s_status for /cideon/wsa_down-status
  .
selection-screen end of block bl2.

*INFO
selection-screen begin of block bl3 with frame title text-012.
select-options:
   sinsname for /cideon/wsa_down-insname,
   sinsdate for /cideon/wsa_down-insdate,
   sinstime for /cideon/wsa_down-instime,
   sinsprog for /cideon/wsa_down-insprog,
   supdname for /cideon/wsa_down-updname,
   supddate for /cideon/wsa_down-upddate,
   supdtime for /cideon/wsa_down-updtime,
   supdprog for /cideon/wsa_down-updprog .
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
  include /cideon/_maint_wsa_down_cl.
*  include z_maint_zcl_fauf_werk_ve_cl.
  include /cideon/_maint_wsa_down_pbo.
*  include z_maint_zcl_fauf_werk_ve_pbo.
  include /cideon/_maint_wsa_down_pai.
*  include z_maint_zcl_fauf_werk_ve_pai.
  include /cideon/_maint_wsa_down_fm.
*  include z_maint_zcl_fauf_werk_ve_fm.
