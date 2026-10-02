*----------------------------------------------------------------------*
*   INCLUDE ZCK_CFG_00_ALV_EDIT_FORM                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SHOW_UPDINS_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_updins_info.
  DATA: wa_insupd LIKE zcl_insupd.

  MOVE-CORRESPONDING ZCL_ORIG_FORMAT TO wa_insupd.
  CALL FUNCTION 'Z_CK_SHOW_INS_UPD'
       EXPORTING
            i_insupd_data = wa_insupd.

ENDFORM.                               " SHOW_UPDINS_INFO

*&---------------------------------------------------------------------*
*&      Form  READ_MARKED_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_marked_lines.
  REFRESH it_det.
  REFRESH it_selected_rows.
  max_lines = 0.
  CALL METHOD ref_alv->get_selected_rows
     IMPORTING
       et_index_rows = it_selected_rows.

  LOOP AT it_selected_rows INTO wa_selected_rows.
    READ TABLE it INTO wa
               INDEX wa_selected_rows-index.
    APPEND wa TO it_det.
    max_lines = max_lines + 1.
  ENDLOOP.
  READ TABLE it_det INTO ZCL_ORIG_FORMAT INDEX 1.
  READ TABLE it_det INTO ZCL_ORIG_FORMAT INDEX 1.
*  IF NOT zhy3_order_hd-no_order IS INITIAL AND
*         max_lines = 0.
*    max_lines = 1.
*  ENDIF.
  index = 1.
ENDFORM.                               " READ_MARKED_LINES

*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data.

  PERFORM make_insupd.

* Modify DB
*  MODIFY zcl_plint_cfg_00 FROM zcl_plint_cfg_00.
  MODIFY (tabname) FROM ZCL_ORIG_FORMAT.
  IF sy-subrc NE 0.
    MESSAGE i002(zck_dialog)
      WITH tabname '' '' ''.
  ELSE.
  ENDIF.
* modify internal table
  MODIFY it_det FROM ZCL_ORIG_FORMAT INDEX index.

  PERFORM show_new_data.
  CLEAR wa_save_neccessary.

  LOOP AT it INTO wa
    WHERE
    DOKAR = ZCL_ORIG_FORMAT-dokar
    and DOKNR = ZCL_ORIG_FORMAT-doknr
    and DOKTL = ZCL_ORIG_FORMAT-doktl
    and DOKVR = ZCL_ORIG_FORMAT-dokvr
    and ORIGINALTYPE = ZCL_ORIG_FORMAT-originaltype
    and WSAPPLICATION = ZCL_ORIG_FORMAT-wsapplication
    and DOCFILE = ZCL_ORIG_FORMAT-docfile
    and PAGEFROM = ZCL_ORIG_FORMAT-pagefrom
    and PAGETO = ZCL_ORIG_FORMAT-pageto
    .
    IF sy-subrc NE 0.
    ELSE.
      index = sy-tabix.
      EXIT.
    ENDIF.
  ENDLOOP.


  PERFORM set_marked_line.

ENDFORM.                               " SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.

  SELECT * FROM (tabname)
    UP TO max_sel ROWS BYPASSING BUFFER
    INTO TABLE it
           WHERE
    dokar IN s_dokar
    AND doknr IN s_doknr
    AND doktl IN s_doktl
    AND dokvr IN s_dokvr
    AND originaltype IN s_o_type
    AND wsapplication IN s_wsappl
    AND docfile IN s_d_file
    AND pagefrom IN s_p_from
    AND pageto IN s_p_to

    AND application_id IN s_app_id
    AND file_id IN s_f_id
    AND pageformat IN s_p_form


      AND zclinsname IN sinsname
      AND zclinsdate IN sinsdate
      AND zclinstime IN sinstime
      AND zclinsprog IN sinsprog
      AND zclupdname IN supdname
      AND zclupddate IN supddate
      AND zclupdtime IN supdtime
      AND zclupdprog IN supdprog  .
  .
  IF sy-subrc NE 0.
    PERFORM get_data_count.
    IF count_lines EQ 0.
    ELSE.
      MESSAGE i001(zck_dialog) WITH tabname '' '' ''.
    ENDIF.
  ELSE.
  ENDIF.


