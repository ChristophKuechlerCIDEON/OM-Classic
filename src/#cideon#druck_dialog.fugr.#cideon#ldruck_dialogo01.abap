*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_DRUCKDIALOG'.
  SET TITLEBAR 'PF_TP_DRUCKDIALOG'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  PERFORM set_screen_attributes.
  PERFORM set_scr_attr_aufnr.
  PERFORM set_scr_attr_vbeln.
  PERFORM set_scr_attr_firma.
  PERFORM set_scr_attr_kostl.
  PERFORM set_scr_attr_id_plotjob.
  PERFORM set_scr_attr_pspid.
  PERFORM set_scr_attr_lifnr.
ENDMODULE.                 " STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.

ENDMODULE.                 " USER_COMMAND_0103  INPUT
