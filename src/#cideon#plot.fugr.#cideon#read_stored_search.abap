FUNCTION /cideon/read_stored_search.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"  TABLES
*"      ITAB_SEARCH STRUCTURE  ZCL_S_DOCSEARCH
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  C: Küchler
*
* Kontakt:
*           helpdesk@cideon-software.com
*
*-----------------------------------------------------------------------
* Journal
* 05.07.2004 - Erstellung
* 23.08.2004 - CS / Dokumentationsdruck
* 11.04.2005 - Lieferantenanbindung (LIFNR, NAME1_LIFNR, EBELN)
* 14.04.2005 - SEITE_VON, SEITE_BIS
* 18.04.2005 - AO$_MERGE
* 10.05.2005 - MATNR
* 18.09.2005 - QMNUM
* 28.11.2005 - VBELN (Mikron)
* 31.01.2006 - BADI Implementierung um Einträge anzupassen
* 30.03.2006 - AENNR
* 31.03.2006 - STLNR
* 18.09.2006 - Übergabe der Spool ID in die DOKNR
* 23.02.2007 - EBELP
* 20.03.2007 - KNZ_MARKED_EBELN
* 01.08.2007 - VBELN POSNR
* 07.08.2007 - SP45
*            - Kapitel
* 13.08.2007 - SP 46
*              MDR_DIS
*              ROOT_DIS
* 22.08.2007 - F_DYN_TOC
* 03.09.2007 - F_DYN_COV
* 20.09.2007 - PSP_HYRACHIE
* 03.01.2008 - SP 62 / 3.0.4.7
*              Vorbereitungen für Erstellen von DIS aus Spooleinträgen
*              für die Integration in Einkaufstransaktionen
* 17.01.2008 - PARA1 bis 4
* 04.10.2008 - SP 79
*              PRINT_TYPE
*              RECIPIENT
*              NR_COPIES
*              PRINT_CAUSE
*              CHARG
*              DATE_EXTERM
*              TIME_EXTERM
*              USER_EXTERM
*              CAUSE_EXTERM
* 05.10.2008 - EXP_PROGRAM
*
* 13.09.2010 - CKR
* 7.0.132.3    VORNR übertragen aus Fertigungsauftrag ->
*              für Spooldokumente
*              -> RGG / KUMBA
*
* SP 134
* 7.0.134.1  - CKR
*              Erweiterung /CIDEON/S_ENHC_TRANSFER_01
*              Rademaker
*              PARA 5 - 8 / CUSTOMER / PROJ_NR
*
* 7.0.134.3 - CKR
* 21.10.2010  Übergabe der Daten bei erneutem Druck aus PlotLOG
*             ID_REF  /CIDEON/ID_PLOTLOG_REF
*             ID_PLOTJOB_REF  /CIDEON/ID_PLOTJOB_REF
*             ID_PLOTJOB_32_RE  /CIDEON/ID_PLOTJOB_GUID32_REF
*
* SP 139
* 04.11.2010 - CKR
* 7.0.139.1    Erweiterung /CIDEON/S_ENHC_TRANSFER_01
*              SERNR
*              EMITEC
*
* SP 141
* 09.11.2010 - CKR
* 7.0.141.1    BADI für Übergabe von Kundeneingenen Feldern
*              ZAPPEND in /CIDEON/S_ENHC_TRANSFER_01
*
* SP 143
* 16.12.2010 - CKR
*
* 16.12.2010 - CKR
* 7.0.142.4    Integration der /CIDEON/S_ENHC_TRANSFER_02
*              /CIDEON/READ_STORED_SEARCH
*
*              URL innerhalb des OBJECT_TYP
** 7.0.146.5
*             Löschen in Tabelle ZCL_PSB_TMP2
*             FB /CIDEON/READ_STORED_SEARCH
* 7.0.170.1
* 2014/10/02 - APEX
* Anpassung der Sourcen auf Ersetzung von FB GUID_CREATE
*-----------------------------------------------------------------------

* try to read stored search entries
*ITAB
  DATA: itab_stpo_api02 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_1 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_2 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_result TYPE TABLE OF stpo_api02.
  DATA: itab_draw TYPE TABLE OF draw.
