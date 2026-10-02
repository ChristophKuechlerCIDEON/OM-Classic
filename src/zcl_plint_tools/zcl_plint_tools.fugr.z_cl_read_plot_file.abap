FUNCTION z_cl_read_plot_file.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP
*"     VALUE(I_TRENNZEICHEN) TYPE  CHAR1 DEFAULT '/'
*"  TABLES
*"      O_ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
* 23.09.2002 - Erstellung
* 04.11.2005   Komponentenzuweisung über dynamisches Assign PRE
* 28.02.2006 - Dateinamensabfrage
* 06.07.2006 - DATA: tab TYPE x VALUE '09'. ersetzt
* 06.11.2007 - Umbau eun GUI_DOWNLOAD
* 07.12.2007 - kleine Änderungen
*-----------------------------------------------------------------------
  TYPES:
   BEGIN OF t_data_tab,
     zcl_s_plotlist,                                        "line(255),
   END OF t_data_tab.

  TYPES:
    BEGIN OF t_data_tab2,
      line(3000),
    END OF t_data_tab2.

  DATA: tmp_filename TYPE rlgrap-filename.
*ITAB
  DATA: itab_data TYPE TABLE OF zcl_s_plotlist. "t_data_tab.
  DATA: itab_data2 TYPE TABLE OF t_data_tab2.
  DATA: tmp_data TYPE TABLE OF char1024.

*WA
  DATA: wa_data TYPE t_data_tab.
  DATA: wa_search TYPE zcl_s_docsearch.
  DATA: wa_data2 TYPE t_data_tab2.
  DATA: wa_tmp_data TYPE char1024.
*NORMAL
  DATA: numc(3)  TYPE n.
  DATA: f_cancel(1).
* CKR 2006/07/06
*  DATA: tab TYPE x VALUE '09'.

* CKR 05.11.2007
  DATA: tab TYPE char1  VALUE '|'.

*  DATA: tab TYPE char2 VALUE '09'.
* CKR 2007/10/29  Anpassung '/h/'
*  DATA: tab TYPE char3 VALUE '/h/'.

  "TRENN_SEM TYPE X VALUE '3B',
  "hex3B = dec59 = ;
  "TRENN_TAB TYPE X VALUE '09',
  " hex09 = dec09 = Tabulator
  "TRENNER TYPE X,

**  Begin 04.11.2005 PRE
**  FB zur Ermittlung der Tabellenstruktur incl Keyfelder
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

*--------------------------------------------------------

  CLEAR f_cancel.
  tmp_filename = i_filename.


  tmp_string = i_filename.


  DATA: fullpath TYPE string.
  DATA: path TYPE string.
  DATA: user_action TYPE i.

  DATA: file_table TYPE filetable.
  DATA: lc_file_table TYPE file_table.

  DATA: rc TYPE i.

* Path gewinnen
  DATA: pf_path TYPE char255.
  DATA: pfx_path TYPE filep.
  DATA: pfx_file TYPE filep.

  CLEAR pf_path.
  CLEAR pfx_path.
  CLEAR pfx_file.

  pf_path = tmp_string.

  CALL FUNCTION 'CV120_SPLIT_PATH'
       EXPORTING
            pf_path  = pf_path
       IMPORTING
            pfx_path = pfx_path
            pfx_file = pfx_file.

  path_string = pfx_path.



  CLEAR file_table.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*      WINDOW_TITLE            =
       default_extension       = '*.lst'
       default_filename        =  '*.lst' " tmp_string
       file_filter             = '*.lst'
       initial_directory       = path_string
