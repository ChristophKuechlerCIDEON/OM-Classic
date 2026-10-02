*----------------------------------------------------------------------*
*   INCLUDE ZCL_MAINTAIN_PLINT_CFG_00F01                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_for_modifications
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_modifications.

  IF wa_cfg_00-pname NE wa2_cfg_00-pname.
    flag_modifications = 'X'.
  ENDIF.

  IF flag_modifications = 'X'.
    wa_cfg_00-zclinsname = sy-uname.
    wa_cfg_00-zclinsdate = sy-datum.
    wa_cfg_00-zclinstime = sy-uzeit.
    wa_cfg_00-zclinsprog = sy-uname.
    wa_cfg_00-zclupdname = sy-uname.
    wa_cfg_00-zclupddate = sy-datum.
    wa_cfg_00-zclupdtime = sy-uzeit.
    wa_cfg_00-zclupdprog = sy-uname.
  ENDIF.

ENDFORM.                    " check_for_modifications

*&---------------------------------------------------------------------*
*&      Form  check_insupd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_insupd.
  IF wa_cfg_00-zclinsname IS INITIAL.
    wa_cfg_00-zclinsname = sy-uname.
  ENDIF.
  IF wa_cfg_00-zclinsdate IS INITIAL.
    wa_cfg_00-zclinsdate = sy-datum.
  ENDIF.
  IF wa_cfg_00-zclinstime IS INITIAL.
    wa_cfg_00-zclinstime = sy-uzeit.
  ENDIF.
  IF wa_cfg_00-zclinsprog IS INITIAL.
    wa_cfg_00-zclinsprog = sy-uname.
  ENDIF.
  IF wa_cfg_00-zclupdname IS INITIAL.
    wa_cfg_00-zclupdname = sy-uname.
  ELSE.
    wa_cfg_00-zclupdname = sy-uname.
  ENDIF.
  IF wa_cfg_00-zclupddate IS INITIAL.
    wa_cfg_00-zclupddate = sy-datum.
  ELSE.
    wa_cfg_00-zclupddate = sy-datum.
  ENDIF.
  IF wa_cfg_00-zclupdtime IS INITIAL.
    wa_cfg_00-zclupdtime = sy-uzeit.
  ELSE.
    wa_cfg_00-zclupdtime = sy-uzeit.
  ENDIF.
  IF wa_cfg_00-zclupdprog IS INITIAL.
    wa_cfg_00-zclupdprog = sy-uname.
  ELSE.
    wa_cfg_00-zclupdprog = sy-uname.
  ENDIF.
ENDFORM.                    " check_insupd

*&---------------------------------------------------------------------*
*&      Form  copy_the_row_as_diffrent_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_the_row_as_diffrent_row.

  IF wa2_cfg_00 IS INITIAL AND NOT ( wa_cfg_00 IS INITIAL ).
    MOVE wa_cfg_00 TO wa2_cfg_00.
  ELSEIF NOT ( wa_selected_cfg_00 IS INITIAL ).
    MOVE wa_selected_cfg_00 TO wa_cfg_00.
    MOVE wa_selected_cfg_00 TO wa2_cfg_00.
  ELSE.
  ENDIF.

  IF flag_toggle_edit = '0'.
    flag_toggle_edit = '1'.
  ELSE.
  ENDIF.

ENDFORM.                    " copy_the_row_as_diffrent_row
*&---------------------------------------------------------------------*
*&      Form  create_new_table_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_new_table_row.

  CLEAR wa_cfg_00.
  CLEAR wa2_cfg_00.

  flag_toggle_edit = '1'.

ENDFORM.                    " create_new_table_row
*&---------------------------------------------------------------------*
*&      Form  delete_row_from_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_row_from_table.

  IF NOT ( wa_cfg_00 IS INITIAL ).
    DELETE FROM zcl_plint_cfg_00
               WHERE pname          = wa_cfg_00-pname.

  ELSEIF NOT ( wa_selected_cfg_00 IS INITIAL ).
    DELETE FROM zcl_plint_cfg_00
                    WHERE pname          = wa_selected_cfg_00-pname.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE i073(zcl_plint_message_01)
       WITH 'ZCL_PLINT_CFG_00' wa_cfg_00-pname '' ''.
  ELSE.
  ENDIF.

  COMMIT WORK.

  CLEAR wa_cfg_00.

  flag_toggle_edit = '0'.

