*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLOT_FERTIGUNGSAUFTRAG_O01                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
* get INI Values for USer
  IF g_init <> 'X'.
* Berechtigungscheck
    AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '16'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc > 0.
      MESSAGE s099(zcl_plint_tools)
        WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
      LEAVE PROGRAM.
    ELSE.
    ENDIF.

*   Checkboxvorbelegung
    wa_fertigung-knz_dok_link = 'X'.
    wa_fertigung-knz_mat_link = 'X'.
    wa_fertigung-knz_stl_aufl = 'X'.

    g_init = 'X'.

  ENDIF.

  SET PF-STATUS 'PF_FERTIGUNG'.
  SET TITLEBAR 'TB_FERTIGUNG'.

  CLEAR g_exit.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb OUTPUT.
*  cb_knz_sofort_plotten = wa_fertigung-knz_sofort_plotten.
*  cb_knz_dok_link = wa_fertigung-knz_dok_link.
*  cb_knz_mat_link = wa_fertigung-knz_mat_link.
*  cb_knz_txt_link = wa_fertigung-knz_txt_link.
*  cb_knz_aufpl_vorgaenge = wa_fertigung-knz_aufpl_vorgaenge.
*  cb_knz_aufpl_folgen = wa_fertigung-knz_aufpl_folgen.
*
*  cb_knz_stl_aufl = wa_fertigung-knz_stl_aufl.
*
*  cb_knz_dok_stl_aufl = wa_fertigung-knz_dok_stl_aufl.
*  cb_knz_dok_link_aufl = wa_fertigung-knz_dok_link_aufl.
*  cb_knz_dok_hier_aufl = wa_fertigung-knz_dok_hier_aufl.
*
*  cb_knz_dok_stl_aufl_mehrst =
*    wa_fertigung-knz_dok_stl_aufl_mehrst.
*  cb_knz_dok_link_aufl_mehrst =
*    wa_fertigung-knz_dok_link_aufl_mehrst.
*  cb_knz_dok_hier_aufl_mehrst =
*    wa_fertigung-knz_dok_hier_aufl_mehrst.

ENDMODULE.                 " SET_CB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF_200'.
  SET TITLEBAR 'T_200'.

  IF alv_drad IS INITIAL.
    CREATE OBJECT container_alv_drad
      EXPORTING container_name = 'CC_ALV_DRAD'.
    IF sy-subrc <> 0.
    ELSE.
      CREATE OBJECT   alv_drad
      EXPORTING i_parent = container_alv_drad
        .
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      g_layo_alv_drad-sel_mode = 'A'.

      CALL METHOD alv_drad->set_table_for_first_display
        EXPORTING
          i_structure_name              = 'ZCL_S_DRAD'
*          is_variant                    = gs_layout_searchlist
          is_layout                     = g_layo_alv_drad
*          i_save                        = x_save_searchlist
          i_default                     = ''
*          it_toolbar_excluding          = itab_tb_ex_searchlist
        CHANGING
          it_outtab                     = itab_drad
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
    ENDIF.
  ELSE.
    CALL METHOD alv_drad->refresh_table_display
*      EXPORTING
*        IS_STABLE      =
*        I_SOFT_REFRESH =
*      EXCEPTIONS
*        FINISHED       = 1
*        others         = 2
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_101 OUTPUT.
  cb_knz_sofort_plotten = wa_fertigung-knz_sofort_plotten.
  cb_knz_no_bypass = wa_fertigung-knz_no_bypass.
  cb_knz_dok_link = wa_fertigung-knz_dok_link.
  cb_knz_mat_link = wa_fertigung-knz_mat_link.
  cb_knz_txt_link = wa_fertigung-knz_txt_link.
ENDMODULE.                 " set_cb_101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_102 OUTPUT.
  cb_knz_stl_aufl = wa_fertigung-knz_stl_aufl.
ENDMODULE.                 " set_cb_102  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_103 OUTPUT.
  cb_knz_dok_stl_aufl = wa_fertigung-knz_dok_stl_aufl.
  cb_knz_dok_link_aufl = wa_fertigung-knz_dok_link_aufl.
  cb_knz_dok_hier_aufl = wa_fertigung-knz_dok_hier_aufl.

  cb_knz_dok_stl_aufl_mehrst =
    wa_fertigung-knz_dok_stl_aufl_mehrst.
  cb_knz_dok_link_aufl_mehrst =
    wa_fertigung-knz_dok_link_aufl_mehrst.
  cb_knz_dok_hier_aufl_mehrst =
    wa_fertigung-knz_dok_hier_aufl_mehrst.
ENDMODULE.                 " set_cb_103  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_104  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_104 OUTPUT.
  cb_knz_aufpl_vorgaenge = wa_fertigung-knz_aufpl_vorgaenge.
  cb_knz_aufpl_folgen = wa_fertigung-knz_aufpl_folgen.
ENDMODULE.                 " set_cb_104  OUTPUT
