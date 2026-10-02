FUNCTION Z_CL_GET_ADRESSE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  concatenate I_WA_PLOTJOBS-name1 '/' I_WA_PLOTJOBS-name1 '/'
    I_WA_PLOTJOBS-Firma '/' I_WA_PLOTJOBS-Abteilung '/'
    I_WA_PLOTJOBS-stras '/' I_WA_PLOTJOBS-ort1 '/'
    I_WA_PLOTJOBS-pstlz '/' I_WA_PLOTJOBS-telf1 '/'
    I_WA_PLOTJOBS-telfx '/' I_WA_PLOTJOBS-smtp_addr '/'
    into o_stempel_wert.

ENDFUNCTION.
