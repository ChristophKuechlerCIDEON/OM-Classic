FUNCTION z_get_mat_revision_level.
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
* 26.07.2005 - Erstellung
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL

  wa_plotjob = i_wa_plotjobs.

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*       EXPORTING
*            input  = wa_plotjob-doknr
*       IMPORTING
*            output = wa_plotjob-doknr.
*

* Tabelle AEOI abfragen
  DATA: wa_aeoi TYPE aeoi.
  CLEAR wa_aeoi.
  SELECT * FROM aeoi INTO
    wa_aeoi
    WHERE aetyp = '41'
    AND objkt = wa_plotjob-matnr
    ORDER BY revlv.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR wa_aeoi.
  ELSE.
  ENDIF.

  o_stempel_wert = wa_aeoi-revlv.

ENDFUNCTION.
