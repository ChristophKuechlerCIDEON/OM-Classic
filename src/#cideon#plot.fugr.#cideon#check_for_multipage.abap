FUNCTION /cideon/check_for_multipage.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      ITAB_TMP_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
  DATA: wa_plotjobs LIKE zcl_s_plotlist.
*ITAB
  DATA: itab_page_format TYPE TABLE OF zcl_orig_format.
  DATA: itab_tmp_plotjobs_3 TYPE TABLE OF  zcl_s_plotlist.
*WA
  DATA: wa_page_format TYPE zcl_orig_format.

  REFRESH itab_tmp_plotjobs_3.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*   Check for existence
    SELECT SINGLE * FROM zcl_orig_format INTO wa_page_format
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      AND wsapplication = wa_plotjobs-wsapplication
      AND docfile  = wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    IF sy-subrc NE 0.
      APPEND wa_plotjobs TO itab_tmp_plotjobs_3.
      CONTINUE.
    ELSE.
    ENDIF.

    REFRESH itab_page_format.
*   get the intervals
    SELECT * FROM zcl_orig_format INTO TABLE itab_page_format
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      AND wsapplication = wa_plotjobs-wsapplication
      AND docfile  = wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

    LOOP AT itab_page_format INTO wa_page_format.
      wa_plotjobs-knz_multi_page = 'X'.
      wa_plotjobs-seite_von = wa_page_format-pagefrom.
      wa_plotjobs-seite_bis = wa_page_format-pageto.
      wa_plotjobs-format_ausgabe = wa_page_format-pageformat.
      APPEND wa_plotjobs TO itab_tmp_plotjobs_3.
    ENDLOOP.


  ENDLOOP.

  REFRESH itab_tmp_plotjobs.
  LOOP AT itab_tmp_plotjobs_3 INTO wa_plotjobs.
    APPEND wa_plotjobs TO itab_tmp_plotjobs.
  ENDLOOP.

  REFRESH itab_tmp_plotjobs_3.


ENDFUNCTION.
