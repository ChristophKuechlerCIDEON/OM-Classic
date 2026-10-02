FUNCTION /cideon/psbrw_obj_release_frta.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"     REFERENCE(FM_NAME) TYPE  RS38L_FNAM
*"  TABLES
*"      SELECTED_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------

***********************************************************************
* Journal
* 12.05.2005 - Erstellung
* 13.05.2005 - Integration des Materialstücklistendrucks
* 25.05.2005 - Weitergabe von Informationen bei Materialstücklisten-
*              auflösung
*              Rangfolgeliste auch bei Materialstücklisten beachten
* 10.06.2005 - Anpassungen für itelligence / B. Krone
* 20.06.2005 - Übergabe des Auflösungsdatums für Materialstücklisten-
*              Auflösung BOM_DATUV
* 02.09.2005 - IW22-26
* 30.09.2005 - Weitergabe der Meldungswerte aus Stücklisten
*              baustein
* 06.01.2006 - ME21N - ME24N
* 24.01.2006 - Übergabe von LIFNR etc. auch bei Dokumentpositionen der
*              Stückliste
* 30.01.2006 - Erweiterung des BADI für Rangliste
* 30.03.2006 - STLAL auf internes Format konvertieren
* 31.03.2006 - STLNR / AENNR für Stückliste -> Spool
* 24.07.2006 - Integration in Dokumente spezial / Stücklistendruck
* 18.10.2006 - Übergabe der Sprache zur Ausgabe der Stücklisten
* 19.11.2007 - SP58
*              Anbindung an /CIDEON/MNT_PLOT_LOG
* 07.02.2008 - SP 65
*              Integration BADI, um übergebene Objekte weiter
*              anzupassen
* 06.05.2008 - SP 074
* 07.05.2008 - SP 075
*              Umbau, daß nur der Hinweis auf nicht freigegebene
*              Funktion kommt.
* 07.10.2008 - SP 81
*              /CIDEON/SPSO als TA
* 27.10.2008 - SP 84
*              neue BADI Methode CHG_SEL_OBJ_INIT
* 28.10.2008 - EBELP Übergabe
*
* V 104
* 28.09.2009 - Stücklistenlevel an BOm Ausgabe übergeben
*
* 29.09.2009 - Übergabe des Gültigkeitsdatums / Auflösungsdatum
*
* SP 107
* 09.10.2009 - /CIDEON/PSBRW_OBJ_RELEASE_FRTA
*              Freigabe für Lieferplan ME38
*              -> B. Krone
*
* 7.0.1.23   - SR 8516 - Purchase Order - Default Distributor
*              HST
*            - /CIDEON/PSBRW_OBJ_RELEASE_FRTA
*
***********************************************************************
* toDo
*    - Testen, ob Stückliste in Gültigkeitsdatum liegt
*    -
***********************************************************************
*ITAB
  DATA: itab_drad TYPE TABLE OF drad.
  DATA: itab_mara TYPE TABLE OF mara.
  DATA: itab_stpo TYPE TABLE OF stpo.
  DATA: itab_dok TYPE TABLE OF stpox.
  DATA: itab_txt TYPE TABLE OF stpox.
  DATA: itab_mast TYPE TABLE OF mast.

  DATA: itab_draw TYPE TABLE OF draw.
  DATA: itab_objects TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: itab_spoolids TYPE tsfspoolid.

  DATA: selected_objects_tmp TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: selected_objects_result TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: itab_mat_dokar_prio_list TYPE TABLE OF dokar.
  DATA: drad_objects_badi TYPE dms_tbl_drad.
  DATA: stpox_objects_badi TYPE /cideon/ttype_s_stpox.
*WA
  DATA: wa_drad TYPE drad.
  DATA: wa_mara TYPE mara.
  DATA: wa_stpo TYPE stpo.
  DATA: wa_stpox TYPE stpox.
  DATA: wa_mast TYPE mast.

  DATA: wa_draw TYPE draw.
  DATA: wa_objects TYPE zcl_pdm_exp_objects.
  DATA: wa_objects_tmp TYPE zcl_pdm_exp_objects.

  DATA: wa_default_data TYPE /cideon/plot_defaultdata.
  DATA: wa_user_data TYPE /cideon/plot_userdata.
  DATA: return TYPE bapiret2.
  DATA: wa_bom_print TYPE  /cideon/bom_print.
  DATA: wa_spoolids TYPE rspoid.

  DATA: wa_dokar TYPE dokar.
*NORMAL
  DATA: save_tcode LIKE sy-tcode.

  DATA: lc_transaction_name TYPE tcode.

  DATA: drad_key TYPE drad-objky.
  DATA: drad_objekt TYPE drad-dokob.

  DATA: index TYPE i.
  DATA: f_read_settings VALUE ''.
  DATA: spoolid TYPE tsfspoolid.

  DATA: f_found_dokar.
  DATA: index_drad TYPE i.
  DATA: index_dok TYPE i.

