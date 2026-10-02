FUNCTION z_cl_update_skel_clf_lines.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_UNAME) TYPE  XUBNAME
*"             VALUE(I_FILENAME) TYPE  FILEP
*"       EXCEPTIONS
*"              ERROR
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
  DATA: itab_skel_lines TYPE TABLE OF zcl_skel_clf_lin.
*WA
  DATA: wa_skel_lines LIKE zcl_skel_clf_lin.
  DATA: wa_data_tab TYPE t_data_tab.
*NORMAL
  DATA: numc(3)  TYPE n.
  DATA: f_cancel(1).


  CLEAR f_cancel.
  tmp_filename = i_filename.

  user_name = i_uname.

  CALL FUNCTION 'Z_CL_CHECK_FOR_UNAME'
    EXPORTING
      i_uname = user_name
    IMPORTING
      o_uname = user_name
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

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
      '' 'Z_CL_READ_SKELETON' RAISING error.
  ENDIF.

  TRANSLATE f_cancel TO UPPER CASE.
  IF f_cancel = 'X'.
    EXIT.
  ELSE.
  ENDIF.

  IF data_tab[] IS INITIAL.
    MESSAGE i062(zcl_plint_tools)
      WITH tmp_filename ''
      '' 'Z_CL_UPDATE_SKEL_CLF' RAISING error.
  ELSE.
  ENDIF.

* Tabelle saubermachen
  SELECT SINGLE * FROM zcl_skel_clf_lin
    INTO wa_skel_lines
    WHERE nutzer = user_name.
  IF sy-subrc NE 0.
  ELSE.
    DELETE FROM zcl_skel_clf_lin
      WHERE nutzer = user_name
      .
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      RAISE error.
    ELSE.
    ENDIF.

  ENDIF.

  REFRESH itab_skel_lines.
  CLEAR wa_skel_lines.
  CLEAR numc.
  LOOP AT data_tab INTO wa_data_tab.
    CLEAR wa_skel_lines.
    wa_skel_lines-nutzer = user_name.
    wa_skel_lines-counter = numc.
    wa_skel_lines-line = wa_data_tab-line.
    wa_skel_lines-zclinsname = sy-uname.
    wa_skel_lines-zclinsdate = sy-datum.
    wa_skel_lines-zclinstime = sy-uzeit.
    wa_skel_lines-zclinsprog = sy-repid.
    wa_skel_lines-zclupdname = sy-uname.
    wa_skel_lines-zclupddate = sy-datum.
    wa_skel_lines-zclupdtime = sy-uzeit.
    wa_skel_lines-zclupdprog = sy-repid.

    INSERT INTO zcl_skel_clf_lin
      VALUES wa_skel_lines.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      RAISE error.
    ELSE.
    ENDIF.


    numc = numc + 1.
  ENDLOOP.

  COMMIT WORK.
  MESSAGE i059(zcl_plint_tools) WITH '' '' '' ''.
ENDFUNCTION.
