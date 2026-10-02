*----------------------------------------------------------------------*
*   INCLUDE Z_PP_CO_MAINTAINANCE_F01                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  get_selected_row1
*&---------------------------------------------------------------------*
*       text req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_row1.

  REFRESH itab_index_rows_alv_grid.
  REFRESH itab_aufk_porders.

  CLEAR itab_index_rows_alv_grid.
  CLEAR wa_aufk.
  CLEAR wa_aufk_porders.
  CLEAR index_itab_searchlist.

  CLEAR index_itab_searchlist.

  CALL METHOD obj_alv_grid1->get_selected_rows
    IMPORTING
      et_index_rows = itab_index_rows_alv_grid .

  DESCRIBE TABLE itab_index_rows_alv_grid LINES count_lines.

  IF NOT ( itab_index_rows_alv_grid IS INITIAL ).

    LOOP AT itab_index_rows_alv_grid INTO wa_index_one_alv_grid_row.
      index_itab_searchlist = wa_index_one_alv_grid_row-index.

      READ TABLE itab_aufk INDEX index_itab_searchlist INTO wa_aufk.

      APPEND wa_aufk TO itab_aufk_porders.

    ENDLOOP.

  ELSE.
    MESSAGE i076(zcvn).
    LEAVE TO SCREEN 999.
  ENDIF.

ENDFORM.                    " get_selected_row1

*&---------------------------------------------------------------------*
*&      Form  get_details_material_pp_order
*&---------------------------------------------------------------------*
*       text "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_details_material_pp_order.

  REFRESH itab_afpo.
  REFRESH itab_mara.
  REFRESH itab_mara_materials.
  CLEAR   itab_afpo.
  CLEAR   itab_mara.
  CLEAR   wa_afpo.
  CLEAR   wa_aufk_porders.

  bom_flag = 'M'.

  LOOP AT itab_aufk_porders INTO wa_aufk_porders.

    SELECT * FROM afpo INTO TABLE itab_afpo
                          WHERE aufnr = wa_aufk_porders-aufnr.

    LOOP AT itab_afpo INTO wa_afpo.

      SELECT * FROM mara INTO TABLE itab_mara
                                WHERE matnr = wa_afpo-matnr.

      IF sy-subrc = 0.

        LOOP AT itab_mara INTO wa_mara.
          APPEND wa_mara TO itab_mara_materials.
        ENDLOOP.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

  REFRESH itab_mara.
  CLEAR itab_mara.
  CLEAR wa_mara.

  CALL SCREEN '0993'.

ENDFORM.                    " get_details_material_pp_order

*&---------------------------------------------------------------------*
*&      Form  create_new_material
*&---------------------------------------------------------------------*
*       text "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_new_material_immediate.

*  IF mm_im IS INITIAL.
*    CALL SCREEN '0995' STARTING AT 15 2 ENDING AT 90 17.
*  ELSE.
*    CALL TRANSACTION 'MM01'.
*  ENDIF.

ENDFORM.                    " create_new_material_immediate

*&---------------------------------------------------------------------*
*&      Form  selection_of_display_or_modify
*&---------------------------------------------------------------------*
*       text "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selection_of_display_or_modify.

  CLEAR bom_flag.

  IF NOT ( eqp_sl IS INITIAL ).
    CALL TRANSACTION 'IB03'.
  ELSEIF NOT ( dok_sl IS INITIAL ).
    bom_flag = 'D'.
    PERFORM get_data_for_search_list.
  ELSEIF NOT ( mat_sl IS INITIAL ).
    bom_flag = 'M'.
    PERFORM get_data_for_search_list.
  ELSEIF NOT ( tec_sl IS INITIAL ).
    CALL TRANSACTION 'IB13'.
  ELSEIF NOT ( auf_sl IS INITIAL ).
    CALL TRANSACTION 'CS63'.
  ELSEIF NOT ( pro_sl IS INITIAL ).
    CALL TRANSACTION 'CS73'.
  ENDIF.

ENDFORM.                    " selection_of_display_or_modify

*&---------------------------------------------------------------------*
*&      Form  creation_of_stueckliste
*&---------------------------------------------------------------------*
*       text   "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM creation_of_stueckliste.

  IF NOT ( dok_sl IS INITIAL ).
    CALL TRANSACTION 'CV11'.
  ELSEIF NOT ( mat_sl IS INITIAL ).
    CALL TRANSACTION 'CS01'.
  ELSEIF NOT ( eqp_sl IS INITIAL ).
    CALL TRANSACTION 'IB01'.
  ELSEIF NOT ( tec_sl IS INITIAL ).
    CALL TRANSACTION 'IB11'.
  ELSEIF NOT ( auf_sl IS INITIAL ).
    CALL TRANSACTION 'CS61'.
  ELSEIF NOT ( pro_sl IS INITIAL ).
    CALL TRANSACTION 'CS71'.
  ENDIF.