* BADI
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.

* BADI initialisieren
  CLEAR badi_main_pre_001.
  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
    CLEAR badi_main_pre_001.
  ELSE.
  ENDIF.

  CLEAR wa_objects.
  REFRESH itab_objects.
  CLEAR save_tcode.

  CLEAR wa_user_data.
  CLEAR wa_default_data.


  CASE sy-tcode.
    WHEN 'CV03N'.
      save_tcode = 'CC04'.
      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD'X'.
    WHEN OTHERS.
      save_tcode = sy-tcode.
      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD'X'.
  ENDCASE.

* Generalisierung für die Transaktionen der Bestellanforderung,
* Lieferplan
  IF sy-tcode CS 'ME5'.
    IF sy-fdpos = 0.
      save_tcode = 'ME5X'.
    ENDIF.
  ENDIF.
  IF sy-tcode CS 'ME32' OR sy-tcode CS 'ME33'.
    IF sy-fdpos = 0.
      save_tcode = 'ME32X'.
    ENDIF.
  ENDIF.

  CASE save_tcode.
    WHEN 'CC04'
      OR 'CSMB'
      OR 'CL30N'
      OR 'CV04N'
      OR 'CSKB'
      OR '' "CAD Desktop schreibt keinen TCODE
      OR 'CDESK'
      OR 'ME5X'        " Bestellanforderung
      OR 'IW31'        " Instandhaltungsauftrag anlegen
      OR 'IW32'        " Instandhaltungsauftrag ändern
      OR 'IW33'        " Instandhaltungsauftrag anzeigen
      OR 'IE01'
      OR 'IE02'        " Equipment ändern
      OR 'IE03'        " Equipment anzeigen
      OR 'IL01'        " Technischen Platz anlegen
      OR 'IL02'        " Technischen Platz ändern
      OR 'IL03'        " Technischen Platz anzeigen

      OR 'ME32X'       " Lieferplan ändern / anzeigen
      OR 'ME36'
      OR 'ME37'
      OR 'ME38'

      OR 'ME42'        " Anfrage ändern
      OR 'ME43'        " Anfrage anzeigen
      OR 'ME47'        " Angebot pflegen
      OR 'ME48'        " Angebot anzeigen

      OR 'VA12'        " Verkauf Anfrage ändern
      OR 'VA13'        " Verkauf Anfrage anzeigen
      OR 'VA22'        " Verkauf Angebot ändern
      OR 'VA23'        " Verkauf Angebot anzeigen
      OR 'VA02'        " Verkauf Auftrag ändern
      OR 'VA03'        " Verkauf Auftrag anzeigen
      OR 'SE37'
      OR 'ME21'        " Bestellung anlegen
      OR 'ME21N'
      OR 'ME22N'
      OR 'ME22'
      OR 'ME23N'
      OR 'ME23'
      OR 'CJ20N'       " Projektbuilder
      OR 'SRMSTART'    " Records Management (nur ab 4.7)
*     Anpassungen itelligence / B. Krone
      OR 'SE38'
      OR 'SA38'
      OR 'ZPLM12'
      OR 'IW21'        " Instandhaltungsmeldung
      OR 'IW22'
      OR 'IW23'
      OR 'IW24'
      OR 'IW25'
      OR 'IW26'

      OR 'ZCL_PLOT_INTERFACE'        " Integration Dokumente spezial
      OR '/CIDEON/MNT_PLOT_LOG'      " lieferantenmahnung

      OR 'MD01'        " Bedarfs- Bestandsliste
      OR 'MD02'
      OR 'MD03'
      OR 'MD04'

      OR '/CIDEON/SPSO'
      .


    WHEN OTHERS.
      MESSAGE s002(zcl_prod_struk_brws)
        WITH '' '' '' '' .
      "RAISE error.
      "EXIT.
  ENDCASE.

* BADI vor Verarbeitung
  CALL METHOD badi_main_pre_001->chg_sel_obj_init
    CHANGING
      selected_objects = selected_objects[]
      return           = return
     EXCEPTIONS
       cancel           = 1
       OTHERS           = 2
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
         RAISING error.
  ENDIF.


*  lc_transaction_name = 'ZCL_PLOT_INTERFACE'.
*  CALL TRANSACTION lc_transaction_name.

