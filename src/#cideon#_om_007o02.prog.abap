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

    "CKR
    " 2009/03/02
    IF f_bypass_to_plotlist = 'X'.
      IF user_data-modus = 'NORMAL'.
        SET PF-STATUS 'ZCL_PF_PLD_007_02_N'.

*    IF badi_main_pre_001 IS INITIAL.
*    ELSE.
*      CALL METHOD badi_main_pre_001->status_change
*        EXPORTING
*          status = 'ZCL_PF_PLD_007_02_N'
*          .
*    ENDIF.

      ELSE.
        SET PF-STATUS 'ZCL_PF_PLD_007_02'.

*    IF badi_main_pre_001 IS INITIAL.
*    ELSE.
*      CALL METHOD badi_main_pre_001->status_change
*        EXPORTING
*          status = 'ZCL_PF_PLD_007_02'
*          .
*    ENDIF.

      ENDIF.
    ELSE.
    ENDIF.



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

    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
    f_bypass = ''.

    " 2009/01/27
    " nur alles Durchlaufen, falls f_bypass_to_plotlist
    " nicht gesetzt ist.

    IF f_bypass_to_plotlist = 'X'.
      "Setzen des Tab
      tabstripcontrol_001-activetab = 'TAB2'.
      f_alv_plotlist = 'X'.
    ELSE.
      PERFORM send.

      COMMIT WORK AND WAIT.
      LEAVE PROGRAM.
    ENDIF.

    CLEAR f_bypass_to_plotlist.


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
  CLEAR gs_layout_sdlist.
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
*&---------------------------------------------------------------------*
*&      Module  bypass2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE bypass2 OUTPUT.
* direkter Sprung in die Plotliste ohne Suchliste

  IF sy-uname = 'KUECHLER'.
    "f_pl_from_log = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF f_pl_from_log = 'X'.
    IF user_data-modus = 'NORMAL'.
      SET PF-STATUS 'ZCL_PF_PLD_007_02_N'.
    ELSE.
      SET PF-STATUS 'ZCL_PF_PLD_007_02'.
    ENDIF.

    "itab_plotjobs setzen
    DATA: lt_log TYPE TABLE OF /cideon/pl_log.
    DATA: ls_log TYPE /cideon/pl_log.

    CLEAR lt_log.
    SELECT * FROM /cideon/pl_log INTO TABLE lt_log
      WHERE zclinsdate = sy-datum
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    LOOP AT lt_log INTO ls_log.
      CLEAR wa_plotjobs.
      MOVE-CORRESPONDING ls_log TO wa_plotjobs.

      wa_plotjobs-id_ref = ls_log-id.
      wa_plotjobs-id_plotjob_ref = ls_log-id_plotjob.
      wa_plotjobs-id_plotjob_32_re = ls_log-id_plotjob_32.

      APPEND wa_plotjobs TO itab_plotjobs.
    ENDLOOP.

    PERFORM create_and_init_tree.
    PERFORM create_and_init_plotlist.

    "Setzen des Tab
    tabstripcontrol_001-activetab = 'TAB2'.
    f_alv_plotlist = 'X'.

  ELSE.
  ENDIF.

  CLEAR f_pl_from_log.


  PERFORM check_exist_files_2.

  "PERFORM set_knz_use_checked_in.
  PERFORM set_knz_use_checked_in_2.

                                                            " SP 127
  " DATEI Größe holen
  PERFORM pl_set_file_size.

  PERFORM reindex_table_2.

* Kundendaten anfügen
  PERFORM add_client_data_4.
* Kostenstelle einfügen
  PERFORM add_cost_center_3.

  "Plotliste auf Dupplikate durchsuchen
  PERFORM clear_pl_doubles.

  PERFORM clear_plot_details.

  PERFORM refresh_joblist.
  PERFORM rebuild_tree_plotlist.



ENDMODULE.                 " bypass2  OUTPUT
