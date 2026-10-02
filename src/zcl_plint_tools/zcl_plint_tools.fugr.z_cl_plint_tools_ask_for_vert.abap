FUNCTION Z_CL_PLINT_TOOLS_ASK_FOR_VERT .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  SY-UNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  SY-UNAME
*"  EXPORTING
*"     VALUE(O_VERTEILER) TYPE  ZCL_NAME_VERTEILER
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
* 10.09.2002 - Erstellung
* 25.08.2003 - Anpassung an neue Verteileransteuerung
*-----------------------------------------------------------------------

  clear ask_verteiler.

  uname = i_uname.
  default_nutzer = i_default_nutzer.

  call screen 590 starting at 10 10 ending at 51 21.

  o_verteiler = ask_verteiler.


ENDFUNCTION.
