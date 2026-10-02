FUNCTION z_cl_plint_tools_ask_for_vbeln.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_VBELN) LIKE  ZCL_S_PLOTLIST-VBELN
*"  EXCEPTIONS
*"      ERROR
*"      FORGET
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 23.07.2002 creation
* 17.05.2005 - Umbau auf Suchhilfe
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
*ITAB
  DATA: dynpselect TYPE TABLE OF dselc.
  DATA: dynpvaluetab TYPE TABLE OF dval.
*WA
  DATA: wa_help_infos TYPE help_info.
*NORMAL
  DATA: selection.
*  DATA: fldvalue TYPE text132.
  DATA: fldvalue TYPE help_info-fldvalue.
  CLEAR ask_vbeln.

*  call screen 570 starting at 10 10 ending at 67 25.

  CLEAR selection.
  CLEAR wa_help_infos.
  CLEAR fldvalue.
  CLEAR dynpselect.
  CLEAR dynpvaluetab.

  wa_help_infos-call = 'V'.
  wa_help_infos-object = 'F'.
  wa_help_infos-program = 'SAPLZCL_PLINT_TOOLS'.
  wa_help_infos-dynpro = '0570'.
  wa_help_infos-tabname = 'ZCL_S_VBELN'.
  wa_help_infos-fieldname = 'VBELN'.
  wa_help_infos-fldvalue = 'CHAR'.

  CALL FUNCTION 'HELP_START'
    EXPORTING
      help_infos         = wa_help_infos
    IMPORTING
      selection          = selection
      select_value       = fldvalue
*      RSMDY_RET          =
     TABLES
       dynpselect         = dynpselect
       dynpvaluetab       = dynpvaluetab
            .
  IF selection = 'X'.
    ask_vbeln = fldvalue.
  ELSE.
  ENDIF.

  o_vbeln = ask_vbeln.

ENDFUNCTION.