*WA
  DATA: wa_stpo_api02 TYPE stpo_api02.
  DATA: wa_draw TYPE draw.
  DATA: wa_search TYPE zcl_s_docsearch.
  DATA: return TYPE bapiret2.
*NORMA
  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.
  DATA: wa_dost TYPE dost.
  DATA: laenge TYPE i.
  DATA: char25(25).
  DATA: anzahl TYPE i.

  DATA: itab_stored_search TYPE TABLE OF zcl_psb_tmp.
  DATA: wa_stored_search TYPE zcl_psb_tmp.
  DATA: wa_stored_search2 TYPE zcl_psb_tmp2.

  DATA: f_lesen(1).

* BADI
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.

* Lesen oder nicht Lesen, daß ist hier die Frage :-))
*  IMPORT f_lesen FROM MEMORY ID 'PLOT_READ_AKT_QUEUE'.
*  EXPORT ''
*    TO MEMORY ID 'PLOT_READ_AKT_QUEUE'.
  GET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD f_lesen.
  IF f_lesen = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF i_wa_user_data-read_tmp_search = 'X'.
  ELSE.
    IF i_wa_user_data-delete_tmp_search = 'X'.
      DELETE FROM zcl_psb_tmp
        WHERE uname = i_wa_user_data-uname
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
      DELETE FROM zcl_psb_tmp2
        WHERE uname = i_wa_user_data-uname
          .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
    EXIT.
  ENDIF.

  CLEAR   itab_stored_search.
  REFRESH itab_stored_search.
  CLEAR wa_stored_search.

  SELECT * FROM zcl_psb_tmp INTO TABLE itab_stored_search
    WHERE
    uname = i_wa_user_data-uname
    ORDER BY counter
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

* Badi aufruf, um die liste der übergebenen dokumente
* zu manipulieren
  CLEAR return.
  CLEAR badi_main_pre_001.
  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
    DATA: selected_objects_badi TYPE /cideon/ttype_s_psb_tmp.
    CLEAR selected_objects_badi.
*         Inhalte übergeben
    selected_objects_badi[] = itab_stored_search[].
    CLEAR return.
    CALL METHOD badi_main_pre_001->chg_obj_after_read_tmp
      CHANGING
        selected_objects = selected_objects_badi
        return           = return.
    IF return IS INITIAL.
*     Inhalte übergeben
      itab_stored_search[] = selected_objects_badi[].
    ELSE.
    ENDIF.
  ENDIF.


  LOOP AT itab_stored_search INTO wa_stored_search.
    CLEAR wa_search.

*   allgemeine Übergabe
    wa_search-psteu = wa_stored_search-psteu.
    wa_search-samlt = wa_stored_search-samlt.
    wa_search-pmode = wa_stored_search-pmode.
    wa_search-drart = wa_stored_search-drart.
    wa_search-ktext = wa_stored_search-ktext.
    wa_search-selpr = wa_stored_search-selpr.
    wa_search-tcode = wa_stored_search-tcode.

    wa_search-projn = wa_stored_search-projn.

    "2. Tabelle lesen
    CLEAR wa_stored_search2.
    SELECT SINGLE * FROM zcl_psb_tmp2
      INTO wa_stored_search2
      WHERE
        uname = wa_stored_search-uname
        AND object_type  = wa_stored_search-object_type
        AND dokar = wa_stored_search-dokar
        AND doknr = wa_stored_search-doknr
        AND dokvr = wa_stored_search-dokvr
        AND doktl = wa_stored_search-doktl
        AND counter = wa_stored_search-counter
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    MOVE-CORRESPONDING wa_stored_search2 TO wa_search.

*   spezielle Übergabe
    CASE wa_stored_search-object_type.
      WHEN 'BILLOFDOC'.

