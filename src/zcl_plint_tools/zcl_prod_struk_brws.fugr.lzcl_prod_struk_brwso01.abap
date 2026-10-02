*----------------------------------------------------------------------*
***INCLUDE LZCL_PROD_STRUK_BRWSO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_100'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'TAB_CNTRL_01':
* GET LINES OF TABLECONTROL
MODULE tab_cntrl_01_get_lines OUTPUT.
  g_tab_cntrl_01_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS_CAPID'.
  SET TITLEBAR 'TITLE_CAPID'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.

ENDMODULE.                 " STATUS_0300  OUTPUT
