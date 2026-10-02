FUNCTION /cideon/ask_for_mast.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_WA_MAST) TYPE  MAST
*"  TABLES
*"      IO_ITAB_MAST STRUCTURE  MAST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 14.06.2005 - Erstellung
* 15.06.2005 - ALV
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------

* Anzeige der übergebenen Materialstücklisten
  CLEAR wa_mast.
  CLEAR itab_mast.
  itab_mast[] = io_itab_mast[].

  CALL SCREEN 0680 STARTING AT 10 10 ENDING AT 60 20.

  IF wa_mast IS INITIAL.
    CLEAR o_wa_mast.
    RAISE error.
  ELSE.
    CLEAR o_wa_mast.
    o_wa_mast = wa_mast.
  ENDIF.

ENDFUNCTION.