*      MULTISELECTION          =
    CHANGING
      file_table              = file_table
      rc                      = rc
      user_action             = user_action
     EXCEPTIONS
       file_open_dialog_failed = 1
       cntl_error              = 2
       error_no_gui            = 3
       OTHERS                  = 4
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  IF file_table[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  READ TABLE file_table INTO lc_file_table INDEX 1.

  tmp_string = lc_file_table-filename.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = tmp_string
     filetype                = 'ASC'
     has_field_separator     = 'X'
*    HEADER_LENGTH           = 0
*  IMPORTING
*    FILELENGTH              =
*    HEADER                  =
    CHANGING
      data_tab                = itab_data2
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      filename                      = tmp_string
*   filetype                      = 'ASC'
*   has_field_separator           = 'X'
**   HEADER_LENGTH                 = 0
**   READ_BY_LINE                  = 'X'
**   DAT_MODE                      = ' '
** IMPORTING
**   FILELENGTH                    =
**   HEADER                        =
*    TABLES
*      data_tab                      = itab_data2
* EXCEPTIONS
*   file_open_error               = 1
*   file_read_error               = 2
*   no_batch                      = 3
*   gui_refuse_filetransfer       = 4
*   invalid_type                  = 5
*   no_authority                  = 6
*   unknown_error                 = 7
*   bad_data_format               = 8
*   header_not_allowed            = 9
*   separator_not_allowed         = 10
*   header_too_long               = 11
*   unknown_dp_error              = 12
*   access_denied                 = 13
*   dp_out_of_memory              = 14
*   disk_full                     = 15
*   dp_timeout                    = 16
*   OTHERS                        = 17
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.


*  itab_data[] = itab_data2[].


*  CALL FUNCTION 'UPLOAD'
*   EXPORTING
**     CODEPAGE                      = ' '
*     filename                      = tmp_filename
*     filetype                      = 'ASC'
**     filetype                      = 'DAT'
**     ITEM                          = ' '
**     FILEMASK_MASK                 = ' '
**     FILEMASK_TEXT                 = ' '
*     filetype_no_change            = 'X'
**     FILEMASK_ALL                  = ' '
**     FILETYPE_NO_SHOW              = ' '
**     LINE_EXIT                     = ' '
**     USER_FORM                     = ' '
**     USER_PROG                     = ' '
**     SILENT                        = 'S'
*   IMPORTING
**     FILESIZE                      =
*     cancel                        = f_cancel
**     ACT_FILENAME                  =
**     ACT_FILETYPE                  =
*    TABLES
*      data_tab                      = itab_data2
*    EXCEPTIONS
*     conversion_error              = 1
*     invalid_table_width           = 2
*     invalid_type                  = 3
*     no_batch                      = 4
*     unknown_error                 = 5
*     gui_refuse_filetransfer       = 6
*     OTHERS                        = 7
*            .
*  IF sy-subrc <> 0.
*    MESSAGE i050(zcl_plint_tools)
*      WITH tmp_filename ''
*      '' 'Z_CL_READ_PLOT_FILE' RAISING error.
*  ENDIF.

  TRANSLATE f_cancel TO UPPER CASE.
  IF f_cancel = 'X'.
    EXIT.
  ELSE.
  ENDIF.

* Tabelle splitten
  LOOP AT itab_data2 INTO wa_data2.
    SPLIT wa_data2 AT tab INTO TABLE tmp_data.
    DELETE tmp_data INDEX 1.

    LOOP AT lt_wtab ASSIGNING <component>.
      index = sy-tabix.
      CHECK <component> IS ASSIGNED.
      ASSIGN COMPONENT <component> OF STRUCTURE ls_data TO <value>.
      CHECK <value> IS ASSIGNED.
      READ TABLE tmp_data INTO wa_tmp_data INDEX index.
      MOVE wa_tmp_data TO <value>.
    ENDLOOP.
    APPEND ls_data TO itab_data.
  ENDLOOP.


  IF itab_data[] IS INITIAL.
    MESSAGE i062(zcl_plint_tools)
      WITH tmp_filename ''
      '' 'Z_CL_READ_PLOT_FILE' RAISING error.
  ELSE.
  ENDIF.

  CLEAR wa_search.
  CLEAR wa_data.
  REFRESH o_itab_plotjobs.

  o_itab_plotjobs[] = itab_data[].

*  loop at itab_data into wa_data.
*    clear wa_Search.
*    split wa_data at I_TRENNZEICHEN
*      into wa_search-dokar wa_Search-doknr
*      wa_search-dokvr wa_search-doktl.
*    append wa_search to o_itab_search.
*  endloop.

  MESSAGE s069(zcl_plint_tools) WITH '' '' '' ''.
ENDFUNCTION.
