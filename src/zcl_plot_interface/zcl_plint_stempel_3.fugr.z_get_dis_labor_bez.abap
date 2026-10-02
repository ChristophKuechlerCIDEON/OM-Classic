FUNCTION z_get_dis_labor_bez.
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
  DATA:labor_bez TYPE t024x-lbtxt.

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


  CLEAR labor_bez.
  SELECT SINGLE lbtxt FROM t024x
    INTO labor_bez
    WHERE spras = sy-langu
    AND labor = labor

    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.



  o_stempel_wert = labor_bez.



ENDFUNCTION.
