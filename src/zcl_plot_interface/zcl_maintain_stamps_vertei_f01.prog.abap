*----------------------------------------------------------------------*
*   INCLUDE ZCL_MAINTAIN_PLINT_CFG_00F01                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.

  REFRESH itab_stamp_vertei.

  SELECT * FROM zcl_stamp_vertei
    INTO TABLE itab_stamp_vertei
    WHERE
        verteiler      IN s_sverte
    AND stempel_name   IN s_sname
    AND fm_name        IN s_fmname
    AND status         IN s_status
    AND zclinsname     IN sinsname
    AND zclinsdate     IN sinsdate
    AND zclinstime     IN sinstime
    AND zclinsprog     IN sinsprog
    AND zclupdname     IN supdname
    AND zclupddate     IN supddate
    AND zclupdtime     IN supdtime
    AND zclupdprog     IN supdprog
    .
  IF sy-subrc NE  0.
  ELSE.
  ENDIF.

ENDFORM.                    " get_data
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
  IF ok_code = 'COPY'.
    READ TABLE itab_stamp_vertei
              INDEX lv_index INTO wa_stamp_vertei.
  ELSE.
    IF itab_stamp_vertei IS INITIAL.
      CLEAR wa_stamp_vertei.
    ELSE.
     READ TABLE itab_stamp_vertei INDEX lv_index_itab_stamp_vertei INTO
                     wa_stamp_vertei.
    ENDIF.
  ENDIF.

ENDFORM.                    " read_akt_line_ALV
*&---------------------------------------------------------------------*
*&      Form  save_wa_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_wa_alv.

*  Sri...Modified
  IF lv_index_itab_stamp_vertei EQ 0.
    lv_index_itab_stamp_vertei = 1.
  ENDIF.

* Saves the WA
  IF wa_stamp_vertei IS INITIAL.
    EXIT.
  ELSE.
    MODIFY itab_stamp_vertei FROM wa_stamp_vertei
      INDEX lv_index_itab_stamp_vertei.
  ENDIF.


ENDFORM.                    " save_wa_ALV
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


  IF wa_stamp_vertei IS INITIAL.
  ELSEIF lv_flag_modifications NE space.
    INSERT INTO zcl_stamp_vertei VALUES wa_stamp_vertei.
  ELSE.
    PERFORM check_insupd.
    MODIFY zcl_stamp_vertei FROM wa_stamp_vertei.

    COMMIT WORK. " Sri.....am Montag,30.09.2002.
    IF  sy-subrc NE 0.
      MESSAGE i069(zcl_plint_message_01)
         WITH 'ZCL_MAINTAIN_STAMP_vertei'
                   wa_stamp_vertei-stempel_name
                                wa_stamp_vertei-fm_name  ''.
    ELSE.
    ENDIF.
  ENDIF.

  CLEAR lv_flag_modifications.

ENDFORM.                    " save_to_db
*&---------------------------------------------------------------------*
*&      Form  refresh_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_alv.

  CLEAR wa_stamp_vertei. " Sri.....30.09.2002

  CALL METHOD obj_alv_grid->refresh_table_display
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

  lv_flag_toggle_edit = '0'. " Sri.....30.09.2002

ENDFORM.                    " refresh_alv
*&---------------------------------------------------------------------*
*&      Form  check_insupd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_insupd.
  IF wa_stamp_vertei-zclinsname IS INITIAL.
    wa_stamp_vertei-zclinsname = sy-uname.
  ENDIF.
  IF wa_stamp_vertei-zclinsdate IS INITIAL.
    wa_stamp_vertei-zclinsdate = sy-datum.
  ENDIF.
  IF wa_stamp_vertei-zclinstime IS INITIAL.
    wa_stamp_vertei-zclinstime = sy-uzeit.
  ENDIF.
  IF wa_stamp_vertei-zclinsprog IS INITIAL.
    wa_stamp_vertei-zclinsprog = sy-uname.
  ENDIF.
  IF wa_stamp_vertei-zclupdname IS INITIAL.
    wa_stamp_vertei-zclupdname = sy-uname.
  ELSE.
    wa_stamp_vertei-zclupdname = sy-uname.
  ENDIF.
  IF wa_stamp_vertei-zclupddate IS INITIAL.
    wa_stamp_vertei-zclupddate = sy-datum.
  ELSE.
    wa_stamp_vertei-zclupddate = sy-datum.
  ENDIF.
  IF wa_stamp_vertei-zclupdtime IS INITIAL.
    wa_stamp_vertei-zclupdtime = sy-uzeit.
  ELSE.
    wa_stamp_vertei-zclupdtime = sy-uzeit.
  ENDIF.
  IF wa_stamp_vertei-zclupdprog IS INITIAL.
    wa_stamp_vertei-zclupdprog = sy-uname.
  ELSE.
    wa_stamp_vertei-zclupdprog = sy-uname.
  ENDIF.
