FUNCTION Z_GET_EBELN_VORSATZ.
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
* 07.09.2005 - Kopie Anpassung Karl Mayer
*-----------------------------------------------------------------------
* Mitgabe von Vorsatz: "Einkaufsbeleg"
*-----------------------------------------------------------------------


*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL

  wa_plotjob = i_wa_plotjobs.
  CLEAR o_stempel_wert.

  IF wa_plotjob-ebeln IS INITIAL.
*   keine Reaktion
  ELSE.
    CONCATENATE text-006 wa_plotjob-ebeln
      INTO o_stempel_wert SEPARATED BY space.
  ENDIF.

*  o_stempel_wert = wa_plotjob-ebeln.



ENDFUNCTION.
