FUNCTION /cideon/make_display_icon.
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

* updates the DISPLAY_ICON in the searchlist
  LOOP AT itab_search INTO wa_search.
    wa_search-icon_display = icon_doc_item_detail.

    wa_search-icon_display_dis = icon_doc_header_detail.

    MODIFY itab_search FROM wa_search INDEX sy-tabix.
  ENDLOOP.

ENDFUNCTION.
