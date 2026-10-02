*&---------------------------------------------------------------------*
*&      Form  create_and_init_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_and_init_plotlist.
* Plotliste erstellen

  IF grid_plotlist IS INITIAL.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR g_layo_grid_plotlist.
  CLEAR gs_layout_plotlist.
  gs_layout_plotlist-report = sy-repid.

  IF user_data-plot_alv_var IS INITIAL.
  ELSE.
    MOVE user_data-plot_alv_var  TO gs_layout_plotlist-variant.
    MOVE sy-repid TO gs_layout_plotlist-report.

    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
         EXPORTING
              i_save        = 'X'
         CHANGING
              cs_variant    = gs_layout_plotlist
         EXCEPTIONS
              wrong_input   = 1
              not_found     = 2
              program_error = 3
              OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.


  IF user_data-knz_alv_patch = 'X'.
    CLEAR gs_layout_plotlist-variant.
  ELSE.
  ENDIF.


  CREATE OBJECT container_grid_plotlist
    EXPORTING container_name = 'CONTAINER_GRID_PLOTLIST'.

*   fill the EXCLUDE-Table
  CLEAR itab_tb_ex_plotlist.
  REFRESH itab_tb_ex_plotlist.
  "CKR 2008/12/05
  DATA: ls_ex TYPE ui_func.
  CLEAR ls_ex.

  ls_ex = '&AUBTOT'.
  APPEND ls_ex TO itab_tb_ex_plotlist.

  ls_ex = '&AUF'.
  APPEND ls_ex TO itab_tb_ex_plotlist.

  ls_ex = '&INFO'.
  APPEND ls_ex TO itab_tb_ex_plotlist.

  ls_ex = '&MB_SUM'.
  APPEND ls_ex TO itab_tb_ex_plotlist.

  ls_ex = '&SUM'.
  APPEND ls_ex TO itab_tb_ex_plotlist.

  ls_ex = '&GRAPH'.
  APPEND ls_ex TO itab_tb_ex_plotlist.


  " 2010/06/16 CKR
  DATA: exit TYPE REF TO /cideon/if_ex_pre_main_001.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = exit.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF exit IS INITIAL.
  ELSE.
    "
    CALL METHOD exit->chg_pl_excl_bt
       CHANGING
         it_bt_ex = itab_tb_ex_plotlist
        .

  ENDIF.


*  SELECT exclude_fc FROM zcl_plint_excalv
*    INTO TABLE itab_tb_ex_plotlist
*    WHERE uname = sy-uname
*    AND alvname = 'GRID_PLOTLIST'
*    .
*  IF sy-subrc NE 0.
*  ELSE.
*  ENDIF.
*
*  IF itab_tb_ex_plotlist[] IS INITIAL.
*    SELECT exclude_fc FROM zcl_plint_excalv
*      INTO TABLE itab_tb_ex_plotlist
*      WHERE uname = default_data-default_nutzer
*      AND alvname = 'GRID_PLOTLIST'
*      .
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

  CREATE OBJECT   grid_plotlist
    EXPORTING i_parent = container_grid_plotlist.

  g_layo_grid_plotlist-sel_mode = 'A'.
  g_layo_grid_plotlist-excp_fname = 'LIGHT'.
  g_layo_grid_plotlist-excp_led = 'X'.


  CALL METHOD grid_plotlist->set_table_for_first_display
    EXPORTING
      i_structure_name              = 'ZCL_S_PLOTLIST'
*        i_structure_name              = 'ZORI_DOC_FILES'
      is_variant                    = gs_layout_plotlist
      i_save                        = x_save_plotlist
      i_default                     = ''
      is_layout                     = g_layo_grid_plotlist
      it_toolbar_excluding          = itab_tb_ex_plotlist
    CHANGING
      it_outtab                     = itab_plotjobs
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CLEAR g_fc_grid_plotlist.
  CALL METHOD grid_plotlist->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = g_fc_grid_plotlist
      .
  LOOP AT g_fc_grid_plotlist INTO wa_fc_grid_plotlist.
    IF wa_fc_grid_plotlist-fieldname = 'ICON_FEHLBLATT'.
      wa_fc_grid_plotlist-icon = 'X'.
      MODIFY g_fc_grid_plotlist FROM wa_fc_grid_plotlist
        INDEX sy-tabix.
    ELSE.
    ENDIF.

    IF wa_fc_grid_plotlist-fieldname = 'ICON_DISPLAY'.
      wa_fc_grid_plotlist-icon = 'X'.
      wa_fc_grid_plotlist-hotspot = 'X'.
      MODIFY g_fc_grid_plotlist FROM wa_fc_grid_plotlist
        INDEX sy-tabix.
    ELSE.
    ENDIF.

    IF wa_fc_grid_plotlist-fieldname = 'ICON_DISPLAY_DIS'.
      wa_fc_grid_plotlist-icon = 'X'.
      wa_fc_grid_plotlist-hotspot = 'X'.
      MODIFY g_fc_grid_plotlist FROM wa_fc_grid_plotlist
        INDEX sy-tabix.
    ELSE.
    ENDIF.

  ENDLOOP.
  CALL METHOD grid_plotlist->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = g_fc_grid_plotlist
      .
  CALL METHOD grid_plotlist->refresh_table_display
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

  SET HANDLER
    plot_handler->catch_dblclick FOR grid_plotlist.
  SET HANDLER
    plot_handler->handle_toolbar FOR grid_plotlist.
  SET HANDLER
    plot_handler->handle_user_command FOR grid_plotlist.
  SET HANDLER
    plot_handler->handle_context_menu FOR grid_plotlist.

  SET HANDLER
    plot_handler->handle_after_user_command FOR grid_plotlist.

  SET HANDLER
    plot_handler->handle_hotspot_click FOR grid_plotlist.

  CALL METHOD grid_plotlist->set_toolbar_interactive.

ENDFORM.                    " create_and_init_plotlist
