FUNCTION Z_CL_GET_DOKNR_KEINE_VORN_8ST.
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
* 18.11.2002 creation
*
*-----------------------------------------------------------------------
*ITAB
*WA
*NORMAL
  DATA: doknr_normal TYPE draw-doknr.
  DATA: doknr_ohne_vornullen TYPE draw-doknr.


  CLEAR doknr_normal.
  CLEAR doknr_ohne_vornullen.

  doknr_normal = i_wa_plotjobs-doknr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = doknr_normal
       IMPORTING
            output = doknr_ohne_vornullen.



  o_stempel_wert = doknr_ohne_vornullen(8).


ENDFUNCTION.
