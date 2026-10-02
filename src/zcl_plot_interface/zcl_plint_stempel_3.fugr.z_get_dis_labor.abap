FUNCTION z_get_dis_labor.
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
* 06.04.2005 - Erstellung
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL
  DATA: labor TYPE draw-labor.

  wa_plotjob = i_wa_plotjobs.
  CLEAR labor.
  SELECT SINGLE labor FROM draw
    INTO labor
    WHERE dokar = wa_plotjob-dokar
    AND doknr = wa_plotjob-doknr
    AND doktl = wa_plotjob-doktl
    AND dokvr = wa_plotjob-dokvr
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


  o_stempel_wert = labor.



ENDFUNCTION.
