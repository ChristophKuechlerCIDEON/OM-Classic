*&---------------------------------------------------------------------*
*& Report  ZCL_DELETE_TEMP_DIRECTORIES                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_delete_temp_directories.

DATA : count TYPE i.

*CALL FUNCTION 'Z_CL_DEL_TMP_DIR_BY_NAMES'
*     EXPORTING
*          user   = sy-uname
**     IMPORTING
**          count  = count
*     EXCEPTIONS
*          error  = 1
*          OTHERS = 2.
*IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
