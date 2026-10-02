FUNCTION z_cl_read_ini_aoformats.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME
*"     VALUE(I_FILENAME) TYPE  FILEP
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

*ITAB
  DATA: itab_format_werte TYPE TABLE OF zcl_format_werte.
  DATA: itab_paper_format TYPE TABLE OF zcl_format_types.
  "zcl_paper_format.
*WA
  DATA: wa_format_werte TYPE zcl_format_werte.
  DATA: wa_paper_format TYPE zcl_paper_format.
*NORMAL
  DATA: tmp_filename TYPE rlgrap-filename.
  DATA: itab_index TYPE i.
  DATA: text1(30).
  DATA: text2(30).

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
*   IMPORTING
*     FILESIZE                      =
*     CANCEL                        =
*     ACT_FILENAME                  =
*     ACT_FILETYPE                  =
TABLES
  data_tab                      = ini_data_tab
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
      '' 'Z_CL_READ_INI_AOFORMATS' RAISING error.
  ENDIF.

* interne Tabelle bereinigen
  LOOP AT ini_data_tab INTO wa_ini_data_tab.
    itab_index = sy-tabix.

    IF wa_ini_data_tab CS 'DESCRIPTION::'.
    ELSE.
      DELETE ini_data_tab INDEX itab_index.
    ENDIF.
  ENDLOOP.

  LOOP AT ini_data_tab INTO wa_ini_data_tab.
    itab_index = sy-tabix.

    IF wa_ini_data_tab IS INITIAL.
      DELETE ini_data_tab INDEX itab_index.
    ELSE.
    ENDIF.
  ENDLOOP.

  IF sy-langu = 'D'.
    LOOP AT ini_data_tab INTO wa_ini_data_tab.
      itab_index = sy-tabix.

      IF wa_ini_data_tab CS 'DESCRIPTION::GERMAN'.
      ELSE.
        DELETE ini_data_tab INDEX itab_index.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT ini_data_tab INTO wa_ini_data_tab.
      itab_index = sy-tabix.

      IF wa_ini_data_tab CS 'DESCRIPTION::ENGLISH'.
      ELSE.
        DELETE ini_data_tab INDEX itab_index.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT ini_data_tab INTO wa_ini_data_tab.
    itab_index = sy-tabix.

    SPLIT wa_ini_data_tab AT '= ' INTO text1 text2.
    wa_ini_data_tab = text2.

    MODIFY ini_data_tab FROM wa_ini_data_tab INDEX itab_index.
  ENDLOOP.



* Formattabelle updaten

  LOOP AT ini_data_tab INTO wa_ini_data_tab.
    SELECT SINGLE * FROM zcl_format_werte
      INTO wa_format_werte
      WHERE formatname = wa_ini_data_tab
      .
    IF sy-subrc NE 0.
      CLEAR wa_format_werte.
      wa_format_werte-formatname = wa_ini_data_tab.
      wa_format_werte-zclinsname = sy-uname.
      wa_format_werte-zclinsdate = sy-datum.
      wa_format_werte-zclinstime = sy-uzeit.
      wa_format_werte-zclinsprog = sy-repid.
      wa_format_werte-zclupdname = sy-uname.
      wa_format_werte-zclupddate = sy-datum.
      wa_format_werte-zclupdtime = sy-uzeit.
      wa_format_werte-zclupdprog = sy-repid.
      INSERT INTO zcl_format_werte VALUES wa_format_werte .
      IF sy-subrc NE 0.
        MESSAGE e003(zcl_plint_tools) WITH 'zcl_format_werte'
          wa_format_werte-formatname '' ''
          RAISING error.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
