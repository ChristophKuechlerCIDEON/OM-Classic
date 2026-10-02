FUNCTION z_cl_get_dostxt_uni.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA: wa_drat TYPE drat.

  SELECT SINGLE * FROM drat INTO wa_drat
    WHERE dokar = i_wa_plotjobs-dokar
    AND doknr = i_wa_plotjobs-doknr
    AND dokvr = i_wa_plotjobs-dokvr
    AND doktl = i_wa_plotjobs-doktl
    AND langu = sy-langu
    .
  IF sy-subrc NE 0.
  ELSE.
    o_stempel_wert = i_wa_plotjobs-dostx.
  ENDIF.

ENDFUNCTION.
