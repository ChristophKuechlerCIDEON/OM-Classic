FUNCTION z_cl_get_w_vogel_gueltigkeit.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*  falls eine neuere Version verfüpgbar ist, so ist der Rückgabewert
*  auf "Ungültig" zu setzen
*
*"----------------------------------------------------------------------

* ITAB
* WA
  DATA: wa_draw TYPE draw.
* NORMAL
  DATA: stempel_wert TYPE zcl_stempel_wert.


  CLEAR stempel_wert.

* nach neuerer Version checken
  SELECT SINGLE * FROM draw INTO wa_draw
    WHERE dokar = i_wa_plotjobs-dokar
      AND doknr = i_wa_plotjobs-doknr
      AND doktl = i_wa_plotjobs-doktl
      AND dokvr > i_wa_plotjobs-dokvr
    .
  IF sy-subrc NE 0.
*   ist neueste Version
    stempel_wert = text-010.
  ELSE.
*   neuere Version Verfügbar
    stempel_wert = text-011.
  ENDIF.



* Stempelwert zurückgeben
  o_stempel_wert = stempel_wert.


ENDFUNCTION.
