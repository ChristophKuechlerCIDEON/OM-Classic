FUNCTION z_cl_write_plot_file.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP
*"     VALUE(I_TRENNZEICHEN) TYPE  CHAR1 DEFAULT '/'
*"  TABLES
*"      I_ITAB_PLOTLIST STRUCTURE  ZCL_S_PLOTLIST
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
* 23.09.2002 Erstellung
* 28.02.2006 - Dateinamensdialog
* 06.11.2007 - Umbau eun GUI_DOWNLOAD
* 10.12.2007 - Verzeichnis vorher anlegen, falls möglich
* 12.12.2007 - Extension wieder rausnehmen
*-----------------------------------------------------------------------
  TYPES:
   BEGIN OF t_data_tab,
     line(255),
   END OF t_data_tab.

  DATA: tmp_filename TYPE rlgrap-filename.
*ITAB
  DATA: itab_data TYPE TABLE OF zcl_s_plotlist. "t_data_tab.
*WA
  DATA: wa_data TYPE zcl_s_plotlist. "t_data_tab.
  DATA: wa_search TYPE zcl_s_docsearch.
*NORMAL
  DATA: numc(3)  TYPE n.
  DATA: f_cancel(1).
  DATA: filename_str TYPE string.

  CLEAR f_cancel.
  tmp_filename = i_filename.

  REFRESH itab_data.

*  loop at I_ITAB_SEARCHLIST into wa_search.
*    clear wa_data.
*    concatenate wa_search-dokar wa_search-doknr wa_search-dokvr
*      wa_search-doktl
*      into wa_data separated by i_trennzeichen .
*
*    append wa_data to itab_data.
*  endloop.

  itab_data[] = i_itab_plotlist[].

*  DATA: dsn(255).
*  dsn = tmp_filename.
*
*  OPEN DATASET dsn FOR OUTPUT IN TEXT MODE.
*  IF sy-subrc NE 0.
*  ELSE.
*    LOOP AT itab_data INTO wa_data.
*      TRANSFER wa_data TO dsn.
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

  DATA: tabname TYPE tabname VALUE 'ZCL_S_PLOTLIST',
        lt_table TYPE TABLE OF dd03p,
        index TYPE sy-tabix.

  DATA:  ls_wtab TYPE fieldname,
         lt_wtab TYPE TABLE OF fieldname.
  DATA:  ls_data TYPE zcl_s_plotlist.

  FIELD-SYMBOLS:  <component> TYPE ANY,
                  <data> TYPE ANY,
                  <struc> TYPE ANY,
                  <value> TYPE ANY.

  CALL FUNCTION 'DDIF_TABL_GET'
       EXPORTING
            name      = tabname
       TABLES
            dd03p_tab = lt_table.
*  Auslesen der Namen der Felder und Aufbau der Struktur
  LOOP AT lt_table ASSIGNING <struc>.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <struc> TO <component>.
    CHECK <component> IS ASSIGNED.
    ls_wtab = <component>.
    APPEND ls_wtab TO lt_wtab.
  ENDLOOP.

* Zusammensetzen der Linien
  TYPES:
    BEGIN OF t_data_tab2,
      line(3000),
    END OF t_data_tab2.
  DATA: itab_data2 TYPE TABLE OF t_data_tab2.
  DATA: wa_data2 TYPE t_data_tab2.

  DATA: str TYPE string.

  CLEAR itab_data2.
  LOOP AT itab_data INTO wa_data.
    CLEAR wa_data2.
    LOOP AT lt_wtab ASSIGNING <component>.
      index = sy-tabix.
      CHECK <component> IS ASSIGNED.
      ASSIGN COMPONENT <component> OF STRUCTURE wa_data TO <value>.
      CHECK <value> IS ASSIGNED.
*      READ TABLE tmp_data INTO wa_tmp_data INDEX index.
      MOVE <value> TO str.

      CONCATENATE wa_data2 str
        INTO wa_data2 SEPARATED BY '|'.
    ENDLOOP.
    APPEND wa_data2 TO itab_data2.
  ENDLOOP.

  CLEAR filename_str.
  filename_str = i_filename.

  DATA: fullpath TYPE string.
  DATA: path TYPE string.
  DATA: user_action TYPE i.


* Path gewinnen
  DATA: pf_path TYPE char255.
  DATA: pfx_path TYPE filep.
  DATA: pfx_file TYPE filep.

  CLEAR pf_path.
  CLEAR pfx_path.
  CLEAR pfx_file.

  pf_path = filename_str.

  CALL FUNCTION 'CV120_SPLIT_PATH'
       EXPORTING
            pf_path  = pf_path
       IMPORTING
            pfx_path = pfx_path
            pfx_file = pfx_file.

  path_string = pfx_path.

  DATA: rc TYPE i.
  DATA: str_dir TYPE string.

  CLEAR rc.
  CLEAR str_dir.

  str_dir = pfx_path.

  CALL METHOD cl_gui_frontend_services=>directory_create
    EXPORTING
      directory                = str_dir
    CHANGING
      rc                       = rc
  EXCEPTIONS
    directory_create_failed  = 1
    cntl_error               = 2
    error_no_gui             = 3
    path_not_found           = 4
    directory_access_denied  = 5
    directory_already_exists = 6
    unknown_error            = 7
    OTHERS                   = 8
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Anmerkung CKR 2007/12/12
* default_extension nicht füllen, da sonst Probleme mit
* GUI 6.40

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
     EXPORTING
