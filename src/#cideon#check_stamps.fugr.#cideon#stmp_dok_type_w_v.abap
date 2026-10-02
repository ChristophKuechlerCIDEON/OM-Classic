FUNCTION /cideon/stmp_dok_type_w_v.
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
*   - Module für Willy Vogel
*   - Implementation laut Spezifikation Stempeleinrichtungen
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
  LOOP AT i_itab_class INTO wa_class
    WHERE
      stempel_name = 'PLM_ERZEUG_SYS'
      .
  ENDLOOP.

* Feld LABOR lesen
  CLEAR wa_draw.
  SELECT SINGLE * FROM draw INTO wa_draw
    WHERE dokar = i_wa_plotjobs-dokar
    AND doknr = i_wa_plotjobs-doknr
    AND doktl = i_wa_plotjobs-doktl
    AND dokvr = i_wa_plotjobs-dokvr
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


* Entscheidung
  IF wa_class-stempel_wert = 'Scan'
     OR wa_class-stempel_wert = 'SCAN'
     OR wa_draw-labor = 'HOC'
     OR wa_draw-labor = 'BLN'.
    o_stempel_wert = wa_draw-dokar .
  ELSE.
    CLEAR o_stempel_wert.
  ENDIF.



ENDFUNCTION.
