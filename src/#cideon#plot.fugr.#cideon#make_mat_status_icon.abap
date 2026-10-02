FUNCTION /cideon/make_mat_status_icon.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      ITAB_SEARCH STRUCTURE  ZCL_S_DOCSEARCH
*"      ITAB_MAT_STATUS_EXC STRUCTURE  ZCL_S_MSTAE
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
*WA
  DATA: wa_search TYPE  zcl_s_docsearch.
  DATA: wa_mat_status_exc TYPE  zcl_s_mstae.

* updates the Icon in the searchlist for Material Status
  DATA: index_search TYPE sy-tabix.
  DATA: f_found.

  LOOP AT itab_search INTO wa_search.
    index_search = sy-tabix.
    IF wa_search-matnr IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

    IF wa_search-mstde <= sy-datum.
    ELSE.
      CONTINUE.
    ENDIF.

    CLEAR f_found.
    LOOP AT itab_mat_status_exc INTO wa_mat_status_exc.
      IF wa_mat_status_exc = wa_search-mstae.
        wa_search-mat_status = i_wa_user_data-mat_status_icon.
        "03/05/0A/0W/BA
        f_found = 'X'.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    IF f_found IS INITIAL.
    ELSE.
      MODIFY itab_search FROM wa_search INDEX index_search.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
