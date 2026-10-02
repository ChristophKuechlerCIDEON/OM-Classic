*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/LCDESK_MAT_BOM2F02
*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  set_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_field_catalog.

  REFRESH it_field_cat.

  LOOP AT gt_fields INTO gs_fields.
    CLEAR wa_field_cat.
    wa_field_cat-fieldname = gs_fields.
    APPEND wa_field_cat TO it_field_cat.
  ENDLOOP.

ENDFORM.                    " set_field_catalog
*&---------------------------------------------------------------------*
*&      Form  set_grid_toolbar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ITAB_TB_EX_SEARCHLIST  text
*----------------------------------------------------------------------*
FORM set_grid_toolbar CHANGING ct_excl_func  TYPE ui_functions.
*  append cl_gui_alv_grid=>mc_mb_variant        to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_filter         to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_sum            to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_export         to ct_excl_func.
*  append cl_gui_alv_grid=>mc_mb_view           to ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_print          to ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_graph          TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_info           TO ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_find           to ct_excl_func.
*  append cl_gui_alv_grid=>mc_fc_detail         to ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_check          TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_refresh        TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy       TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_mb_paste          TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row   TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO ct_excl_func.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO ct_excl_func.

ENDFORM.                    " set_grid_toolbar
*&---------------------------------------------------------------------*
*&      Form  popup_to_confirm
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
              textline1 = text-001
              titel     = text-002
         IMPORTING
              answer    = answer
         EXCEPTIONS
              OTHERS    = 1.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ELSE.
    answer = 'J'.
  ENDIF.

ENDFORM.                    " popup_to_confirm
*&---------------------------------------------------------------------*
*&      Form  delete_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_entries.

  CALL METHOD ref_alv->get_selected_rows
     IMPORTING
       et_index_rows = it_selected_rows.

  LOOP AT it_selected_rows INTO wa_selected_rows.
    DELETE <mat_bom> INDEX wa_selected_rows-index.
  ENDLOOP.

ENDFORM.                    " delete_entries
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
      it_index_rows = it_selected_rows.

ENDFORM.                    " set_marked_line
*&---------------------------------------------------------------------*
*&      Form  read_onlyone_markedline
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_onlyone_markedline.

  DATA:  l_lines TYPE i.

  REFRESH it_selected_rows.
  CLEAR wa_selected_rows.

  CALL METHOD ref_alv->get_selected_rows
     IMPORTING
       et_index_rows = it_selected_rows.
  DESCRIBE TABLE it_selected_rows LINES l_lines.
  IF l_lines = 0.
    MESSAGE s007(/cideon/mat_bom_prin).
    gf_refresh_data = abap_false.
    EXIT.
  ELSEIF l_lines > 1.
    MESSAGE s008(/cideon/mat_bom_prin).
    gf_refresh_data = abap_false.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT it_selected_rows INTO wa_selected_rows.
    READ TABLE <mat_bom> ASSIGNING <wa>
               INDEX wa_selected_rows-index.
  ENDLOOP.

