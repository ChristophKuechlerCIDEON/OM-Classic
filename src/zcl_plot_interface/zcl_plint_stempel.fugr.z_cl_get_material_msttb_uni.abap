FUNCTION Z_CL_GET_MATERIAL_MSTTB_UNI .
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
* 15.01.2003 - Erstellung
*-----------------------------------------------------------------------

* gives back the information text about the MARA-MSTAE

*ITAB
*WA
  DATA: wa_t141t LIKE t141t.
*NORMAL
  DATA: spras TYPE spras.

  spras = sy-langu.

  IF i_wa_plotjobs-mstae IS INITIAL.
    CLEAR o_stempel_wert.
    EXIT.
  ELSE.
    CLEAR wa_t141t.
    SELECT * FROM t141t INTO wa_t141t
      WHERE
        spras = spras
        AND mmsta = i_wa_plotjobs-mstae
      .
    ENDSELECT.
    IF sy-subrc NE 0.
*      PERFORM appl_log_write USING
*        'W' '009' 'ZCL_PLINT_TOOLS'
*        i_wa_plotjobs-mstae i_wa_plotjobs-doknr
*        i_wa_plotjobs-dokvr i_wa_plotjobs-doktl.
    ELSE.
      o_stempel_wert = wa_t141t-mtstb.
    ENDIF.
  ENDIF.

ENDFUNCTION.
