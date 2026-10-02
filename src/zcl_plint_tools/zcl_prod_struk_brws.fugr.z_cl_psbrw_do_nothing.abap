FUNCTION Z_CL_PSBRW_DO_NOTHING.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"       TABLES
*"              SELECTED_OBJECTS STRUCTURE  PDM_EXP_OBJECTS
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

  clear wa_objects.
  refresh itab_objects.

ENDFUNCTION.