ENDFORM.                    " read_onlyone_markedline
*&---------------------------------------------------------------------*
*&      Form  show_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_details.

  DATA: doknr TYPE doknr,
        dokar TYPE dokar,
        doktl TYPE doktl_d,
        dokvr TYPE dokvr.
  FIELD-SYMBOLS <value> TYPE ANY.
  FIELD-SYMBOLS <matnr> TYPE ANY.
  FIELD-SYMBOLS: <diskey> TYPE ANY,
                 <dokar> TYPE ANY,
                 <doknr> TYPE ANY,
                 <doktl> TYPE ANY,
                 <dokvr> TYPE ANY.

  CHECK <wa> IS ASSIGNED.
  CASE gs_bom_print-bomtype.
    WHEN 'CS11' OR 'CS12' OR 'CS13'.
      ASSIGN COMPONENT 'OBJIC' OF STRUCTURE <wa> TO <value>.
      CHECK <value> IS ASSIGNED.
      IF <value> = 'D'.
        ASSIGN COMPONENT 'DOBJT' OF STRUCTURE <wa> TO <diskey>.
        SPLIT <diskey> AT space INTO doknr dokar doktl dokvr.
        SET PARAMETER ID 'CV1' FIELD doknr.
        SET PARAMETER ID 'CV2' FIELD dokar.
        SET PARAMETER ID 'CV3' FIELD dokvr.
        SET PARAMETER ID 'CV4' FIELD doktl.
        CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
      ELSEIF <value> = 'M'.
        ASSIGN COMPONENT 'DOBJT' OF STRUCTURE <wa> TO <matnr>.
        SET PARAMETER ID 'MAT' FIELD <matnr>.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ELSE.
        ASSIGN g_head_matnr TO <matnr>.
        SET PARAMETER ID 'MAT' FIELD <matnr>.
        CALL TRANSACTION 'CS03' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN 'CS03'.
      CASE gs_bom_print-bomausp.
        WHEN 'A'.
          ASSIGN COMPONENT 'OBTSP' OF STRUCTURE <wa> TO <value>.
          CHECK <value> IS ASSIGNED.
          IF <value> = 'D'.
            ASSIGN COMPONENT 'BOMOB' OF STRUCTURE <wa> TO <diskey>.
            CONDENSE  <diskey>.
            SPLIT <diskey> AT space INTO dokar doknr doktl dokvr.
            SET PARAMETER ID 'CV1' FIELD doknr.
            SET PARAMETER ID 'CV2' FIELD dokar.
            SET PARAMETER ID 'CV3' FIELD dokvr.
            SET PARAMETER ID 'CV4' FIELD doktl.
            CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
          ELSEIF <value> = 'M'.
            ASSIGN COMPONENT 'BOMOB' OF STRUCTURE <wa> TO <matnr>.
            SET PARAMETER ID 'MAT' FIELD <matnr>.
            CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          ELSE.
            ASSIGN g_head_matnr TO <matnr>.
            SET PARAMETER ID 'MAT' FIELD <matnr>.
            CALL TRANSACTION 'CS03' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'D'.
          ASSIGN COMPONENT 'DOKAR' OF STRUCTURE <wa> TO <dokar>.
          ASSIGN COMPONENT 'DOKNR' OF STRUCTURE <wa> TO <doknr>.
          ASSIGN COMPONENT 'DOKTL' OF STRUCTURE <wa> TO <doktl>.
          ASSIGN COMPONENT 'DOKVR' OF STRUCTURE <wa> TO <dokvr>.
          CHECK <dokar> IS ASSIGNED AND <doknr> IS ASSIGNED AND
          <doktl> IS ASSIGNED AND <dokvr> IS ASSIGNED.
          CHECK NOT <dokar> IS INITIAL AND NOT <doknr> IS INITIAL
            AND NOT <doktl> IS INITIAL AND NOT <dokvr> IS INITIAL.
          SET PARAMETER ID 'CV1' FIELD <doknr>.
          SET PARAMETER ID 'CV2' FIELD <dokar>.
          SET PARAMETER ID 'CV3' FIELD <dokvr>.
          SET PARAMETER ID 'CV4' FIELD <doktl>.
          CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
        WHEN 'M'.
          ASSIGN COMPONENT 'IDNRK' OF STRUCTURE <wa> TO <matnr>.
          CHECK <matnr> IS ASSIGNED.
          CHECK NOT <matnr> IS INITIAL.
          SET PARAMETER ID 'MAT' FIELD <matnr>.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.

ENDFORM.                    " show_details
*&---------------------------------------------------------------------*
*&      Form  add_position
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_position.

  CALL SCREEN 0200.

