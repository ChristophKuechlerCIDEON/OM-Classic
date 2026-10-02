FUNCTION z_cl_get_doknr_8_stellen_recht.
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
* 17.06.2004 Problem, falls DOKNR kleiner als 8 Stellen
*-----------------------------------------------------------------------
*ITAB
*WA
*NORMAL
  DATA: laenge TYPE i.
  DATA: start_at TYPE i.

  CLEAR start_at.
  CLEAR laenge.
  laenge = strlen( i_wa_plotjobs-doknr ).

* wenn DOKNR kleiner ist
  IF laenge <= 8.
    o_stempel_wert = ''.
    EXIT.
  ELSE.
  ENDIF.

  start_at = laenge - 8.


  o_stempel_wert = i_wa_plotjobs-doknr+start_at(8).


ENDFUNCTION.
