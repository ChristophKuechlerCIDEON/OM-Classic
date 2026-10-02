*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LCDESK_MAT_BOM2F01 .
*----------------------------------------------------------------------*
**&---------------------------------------------------------------------
**
*&      Form  assign_break_point
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM assign_break_point.

  ASSIGN ('(SAPLCDESK)GF_debug') TO <break_point>.
  IF sy-subrc = 0.
    IF <break_point> IS ASSIGNED.
      IF <break_point> = 'X'.
        gf_debug = 'X'.
      ELSE.
        gf_debug = space.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " assign_break_point
*&---------------------------------------------------------------------*
*&      Form  clear_global_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_data.

  CLEAR:
  formname,
  fm_name,
  gs_head_mat,
  return,
  g_head_matnr,
  g_plant,
  g_usage,
  g_alternative,
  g_capid,
  g_changeno,
  gt_head_mat,
  gs_head_mat,
  gt_mat_bom,
  gt_mat_bom_cs03_a,
  gt_mat_bom_cs03_d,
  gt_mat_bom_cs03_m,
  gt_mat_bom_cs11,
  gt_mat_bom_cs12,
  gt_mat_bom_cs13,
  gt_head_mat_dir,
  gt_posi_mat_dir,
  gf_debug,
  hd_tab,
  dref,
  dfies_tab,
  gs_fields,
  gt_fields,
  g_menge,
  g_meins,
  g_stpst,
  g_datuv,
  g_bomtype.

  REFRESH hd_tab.

ENDFORM.                    " clear_global_data
*&---------------------------------------------------------------------*
*&      Form  unassign_field_symbols
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unassign_field_symbols.

  UNASSIGN: <break_point>, <changeno>,
            <mat_bom>, <wa>.

ENDFORM.                    " unassign_field_symbols