*        CLEAR wa_search.

        CALL FUNCTION 'Z_CL_GET_BILLOFDOC_ALL'
          EXPORTING
            i_dokar     = wa_stored_search-dokar
            i_doknr     = wa_stored_search-doknr
            i_dokvr     = wa_stored_search-dokvr
            i_doktl     = wa_stored_search-doktl
          TABLES
            o_itab_draw = itab_draw
          EXCEPTIONS
            error       = 1
            OTHERS      = 2.
        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CLEAR wa_draw.
        wa_draw-dokar           = wa_stored_search-dokar.
        wa_draw-doknr           = wa_stored_search-doknr.
        wa_draw-dokvr           = wa_stored_search-dokvr.
        wa_draw-doktl           = wa_stored_search-doktl.
        "APPEND wa_draw TO itab_draw.
        INSERT wa_draw INTO itab_draw INDEX 1.

        LOOP AT itab_draw INTO wa_draw.
          SELECT SINGLE * FROM draw INTO
            CORRESPONDING FIELDS OF wa_search
            WHERE doknr = wa_draw-doknr
            AND dokar = wa_draw-dokar
            AND doktl = wa_draw-doktl
            AND dokvr = wa_draw-dokvr
            .
          IF sy-subrc NE 0.
            wa_search-doknr = wa_draw-doknr.
            wa_search-dokar = wa_draw-dokar.
            wa_search-doktl = wa_draw-doktl.
            wa_search-dokvr = wa_draw-dokvr.
            APPEND wa_search TO itab_search.
          ELSE.
            APPEND wa_search TO itab_search.
          ENDIF.
        ENDLOOP.

      WHEN 'DOCUMENT'.
*        CLEAR wa_search.
        SELECT SINGLE * FROM draw INTO
          CORRESPONDING FIELDS OF wa_search
          WHERE dokar = wa_stored_search-dokar
          AND doknr = wa_stored_search-doknr
          AND dokvr = wa_stored_search-dokvr
          AND doktl = wa_stored_search-doktl
          .
        IF sy-subrc NE 0.
        ELSE.
          wa_search-id_sl = wa_stored_search-id_sl.
          wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
          wa_search-aufpl = wa_stored_search-aufpl.
          wa_search-aplzl = wa_stored_search-aplzl.
          wa_search-knz_affl = wa_stored_search-knz_affl.
          wa_search-knz_afvc = wa_stored_search-knz_afvc.

          wa_search-verteiler = wa_stored_search-verteiler.

          wa_search-folnr = wa_stored_search-folnr.
          wa_search-vornr = wa_stored_search-vornr.

*         CS
          wa_search-aufnr_cs = wa_stored_search-aufnr_cs.

*         Dokumentationsdruck
          wa_search-seitennummer = wa_stored_search-seitennummer.
          wa_search-dateiname_ziel = wa_stored_search-dateiname_ziel.
          wa_search-seite_von = wa_stored_search-seite_von.
          wa_search-seite_bis = wa_stored_search-seite_bis.
          wa_search-ao_merge = wa_stored_search-ao_merge.

*         Lieferantenanbindung
          wa_search-lifnr = wa_stored_search-lifnr.
          wa_search-name1_lifnr = wa_stored_search-name1_lifnr.
          wa_search-ebeln = wa_stored_search-ebeln.
          wa_search-matnr = wa_stored_search-matnr.

*         IH Anbindung
          wa_search-qmnum = wa_stored_search-qmnum.

*         VBELN Anbindung
          wa_search-vbeln = wa_stored_search-vbeln.

*         AENNR Anbindung
          wa_search-aennr = wa_stored_search-aennr.

*         Stücklistennummer
          wa_search-stlnr = wa_stored_search-stlnr.

*         Einkaufsbelegsnummer
          wa_search-ebelp = wa_stored_search-ebelp.

*         KNZ_MARKED_EBELN
          wa_search-knz_marked_ebeln =
            wa_stored_search-knz_marked_ebeln.

*         VBELN POSNR
          wa_search-posnr =
            wa_stored_search-posnr.

*         Kapitel
          wa_search-kapitel =
            wa_stored_search-kapitel.

*         MDR_DIS / ROOT_DIS
          wa_search-mdr_dokar = wa_stored_search-mdr_dokar.
          wa_search-mdr_doknr = wa_stored_search-mdr_doknr.
          wa_search-mdr_doktl = wa_stored_search-mdr_doktl.
          wa_search-mdr_dokvr = wa_stored_search-mdr_dokvr.

          wa_search-root_dokar = wa_stored_search-root_dokar.
          wa_search-root_doknr = wa_stored_search-root_doknr.
          wa_search-root_doktl = wa_stored_search-root_doktl.
          wa_search-root_dokvr = wa_stored_search-root_dokvr.

