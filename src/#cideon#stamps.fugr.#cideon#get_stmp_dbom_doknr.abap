FUNCTION /CIDEON/GET_STMP_DBOM_DOKNR.
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
* 30.03.2006 - Erstellung
*-----------------------------------------------------------------------
* Stücklistennummer auf Stempel
*
*-----------------------------------------------------------------------


*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL



  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  o_stempel_wert = wa_plotjob-doknr_bom.


ENDFUNCTION.
