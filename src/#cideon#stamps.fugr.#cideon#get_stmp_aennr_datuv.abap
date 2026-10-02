FUNCTION /cideon/get_stmp_aennr_datuv.
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
* 17.10.2006 - Kopie
*-----------------------------------------------------------------------
* Änderungsnummer auf Stempel - gültig ab
*
*-----------------------------------------------------------------------


*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL



  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  o_stempel_wert = wa_plotjob-datuv.


ENDFUNCTION.
