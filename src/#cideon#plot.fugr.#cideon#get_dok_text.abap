FUNCTION /cideon/get_dok_text.
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
* 05.07.2004 - Erstellung
*-----------------------------------------------------------------------
  DATA: wa_search TYPE  zcl_s_docsearch.

* ergänzt Dokumententexte
  DATA: wa_drat TYPE drat.

  LOOP AT itab_search INTO wa_search.
    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM drat INTO wa_drat
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND dokvr = wa_search-dokvr
      AND doktl = wa_search-doktl
      AND langu = sy-langu
      .
    IF sy-subrc NE 0.
    ELSE.
      wa_search-dktxt = wa_drat-dktxt.
      wa_search-dktxt_uc = wa_drat-dktxt_uc.
      MODIFY itab_search FROM wa_search INDEX sy-tabix.
    ENDIF.

  ENDLOOP.



ENDFUNCTION.