*         F_DYN_TOC
          wa_search-f_dyn_toc = wa_stored_search-f_dyn_toc.

*         F_DYN_COV
          wa_search-f_dyn_cov = wa_stored_search-f_dyn_cov.

*         PSP_HYRACHIE
          wa_search-psp_hierachy = wa_stored_search-psp_hierachy.

*         PARA1 bis 4
          wa_search-para1 = wa_stored_search-para1.
          wa_search-para2 = wa_stored_search-para2.
          wa_search-para3 = wa_stored_search-para3.
          wa_search-para4 = wa_stored_search-para4.

*         kontrollierter Druck
          wa_search-print_type = wa_stored_search-print_type.
          wa_search-recipient = wa_stored_search-recipient.
          wa_search-nr_copies = wa_stored_search-nr_copies.
          wa_search-print_cause = wa_stored_search-print_cause.
          wa_search-charg = wa_stored_search-charg.
          wa_search-date_exterm = wa_stored_search-date_exterm.
          wa_search-time_exterm = wa_stored_search-time_exterm.
          wa_search-user_exterm = wa_stored_search-user_exterm.
          wa_search-cause_exterm = wa_stored_search-cause_exterm.

*         experimentelles Programm
          wa_search-exp_program = wa_stored_search-exp_program.

*         PARA5 bis 8
          wa_search-para5 = wa_stored_search-para5.
          wa_search-para6 = wa_stored_search-para6.
          wa_search-para7 = wa_stored_search-para7.
          wa_search-para8 = wa_stored_search-para8.

*         Customer / Projektnummer
          wa_search-customer = wa_stored_search-customer.
          wa_search-proj_nr = wa_stored_search-proj_nr.

*         Referenzen auf Ausgangsjobs
          wa_search-id_ref = wa_stored_search-id_ref.
          wa_search-id_plotjob_ref = wa_stored_search-id_plotjob_ref.
          wa_search-id_plotjob_32_re =
            wa_stored_search-id_plotjob_32_re.

*         Serialnummer
          wa_search-sernr = wa_stored_search-sernr.

          "BADI Implementierung um beispielsweise ZZ-Felder zuübergeben
          IF badi_main_pre_001 IS INITIAL.
          ELSE.
            CALL METHOD badi_main_pre_001->chg_stor_src_item
              CHANGING
                wa_stored_search = wa_stored_search
                wa_search        = wa_search.
            IF return IS INITIAL.
            ELSE.
            ENDIF.
          ENDIF.

          APPEND wa_search TO itab_search.
        ENDIF.
      WHEN 'STUECKLIST'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        APPEND wa_search TO itab_search.
      WHEN 'FOLGE'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
        wa_search-aufpl = wa_stored_search-aufpl.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        APPEND wa_search TO itab_search.
      WHEN 'VORGANG'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
        wa_search-aufpl = wa_stored_search-aufpl.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
        wa_search-doknr = wa_stored_search-object_type.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

        APPEND wa_search TO itab_search.
      WHEN 'SPOOL'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
        wa_search-aufpl = wa_stored_search-aufpl.

        wa_search-verteiler = wa_stored_search-verteiler.

        wa_search-folnr = wa_stored_search-folnr.
        wa_search-vornr = wa_stored_search-vornr.

        wa_search-drtxt = wa_stored_search-drtxt.
        wa_search-tdotftype = wa_stored_search-tdotftype.
        wa_search-tdspoolid = wa_stored_search-tdspoolid.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'SPZ'.
*        wa_search-doknr = wa_stored_search-object_type.
        IF wa_stored_search-doknr IS INITIAL.
          "wa_search-doknr = wa_stored_search-object_type.
          wa_search-doknr = wa_stored_search-tdspoolid.
        ELSE.
          wa_search-doknr = wa_stored_search-doknr.
        ENDIF.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

*       CS
        wa_search-aufnr_cs = wa_stored_search-aufnr_cs.

