FUNCTION z_cl_get_aufnr_cs_alpha.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
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
* 26.07.2002 - Erstellung
*-----------------------------------------------------------------------

  o_stempel_wert = i_wa_plotjobs-aufnr_cs.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = i_wa_plotjobs-aufnr_cs
       IMPORTING
            output = o_stempel_wert.


*  CALL FUNCTION 'CONVERSION_EXIT_MODAT_OUTPUT'
*       EXPORTING
*            input  = i_wa_plotjobs-aufnr_cs
*       IMPORTING
*            output = o_stempel_wert.


ENDFUNCTION.
