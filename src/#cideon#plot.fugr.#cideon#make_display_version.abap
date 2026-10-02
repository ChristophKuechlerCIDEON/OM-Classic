FUNCTION /cideon/make_display_version.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
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
* 287.2005- Erstellung
* 27.09.2005 - HAENSEL - Fix: Änderung der ITAB_SEARCH bei Dokument-
*                             status mit Freigabekennzeichen in der
*                             falschen Zeile, weil SY-TABIX aus der ITAB
*                             DRAW verwendet wurde.
*-----------------------------------------------------------------------
* Aktualisierung der Ikone für Versionen / CDESK
* DIR_STAT_VERS
* Ampel Ikonen
*
*ICON_4 ICON_GREEN_LIGHT               '@08@'."  Green light; positive
*ICON_4 ICON_YELLOW_LIGHT              '@09@'."  Yellow light; neutral
*ICON_4 ICON_RED_LIGHT                 '@0A@'."  Red light; negative

* keine neuere Version -> Grün
* neuere freigegebene Version -> Rot
* neuere nicht freigegebene Version -> Gelb

  DATA: itab_draw TYPE TABLE OF draw.
  DATA: wa_draw TYPE draw.
  DATA: wa_search TYPE zcl_s_docsearch.

  DATA: lines TYPE i.
  DATA: frknz TYPE tdws-frknz.
  DATA: dosar TYPE tdws-dosar.


  CLEAR wa_search.
  LOOP AT itab_search INTO wa_search.
    CLEAR wa_draw.
    CLEAR itab_draw.
    SELECT * FROM draw INTO TABLE itab_draw
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND doktl = wa_search-doktl
      AND dokvr > wa_search-dokvr
      ORDER BY dokvr.
    IF sy-subrc NE 0.
*     keine neuere -> Grün
      wa_search-dir_stat_vers = icon_green_light.
      MODIFY itab_search FROM wa_search INDEX sy-tabix.
      CONTINUE.
    ELSE.
    ENDIF.

*   Testen auf mehrere Versionen
    CLEAR lines.
    DESCRIBE TABLE itab_draw LINES lines.
    LOOP AT itab_draw INTO wa_draw.
      CLEAR frknz.
      CLEAR dosar.

*     Freigabekennzeichen
      CLEAR frknz.
      SELECT SINGLE frknz FROM tdws
        INTO frknz
        WHERE dokar = wa_draw-dokar
        AND dokst = wa_draw-dokst
        .
      IF sy-subrc NE 0.
        wa_search-dir_stat_vers = icon_red_light.
      ELSE.
        IF frknz = 'X'.
*       ein freigegebenes existiert
          wa_search-dir_stat_vers = icon_red_light.
*         BEGIN HAENSEL 27.09.2005
*         MODIFY itab_search FROM wa_search INDEX sy-tabix.
*         END HAENSEL 27.09.2005
          EXIT.
        ELSE.
*       kein freigegebenes existiert
          wa_search-dir_stat_vers = icon_yellow_light.
        ENDIF.
      ENDIF.
    ENDLOOP.

    MODIFY itab_search FROM wa_search INDEX sy-tabix.

  ENDLOOP.




ENDFUNCTION.
