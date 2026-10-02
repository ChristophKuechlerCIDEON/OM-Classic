FUNCTION z_cl_get_dostx_sql.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"       EXPORTING
*"             VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------

* ergänzt STABK / Sprachabhängige Stati
  DATA: wa_tdwst TYPE tdwst.

  SELECT SINGLE * FROM tdwst INTO wa_tdwst
    WHERE  cvlang = sy-langu
    AND dokst = i_wa_plotjobs-dokst
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  o_stempel_wert = wa_tdwst-dostx.


ENDFUNCTION.
