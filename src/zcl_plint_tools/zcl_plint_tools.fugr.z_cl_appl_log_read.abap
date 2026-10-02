FUNCTION Z_CL_APPL_LOG_READ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
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




  CALL FUNCTION 'APPL_LOG_DISPLAY'
       EXCEPTIONS
            no_authority   = 1
            OTHERS         = 2.


ENDFUNCTION.
