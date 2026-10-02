FUNCTION /cideon/ask_for_lifnr.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_LIFNR) LIKE  ZCL_S_PLOTLIST-LIFNR
*"     VALUE(O_NAME1_LIFNR) LIKE  ZCL_S_PLOTLIST-NAME1_LIFNR
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
* 19.05.2005 - Kopie
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
  DATA: ask_lifnr TYPE lifnr.

  CLEAR ask_lifnr.


  CLEAR selection.
  CLEAR wa_help_infos.
  CLEAR fldvalue.
  CLEAR dynpselect.
  CLEAR dynpvaluetab.

  wa_help_infos-call = 'V'.
  wa_help_infos-object = 'F'.
  wa_help_infos-program = 'ZCL_PLINT_DESIGN_007'.
  wa_help_infos-dynpro = '0126'.
  wa_help_infos-tabname = 'ZCL_S_PLOTLIST'.
  wa_help_infos-fieldname = 'LIFNR'.
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
    ask_lifnr = fldvalue.
  ELSE.
    RAISE forget.
  ENDIF.

* Name erfragen
  SELECT SINGLE name1 INTO o_name1_lifnr
    FROM lfa1 WHERE lifnr = ask_lifnr.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


  o_lifnr = ask_lifnr.

ENDFUNCTION.
