FUNCTION z_cl_get_aufnr_alpha.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = i_wa_plotjobs-aufnr
       IMPORTING
            output = o_stempel_wert.

*  o_stempel_wert = i_wa_plotjobs-aufnr.


ENDFUNCTION.
