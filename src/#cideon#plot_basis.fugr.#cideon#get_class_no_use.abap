FUNCTION /cideon/get_class_no_use.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NUTZER) TYPE  XUBNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  XUBNAME
*"  TABLES
*"      O_ITAB_CLASS_DATA_NO_USE STRUCTURE  ZCL_V_UG_CL_N_U
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
*   -  holt Merkmalsdaten
*   -
*-----------------------------------------------------------------------
* Journal
* 30.10.2003  Erstellung
*-----------------------------------------------------------------------

*TYPES
  TYPES: BEGIN OF t_gruppe,
      nutzer_gruppe LIKE zcl_g_cls_n_use-nutzer_gruppe,
    END OF t_gruppe.
*ITAB
  DATA: itab_gruppen TYPE TABLE OF zcl_v_ug_cl_n_u.
*WA
  DATA: wa_gruppe TYPE zcl_v_ug_cl_n_u.
*NORMAL

  CLEAR itab_gruppen.
  CLEAR wa_gruppe.

  SELECT * FROM zcl_v_ug_cl_n_u INTO TABLE itab_gruppen
    WHERE nutzer = i_nutzer.
  IF sy-subrc NE 0.
    SELECT * FROM zcl_v_ug_cl_n_u INTO TABLE itab_gruppen
      WHERE nutzer = i_default_nutzer.
    IF sy-subrc NE 0.

    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

  CLEAR o_itab_class_data_no_use.

  o_itab_class_data_no_use[] = itab_gruppen[].



ENDFUNCTION.
