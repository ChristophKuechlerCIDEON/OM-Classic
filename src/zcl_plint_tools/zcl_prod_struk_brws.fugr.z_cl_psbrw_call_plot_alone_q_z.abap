FUNCTION Z_CL_PSBRW_CALL_PLOT_ALONE_Q_Z.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"  TABLES
*"      SELECTED_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
********************************************
* ACHTUNG !  Parallel-FB Z_CL_PSBRW_CALL_PLOT_ALONE_QUE
*            bitte gleichlautend anpassen !
***********************************************************************

* Journal

  CLEAR wa_objects.
  REFRESH itab_objects.

*  EXPORT ''
*    TO MEMORY ID 'PLOT_READ_AKT_QUEUE'.

  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.

  CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.


ENDFUNCTION.
