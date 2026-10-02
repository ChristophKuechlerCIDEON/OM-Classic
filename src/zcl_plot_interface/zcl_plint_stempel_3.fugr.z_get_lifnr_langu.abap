FUNCTION z_get_lifnr_langu.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"       EXPORTING
*"             VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*  Ermittlung Sprache des Lieferanten
*-----------------------------------------------------------------------
* Author :  Matthias Bartsch
*-----------------------------------------------------------------------
* Journal
* 26.02.2010 - Erstellung
*-----------------------------------------------------------------------
*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL

  DATA: lc_bukrs TYPE lfb1-bukrs,
      lc_lifnr TYPE lfa1-lifnr.

  DATA: ls_e_lfa1 TYPE lfa1,
        ls_e_lfb1 TYPE lfb1.


  wa_plotjob = i_wa_plotjobs.

  CLEAR lc_bukrs.
  lc_lifnr = wa_plotjob-lifnr.

** Lieferantendaten lesen.
  CALL FUNCTION 'VENDOR_READ'
       EXPORTING
            i_bukrs   = lc_bukrs
            i_lifnr   = lc_lifnr
       IMPORTING
            e_lfa1    = ls_e_lfa1
            e_lfb1    = ls_e_lfb1
       EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

  IF sy-subrc <> 0.
    CLEAR o_stempel_wert.
    EXIT.
  ENDIF.

** Sprache des Lieferanten
** wenn English dann 'X'
  IF ls_e_lfa1-spras EQ 'EN'.
    o_stempel_wert = 'X'.
  ELSE.
    CLEAR o_stempel_wert.
  ENDIF.

ENDFUNCTION.
