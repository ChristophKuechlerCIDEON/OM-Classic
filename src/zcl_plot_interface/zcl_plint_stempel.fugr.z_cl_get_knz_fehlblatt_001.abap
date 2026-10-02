FUNCTION z_cl_get_knz_fehlblatt_001.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------


*  o_stempel_wert = i_wa_plotjobs-knz_fehl_blatt.

  IF i_wa_plotjobs-knz_fehl_blatt = 'X'.
    o_stempel_wert = text-050.
  ELSE.
  ENDIF.


ENDFUNCTION.
