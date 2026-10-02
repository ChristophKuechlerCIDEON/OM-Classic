FUNCTION /cideon/make_knz_freigabe_led.
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

  LOOP AT itab_search INTO wa_search.
    CALL FUNCTION '/CIDEON/CHECK_STATUS_FREIGABE'
         EXPORTING
              i_dokar  = wa_search-dokar
              i_dokst  = wa_search-dokst
         EXCEPTIONS
              error    = 1
              freigabe = 2
              gesperrt = 3
              normal   = 4
              OTHERS   = 5.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 2.
          wa_search-knz_freigabe = 3.
        WHEN 3.
          wa_search-knz_freigabe = 1.
        WHEN OTHERS.
          wa_search-knz_freigabe = 2.
      ENDCASE.
    ENDIF.

    MODIFY itab_search FROM wa_search INDEX sy-tabix.
  ENDLOOP.




ENDFUNCTION.
