*&---------------------------------------------------------------------*
*& Report  ZCL_CALL_PROG_VIA_RFC_EXEC                                  *
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
* 12.11.2003 - Erstellung
*-----------------------------------------------------------------------


REPORT  zcl_call_prog_via_rfc_exec    .


PARAMETERS: p_dest LIKE converter-conv_dest DEFAULT 'RFC_PL_CLF_HAMLET'.
PARAMETERS: p_com(600) TYPE c
    DEFAULT 'C:\Neutralformat\ConvertServer\ConvertClient.exe'.


* Aufrufen


CALL FUNCTION 'RFC_REMOTE_EXEC'
    DESTINATION p_dest
  EXPORTING
    command = p_com
    .

IF sy-subrc NE 0.
  WRITE sy-subrc.
ELSE.
ENDIF.
