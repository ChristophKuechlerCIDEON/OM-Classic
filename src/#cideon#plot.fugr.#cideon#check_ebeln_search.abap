FUNCTION /cideon/check_ebeln_search.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"  TABLES
*"      ITAB_SEARCH STRUCTURE  ZCL_S_DOCSEARCH
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 10.05.2005 - Erstellung
* 03.08.2007 - Anpassung für Vorselektion bei Lieferantenupdate
*-----------------------------------------------------------------------
* bei Übernahme aus BANF, Bestellung etc. erfolgt Abfrage, ob bereinigt
* werden soll.
* Dokumente wurden mglw. schon an Lieferanten gesendet
* falls keine LIFNR gepflegt wurde, dann auch keinen Test durchführen,
* um nicht andere Anbindungen zu stören
*-----------------------------------------------------------------------

* try to read stored search entries
*ITAB
*WA
  DATA: wa_search LIKE itab_search.
  DATA: wa_pl_log TYPE /cideon/pl_log.
*NORMAL
  DATA: index TYPE i.

  IF i_wa_user_data-knz_check_ebeln = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  CASE i_wa_user_data-check_ebeln_strategy.
    WHEN 'I'.
*     Ignore
      EXIT.
    WHEN 'S'.
    WHEN 'D'.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  LOOP AT itab_search INTO wa_search.
*   nur relevante Einträge benutzen
    IF wa_search-lifnr IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

    index = sy-tabix.
    CLEAR wa_pl_log.
    SELECT SINGLE * FROM /cideon/pl_log
      INTO wa_pl_log
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND doktl = wa_search-doktl
      AND dokvr = wa_search-dokvr
      AND lifnr = wa_search-lifnr
      .
    IF sy-subrc NE 0.
    ELSE.
      CASE i_wa_user_data-check_ebeln_strategy.
        WHEN 'S'.
*         Tabelle für Selection füllen
          wa_search-sel_from_ebeln = 'X'.

          wa_search-knz_marked_ebeln = 'X'.

          MODIFY itab_search FROM wa_search INDEX index.
*         Meldung schreiben
          MESSAGE s016(/cideon/plot_basis).
        WHEN 'D'.
*         Löschen
          DELETE itab_search INDEX index.
*         Meldung schreiben
          MESSAGE s015(/cideon/plot_basis).
      ENDCASE.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
