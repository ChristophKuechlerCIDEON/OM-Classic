FUNCTION /cideon/get_distrib_with_edit.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_PREPROCESSOR) TYPE  ZCL_NAME_PREPROZESSOR OPTIONAL
*"  EXPORTING
*"     VALUE(O_ANSWER) TYPE  CHAR1
*"  TABLES
*"      IT_VERTEILER STRUCTURE  /CIDEON/STRING
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
* 13.02.2007 - Kopie
* 10.05.2007 - SP 39
*              Reaktion auf leere Zeilen bei der Eingabe
*-----------------------------------------------------------------------
* toDo
*   - get_text_as_stream überarbeiten...
*-----------------------------------------------------------------------

  CLEAR o_answer.

  CLEAR g_answer.

  it_text[] = it_verteiler[].
  g_preprocessor = i_preprocessor.

  CALL SCREEN 300 STARTING AT 10 10 ENDING AT 104 28.

  o_answer = g_answer.
  IF o_answer = 'X'.
*   leere Zeilen bereinigen
*    LOOP AT it_text INTO wa_text.
*      IF wa_text IS INITIAL.
*        DELETE it_text INDEX sy-tabix.
*      ELSE.
*      ENDIF.
*    ENDLOOP.

*    it_verteiler[] = it_text[].

    DELETE gt_outtab WHERE verteiler IS initial.

    SORT gt_outtab BY verteiler ASCENDING.

  ELSE.
  ENDIF.

ENDFUNCTION.
