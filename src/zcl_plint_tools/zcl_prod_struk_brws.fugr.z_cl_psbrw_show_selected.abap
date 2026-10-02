FUNCTION z_cl_psbrw_show_selected.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"  TABLES
*"      SELECTED_OBJECTS STRUCTURE  PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
*  2009/06/23 - Eric Voss:
*               Deaktivieren der alten Funktionalität
*               Aufruf des neuen FuBa  /CIDEON/PSBRW_SHOW_SELECTED
*-------------------------------------------------------------------
********************************************
* ACHTUNG !  Parallel-FB Z_CL_PSBRW_SHOW_SELECTED_z
*            bitte gleichlautend anpassen !
***********************************************************************

*  PERFORM read_stored_search.
*
*  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 70 25.

*  clear G_TAB_CNTRL_01_LINES.
*  clear ok_code.
*  clear wa_stored_search.
*  refresh itab_stored_search.

  CALL FUNCTION '/CIDEON/PSBRW_SHOW_SELECTED'
     EXPORTING
       function               = function
     TABLES
       selected_objects       = selected_objects
* EXCEPTIONS
*   ERROR                  = 1
*   OTHERS                 = 2
             .


ENDFUNCTION.