ENDFORM.                               " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DELETE_ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_entry.
  DELETE FROM (tabname)
    WHERE
    DOKAR = ZCL_ORIG_FORMAT-dokar
    and DOKNR = ZCL_ORIG_FORMAT-doknr
    and DOKTL = ZCL_ORIG_FORMAT-doktl
    and DOKVR = ZCL_ORIG_FORMAT-dokvr
    and ORIGINALTYPE = ZCL_ORIG_FORMAT-originaltype
    and WSAPPLICATION = ZCL_ORIG_FORMAT-wsapplication
    and DOCFILE = ZCL_ORIG_FORMAT-docfile
    and PAGEFROM = ZCL_ORIG_FORMAT-pagefrom
    and PAGETO = ZCL_ORIG_FORMAT-pageto
    .

  CLEAR ZCL_ORIG_FORMAT.
  wa_edit_mode = co_show_mode.
  PERFORM show_new_data.
ENDFORM.                               " DELETE_ENTRY

*&---------------------------------------------------------------------*
*&      Form  SHOW_NEW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_new_data.
  PERFORM get_data.
  CALL METHOD ref_alv->refresh_table_display.
ENDFORM.                               " SHOW_NEW_DATA

*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_to_confirm.
  IF wa_save_neccessary = 'X' OR NOT sy-datar IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
         EXPORTING
              textline1 = 'Wollen Sie die Bearbeitung beenden?'(001)
              titel     = 'Bearbeitung beenden'(002)
         IMPORTING
              answer    = answer
         EXCEPTIONS
              OTHERS    = 1.
  ELSE.
    answer = 'J'.
  ENDIF.
ENDFORM.                               " POPUP_TO_CONFIRM

*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_field_catalog.

  REFRESH it_field_cat.
*  wa_field_cat-fieldname  = 'TEST_FIELD'.
*  wa_field_cat-coltext    = 'Testspalte'.
*  wa_field_cat-tooltip    = 'Testspalte'.
*  wa_field_cat-seltext    = 'Testspalte'.
*  wa_field_cat-just       = 'C'.
*  wa_field_cat-outputlen  = 30.
*  wa_field_cat-intlen     = 10.
*  wa_field_cat-inttype    = 'I'.
*  wa_field_cat-col_pos    = 3.
*  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSNAME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSDATE'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSTIME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLINSPROG'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDNAME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDDATE'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDTIME'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'ZCLUPDPROG'.
  wa_field_cat-no_out  = 'X'.
  APPEND wa_field_cat TO it_field_cat.

ENDFORM.                               " SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  make_INSUPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_insupd.
*  FIELD-SYMBOLS <wa> TYPE ty_. "ZCL_PLINT_CFG_00.


  ASSIGN ZCL_ORIG_FORMAT TO <wa> .

*  <wa> = ZCL_PLINT_CFG_00.

  IF <wa>-zclinsname IS INITIAL.
    <wa>-zclinsname = sy-uname.
    <wa>-zclinsdate = sy-datum.
    <wa>-zclinstime = sy-uzeit.
    <wa>-zclinsprog = sy-repid.
    <wa>-zclupdname = sy-uname.
    <wa>-zclupddate = sy-datum.
    <wa>-zclupdtime = sy-uzeit.
    <wa>-zclupdprog = sy-repid.
  ELSE.
    <wa>-zclupdname = sy-uname.
    <wa>-zclupddate = sy-datum.
    <wa>-zclupdtime = sy-uzeit.
    <wa>-zclupdprog = sy-repid.
  ENDIF.

ENDFORM.                    " make_INSUPD
*&---------------------------------------------------------------------*
*&      Form  get_data_count
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_count.

  CLEAR count_lines.

  SELECT COUNT( * ) FROM (tabname)
    INTO count_lines
    WHERE
    dokar IN s_dokar
    AND doknr IN s_doknr
    AND doktl IN s_doktl
    AND dokvr IN s_dokvr
    AND originaltype IN s_o_type
    AND wsapplication IN s_wsappl
    AND docfile IN s_d_file
    AND pagefrom IN s_p_from
    AND pageto IN s_p_to

    AND application_id IN s_app_id
    AND file_id IN s_f_id
    AND pageformat IN s_p_form

      AND zclinsname IN sinsname
      AND zclinsdate IN sinsdate
      AND zclinstime IN sinstime
      AND zclinsprog IN sinsprog
      AND zclupdname IN supdname
      AND zclupddate IN supddate
      AND zclupdtime IN supdtime
      AND zclupdprog IN supdprog  .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
ENDFORM.                    " get_data_count
*&---------------------------------------------------------------------*
*&      Form  set_marked_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_marked_line.

  REFRESH it_selected_rows.
  CLEAR wa_selected_rows.

  wa_selected_rows-index = index.
  APPEND wa_selected_rows TO it_selected_rows.

  CALL METHOD ref_alv->set_selected_rows
    EXPORTING
      it_index_rows = it_selected_rows
*      IT_ROW_NO     =
      .


ENDFORM.                    " set_marked_line
