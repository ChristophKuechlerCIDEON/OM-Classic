FUNCTION z_cl_get_w_vogel_dok_state_big.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*
*
*
*"----------------------------------------------------------------------

* ITAB
* WA
  DATA: wa_draw TYPE draw.
* NORMAL
  DATA: stempel_wert TYPE zcl_stempel_wert.


  CLEAR stempel_wert.

  IF i_wa_plotjobs-dokst = 'FR'.
*   leer Rückgeben
  ELSE.
*   Inhalt von DOKSTX
    DATA: wa_tdwst TYPE tdwst.

    SELECT SINGLE * FROM tdwst INTO wa_tdwst
      WHERE  cvlang = sy-langu
      AND dokst = i_wa_plotjobs-dokst
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    stempel_wert = wa_tdwst-dostx.

  ENDIF.

* Stempelwert zurückgeben
  o_stempel_wert = stempel_wert.


ENDFUNCTION.
