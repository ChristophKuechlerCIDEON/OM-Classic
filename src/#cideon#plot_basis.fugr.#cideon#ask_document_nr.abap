FUNCTION /cideon/ask_document_nr.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_DOKNR) TYPE  DOKNR
*"     VALUE(O_DOKAR) TYPE  DOKAR
*"     VALUE(O_DOKVR) TYPE  DOKVR
*"     VALUE(O_DOKTL) TYPE  DOKTL_D
*"     VALUE(O_AENNR) TYPE  AENNR
*"     VALUE(O_CCDAT) TYPE  CCDAT
*"     VALUE(O_STUFE) TYPE  ZCL_S_DRAW01-STUFE
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
* 02.02.2004  - creation / copy
* 29.01.2005  - Einbindung EXIT / Abbrechen ohne Bildschirmprüfung
* 02.01.2009 - SP 87
*              BUG 5593
*              Übernahme der kompletten Dokumentschlüssel aus der F4
*              Hilfe
* SP119
* 18.02.2010 - Einbau von Stücklistenstufen
*
*-----------------------------------------------------------------------

  CLEAR wa_zcl_s_draw01.

  CLEAR: doknr.
  CLEAR: g_draw_doknr.
  CLEAR: dokar.
  CLEAR: g_draw_dokar.
  CLEAR: doktl.
  CLEAR: g_draw_doktl.
  CLEAR: dokvr.
  CLEAR: g_draw_dokvr.

  CLEAR: aennr.
  CLEAR: g_aennr.
  CLEAR: ccdat.
  CLEAR: g_ccdat.

  clear stufe.
  clear g_stufe.

*  set parameter id 'CV1' field doknr.
*  SET PARAMETER ID 'CV2' FIELD dokar.
*  SET PARAMETER ID 'CV3' FIELD dokvr.
*  SET PARAMETER ID 'CV4' FIELD doktl.


  CALL SCREEN 600 STARTING AT 10 10 ENDING AT 60 17.

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
  o_doktl = g_draw_doktl.
  o_dokvr = g_draw_dokvr.

  o_aennr = g_aennr.
  o_ccdat = g_ccdat.

  o_stufe = g_stufe.

ENDFUNCTION.
