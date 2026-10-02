FUNCTION /cideon/get_dok_status.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      ITAB_TMP_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
* 12.07.2004 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
  DATA: wa_search_tmp LIKE zcl_s_docsearch. "draw.


* DOKST, STABK, TXT
  DATA: index_tab TYPE sy-tabix.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    index_tab = sy-tabix.

    LOOP AT itab_search INTO wa_search_tmp
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      .
    ENDLOOP.

    IF sy-subrc NE 0.
    ELSE.
      wa_plotjobs-dokst = wa_search_tmp-dokst.
      wa_plotjobs-stabk = wa_search_tmp-stabk.
      wa_plotjobs-dostx = wa_search_tmp-dostx.
      wa_plotjobs-mstae = wa_search_tmp-mstae.
      wa_plotjobs-mstde = wa_search_tmp-mstde.
      wa_plotjobs-mat_count = wa_search_tmp-mat_count.

      wa_plotjobs-light = wa_search_tmp-knz_freigabe.

      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX index_tab.
    ENDIF.
  ENDLOOP.



ENDFUNCTION.
