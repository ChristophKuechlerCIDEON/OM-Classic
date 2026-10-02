*&---------------------------------------------------------------------*
*& Report  ZCL_DELETE_TEMP_DIR_BY_DATES                                *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_delete_temp_dir_by_dates  .

DATA : count TYPE i.

CALL FUNCTION 'Z_CL_DEL_TMP_DIR_BY_DATES'
     EXPORTING
          i_down_path    = '\\Soft-gr-oratest\AutoORG\TEMP\CV04N\'
          filter         = '*.*'
          deletable_days = '2'
*          user           = sy-uname
     IMPORTING
          count          = count
     EXCEPTIONS
          error          = 1
          OTHERS         = 2.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
