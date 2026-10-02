*----------------------------------------------------------------------*
***INCLUDE ZCL_UPDAE_INI_FILES_O .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_INI_FILES'.
  SET TITLEBAR '0100'.

  GET PARAMETER ID 'Z_CL_DEF_USER' FIELD wa_work_normal-bname.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_checkboxen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_checkboxen OUTPUT.

  cb_knz_use_converter = wa_pre_processor_rfc-knz_use_converter.

ENDMODULE.                 " set_checkboxen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_data OUTPUT.

  /cideon/_s_pre_preocessor = wa_pre_processor_rfc.

ENDMODULE.                 " set_data  OUTPUT
