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

  REFRESH itab.

  SELECT * FROM (tab_name)
    INTO TABLE itab
    WHERE
    id IN s_1
    AND prio_von IN s_2
    AND prio_bis IN s_3
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
  IF itab IS INITIAL.
    CLEAR wa.
    clear wa2.
  ELSE.
    READ TABLE itab INDEX index_itab INTO
      wa.
    wa2 = wa.
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
  IF index_itab EQ 0.
    index_itab = 1.
  ENDIF.

* Saves the WA
  IF wa IS INITIAL.
    EXIT.
  ELSE.
    MODIFY itab FROM wa
      INDEX index_itab.
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


  IF wa IS INITIAL.
  ELSEIF flag_modifications NE space.
    INSERT INTO (tab_name) VALUES wa.
    if sy-subrc ne 0.
    else.
    endif.
  ELSE.
    PERFORM check_insupd.
    MODIFY (tab_name) FROM wa
      .
    if sy-subrc ne 0.
    else.
    endif.
    COMMIT WORK. " Sri.....am Montag,30.09.2002.
    IF  sy-subrc NE 0.
      MESSAGE i069(zcl_plint_message_01)
         WITH TAB_Name wa ''  ''.
    ELSE.
    ENDIF.
  ENDIF.

*  IF wa_cfg_00 IS INITIAL.
*  ELSE.
*    PERFORM check_insupd.
*    MODIFY zcl_plint_cfg_00 FROM wa_cfg_00
*      .
*    COMMIT WORK. " Sri.....am Montag,30.09.2002.
*    IF  sy-subrc NE 0.
*      MESSAGE i069(zcl_plint_message_01)
*         WITH 'ZCL_PLINT_CFG_00' wa_cfg_00-pwert '' ''.
*    ELSE.
*    ENDIF.
*  ENDIF.
  CLEAR flag_modifications.
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

  CLEAR wa. " Sri.....30.09.2002

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
*&      Form  check_insupd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_insupd.
  IF wa-zclinsname IS INITIAL.
    wa-zclinsname = sy-uname.
  ENDIF.
  IF wa-zclinsdate IS INITIAL.
    wa-zclinsdate = sy-datum.
  ENDIF.
  IF wa-zclinstime IS INITIAL.
    wa-zclinstime = sy-uzeit.
  ENDIF.
  IF wa-zclinsprog IS INITIAL.
    wa-zclinsprog = sy-uname.
  ENDIF.

  wa-zclupdname = sy-uname.
  wa-zclupdprog = sy-repid.
  wa-zclupddate = sy-datum.
  wa-zclupdtime = sy-uzeit.
*  IF wa-zclupdname IS INITIAL.
*    wa-zclupdname = sy-uname.
*  ELSE.
*    wa-zclupdname = sy-uname.
*  ENDIF.
*  IF wa-zclupddate IS INITIAL.
*    wa-zclupddate = sy-datum.
*  ELSE.
*    wa-zclupddate = sy-datum.
*  ENDIF.
*  IF wa-zclupdtime IS INITIAL.
*    wa-zclupdtime = sy-uzeit.
*  ELSE.
*    wa-zclupdtime = sy-uzeit.
*  ENDIF.
*  IF wa-zclupdprog IS INITIAL.
*    wa-zclupdprog = sy-uname.
*  ELSE.
*    wa-zclupdprog = sy-uname.
*  ENDIF.
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
  CLEAR wa.
  flag_toggle_edit = '1'.
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

  flag_toggle_pname = '0'.

  IF wa2 IS INITIAL.
    MOVE wa TO wa.
  ELSE.
  ENDIF.

  IF flag_toggle_edit EQ '0'.
    flag_toggle_edit = '1'.
  ELSEIF flag_toggle_edit = '1'.
    flag_toggle_edit = '0'.
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

  DELETE FROM (tab_name)
                  WHERE id          = wa-id
* only PNAME is the key !!!
*                    AND pwert          = wa_cfg_00-pwert
*                    AND pdoku          = wa_cfg_00-pdoku
*                    AND zclinsname     = wa_cfg_00-zclinsname
*                    AND zclinsname     = wa_cfg_00-zclinsname
*                    AND zclinsdate     = wa_cfg_00-zclinsdate
*                    AND zclinstime     = wa_cfg_00-zclinstime
*                    AND zclinsprog     = wa_cfg_00-zclinsprog
*                    AND zclupdname     = wa_cfg_00-zclupdname
*                    AND zclupddate     = wa_cfg_00-zclupddate
*                    AND zclupdtime     = wa_cfg_00-zclupdtime
*                    AND zclupdprog     = wa_cfg_00-zclupdprog
                    .
  IF sy-subrc NE 0.
    MESSAGE i073(zcl_plint_message_01)
       WITH tab_name wa '' ''.
  ELSE.
  ENDIF.

  COMMIT WORK.

  CLEAR wa.

  flag_toggle_edit = '0'.

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

  IF wa2 IS INITIAL.
    MOVE wa TO wa2.
  ELSE.
  ENDIF.

  IF flag_toggle_edit = '0'.
    flag_toggle_edit = '1'.
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

  IF wa-id NE wa2-id.
    flag_modifications = 'X'.
  ENDIF.

  IF flag_modifications = 'X'.
    wa-zclinsname = sy-uname.
    wa-zclinsdate = sy-datum.
    wa-zclinstime = sy-uzeit.
    wa-zclinsprog = sy-uname.
    wa-zclupdname = sy-uname.
    wa-zclupddate = sy-datum.
    wa-zclupdtime = sy-uzeit.
    wa-zclupdprog = sy-uname.
  ENDIF.

ENDFORM.                    " check_for_modifications
*&---------------------------------------------------------------------*
*&      Form  get_selected_rows_from_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*form get_selected_rows_from_alv.
*
*  REFRESH itab_selected_format_types.
*  CLEAR   itab_selected_format_types.
*  REFRESH lv_index_itab_lvc_t_row.
*  CLEAR   lv_index_itab_lvc_t_row.
*
*  CALL METHOD obj_alv_grid->get_selected_rows
*    IMPORTING
*      et_index_rows = lv_index_itab_lvc_t_row
**     et_row_no     =
*            .
*
*  IF NOT ( lv_index_itab_lvc_t_row IS INITIAL ).
*      CLEAR wa_format_types.
*
*    LOOP AT lv_index_itab_lvc_t_row INTO lv_index_wa_lvc_s_row.
*      MOVE lv_index_wa_lvc_s_row-index TO lv_index.
*
*      READ TABLE itab_format_types INDEX lv_index
*          INTO wa_selected_format_types.
*
*    ENDLOOP.
*    MOVE wa_selected_format_types TO wa_format_types.
*  ENDIF.
*
*endform.                    " get_selected_rows_from_alv
