FUNCTION /cideon/ask_for_lif_faxnr_long.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_LIF_FAXNR_LONG) LIKE  ZCL_S_PLOTLIST-LIF_FAXNR_LONG
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
* SP 92
* 20.05.2009 - Konvertierung ausgeschaltet, weil sonst Vornullen
*              verloren gehen
* SP 116
* 7.0.1.14
* 22.01.2010 - RGG / Welser
*              /CIDEON/ASK_FOR_LIF_FAXNR_LONG
*              FAX Nummer nicht mehr in internes Format konvertieren
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

  CLEAR ask_lif_faxnr_long.


  CALL SCREEN 710 STARTING AT 10 10 ENDING AT 54 15.

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*       EXPORTING
*            input  = ask_lif_faxnr_long
*       IMPORTING
*            output = ask_lif_faxnr_long.


  o_lif_faxnr_long = ask_lif_faxnr_long.

ENDFUNCTION.
