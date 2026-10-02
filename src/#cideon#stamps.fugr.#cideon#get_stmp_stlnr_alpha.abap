FUNCTION /cideon/get_stmp_stlnr_alpha.
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
* 02.08.2006 - Kopie und Anpassung
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

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = wa_plotjob-stlnr
       IMPORTING
            output = o_stempel_wert.


*  o_stempel_wert = wa_plotjob-stlnr.


ENDFUNCTION.
