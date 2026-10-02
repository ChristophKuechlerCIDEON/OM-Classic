*----------------------------------------------------------------------*
*   INCLUDE ZCK_MAINT_ZCL_USR_GRP_KL_PAI                               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'OK'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'REFRESH'.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'PLOT'.
      PERFORM get_sel_items.
      PERFORM get_sel_jobs.
      PERFORM set_sel_job_items.
      PERFORM send_plot_items.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'DEL_ITEM'.
      PERFORM get_sel_items.
      PERFORM delete_item.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'DEL_JOB'.
      PERFORM get_sel_items.
      PERFORM delete_job.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'HOT_SPOT_CLICK_DISPLAY_DIS'.
      PERFORM view_dis.

    WHEN 'HOT_SPOT_CLICK_DISPLAY'.
      "Original anzeigen
      PERFORM view_dis_original.


    WHEN 'CHG_FAIL_B'.
      PERFORM get_sel_items.
      PERFORM change_fehl_blatt.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'CREA_DIS'.
*     DIS erstellen
      PERFORM get_sel_items.
      PERFORM create_dis.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'RELATE_DIS'.
*     DIS zuordnen
      PERFORM get_sel_items.
      PERFORM relate_dis.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'CHG_PA'.
*     Original zuordnen
      PERFORM get_sel_items.
      PERFORM relate_original_pl_ohne_dis.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'KNZ_AUTO_PROC_ON'.
      PERFORM get_sel_items.
      PERFORM set_knz_auto_process USING 'X'.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'KNZ_AUTO_PROC_OFF'.
      PERFORM get_sel_items.
      PERFORM set_knz_auto_process USING ''.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'DWNL_LOCAL'.
      PERFORM get_sel_items.
      PERFORM download_to_local.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN 'STR_KONV'.
      PERFORM get_sel_items.
      PERFORM start_converting.
      PERFORM reload_alv.
      PERFORM refresh_alv.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0100  INPUT
