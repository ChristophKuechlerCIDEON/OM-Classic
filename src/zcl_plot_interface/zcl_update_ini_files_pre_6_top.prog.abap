*&---------------------------------------------------------------------*
*& Include ZCL_UPDAE_INI_FILES_TOP                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  zcl_update_ini_files          .

DATA: ok_code LIKE sy-ucomm.


*ITAB
*WA
DATA: wa_work_normal TYPE zcl_work_normal.
DATA: wa_pre_processor_rfc TYPE /cideon/_s_pre_preocessor.

*NORMAL
DATA: username LIKE usr02-bname.
DATA: filename TYPE filep.

DATA: preprozessor TYPE zcl_preprozessor-preprozessor.


DATA: scan_pfad_pre LIKE wa_work_normal-scan_pfad_pre.
DATA: down_pfad_pre LIKE wa_work_normal-down_pfad_pre.


DATA: /cideon/_s_pre_preocessor like
  /cideon/_s_pre_preocessor.


*Checkboxxen
DATA: cb_knz_use_converter(1).
