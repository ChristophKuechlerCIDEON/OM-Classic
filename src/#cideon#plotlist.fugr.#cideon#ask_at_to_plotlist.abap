FUNCTION /cideon/ask_at_to_plotlist.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      LT_FILES STRUCTURE  ZORI_DOC_FILES
*"      LT_FILES_DETAIL STRUCTURE  BAPI_DOC_FILES2
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Auswahl der zu übernehmenden Originale
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 19.09.2007 - Erstellung
* 20.09.2007 - Erweiterung
*-----------------------------------------------------------------------

  f_init = 'X'.


  CLEAR lt_files_internal.
  lt_files_internal[] = lt_files[].

  DATA: lt_files_tmp TYPE TABLE OF zori_doc_files.
  DATA: lt_files_detail_tmp TYPE TABLE OF bapi_doc_files2.
  DATA: lc_files TYPE zori_doc_files.
  DATA: lc_files_detail TYPE bapi_doc_files2.


  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 120 30.

  CASE save_code.
    WHEN 'OK'.
      CLEAR lt_files_tmp.
      CLEAR lt_files_detail_tmp.
      LOOP AT lt_sel_rows INTO lc_sel_rows.
        CLEAR lc_files.
        CLEAR lc_files_detail.
        READ TABLE lt_files INTO lc_files INDEX lc_sel_rows.
        READ TABLE lt_files_detail INTO lc_files_detail
          INDEX lc_sel_rows.
        APPEND lc_files TO lt_files_tmp.
        APPEND lc_files_detail TO lt_files_detail_tmp.
      ENDLOOP.
      lt_files[] = lt_files_tmp[].
      lt_files_detail[] = lt_files_detail_tmp[].
    WHEN 'CANC'.
      REFRESH lt_files.
      REFRESH lt_files_detail.
  ENDCASE.


  PERFORM free_control.

ENDFUNCTION.
