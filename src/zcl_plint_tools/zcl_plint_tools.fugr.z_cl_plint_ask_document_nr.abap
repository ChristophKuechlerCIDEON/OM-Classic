FUNCTION z_cl_plint_ask_document_nr.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_DOKNR) TYPE  DOKNR
*"     VALUE(O_DOKAR) TYPE  DOKAR
*"     VALUE(O_DOKVR) TYPE  DOKVR
*"     VALUE(O_DOKTL) TYPE  DOKTL_D
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
* 02.08.2002 creation
* 26.04.2005 - Anordnung der Schaltflächen
* 06.08.2007 - Aufruf der Dokumentesuche für Dokumenten
*              auswahl
* 02.01.2009 - SP 87
*              BUG 5593
*              Übernahme der kompletten Dokumentschlüssel aus der F4
*              Hilfe
*-----------------------------------------------------------------------

  CLEAR: doknr.
  CLEAR: g_draw_doknr.
  CLEAR: dokar.
  CLEAR: g_draw_dokar.
  CLEAR: dokvr.
  CLEAR: g_draw_dokvr.
  CLEAR: doktl.
  CLEAR: g_draw_doktl.

*  SET PARAMETER ID 'CV1' FIELD doknr.
*  SET PARAMETER ID 'CV2' FIELD dokar.
*  SET PARAMETER ID 'CV3' FIELD dokvr.
*  SET PARAMETER ID 'CV4' FIELD doktl.


  CALL SCREEN 600 STARTING AT 10 10 ENDING AT 60 15.

  IF g_draw_doknr IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.
  IF g_draw_dokar IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.
  IF g_draw_dokvr IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.
  IF g_draw_doktl IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.


  o_doknr = g_draw_doknr.
  o_dokar = g_draw_dokar.
  o_dokvr = g_draw_dokvr.
  o_doktl = g_draw_doktl.

ENDFUNCTION.
