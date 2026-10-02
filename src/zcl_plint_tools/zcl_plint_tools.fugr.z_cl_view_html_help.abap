FUNCTION z_cl_view_html_help.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FILENAME) TYPE  FILEP OPTIONAL
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
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------


* concatenate 'file:\\' i_filename into edurl.

  edurl = i_filename.

  CALL SCREEN 580.




ENDFUNCTION.
