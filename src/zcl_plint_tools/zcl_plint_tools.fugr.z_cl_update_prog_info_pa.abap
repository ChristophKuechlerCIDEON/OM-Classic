FUNCTION z_cl_update_prog_info_pa.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP
*"     VALUE(I_LANGU) TYPE  LANGU DEFAULT 'D'
*"     VALUE(I_TCODE) TYPE  TCODE
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------
  TYPES:
   BEGIN OF t_data_tab,
     line(255),
   END OF t_data_tab.


  DATA: tmp_filename TYPE rlgrap-filename.
*ITAB
  DATA: data_tab TYPE TABLE OF t_data_tab.
*WA
  DATA: wa_data_tab TYPE t_data_tab.
*NORMAL
  DATA: numc(3)  TYPE n.
  DATA: f_cancel(1).


  CLEAR f_cancel.
  tmp_filename = i_filename.


  tmp_string = i_filename.
  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'UPLOAD'.

  CALL FUNCTION lc_fname

"CALL FUNCTION 'UPLOAD'
EXPORTING
*     CODEPAGE                      = ' '
 filename                      = tmp_filename
*     FILETYPE                      = ' '
*     ITEM                          = ' '
*     FILEMASK_MASK                 = ' '
*     FILEMASK_TEXT                 = ' '
*     FILETYPE_NO_CHANGE            = ' '
*     FILEMASK_ALL                  = ' '
*     FILETYPE_NO_SHOW              = ' '
*     LINE_EXIT                     = ' '
*     USER_FORM                     = ' '
*     USER_PROG                     = ' '
*     SILENT                        = 'S'
IMPORTING
*     FILESIZE                      =
 cancel                        = f_cancel
*     ACT_FILENAME                  =
*     ACT_FILETYPE                  =
TABLES
  data_tab                      = data_tab
EXCEPTIONS
 conversion_error              = 1
 invalid_table_width           = 2
 invalid_type                  = 3
 no_batch                      = 4
 unknown_error                 = 5
 gui_refuse_filetransfer       = 6
 OTHERS                        = 7
        .
  IF sy-subrc <> 0.
    MESSAGE i050(zcl_plint_tools)
      WITH tmp_filename ''
      '' 'Z_CL_UPDATE_PROG_INFO' RAISING error.
  ENDIF.

  TRANSLATE f_cancel TO UPPER CASE.
  IF f_cancel = 'X'.
    MESSAGE i067(zcl_plint_tools) WITH
      '' '' '' '' RAISING error.
    EXIT.
  ELSE.
  ENDIF.

  IF data_tab[] IS INITIAL.
    MESSAGE i062(zcl_plint_tools)
      WITH tmp_filename ''
      'Z_CL_UPDATE_PROG_INFO' '' RAISING error.
  ELSE.
  ENDIF.

* Tabelle saubermachen
  SELECT SINGLE * FROM zcl_prog_info_pa
    INTO wa_prog_info_pa
    WHERE tcode = i_tcode
    AND langu = i_langu
    .
  IF sy-subrc NE 0.
  ELSE.
    DELETE FROM zcl_prog_info_pa
     WHERE tcode = i_tcode
     AND langu = i_langu
      .
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      RAISE error.
    ELSE.
    ENDIF.

  ENDIF.

  CLEAR numc.
  LOOP AT data_tab INTO wa_data_tab.
    CLEAR wa_prog_info_pa.
    wa_prog_info_pa-tcode = i_tcode.
    wa_prog_info_pa-langu = i_langu.
    wa_prog_info_pa-counter = numc.
    wa_prog_info_pa-line = wa_data_tab-line.
    wa_prog_info_pa-zclinsname = sy-uname.
    wa_prog_info_pa-zclinsdate = sy-datum.
    wa_prog_info_pa-zclinstime = sy-uzeit.
    wa_prog_info_pa-zclinsprog = sy-repid.
    wa_prog_info_pa-zclupdname = sy-uname.
    wa_prog_info_pa-zclupddate = sy-datum.
    wa_prog_info_pa-zclupdtime = sy-uzeit.
    wa_prog_info_pa-zclupdprog = sy-repid.

    INSERT INTO zcl_prog_info_pa
      VALUES wa_prog_info_pa.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      RAISE error.
    ELSE.
    ENDIF.


    numc = numc + 1.
  ENDLOOP.

  COMMIT WORK.
  MESSAGE i064(zcl_plint_tools) WITH '' '' '' ''.
ENDFUNCTION.
