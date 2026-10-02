FUNCTION z_cl_read_zcl_psb_tmp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(NO_DOC) TYPE  C
*"----------------------------------------------------------------------

  DATA: itab_stored_search TYPE TABLE OF zcl_psb_tmp.
  DATA: wa_stored_search TYPE zcl_psb_tmp.
  DATA: lf_line TYPE i.
  DATA: wa_item TYPE zcl_pdm_objects_fa_int.
  DATA: itab_item TYPE TABLE OF zcl_pdm_objects_fa_int.
*WA
  DATA: wa_default_data TYPE /cideon/plot_defaultdata.
  DATA: wa_user_data TYPE /cideon/plot_userdata.
* Einstellungen lesen
  CLEAR wa_user_data.
  CLEAR wa_default_data.

  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = ''
       IMPORTING
            o_default_data = wa_default_data.


  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = wa_default_data
       IMPORTING
            o_user_data    = wa_user_data.

  IF wa_user_data-read_tmp_search = 'X'.
    SELECT * FROM zcl_psb_tmp INTO TABLE itab_stored_search
    WHERE    uname = wa_user_data-uname.

    DESCRIBE TABLE itab_stored_search LINES lf_line.
    IF lf_line = 0.
      no_doc = 'X'.
      MESSAGE s001(/cideon/plot_cs).
    ELSE.
      CLEAR no_doc.

*********************************************************************
*  Wenn automatisches Löschen von Duplikaten gewünscht, dann
*  diese Aktionen freischalten!!

*      SORT  itab_stored_search.
*      DELETE ADJACENT DUPLICATES FROM  itab_stored_search
*          COMPARING dokar doknr doktl dokvr.
*      IF sy-subrc = 0.
*        DELETE FROM zcl_psb_tmp
*          WHERE uname = wa_user_data-uname.
*
*        LOOP AT itab_stored_search INTO wa_stored_search.
*          INSERT zcl_psb_tmp FROM wa_stored_search.
*        ENDLOOP.
*      ENDIF.

    ENDIF.
  ENDIF.

ENDFUNCTION.