ENDFORM.                    " delete_row_from_table

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.

  REFRESH itab_cfg_00.

  SELECT * FROM zcl_plint_cfg_00
    INTO TABLE itab_cfg_00
    WHERE
    pname IN s_pname
    AND pwert IN s_wert
    AND pdoku IN s_doku
    AND zclinsname IN sinsname
    AND zclinsdate IN sinsdate
    AND zclinstime IN sinstime
    AND zclinsprog IN sinsprog
    AND zclupdname IN supdname
    AND zclupddate IN supddate
    AND zclupdtime IN supdtime
    AND zclupdprog IN supdprog
    .
  IF sy-subrc NE  0.
  ELSE.
  ENDIF.

ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  get_selected_rows_from_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_rows_from_alv.


  REFRESH lv_index_itab_lvc_t_row.
  CLEAR   lv_index_wa_lvc_s_row.
  CLEAR   lv_index.

  REFRESH itab_selected_cfg_00.
  CLEAR   itab_selected_cfg_00.
  CLEAR   wa_selected_cfg_00.

  CALL METHOD alv->get_selected_rows
    IMPORTING
      et_index_rows = lv_index_itab_lvc_t_row
*     et_row_no     =
            .
  IF NOT ( lv_index_itab_lvc_t_row IS INITIAL ).
    CLEAR wa_cfg_00.
    LOOP AT lv_index_itab_lvc_t_row INTO lv_index_wa_lvc_s_row.
      MOVE lv_index_wa_lvc_s_row-index TO lv_index.
      READ TABLE itab_cfg_00 INDEX lv_index
          INTO wa_selected_cfg_00.

    ENDLOOP.
    MOVE wa_selected_cfg_00 TO wa_cfg_00.
  ENDIF.

ENDFORM.                    " get_selected_rows_from_alv
*&---------------------------------------------------------------------*
*&      Form  modify_table_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_table_row.

  flag_toggle_pname = '0'.

  IF wa2_cfg_00 IS INITIAL AND NOT ( wa_cfg_00 IS INITIAL ).
    MOVE wa_cfg_00 TO wa2_cfg_00.
  ELSEIF NOT ( wa_selected_cfg_00 IS INITIAL ).

    MOVE wa_selected_cfg_00 TO wa2_cfg_00.
    MOVE wa_selected_cfg_00 TO wa_cfg_00.

  ENDIF.

  IF flag_toggle_edit EQ '0'.
    flag_toggle_edit = '1'.
  ELSEIF flag_toggle_edit = '1'.
    flag_toggle_edit = '0'.
  ENDIF.
ENDFORM.                    " modify_table_row

*&---------------------------------------------------------------------*
*&      Form  read_akt_line_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_akt_line_alv.
* get the aktual / selected line in the search list
* check is table is empty
  IF itab_cfg_00 IS INITIAL.
    CLEAR wa_cfg_00.
  ELSE.
    READ TABLE itab_cfg_00 INDEX index_itab_cfg_00 INTO
      wa_cfg_00.
  ENDIF.

ENDFORM.                    " read_akt_line_ALV
*&---------------------------------------------------------------------*
*&      Form  refresh_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_alv.

  CLEAR wa_cfg_00. " Sri.....30.09.2002

  CALL METHOD alv->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  flag_toggle_edit = '0'. " Sri.....30.09.2002

ENDFORM.                    " refresh_alv
*&---------------------------------------------------------------------*
*&      Form  save_to_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_to_db.
* saves actual wa to database
  IF wa_cfg_00 IS INITIAL.
  ELSEIF flag_modifications NE space.
    INSERT INTO zcl_plint_cfg_00 VALUES wa_cfg_00.
  ELSE.
    PERFORM check_insupd.
    MODIFY zcl_plint_cfg_00 FROM wa_cfg_00
      .
    COMMIT WORK.
    IF  sy-subrc NE 0.
      MESSAGE i069(zcl_plint_message_01)
         WITH 'ZCL_PLINT_CFG_00' wa_cfg_00-pname wa_cfg_00-pwert  ''.
    ELSE.
    ENDIF.
  ENDIF.

  CLEAR flag_modifications.
ENDFORM.                    " save_to_db

*&---------------------------------------------------------------------*
*&      Form  save_wa_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_wa_alv.

  IF wa_cfg_00 IS INITIAL.
    EXIT.
  ELSE.
    MODIFY itab_cfg_00 FROM wa_cfg_00
      INDEX index_itab_cfg_00.
  ENDIF.

ENDFORM.                    " save_wa_ALV