ENDFORM.                    " add_position
*&---------------------------------------------------------------------*
*&      Form  modify_stack
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DOCUMENT  text
*----------------------------------------------------------------------*
FORM modify_stack USING m_objtp LIKE pdm_tree-object_type.

  CALL FUNCTION 'C_PDM_ADD_OBJECT_TO_STACK'
       EXPORTING
            objtyp        = m_objtp
            object_fields = object_keyfields.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command_0200.

  CASE save_ok_code.
    WHEN 'BACK'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'SEARCH'.
      CALL TRANSACTION 'CV04N'.

      GET PARAMETER ID 'CV1' FIELD draw-doknr.
      GET PARAMETER ID 'CV2' FIELD draw-dokar.
      GET PARAMETER ID 'CV4' FIELD draw-doktl.
      GET PARAMETER ID 'CV3' FIELD draw-dokvr.

    WHEN 'ENTER'.
      CLEAR: object_keyfields.

      CASE browser_tab_strip-activetab.
        WHEN 'FCDOC'.
          CHECK ( NOT ( draw-dokar IS INITIAL ) AND
                  NOT ( draw-doknr IS INITIAL ) AND
                  NOT ( draw-doktl IS INITIAL ) AND
                  NOT ( draw-dokvr IS INITIAL ) ).

          MOVE: document    TO root_object_type,
                draw-dokar  TO object_keyfields-dokar,
                draw-doknr  TO object_keyfields-doknr,
                draw-doktl  TO object_keyfields-doktl,
                draw-dokvr  TO object_keyfields-dokvr.

          PERFORM modify_stack USING document.
        WHEN 'FCMAT'.
          CHECK NOT ( mara-matnr IS INITIAL ).

          MOVE: material    TO root_object_type,
                mara-matnr  TO object_keyfields-matnr,
                stpo-meins  TO g_meins,
                stpo-menge  TO g_menge.

          PERFORM modify_stack USING material.
      ENDCASE.

      IF gf_ins_app = co_append.
        PERFORM add_mat_bom.
      ELSEIF gf_ins_app = co_insert.
        PERFORM insert_mat_bom.
      ENDIF.
      SET SCREEN 0. LEAVE SCREEN.

    WHEN 'STACK_DOC'.
      CLEAR: object_keyfields.

      CALL FUNCTION 'C_PDM_SHOW_OBJECTS_FROM_STACK'
           EXPORTING
                objtyp            = document
           IMPORTING
                new_object_fields = object_keyfields.

      IF object_keyfields-doknr IS INITIAL.
        CLEAR: save_ok_code.
      ELSE.
        MOVE:  object_keyfields-dokar TO draw-dokar,
               object_keyfields-doknr TO draw-doknr,
               object_keyfields-doktl TO draw-doktl,
               object_keyfields-dokvr TO draw-dokvr.
*              'ENTER'                 TO
        CLEAR save_ok_code.
      ENDIF.
*      PERFORM user_command_0200.

    WHEN 'STACK_MAT'.
      CLEAR: object_keyfields.

      CALL FUNCTION 'C_PDM_SHOW_OBJECTS_FROM_STACK'
           EXPORTING
                objtyp            = material
           IMPORTING
                new_object_fields = object_keyfields.

      IF object_keyfields-matnr IS INITIAL.
        CLEAR: save_ok_code.
      ELSE.
        MOVE:  object_keyfields-matnr TO mara-matnr.
*              'ENTER'                 TO
        CLEAR save_ok_code.
      ENDIF.
*      PERFORM user_command_0200.

  ENDCASE.

