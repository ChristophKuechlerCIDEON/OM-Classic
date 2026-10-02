FUNCTION Z_CL_ASK_FAIL_DOCUMENTS_NEW.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      I_ITAB_ZORI_DOC_FILES STRUCTURE  ZORI_DOC_FILES OPTIONAL
*"      I_ITAB_ZORI_DOC_FILES_DETAIL STRUCTURE  BAPI_DOC_FILES2
*"       OPTIONAL
*"      O_ITAB_ZORI_DOC_FILES STRUCTURE  ZORI_DOC_FILES OPTIONAL
*"      O_ITAB_ZORI_DOC_FILES_DETAIL STRUCTURE  BAPI_DOC_FILES2
*"       OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 28.08.2002 Erstellung
*-----------------------------------------------------------------------
*
* Fragt nach einer erneuten Übernahme nach den Dokumenten
*----------------------------------------------------------------------

*  include ZCL_PLINT_TOOL_CLASSES.

  g_first = 'X'.

  REFRESH itab_zori_doc_files_alv.
  refresh itab_tmp_zori_doc_files.
  refresh itab_tmp_zori_doc_files_detail.

  itab_zori_doc_files_alv[] = i_itab_zori_doc_files[].
  itab_zori_doc_files_detail[] = i_itab_zori_doc_files_detail[].

  CALL SCREEN 800 STARTING AT 10 10 ENDING AT 80 20.

  o_itab_zori_doc_files[] = itab_tmp_zori_doc_files[].
  o_itab_zori_doc_files_detail[] =
    itab_tmp_zori_doc_files_detail[].

ENDFUNCTION.
