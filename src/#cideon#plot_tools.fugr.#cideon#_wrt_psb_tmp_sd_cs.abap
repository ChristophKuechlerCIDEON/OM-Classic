FUNCTION /cideon/_wrt_psb_tmp_sd_cs.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DATEINAME_ZIEL) TYPE  FILEP DEFAULT ''
*"     VALUE(I_KNZ_START_OUTPUT) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_KNZ_MERGE) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_KNZ_MERGE_GROUP) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_KNZ_DYN_COV) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_BYPASS_SEARCHLIST) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_KNZ_USE_FILTER) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_BYPASS_PLOTLIST) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_USE_OPERATOR_MODE) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_BATCH) TYPE  CHAR1 DEFAULT ''
*"     VALUE(I_VERTEILER) TYPE  ZCL_NAME_VERTEILER DEFAULT ''
*"     VALUE(I_COUNT_SET) TYPE  CHAR5 DEFAULT ''
*"  TABLES
*"      I_ITAB_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"      I_LT_DAPPL STRUCTURE  TDWP OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*  Schreibt Einträge in Tabelle ZCL_PSB_TMP
*  Anwendung technische Dokumentation Ammann
*  Mischung von DIS und Spoolaufträge, URL
*  Mitgabe von Informationen zu Seitennummern
*----------------------------------------------------------------------
* Author :  C. Küchler
*
* Kontakt:
*           helpdesk@cideon-software.com
*
*----------------------------------------------------------------------
* Journal
* 14.04.2005 - Erstellung
* 18.04.2005 - Mergen mit AO$_MERGE
* 25.04.2005 - I_KNZ_START_OUTPUT
* 26.04.2005 - I_KNZ_MERGE
* 22.08.2007 - I_KNZ_MERGE_GROUP
*              Zusammenfassen auf Guppenebene
* 03.09.2007 - F_DYN_COV
* 02.03.2009 - Kopie
* SP 95
* 01.07.2009 - automtisches Durchlaufen der Plotliste
*              Deutz
*
* SP145
* 17.01.2011 - CKR
*              Verteiler Übergabe
* 18.01.2011 - CKR
* 7.0.145.1    Anpassung
*              /CIDEON/_WRT_PSB_TMP_SD_CS
*              Übergabe eines gesonderten Verteilers
*
* 7.0.148.2  - CKR
* 18.04.2011   Setzen der Satzanzahl in FB /CIDEON/_WRT_PSB_TMP_SD_CS
*
*----------------------------------------------------------------------
* AO$_MERGE: 0 = kein
*            1 = 1. Wert
*            2 = letzter Wert
***********************************************************************
*
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
            i_batch        = i_batch
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

    IF i_verteiler IS INITIAL.
      wa_objects-verteiler = wa_user_data-default_verteiler_dok.
    ELSE.
      wa_objects-verteiler = i_verteiler.
    ENDIF.

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

  "Bypass der Suchliste
  IF i_bypass_searchlist = 'X'.
    SET PARAMETER ID '/CIDEON/OM_BYPASS_PL' FIELD 'X'.
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
  ELSE.
  ENDIF.

  "Filter
  IF i_knz_use_filter = 'X'.
    SET PARAMETER ID '/CIDEON/OM_USE_FILT' FIELD 'X'.

    DATA: ls_tdwp TYPE tdwp.
    DATA: ls_lt_wsa TYPE char200.
    CLEAR ls_lt_wsa.
    LOOP AT i_lt_dappl INTO ls_tdwp.
      CONCATENATE ls_lt_wsa ls_tdwp-dappl
        ';'
        INTO ls_lt_wsa.
    ENDLOOP.

    SET PARAMETER ID '/CIDEON/OM_LT_WSA' FIELD ls_lt_wsa.
  ELSE.
  ENDIF.

  IF i_bypass_plotlist = 'X'.
    SET PARAMETER ID '/CIDEON/OM_BYPASS_PL' FIELD 'X'.
  ELSE.
    SET PARAMETER ID '/CIDEON/OM_BYPASS_PL' FIELD ''.
  ENDIF.


  "Setzen der Satz Informationen
  SET PARAMETER ID '/CIDEON/OM_SET' FIELD i_count_set.


  IF i_knz_start_output = 'X'.
*   Aufruf des PlotInterfaces
    SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
    CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.

*   Einstellungen zurücksetzen
    SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
    SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.


    SET PARAMETER ID '/CIDEON/OM_BYPASS_PL' FIELD ''.
    SET PARAMETER ID '/CIDEON/OM_USE_FILT' FIELD ''.
    SET PARAMETER ID '/CIDEON/OM_LT_WSA' FIELD ''.

    SET PARAMETER ID '/CIDEON/OM_BYPASS_PL' FIELD ''.
  ELSE.
  ENDIF.




ENDFUNCTION.