*       Dokumenationsdruck
        wa_search-seitennummer = wa_stored_search-seitennummer.
        wa_search-dateiname_ziel = wa_stored_search-dateiname_ziel.
        wa_search-seite_von = wa_stored_search-seite_von.
        wa_search-seite_bis = wa_stored_search-seite_bis.
        wa_search-ao_merge = wa_stored_search-ao_merge.

*       Lieferantenanbindung
        wa_search-lifnr = wa_stored_search-lifnr.
        wa_search-name1_lifnr = wa_stored_search-name1_lifnr.
        wa_search-ebeln = wa_stored_search-ebeln.
        wa_search-matnr = wa_stored_search-matnr.

*       IH Anbindung
        wa_search-qmnum = wa_stored_search-qmnum.

*       VBELN Anbindung
        wa_search-vbeln = wa_stored_search-vbeln.

*       AENNR Anbindung
        wa_search-aennr = wa_stored_search-aennr.

*       Stücklistennummer
        wa_search-stlnr = wa_stored_search-stlnr.

*       Einkaufsbelegsnummer
        wa_search-ebelp = wa_stored_search-ebelp.

*       KNZ_MARKED_EBELN
        wa_search-knz_marked_ebeln =
          wa_stored_search-knz_marked_ebeln.

*         VBELN POSNR
        wa_search-posnr =
          wa_stored_search-posnr.

*         Kapitel
        wa_search-kapitel =
          wa_stored_search-kapitel.

*         MDR_DIS / ROOT_DIS
        wa_search-mdr_dokar = wa_stored_search-mdr_dokar.
        wa_search-mdr_dokvr = wa_stored_search-mdr_doknr.
        wa_search-mdr_doktl = wa_stored_search-mdr_doktl.
        wa_search-mdr_dokvr = wa_stored_search-mdr_dokvr.

        wa_search-root_dokar = wa_stored_search-root_dokar.
        wa_search-root_doknr = wa_stored_search-root_doknr.
        wa_search-root_doktl = wa_stored_search-root_doktl.
        wa_search-root_dokvr = wa_stored_search-root_dokvr.

*       F_DYN_TOC
        wa_search-f_dyn_toc = wa_stored_search-f_dyn_toc.

*       F_DYN_COV
        wa_search-f_dyn_cov = wa_stored_search-f_dyn_cov.

*       PSP_HYRACHIE
        wa_search-psp_hierachy = wa_stored_search-psp_hierachy.


*       PARA1 bis 4
        wa_search-para1 = wa_stored_search-para1.
        wa_search-para2 = wa_stored_search-para2.
        wa_search-para3 = wa_stored_search-para3.
        wa_search-para4 = wa_stored_search-para4.

*         kontrollierter Druck
        wa_search-print_type = wa_stored_search-print_type.
        wa_search-recipient = wa_stored_search-recipient.
        wa_search-nr_copies = wa_stored_search-nr_copies.
        wa_search-print_cause = wa_stored_search-print_cause.
        wa_search-charg = wa_stored_search-charg.
        wa_search-date_exterm = wa_stored_search-date_exterm.
        wa_search-time_exterm = wa_stored_search-time_exterm.
        wa_search-user_exterm = wa_stored_search-user_exterm.
        wa_search-cause_exterm = wa_stored_search-cause_exterm.

*         experimentelles Programm
        wa_search-exp_program = wa_stored_search-exp_program.

*         PARA5 bis 8
        wa_search-para5 = wa_stored_search-para5.
        wa_search-para6 = wa_stored_search-para6.
        wa_search-para7 = wa_stored_search-para7.
        wa_search-para8 = wa_stored_search-para8.

*         Customer / Projektnummer
        wa_search-customer = wa_stored_search-customer.
        wa_search-proj_nr = wa_stored_search-proj_nr.

*         Referenzen auf Ausgangsjobs
        wa_search-id_ref   = wa_stored_search-id_ref  .
        wa_search-id_plotjob_ref = wa_stored_search-id_plotjob_ref.
        wa_search-id_plotjob_32_re =
          wa_stored_search-id_plotjob_32_re.

