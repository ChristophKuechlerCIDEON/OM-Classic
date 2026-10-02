FUNCTION Z_CL_PLINT_TOOLS_ASK_FOR_COPY.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_KOPIEN) TYPE  ZCL_S_PLOTLIST-KOPIEN
*"  EXPORTING
*"     VALUE(O_KOPIEN) TYPE  ZCL_S_PLOTLIST-KOPIEN
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

  clear ask_kopien.
  ask_kopien = i_kopien.


  call screen 510 starting at 10 10 ending at 51 21.

  o_kopien = ask_kopien.


ENDFUNCTION.