*     Integration des Materialstücklistendrucks
*     Durchlaufen der Tabelle und Test auf Spoolausgaben
*     Test, ob Materialdrucke benötigt werden, dann Lesen der
*     Einstellungen
  CLEAR f_read_settings.
  LOOP AT selected_objects INTO wa_objects
    WHERE f_cs03 = 'X'
    OR f_cs11 = 'X'
    OR f_cs12 = 'X'
    OR f_cs13 = 'X'
    OR object_type = 'BILLOFMAT'
    OR object_type = 'BOMITEM'
    OR object_type = 'MATERIAL'
    OR object_type_original = 'MARA'
    .
    f_read_settings = 'X'.
    EXIT.
  ENDLOOP.

  IF f_read_settings = 'X'.
    CLEAR wa_user_data.
    CLEAR wa_default_data.

    CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
         EXPORTING
              i_batch        = ''
         IMPORTING
              o_default_data = wa_default_data.


    CALL FUNCTION '/CIDEON/READ_USERDATA'
         EXPORTING
              i_default_data = wa_default_data
         IMPORTING
              o_user_data    = wa_user_data.

*       Prioritätenliste für Dokumentarten
    IF wa_user_data-mat_dokar_prio_list IS INITIAL.
    ELSE.
*         Tabelle erstellen
      CLEAR itab_mat_dokar_prio_list.
      SPLIT wa_user_data-mat_dokar_prio_list
        AT '/'
        INTO TABLE itab_mat_dokar_prio_list.
    ENDIF.

  ELSE.
  ENDIF.

*     Prioritätenliste
*     Übergabe mit DOCUMENT_TYPE_ORIGINAL = 'MARA'
*     object_key_original = Materialnummer
*     Bereinigung der übergebenen Liste
  CLEAR selected_objects_tmp.
  CLEAR selected_objects_result.

  IF itab_mat_dokar_prio_list[] IS INITIAL.
  ELSE.
*       BADI Aufruf, um die Liste der übergebenen Dokumente
*       zu manipulieren
    CLEAR return.
    CLEAR badi_main_pre_001.
    CALL METHOD cl_exithandler=>get_instance
      CHANGING
        instance = badi_main_pre_001.
    IF sy-subrc NE 0.
    ELSE.
      DATA: selected_objects_badi TYPE /cideon/ttype_s_selobjects.
      CLEAR selected_objects_badi.
*         Inhalte übergeben
      selected_objects_badi[] = selected_objects[].
      CLEAR return.
      CALL METHOD badi_main_pre_001->chg_sel_obj_before_prio
        CHANGING
          selected_objects = selected_objects_badi
          return           = return
          .
      IF return IS INITIAL.
*           Inhalte übergeben
        selected_objects[] = selected_objects_badi[].
      ELSE.
      ENDIF.
    ENDIF.


    CALL FUNCTION 'Z_CL_PSBRW_MAT_DOK_PRIO_CHECK'
         EXPORTING
              i_mat_dokar_prio_list = wa_user_data-mat_dokar_prio_list
         TABLES
              i_selected_objects    = selected_objects
              o_selected_objects    = selected_objects_result
         EXCEPTIONS
              error                 = 1
              OTHERS                = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
*       Übergabe der Resultate in normale Tabelle
    selected_objects[] = selected_objects_result[].

  ENDIF.




*     Integration des Materialstücklistendrucks
  LOOP AT selected_objects INTO wa_objects.
    index = sy-tabix.
*       Konvertierung auf internes Format für STLAL
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              input  = wa_objects-stlal
         IMPORTING
              output = wa_objects-stlal.
    MODIFY selected_objects FROM wa_objects INDEX sy-tabix.

    IF wa_objects-object_type = 'BILLOFMAT'.
      IF wa_objects-f_cs13 = 'X'.
*           Druck erstellen
        CLEAR spoolid.
        CLEAR return.
        CLEAR wa_bom_print.

        wa_bom_print-formname = wa_user_data-smartform_cs13.
        wa_bom_print-capid = wa_user_data-mat_capid.
        wa_bom_print-explv = wa_user_data-mat_stpst.
        wa_bom_print-werks = wa_objects-werks.
        wa_bom_print-stlan = wa_objects-stlan.
        wa_bom_print-stlal = wa_objects-stlal.
        wa_bom_print-bomtype = 'CS13'.
        wa_bom_print-bomausp = ''.
        wa_bom_print-datuv = wa_user_data-bom_datuv.
        IF wa_objects-ccdat IS INITIAL.
        ELSE.
          wa_bom_print-datuv = wa_objects-ccdat.
        ENDIF.

        wa_bom_print-spras = wa_objects-cs13_spras.

*           Test, ob Funktionsbaustein vorhanden ist
        PERFORM check_fb__mat_bom_print.

*           Test, ob Stückliste im Gültigkeitsraum ist
        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_CHK_SLK'
          EXPORTING
            matnr           = wa_objects-matnr
            bom_print       = wa_bom_print
          IMPORTING
*               RETURN          =
            aennr           = wa_objects-aennr
            stlnr           = wa_objects-stlnr
          EXCEPTIONS
            no_stko         = 1
            OTHERS          = 2
                  .
        IF sy-subrc <> 0.
          IF sy-subrc = '1'.
