*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLOT_FERTIGUNGSAUFTRAG_I01                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

*  save_ok_code = ok_code.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
*  Tabs
    WHEN 'TAB1'.
      tab_strp_control_001-activetab = 'TAB1'.
    WHEN 'TAB2'.
      tab_strp_control_001-activetab = 'TAB2'.
    WHEN 'TAB3'.
      tab_strp_control_001-activetab = 'TAB3'.
    WHEN 'TAB4'.
      tab_strp_control_001-activetab = 'TAB4'.
    WHEN 'PLOT'.
      PERFORM check_values.
      PERFORM clear_tables.
      PERFORM get_items.
      PERFORM make_sl_tmp_entries.

**     BYPASS
*      IF wa_fertigung-knz_no_bypass = 'X'.
*        SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
*      ELSE.
*        SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
*      ENDIF.

      IF wa_fertigung-knz_sofort_plotten = 'X'.
        PERFORM make_itab_drad_to_plot.
        PERFORM make_plot_entries.
        PERFORM call_plot_interface.
      ELSE.
        " erstmal Anzeige, dann weitere Auswahl
        CALL SCREEN 200.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb INPUT.
*
*  wa_fertigung-knz_sofort_plotten = cb_knz_sofort_plotten.
*  wa_fertigung-knz_dok_link = cb_knz_dok_link.
*  wa_fertigung-knz_mat_link = cb_knz_mat_link.
*  wa_fertigung-knz_txt_link = cb_knz_txt_link.
*  wa_fertigung-knz_aufpl_vorgaenge = cb_knz_aufpl_vorgaenge.
*  wa_fertigung-knz_aufpl_folgen = cb_knz_aufpl_folgen.
*
*  wa_fertigung-knz_stl_aufl = cb_knz_stl_aufl.
*
*  wa_fertigung-knz_dok_stl_aufl = cb_knz_dok_stl_aufl.
*  wa_fertigung-knz_dok_link_aufl = cb_knz_dok_link_aufl.
*  wa_fertigung-knz_dok_hier_aufl = cb_knz_dok_hier_aufl.
*  wa_fertigung-knz_dok_stl_aufl_mehrst = cb_knz_dok_stl_aufl_mehrst.
*  wa_fertigung-knz_dok_link_aufl_mehrst = cb_knz_dok_link_aufl_mehrst.
*  wa_fertigung-knz_dok_hier_aufl_mehrst = cb_knz_dok_hier_aufl_mehrst.

ENDMODULE.                 " GET_CB  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input INPUT.
* checken auf bestimmte Eingaben

  IF wa_fertigung-knz_stl_aufl = 'X'.
    IF wa_capid-capid IS INITIAL.
      MESSAGE w001(zcl_plot_fertigung) WITH '' '' '' ''.
      CLEAR ok_code.
    ELSE.
    ENDIF.
  ELSE.

  ENDIF.


ENDMODULE.                 " check_input  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
*  save_ok_code = ok_code.

*     BYPASS
  IF wa_fertigung-knz_no_bypass = 'X'.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
  ELSE.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
  ENDIF.


  CASE ok_code.
    WHEN 'BACK'.
*     BYPASS
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
      COMMIT WORK AND WAIT.
      LEAVE TO SCREEN 100.
    WHEN 'CANC'.
*     BYPASS
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
      COMMIT WORK AND WAIT.
      LEAVE TO SCREEN 100.
    WHEN 'EXIT'.
*     BYPASS
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
      COMMIT WORK AND WAIT.
      LEAVE TO SCREEN 100.
    WHEN 'TO_PLOT'.
      PERFORM get_sel_drad.
      PERFORM make_plot_entries.
      PERFORM call_plot_interface.
*     BYPASS
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
      COMMIT WORK AND WAIT.
    WHEN OTHERS.
*     BYPASS
      SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
      COMMIT WORK AND WAIT.
  ENDCASE.

  CLEAR ok_code.


ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_101 INPUT.
  wa_fertigung-knz_sofort_plotten = cb_knz_sofort_plotten.
  wa_fertigung-knz_no_bypass = cb_knz_no_bypass.
  wa_fertigung-knz_dok_link = cb_knz_dok_link.
  wa_fertigung-knz_mat_link = cb_knz_mat_link.
  wa_fertigung-knz_txt_link = cb_knz_txt_link.
ENDMODULE.                 " get_cb_101  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_102 INPUT.
  wa_fertigung-knz_stl_aufl = cb_knz_stl_aufl.
ENDMODULE.                 " get_cb_102  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_103 INPUT.
  wa_fertigung-knz_dok_stl_aufl = cb_knz_dok_stl_aufl.
  wa_fertigung-knz_dok_link_aufl = cb_knz_dok_link_aufl.
  wa_fertigung-knz_dok_hier_aufl = cb_knz_dok_hier_aufl.
  wa_fertigung-knz_dok_stl_aufl_mehrst = cb_knz_dok_stl_aufl_mehrst.
  wa_fertigung-knz_dok_link_aufl_mehrst = cb_knz_dok_link_aufl_mehrst.
  wa_fertigung-knz_dok_hier_aufl_mehrst = cb_knz_dok_hier_aufl_mehrst.
ENDMODULE.                 " get_cb_103  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cb_104  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cb_104 INPUT.
  wa_fertigung-knz_aufpl_vorgaenge = cb_knz_aufpl_vorgaenge.
  wa_fertigung-knz_aufpl_folgen = cb_knz_aufpl_folgen.
ENDMODULE.                 " get_cb_104  INPUT
