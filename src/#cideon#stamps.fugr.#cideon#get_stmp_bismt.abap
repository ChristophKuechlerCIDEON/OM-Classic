FUNCTION /cideon/get_stmp_bismt.
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
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 02.10.2006 - Erstellung
* 08.01.2009 - Kopie
*-----------------------------------------------------------------------
* Alte Materialnummer holen
*
*-----------------------------------------------------------------------

  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL
  DATA: labor TYPE draw-labor.

  wa_plotjob = i_wa_plotjobs.

*  call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
*       exporting
*            input  = wa_plotjob-matnr
*       importing
*            output = wa_plotjob-matnr.
*  .

  DATA: ls_mara TYPE mara.
  CLEAR ls_mara.

  SELECT SINGLE * FROM mara INTO ls_mara
    WHERE matnr = wa_plotjob-matnr
    .
  IF sy-subrc NE 0.
    CLEAR o_stempel_wert.
  ELSE.
    o_stempel_wert = ls_mara-bismt.
  ENDIF.

  "o_stempel_wert = wa_plotjob-matnr.


ENDFUNCTION.