*         Serialnummer
        wa_search-sernr = wa_stored_search-sernr.

        "BADI Implementierung um beispielsweise ZZ-Felder zuübergeben
        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->chg_stor_src_item
            CHANGING
              wa_stored_search = wa_stored_search
              wa_search        = wa_search.
          IF return IS INITIAL.
          ELSE.
          ENDIF.
        ENDIF.

        APPEND wa_search TO itab_search.

      WHEN 'URL'.
*        CLEAR wa_search.
        wa_search-object_type = wa_stored_search-object_type.
        wa_search-id_sl = wa_stored_search-id_sl.
        wa_search-aufnr_pp = wa_stored_search-aufnr_pp.
        wa_search-aufpl = wa_stored_search-aufpl.

        wa_search-verteiler = wa_stored_search-verteiler.

        wa_search-folnr = wa_stored_search-folnr.
        wa_search-vornr = wa_stored_search-vornr.

        wa_search-drtxt = wa_stored_search-drtxt.
        wa_search-tdotftype = wa_stored_search-tdotftype.
        wa_search-tdspoolid = wa_stored_search-tdspoolid.

        wa_search-knz_spez_dok = 'X'.
        wa_search-dokar = 'URL'.
*        wa_search-doknr = wa_stored_search-object_type.
        IF wa_stored_search-doknr IS INITIAL.
          "wa_search-doknr = wa_stored_search-object_type.
          "wa_search-doknr = wa_stored_searc-tdspoolid.
          DATA: lc_guid TYPE guid.
          CLEAR lc_guid.

          "CALL FUNCTION 'GUID_CREATE'
          CALL FUNCTION '/CIDEON/OM_CLASSIC_GUID_CREATE'
            IMPORTING
              ev_guid_16       = lc_guid
*             EV_GUID_22       =
*             EV_GUID_32       =
                    .
          wa_search-doknr = lc_guid.

        ELSE.
          wa_search-doknr = wa_stored_search-doknr.
        ENDIF.
        wa_search-doktl = '000'.
        wa_search-dokvr = '00'.

*       CS
        wa_search-aufnr_cs = wa_stored_search-aufnr_cs.

*       Dokumenationsdruck
        wa_search-seitennummer = wa_stored_search-seitennummer.
        wa_search-dateiname_ziel = wa_stored_search-dateiname_ziel.
        wa_search-seite_von = wa_stored_search-seite_von.
        wa_search-seite_bis = wa_stored_search-seite_bis.
        wa_search-ao_merge = wa_stored_search-ao_merge.

*       Lieferantenanbindung
        wa_search-lifnr = wa_stored_search-lifnr.
        wa_search-name1_lifnr = wa_stored_search-name1_lifnr.
        wa_search-ebeln = wa_stored_search-ebeln.
        wa_search-matnr = wa_stored_search-matnr.

*       IH Anbindung
        wa_search-qmnum = wa_stored_search-qmnum.

*       VBELN Anbindung
        wa_search-vbeln = wa_stored_search-vbeln.

*       AENNR Anbindung
        wa_search-aennr = wa_stored_search-aennr.

*       Stücklistennummer
        wa_search-stlnr = wa_stored_search-stlnr.

*       Einkaufsbelegsnummer
        wa_search-ebelp = wa_stored_search-ebelp.

*       KNZ_MARKED_EBELN
        wa_search-knz_marked_ebeln =
          wa_stored_search-knz_marked_ebeln.

*         VBELN POSNR
        wa_search-posnr =
          wa_stored_search-posnr.

*         Kapitel
        wa_search-kapitel =
          wa_stored_search-kapitel.

*         MDR_DIS / ROOT_DIS
        wa_search-mdr_dokar = wa_stored_search-mdr_dokar.
        wa_search-mdr_dokvr = wa_stored_search-mdr_doknr.
        wa_search-mdr_doktl = wa_stored_search-mdr_doktl.
        wa_search-mdr_dokvr = wa_stored_search-mdr_dokvr.

        wa_search-root_dokar = wa_stored_search-root_dokar.
        wa_search-root_doknr = wa_stored_search-root_doknr.
        wa_search-root_doktl = wa_stored_search-root_doktl.
        wa_search-root_dokvr = wa_stored_search-root_dokvr.