ENDFORM.                    " user_command_0200
*&---------------------------------------------------------------------*
*&      Form  add_mat_bom
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_mat_bom.

  DATA:  ls_documentdata TYPE bapi_doc_draw2,
         l_return TYPE bapiret2,
         l_ktext TYPE makt-maktx,
         ls_ent1027 TYPE ent1027,
         l_licence_date_in LIKE sy-datum,
         l_licence_date_out LIKE sy-datum,
         l_obtsp,
         l_doknr TYPE doknr,
         l_matnr TYPE mara-matnr,
         l_meins TYPE stpo-meins,
         l_menge TYPE stpo-menge,
         l_datuv TYPE sy-datum,
         l_stlkz TYPE stlkz,
         ls_mat_bom_cs03_a TYPE /cideon/stpos_cs03_a,
         ls_mat_bom_cs03_d TYPE /cideon/stpos_cs03_d,
         ls_mat_bom_cs03_m TYPE /cideon/stpos_cs03_m,
         ls_mat_bom_cs11 TYPE /cideon/stpos_cs11,
         ls_mat_bom_cs12 TYPE /cideon/stpos_cs12,
         ls_mat_bom_cs13 TYPE /cideon/stpos_cs13.

  CALL FUNCTION 'SLIC_GET_LICENCE_DATE'
       IMPORTING
            licence_date = l_licence_date_in.
  IF NOT l_licence_date_in IS INITIAL.
    l_licence_date_out = l_licence_date_in.
  ENDIF.

  CASE root_object_type.
    WHEN material.
      l_obtsp = co_mat.
      MOVE g_meins TO l_meins.
      MOVE g_menge TO l_menge.
      SELECT SINGLE maktx ersda FROM ent1027 INTO (l_ktext, l_datuv)
      WHERE matnr = object_keyfields-matnr.
      SELECT SINGLE matnr FROM mast INTO l_matnr
      WHERE matnr = object_keyfields-matnr.
      IF sy-subrc = 0.
        l_stlkz = 'X'.
      ENDIF.
      CLEAR l_matnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
           EXPORTING
                input  = object_keyfields-matnr
           IMPORTING
                output = l_matnr.

    WHEN document.
      l_obtsp = co_doc.
      CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
           EXPORTING
                documenttype    = object_keyfields-dokar
                documentnumber  = object_keyfields-doknr
                documentpart    = object_keyfields-doktl
                documentversion = object_keyfields-dokvr
           IMPORTING
                documentdata    = ls_documentdata
                return          = l_return.

      IF l_return-type CA 'EA'.
        MOVE 'E' TO return-type.
      ENDIF.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
           EXPORTING
                input  = object_keyfields-doknr
           IMPORTING
                output = l_doknr.
      l_ktext = ls_documentdata-description.
      MOVE 'ST' TO l_meins.
      MOVE 1    TO l_menge.
      MOVE ls_documentdata-createdate TO l_datuv.
      MOVE ls_documentdata-structureindicator TO l_stlkz.
  ENDCASE.

  CLEAR: ls_mat_bom_cs03_a, ls_mat_bom_cs03_d,
         ls_mat_bom_cs03_m, ls_mat_bom_cs11,
         ls_mat_bom_cs12, ls_mat_bom_cs13.

  SELECT SINGLE obtsp FROM tcs21 INTO ls_mat_bom_cs03_a-obtsp
         WHERE spras = sy-langu
         AND   objty = l_obtsp.
  MOVE:  g_posnr TO ls_mat_bom_cs03_a-posnr,
         l_ktext TO ls_mat_bom_cs03_a-ktext,
         l_menge TO ls_mat_bom_cs03_a-menge,
         l_meins TO ls_mat_bom_cs03_a-meins,
         l_licence_date_out TO ls_mat_bom_cs03_a-datub,
         l_datuv TO ls_mat_bom_cs03_a-datuv,
         l_stlkz TO ls_mat_bom_cs03_a-stlkz.
  MOVE-CORRESPONDING ls_mat_bom_cs03_a TO ls_mat_bom_cs03_d.
  MOVE-CORRESPONDING ls_mat_bom_cs03_a TO ls_mat_bom_cs03_m.

  MOVE: g_stufe TO ls_mat_bom_cs11-dstuf,
        g_posnr TO ls_mat_bom_cs11-posnr,
        ls_mat_bom_cs03_a-obtsp TO ls_mat_bom_cs11-objic,
        l_menge TO ls_mat_bom_cs11-mngko,
        l_meins TO ls_mat_bom_cs11-meins,
        l_stlkz TO ls_mat_bom_cs11-bomfl,
        l_ktext TO ls_mat_bom_cs11-ojtxp.
  CASE l_obtsp.
    WHEN '1'.
      MOVE l_matnr TO ls_mat_bom_cs11-dobjt.
    WHEN '3'.
      CONCATENATE  l_doknr object_keyfields-dokar
                   object_keyfields-doktl object_keyfields-dokvr
                   INTO ls_mat_bom_cs11-dobjt.
  ENDCASE.
  MOVE-CORRESPONDING ls_mat_bom_cs11 TO ls_mat_bom_cs12.
  MOVE-CORRESPONDING ls_mat_bom_cs11 TO ls_mat_bom_cs13.

  CASE gs_bom_print-bomtype.
    WHEN 'CS03'.
      CASE gs_bom_print-bomausp.
        WHEN 'A'.
          CALL FUNCTION 'ITM_BOMOB_PROVIDE'
               EXPORTING
                    i_objty = l_obtsp
                    i_idnrk = l_matnr
                    i_dokar = object_keyfields-dokar
                    i_doknr = object_keyfields-doknr
                    i_doktl = object_keyfields-doktl
                    i_dokvr = object_keyfields-dokvr
               IMPORTING
                    e_bomob = ls_mat_bom_cs03_a-bomob.
          .
          APPEND ls_mat_bom_cs03_a TO <mat_bom>.
          wa_selected_rows-index = sy-tabix.
        WHEN 'D'.
          ls_mat_bom_cs03_d-doknr = object_keyfields-doknr.
          ls_mat_bom_cs03_d-dokar = object_keyfields-dokar.
          ls_mat_bom_cs03_d-doktl = object_keyfields-doktl.
          ls_mat_bom_cs03_d-dokvr = object_keyfields-dokvr.
          APPEND ls_mat_bom_cs03_d TO <mat_bom>.
          wa_selected_rows-index = sy-tabix.
        WHEN 'M'.
          ls_mat_bom_cs03_m-idnrk = l_matnr.
          APPEND ls_mat_bom_cs03_m TO <mat_bom>.
          wa_selected_rows-index = sy-tabix.

      ENDCASE.
    WHEN 'CS11'.
      APPEND ls_mat_bom_cs11 TO <mat_bom>.
      wa_selected_rows-index = sy-tabix.

    WHEN 'CS12'.
      ls_mat_bom_cs12-dglvl = g_stufe.
      APPEND ls_mat_bom_cs12 TO <mat_bom>.
      wa_selected_rows-index = sy-tabix.

    WHEN 'CS13'.
      APPEND ls_mat_bom_cs13 TO <mat_bom>.
      wa_selected_rows-index = sy-tabix.

    WHEN OTHERS.
  ENDCASE.
  REFRESH it_selected_rows.
  APPEND wa_selected_rows TO it_selected_rows.

