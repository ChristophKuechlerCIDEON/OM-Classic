FUNCTION Z_CL_GET_NAME_FIRMA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------


  concatenate I_WA_PLOTJOBS-Name1 '/' I_WA_PLOTJOBS-name2 '/'
    I_WA_PLOTJOBS-firma into  o_stempel_wert.


ENDFUNCTION.
