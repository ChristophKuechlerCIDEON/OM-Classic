FUNCTION z_cl_get_draw_dwname.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
  DATA: wa_draw TYPE draw.


  SELECT SINGLE * FROM draw INTO wa_draw
    WHERE dokar = i_wa_plotjobs-dokar
      AND doknr = i_wa_plotjobs-doknr
      AND doktl = i_wa_plotjobs-doktl
      AND dokvr = i_wa_plotjobs-dokvr
      .
  IF sy-subrc NE 0.
    RAISE error.
  ELSE.
  ENDIF.

  o_stempel_wert = wa_draw-dwnam.


ENDFUNCTION.