*               keine Stückliste / Kein Kopf
            MESSAGE i013(zcl_prod_struk_brws)
              WITH
              wa_bom_print-datuv wa_objects-matnr
              wa_bom_print-stlal wa_bom_print-stlan.
            DELETE selected_objects INDEX index.
            CONTINUE.
          ELSE.
          ENDIF.
        ELSE.
        ENDIF.

        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_PRINT'
             EXPORTING
                  matnr     = wa_objects-matnr
                  bom_print = wa_bom_print
                  tddest    = wa_user_data-mat_tddest
                  tdprinter = wa_user_data-mat_tdprinter
             IMPORTING
                  spoolids  = itab_spoolids
                  return    = return.
        IF return IS INITIAL.
        ELSE.
*             Benutzung des Returnwertes
          MESSAGE ID return-id TYPE return-type
            NUMBER return-number
            WITH return-message_v1 return-message_v2
            wa_objects-matnr wa_bom_print-formname.

          MESSAGE e010(zcl_prod_struk_brws)
            WITH wa_objects-matnr wa_bom_print-formname
            '' ''.
        ENDIF.
        CLEAR wa_spoolids.
        READ TABLE itab_spoolids INTO wa_spoolids INDEX 1.

*           Eintrag für Spool erstellen
        CLEAR wa_objects-f_cs13.
        wa_objects-object_type = 'SPOOL'.
        wa_objects-tdspoolid = wa_spoolids.
        wa_objects-doknr = wa_spoolids.
        DELETE selected_objects INDEX index.
        INSERT wa_objects INTO selected_objects
          INDEX index.
        CONTINUE.
      ELSE.
      ENDIF.
      IF wa_objects-f_cs12 = 'X'.
*           Druck erstellen
        CLEAR spoolid.
        CLEAR return.
        CLEAR wa_bom_print.

        wa_bom_print-formname = wa_user_data-smartform_cs12.
        wa_bom_print-capid = wa_user_data-mat_capid.
        wa_bom_print-explv = wa_user_data-mat_stpst.
        wa_bom_print-werks = wa_objects-werks.
        wa_bom_print-stlan = wa_objects-stlan.
        wa_bom_print-stlal = wa_objects-stlal.
        wa_bom_print-bomtype = 'CS12'.
        wa_bom_print-bomausp = ''.
        wa_bom_print-datuv = wa_user_data-bom_datuv.
        IF wa_objects-ccdat IS INITIAL.
        ELSE.
          wa_bom_print-datuv = wa_objects-ccdat.
        ENDIF.

        wa_bom_print-spras = wa_objects-cs12_spras.

*           Test, ob Funktionsbaustein vorhanden ist
        PERFORM check_fb__mat_bom_print.

*           Test, ob Stückliste im Gültigkeitsraum ist
        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_CHK_SLK'
          EXPORTING
            matnr           = wa_objects-matnr
            bom_print       = wa_bom_print
          IMPORTING
*               RETURN          =
            aennr           = wa_objects-aennr
            stlnr           = wa_objects-stlnr
          EXCEPTIONS
            no_stko         = 1
            OTHERS          = 2
                  .
        IF sy-subrc <> 0.
          IF sy-subrc = '1'.
*               keine Stückliste / Kein Kopf
            MESSAGE i013(zcl_prod_struk_brws)
              WITH
              wa_bom_print-datuv wa_objects-matnr
              wa_bom_print-stlal wa_bom_print-stlan.
            DELETE selected_objects INDEX index.
            CONTINUE.
          ELSE.
          ENDIF.
        ELSE.
        ENDIF.

        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_PRINT'
             EXPORTING
                  matnr     = wa_objects-matnr
                  bom_print = wa_bom_print
                  tddest    = wa_user_data-mat_tddest
                  tdprinter = wa_user_data-mat_tdprinter
             IMPORTING
                  spoolids  = itab_spoolids
                  return    = return.
        IF return IS INITIAL.
        ELSE.
*             Benutzung des Returnwertes
          MESSAGE ID return-id TYPE return-type
            NUMBER return-number
            WITH return-message_v1 return-message_v2
            wa_objects-matnr wa_bom_print-formname.

          MESSAGE e010(zcl_prod_struk_brws)
            WITH wa_objects-matnr wa_bom_print-formname
            '' ''.
        ENDIF.
        CLEAR wa_spoolids.
        READ TABLE itab_spoolids INTO wa_spoolids INDEX 1.

*           Eintrag für Spool erstellen
        CLEAR wa_objects-f_cs12.
        wa_objects-object_type = 'SPOOL'.
        wa_objects-tdspoolid = wa_spoolids.
        wa_objects-doknr = wa_spoolids.
        DELETE selected_objects INDEX index.
        INSERT wa_objects INTO selected_objects
          INDEX index.
        CONTINUE.
      ELSE.
      ENDIF.

      IF wa_objects-f_cs11 = 'X'.