*      WINDOW_TITLE      =
*       default_extension = '*.lst'
       default_file_name = filename_str
       file_filter       = '*.lst'
       initial_directory =  path_string  "filename_str
    CHANGING
      filename          = filename_str
      path              =  path
      fullpath          = fullpath
      user_action       = user_action
    EXCEPTIONS
      cntl_error        = 1
      error_no_gui      = 2
      OTHERS            = 3
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CASE user_action.
    WHEN '9'.
      EXIT.
  ENDCASE.


* Falls keine Extension '*.lst', dann diese explizit setzen
*
  DATA: pf_file TYPE filep.
  DATA: pfx_extension(30).

  CLEAR pf_file.
  pf_file = fullpath.

  CLEAR pfx_extension.

  CALL FUNCTION 'CV120_SPLIT_FILE'
    EXPORTING
      pf_file                = pf_file
  IMPORTING
*   PFX_FILE               =
    pfx_extension          = pfx_extension
*   PFX_DOTEXTENSION       =
            .

  IF pfx_extension = 'LST'
    OR pfx_extension = 'lst'.
  ELSE.
    CONCATENATE fullpath '.lst'
      INTO fullpath.
  ENDIF.


  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
*    BIN_FILESIZE            =
      filename                = fullpath "filename_str
     filetype                = 'ASC'
*    APPEND                  = SPACE
     write_field_separator   = space
*    HEADER                  = '00'
     trunc_trailing_blanks   = space
*    WRITE_LF                = 'X'
*    COL_SELECT              = SPACE
*    COL_SELECT_MASK         = SPACE
*  IMPORTING
*    FILELENGTH              =
    CHANGING
      data_tab                = itab_data2 "itab_data
  EXCEPTIONS
    file_write_error        = 1
    no_batch                = 2
    gui_refuse_filetransfer = 3
    invalid_type            = 4
    no_authority            = 5
    unknown_error           = 6
    header_not_allowed      = 7
    separator_not_allowed   = 8
    filesize_not_allowed    = 9
    header_too_long         = 10
    dp_error_create         = 11
    dp_error_send           = 12
    dp_error_write          = 13
    unknown_dp_error        = 14
    access_denied           = 15
    dp_out_of_memory        = 16
    disk_full               = 17
    dp_timeout              = 18
    file_not_found          = 19
    dataprovider_exception  = 20
    control_flush_error     = 21
    OTHERS                  = 22
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    MESSAGE i068(zcl_plint_tools) WITH '' '' '' ''.
  ENDIF.


*  CALL FUNCTION 'DOWNLOAD'
*   EXPORTING
**     BIN_FILESIZE                  = ' '
**     CODEPAGE                      = ' '
*     filename                      = tmp_filename
*     filetype                      = 'DAT'
**     filetype                      = 'ASC'
**     ITEM                          = ' '
**     MODE                          = ' '
**     WK1_N_FORMAT                  = ' '
**     WK1_N_SIZE                    = ' '
**     WK1_T_FORMAT                  = ' '
**     WK1_T_SIZE                    = ' '
**     FILEMASK_MASK                 = ' '
**     FILEMASK_TEXT                 = ' '
*     filetype_no_change            = 'X'
**     FILEMASK_ALL                  = ' '
**     FILETYPE_NO_SHOW              = ' '
**     SILENT                        = 'S'
**     COL_SELECT                    = ' '
**     COL_SELECTMASK                = ' '
**     NO_AUTH_CHECK                 = ' '
*    IMPORTING
**     ACT_FILENAME                  =
**     ACT_FILETYPE                  =
**     FILESIZE                      =
*     cancel                        = f_cancel
*    TABLES
*      data_tab                      = itab_data
**     FIELDNAMES                    =
*   EXCEPTIONS
*     invalid_filesize              = 1
*     invalid_table_width           = 2
*     invalid_type                  = 3
*     no_batch                      = 4
*     unknown_error                 = 5
*     gui_refuse_filetransfer       = 6
*     customer_error                = 7
*     OTHERS                        = 8
*            .
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.


  TRANSLATE f_cancel TO UPPER CASE.
  IF f_cancel = 'X'.
    EXIT.
  ELSE.
  ENDIF.

*  MESSAGE i068(zcl_plint_tools) WITH '' '' '' ''.

ENDFUNCTION.
