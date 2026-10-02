FUNCTION z_cl_get_pmode_text.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  CASE i_wa_plotjobs-pmode.
    WHEN 'B'.
      o_stempel_wert = text-020.
    WHEN 'O'.
      o_stempel_wert = text-021.
    WHEN OTHERS.
      o_stempel_wert = i_wa_plotjobs-pmode.
  ENDCASE.


*  o_stempel_wert = i_wa_plotjobs-pspid.


ENDFUNCTION.
