FUNCTION z_cl_write_format_ins_db.
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

*  IF i_commit = 'X'.
*    COMMIT WORK.
*  ELSE.
*  ENDIF.

  CLEAR wa_page_format.
  CLEAR wa_page_format2.
  READ TABLE itab_page_format INTO wa_page_format INDEX 1.

  wa_page_format-dokar = i_bapi_doc_files2-documenttype.
  wa_page_format-doknr = i_bapi_doc_files2-documentnumber.
  wa_page_format-dokvr = i_bapi_doc_files2-documentversion.
  wa_page_format-doktl = i_bapi_doc_files2-documentpart.

* check, ob schon etwas vorhanden.
  SELECT SINGLE * FROM zcl_orig_format
    INTO wa_page_format2
      WHERE dokar = wa_page_format-dokar
      AND doknr = wa_page_format-doknr
      AND doktl = wa_page_format-doktl
      AND dokvr = wa_page_format-dokvr
      "and originaltype = wa_page_format-originaltype
      AND wsapplication = wa_page_format-wsapplication
      AND docfile = wa_page_format-docfile

*      wa_page_format-APPLICATION_ID = i_bapi_doc_files2-APPLICATION_ID.
*      wa_page_format-file_ID = i_bapi_doc_files2-file_ID.
    .
  IF sy-subrc NE 0.
*   keine vorhanden -> einfach einfügen
    LOOP AT itab_page_format INTO wa_page_format.
      wa_page_format-dokar = i_bapi_doc_files2-documenttype.
      wa_page_format-doknr = i_bapi_doc_files2-documentnumber.
      wa_page_format-dokvr = i_bapi_doc_files2-documentversion.
      wa_page_format-doktl = i_bapi_doc_files2-documentpart.

      wa_page_format-application_id = i_bapi_doc_files2-application_id.
      wa_page_format-file_id = i_bapi_doc_files2-file_id.

      wa_page_format-zclinsname = sy-uname.
      wa_page_format-zclinsdate = sy-datum.
      wa_page_format-zclinstime = sy-uzeit.
      wa_page_format-zclinsprog = sy-repid.
      wa_page_format-zclupdname = sy-uname.
      wa_page_format-zclupddate = sy-datum.
      wa_page_format-zclupdtime = sy-uzeit.
      wa_page_format-zclupdprog = sy-repid.

      INSERT zcl_orig_format FROM wa_page_format.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
        MESSAGE e103(zcl_plint_tools) WITH
            'zcl_orig_format' sy-tabix
            '' '' RAISING error.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

  ELSE.
*   vorhanden -> Sperren,Löschen, Einfügen
    DELETE FROM zcl_orig_format
      WHERE dokar = wa_page_format-dokar
      AND doknr = wa_page_format-doknr
      AND doktl = wa_page_format-doktl
      AND dokvr = wa_page_format-dokvr
      "and originaltype = wa_page_format-originaltype
      AND wsapplication = wa_page_format-wsapplication
      AND docfile = wa_page_format-docfile

*      wa_page_format-APPLICATION_ID = i_bapi_doc_files2-APPLICATION_ID.
*      wa_page_format-file_ID = i_bapi_doc_files2-file_ID.
      .
    IF sy-subrc NE 0.
*     Message
      ROLLBACK WORK.
      MESSAGE e104(zcl_plint_tools) WITH
          'zcl_orig_format' sy-tabix
          '' '' RAISING error.
    ELSE.
*     Einfügen
      LOOP AT itab_page_format INTO wa_page_format.
        wa_page_format-dokar = i_bapi_doc_files2-documenttype.
        wa_page_format-doknr = i_bapi_doc_files2-documentnumber.
        wa_page_format-dokvr = i_bapi_doc_files2-documentversion.
        wa_page_format-doktl = i_bapi_doc_files2-documentpart.

        wa_page_format-application_id =
          i_bapi_doc_files2-application_id.
        wa_page_format-file_id = i_bapi_doc_files2-file_id.

        wa_page_format-zclinsname = sy-uname.
        wa_page_format-zclinsdate = sy-datum.
        wa_page_format-zclinstime = sy-uzeit.
        wa_page_format-zclinsprog = sy-repid.
        wa_page_format-zclupdname = sy-uname.
        wa_page_format-zclupddate = sy-datum.
        wa_page_format-zclupdtime = sy-uzeit.
        wa_page_format-zclupdprog = sy-repid.

        INSERT zcl_orig_format FROM wa_page_format.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE e103(zcl_plint_tools) WITH
              'zcl_orig_format' sy-tabix
              '' '' RAISING error.
          EXIT.
        ELSE.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.



*  IF i_commit = 'X'.
*    COMMIT WORK.
*  ELSE.
*  ENDIF.

ENDFUNCTION.
