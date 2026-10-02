FUNCTION z_cl_psbrw_obj_release.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"     REFERENCE(FM_NAME) TYPE  RS38L_FNAM
*"  TABLES
*"      SELECTED_OBJECTS STRUCTURE  PDM_EXP_OBJECTS
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
* 02.09.2005 - IW22-26
* 03.05.2006 - Änderungen für CSMB
* 30.05.2006 - Dokumente zum Stücklistenkopf für BOMITEM
* 03.07.2006 - Änderungen für Karl Mayer / CSMB
*              Dokumente für Stücklistenkopf
*              diese Dokumente sind die nomalen Verknüpfungen zum
*              Material des Stücklistenkopfes
*
*              Erweiterung auf Transaktionen des CAD Desktop
*              Erweiterungstools
* 06.11.2006 - Abfrage der Änderungsnummer für Dokumente, falls noch
*              nicht gefüllt
* 06.05.2008 - SP 074
*              MD04 etc. hinzugefügt ... B. Krone
* 07.05.2008 - SP 075
*              Umbau, daß nur der Hinweis auf nicht freigegebene
*              Funktion kommt.

***********************************************************************
*ITAB
  DATA: itab_drad TYPE TABLE OF drad.
  DATA: itab_mara TYPE TABLE OF mara.
  DATA: itab_stpo TYPE TABLE OF stpo.
  DATA: itab_dok TYPE TABLE OF stpox.
  DATA: itab_txt TYPE TABLE OF stpox.
  DATA: itab_mast TYPE TABLE OF mast.

  DATA: itab_draw TYPE TABLE OF draw.
*WA
  DATA: wa_drad TYPE drad.
  DATA: wa_mara TYPE mara.
  DATA: wa_stpo TYPE stpo.
  DATA: wa_stpox TYPE stpox.
  DATA: wa_mast TYPE mast.

  DATA: wa_draw TYPE draw.

  DATA: wa_default_data TYPE /cideon/plot_defaultdata.
  DATA: wa_user_data TYPE /cideon/plot_userdata.

*NORMAL
  DATA: save_tcode LIKE sy-tcode.

  DATA: lc_transaction_name TYPE tcode.

  DATA: drad_key TYPE drad-objky.
  DATA: drad_objekt TYPE drad-dokob.

  DATA: f_read_settings VALUE ''.

  DATA: index TYPE i.


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
      OR 'ME22N'
      OR 'ME22'
      OR 'ME23N'
      OR 'ME23'
      OR 'CJ20N'       " Projektbuilder
      OR 'SRMSTART'    " Records Management (nur ab 4.7)
      OR 'IW21'        " Instandhaltungsmeldung
      OR 'IW22'
      OR 'IW23'
      OR 'IW24'
      OR 'IW25'
      OR 'IW26'
      OR 'CC07'
                       " CAD Desktop Erweiterungstool / Start CDESK
      OR '/CIDEON/CDESK_INV'
      OR '/CIDEON/CDESK_ACAD'
      OR '/CIDEON/CDESK_ACADM'
      OR '/CIDEON/CDESK_MDT'
      OR '/CIDEON/CDESK_INVCAD'

      OR 'MD01'        " Bedarfs- Bestandsliste
      OR 'MD02'
      OR 'MD03'
      OR 'MD04'
      .

    WHEN OTHERS.
      MESSAGE s002(zcl_prod_struk_brws)
        WITH '' '' '' '' .
      "EXIT.
  ENDCASE.

*  lc_transaction_name = 'ZCL_PLOT_INTERFACE'.
*  CALL TRANSACTION lc_transaction_name.

  CLEAR f_read_settings.
  LOOP AT selected_objects INTO wa_objects
    WHERE
    object_type = 'BILLOFMAT'
    OR object_type = 'BOMITEM'
    OR object_type = 'MATERIAL'
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

  ELSE.
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
*             Anpassungen für Dokumentenpositionen  in den Stückliste
          IF wa_objects-doknr IS INITIAL.
          ELSE.
*               Ändern der Einstellungen
            wa_objects-object_type = 'DOCUMENT'.
            APPEND wa_objects TO itab_objects.
          ENDIF.
        ELSE.
          REFRESH itab_mara.
          CLEAR wa_mara.
          CASE wa_objects-object_type.
            WHEN 'BILLOFMAT'.
