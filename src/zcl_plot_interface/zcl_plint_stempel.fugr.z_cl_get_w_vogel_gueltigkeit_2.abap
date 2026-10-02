FUNCTION z_cl_get_w_vogel_gueltigkeit_2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*  falls das Dokument sich nicht im Freigabestatus befindet ist der
*  Stempelwert auf "Ungültig" zu setzen
*
*"----------------------------------------------------------------------

* ITAB
  DATA: itab_tdws TYPE TABLE OF tdws.
* WA
  DATA: wa_draw TYPE draw.
  DATA: wa_tdws TYPE tdws.
* NORMAL
  DATA: stempel_wert TYPE zcl_stempel_wert.


  CLEAR stempel_wert.
  CLEAR itab_tdws.

* Freigabestatus  für verwendete Dokumentenart erfragen
  SELECT SINGLE * FROM tdws INTO wa_tdws
    WHERE dokar = i_wa_plotjobs-dokar
      AND dokst = i_wa_plotjobs-dokst
      AND frknz = 'X'
      .
  IF sy-subrc NE 0.
*   leider kein Freigabestatus
    stempel_wert = text-013.
  ELSE.
*   ist Freigabestatus
    stempel_wert = text-012.
  ENDIF.

  o_stempel_wert = stempel_wert.

ENDFUNCTION.
