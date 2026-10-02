FUNCTION /cideon/get_matnr.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
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
* 10.05.2005 - MATNR, nur überschreiben, falls nicht schon vor
*              gefüllt
*-----------------------------------------------------------------------
  DATA: wa_search TYPE  zcl_s_docsearch.

* get the material and the status
  DATA: wa_drad TYPE drad.
  DATA: mat_count TYPE i.

  IF i_wa_user_data-knz_get_material IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_search INTO wa_search.
    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    CLEAR wa_drad.
    SELECT SINGLE  * FROM drad INTO wa_drad
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND dokvr = wa_search-dokvr
      AND doktl = wa_search-doktl
      AND dokob = 'MARA'
      .
    IF sy-subrc NE 0.
    ELSE.
      CLEAR mat_count.
      mat_count = 1.
      SELECT COUNT( * ) FROM drad INTO mat_count
        WHERE dokar = wa_search-dokar
        AND doknr = wa_search-doknr
        AND dokvr = wa_search-dokvr
        AND doktl = wa_search-doktl
        AND dokob = 'MARA'
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
      wa_search-mat_count = mat_count.

      IF wa_search-matnr IS INITIAL.
        wa_search-matnr = wa_drad-objky.
      ELSE.
      ENDIF.

      SELECT SINGLE mstae mstde  FROM mara
        INTO (wa_search-mstae, wa_search-mstde )
        WHERE matnr = wa_search-matnr.
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      MODIFY itab_search FROM wa_search INDEX sy-tabix.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
