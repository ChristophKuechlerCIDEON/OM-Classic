*&---------------------------------------------------------------------*
*& Report  /CIDEON/DEL_FROM_QUEUE                                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  /cideon/del_from_queue        .

TABLES zcl_psb_tmp.

SELECT-OPTIONS s_date FOR zcl_psb_tmp-zclinsdate DEFAULT sy-datum.


*DELETE FROM zcl_psb_tmp WHERE zclinsdate IN s_date
*.
*IF sy-subrc NE 0.
*ELSE.
*ENDIF.