ENDFORM.                    " check_insupd

*&---------------------------------------------------------------------*
*&      Form  create_new_table_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_new_table_row.
  CLEAR wa_stamp_vertei.
  lv_flag_toggle_edit = '1'.
ENDFORM.                    " create_new_table_row

*&---------------------------------------------------------------------*
*&      Form  modify_table_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_table_row.

  lv_flag_toggle_sname = '0'.

  IF wa2_stamp_vertei IS INITIAL.
    MOVE wa_stamp_vertei TO wa2_stamp_vertei.
  ELSE.
  ENDIF.

  IF lv_flag_toggle_edit EQ '0'.
    lv_flag_toggle_edit = '1'.
  ELSEIF lv_flag_toggle_edit = '1'.
    lv_flag_toggle_edit = '0'.
  ENDIF.
ENDFORM.                    " modify_table_row
*&---------------------------------------------------------------------*
*&      Form  delete_row_from_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_row_from_table.

  IF alv_event_handler IS INITIAL.
    CREATE OBJECT alv_event_handler.
  ELSE.
  ENDIF.

  IF NOT ( wa_stamp_vertei IS INITIAL ).
    DELETE FROM zcl_stamp_vertei
                    WHERE verteiler = wa_stamp_vertei-verteiler
                    AND   stempel_name   = wa_stamp_vertei-stempel_name.

  ELSEIF NOT ( itab_selected_stamp_vertei IS INITIAL ).
    CLEAR wa_selected_stamp_vertei.
    DELETE zcl_stamp_vertei FROM TABLE itab_selected_stamp_vertei.
  ELSE.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE i073(zcl_plint_message_01)
                   WITH 'ZCL_MAINTAIN_STAMP_vertei'
                           wa_stamp_vertei-stempel_name '' ''.
  ELSE.
  ENDIF.

  COMMIT WORK.

  CLEAR wa_stamp_vertei.

  lv_flag_toggle_edit = '0'.

ENDFORM.                    " delete_row_from_table
*&---------------------------------------------------------------------*
*&      Form  copy_the_row_as_diffrent_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_the_row_as_diffrent_row.

  IF wa2_stamp_vertei IS INITIAL.
    MOVE wa_stamp_vertei TO wa2_stamp_vertei.
  ELSE.
  ENDIF.

  IF lv_flag_toggle_edit = '0'.
    lv_flag_toggle_edit = '1'.
  ELSE.
  ENDIF.

ENDFORM.                    " copy_the_row_as_diffrent_row
*&---------------------------------------------------------------------*
*&      Form  check_for_modifications
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_modifications.

  IF ( wa_stamp_vertei-stempel_name NE wa2_stamp_vertei-stempel_name
          AND
  wa_stamp_vertei-verteiler NE wa2_stamp_vertei-verteiler ).

    lv_flag_modifications = 'X'.

  ENDIF.

  IF lv_flag_modifications = 'X'.
    wa_stamp_vertei-zclinsname = sy-uname.
    wa_stamp_vertei-zclinsdate = sy-datum.
    wa_stamp_vertei-zclinstime = sy-uzeit.
    wa_stamp_vertei-zclinsprog = sy-uname.
    wa_stamp_vertei-zclupdname = sy-uname.
    wa_stamp_vertei-zclupddate = sy-datum.
    wa_stamp_vertei-zclupdtime = sy-uzeit.
    wa_stamp_vertei-zclupdprog = sy-uname.
  ENDIF.

ENDFORM.                    " check_for_modifications
*&---------------------------------------------------------------------*
*&      Form  get_selected_row_from_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_row_from_alv.

  REFRESH lv_index_itab_lvc_t_row.
  CLEAR   lv_index_wa_lvc_s_row.
  CLEAR   lv_index.

  REFRESH itab_selected_stamp_vertei.
  CLEAR   itab_selected_stamp_vertei.
  CLEAR   wa_selected_stamp_vertei.

  CALL METHOD obj_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lv_index_itab_lvc_t_row
*    et_row_no     = tmp_index_itab_stamp_vertei.
            .


  IF NOT ( lv_index_itab_lvc_t_row IS INITIAL ).
    CLEAR wa_stamp_vertei.
    LOOP AT lv_index_itab_lvc_t_row INTO lv_index_wa_lvc_s_row.
      MOVE lv_index_wa_lvc_s_row-index TO lv_index.

      READ TABLE itab_stamp_vertei INDEX lv_index
          INTO wa_selected_stamp_vertei.
    ENDLOOP.
    MOVE wa_selected_stamp_vertei TO wa_stamp_vertei.
  ENDIF.

ENDFORM.                    " get_selected_row_from_alv
