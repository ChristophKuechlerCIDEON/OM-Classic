FUNCTION z_cl_int_write_plot_psb_no_str.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(F_AUT_PROCESS) TYPE  CHAR1 DEFAULT 'X'
*"  TABLES
*"      I_ITAB_ITEMS STRUCTURE  ZCL_PDM_OBJECTS_FA_INT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*  Schreibt Einträge in Tabelle ZCL_PSB_TMP
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 12.06.2003 - Erstellung
* 02.04.2004 - Kopie
*************************************************
* ACHTUNG !  Parallel-FB für Batch Z_CL_WRITE_PLOT_PSB_NOSTR_BTCH
*            bitte gleichlautend anpassen !
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_objects TYPE TABLE OF zcl_pdm_exp_objects.
*WA
  DATA: wa_items TYPE zcl_pdm_objects_fa_int.
  DATA: wa_objects TYPE zcl_pdm_exp_objects.
*NORMAL



  REFRESH itab_objects.
  CLEAR itab_objects.
  CLEAR wa_objects.


  LOOP AT i_itab_items INTO wa_items.
    MOVE-CORRESPONDING wa_items TO wa_objects.

    wa_objects-object_type = 'DOCUMENT'.

    APPEND wa_objects TO itab_objects.
  ENDLOOP.


*call Z_CL_PSBRW_WRITE_PSB_TMP_FRTA

  CALL FUNCTION '/CIDEON/PSBRW_WRT_PSB_TMP_FRTA'
       TABLES
            i_itab_objects = itab_objects
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* mglw. automatischer Durchlauf durch PlotInterface
  IF f_aut_process = 'X'.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
  ELSE.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
  ENDIF.

** Aufruf des PlotInterfaces
  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
*  CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.


* Einstellungen zurücksetzen
*  SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
*  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.

ENDFUNCTION.
