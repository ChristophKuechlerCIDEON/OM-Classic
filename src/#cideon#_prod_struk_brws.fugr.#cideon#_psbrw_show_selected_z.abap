FUNCTION /CIDEON/_PSBRW_SHOW_SELECTED_Z.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"       TABLES
*"              SELECTED_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
*
*-------------------------------------------------------------------
********************************************
* ACHTUNG !  Parallel-FB Z_CL_PSBRW_SHOW_SELECTED
*            bitte gleichlautend anpassen !
***********************************************************************

*  clear wa_stored_search.
*  refresh itab_stored_search.
*
*
*  select * from zcl_psb_tmp
*    into table itab_stored_search
*    where uname = sy-uname
*    .
*  if sy-subrc ne 0.
*    message s151(ZCL_PLINT_MESSAGE_01) with
*      '' '' '' ''.
*    exit.
*  else.
*  endif.

  PERFORM read_stored_search.

  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 70 25.

  clear G_TAB_CNTRL_01_LINES.
  clear ok_code.
  clear wa_stored_search.
  refresh itab_stored_search.

ENDFUNCTION.
