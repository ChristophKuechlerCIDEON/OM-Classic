FUNCTION z_get_madaus_99.
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
* 01.02.2005 - Erstellung
*              Dokument ungültig Status 99
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_signs_dms_tab TYPE TABLE OF rc77b.
  DATA: it_statuslog TYPE TABLE OF bapi_doc_drap.
*WA
  DATA: wa_draw TYPE draw.
  DATA: wa_plotjob TYPE zcl_s_plotlist.

  DATA: wa_statuslog TYPE bapi_doc_drap.
  DATA: return TYPE bapiret2.
  DATA: wa_tdwst TYPE tdwst.
*NORMAL
  DATA: f_found.
  DATA: index TYPE i.
  DATA: index_found_80 TYPE i.
  DATA: f_found_35.
  DATA: datum(10).


  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  IF wa_plotjob-dokst = '99'.
  ELSE.
    CLEAR o_stempel_wert.
    EXIT.
  ENDIF.

* Dokumentenstatustext lesen
  SELECT SINGLE * FROM tdwst
    INTO wa_tdwst
    WHERE cvlang = sy-langu
    AND dokst = wa_plotjob-dokst
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


  o_stempel_wert = wa_tdwst-dostx.



ENDFUNCTION.
