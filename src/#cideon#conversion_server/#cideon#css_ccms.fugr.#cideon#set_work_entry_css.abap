FUNCTION /cideon/set_work_entry_css.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXCEPTIONS
*"      KEIN_EINTRAG
*"      ERROR
*"      GESPERRT
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 14.06.2004 -
*-----------------------------------------------------------------------

*TYPES
*ITAB
*WA
*NORMAL



  PERFORM sperren.

*Testen, ob Dokument gesperrt ist, dann Job neu Einplanen



  PERFORM entsperren.












ENDFUNCTION.
