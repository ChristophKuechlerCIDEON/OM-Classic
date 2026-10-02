FUNCTION z_cl_psbrw_call_plot_001_o_stl.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
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
* Journal
* 14.08.2002 - Erstellung
* 03.09.2002 - Eweiterung um TCODE
* 06.04.2004 - Heiko Hänsel
*              Unterstützung für die Transaktionen der
*              Bestellanforderung ME5*
* 07.04.2004 - Kopie / Rausnahme der Stücklisten
* 28.09.2004 - Umarbeitung
*              Erweiterung für direkt verknüpfte Dokumente zu
*              technischen Plätzen / Equipments
*              Änderungsnummer
*-----------------------------------------------------------------------
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
*NORMAL
  DATA: save_tcode LIKE sy-tcode.

  DATA: drad_key TYPE drad-objky.
  DATA: drad_objekt TYPE drad-dokob.

  CLEAR wa_objects.
  REFRESH itab_objects.
  CLEAR save_tcode.


  CASE sy-tcode.
    WHEN 'CV03N'.
      save_tcode = 'CC04'.
      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD'X'.
    WHEN OTHERS.
      save_tcode = sy-tcode.
      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD'X'.
  ENDCASE.

* Generalisierung für die Transaktionen der Bestellanforderung
  IF sy-tcode CS 'ME5'.
    IF sy-fdpos = 0.
      save_tcode = 'ME5X'.
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
      OR 'SE37'
      OR 'ME22N'
      OR 'ME22'
      OR 'SRMSTART'    " Records Management (nur ab 4.7)
      .
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
                            I_DATUM      = sy-datum
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
*                  REFRESH itab_mast.
*                  SELECT * FROM mast INTO TABLE itab_mast
*                    WHERE matnr = wa_objects-matnr.
*                  IF sy-subrc NE 0.
*                  ELSE.
*                    LOOP AT itab_mast INTO wa_mast.
*                      "CLEAR wa_objects.
*                      wa_objects-object_type = 'BILLOFMAT'.
*                      wa_objects-stlan = wa_mast-stlan.
*                      wa_objects-stlnr = wa_mast-stlnr.
*                      wa_objects-stlal = wa_mast-stlal.
*                      APPEND wa_objects TO selected_objects.
*                    ENDLOOP.
*                  ENDIF.

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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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



*        IF ( wa_objects-object_type = 'DOCUMENT' )
*          OR ( wa_objects-object_type = 'BILLOFDOC' )
*          .
*          IF ( wa_objects-dokar IS INITIAL )
*          OR ( wa_objects-doknr IS INITIAL )
*          OR ( wa_objects-dokvr IS INITIAL )
*          OR ( wa_objects-doktl IS INITIAL )
*          .
*          ELSE.
*            APPEND wa_objects TO itab_objects.
*          ENDIF.
*        ELSE.
*          IF ( wa_objects-object_type = 'BILLOFMAT' )
*            OR ( wa_objects-object_type = 'BOMITEM' )
*            OR ( wa_objects-object_type = 'MATERIAL' )
*            .
*            IF  wa_objects-matnr IS INITIAL
*            .
*            ELSE.
*              REFRESH itab_mara.
*              CLEAR wa_mara.
*              CASE wa_objects-object_type.
*                WHEN 'BILLOFMAT'.
*                  CALL FUNCTION 'Z_CL_GET_BILLOFMAT_ALL'
*                       EXPORTING
*                            i_matnr      = wa_objects-matnr
*                            i_stlan      = wa_objects-stlan
*                            i_stlal      = wa_objects-stlal
*                            i_werks      = wa_objects-werks
*                       TABLES
*                            o_itab_matnr = itab_mara
*                            o_itab_dok   = itab_dok
*                            o_itab_txt   = itab_txt
*                       EXCEPTIONS
*                            error        = 1
*                            OTHERS       = 2.
*                  IF sy-subrc <> 0.
*                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*                  ENDIF.
**                  wa_mara-matnr = wa_objects-matnr.
**                  APPEND wa_mara TO itab_mara.
*                WHEN 'BOMITEM'.
*                  wa_mara-matnr = wa_objects-matnr.
*                  APPEND wa_mara TO itab_mara.
*                WHEN 'MATERIAL'.
*                  wa_mara-matnr = wa_objects-matnr.
*                  APPEND wa_mara TO itab_mara.
*
**                 Suche nach vorhandenen Stücklisten
**                  REFRESH itab_mast.
**                  SELECT * FROM mast INTO TABLE itab_mast
**                    WHERE matnr = wa_objects-matnr.
**                  IF sy-subrc NE 0.
**                  ELSE.
**                    LOOP AT itab_mast INTO wa_mast.
**                      "CLEAR wa_objects.
**                      wa_objects-object_type = 'BILLOFMAT'.
**                      wa_objects-stlan = wa_mast-stlan.
**                      wa_objects-stlnr = wa_mast-stlnr.
**                      wa_objects-stlal = wa_mast-stlal.
**                      APPEND wa_objects TO selected_objects.
**                    ENDLOOP.
**                  ENDIF.
*
*              ENDCASE.
*
*              REFRESH itab_drad.
*              CLEAR itab_drad.
*
**             get object doc links
*              LOOP AT itab_mara INTO wa_mara.
*                wa_objects-matnr = wa_mara-matnr.
*                SELECT * FROM drad INTO TABLE itab_drad
*                 WHERE dokob = 'MARA'
*                 AND objky = wa_objects-matnr
*                 .
*                IF sy-subrc NE 0.
*                ELSE.
*                ENDIF.
*                LOOP AT itab_drad INTO wa_drad.
*                  CLEAR wa_objects.
*                  MOVE-CORRESPONDING wa_drad TO wa_objects.
*                  wa_objects-object_type = 'DOCUMENT'.
*                  APPEND wa_objects TO itab_objects.
*                ENDLOOP.
*              ENDLOOP.
*
**             Dokumentenpositionen der Stückliste holen
*              LOOP AT itab_dok INTO wa_stpox.
*                CLEAR wa_objects.
*                MOVE-CORRESPONDING wa_stpox TO wa_objects.
*                wa_objects-object_type = 'DOCUMENT'.
*                APPEND wa_objects TO itab_objects.
*              ENDLOOP.
*
*            ENDIF.
*          ELSE.
*          ENDIF.
*        ENDIF.
      ENDLOOP.

      IF itab_objects[] IS INITIAL.
        MESSAGE s000(zcl_prod_struk_brws)
          WITH '' '' '' '' .
        EXIT.
      ELSE.
      ENDIF.

      CALL FUNCTION 'Z_CL_PSBRW_WRITE_PSB_TMP'
           TABLES
                i_itab_objects = itab_objects
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN OTHERS.
      MESSAGE s002(zcl_prod_struk_brws)
        WITH '' '' '' '' .
      EXIT.
  ENDCASE.


  CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.


ENDFUNCTION.