*       F_DYN_TOC
        wa_search-f_dyn_toc = wa_stored_search-f_dyn_toc.

*       F_DYN_COV
        wa_search-f_dyn_cov = wa_stored_search-f_dyn_cov.

*       PSP_HYRACHIE
        wa_search-psp_hierachy = wa_stored_search-psp_hierachy.


*       PARA1 bis 4
        wa_search-para1 = wa_stored_search-para1.
        wa_search-para2 = wa_stored_search-para2.
        wa_search-para3 = wa_stored_search-para3.
        wa_search-para4 = wa_stored_search-para4.

*       kontrollierter Druck
        wa_search-print_type = wa_stored_search-print_type.
        wa_search-recipient = wa_stored_search-recipient.
        wa_search-nr_copies = wa_stored_search-nr_copies.
        wa_search-print_cause = wa_stored_search-print_cause.
        wa_search-charg = wa_stored_search-charg.
        wa_search-date_exterm = wa_stored_search-date_exterm.
        wa_search-time_exterm = wa_stored_search-time_exterm.
        wa_search-user_exterm = wa_stored_search-user_exterm.
        wa_search-cause_exterm = wa_stored_search-cause_exterm.

*       experimentelles Programm
        wa_search-exp_program = wa_stored_search-exp_program.

*         PARA5 bis 8
        wa_search-para5 = wa_stored_search-para5.
        wa_search-para6 = wa_stored_search-para6.
        wa_search-para7 = wa_stored_search-para7.
        wa_search-para8 = wa_stored_search-para8.

*         Customer / Projektnummer
        wa_search-customer = wa_stored_search-customer.
        wa_search-proj_nr = wa_stored_search-proj_nr.

*         Referenzen auf Ausgangsjobs
        wa_search-id_ref   = wa_stored_search-id_ref  .
        wa_search-id_plotjob_ref = wa_stored_search-id_plotjob_ref.
        wa_search-id_plotjob_32_re =
          wa_stored_search-id_plotjob_32_re.

*         Serialnummer
        wa_search-sernr = wa_stored_search-sernr.

*        "2. Tabelle lesen
*        CLEAR wa_stored_search2.
*        SELECT SINGLE * FROM zcl_psb_tmp2
*          INTO wa_stored_search2
*          WHERE
*            uname = wa_stored_search-uname
*            AND object_type  = wa_stored_search-object_type
*            AND dokar = wa_stored_search-dokar
*            AND doknr = wa_stored_search-doknr
*            AND dokvr = wa_stored_search-dokvr
*            AND doktl = wa_stored_search-doktl
*            AND counter = wa_stored_search-counter
*          .
*        IF sy-subrc NE 0.
*        ELSE.
*        ENDIF.

*        URL
        wa_search-url = wa_stored_search2-url.

        "BADI Implementierung um beispielsweise ZZ-Felder zuübergeben
        IF badi_main_pre_001 IS INITIAL.
        ELSE.
          CALL METHOD badi_main_pre_001->chg_stor_src_item
            CHANGING
              wa_stored_search = wa_stored_search
              wa_search        = wa_search.
          IF return IS INITIAL.
          ELSE.
          ENDIF.
        ENDIF.

        APPEND wa_search TO itab_search.

      WHEN OTHERS.

    ENDCASE.
  ENDLOOP.

  IF i_wa_user_data-delete_tmp_search = 'X'.
    DELETE FROM zcl_psb_tmp
      WHERE uname = i_wa_user_data-uname
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
    DELETE FROM zcl_psb_tmp2
      WHERE uname = i_wa_user_data-uname
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    DATA: selected_objects_badi2 TYPE /cideon/ttype_s_docsearch.
    CLEAR selected_objects_badi2.
*         Inhalte übergeben
    selected_objects_badi2[] = itab_search[].
    CLEAR return.
    CALL METHOD badi_main_pre_001->chg_obj_after_read_tmp2
      CHANGING
        selected_objects = selected_objects_badi2
        return           = return.
    IF return IS INITIAL.
*     Inhalte übergeben
      itab_search[] = selected_objects_badi2[].
    ELSE.
    ENDIF.
  ENDIF.

ENDFUNCTION.
