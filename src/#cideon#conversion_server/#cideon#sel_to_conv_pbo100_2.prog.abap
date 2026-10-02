*----------------------------------------------------------------------*
***INCLUDE /CIDEON/SEL_TO_MIGRATE_PBO100 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100' WITH anzahl_ergebnisse '' '' ''.

  IF alv_ergebnisse IS INITIAL.
    CREATE OBJECT custom_control_alv
      EXPORTING container_name = 'CUSTOM_CONTROL_ALV'.
    IF sy-subrc <> 0.
    ENDIF.

    CREATE OBJECT   alv_ergebnisse
      EXPORTING i_parent = custom_control_alv
      .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    CLEAR gs_layout_searchlist.
    gs_layout_searchlist-report = sy-repid.
    gs_layout_searchlist-username = sy-uname.

    CALL METHOD alv_ergebnisse->set_table_for_first_display
      EXPORTING
        i_structure_name              = 'DRAW'
        is_variant                    = gs_layout_searchlist
*        is_layout                   = g_layo_grid_searchlist
        i_save                        = x_save_searchlist
        i_default                     = 'X'
*        it_toolbar_excluding          = itab_tb_ex_searchlist
      CHANGING
        it_outtab                     = itab_ptx_draw
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
* nicht in 4.6b enthalten
*        too_many_lines                = 3
        OTHERS                        = 4
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD alv_ergebnisse->get_frontend_layout
      IMPORTING
        es_layout = g_layo_alv_ergebnisse
        .
    g_layo_alv_ergebnisse-sel_mode = 'A'.

    CALL METHOD alv_ergebnisse->set_frontend_layout
      EXPORTING
        is_layout = g_layo_alv_ergebnisse
        .
    CALL METHOD alv_ergebnisse->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
* nicht in 4.6b enthalten
*      EXCEPTIONS
*        finished       = 1
*        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    SET HANDLER
      alv_handler->catch_dblclick FOR alv_ergebnisse.

  ELSE.
  ENDIF.



ENDMODULE.                 " STATUS_0100  OUTPUT
