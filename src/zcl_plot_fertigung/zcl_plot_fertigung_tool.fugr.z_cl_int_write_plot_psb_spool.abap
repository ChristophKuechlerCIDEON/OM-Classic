FUNCTION z_cl_int_write_plot_psb_spool.
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
*  Schreibt Einträge in Tabelle ZCL_PSB_TMP für Spooleinträge
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 12.06.2003 - Erstellung
* 23.03.2004 - Kopie
* 11.05.2004 - Abschließen des Spools
*
* SP 147
* 07.03.2011 - CKR
* 7.0.147.3    SR 11142 Empty Spool ID tranferred to OCC
*              bei leere ID, wird jetzt der Eintrag in die Tabelle
*              verweigert
*              FB Z_CL_INT_WRITE_PLOT_PSB_SPOOL
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

    wa_objects-object_type = 'SPOOL'.

    "leere ID
    IF wa_objects-tdspoolid IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

    APPEND wa_objects TO itab_objects.
  ENDLOOP.

* Spoolauftrag locken und abschließen lassen
  LOOP AT i_itab_items INTO wa_items.

    "leere ID
    IF wa_items-tdspoolid IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

    DATA: final TYPE c.
    CLEAR final.
    CALL FUNCTION 'RSPO_FINAL_SPOOLJOB'
      EXPORTING
        rqident             = wa_items-tdspoolid
*       RQ                  =
        set                 = 'X'
      IMPORTING
        final               = final
*       RQ                  =
      EXCEPTIONS
        no_such_job         = 1
        no_permission       = 2
        OTHERS              = 3
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDLOOP.

* RSPO_FINAL_SPOOLJOB


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
*  IF f_aut_process = 'X'.
*    SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
*  ELSE.
*    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
*  ENDIF.

* Aufruf des PlotInterfaces
*  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
*  CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.


* Einstellungen zurücksetzen
*  SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
*  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.

ENDFUNCTION.
