FUNCTION z_cl_get_drart_text.
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
* 26.07.2002 - Erstellung
*-----------------------------------------------------------------------

  CASE i_wa_plotjobs-drart.
    WHEN 'O'.
      o_stempel_wert = text-030.
    WHEN 'T'.
      o_stempel_wert = text-031.
    WHEN 'N'.
      o_stempel_wert = text-032.
    WHEN OTHERS.
      o_stempel_wert = i_wa_plotjobs-drart.
  ENDCASE.

*  o_stempel_wert = i_wa_plotjobs-drart.


ENDFUNCTION.
