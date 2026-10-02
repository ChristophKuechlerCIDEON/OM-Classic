FUNCTION z_cl_get_dostxt_en.
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
  DATA: spras TYPE spras.

  spras = 'En'.

  SELECT SINGLE * FROM drat INTO wa_drat
    WHERE dokar = i_wa_plotjobs-dokar
    AND doknr = i_wa_plotjobs-doknr
    AND dokvr = i_wa_plotjobs-dokvr
    AND doktl = i_wa_plotjobs-doktl
    AND langu = spras
    .
  IF sy-subrc NE 0.
    CLEAR o_stempel_wert.
  ELSE.
    o_stempel_wert = wa_drat-dktxt.
  ENDIF.

ENDFUNCTION.
