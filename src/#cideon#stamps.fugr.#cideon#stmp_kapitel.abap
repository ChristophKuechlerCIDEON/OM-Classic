FUNCTION /cideon/stmp_kapitel.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Normung aus Statuslog DIS / Nutzer - Fester Text
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.04.2005 - Erstellung
* 12.11.2005 - Kopie
* 15.02.2006 - Kopie
* 20.02.2006 - Kopie
* 07.08.2007 - Kopie
*-----------------------------------------------------------------------

*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.


  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  CLEAR o_stempel_wert.


  o_stempel_wert = wa_plotjob-kapitel.


ENDFUNCTION.