*           Druck erstellen
        CLEAR spoolid.
        CLEAR return.
        CLEAR wa_bom_print.

        wa_bom_print-formname = wa_user_data-smartform_cs11.
        wa_bom_print-capid = wa_user_data-mat_capid.
        wa_bom_print-explv = wa_user_data-mat_stpst.
        wa_bom_print-werks = wa_objects-werks.
        wa_bom_print-stlan = wa_objects-stlan.
        wa_bom_print-stlal = wa_objects-stlal.
        wa_bom_print-bomtype = 'CS11'.
        wa_bom_print-bomausp = ''.
        wa_bom_print-datuv = wa_user_data-bom_datuv.
        IF wa_objects-ccdat IS INITIAL.
        ELSE.
          wa_bom_print-datuv = wa_objects-ccdat.
        ENDIF.

        wa_bom_print-spras = wa_objects-cs11_spras.

*           Test, ob Funktionsbaustein vorhanden ist
        PERFORM check_fb__mat_bom_print.

*           Test, ob Stückliste im Gültigkeitsraum ist
        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_CHK_SLK'
          EXPORTING
            matnr           = wa_objects-matnr
            bom_print       = wa_bom_print
          IMPORTING
*               RETURN          =
            aennr           = wa_objects-aennr
            stlnr           = wa_objects-stlnr
          EXCEPTIONS
            no_stko         = 1
            OTHERS          = 2
                  .
        IF sy-subrc <> 0.
          IF sy-subrc = '1'.
*               keine Stückliste / Kein Kopf
            MESSAGE i013(zcl_prod_struk_brws)
              WITH
              wa_bom_print-datuv wa_objects-matnr
              wa_bom_print-stlal wa_bom_print-stlan.
            DELETE selected_objects INDEX index.
            CONTINUE.
          ELSE.
          ENDIF.
        ELSE.
        ENDIF.

        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_PRINT'
             EXPORTING
                  matnr     = wa_objects-matnr
                  bom_print = wa_bom_print
                  tddest    = wa_user_data-mat_tddest
                  tdprinter = wa_user_data-mat_tdprinter
             IMPORTING
                  spoolids  = itab_spoolids
                  return    = return.
        IF return IS INITIAL.
        ELSE.
*             Benutzung des Returnwertes
          MESSAGE ID return-id TYPE return-type
            NUMBER return-number
            WITH return-message_v1 return-message_v2
            wa_objects-matnr wa_bom_print-formname.

          MESSAGE e010(zcl_prod_struk_brws)
            WITH wa_objects-matnr wa_bom_print-formname
            '' ''.
        ENDIF.
        CLEAR wa_spoolids.
        READ TABLE itab_spoolids INTO wa_spoolids INDEX 1.

*           Eintrag für Spool erstellen
        CLEAR wa_objects-f_cs11.
        wa_objects-object_type = 'SPOOL'.
        wa_objects-tdspoolid = wa_spoolids.
        wa_objects-doknr = wa_spoolids.
        DELETE selected_objects INDEX index.
        INSERT wa_objects INTO selected_objects
          INDEX index.
        CONTINUE.
      ELSE.
      ENDIF.

      IF wa_objects-f_cs03 = 'X'.
*           Druck erstellen
        CLEAR spoolid.
        CLEAR return.
        CLEAR wa_bom_print.

        wa_bom_print-formname = wa_user_data-smartform_cs02.
        wa_bom_print-capid = wa_user_data-mat_capid.
        wa_bom_print-explv = wa_user_data-mat_stpst.
        wa_bom_print-werks = wa_objects-werks.
        wa_bom_print-stlan = wa_objects-stlan.
        wa_bom_print-stlal = wa_objects-stlal.
        wa_bom_print-bomtype = 'CS03'.
        wa_bom_print-bomausp = 'A'.
        wa_bom_print-datuv = wa_user_data-bom_datuv.
        IF wa_objects-ccdat IS INITIAL.
        ELSE.
          wa_bom_print-datuv = wa_objects-ccdat.
        ENDIF.

        wa_bom_print-spras = wa_objects-cs03_spras.

*           Test, ob Funktionsbaustein vorhanden ist
        PERFORM check_fb__mat_bom_print.

*           Test, ob Stückliste im Gültigkeitsraum ist
        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_CHK_SLK'
          EXPORTING
            matnr           = wa_objects-matnr
            bom_print       = wa_bom_print
         IMPORTING
*               RETURN          =
            aennr           = wa_objects-aennr
            stlnr           = wa_objects-stlnr
          EXCEPTIONS
            no_stko         = 1
            OTHERS          = 2
                  .
        IF sy-subrc <> 0.
          IF sy-subrc = '1'.