*                 Dokumentzuordnungen zum Stücklistenkopf besorgen
*                 Typ, Alternative, Nummer etc.
              DATA: wa_stko TYPE stko.
              CLEAR wa_stko.
              SELECT SINGLE * FROM stko INTO wa_stko
                WHERE stlty = wa_objects-stlty
                AND stlnr = wa_objects-stlnr
                AND stlal = wa_objects-stlal
                .
              IF sy-subrc NE 0.
              ELSE.
*                   Alles holen, mit GUIDX aus der DRAD
                CLEAR wa_drad.
                REFRESH itab_drad.
                SELECT * FROM drad INTO TABLE itab_drad
                  WHERE objky = wa_stko-guidx.
                .
                IF sy-subrc NE 0.
                ELSE.
                  LOOP AT itab_drad INTO wa_drad.
                    wa_objects-dokar = wa_drad-dokar.
                    wa_objects-doknr = wa_drad-doknr.
                    wa_objects-doktl = wa_drad-doktl.
                    wa_objects-dokvr = wa_drad-dokvr.

                    wa_objects-object_type = 'DOCUMENT'.
                    APPEND wa_objects TO itab_objects.
                  ENDLOOP.
                ENDIF.
              ENDIF.

*                 CKR 2006/07/03
*                 Dokumentverknüpfungen zum Kopmaterial holen
              CLEAR itab_drad.
              CLEAR wa_objects_2.
              wa_objects_2 = wa_objects.

              SELECT * FROM drad INTO TABLE itab_drad
               WHERE dokob = 'MARA'
               AND objky = wa_objects_2-matnr
               .
              IF sy-subrc NE 0.
              ELSE.
              ENDIF.
              LOOP AT itab_drad INTO wa_drad.
                " CLEAR wa_objects_2.
                MOVE-CORRESPONDING wa_drad TO wa_objects_2.
                wa_objects_2-object_type = 'DOCUMENT'.
                APPEND wa_objects_2 TO itab_objects.
              ENDLOOP.

*                 Auflösungsdatum
              DATA: datum TYPE sy-datum.
              CLEAR datum.
              GET  PARAMETER ID '/CIDEON/PSB_DATE' FIELD datum.

              CALL FUNCTION 'Z_CL_GET_BILLOFMAT_ALL'
                   EXPORTING
                        i_matnr      = wa_objects-matnr
                        i_stlan      = wa_objects-stlan
                        i_stlal      = wa_objects-stlal
                        i_werks      = wa_objects-werks
                        i_datum      = datum
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
            LOOP AT itab_drad INTO wa_drad.
              CLEAR wa_objects.
              MOVE-CORRESPONDING wa_drad TO wa_objects.

              wa_objects-matnr = wa_mara-matnr.

              wa_objects-object_type = 'DOCUMENT'.
              APPEND wa_objects TO itab_objects.
            ENDLOOP.
          ENDLOOP.

*             Dokumentenpositionen der Stückliste holen
          LOOP AT itab_dok INTO wa_stpox.
            CLEAR wa_objects.
            MOVE-CORRESPONDING wa_stpox TO wa_objects.
            wa_objects-object_type = 'DOCUMENT'.
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

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

  IF itab_objects[] IS INITIAL.
    MESSAGE s000(zcl_prod_struk_brws)
      WITH '' '' '' '' .
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_objects INTO wa_objects.
    index = sy-tabix.

    IF wa_objects-object_type = 'DOCUMENT'.
    ELSE.
      CONTINUE.
    ENDIF.

    IF wa_objects-aennr IS INITIAL.
    ELSE.
      CONTINUE.
    ENDIF.

    SELECT SINGLE aennr FROM draw
      INTO wa_objects-aennr
      WHERE dokar = wa_objects-dokar
      AND doknr = wa_objects-doknr
      AND doktl = wa_objects-doktl
      AND dokvr = wa_objects-dokvr
      .
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

    MODIFY itab_objects FROM wa_objects INDEX index.
  ENDLOOP.

  CALL FUNCTION 'Z_CL_PSBRW_WRITE_PSB_TMP'
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
