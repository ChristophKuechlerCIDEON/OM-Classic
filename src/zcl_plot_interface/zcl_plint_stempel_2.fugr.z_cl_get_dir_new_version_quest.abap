FUNCTION z_cl_get_dir_new_version_quest.
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
* 03.01.2005 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_draw TYPE draw.
  DATA: wa_plotjob TYPE zcl_s_plotlist.

  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.


  CLEAR wa_draw.
  SELECT SINGLE * FROM draw INTO wa_draw
    WHERE dokar = wa_plotjob-dokar
    AND doknr = wa_plotjob-doknr
    AND doktl = wa_plotjob-doktl
    AND dokvr > wa_plotjob-dokvr
    .
  IF sy-subrc NE 0.
    o_stempel_wert = ''.
  ELSE.
    o_stempel_wert = text-035.
  ENDIF.


*  o_stempel_wert = '0'.


ENDFUNCTION.
