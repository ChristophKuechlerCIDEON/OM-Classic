FUNCTION /cideon/get_notes_with_edit.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_ANSWER) TYPE  CHAR1
*"  TABLES
*"      IT_NOTIZ TYPE  /CIDEON/TTYPE_S_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* Info:

*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 03.11.2006 - Erstellung
* 29.11.2006 - Daten als Stream holen
*-----------------------------------------------------------------------
* toDo
*   - get_text_as_stream überarbeiten...
*-----------------------------------------------------------------------

  CLEAR o_answer.

  CLEAR g_answer.

  it_text[] = it_notiz[].

  CALL SCREEN 300 STARTING AT 10 10 ENDING AT 104 28.

  o_answer = g_answer.
  IF o_answer = 'X'.
    it_notiz[] = it_text[].
  ELSE.
  ENDIF.

ENDFUNCTION.
