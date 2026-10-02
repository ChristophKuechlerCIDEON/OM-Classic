FUNCTION Z_GET_AUFNR_ALPHA.
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
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 17.05.2005 - Erstellung
* 07.09.2005 - Kopie / Anpassung
*-----------------------------------------------------------------------

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = i_wa_plotjobs-aufnr
    IMPORTING
      output = i_wa_plotjobs-aufnr.

*  o_stempel_wert = i_wa_plotjobs-aufnr.

  CLEAR o_stempel_wert.

  IF i_wa_plotjobs-aufnr IS INITIAL.
  ELSE.
    CONCATENATE text-005 i_wa_plotjobs-aufnr
    INTO o_stempel_wert SEPARATED BY space.
  ENDIF.

ENDFUNCTION.