ENDFORM.                    " creation_of_stueckliste

*&---------------------------------------------------------------------*
*&      Form  select_and_display_or_mofify
*&---------------------------------------------------------------------*
*       text "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_and_display_or_mofify.

  CLEAR itab_stpo_positions.
  CLEAR wa_mara.
  REFRESH itab_mast.
  REFRESH itab_stpo.
  REFRESH itab_stpo_positions.


  LOOP AT itab_mara INTO wa_mara.

    SELECT * FROM mast INTO TABLE itab_mast
        WHERE matnr = wa_mara-matnr.

    IF sy-subrc = 0.
      LOOP AT itab_mast INTO wa_mast.
        SELECT * FROM stpo INTO TABLE itab_stpo
            WHERE stlnr = wa_mast-stlnr.

        IF sy-subrc = 0.
          LOOP AT itab_stpo INTO wa_stpo.
            APPEND wa_stpo TO itab_stpo_positions.
          ENDLOOP.
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDLOOP.

  REFRESH itab_stpo.
  CLEAR   itab_stpo.
  CLEAR   wa_stpo.

*  Display STPO values.
  IF NOT ( itab_stpo_positions IS INITIAL ).
    CALL SCREEN '0887'.
  ENDIF.

ENDFORM.                    " select_and_display_or_mofify

*&---------------------------------------------------------------------*
*&      Form  get_selected_row4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_row4.

  REFRESH itab_mara.
  REFRESH itab_index_rows_alv_grid.
  CLEAR wa_mara.
  CLEAR index_itab_searchlist.
  CLEAR itab_index_rows_alv_grid.

  CHECK NOT ( obj_alv_grid4 IS INITIAL ).

  CALL METHOD obj_alv_grid4->get_selected_rows
    IMPORTING
      et_index_rows = itab_index_rows_alv_grid .

  DESCRIBE TABLE itab_index_rows_alv_grid LINES count_lines.

  IF NOT ( itab_index_rows_alv_grid IS INITIAL ).
    LOOP AT itab_index_rows_alv_grid INTO wa_index_one_alv_grid_row.
      index_itab_searchlist = wa_index_one_alv_grid_row-index.

      READ TABLE itab_mara_materials INDEX index_itab_searchlist
          INTO wa_mara.

      APPEND wa_mara TO itab_mara.

    ENDLOOP.
  ELSE.
    MESSAGE i076(zcvn).
    LEAVE TO SCREEN 999.

  ENDIF.

ENDFORM.                    " get_selected_row4

*&---------------------------------------------------------------------*
*&      Form  get_data_for_search_list
*&---------------------------------------------------------------------*
*       text "req....................
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_for_search_list.

  IF bom_flag = 'D'.
    REFRESH itab_draw.

    CALL FUNCTION 'CV100_DOC_SEARCH'
     EXPORTING
       pf_cv04_list_type       = '2'
*    PF_WEB_LIST_TYPE        =
       api_flag                = 'X'
     TABLES
       ptx_draw                = itab_draw
      .

    CLEAR wa_draw.

    CALL SCREEN '0888'. " Displays DRAW table as per selections...
  ELSEIF bom_flag = 'M'.
    REFRESH itab_mara.
    CLEAR itab_mara.

    CALL SCREEN '0899'.

  ENDIF.

ENDFORM.                    " get_data_for_search_list

*&---------------------------------------------------------------------*
*&      Form  get_selected_row5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_row5.

  REFRESH itab_draw_documents.
  REFRESH itab_index_rows_alv_grid.
  CLEAR index_itab_searchlist.
  CLEAR itab_index_rows_alv_grid.

  CHECK NOT ( obj_alv_grid5 IS INITIAL ).

  CALL METHOD obj_alv_grid5->get_selected_rows
    IMPORTING
      et_index_rows = itab_index_rows_alv_grid .

  IF NOT ( itab_index_rows_alv_grid IS INITIAL ).
    LOOP AT itab_index_rows_alv_grid INTO wa_index_one_alv_grid_row.
      index_itab_searchlist = wa_index_one_alv_grid_row-index.
      READ TABLE itab_draw INDEX index_itab_searchlist INTO wa_draw.
      APPEND wa_draw TO itab_draw_documents.
    ENDLOOP.

  ELSE.
    MESSAGE i079(zcvn).
    gl_flag = 'X'.
  ENDIF.

