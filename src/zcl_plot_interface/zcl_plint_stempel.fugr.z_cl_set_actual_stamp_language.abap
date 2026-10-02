FUNCTION z_cl_set_actual_stamp_language.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
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
* 17.02.2002 Erstellung
*-----------------------------------------------------------------------

*ITAB
*WA
*NORMAL

  GET PARAMETER ID 'ZCL_STAMP_LANGUAGE' FIELD wa_sprache.

  IF wa_sprache IS INITIAL.
    wa_sprache = sy-langu.
  ELSE.
  ENDIF.


  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 60 22.


*  SET PARAMETER ID 'ZCL_STAMP_LANGUAGE' FIELD 'DE'.

ENDFUNCTION.
