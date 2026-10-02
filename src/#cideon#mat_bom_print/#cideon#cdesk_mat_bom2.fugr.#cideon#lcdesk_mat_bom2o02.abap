*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LCDESK_MAT_BOM2O02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_control_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_control_100 OUTPUT.

* wenn objekt noch nicht angelegt, dann create.
  IF ref_container IS INITIAL.

    g_repid = sy-repid.

    CREATE OBJECT ref_container
    EXPORTING
      repid = g_repid
      dynnr = '100'
      extension   = 800
      side  = cl_gui_docking_container=>dock_at_top.


    CREATE OBJECT ref_alv
      EXPORTING
        i_parent          = ref_container.

* set layout
* mark column
    wa_s_layo-sel_mode   = 'A'.
    wa_s_layo-zebra      = abap_true.
    wa_s_layo-cwidth_opt = abap_true.

* variant
    wa_s_variant-report = sy-repid.

* field catalog
    PERFORM set_field_catalog.
    PERFORM set_grid_toolbar CHANGING itab_tb_ex_searchlist.

    CALL METHOD ref_alv->set_table_for_first_display
       EXPORTING
         i_structure_name     = tabname
         is_layout            = wa_s_layo
         is_variant           = wa_s_variant
         i_save               = co_variant_both
         i_default            = abap_true
         it_toolbar_excluding = itab_tb_ex_searchlist
      CHANGING
        it_outtab             = <mat_bom>
        it_fieldcatalog       = it_field_cat.

    SET HANDLER lcl_event_handler=>on_double_click FOR ref_alv.
    CALL METHOD ref_alv->set_toolbar_interactive.

    CALL METHOD cl_gui_control=>set_focus
                EXPORTING control = ref_alv.
    CALL METHOD cl_gui_cfw=>flush.

  ELSE.

    CALL METHOD ref_alv->get_frontend_layout
       IMPORTING
         es_layout = wa_s_layo .
    wa_s_layo-cwidth_opt = abap_true.

    CALL METHOD ref_alv->set_frontend_layout
      EXPORTING
        is_layout = wa_s_layo .

    CALL METHOD ref_alv->refresh_table_display.
    IF it_selected_rows IS INITIAL.
      wa_selected_rows-index = 1.
      APPEND wa_selected_rows TO it_selected_rows.
    ENDIF.
    CALL METHOD ref_alv->set_selected_rows
          EXPORTING
            it_index_rows = it_selected_rows.

  ENDIF.

ENDMODULE.                 " init_control_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0201  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_0201 OUTPUT.

  CLEAR: stack_available.

  READ TABLE usrobjstack WITH KEY bname       = syst-uname
                                  object_type = material.

  IF syst-subrc EQ 0.
    MOVE: cross TO stack_available.
  ENDIF.

  LOOP AT SCREEN.
    CHECK screen-name EQ 'SHOW_STACK'.

    IF stack_available IS INITIAL.
* Deactivate the SHOW_STACK button if there is no stack available
      MOVE: 1 TO screen-invisible.
    ELSE.
* Activate the SHOW_STACK button if there is a stack available
      MOVE: 0 TO screen-invisible.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'STPOX-STUFE'.
        CASE gs_bom_print-bomtype.
          WHEN 'CS11'.
            MOVE: 0 TO screen-invisible.
          WHEN OTHERS.
            MOVE: 1 TO screen-invisible.
            MOVE: 0 TO screen-input.
            MOVE: 0 TO screen-output.
            MOVE: 0 TO screen-active.
        ENDCASE.
        MODIFY SCREEN.
      WHEN 'STPOX-POSNR'.
        CASE gs_bom_print-bomtype.
          WHEN 'CS13'.
            MOVE: 1 TO screen-invisible.
            MOVE: 0 TO screen-input.
            MOVE: 0 TO screen-output.
            MOVE: 0 TO screen-active.
          WHEN OTHERS.
            MOVE: 0 TO screen-invisible.
        ENDCASE.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_0201  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  initialize_objstack  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize_objstack OUTPUT.

  CHECK NOT ( init_stack IS INITIAL ).

  CLEAR: init_stack.

  CLEAR: usrobjstack. REFRESH usrobjstack.

* Fill the internal stack table
  SELECT * FROM usrobjects INTO TABLE usrobjstack
     WHERE bname EQ syst-uname.

  SORT usrobjstack BY bname object_type counter ASCENDING.

ENDMODULE.                 " initialize_objstack  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0202  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_0202 OUTPUT.

  CLEAR: stack_available.

  READ TABLE usrobjstack WITH KEY bname       = syst-uname
                                  object_type = document.

  IF syst-subrc EQ 0.
    MOVE: cross TO stack_available.
  ENDIF.

  LOOP AT SCREEN.
    CHECK screen-name EQ 'SHOW_STACK'.

    IF stack_available IS INITIAL.
* Deactivate the SHOW_STACK button if there is no stack available
      MOVE: 1 TO screen-invisible.
    ELSE.
* Activate the SHOW_STACK button if there is a stack available
      MOVE: 0 TO screen-invisible.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'STPOX-STUFE'.
        CASE gs_bom_print-bomtype.
          WHEN 'CS11'.
            MOVE: 0 TO screen-invisible.
          WHEN OTHERS.
            MOVE: 1 TO screen-invisible.
            MOVE: 0 TO screen-input.
            MOVE: 0 TO screen-output.
            MOVE: 0 TO screen-active.
        ENDCASE.
        MODIFY SCREEN.
      WHEN 'STPOX-POSNR'.
        CASE gs_bom_print-bomtype.
          WHEN 'CS13'.
            MOVE: 1 TO screen-invisible.
            MOVE: 0 TO screen-input.
            MOVE: 0 TO screen-output.
            MOVE: 0 TO screen-active.
          WHEN OTHERS.
            MOVE: 0 TO screen-invisible.
        ENDCASE.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_0202  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_FOCUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_focus OUTPUT.

  CASE browser_tab_strip-activetab.
    WHEN 'FCDOC'.
      SET CURSOR FIELD 'DRAW-DOKNR'.

    WHEN 'FCMAT'.
      SET CURSOR FIELD 'MARA-MATNR'.

  ENDCASE.

ENDMODULE.                 " SET_SCREEN_FOCUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_position  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_position OUTPUT.

  MOVE '99' TO stpox-stufe.
  MOVE 'ZPOS' TO stpox-posnr.

ENDMODULE.                 " set_position  OUTPUT
