FUNCTION /cideon/get_class_no_use_stamp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_NUTZER) TYPE  XUBNAME
*"             VALUE(I_DEFAULT_NUTZER) TYPE  XUBNAME
*"       TABLES
*"              O_ITAB_CLASS_DATA_NO_USE STRUCTURE  ZCL_V_UG_CL_N_U
*"       EXCEPTIONS
*"              ERROR
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
      nutzer_gruppe LIKE zclg_cls_n_use_s-nutzer_gruppe,
    END OF t_gruppe.
*ITAB
  DATA: itab_gruppen TYPE TABLE OF zclv_ug_cl_n_u_s.
*WA
  DATA: wa_gruppe TYPE zclv_ug_cl_n_u_s.
*NORMAL

  CLEAR itab_gruppen.
  CLEAR wa_gruppe.

  SELECT * FROM zclv_ug_cl_n_u_s INTO TABLE itab_gruppen
    WHERE nutzer = i_nutzer.
  IF sy-subrc NE 0.
    SELECT * FROM zclv_ug_cl_n_u_s INTO TABLE itab_gruppen
      WHERE nutzer = i_default_nutzer.
    IF sy-subrc NE 0.

    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

  CLEAR o_itab_class_data_no_use.

  o_itab_class_data_no_use[] = itab_gruppen[].



ENDFUNCTION.
