FUNCTION /cideon/set_knz_use_checked_in.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
* 16.07.2004 - Erstellung
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.

* abgelegte Dateien bevorzugen?
  DATA: index_plotjobs TYPE sy-tabix.

  IF i_wa_user_data-knz_use_checked_in = 'X'.
    LOOP AT itab_plotjobs INTO wa_plotjobs.
      index_plotjobs = sy-tabix.
*     Testen ob abgelegte Version benutzt werden kann
      IF wa_plotjobs-checked IS INITIAL.
        IF wa_plotjobs-storagecategory IS INITIAL.
          CLEAR wa_plotjobs-knz_use_checked_in.
        ELSE.
          wa_plotjobs-knz_use_checked_in = 'X'.
          CLEAR wa_plotjobs-knz_fehl_blatt.
*          wa_plotjobs-light = '3'.
          CLEAR wa_plotjobs-icon_fehlblatt.
        ENDIF.
      ELSE.
        wa_plotjobs-knz_use_checked_in = 'X'.
      ENDIF.
      MODIFY itab_plotjobs FROM wa_plotjobs INDEX index_plotjobs.
    ENDLOOP.
  ELSE.
    LOOP AT itab_plotjobs INTO wa_plotjobs.
      index_plotjobs = sy-tabix.
      IF wa_plotjobs-checked IS INITIAL.
        CLEAR wa_plotjobs-knz_use_checked_in.
      ELSE.
        wa_plotjobs-knz_use_checked_in = 'X'.
      ENDIF.
      MODIFY itab_plotjobs FROM wa_plotjobs INDEX index_plotjobs.
    ENDLOOP.
  ENDIF.


ENDFUNCTION.
