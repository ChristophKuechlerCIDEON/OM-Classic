*&---------------------------------------------------------------------*
*& Report  ZCL_TRANSPORT_TABLES_PLOT                                   *
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
*-----------------------------------------------------------------------
* Journal
* 23.08.2003  Erstellung
*-----------------------------------------------------------------------
REPORT  zcl_transport_tables_plot     .

* TYPES
* ITAB
* WA
* NORMAL
DATA: ok_code TYPE sy-ucomm.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.



*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.


  CASE ok_code.
    WHEN 'TRANS'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
*  Tabs
    WHEN 'TAB1'.
      tabstripcontrol_001-activetab = 'TAB1'.
    WHEN 'TAB2'.
      tabstripcontrol_001-activetab = 'TAB2'.
    when others.
  ENDCASE.

clear ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZCL_TRANSPORT_TABLES_PLOT'.
  SET TITLEBAR 'ZCL_TRANSPORT_TABLES_PLOT'.

ENDMODULE.                 " STATUS_0100  OUTPUT
