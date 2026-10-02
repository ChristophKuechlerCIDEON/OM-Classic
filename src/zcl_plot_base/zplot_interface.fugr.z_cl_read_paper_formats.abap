FUNCTION z_cl_read_paper_formats.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME OPTIONAL
*"  TABLES
*"      O_ITAB_PAPER_FORMAT STRUCTURE  ZCL_PAPER_FORMAT OPTIONAL
*"----------------------------------------------------------------------

  TABLES : zcl_paper_format.

  SELECT * FROM zcl_paper_format INTO TABLE itab_paper_format.

  LOOP AT itab_paper_format INTO wa_paper_format.

*    DELETE FROM zcl_paper_format WHERE paper_index  =
*    wa_paper_format-paper_index.

  ENDLOOP.

*  COMMIT WORK.
ENDFUNCTION.
