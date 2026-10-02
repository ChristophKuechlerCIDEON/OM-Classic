FUNCTION /cideon/check_status_freigabe.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOKAR) TYPE  DRAW-DOKAR
*"     VALUE(I_DOKST) TYPE  DRAW-DOKST
*"  EXCEPTIONS
*"      ERROR
*"      FREIGABE
*"      GESPERRT
*"      NORMAL
*"----------------------------------------------------------------------
*&     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 29.01.2004 - Erstellung
* 06.07.2006 - Berücksichtigung von SPOOL Dokumenten SPZ
*-----------------------------------------------------------------------
* ITAB
* WA
* NORAL
  DATA: frknz TYPE tdws-frknz.
  DATA: dosar TYPE tdws-dosar.

* Berücksichtigung von SPOOL Dokumenten SPZ
  IF i_dokar = 'SPZ'.
    RAISE freigabe.
  ELSE.
  ENDIF.


* Freigabekennzeichen
  CLEAR frknz.
  SELECT SINGLE frknz FROM tdws
    INTO frknz
    WHERE dokar = i_dokar
    AND dokst = i_dokst
    .
  IF sy-subrc NE 0.
    RAISE error.
  ELSE.
  ENDIF.

  IF frknz = 'X'.
    RAISE freigabe.
  ELSE.
  ENDIF.


* Sperrstatus
  CLEAR dosar.
  SELECT SINGLE dosar FROM tdws
    INTO dosar
    WHERE dokar = i_dokar
    AND dokst = i_dokst
    .
  IF sy-subrc NE 0.
    RAISE error.
  ELSE.
  ENDIF.

  IF dosar = 'S'.
    RAISE gesperrt.
  ELSE.
  ENDIF.


* nichts anderes passiert dann ein Status dazwischen
  RAISE normal.

ENDFUNCTION.
