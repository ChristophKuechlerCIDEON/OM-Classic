FUNCTION z_cl_get_w_vogel_dok_state_un.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* Sprachabhängige Stati / speziel für Willy Vogel
  DATA: wa_tdwst TYPE tdwst.


  IF i_wa_plotjobs-dokst = 'UN'.
    SELECT SINGLE * FROM tdwst INTO wa_tdwst
      WHERE  cvlang = sy-langu
      AND dokst = i_wa_plotjobs-dokst
      .
    IF sy-subrc NE 0.
      CLEAR wa_tdwst.
    ELSE.
    ENDIF.
  ELSE.
    CLEAR wa_tdwst.
  ENDIF.


  o_stempel_wert = wa_tdwst-dostx.


ENDFUNCTION.