*               keine Stückliste / Kein Kopf
            MESSAGE i013(zcl_prod_struk_brws)
              WITH
              wa_bom_print-datuv wa_objects-matnr
              wa_bom_print-stlal wa_bom_print-stlan.
            DELETE selected_objects INDEX index.
            CONTINUE.
          ELSE.
          ENDIF.
        ELSE.
        ENDIF.

        CALL FUNCTION '/CIDEON/MATNR_MAT_BOM_PRINT'
             EXPORTING
                  matnr     = wa_objects-matnr
                  bom_print = wa_bom_print
                  tddest    = wa_user_data-mat_tddest
                  tdprinter = wa_user_data-mat_tdprinter
             IMPORTING
                  spoolids  = itab_spoolids
                  return    = return.
        IF return IS INITIAL.
        ELSE.
*             Benutzung des Returnwertes
          MESSAGE ID return-id TYPE return-type
            NUMBER return-number
            WITH return-message_v1 return-message_v2
            wa_objects-matnr wa_bom_print-formname.

          MESSAGE e010(zcl_prod_struk_brws)
            WITH wa_objects-matnr wa_bom_print-formname
            '' ''.
        ENDIF.
        CLEAR wa_spoolids.
        READ TABLE itab_spoolids INTO wa_spoolids INDEX 1.

*           Eintrag für Spool erstellen
        CLEAR wa_objects-f_cs03.
        wa_objects-object_type = 'SPOOL'.
        wa_objects-tdspoolid = wa_spoolids.
        wa_objects-doknr = wa_spoolids.
        DELETE selected_objects INDEX index.
        INSERT wa_objects INTO selected_objects
          INDEX index.
        CONTINUE.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.

  ENDLOOP.

*     BADI Integration, um Tabelle der Übergebenen Dokumente zu ändern
  CLEAR return.

  CALL METHOD badi_main_pre_001->chg_sel_obj_before_proc
    CHANGING
      selected_objects = selected_objects[]
      return           = return
     EXCEPTIONS
       cancel           = 1
       OTHERS           = 2
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
         RAISING error.
  ENDIF.




*     normaler Produktstrukturbrowser
  LOOP AT selected_objects INTO wa_objects.
    CASE wa_objects-object_type.
      WHEN 'DOCUMENT' OR 'BILLOFDOC'.
        IF ( wa_objects-dokar IS INITIAL )
        OR ( wa_objects-doknr IS INITIAL )
        OR ( wa_objects-dokvr IS INITIAL )
        OR ( wa_objects-doktl IS INITIAL )
        .
        ELSE.
          APPEND wa_objects TO itab_objects.
        ENDIF.
      WHEN 'BILLOFMAT' OR 'BOMITEM' OR 'MATERIAL'.
        IF  wa_objects-matnr IS INITIAL
        .
        ELSE.
          REFRESH itab_mara.
          CLEAR wa_mara.
          CASE wa_objects-object_type.
            WHEN 'BILLOFMAT'.
              CALL FUNCTION 'Z_CL_GET_BILLOFMAT_ALL'
                   EXPORTING
                        i_matnr      = wa_objects-matnr
                        i_stlan      = wa_objects-stlan
                        i_stlal      = wa_objects-stlal
                        i_werks      = wa_objects-werks
                        i_datum      = sy-datum
                   TABLES
                        o_itab_matnr = itab_mara
                        o_itab_dok   = itab_dok
                        o_itab_txt   = itab_txt
                   EXCEPTIONS
                        error        = 1
                        OTHERS       = 2.
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.
*                  wa_mara-matnr = wa_objects-matnr.
*                  APPEND wa_mara TO itab_mara.
            WHEN 'BOMITEM'.
              wa_mara-matnr = wa_objects-matnr.
              APPEND wa_mara TO itab_mara.
            WHEN 'MATERIAL'.
              wa_mara-matnr = wa_objects-matnr.
              APPEND wa_mara TO itab_mara.

*                 Suche nach vorhandenen Stücklisten
              REFRESH itab_mast.
              SELECT * FROM mast INTO TABLE itab_mast
                WHERE matnr = wa_objects-matnr.
              IF sy-subrc NE 0.
              ELSE.
                LOOP AT itab_mast INTO wa_mast.
                  "CLEAR wa_objects.
                  wa_objects-object_type = 'BILLOFMAT'.
                  wa_objects-stlan = wa_mast-stlan.
                  wa_objects-stlnr = wa_mast-stlnr.
                  wa_objects-stlal = wa_mast-stlal.
                  APPEND wa_objects TO selected_objects.
                ENDLOOP.
              ENDIF.

          ENDCASE.

          REFRESH itab_drad.
          CLEAR itab_drad.

*             get object doc links
          LOOP AT itab_mara INTO wa_mara.
            wa_objects-matnr = wa_mara-matnr.
            SELECT * FROM drad INTO TABLE itab_drad
             WHERE dokob = 'MARA'
             AND objky = wa_objects-matnr
             .
            IF sy-subrc NE 0.
            ELSE.
            ENDIF.
            CLEAR wa_objects_tmp.
            wa_objects_tmp = wa_objects.

