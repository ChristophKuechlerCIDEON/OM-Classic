*&---------------------------------------------------------------------*
*& Report  ZCL_PRINT_FAUF_START_PLOT  *
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
*-----------------------------------------------------------------------
* Journal
* 29.09.2003 - Erstellung
* 01.10.2003 - Einstellungen lesen
* to do
*-----------------------------------------------------------------------

REPORT  zcl_print_fauf_01 .


*TYPES
*ITAB
DATA: itab_items_fauf TYPE TABLE OF zcl_pdm_objects_fa_int.
*WA
DATA: wa_default_data TYPE /cideon/plot_defaultdata.
DATA: wa_user_data TYPE /cideon/plot_userdata.
DATA: wa_item_fauf TYPE zcl_pdm_objects_fa_int.
*NORMAL



* Einstellungen lesen
CLEAR wa_user_data.
CLEAR wa_default_data.

CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
     EXPORTING
          i_batch        = ''
     IMPORTING
          o_default_data = wa_default_data.


CALL FUNCTION '/CIDEON/READ_USERDATA'
     EXPORTING
          i_default_data = wa_default_data
     IMPORTING
          o_user_data    = wa_user_data.


* mglw. automatischer Durchlauf durch PlotInterface
IF wa_user_data-knz_auto_fauf = 'X'.
  SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
ELSE.
  SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
ENDIF.

* Satzanzahl
*DATA: count_satz_c(5).
*CLEAR count_satz_c.
*
*count_satz_c = wa_user_data-default_satzanzahl.
*SET PARAMETER ID '/CIDEON/OM_SET' FIELD count_satz_c.

* Aufruf des PlotInterfaces
SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.


* Einstellungen zurücksetzen
SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.
