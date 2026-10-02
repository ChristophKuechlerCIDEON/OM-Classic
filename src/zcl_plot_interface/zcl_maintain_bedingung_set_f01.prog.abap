*----------------------------------------------------------------------*
*   INCLUDE ZCL_MAINTAIN_BEDINGUNG_SET_F01                             *
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

  DATA : wa_tmp_beding_set TYPE zcl_beding_set.

  IF ( wa_beding_set-uname NE wa2_beding_set-uname )
      AND
      ( wa_beding_set-verteiler NE wa2_beding_set-verteiler )
      AND
      ( wa_beding_set-id_schluessel NE wa2_beding_set-id_schluessel )
      AND
      ( wa_beding_set-id_bedingung NE wa2_beding_set-id_bedingung ).


*( wa_beding_set-id_bedingung_sub NE wa2_beding_set-id_bedingung_sub ).

    LOOP AT itab_beding_set INTO wa_tmp_beding_set WHERE
                  id_bedingung_sub = wa_beding_set-id_bedingung_sub.
    ENDLOOP.

    IF sy-subrc <> 0.
      lv_flag_modifications = 'X'.
    ELSE.
    ENDIF.
  ENDIF.

  IF lv_flag_modifications = 'X'.
    wa_beding_set-zclinsname = sy-uname.
    wa_beding_set-zclinsdate = sy-datum.
    wa_beding_set-zclinstime = sy-uzeit.
    wa_beding_set-zclinsprog = sy-uname.
    wa_beding_set-zclupdname = sy-uname.
    wa_beding_set-zclupddate = sy-datum.
    wa_beding_set-zclupdtime = sy-uzeit.
    wa_beding_set-zclupdprog = sy-uname.
  ELSE.
    CLEAR wa_beding_set.
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
  IF wa_beding_set-zclinsname IS INITIAL.
    wa_beding_set-zclinsname = sy-uname.
  ENDIF.
  IF wa_beding_set-zclinsdate IS INITIAL.
    wa_beding_set-zclinsdate = sy-datum.
  ENDIF.
  IF wa_beding_set-zclinstime IS INITIAL.
    wa_beding_set-zclinstime = sy-uzeit.
  ENDIF.
  IF wa_beding_set-zclinsprog IS INITIAL.
    wa_beding_set-zclinsprog = sy-uname.
  ENDIF.
  IF wa_beding_set-zclupdname IS INITIAL.
    wa_beding_set-zclupdname = sy-uname.
  ELSE.
    wa_beding_set-zclupdname = sy-uname.
  ENDIF.
  IF wa_beding_set-zclupddate IS INITIAL.
    wa_beding_set-zclupddate = sy-datum.
  ELSE.
    wa_beding_set-zclupddate = sy-datum.
  ENDIF.
  IF wa_beding_set-zclupdtime IS INITIAL.
    wa_beding_set-zclupdtime = sy-uzeit.
  ELSE.
    wa_beding_set-zclupdtime = sy-uzeit.
  ENDIF.
  IF wa_beding_set-zclupdprog IS INITIAL.
    wa_beding_set-zclupdprog = sy-uname.
  ELSE.
    wa_beding_set-zclupdprog = sy-uname.
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

  IF wa2_beding_set IS INITIAL AND NOT ( wa_beding_set IS INITIAL ).
    MOVE wa_beding_set TO wa2_beding_set.
  ELSEIF NOT ( wa_selected_beding_set IS INITIAL ).

    MOVE wa_selected_beding_set TO wa_beding_set.
    MOVE wa_selected_beding_set TO wa2_beding_set.

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

  CLEAR wa_beding_set.
  CLEAR wa2_beding_set.

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

  IF NOT ( wa_beding_set IS INITIAL ).
    DELETE FROM zcl_beding_set
                 WHERE uname          = wa_beding_set-uname
                 AND verteiler        = wa_beding_set-verteiler
                 AND id_schluessel    = wa_beding_set-id_schluessel
                 AND id_bedingung     = wa_beding_set-id_bedingung
                 AND id_bedingung_sub = wa_beding_set-id_bedingung_sub.

  ELSEIF NOT ( itab_selected_beding_set IS INITIAL ).
    CLEAR wa_selected_beding_set.
    DELETE zcl_beding_set FROM TABLE itab_selected_beding_set.
  ELSE.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE i073(zcl_plint_message_01)
       WITH 'ZCL_PLINT_CFG_00' wa_beding_set-id_bedingung_sub '' ''.
  ELSE.
  ENDIF.

  COMMIT WORK.

  CLEAR wa_beding_set.

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

  REFRESH itab_beding_set.

  SELECT * FROM zcl_beding_set
    INTO TABLE itab_beding_set
    WHERE
        uname            IN s_uname
    AND verteiler        IN s_vertlr
    AND id_schluessel    IN s_schlel
    AND id_bedingung     IN s_beding
    AND id_bedingung_sub IN s_bedsub
    AND prio             IN s_prio
    AND beschreibung     IN s_beshri
    AND bedingungsfeld   IN s_bedfel
    AND operator         IN s_opetor
    AND vergleichswert   IN s_glewrt
    AND zclinsname       IN sinsname
    AND zclinsdate       IN sinsdate
    AND zclinstime       IN sinstime
    AND zclinsprog       IN sinsprog
    AND zclupdname       IN supdname
    AND zclupddate       IN supddate
    AND zclupdtime       IN supdtime
    AND zclupdprog       IN supdprog
          .

  IF sy-subrc EQ  0.
    SORT itab_beding_set BY id_bedingung_sub.
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

  REFRESH itab_selected_beding_set.
  CLEAR   itab_selected_beding_set.
  REFRESH lv_index_itab_lvc_t_row.
  CLEAR   lv_index_itab_lvc_t_row.

  CALL METHOD obj_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lv_index_itab_lvc_t_row
