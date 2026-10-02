FUNCTION Z_CL_GET_BATCH.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  if sy-batch = 'X'.
    o_stempel_wert = text-000.
  else.
    o_stempel_wert = text-001.
  endif.


ENDFUNCTION.
