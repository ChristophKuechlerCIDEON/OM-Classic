*&---------------------------------------------------------------------*
*& Include ZCL_UPDAE_INI_FILES_TOP                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  ZCL_UPDATE_INI_FILES          .

DATA: ok_code like sy-ucomm.


*ITAB
*WA
DATA: wa_work_normal type zcl_work_Normal.
*NORMAL
DATA: username like usr02-bname.
DATA: FilENAME type filep.
