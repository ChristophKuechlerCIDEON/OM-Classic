FUNCTION z_cl_read_search_file.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP
*"     VALUE(I_TRENNZEICHEN) TYPE  CHAR1 DEFAULT '/'
*"  TABLES
*"      O_ITAB_SEARCH STRUCTURE  ZCL_S_DOCSEARCH
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
* 27.09.2004 - Anpassung auf Dokumentennummernexit
*              Vornullen
* 21.10.2004 - auch für DOKTL und DOKVR
*-----------------------------------------------------------------------
  TYPES:
   BEGIN OF t_data_tab,
     line(255),
   END OF t_data_tab.

  DATA: tmp_filename TYPE rlgrap-filename.
*ITAB
  DATA: itab_data TYPE TABLE OF t_data_tab.
*WA
  DATA: wa_data TYPE t_data_tab.
  DATA: wa_search TYPE zcl_s_docsearch.
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
"call function 'UPLOAD'
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
  data_tab                      = itab_data
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
      '' 'Z_CL_READ_SEARCH_FILE' RAISING error.
  ENDIF.

  TRANSLATE f_cancel TO UPPER CASE.
  IF f_cancel = 'X'.
    EXIT.
  ELSE.
  ENDIF.

  IF itab_data[] IS INITIAL.
    MESSAGE i062(zcl_plint_tools)
      WITH tmp_filename ''
      '' 'Z_CL_READ_SEARCH_FILE' RAISING error.
  ELSE.
  ENDIF.

  CLEAR wa_search.
  CLEAR wa_data.
  REFRESH o_itab_search.

  LOOP AT itab_data INTO wa_data.
    CLEAR wa_search.
    SPLIT wa_data AT i_trennzeichen INTO wa_search-dokar
      wa_search-doknr wa_search-dokvr wa_search-doktl.
*   Konvertierungsexit / Vornullen
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_search-doknr
      IMPORTING
        output = wa_search-doknr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_search-doktl
      IMPORTING
        output = wa_search-doktl.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_search-dokvr
      IMPORTING
        output = wa_search-dokvr.

    APPEND wa_search TO o_itab_search.
  ENDLOOP.

  MESSAGE i065(zcl_plint_tools) WITH '' '' '' ''.
ENDFUNCTION.
