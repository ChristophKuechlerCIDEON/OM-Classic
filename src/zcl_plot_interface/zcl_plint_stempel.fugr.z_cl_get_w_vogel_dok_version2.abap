FUNCTION z_cl_get_w_vogel_dok_version2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------



  IF i_wa_plotjobs-dokar = 'TEZ'.
    o_stempel_wert = i_wa_plotjobs-dokvr.
  ELSE.
    CLEAR o_stempel_wert.
  ENDIF.


*  o_stempel_wert = .


ENDFUNCTION.
