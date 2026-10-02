FUNCTION z_cl_get_right_zcl_plotau.
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
* 31.01.2005 - Erstellung
* 14.03.2005 - Änderung auf
* autorisierte Ausgabe
* Arbeitskopie, vom Aktualisierungsdienst ausgeschlossen!
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
*NORMAL

  CLEAR wa_plotjobs.
  wa_plotjobs = i_wa_plotjobs.


* "Authorisierte Ausgabe"
  AUTHORITY-CHECK OBJECT 'ZCL_PLOTAU'
*               ID 'ZCL_TA' FIELD sy-tcode
           ID 'ACTVT' FIELD '02'
           ID 'DOKAR' FIELD wa_plotjobs-dokar
           ID 'DOKST' FIELD wa_plotjobs-dokst
  .
  IF sy-subrc NE  0.
  ELSE.
    o_stempel_wert = text-070.
    EXIT.
  ENDIF.

* "nicht authorisierte Ausgabe / vom Änderungsdienst
*  ausgeschlossen"
  AUTHORITY-CHECK OBJECT 'ZCL_PLOTAU'
*               ID 'ZCL_TA' FIELD sy-tcode
           ID 'ACTVT' FIELD '03'
           ID 'DOKAR' FIELD wa_plotjobs-dokar
           ID 'DOKST' FIELD wa_plotjobs-dokst
  .
  IF sy-subrc NE  0.
  ELSE.
    o_stempel_wert = text-071.
    EXIT.
  ENDIF.

* "keine Ausgabe"
  AUTHORITY-CHECK OBJECT 'ZCL_PLOTAU'
*               ID 'ZCL_TA' FIELD sy-tcode
           ID 'ACTVT' FIELD '03'
           ID 'DOKAR' FIELD wa_plotjobs-dokar
           ID 'DOKST' FIELD wa_plotjobs-dokst
  .
  IF sy-subrc NE  0.
  ELSE.
  ENDIF.


  o_stempel_wert = text-072.


ENDFUNCTION.
