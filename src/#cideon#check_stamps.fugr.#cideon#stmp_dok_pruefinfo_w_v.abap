FUNCTION /cideon/stmp_dok_pruefinfo_w_v.
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
  DATA: wa_class_1 TYPE zcl_s_stempel_value.
  DATA: wa_class_2 TYPE zcl_s_stempel_value.
  DATA: wa_class_3 TYPE zcl_s_stempel_value.
  DATA: wa_class_4 TYPE zcl_s_stempel_value.
  DATA: wa_stamp TYPE zcl_s_stempel_value.
  DATA: wa_draw TYPE draw.
*NORMAL


* PLM_PRFG-GRP-LTG-NAM lesen
  CLEAR wa_class_1.
  LOOP AT i_itab_class INTO wa_class_1
    WHERE
      stempel_name = 'PLM_PRFG-GRP-LTG-NAM'
      .
  ENDLOOP.

* PLM_PRFG-NORM-NAM lesen
  CLEAR wa_class_2.
  LOOP AT i_itab_class INTO wa_class_2
    WHERE
      stempel_name = 'PLM_PRFG-NORM-NAM'
      .
  ENDLOOP.

* PLM_PRFG-ABT-LTG-NAM lesen
  CLEAR wa_class_3.
  LOOP AT i_itab_class INTO wa_class_3
    WHERE
      stempel_name = 'PLM_PRFG-ABT-LTG-NAM'
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
*  IF wa_draw-labor = 'BLN'.
*    IF wa_class_1-stempel_wert IS INITIAL
*     OR wa_class_2-stempel_wert IS INITIAL
*     OR wa_class_3-stempel_wert IS INITIAL
*     .
*      o_stempel_wert = 'Prüfinfo auf Papieroriginal'.
*    ELSE.
*      CLEAR o_stempel_wert.
*    ENDIF.
*  ELSE.
*    CLEAR o_stempel_wert.
*  ENDIF.

* Erweiterung am 15.10.2003
  IF wa_draw-labor = 'BLN'
    AND wa_draw-dwnam = 'UEBERNAHME'.
    IF wa_class_1-stempel_wert IS INITIAL
     OR wa_class_2-stempel_wert IS INITIAL
     OR wa_class_3-stempel_wert IS INITIAL
     .
      o_stempel_wert = text-050. "'Prüfinfo auf Papieroriginal'.
    ELSE.
      CLEAR o_stempel_wert.
    ENDIF.
  ELSE.
    CLEAR o_stempel_wert.
  ENDIF.




ENDFUNCTION.
