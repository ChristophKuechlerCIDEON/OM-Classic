FUNCTION z_cl_write_search_file.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP
*"     VALUE(I_TRENNZEICHEN) TYPE  CHAR1 DEFAULT '/'
*"  TABLES
*"      I_ITAB_SEARCHLIST STRUCTURE  ZCL_S_DOCSEARCH
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

  REFRESH itab_data.

  LOOP AT i_itab_searchlist INTO wa_search.
    CLEAR wa_data.
    CONCATENATE wa_search-dokar wa_search-doknr wa_search-dokvr
      wa_search-doktl
      INTO wa_data SEPARATED BY i_trennzeichen .

    APPEND wa_data TO itab_data.
  ENDLOOP.

  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'DOWNLOAD'.

  CALL FUNCTION lc_fname
"CALL FUNCTION 'DOWNLOAD'
EXPORTING
*     BIN_FILESIZE                  = ' '
*     CODEPAGE                      = ' '
 filename                      = tmp_filename
*     FILETYPE                      = ' '
*     ITEM                          = ' '
*     MODE                          = ' '
*     WK1_N_FORMAT                  = ' '
*     WK1_N_SIZE                    = ' '
*     WK1_T_FORMAT                  = ' '
*     WK1_T_SIZE                    = ' '
*     FILEMASK_MASK                 = ' '
*     FILEMASK_TEXT                 = ' '
*     FILETYPE_NO_CHANGE            = ' '
*     FILEMASK_ALL                  = ' '
*     FILETYPE_NO_SHOW              = ' '
*     SILENT                        = 'S'
*     COL_SELECT                    = ' '
*     COL_SELECTMASK                = ' '
*     NO_AUTH_CHECK                 = ' '
IMPORTING
*     ACT_FILENAME                  =
*     ACT_FILETYPE                  =
*     FILESIZE                      =
  cancel                        = f_cancel
TABLES
  data_tab                      = itab_data
*     FIELDNAMES                    =
EXCEPTIONS
 invalid_filesize              = 1
 invalid_table_width           = 2
 invalid_type                  = 3
 no_batch                      = 4
 unknown_error                 = 5
 gui_refuse_filetransfer       = 6
 customer_error                = 7
 OTHERS                        = 8
        .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  TRANSLATE f_cancel TO UPPER CASE.
  IF f_cancel = 'X'.
    EXIT.
  ELSE.
  ENDIF.

  MESSAGE i066(zcl_plint_tools) WITH '' '' '' ''.

ENDFUNCTION.
