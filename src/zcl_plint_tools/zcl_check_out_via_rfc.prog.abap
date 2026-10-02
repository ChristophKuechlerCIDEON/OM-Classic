*&---------------------------------------------------------------------*
*& Report  ZCL_CHECK_OUT_VIA_RFC                                       *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 04.11.2003 - Erstellung
*-----------------------------------------------------------------------

REPORT  zcl_check_out_via_rfc         .

*TYPE
TYPES: BEGIN OF t_itab,
  line(1024),
  END OF t_itab.
*ITAB
DATA: itab_data TYPE TABLE OF t_itab.
*WA
*NORMAL
DATA: laenge TYPE i.

PARAMETERS: p_dest LIKE converter-conv_dest DEFAULT 'RFC_PL_CLF_HAMLET'.
PARAMETERS: source LIKE rlgrap-filename
   DEFAULT 'c:\temp\Eingefangen2.jpg'.
PARAMETERS: dest2 LIKE rlgrap-filename
  DEFAULT 'c:\temp\Eingefangen_dest.jpg'.
PARAMETERS: dest LIKE rlgrap-filename
  DEFAULT 'c:\convert\Ploting\Eingefangen_dest.jpg'.

START-OF-SELECTION.

  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'WS_UPLOAD'.

  CALL FUNCTION lc_fname

"call function 'WS_UPLOAD'
EXPORTING
*   CODEPAGE                      = ' '
  filename                      = source
  filetype                      = 'BIN'
*   HEADLEN                       = ' '
*   LINE_EXIT                     = ' '
*   TRUNCLEN                      = ' '
*   USER_FORM                     = ' '
*   USER_PROG                     = ' '
*   DAT_D_FORMAT                  = ' '
* IMPORTING
*   FILELENGTH                    =
TABLES
  data_tab                      = itab_data
EXCEPTIONS
  conversion_error              = 1
  file_open_error               = 2
  file_read_error               = 3
  invalid_type                  = 4
  no_batch                      = 5
  unknown_error                 = 6
  invalid_table_width           = 7
  gui_refuse_filetransfer       = 8
  customer_error                = 9
  OTHERS                        = 10
        .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.







  CALL FUNCTION 'RFC_REMOTE_FILE'
    DESTINATION
    p_dest
    EXPORTING
      file                  = dest
      write                 = 'X' "X=write <space>=read
    TABLES
      filedata              = itab_data
    EXCEPTIONS
      system_failure        = 1
      communication_failure = 2.

  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
