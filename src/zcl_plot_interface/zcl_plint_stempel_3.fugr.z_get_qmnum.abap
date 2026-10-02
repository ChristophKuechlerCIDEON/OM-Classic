FUNCTION z_get_qmnum.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.04.2005 - Erstellung
* 19.09.2005 - Kopie
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------


*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL

  wa_plotjob = i_wa_plotjobs.
  CLEAR o_stempel_wert.



  o_stempel_wert = wa_plotjob-qmnum.


ENDFUNCTION.
