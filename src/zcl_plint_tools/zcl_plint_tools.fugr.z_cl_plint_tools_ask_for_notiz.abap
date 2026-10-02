FUNCTION Z_CL_PLINT_TOOLS_ASK_FOR_NOTIZ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(O_NOTIZ) TYPE  ZCL_S_PLOTLIST-NOTIZ
*"  EXCEPTIONS
*"      ERROR
*"      FORGET
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 10.09.2002 Erstellung
*-----------------------------------------------------------------------

  clear ask_notiz.

  call screen 520 starting at 10 10 ending at 51 21.

  o_notiz = ask_notiz.


ENDFUNCTION.