ENDFORM.                    " add_mat_bom
*&---------------------------------------------------------------------*
*&      Form  insert_mat_bom
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_mat_bom.


  DATA:  ls_documentdata TYPE bapi_doc_draw2,
         l_return TYPE bapiret2,
         l_ktext TYPE makt-maktx,
         ls_ent1027 TYPE ent1027,
         l_licence_date_in LIKE sy-datum,
         l_licence_date_out LIKE sy-datum,
         l_obtsp,
         l_doknr TYPE doknr,
         l_matnr TYPE mara-matnr,
         l_meins TYPE stpo-meins,
         l_menge TYPE stpo-menge,
         l_datuv TYPE sy-datum,
         l_stlkz TYPE stlkz,
         ls_mat_bom_cs03_a TYPE /cideon/stpos_cs03_a,
         ls_mat_bom_cs03_d TYPE /cideon/stpos_cs03_d,
         ls_mat_bom_cs03_m TYPE /cideon/stpos_cs03_m,
         ls_mat_bom_cs11 TYPE /cideon/stpos_cs11,
         ls_mat_bom_cs12 TYPE /cideon/stpos_cs12,
         ls_mat_bom_cs13 TYPE /cideon/stpos_cs13,
         index TYPE i.

  CALL FUNCTION 'SLIC_GET_LICENCE_DATE'
       IMPORTING
            licence_date = l_licence_date_in.
  IF NOT l_licence_date_in IS INITIAL.
    l_licence_date_out = l_licence_date_in.
  ENDIF.

  CASE root_object_type.
    WHEN material.
      l_obtsp = co_mat.
      MOVE g_meins TO l_meins.
      MOVE g_menge TO l_menge.
      SELECT SINGLE maktx ersda FROM ent1027 INTO (l_ktext, l_datuv)
      WHERE matnr = object_keyfields-matnr.
      SELECT SINGLE matnr FROM mast INTO l_matnr
      WHERE matnr = object_keyfields-matnr.
      IF sy-subrc = 0.
        l_stlkz = 'X'.
      ENDIF.
      CLEAR l_matnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
           EXPORTING
                input  = object_keyfields-matnr
           IMPORTING
                output = l_matnr.

    WHEN document.
      l_obtsp = co_doc.
      CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
           EXPORTING
                documenttype    = object_keyfields-dokar
                documentnumber  = object_keyfields-doknr
                documentpart    = object_keyfields-doktl
                documentversion = object_keyfields-dokvr
           IMPORTING
                documentdata    = ls_documentdata
                return          = l_return.

      IF l_return-type CA 'EA'.
        MOVE 'E' TO return-type.
      ENDIF.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
           EXPORTING
                input  = object_keyfields-doknr
           IMPORTING
                output = l_doknr.
      l_ktext = ls_documentdata-description.
      MOVE 'ST' TO l_meins.
      MOVE 1    TO l_menge.
      MOVE ls_documentdata-createdate TO l_datuv.
      MOVE ls_documentdata-structureindicator TO l_stlkz.
  ENDCASE.

  CLEAR: ls_mat_bom_cs03_a, ls_mat_bom_cs03_d,
         ls_mat_bom_cs03_m, ls_mat_bom_cs11,
         ls_mat_bom_cs12, ls_mat_bom_cs13.

  SELECT SINGLE obtsp FROM tcs21 INTO ls_mat_bom_cs03_a-obtsp
         WHERE spras = sy-langu
         AND   objty = l_obtsp.
  MOVE:  g_posnr TO ls_mat_bom_cs03_a-posnr,
         l_ktext TO ls_mat_bom_cs03_a-ktext,
         l_menge TO ls_mat_bom_cs03_a-menge,
         l_meins TO ls_mat_bom_cs03_a-meins,
         l_licence_date_out TO ls_mat_bom_cs03_a-datub,
         l_datuv TO ls_mat_bom_cs03_a-datuv,
         l_stlkz TO ls_mat_bom_cs03_a-stlkz.
  MOVE-CORRESPONDING ls_mat_bom_cs03_a TO ls_mat_bom_cs03_d.
  MOVE-CORRESPONDING ls_mat_bom_cs03_a TO ls_mat_bom_cs03_m.

  MOVE: g_stufe TO ls_mat_bom_cs11-dstuf,
        g_posnr TO ls_mat_bom_cs11-posnr,
        ls_mat_bom_cs03_a-obtsp TO ls_mat_bom_cs11-objic,
        l_menge TO ls_mat_bom_cs11-mngko,
        l_meins TO ls_mat_bom_cs11-meins,
        l_stlkz TO ls_mat_bom_cs11-bomfl,
        l_ktext TO ls_mat_bom_cs11-ojtxp.
  CASE l_obtsp.
    WHEN '1'.
      MOVE l_matnr TO ls_mat_bom_cs11-dobjt.
    WHEN '3'.
      CONCATENATE  l_doknr object_keyfields-dokar
                   object_keyfields-doktl object_keyfields-dokvr
                   INTO ls_mat_bom_cs11-dobjt.
  ENDCASE.
  MOVE-CORRESPONDING ls_mat_bom_cs11 TO ls_mat_bom_cs12.
  MOVE-CORRESPONDING ls_mat_bom_cs11 TO ls_mat_bom_cs13.

  CASE gs_bom_print-bomtype.
    WHEN 'CS03'.
      CASE gs_bom_print-bomausp.
        WHEN 'A'.
          CALL FUNCTION 'ITM_BOMOB_PROVIDE'
               EXPORTING
                    i_objty = l_obtsp
                    i_idnrk = l_matnr
                    i_dokar = object_keyfields-dokar
                    i_doknr = object_keyfields-doknr
                    i_doktl = object_keyfields-doktl
                    i_dokvr = object_keyfields-dokvr
               IMPORTING
                    e_bomob = ls_mat_bom_cs03_a-bomob.

          CLEAR index.
          index = wa_selected_rows-index + 1.
          INSERT ls_mat_bom_cs03_a INTO <mat_bom> INDEX index.
        WHEN 'D'.
          ls_mat_bom_cs03_d-doknr = object_keyfields-doknr.
          ls_mat_bom_cs03_d-dokar = object_keyfields-dokar.
          ls_mat_bom_cs03_d-doktl = object_keyfields-doktl.
          ls_mat_bom_cs03_d-dokvr = object_keyfields-dokvr.
          CLEAR index.
          index = wa_selected_rows-index + 1.
          INSERT ls_mat_bom_cs03_d INTO <mat_bom> INDEX index.
        WHEN 'M'.
          ls_mat_bom_cs03_m-idnrk = l_matnr.
          CLEAR index.
          index = wa_selected_rows-index + 1.
          INSERT ls_mat_bom_cs03_m INTO <mat_bom> INDEX index.

      ENDCASE.
    WHEN 'CS11'.
      CLEAR index.
      index = wa_selected_rows-index + 1.
      INSERT ls_mat_bom_cs11 INTO <mat_bom> INDEX index.

    WHEN 'CS12'.
      ls_mat_bom_cs12-dglvl = g_stufe.
      CLEAR index.
      index = wa_selected_rows-index + 1.
      INSERT ls_mat_bom_cs12 INTO <mat_bom> INDEX index.

    WHEN 'CS13'.
      CLEAR index.
      index = wa_selected_rows-index + 1.
      INSERT ls_mat_bom_cs13 INTO <mat_bom> INDEX index.

    WHEN OTHERS.
  ENDCASE.

  REFRESH it_selected_rows.
  wa_selected_rows-index = wa_selected_rows-index + 1.
  APPEND wa_selected_rows TO it_selected_rows.


ENDFORM.                    " insert_mat_bom
