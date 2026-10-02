FUNCTION /CIDEON/GET_STMP_PRINT_TYPE.
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
* 05.07.2006 - Erstellung
* 30.09.2008 - Kopie
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: wa_partner_addr TYPE /cideon/sdpartner.
*NORMAL

  CLEAR o_stempel_wert.

  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.



* Feld befüllen
  o_stempel_wert = wa_plotjob-print_type.


ENDFUNCTION.