*               BADI Aufruf, um die Liste der übergebenen Dokumente
*               zu manipulieren
            CLEAR return.
            IF badi_main_pre_001 IS INITIAL.
            ELSE.
              CLEAR drad_objects_badi.
*                Inhalte übergeben
              drad_objects_badi[] = itab_drad[].
              CLEAR return.
              CALL METHOD badi_main_pre_001->chg_drad_obj_before_prio
                                                             CHANGING
                                     drad_objects = drad_objects_badi
                                                return       = return
                                                                     .
              IF return IS INITIAL.
*                   Inhalte übergeben
                itab_drad[] = drad_objects_badi[].
              ELSE.
              ENDIF.
            ENDIF.

*               Alles aus der ITAB_DRAD herauswerfen, was nicht in der
*               Rangliste enthalten ist
            IF itab_mat_dokar_prio_list[] IS INITIAL.
            ELSE.
              CLEAR f_found_dokar.
              LOOP AT itab_mat_dokar_prio_list[]
                INTO wa_dokar.
                LOOP AT itab_drad INTO wa_drad
                  WHERE dokar = wa_dokar.
                  f_found_dokar = 'X'.
                  EXIT.
                ENDLOOP.
                IF f_found_dokar = 'X'.
*                     Alle anderen Einträge löschen
                  LOOP AT itab_drad INTO wa_drad
                    WHERE dokar <> wa_dokar.
                    index_drad = sy-tabix.
                    DELETE itab_drad INDEX index_drad.
                  ENDLOOP.
                  EXIT.
                ELSE.
                ENDIF.
              ENDLOOP.
            ENDIF.

            LOOP AT itab_drad INTO wa_drad.
              CLEAR wa_objects.
              MOVE-CORRESPONDING wa_drad TO wa_objects.
*                 Übergabe von Daten auf Mutterobject
              wa_objects-ebeln = wa_objects_tmp-ebeln.
              wa_objects-lifnr = wa_objects_tmp-lifnr.
              wa_objects-name1_lifnr = wa_objects_tmp-name1_lifnr.

              wa_objects-ebelp = wa_objects_tmp-ebelp.

              wa_objects-object_type = 'DOCUMENT'.
              APPEND wa_objects TO itab_objects.
            ENDLOOP.
          ENDLOOP.

*             Dokumentenpositionen der Stückliste holen
*             BADI Aufruf, um die Liste der übergebenen Dokumente
*             zu manipulieren
          CLEAR return.
          IF badi_main_pre_001 IS INITIAL.
          ELSE.
            CLEAR stpox_objects_badi.
*                Inhalte übergeben
            stpox_objects_badi[] = itab_dok[].
            CLEAR return.
            CALL METHOD badi_main_pre_001->chg_stpox_obj_before_prio
                                                            CHANGING
                                  stpox_objects = stpox_objects_badi
                                               return       = return
                                                                .
            IF return IS INITIAL.
*                   Inhalte übergeben
              itab_dok[] = stpox_objects_badi[].
            ELSE.
            ENDIF.
          ENDIF.

*             Alles aus der itab_dok herauswerfen, was nicht in der
*             Rangliste enthalten ist
          IF itab_mat_dokar_prio_list[] IS INITIAL.
          ELSE.
            CLEAR f_found_dokar.
            LOOP AT itab_mat_dokar_prio_list[]
              INTO wa_dokar.
              LOOP AT itab_dok INTO wa_stpox
                WHERE dokar = wa_dokar.
                f_found_dokar = 'X'.
                EXIT.
              ENDLOOP.
              IF f_found_dokar = 'X'.
*                   Alle anderen Einträge löschen
                LOOP AT itab_dok INTO wa_stpox
                  WHERE dokar <> wa_dokar.
                  index_dok = sy-tabix.
                  DELETE itab_dok INDEX index_dok.
                ENDLOOP.
                EXIT.
              ELSE.
              ENDIF.
            ENDLOOP.
          ENDIF.

*             Übergabe Dokumentenpostionen aus der Stückliste
          LOOP AT itab_dok INTO wa_stpox.
            CLEAR wa_objects.
            MOVE-CORRESPONDING wa_stpox TO wa_objects.
            wa_objects-object_type = 'DOCUMENT'.
*               Übergabe von Daten auf Mutterobject
            wa_objects-ebeln = wa_objects_tmp-ebeln.
            wa_objects-lifnr = wa_objects_tmp-lifnr.
            wa_objects-name1_lifnr = wa_objects_tmp-name1_lifnr.

            wa_objects-ebelp = wa_objects_tmp-ebelp.

            APPEND wa_objects TO itab_objects.
          ENDLOOP.

        ENDIF.
      WHEN 'EQUIPMENT'.
