FUNCTION /cideon/chg_interval_mltpage .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"     VALUE(I_SEITE_VON) TYPE  ZCL_S_PLOTLIST-SEITE_VON
*"     VALUE(I_SEITE_BIS) TYPE  ZCL_S_PLOTLIST-SEITE_BIS
*"  TABLES
*"      IO_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   - setzt Eigenschaften, wie Seitenzahlen / Intervalle bei Multipage
*     Dokumenten, falls erforderlich
*-----------------------------------------------------------------------
* Journal
* 19.06.2003 Multipage
*
* SP 115
* 08.01.2010 - freie Intervalle
*
*-----------------------------------------------------------------------

* ITAB
  DATA: itab_plotjobs TYPE TABLE OF zcl_s_plotlist.
* WA
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
  DATA: wa_plotjobs_first TYPE zcl_s_plotlist.
  DATA: wa_plotjobs_last TYPE zcl_s_plotlist.
  DATA: wa_plotjobs_next TYPE zcl_s_plotlist.
* NORMAL
  DATA: anzahl_eintraege TYPE i.
  DATA: index_1 TYPE i.
  DATA: index_2 TYPE i.
  DATA: seite_von TYPE i.
  DATA: seite_bis TYPE i.


  REFRESH itab_plotjobs.
  CLEAR wa_plotjobs.

  itab_plotjobs[] = io_itab_plotjobs[].

  seite_von = i_seite_von.
  seite_bis = i_seite_bis.


* Vorbereitungen / Fehler ausschließen
* falls Startseite gefüllt und Endseite leer, dann
* Startseite = Endseite
  IF ( NOT i_seite_von IS INITIAL )
    AND i_seite_bis IS INITIAL.
    i_seite_bis = i_seite_von.
  ELSE.
  ENDIF.

* falls Startseite leer und Endseite gefüllt, dann
* Startseite = 1
  IF (  i_seite_von IS INITIAL )
    AND ( NOT i_seite_bis IS INITIAL ).
    i_seite_von = 1.
  ELSE.
  ENDIF.

* alles Drucken
* falls Start und Endseite leer, dann alles drucken
  IF i_seite_von IS INITIAL
    AND i_seite_bis IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  DESCRIBE TABLE itab_plotjobs LINES anzahl_eintraege.

* auf Vergleiche achten!!! Probleme mit CHAR-Vergleichen
* auf Zuweisungen achten!!! Probleme mit Zuweisung INT nach CHAR

* eine Seite Drucken
  IF seite_von = seite_bis .
    IF anzahl_eintraege = 1.
*     ein Eintrag
      READ TABLE itab_plotjobs INTO wa_plotjobs INDEX 1.
      wa_plotjobs-seite_von = seite_von.
      wa_plotjobs-seite_bis = seite_bis.

      io_itab_plotjobs[] = itab_plotjobs[].
      EXIT.
    ELSE.
*     mehrere Seiten -> richtiges Intervall finden
*     ein Eintrag muß passen...
*     Test, ob Seiteninvall überhaupt möglich
      READ TABLE itab_plotjobs INTO wa_plotjobs_first INDEX 1.
      READ TABLE itab_plotjobs INTO wa_plotjobs_last
        INDEX anzahl_eintraege.

      IF ( seite_von >= wa_plotjobs_first-seite_von )
        AND ( seite_bis <= wa_plotjobs_last-seite_bis )
        .
*       im Intervall enthalten
*       Finden der richtigen Intervalle
*       Intervallgrenzen von Oben nach Unten bereinigen 1 - max
        LOOP AT itab_plotjobs INTO wa_plotjobs.
          index_1 = sy-tabix.
          index_2 = index_1 + 1.
          IF index_2 > anzahl_eintraege.
            CONTINUE.
          ELSE.
          ENDIF.

          READ TABLE itab_plotjobs INTO wa_plotjobs_next INDEX index_2.

          IF seite_von > wa_plotjobs-seite_bis.
            DELETE itab_plotjobs INDEX index_1.
            DESCRIBE TABLE itab_plotjobs LINES anzahl_eintraege.
            CONTINUE.
          ELSE.
          ENDIF.
        ENDLOOP.

*       Spezialfall nur eine Seite drucken
        READ TABLE itab_plotjobs INTO wa_plotjobs INDEX 1.
        REFRESH itab_plotjobs.
        CLEAR itab_plotjobs.
*       Seitenzahlen anpassen
        wa_plotjobs-seite_von = i_seite_von.
        wa_plotjobs-seite_bis = i_seite_bis.

        APPEND wa_plotjobs TO itab_plotjobs.

      ELSE.
*       nicht im Intervall enthalten
        MESSAGE i100(/cideon/druck_basis) WITH
          '' '' '' ''.
      ENDIF.
    ENDIF.
  ELSE.
*   mehrere Seiten
    IF anzahl_eintraege = 1.
*     ein Eintrag
      READ TABLE itab_plotjobs INTO wa_plotjobs INDEX 1.
      wa_plotjobs-seite_von = i_seite_von.
      wa_plotjobs-seite_bis = i_seite_bis.

      io_itab_plotjobs[] = itab_plotjobs[].
      EXIT.
    ELSE.
*     mehrere Seiten -> richtiges Intervall finden
*     ein Eintrag muß passen...
*     Test, ob Seiteninvall überhaupt möglich
      READ TABLE itab_plotjobs INTO wa_plotjobs_first INDEX 1.
      READ TABLE itab_plotjobs INTO wa_plotjobs_last
        INDEX anzahl_eintraege.

      IF  seite_von >= wa_plotjobs_first-seite_von
        AND seite_bis <= wa_plotjobs_last-seite_bis.
*       im Intervall enthalten
*       Finden der richtigen Intervalle
*       Intervallgrenzen von Oben nach Unten bereinigen 1 - max
        LOOP AT itab_plotjobs INTO wa_plotjobs.
          index_1 = sy-tabix.
*          index_2 = index_1 + 1.
*          IF index_2 > anzahl_eintraege.
*            CONTINUE.
*          ELSE.
*          ENDIF.
*
*          READ TABLE itab_plotjobs INTO wa_plotjobs_next INDEX index_2.

          IF seite_von > wa_plotjobs-seite_bis.
            DELETE itab_plotjobs INDEX index_1.
            DESCRIBE TABLE itab_plotjobs LINES anzahl_eintraege.
            CONTINUE.
          ELSE.
          ENDIF.
        ENDLOOP.

*       den Rest bereinigen
        LOOP AT itab_plotjobs INTO wa_plotjobs.
          index_1 = sy-tabix.

          IF seite_bis < wa_plotjobs-seite_von.
            DELETE itab_plotjobs INDEX index_1.
            DESCRIBE TABLE itab_plotjobs LINES anzahl_eintraege.
            CONTINUE.
          ELSE.
          ENDIF.
        ENDLOOP.

      ELSE.
*       nicht im Intervall enthalten
        MESSAGE i100(/cideon/druck_basis) WITH
          '' '' '' ''.
      ENDIF.
    ENDIF.

  ENDIF.  "Ende

* Intervall Drucken




* Rückgabe
  io_itab_plotjobs[] = itab_plotjobs[].


ENDFUNCTION.
