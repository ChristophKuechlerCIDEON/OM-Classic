FUNCTION z_cl_check_items.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BAPI_DOC_FILES2) TYPE  BAPI_DOC_FILES2
*"  TABLES
*"      I_ITAB_PAGE_FORMAT STRUCTURE  ZCL_ORIG_FORMAT
*"  EXCEPTIONS
*"      ERROR
*"      INCONSISTENT_DATA
*"----------------------------------------------------------------------

*ITAB
*WA
  DATA: wa_page_format TYPE zcl_orig_format.
  DATA: wa_page_format2 TYPE zcl_orig_format.
*NORMAL
  DATA: last TYPE i.
  DATA: check TYPE i.


  IF i_itab_page_format[] IS INITIAL.
    MESSAGE e100(zcl_plint_tools) WITH
        'ITAB_PAGE_FORMAT' 'Z_CL_WRITE_FORMAT_ORIG_FILE'
        '' '' raising error.
    EXIT.
  ELSE.
  ENDIF.



  READ TABLE i_itab_page_format INTO wa_page_format INDEX 1.
  IF sy-subrc NE 0.
      MESSAGE e102(zcl_plint_tools) WITH
        'ITAB_PAGE_FORMAT' '1'
        '' ''  RAISING inconsistent_data.
  ELSE.
    IF wa_page_format-pagefrom <> '1'.
      MESSAGE e102(zcl_plint_tools) WITH
        'ITAB_PAGE_FORMAT' sy-tabix
        '' text-001  RAISING inconsistent_data.
    ELSE.
    ENDIF.
  ENDIF.

  last = 0.
  LOOP AT i_itab_page_format INTO wa_page_format.
    IF wa_page_format-pagefrom > wa_page_format-pageto.
      MESSAGE e102(zcl_plint_tools) WITH
        'ITAB_PAGE_FORMAT' sy-tabix
        '' text-002  RAISING inconsistent_data.
    ELSE.
    ENDIF.
    IF wa_page_format-pageformat IS INITIAL.
      MESSAGE e102(zcl_plint_tools) WITH
        'ITAB_PAGE_FORMAT' sy-tabix
        '' text-003  RAISING inconsistent_data.
    ELSE.
    ENDIF.

    check = wa_page_format-pagefrom - last .
    IF check <> 1.
      MESSAGE e102(zcl_plint_tools) WITH
        'ITAB_PAGE_FORMAT' sy-tabix
        '' text-004  RAISING inconsistent_data.
    ELSE.
    ENDIF.
    last = wa_page_format-pageto.
  ENDLOOP.


ENDFUNCTION.
