FUNCTION z_cl_psbrw_wrt_psb_tmp_sd_cs.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DATEINAME_ZIEL) TYPE  FILEP
*"     VALUE(I_KNZ_START_OUTPUT) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_KNZ_MERGE) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_KNZ_MERGE_GROUP) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_KNZ_DYN_COV) TYPE  CHAR1 DEFAULT ''
*"  TABLES
*"      I_ITAB_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*  Schreibt Einträge in Tabelle ZCL_PSB_TMP
*  Anwendung technische Dokumentation Ammann
*  Mischung von DIS und Spoolaufträge
*  Mitgabe von Informationen zu Seitennummern
*-----------------------------------------------------------------------
* Author :  C. Küchler
*
* Anpassungen:

*
* Kontakt:
*           helpdesk@cideon-software.com
*
*-----------------------------------------------------------------------
* Journal
* 14.04.2005 - Erstellung
* 18.04.2005 - Mergen mit AO$_MERGE
* 25.04.2005 - I_KNZ_START_OUTPUT
* 26.04.2005 - I_KNZ_MERGE
* 22.08.2007 - I_KNZ_MERGE_GROUP
*              Zusammenfassen auf Guppenebene
* 03.09.2007 - F_DYN_COV
* 02.03.2009 - SP 89
*              Umbau auf /CIDEON/
*-----------------------------------------------------------------------
* AO$_MERGE: 0 = kein
*            1 = 1. Wert
*            2 = letzter Wert
************************************************************************




  CALL FUNCTION '/CIDEON/_WRT_PSB_TMP_SD_CS'
       EXPORTING
            i_dateiname_ziel   = i_dateiname_ziel
            i_knz_start_output = i_knz_start_output
            i_knz_merge        = i_knz_merge
            i_knz_merge_group  = i_knz_merge_group
            i_knz_dyn_cov      = i_knz_dyn_cov
       TABLES
            i_itab_objects     = i_itab_objects
       EXCEPTIONS
            error              = 1
            OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  EXIT.



*ITAB
*WA
  DATA: wa_objects LIKE i_itab_objects.
  DATA: wa_user_data TYPE /cideon/plot_userdata.
  DATA: wa_default_data TYPE /cideon/plot_defaultdata.
*NORMAL
  DATA: index TYPE i.

* Einstellungen lesen
  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = ''
       IMPORTING
            o_default_data = wa_default_data.
  CLEAR user_data.

  user_data-uname = sy-uname.

  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = wa_default_data
       IMPORTING
            o_user_data    = wa_user_data.


* Zieldateiname setzen
* Verteiler + Kennzeichen Automatik setzen
  LOOP AT i_itab_objects INTO wa_objects.
    index = sy-tabix.
    wa_objects-dateiname_ziel = i_dateiname_ziel.
    wa_objects-verteiler = wa_user_data-default_verteiler_dok.

*   AO$_MERGE = 1
    IF i_knz_merge = 'X'.
      wa_objects-ao_merge = '1'.
    ELSE.
      wa_objects-ao_merge = '0'.
    ENDIF.

*   MERGE_GROUP
    IF i_knz_merge_group = 'X'.
      wa_objects-f_dyn_toc = '1'.
    ELSE.
      wa_objects-f_dyn_toc = '0'.
    ENDIF.

*   Dyn Cover
    IF i_knz_dyn_cov = 'X'.
      wa_objects-f_dyn_cov = '1'.
    ELSE.
      wa_objects-f_dyn_cov = '0'.
    ENDIF.

    MODIFY i_itab_objects FROM wa_objects INDEX index.
  ENDLOOP.



* Übergabe in ZCL_PSB_TMP
  CALL FUNCTION '/CIDEON/PSBRW_WRT_PSB_TMP_FRTA'
       TABLES
            i_itab_objects = i_itab_objects
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* mglw. automatischer Durchlauf durch PlotInterface
  IF wa_user_data-knz_auto_dok = 'X'.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
  ELSE.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
  ENDIF.

  IF i_knz_start_output = 'X'.
*   Aufruf des PlotInterfaces
    SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
    CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.

*   Einstellungen zurücksetzen
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
    SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.
  ELSE.
  ENDIF.

ENDFUNCTION.
