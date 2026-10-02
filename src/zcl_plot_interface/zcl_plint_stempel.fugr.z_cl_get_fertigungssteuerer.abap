FUNCTION z_cl_get_fertigungssteuerer.
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
  DATA: wa_afko TYPE afko.
*NORMAL
  DATA: fevor TYPE afko-fevor.

  CLEAR fevor.

  IF i_wa_plotjobs-aufnr IS INITIAL.
    CLEAR o_stempel_wert.
    EXIT.
  ELSE.
  ENDIF.

  SELECT SINGLE fevor FROM afko
    INTO fevor
    WHERE aufnr = i_wa_plotjobs-aufnr
    .
  IF sy-subrc NE 0.
    CLEAR o_stempel_wert.
  ELSE.
  ENDIF.





  o_stempel_wert = fevor.

ENDFUNCTION.
