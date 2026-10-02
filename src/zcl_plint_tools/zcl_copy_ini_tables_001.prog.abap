*&---------------------------------------------------------------------*
*& Report  ZCL_COPY_INI_TABLES_001                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  ZCL_COPY_INI_TABLES_001       .

DATA: wa type ZCL_REPCL_INI_PR.


*delete from zcl_repcl_ini_pt CLIENT SPECIFIED
*  where mandt <> '000'
*  .
*
*
*select * from zcl_repcl_ini_pr CLIENT SPECIFIED
*  into wa
*  where mandt <> '000'
*  .
*
*  insert into zcl_repcl_ini_pt CLIENT SPECIFIED values wa
*   .
*
*
*endselect.

delete from zcl_repcl_ini_pr CLIENT SPECIFIED
  where mandt <> '000'
  .


select * from zcl_repcl_ini_pt CLIENT SPECIFIED
  into wa
  where mandt <> '000'
  .

  insert into zcl_repcl_ini_pr CLIENT SPECIFIED values wa
   .


endselect.
