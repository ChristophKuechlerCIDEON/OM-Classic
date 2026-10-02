*&---------------------------------------------------------------------*
*& Report  ZCL_LOCAL_FILE_SELECT                                       *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_local_file_select         .


TABLES rlgrap.

DATA: i_tab TYPE filetable,
      vg_subrc TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK backdrop WITH FRAME TITLE text-001.
SELECT-OPTIONS so_fpath FOR rlgrap-filename.
SELECTION-SCREEN END OF BLOCK backdrop.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_fpath-low.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
          window_title = 'Select File'
          default_filename = '*.ppl'
          multiselection = ''
      CHANGING
          file_table = i_tab
          rc = vg_subrc.

  LOOP AT i_tab INTO so_fpath-low.
      so_fpath-sign = 'I'.
    so_fpath-option = 'EQ'.
    APPEND so_fpath.
  ENDLOOP.
