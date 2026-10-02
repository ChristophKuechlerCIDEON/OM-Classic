FUNCTION /cideon/pl_set_file_size.
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
* 16.06.2010 - Kopie
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.

* abgelegte Dateien bevorzugen?
  DATA: index_plotjobs TYPE sy-tabix.
  DATA: lc_file_size TYPE sdok_fsize.


  LOOP AT itab_plotjobs INTO wa_plotjobs.
    index_plotjobs = sy-tabix.
    SELECT SINGLE file_size INTO wa_plotjobs-file_size FROM dms_phf_cd1
      WHERE phio_id = wa_plotjobs-file_id.
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.

    ENDIF.

    MODIFY itab_plotjobs FROM wa_plotjobs INDEX index_plotjobs.
  ENDLOOP.


ENDFUNCTION.