ENDFORM.                    " get_selected_row5

*&---------------------------------------------------------------------*
*&      Form  material_bom_change
*&---------------------------------------------------------------------*
*       text  "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM material_bom_change.

  REFRESH itab_mast.
  CLEAR wa_mast.
  CLEAR count_lines.


  SELECT * FROM mast INTO TABLE itab_mast
                              WHERE matnr = wa_mara-matnr.

  DESCRIBE TABLE itab_mast LINES count_lines.

  IF count_lines GT 1.

    CALL SCREEN '0886'.

    SET PARAMETER ID : 'MAT' FIELD wa_mast-matnr,
                       'WRK' FIELD wa_mast-werks,
                       'CSV' FIELD wa_mast-stlan.
  ELSE.
    LOOP AT itab_mast INTO wa_mast.
      SET PARAMETER ID : 'MAT' FIELD wa_mast-matnr,
                         'WRK' FIELD wa_mast-werks,
                         'CSV' FIELD wa_mast-stlan.
    ENDLOOP.
  ENDIF.

  CALL TRANSACTION 'CS02' AND SKIP FIRST SCREEN.

ENDFORM.                    " material_bom_change

*&---------------------------------------------------------------------*
*&      Form  select_data_from_screen_899
*&---------------------------------------------------------------------*
*       text  "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data_from_screen_899.

  DATA : lv_answer TYPE c.

  CLEAR lv_answer.
  CLEAR itab_mara_materials.
  REFRESH itab_mara_materials.

  IF     s_matnr IS INITIAL
     AND s_mtype IS INITIAL
     AND s_cname IS INITIAL
     AND s_modby IS INITIAL
     AND s_cdate IS INITIAL
     AND s_mdate IS INITIAL.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
       defaultoption    = 'N'
        textline1       = 'Wanna To Display whole Data from MARA'
*       TEXTLINE2       = ' '
        titel           = 'Do You really Want Display Whole Table'
       start_column     = 25
       start_row        = 6
*       CANCEL_DISPLAY  = ''
     IMPORTING
       answer           = lv_answer.

    IF lv_answer = 'J'.
      SELECT * FROM mara INTO TABLE itab_mara_materials.
    ELSE.
      EXIT.
    ENDIF.

  ELSE.
    SELECT * FROM mara INTO TABLE itab_mara_materials
            WHERE matnr IN s_matnr
              AND mtart IN s_mtype
              AND ernam IN s_cname
              AND aenam IN s_modby
              AND ersda IN s_cdate
              AND laeda IN s_mdate.
  ENDIF.
ENDFORM.                    " select_data_from_screen_899

*&---------------------------------------------------------------------*
*&      Form  clear_subscreen_fields
*&---------------------------------------------------------------------*
*       text   "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_subscreen_fields.

  REFRESH s_matnr.
  REFRESH s_mtype.
  REFRESH s_cname.
  REFRESH s_modby.
  REFRESH s_cdate.
  REFRESH s_mdate.

ENDFORM.                    " clear_subscreen_fields

*&---------------------------------------------------------------------*
*&      Form  user_doc_bom_decision
*&---------------------------------------------------------------------*
*       text  "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_doc_bom_decision.

  DATA : lv_answer TYPE c.

  REFRESH itab_dost.

  IF gl_flag NE space.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
       defaultoption    = 'N'
       textline1       = 'Would U like to enter the directly ?'
*      TEXTLINE2         =
       titel           = 'Select a button'
       start_column     = 25
       start_row        = 6
*      CANCEL_DISPLAY    = 'X'
     IMPORTING
       answer           = lv_answer.

    IF lv_answer EQ 'J'.
      CALL TRANSACTION 'CV13'.
    ENDIF.

  ELSE.
    LOOP AT itab_draw_documents INTO wa_draw_documents.

      SELECT * FROM dost INTO TABLE itab_dost
          WHERE dokar = wa_draw_documents-dokar
            AND doknr = wa_draw_documents-doknr
            AND dokvr = wa_draw_documents-dokvr
            AND doktl = wa_draw_documents-doktl.

      LOOP AT itab_dost INTO wa_dost.
        SELECT * FROM stpo INTO TABLE itab_stpo_positions
            WHERE stlty = bom_flag
            AND stlnr = wa_dost-stlnr.
      ENDLOOP.

    ENDLOOP.
  ENDIF.

*  Display STPO values.
  IF NOT ( itab_stpo_positions IS INITIAL ).
    CALL SCREEN '0887'.
  ENDIF.

ENDFORM.                    " user_doc_bom_decision

