FUNCTION Z_CL_ASK_FOR_SELECTION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_FORMAT_AUSGABE) TYPE  ZCL_S_PLOTLIST-FORMAT_AUSGABE
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 28.08.2002 Erstellung
*-----------------------------------------------------------------------

  clear wa_plotjobs.

  CALL SCREEN 560 STARTING AT 10 10 ENDING AT 58 22.

  o_format_ausgabe = wa_plotjobs-format_ausgabe.

ENDFUNCTION.
