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

  IF wa_format_types-paper_format NE wa2_format_types-paper_format.
    lv_flag_modifications = 'X'.
  ENDIF.

  IF lv_flag_modifications = 'X'.
    wa_format_types-zclinsname = sy-uname.
    wa_format_types-zclinsdate = sy-datum.
    wa_format_types-zclinstime = sy-uzeit.
    wa_format_types-zclinsprog = sy-uname.
    wa_format_types-zclupdname = sy-uname.
    wa_format_types-zclupddate = sy-datum.
    wa_format_types-zclupdtime = sy-uzeit.
    wa_format_types-zclupdprog = sy-uname.
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
  IF wa_format_types-zclinsname IS INITIAL.
    wa_format_types-zclinsname = sy-uname.
  ENDIF.
  IF wa_format_types-zclinsdate IS INITIAL.
    wa_format_types-zclinsdate = sy-datum.
  ENDIF.
  IF wa_format_types-zclinstime IS INITIAL.
    wa_format_types-zclinstime = sy-uzeit.
  ENDIF.
  IF wa_format_types-zclinsprog IS INITIAL.
    wa_format_types-zclinsprog = sy-uname.
  ENDIF.
  IF wa_format_types-zclupdname IS INITIAL.
    wa_format_types-zclupdname = sy-uname.
  ELSE.
    wa_format_types-zclupdname = sy-uname.
  ENDIF.
  IF wa_format_types-zclupddate IS INITIAL.
    wa_format_types-zclupddate = sy-datum.
  ELSE.
    wa_format_types-zclupddate = sy-datum.
  ENDIF.
  IF wa_format_types-zclupdtime IS INITIAL.
    wa_format_types-zclupdtime = sy-uzeit.
  ELSE.
    wa_format_types-zclupdtime = sy-uzeit.
  ENDIF.
  IF wa_format_types-zclupdprog IS INITIAL.
    wa_format_types-zclupdprog = sy-uname.
  ELSE.
    wa_format_types-zclupdprog = sy-uname.
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

  IF wa2_format_types IS INITIAL AND NOT ( wa_format_types IS INITIAL ).
    MOVE wa_format_types TO wa2_format_types.
  ELSEIF NOT ( wa_selected_format_types IS INITIAL ).

    MOVE wa_selected_format_types TO wa_format_types.
    MOVE wa_selected_format_types TO wa2_format_types.

  ELSE.
  ENDIF.

  IF lv_flag_toggle_edit = '0'.
    lv_flag_toggle_edit = '1'.
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

  CLEAR wa_format_types.
  CLEAR wa2_format_types.

  lv_flag_toggle_edit = '1'.

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

  IF NOT ( wa_format_types IS INITIAL ).
    DELETE FROM zcl_format_types
                    WHERE paper_format  = wa_format_types-paper_format
                    AND   paper_index   = wa_format_types-paper_index.

  ELSEIF NOT ( itab_selected_format_types IS INITIAL ).
    CLEAR wa_selected_format_types.
    DELETE zcl_format_types FROM TABLE itab_selected_format_types.
  ELSE.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE i073(zcl_plint_message_01)
       WITH 'ZCL_PLINT_CFG_00' wa_format_types-paper_format'' ''.
  ELSE.
  ENDIF.

  COMMIT WORK.

  CLEAR wa_format_types.

  lv_flag_toggle_edit = '0'.

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

  REFRESH itab_format_types.

  SELECT * FROM zcl_format_types
    INTO TABLE itab_format_types
    WHERE
        paper_format IN s_format
    AND paper_index  IN s_pindex
    AND zclinsname   IN sinsname
    AND zclinsdate   IN sinsdate
    AND zclinstime   IN sinstime
    AND zclinsprog   IN sinsprog
    AND zclupdname   IN supdname
    AND zclupddate   IN supddate
    AND zclupdtime   IN supdtime
    AND zclupdprog   IN supdprog
    .
  IF sy-subrc EQ  0.
    SORT itab_format_types BY paper_index.
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

  REFRESH itab_selected_format_types.
  CLEAR   itab_selected_format_types.
  REFRESH lv_index_itab_lvc_t_row.
  CLEAR   lv_index_itab_lvc_t_row.

  CALL METHOD obj_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lv_index_itab_lvc_t_row
*     et_row_no     =
            .

  IF NOT ( lv_index_itab_lvc_t_row IS INITIAL ).
      CLEAR wa_format_types.

    LOOP AT lv_index_itab_lvc_t_row INTO lv_index_wa_lvc_s_row.
      MOVE lv_index_wa_lvc_s_row-index TO lv_index.

      READ TABLE itab_format_types INDEX lv_index
          INTO wa_selected_format_types.

    ENDLOOP.
    MOVE wa_selected_format_types TO wa_format_types.
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

  CLEAR lv_flag_toggle_sname.

  IF wa2_format_types IS INITIAL AND NOT ( wa_format_types IS INITIAL ).
    MOVE wa_format_types TO wa2_format_types.
  ELSEIF NOT ( wa_selected_format_types IS INITIAL ).
    MOVE wa_selected_format_types TO wa2_format_types.
    MOVE wa_selected_format_types TO wa_format_types.
  ENDIF.

  IF lv_index EQ lv_old_index.
    IF lv_flag_toggle_edit EQ '0'.
      lv_flag_toggle_edit = '1'.
      CLEAR lv_flag_toggle_sname .
    ELSEIF lv_flag_toggle_edit = '1'.
      lv_flag_toggle_edit = '0'.
      CLEAR lv_flag_toggle_sname .
    ENDIF.
  ELSE.
    lv_flag_toggle_edit = '1'.
  ENDIF.

  CLEAR lv_old_index.
  MOVE lv_index TO lv_old_index.

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
  IF itab_format_types IS INITIAL.
    CLEAR wa_format_types.
  ELSE.
    READ TABLE itab_format_types INDEX lv_index_itab_format_types INTO
      wa_format_types.
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

  CLEAR wa_format_types.

  CALL METHOD obj_alv_grid->refresh_table_display
*  EXPORTING
*     IS_STABLE      =
*     I_SOFT_REFRESH =
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
*&      Form  save_to_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_to_db.
* saves actual wa to database
  IF     wa_format_types IS INITIAL.
  ELSEIF lv_flag_modifications NE space.
    INSERT INTO zcl_format_types VALUES wa_format_types.
  ELSE.
    PERFORM check_insupd.
    MODIFY zcl_format_types FROM wa_format_types.
    COMMIT WORK.

    IF  sy-subrc NE 0.
      MESSAGE i069(zcl_plint_message_01)
         WITH 'ZCL_PLINT_CFG_00' wa_format_types-paper_format
                          wa_format_types-paper_index  ''.
    ENDIF.
  ENDIF.

  CLEAR lv_flag_modifications.

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

  IF lv_index_itab_format_types EQ 0.
    lv_index_itab_format_types = 1.
  ENDIF.

  IF wa_format_types IS INITIAL.
    EXIT.
  ELSE.
    MODIFY itab_format_types FROM wa_format_types
      INDEX lv_index_itab_format_types.
  ENDIF.


ENDFORM.                    " save_wa_ALV
