FUNCTION z_cl_plint_tools_ask_for_aufnr.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_AUFNR) TYPE  ZCL_S_PLOTLIST-AUFNR
*"  EXPORTING
*"     VALUE(O_AUFNR) LIKE  ZCL_S_PLOTLIST-AUFNR
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
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------

  CLEAR ask_aufnr.

  ask_aufnr = i_aufnr.

  CALL SCREEN 575 STARTING AT 10 10 ENDING AT 67 25.

  o_aufnr = ask_aufnr.

ENDFUNCTION.
