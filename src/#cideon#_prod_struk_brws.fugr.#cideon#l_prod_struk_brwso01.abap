*----------------------------------------------------------------------*
***INCLUDE /CIDEON/L_PROD_STRUK_BRWSO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0100 output.
  set pf-status 'PF_100'.
*  SET TITLEBAR 'xxx'.

endmodule.                 " STATUS_0100  OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'TAB_CNTRL_01':
* GET LINES OF TABLECONTROL
module tab_cntrl_01_get_lines output.
  g_tab_cntrl_01_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0200 output.
  set pf-status 'STATUS_CAPID'.
  set titlebar 'TITLE_CAPID'.

endmodule.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0300 output.
  set pf-status '0300'.
  set titlebar '0300'.

endmodule.                 " STATUS_0300  OUTPUT
