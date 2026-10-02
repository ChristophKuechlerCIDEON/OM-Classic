*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LCDESK_MAT_BOM2I02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  IF NOT ref_alv IS INITIAL.
    CALL METHOD ref_alv->free.
    CALL METHOD ref_container->free.
    FREE: ref_alv, ref_container.
  ENDIF.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " exit  INPUT
*&---------------------------------------------------------------------*
*&      Module  save_ok_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE save_ok_code INPUT.

  save_ok_code = ok_code.
  CLEAR ok_code.

ENDMODULE.                 " save_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE save_ok_code.
    WHEN 'REFRESH'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        CLEAR it_selected_rows.
      ENDIF.
      CALL METHOD ref_alv->refresh_table_display.
    WHEN 'BACK'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        CLEAR save_ok_code.
        CLEAR it_selected_rows.
        CALL METHOD ref_container->free.
        FREE: ref_container, ref_alv.
        SET SCREEN 0. LEAVE SCREEN.
      ELSE.
        CALL METHOD ref_alv->set_selected_rows
          EXPORTING
            it_index_rows = it_selected_rows.
      ENDIF.
    WHEN 'DEL'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        gf_refresh_data = abap_true.
        CLEAR it_selected_rows.
        PERFORM delete_entries.
      ENDIF.
      CALL METHOD ref_alv->refresh_table_display.
    WHEN 'INFO'.
      CREATE OBJECT gf_versionsinfo.
      CALL METHOD gf_versionsinfo->get_info_lvc
        EXPORTING
          objtype = 'FUNC'
          objname = '/CIDEON/MAT_BOM_CHANGE'.

    WHEN 'INSR'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        gf_refresh_data = abap_true.
      ENDIF.
      gf_ins_app = co_append.
      PERFORM add_position.
      CALL METHOD ref_alv->refresh_table_display.
    WHEN 'INSERT'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        CLEAR wa_save_neccessary.
        gf_refresh_data = abap_true.
      ENDIF.
      gf_ins_app = co_insert.
      PERFORM read_onlyone_markedline.
      IF NOT wa_selected_rows IS INITIAL.
        PERFORM add_position.
        CALL METHOD ref_alv->refresh_table_display.
      ENDIF.
    WHEN 'DETAIL' OR 'DBLCLICK'.
      PERFORM popup_to_confirm.
      IF answer = 'J'.
        gf_refresh_data = abap_false.
        CLEAR wa_save_neccessary.
        IF save_ok_code = 'DETAIL'.
          PERFORM read_onlyone_markedline.
          PERFORM show_details.
        ELSE.
          PERFORM set_marked_line.
          PERFORM read_onlyone_markedline.
          PERFORM show_details.
        ENDIF.
      ENDIF.
  ENDCASE.
  CLEAR save_ok_code.

ENDMODULE.                 " user_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DOC_EXIST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_doc_exist INPUT.

  check browser_tab_strip-activetab = 'FCDOC'.

  DATA: loc_doc_key(36) TYPE c.

  IF draw-doknr IS INITIAL.
    MESSAGE e019(/cideon/mat_bom_prin).
  ENDIF.
  IF draw-dokar IS INITIAL.
    MESSAGE e020(/cideon/mat_bom_prin).
  ENDIF.

  IF draw-doktl IS INITIAL.
    MOVE: '000' TO draw-doktl.
  ENDIF.

  IF draw-dokvr IS INITIAL.
    MOVE: '00'  TO draw-dokvr.
  ENDIF.

  CALL FUNCTION 'DOCNUMBER_CHECK_IN_EXIT'
       EXPORTING
            ex_dokar = draw-dokar
            ex_doknr = draw-doknr
       IMPORTING
            doknr    = draw-doknr.

  SELECT SINGLE dokar doknr doktl dokvr FROM draw
     INTO (draw-dokar,draw-doknr,draw-doktl,draw-dokvr)
     WHERE dokar EQ draw-dokar
       AND doknr EQ draw-doknr
       AND doktl EQ draw-doktl
       AND dokvr EQ draw-dokvr.

  CHECK syst-subrc NE 0.

  CONCATENATE draw-dokar draw-doknr draw-doktl draw-dokvr
                         INTO loc_doc_key SEPARATED BY '/'.

  MESSAGE e018(/cideon/mat_bom_prin) WITH loc_doc_key.

ENDMODULE.                 " CHECK_DOC_EXIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0200 INPUT.

  SET SCREEN 0. LEAVE SCREEN.

ENDMODULE.                 " exit_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  MOVE ok_code TO save_ok_code.
  CLEAR ok_code.
  PERFORM user_command_0200.
  CLEAR save_ok_code.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MAT_EXIST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mat_exist INPUT.

  check browser_tab_strip-activetab = 'FCMAT'.

  SELECT SINGLE matnr FROM mara INTO mara-matnr
     WHERE matnr EQ mara-matnr.

  IF syst-subrc EQ 0.
  ELSE.
    MESSAGE e017(/cideon/mat_bom_prin) WITH mara-matnr.
  ENDIF.

ENDMODULE.                 " CHECK_MAT_EXIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_meins  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_meins INPUT.

  check browser_tab_strip-activetab = 'FCMAT'.

  DATA:l_meins TYPE stpo-meins.

  SELECT SINGLE meins FROM ent1027 INTO l_meins
  WHERE matnr = mara-matnr.
  IF l_meins EQ stpo-meins.
  ELSE.
    stpo-meins = l_meins.
    MESSAGE e016(/cideon/mat_bom_prin) WITH mara-matnr l_meins .
  ENDIF.

ENDMODULE.                 " check_meins  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_menge  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_menge INPUT.

  check browser_tab_strip-activetab = 'FCMAT'.

  IF NOT stpo-meins IS INITIAL.
  ELSE.
    SELECT SINGLE meins FROM ent1027 INTO l_meins
    WHERE matnr = mara-matnr.
    stpo-meins = l_meins.
    MESSAGE e016(/cideon/mat_bom_prin) WITH mara-matnr l_meins .
  ENDIF.

  PERFORM decimals_check
  IN PROGRAM saplcsdi IF FOUND USING stpo-meins stpo-menge.

ENDMODULE.                 " check_menge  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_position_fcmat  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_position_fcmat INPUT.

  check browser_tab_strip-activetab = 'FCMAT'.

  IF stpox-stufe IS INITIAL.
    MOVE '99' TO g_stufe.
    MOVE stpox-stufe TO g_stufe.
  ELSE.
    MOVE stpox-stufe TO g_stufe.
  ENDIF.
  IF stpox-posnr IS INITIAL.
    MOVE 'ZPOS' TO stpox-posnr.
    MOVE stpox-posnr TO g_posnr.
  ELSE.
    MOVE stpox-posnr TO g_posnr.
  ENDIF.

ENDMODULE.                 " check_position_fcmat  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_position_fcdoc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_position_fcdoc INPUT.

  check browser_tab_strip-activetab = 'FCDOC'.

  IF stpox-stufe IS INITIAL.
    MOVE '99' TO g_stufe.
    MOVE stpox-stufe TO g_stufe.
  ELSE.
    MOVE stpox-stufe TO g_stufe.
  ENDIF.
  IF stpox-posnr IS INITIAL.
    MOVE 'ZPOS' TO stpox-posnr.
    MOVE stpox-posnr TO g_posnr.
  ELSE.
    MOVE stpox-posnr TO g_posnr.
  ENDIF.

ENDMODULE.                 " check_position_fcdoc  INPUT
