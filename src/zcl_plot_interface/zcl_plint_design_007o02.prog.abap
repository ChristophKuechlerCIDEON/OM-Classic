*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007O02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  BYPASS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE bypass OUTPUT.
* BYPASS Operationen für automatischen Durchlauf durch PlotInterface

* alles in Suchliste selektieren

  IF f_bypass = 'X'.
*   24.03.2006 CKR
*   beim Beipaß TREE und ALV erstellen lassen

    IF simple_tree_plotlist IS INITIAL.
      PERFORM create_and_init_tree.
    ELSE.
    ENDIF.

    IF grid_plotlist IS INITIAL.
      PERFORM create_and_init_plotlist.
    ELSE.
    ENDIF.


    PERFORM sel_all_search_list.
    PERFORM to_joblist.
    PERFORM sel_all_plot_list.
    PERFORM send.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
    f_bypass = ''.
    COMMIT WORK AND WAIT.
    LEAVE PROGRAM.
  ELSE.
  ENDIF.

ENDMODULE.                 " BYPASS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cb_0127  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cb_0127 OUTPUT.

ENDMODULE.                 " set_cb_0127  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0127  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0127 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  PERFORM set_scr_attr_vbeln.

* ALV Erstellen

  IF grid_sdpartner IS INITIAL.
  ELSE.
    EXIT.
  ENDIF.


  CREATE OBJECT cc_sdpartner
      EXPORTING container_name = 'CC_SDPARTNER'.

  CREATE OBJECT   grid_sdpartner
    EXPORTING i_parent = cc_sdpartner.

*   Variant
    clear gs_layout_sdlist.
    gs_layout_sdlist-report = '0127'."sy-repid.
    gs_layout_sdlist-username = sy-uname.


  CALL METHOD grid_sdpartner->set_table_for_first_display
    EXPORTING
      i_structure_name              =  '/CIDEON/SDPARTNER'
"'SDPARTNERLIST'
*        i_structure_name              = 'ZORI_DOC_FILES'
      is_variant                    = gs_layout_sdlist
      i_save                        = x_save_sdlist
      i_default                     = 'X'
*      is_layout                     = g_layo_grid_plotlist
*      it_toolbar_excluding          = itab_tb_ex_plotlist
    CHANGING
      it_outtab                     = it_sdpartner
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


ENDMODULE.                 " STATUS_0127  OUTPUT
