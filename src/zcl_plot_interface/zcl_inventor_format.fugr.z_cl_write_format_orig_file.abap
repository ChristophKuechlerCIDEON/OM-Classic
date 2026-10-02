FUNCTION z_cl_write_format_orig_file.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BAPI_DOC_FILES2) TYPE  BAPI_DOC_FILES2
*"     VALUE(I_COMMIT) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"  TABLES
*"      ITAB_PAGE_FORMAT STRUCTURE  ZCL_ORIG_FORMAT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*ITAB
*WA
  DATA: wa_page_format TYPE zcl_orig_format.
  DATA: wa_page_format2 TYPE zcl_orig_format.
  DATA: p_bapi_message LIKE messages.
*MORMAL
  DATA: zeile TYPE i.

  IF i_commit = 'X'.
    COMMIT WORK.
  ELSE.
  ENDIF.

  CALL FUNCTION 'Z_CL_CHECK_ITEMS'
       EXPORTING
            i_bapi_doc_files2  = i_bapi_doc_files2
       TABLES
            i_itab_page_format = itab_page_format
       EXCEPTIONS
            error              = 1
            inconsistent_data  = 2
            OTHERS             = 3.
  IF sy-subrc <> 0.
    PERFORM fill_bapi_message_from_syst
                CHANGING
                   p_bapi_message.
    PERFORM fill_bapi_return2
                USING
                   0
                   p_bapi_message
                CHANGING
                   return.
    EXIT.
  ENDIF.

  CALL FUNCTION 'Z_CL_WRITE_FORMAT_INS_DB'
       EXPORTING
            i_bapi_doc_files2 = i_bapi_doc_files2
            i_commit          = 'X'
       TABLES
            itab_page_format  = itab_page_format
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    PERFORM fill_bapi_message_from_syst
                CHANGING
                   p_bapi_message.
    PERFORM fill_bapi_return2
                USING
                   0
                   p_bapi_message
                CHANGING
                   return.
    EXIT.
  ENDIF.


  IF i_commit = 'X'.
    COMMIT WORK.
  ELSE.
  ENDIF.


  CALL FUNCTION 'Z_CL_WRITE_FORMAT_SUCCESS'
       EXCEPTIONS
            error  = 1
            ok     = 2
            OTHERS = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      PERFORM fill_bapi_message_from_syst
                  CHANGING
                     p_bapi_message.
      PERFORM fill_bapi_return2
                  USING
                     0
                     p_bapi_message
                  CHANGING
                     return.

    ELSE.
    ENDIF.
  ENDIF.


ENDFUNCTION.