*           Equipment
        CLEAR drad_key.
        CLEAR drad_objekt.

        CLEAR itab_drad.

        drad_key = wa_objects-equnr.
        drad_objekt = 'EQUI'.

        CALL FUNCTION 'CV200_GET_DRAD_LINK'
          EXPORTING
            key                 = drad_key
            objekt              = drad_objekt
            mandt               = sy-mandt
          TABLES
            doktab              = itab_drad
*               INTDRAD_TAB         =
          EXCEPTIONS
            kein_dokument       = 1
            OTHERS              = 2
                  .
        IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        LOOP AT itab_drad INTO wa_drad.
          CLEAR wa_objects.
          wa_objects-object_type = 'DOCUMENT'.
          MOVE-CORRESPONDING wa_drad TO wa_objects.
          APPEND wa_objects TO itab_objects.
        ENDLOOP.
      WHEN 'FUNCLOCAT'.
*           technischer Platz
        CLEAR drad_key.
        CLEAR drad_objekt.

        CLEAR itab_drad.

        drad_key = wa_objects-tplnr.
        drad_objekt = 'IFLOT'.

        CALL FUNCTION 'CV200_GET_DRAD_LINK'
          EXPORTING
            key                 = drad_key
            objekt              = drad_objekt
            mandt               = sy-mandt
          TABLES
            doktab              = itab_drad
*               INTDRAD_TAB         =
          EXCEPTIONS
            kein_dokument       = 1
            OTHERS              = 2
                  .
        IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        LOOP AT itab_drad INTO wa_drad.
          CLEAR wa_objects.
          wa_objects-object_type = 'DOCUMENT'.
          MOVE-CORRESPONDING wa_drad TO wa_objects.
          APPEND wa_objects TO itab_objects.
        ENDLOOP.
      WHEN 'ECM'.
*           Änderungsnummer
*           sowohl in Dokumenten verwendete, als auch
*           Begleitdokumente zur Änderungsnummer
*           zuerst Begleitdokumente
        CLEAR drad_key.
        CLEAR drad_objekt.

        CLEAR itab_drad.

        drad_key = wa_objects-aennr.
        drad_objekt = 'AENR'.

        CALL FUNCTION 'CV200_GET_DRAD_LINK'
          EXPORTING
            key                 = drad_key
            objekt              = drad_objekt
            mandt               = sy-mandt
          TABLES
            doktab              = itab_drad
*               INTDRAD_TAB         =
          EXCEPTIONS
            kein_dokument       = 1
            OTHERS              = 2
                  .
        IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        LOOP AT itab_drad INTO wa_drad.
          CLEAR wa_objects.
          wa_objects-object_type = 'DOCUMENT'.
          MOVE-CORRESPONDING wa_drad TO wa_objects.
          APPEND wa_objects TO itab_objects.
        ENDLOOP.

*           Dokumente in denen die Änderungsnummer verwendet wird
        CLEAR itab_draw.
        CLEAR wa_draw.

        SELECT * FROM draw INTO TABLE itab_draw
          WHERE aennr = drad_key.
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.

        LOOP AT itab_draw INTO wa_draw.
          CLEAR wa_objects.
          wa_objects-object_type = 'DOCUMENT'.
          MOVE-CORRESPONDING wa_draw TO wa_objects.
          APPEND wa_objects TO itab_objects.
        ENDLOOP.
      WHEN 'SPOOL'.
        APPEND wa_objects TO itab_objects.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

*     Spezialanpassung, wegen Übergabe ohne Speichern
  CLEAR selected_objects.
  REFRESH selected_objects.
  LOOP AT itab_objects INTO wa_objects
    WHERE ktext = 'NO SAVE CKR'.
    APPEND wa_objects TO selected_objects.
  ENDLOOP.
  IF sy-subrc NE 0.
  ELSE.
*       Einträge gefunden -> dann FB verlassen und diese
*       zurückgeben
    EXIT.
  ENDIF.


  IF itab_objects[] IS INITIAL.
    MESSAGE s000(zcl_prod_struk_brws)
      WITH '' '' '' '' .
    EXIT.
  ELSE.
  ENDIF.

* SP 122
  " save_tcode
  IF save_tcode CS 'ME'.
    LOOP AT itab_objects INTO wa_objects.
      index = sy-tabix.
      wa_objects-verteiler = wa_user_data-default_verteiler_ebeln.
      MODIFY itab_objects FROM wa_objects INDEX index.
    ENDLOOP.
  ELSE.
  ENDIF.

  CALL FUNCTION '/CIDEON/PSBRW_WRT_PSB_TMP_FRTA'
       TABLES
            i_itab_objects = itab_objects
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    MESSAGE s003(zcl_prod_struk_brws)
      WITH '' '' '' '' .
  ENDIF.


ENDFUNCTION.
