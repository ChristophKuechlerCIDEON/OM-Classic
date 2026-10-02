FUNCTION Z_CL_GET_AUFNR_FTRMI_ALPHA.
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

  CLEAR o_stempel_wert.

* falls AUFNR gefüllt, dann versuche AFKO zu lesen
  IF i_wa_plotjobs-aufnr IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  DATA: wa_afko TYPE afko.

  SELECT SINGLE * FROM afko INTO wa_afko
    WHERE aufnr = i_wa_plotjobs-aufnr
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_MODAT_OUTPUT'
    EXPORTING
      INPUT         = wa_afko-ftrmi
    IMPORTING
      OUTPUT        = o_stempel_wert
            .



ENDFUNCTION.
