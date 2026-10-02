FUNCTION z_get_cadkz.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 31.03.2005 - Erstellung
* 01.12.2005 - Kopie
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL

  wa_plotjob = i_wa_plotjobs.

* CAD Kennzeichen lesen
  DATA: wa_draw TYPE draw.

  SELECT SINGLE * FROM draw INTO wa_draw
    WHERE dokar = wa_plotjob-dokar
    AND doknr = wa_plotjob-doknr
    AND doktl = wa_plotjob-doktl
    AND dokvr = wa_plotjob-dokvr
    .
  IF sy-subrc NE 0.
    CLEAR o_stempel_wert.
  ELSE.
    o_stempel_wert =   wa_draw-cadkz.
  ENDIF.


*  o_stempel_wert =   wa_plotjob-dktxt.



ENDFUNCTION.