*     et_row_no     =
            .

  IF NOT ( lv_index_itab_lvc_t_row IS INITIAL ).
    CLEAR wa_beding_set.

    LOOP AT lv_index_itab_lvc_t_row INTO lv_index_wa_lvc_s_row.
      MOVE lv_index_wa_lvc_s_row-index TO lv_index.

      READ TABLE itab_beding_set INDEX lv_index
          INTO wa_selected_beding_set.

    ENDLOOP.
    MOVE wa_selected_beding_set TO wa_beding_set.
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

  IF wa2_beding_set IS INITIAL AND NOT ( wa_beding_set IS INITIAL ).
    MOVE wa_beding_set TO wa2_beding_set.
  ELSEIF NOT ( wa_selected_beding_set IS INITIAL ).
    MOVE wa_selected_beding_set TO wa2_beding_set.
    MOVE wa_selected_beding_set TO wa_beding_set.
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
  IF itab_beding_set IS INITIAL.
    CLEAR wa_beding_set.
  ELSE.
    READ TABLE itab_beding_set INDEX lv_index_itab_beding_set INTO
      wa_beding_set.
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

  CLEAR wa_beding_set.

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
  IF     wa_beding_set IS INITIAL.
  ELSEIF lv_flag_modifications NE space.
    INSERT INTO zcl_beding_set VALUES wa_beding_set.
  ELSE.
    PERFORM check_insupd.
    MODIFY zcl_beding_set FROM wa_beding_set.
    COMMIT WORK.

    IF  sy-subrc NE 0.
      MESSAGE i069(zcl_plint_message_01)
         WITH 'ZCL_PLINT_CFG_00' wa_beding_set-uname
                          wa_beding_set-id_bedingung_sub ''.
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

  IF lv_index_itab_beding_set EQ 0.
    lv_index_itab_beding_set = 1.
  ENDIF.

  IF wa_beding_set IS INITIAL.
    EXIT.
  ELSE.
    MODIFY itab_beding_set FROM wa_beding_set
      INDEX lv_index_itab_beding_set.
  ENDIF.


ENDFORM.                    " save_wa_ALV
*&---------------------------------------------------------------------*
*&      Form  check_for_consistency
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_consistency.

  DATA : itab_tmp_verteiler TYPE TABLE OF zcl_verteiler,
         wa_tmp_verteiler   TYPE          zcl_verteiler.

  DATA : itab_tmp_schluessel TYPE TABLE OF zcl_schluessel,
         wa_tmp_schluessel   TYPE          zcl_schluessel.

  DATA : itab_tmp_beding TYPE TABLE OF zcl_bedingung,
         wa_tmp_beding   TYPE          zcl_bedingung.


  SELECT * FROM zcl_verteiler INTO TABLE itab_tmp_verteiler.
  LOOP AT itab_tmp_verteiler INTO wa_tmp_verteiler
                    WHERE uname     = wa_beding_set-uname
                    AND   verteiler = wa_beding_set-verteiler.

  ENDLOOP.

  IF sy-subrc NE 0.



  ENDIF.


ENDFORM.                    " check_for_consistency
