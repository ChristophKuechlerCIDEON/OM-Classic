REPORT /cideon/_om_check_trans_times .

* CIDEON SAP Plotting Interface
*
*----------------------------------------------------------------------
* Author :  C. Küchler
*
* Anpassungen:

* Kontakt:
*           helpdesk@cideon-software.com
*
*----------------------------------------------------------------------
* Journal
* 15.02.2011 - Creation
*
*----------------------------------------------------------------------
*
*----------------------------------------------------------------------

TYPE-POOLS abap.

PARAMETERS: p_root TYPE filep DEFAULT 'c:\temp\'.

DATA: lc_time_stamp TYPE timestampl.

DATA: lc_time_stamp_a TYPE timestampl.
DATA: lc_time_stamp_b TYPE timestampl.
DATA: lc_time_stamp_res TYPE timestampl.

DATA: lc_time_stamp_start TYPE timestampl.
DATA: lc_time_stamp_stop TYPE timestampl.

DATA: lc_root TYPE string.
CLEAR lc_root.

lc_root = p_root.

GET TIME STAMP FIELD lc_time_stamp.
WRITE : / 'time stamp: ', lc_time_stamp.

lc_time_stamp_a = lc_time_stamp.
lc_time_stamp_start = lc_time_stamp.

WRITE: / 'Check existence'.
WRITE: / lc_root.

SKIP.

DATA: result TYPE abap_bool.
CLEAR result.

DATA: lc_exist.
CLEAR lc_exist.

DATA: lc_isdir.
CLEAR lc_isdir.

WRITE : / 'checking : directory_exist'.
CALL METHOD cl_gui_frontend_services=>directory_exist
  EXPORTING
    directory            = lc_root
  RECEIVING
    result               = result
 EXCEPTIONS
   cntl_error           = 1
   error_no_gui         = 2
   wrong_parameter      = 3
   not_supported_by_gui = 4
   OTHERS               = 5
        .
IF sy-subrc <> 0.
ENDIF.

IF result = 'X'.
  lc_exist = 'X'.
  lc_isdir = 'X'.
ELSE.
ENDIF.

GET TIME STAMP FIELD lc_time_stamp.

lc_time_stamp_b = lc_time_stamp.
lc_time_stamp_res = lc_time_stamp_a - lc_time_stamp_b.
WRITE: / 'result: ', lc_time_stamp_res.

SKIP.

CLEAR result.
WRITE : / 'checking : file_exist'.

lc_time_stamp_a = lc_time_stamp.

CALL METHOD cl_gui_frontend_services=>file_exist
  EXPORTING
    file            = lc_root
  RECEIVING
    result          = result
  EXCEPTIONS
    cntl_error      = 1
    error_no_gui    = 2
    wrong_parameter = 3
    OTHERS          = 4
        .
IF sy-subrc <> 0.
ENDIF.

GET TIME STAMP FIELD lc_time_stamp.
lc_time_stamp_b = lc_time_stamp.

lc_time_stamp_res = lc_time_stamp_a - lc_time_stamp_b.
WRITE: / 'result: ', lc_time_stamp_res.

SKIP.

IF result = 'X'.
  lc_exist = 'X'.
  CLEAR lc_isdir.
ELSE.
ENDIF.


IF lc_exist = 'X'.
ELSE.
  " create directory
  DATA: lc_rc TYPE i.
  CLEAR lc_rc.

  WRITE : / 'directory_create'.

  GET TIME STAMP FIELD lc_time_stamp.
  lc_time_stamp_a = lc_time_stamp.

  CALL METHOD cl_gui_frontend_services=>directory_create
  EXPORTING
    directory                = lc_root
  CHANGING
    rc                       = lc_rc
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
  IF sy-subrc NE 0.
  ENDIF.

  GET TIME STAMP FIELD lc_time_stamp.
  lc_time_stamp_b = lc_time_stamp.

  lc_time_stamp_res = lc_time_stamp_a - lc_time_stamp_b.
  WRITE: / 'result: ', lc_time_stamp_res.
  SKIP.
ENDIF.

WRITE : / 'write file'.

GET TIME STAMP FIELD lc_time_stamp.
lc_time_stamp_a = lc_time_stamp.

DATA: lc_filename TYPE string.
CLEAR lc_filename.
CONCATENATE lc_root 'test.txt' INTO lc_filename.

DATA: lt_data_tab TYPE TABLE OF tdline.
DATA: ls_data_tab TYPE tdline.

CLEAR lt_data_tab.
CLEAR ls_data_tab.
ls_data_tab = 'Test'.
APPEND ls_data_tab TO lt_data_tab.

CALL METHOD cl_gui_frontend_services=>gui_download
  EXPORTING
*      BIN_FILESIZE            =
    filename                = lc_filename
*      FILETYPE                = 'ASC'
*      APPEND                  = SPACE
*      WRITE_FIELD_SEPARATOR   = SPACE
*      HEADER                  = '00'
*      TRUNC_TRAILING_BLANKS   = SPACE
*      WRITE_LF                = 'X'
*      COL_SELECT              = SPACE
*      COL_SELECT_MASK         = SPACE
*    IMPORTING
*      FILELENGTH              =
  CHANGING
    data_tab                = lt_data_tab
*    EXCEPTIONS
*      FILE_WRITE_ERROR        = 1
*      NO_BATCH                = 2
*      GUI_REFUSE_FILETRANSFER = 3
*      INVALID_TYPE            = 4
*      NO_AUTHORITY            = 5
*      UNKNOWN_ERROR           = 6
*      HEADER_NOT_ALLOWED      = 7
*      SEPARATOR_NOT_ALLOWED   = 8
*      FILESIZE_NOT_ALLOWED    = 9
*      HEADER_TOO_LONG         = 10
*      DP_ERROR_CREATE         = 11
*      DP_ERROR_SEND           = 12
*      DP_ERROR_WRITE          = 13
*      UNKNOWN_DP_ERROR        = 14
*      ACCESS_DENIED           = 15
*      DP_OUT_OF_MEMORY        = 16
*      DISK_FULL               = 17
*      DP_TIMEOUT              = 18
*      FILE_NOT_FOUND          = 19
*      DATAPROVIDER_EXCEPTION  = 20
*      CONTROL_FLUSH_ERROR     = 21
*      others                  = 22
        .
IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.


GET TIME STAMP FIELD lc_time_stamp.
lc_time_stamp_b = lc_time_stamp.

lc_time_stamp_res = lc_time_stamp_a - lc_time_stamp_b.
WRITE: / 'result: ', lc_time_stamp_res.

SKIP.

GET TIME STAMP FIELD lc_time_stamp.
WRITE: / 'time stamp: ', lc_time_stamp.
lc_time_stamp_stop = lc_time_stamp.

lc_time_stamp_res = lc_time_stamp_start - lc_time_stamp_stop.
WRITE: / 'result whole test: ', lc_time_stamp_res.