*&---------------------------------------------------------------------*
*&      Form  get_selected_row6
*&---------------------------------------------------------------------*
*       text "req
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_row6.

  REFRESH itab_index_rows_alv_grid.
  CLEAR itab_index_rows_alv_grid.
  CLEAR index_itab_searchlist.
  REFRESH itab_stpo.

  CHECK NOT ( obj_alv_grid6 IS INITIAL ).

  CALL METHOD obj_alv_grid6->get_selected_rows
    IMPORTING
      et_index_rows = itab_index_rows_alv_grid .

  IF NOT ( itab_index_rows_alv_grid IS INITIAL ).
    LOOP AT itab_index_rows_alv_grid INTO wa_index_one_alv_grid_row.
      index_itab_searchlist = wa_index_one_alv_grid_row-index.

      READ TABLE itab_stpo_positions INDEX
                index_itab_searchlist INTO wa_stpo_positions.

      APPEND wa_stpo_positions TO itab_stpo.

    ENDLOOP.

  ELSE.
    MESSAGE i076(zcvn).

  ENDIF.

ENDFORM.                    " get_selected_row6

*&---------------------------------------------------------------------*
*&      Form  collect_draw_deatils
*&---------------------------------------------------------------------*
*       text  "req..
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_draw_deatils.

  CLEAR itab_draw.
  REFRESH itab_draw.
  REFRESH itab_search.
  REFRESH itab_draw_autoorg.

  LOOP AT itab_stpo INTO wa_stpo.

* Check for the documents..........
    IF NOT ( wa_stpo-dokar IS INITIAL )
        AND NOT ( wa_stpo-doknr IS INITIAL )
          AND NOT ( wa_stpo-dokvr IS INITIAL )
            AND NOT ( wa_stpo-doktl IS INITIAL ).

*     If a document is found then collect the concern data
*     from the table draw.
      SELECT * FROM draw INTO TABLE itab_draw
          WHERE dokar = wa_stpo-dokar
            AND doknr = wa_stpo-doknr
            AND dokvr = wa_stpo-dokvr
            AND doktl = wa_stpo-doktl.

      IF sy-subrc = 0.
        LOOP AT itab_draw INTO wa_draw.
          APPEND wa_draw TO itab_draw_autoorg.
        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDLOOP.

* Trying to incorporate DRAW table to ZCL_S_DOCSEARCH table
* so that SAP_PLOTTING_SOLUTION can display the data.
  LOOP AT itab_draw_autoorg INTO wa_draw_autoorg.
    MOVE-CORRESPONDING wa_draw_autoorg TO wa_search.
    APPEND wa_search TO itab_search.
  ENDLOOP.

ENDFORM.                    " collect_draw_deatils

*&---------------------------------------------------------------------*
*&      Form  get_selected_and_pass_row7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_and_pass_row7.


  REFRESH itab_index_rows_alv_grid.
  CLEAR wa_mast.
  CLEAR index_itab_searchlist.
  CLEAR itab_index_rows_alv_grid.

  CHECK NOT ( obj_alv_grid7 IS INITIAL ).

  CALL METHOD obj_alv_grid7->get_selected_rows
    IMPORTING
      et_index_rows = itab_index_rows_alv_grid .

  IF NOT ( itab_index_rows_alv_grid IS INITIAL ).
    LOOP AT itab_index_rows_alv_grid INTO wa_index_one_alv_grid_row.
      index_itab_searchlist = wa_index_one_alv_grid_row-index.
    ENDLOOP.

    READ TABLE itab_mast INDEX index_itab_searchlist INTO wa_mast.

  ELSE.
    MESSAGE i076(zcvn).
    LEAVE TO SCREEN 0.

  ENDIF.

ENDFORM.                    " get_selected_and_pass_row7

*&---------------------------------------------------------------------*
*&      Form  select_rows_from_884
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_rows_from_884.

  CLEAR aufk_sel_flag.
  REFRESH itab_aufk.

  IF     s_aufnr IS INITIAL
     AND s_auart IS INITIAL
     AND s_autyp IS INITIAL
     AND s_refnr IS INITIAL
     AND s_ernam IS INITIAL
     AND s_werks IS INITIAL.

    SELECT * FROM aufk INTO TABLE itab_aufk
            WHERE aufnr IN s_aufnr
              AND auart IN s_auart
              AND autyp IN s_autyp
              AND refnr IN s_refnr
              AND ernam IN s_ernam
              AND werks IN s_werks.

    aufk_sel_flag = 'X'.

  ELSE.
    SELECT * FROM aufk INTO TABLE itab_aufk.
    aufk_sel_flag = 'X'.

  ENDIF.

ENDFORM.                    " select_rows_from_884
