FUNCTION /cideon/ask_for_lif_telnr_long.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_LIF_TELNR_LONG) LIKE  ZCL_S_PLOTLIST-LIF_TELNR_LONG
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
  DATA: fldvalue TYPE text132.
*  DATA: ask_lif_telnr_long LIKE zcl_s_plotlist-lif_telnr_long.

  CLEAR ask_lif_telnr_long.


  CALL SCREEN 700 STARTING AT 10 10 ENDING AT 54 15.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = ask_lif_telnr_long
       IMPORTING
            output = ask_lif_telnr_long.


  o_lif_telnr_long = ask_lif_telnr_long.

ENDFUNCTION.
