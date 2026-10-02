FUNCTION /CIDEON/STMP_VBELN_TEST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  TABLES
*"      I_ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE
*"      I_ITAB_CLASS STRUCTURE  ZCL_S_STEMPEL_VALUE
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   -
*   -
*-----------------------------------------------------------------------
* Beschreibung

*-----------------------------------------------------------------------
* Journal
* 29.07.2003
*-----------------------------------------------------------------------

*TYPES
*ITAB
*WA
  DATA: wa_plm_erzeug_sys TYPE zcl_s_stempel_value.
  DATA: wa_class TYPE zcl_s_stempel_value.
  DATA: wa_stamp TYPE zcl_s_stempel_value.
  DATA: wa_draw TYPE draw.
*NORMAL


* PLM_ERZEUG_SYST_LESEN
  CLEAR wa_class.
  LOOP AT i_itab_stamps INTO wa_stamp
    WHERE
      stempel_name = 'VBELN'
      .
  ENDLOOP.



* Entscheidung
  IF wa_stamp-stempel_wert IS INITIAL.
    o_stempel_wert = text-001.
  ELSE.
  ENDIF.

*  CLEAR o_stempel_wert.



ENDFUNCTION.
