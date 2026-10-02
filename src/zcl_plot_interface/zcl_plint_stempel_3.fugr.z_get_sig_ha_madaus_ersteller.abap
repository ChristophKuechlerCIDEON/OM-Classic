FUNCTION Z_GET_SIG_HA_MADAUS_ERSTELLER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"       EXPORTING
*"             VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 31.01.2005 - Erstellung
*              Herstellanweisung (Ersteller) Madaus
*              setzt den Status 30
* 01.02.2005 -
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_signs_dms_tab TYPE TABLE OF rc77b.
*WA
  DATA: wa_draw TYPE draw.
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: wa_key_dms_imp TYPE rc77.
  DATA: wa_signs_dms_tab TYPE rc77b.





ENDFUNCTION.
