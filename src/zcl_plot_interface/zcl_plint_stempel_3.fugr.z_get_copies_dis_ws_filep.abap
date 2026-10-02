FUNCTION z_get_copies_dis_ws_filep.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"       EXPORTING
*"             VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 31.01.2005 - Erstellung
*-----------------------------------------------------------------------
*ITAB
  DATA: it_pl_log TYPE TABLE OF /cideon/pl_log.
*WA
  DATA: wa_pl_log TYPE /cideon/pl_log.
*NORMAL
  DATA: kopien TYPE i.
  DATA: feld TYPE i.
  DATA: kopien_c(20).

* Auslesen aus /CIDEON/PL_LOG Anzahl der schon getätigten
* Kopien
  SELECT * FROM /cideon/pl_log INTO TABLE it_pl_log
    WHERE dokar = i_wa_plotjobs-dokar
      AND doknr = i_wa_plotjobs-doknr
      AND doktl = i_wa_plotjobs-doktl
      AND dokvr = i_wa_plotjobs-dokvr
      AND wsapplication = i_wa_plotjobs-wsapplication
      AND filep = i_wa_plotjobs-filep
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CLEAR kopien.
  LOOP AT it_pl_log INTO wa_pl_log.
    CLEAR feld.
    feld = wa_pl_log-kopien.
    kopien = kopien + feld.

  ENDLOOP.

  CLEAR kopien_c.
  kopien_c = kopien.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = kopien_c
       IMPORTING
            output = o_stempel_wert.



ENDFUNCTION.
