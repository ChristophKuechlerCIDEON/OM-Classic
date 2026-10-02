FUNCTION /cideon/add_to_plotlist.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(P_KNZ_FEHL_BLATT) TYPE  CHAR01 DEFAULT ''
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"  TABLES
*"      ITAB_TMP_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"      ITAB_ZORI_DOC_FILES STRUCTURE  ZORI_DOC_FILES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"      ITAB_ZORI_DOC_FILES_DETAIL STRUCTURE  BAPI_DOC_FILES2
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
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 12.07.2004 - Erstellung
* 23.08.2004 - Dokumenationsdruck
* 25.08.2004 - Schnittstellenänderung
* 27.08.2004 - Schnittstellenänderung
*              ITAB_SEARCH
* 06.04.2005 - Lieferantenanbindung (LIFNR, NAME1_LIFNR)
* 11.04.2005 - Lieferantenanbindung (EBELN)
* 14.04.2005 - DATEINAME_ZIEL Dokumentationsdruck
*              SEITE_VON, SEITE_BIS
* 18.04.2005 - AO$_MERGE
* 17.05.2005 - Adressdaten des Lieferanten
* 19.09.2005 - QMNUM / Meldungsnummer / Sask
* 28.11.2005 - VBELN / Mikron
* 30.03.2006 - AENNR
* 31.03.2006 - STLNR
* 09.08.2006 - Stücklisteninformationen / oberstes Element
* 16.08.2006 - KNZ_CREATE_TOC
*              KNZ_SEND_TOC
* 17.10.2006 - Daten der Änderungsnummer
* 23.02.2007 - Einkaufsbelegposition
* 01.08.2007 - VBELN POSNR
* 07.08.2007 - SP 45
*            - Kapitel
* 13.08.2007 - SP 46
*              MDR_DIS
*              ROOT_DIS
* 22.08.2007 - F_DYN_TOC
* 20.09.2007 - PSP_HIERACHY
* 17.01.2008 - SP62
*              PARA1 bis 4
* 18.07.2008 - SP76
*              7.0.0.1
*              KNZ_USE_MULTIPAGE
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
* SP 104
*            - SATZANZAHL
*
* 7.0.148.3    Übergabe von NR_COPIES aus Baustein
*              FB /CIDEON/ADD_TO_PLOTLIST
*              Mapping auf Feld Kopien, falls gefüllt
*-----------------------------------------------------------------------
*ITAB
*  DATA: itab_zori_doc_files_detail TYPE TABLE OF bapi_doc_files2.
*WA
  DATA: wa_zori_doc_files TYPE zori_doc_files.
  DATA: wa_plotjobs LIKE zcl_s_plotlist.
  DATA: wa_zori_doc_files_detail TYPE bapi_doc_files2.



  DATA: index_details TYPE sy-tabix.
  DATA: tmp_uname LIKE sy-uname.
  DATA: tmp_format_ausgabe LIKE zcl_s_plotlist-format_ausgabe.
* adds the items to the plotting list
  REFRESH itab_tmp_plotjobs.
  LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
    index_details = sy-tabix.
    CLEAR wa_plotjobs.
    MOVE-CORRESPONDING wa_zori_doc_files TO wa_plotjobs.
    READ TABLE itab_zori_doc_files_detail INTO wa_zori_doc_files_detail
      INDEX index_details.
    wa_plotjobs-wsapplication = wa_zori_doc_files_detail-wsapplication.
    wa_plotjobs-filename  = wa_zori_doc_files-filep.
    wa_plotjobs-uname  = i_wa_user_data-uname.
    wa_plotjobs-storagecategory
      = wa_zori_doc_files_detail-storagecategory.

    wa_plotjobs-application_id =
      wa_zori_doc_files_detail-application_id.
    wa_plotjobs-file_id = wa_zori_doc_files_detail-file_id.

    wa_plotjobs-icon_display = icon_doc_item_detail.
    wa_plotjobs-icon_display_dis = icon_doc_header_detail.

    wa_plotjobs-aufnr  = wa_zori_doc_files-aufnr_pp.

    wa_plotjobs-matnr  = wa_zori_doc_files-matnr.
    wa_plotjobs-mat_count  = wa_zori_doc_files-mat_count.

    wa_plotjobs-res4  = wa_zori_doc_files-res4.

    wa_plotjobs-drtxt  = wa_zori_doc_files-drtxt.
    wa_plotjobs-tdotftype  = wa_zori_doc_files-tdotftype.
    wa_plotjobs-tdspoolid  = wa_zori_doc_files-tdspoolid.

    wa_plotjobs-psteu  = wa_zori_doc_files-psteu.
    wa_plotjobs-samlt  = wa_zori_doc_files-samlt.
    wa_plotjobs-pmode  = wa_zori_doc_files-pmode.
    wa_plotjobs-drart  = wa_zori_doc_files-drart.
    wa_plotjobs-ktext  = wa_zori_doc_files-ktext.
*    wa_plotjobs-selpr  = wa_zori_doc_files-selpr.
    wa_plotjobs-tcode  = wa_zori_doc_files-tcode.

    wa_plotjobs-pspnr  = wa_zori_doc_files-projn.

    wa_plotjobs-aufnr_cs  = wa_zori_doc_files-aufnr_cs.

    wa_plotjobs-seitennummer  = wa_zori_doc_files-seitennummer.
    wa_plotjobs-dateiname_ziel = wa_zori_doc_files-dateiname_ziel.
    wa_plotjobs-seite_von = wa_zori_doc_files-seite_von.
    wa_plotjobs-seite_bis = wa_zori_doc_files-seite_bis.
    wa_plotjobs-ao_merge = wa_zori_doc_files-ao_merge.

    wa_plotjobs-lifnr  = wa_zori_doc_files-lifnr.
    wa_plotjobs-name1_lifnr  = wa_zori_doc_files-name1_lifnr.
    wa_plotjobs-ebeln  = wa_zori_doc_files-ebeln.

    wa_plotjobs-lif_tel_number = wa_zori_doc_files-lif_tel_number.
    wa_plotjobs-lif_tel_extens = wa_zori_doc_files-lif_tel_extens.
    wa_plotjobs-lif_telnr_long = wa_zori_doc_files-lif_telnr_long.
    wa_plotjobs-lif_fax_number = wa_zori_doc_files-lif_fax_number.
    wa_plotjobs-lif_fax_extens = wa_zori_doc_files-lif_fax_extens.
    wa_plotjobs-lif_faxnr_long = wa_zori_doc_files-lif_faxnr_long.
    wa_plotjobs-lif_smtp_addr = wa_zori_doc_files-lif_smtp_addr.
    wa_plotjobs-lif_smtp_srch = wa_zori_doc_files-lif_smtp_srch.

    wa_plotjobs-qmnum = wa_zori_doc_files-qmnum.

    wa_plotjobs-vbeln = wa_zori_doc_files-vbeln.

*   Änderungsnummer
    wa_plotjobs-aennr = wa_zori_doc_files-aennr.

*   Stücklistennummer
    wa_plotjobs-stlnr = wa_zori_doc_files-stlnr.

*   oberstes Element / Dokumentenstückliste
    wa_plotjobs-dokar_bom = wa_zori_doc_files-dokar_bom.
    wa_plotjobs-doknr_bom = wa_zori_doc_files-doknr_bom.
    wa_plotjobs-doktl_bom = wa_zori_doc_files-doktl_bom.
    wa_plotjobs-dokvr_bom = wa_zori_doc_files-dokvr_bom.

*   KNZ_CREATE_TOC
    wa_plotjobs-knz_create_toc = i_wa_user_data-knz_create_toc.

*   KNZ_SEND_TOC
    wa_plotjobs-knz_send_toc = i_wa_user_data-knz_send_toc.

*   Daten der Änderungsnummer
    wa_plotjobs-datuv = wa_zori_doc_files-datuv.
    wa_plotjobs-andat = wa_zori_doc_files-andat.
    wa_plotjobs-aedat = wa_zori_doc_files-aedat.

*   Einkaufsbelegsposition
    wa_plotjobs-ebelp = wa_zori_doc_files-ebelp.

*   VBELN POSNR
    wa_plotjobs-posnr = wa_zori_doc_files-posnr.

*   Kapitel
    wa_plotjobs-kapitel = wa_zori_doc_files-kapitel.

*   MDR_DIS / TR_DIS
    wa_plotjobs-mdr_dokar = wa_zori_doc_files-mdr_dokar.
    wa_plotjobs-mdr_doknr = wa_zori_doc_files-mdr_doknr.
    wa_plotjobs-mdr_doktl = wa_zori_doc_files-mdr_doktl.
    wa_plotjobs-mdr_dokvr = wa_zori_doc_files-mdr_dokvr.

    wa_plotjobs-root_dokar = wa_zori_doc_files-root_dokar.
    wa_plotjobs-root_doknr = wa_zori_doc_files-root_doknr.
    wa_plotjobs-root_doktl = wa_zori_doc_files-root_doktl.
    wa_plotjobs-root_dokvr = wa_zori_doc_files-root_dokvr.

*   F_DYN_TOC
    wa_plotjobs-f_dyn_toc = wa_zori_doc_files-f_dyn_toc.

*   PSP_HIERACHY
    wa_plotjobs-psp_hierachy = wa_zori_doc_files-psp_hierachy.

*   PARA1 bis 4
    wa_plotjobs-para1 = wa_zori_doc_files-para1.
    wa_plotjobs-para2 = wa_zori_doc_files-para2.
    wa_plotjobs-para3 = wa_zori_doc_files-para3.
    wa_plotjobs-para4 = wa_zori_doc_files-para4.

*   KNZ_MULTI_PAGE
    wa_plotjobs-knz_multi_page = i_wa_user_data-knz_use_multipage.

*   kontrollierter Druck
    wa_plotjobs-print_type = wa_zori_doc_files-print_type.
    wa_plotjobs-recipient = wa_zori_doc_files-recipient.
    wa_plotjobs-nr_copies = wa_zori_doc_files-nr_copies.
    wa_plotjobs-print_cause = wa_zori_doc_files-print_cause.
    wa_plotjobs-charg = wa_zori_doc_files-charg.
    wa_plotjobs-date_exterm = wa_zori_doc_files-date_exterm.
    wa_plotjobs-time_exterm = wa_zori_doc_files-time_exterm.
    wa_plotjobs-user_exterm = wa_zori_doc_files-user_exterm.
    wa_plotjobs-cause_exterm = wa_zori_doc_files-cause_exterm.

*   experimentelles Programm
    wa_plotjobs-exp_program = wa_zori_doc_files-exp_program.


    SELECT SINGLE posid FROM prps
      INTO wa_plotjobs-pspid
      WHERE pspnr = wa_plotjobs-pspnr
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    APPEND wa_plotjobs TO itab_tmp_plotjobs.
  ENDLOOP.

*  PERFORM add_objectkey_to_plotlist.
  CALL FUNCTION '/CIDEON/ADD_OBJECTKEY_TO_PLOTL'
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  IF i_wa_user_data-knz_use_merkmal_format = 'X'.
*    PERFORM add_format_field.
    CALL FUNCTION '/CIDEON/ADD_FORMAT_FIELD'
         EXPORTING
              i_wa_default_data = i_wa_default_data
         TABLES
              itab_tmp_plotjobs = itab_tmp_plotjobs
         EXCEPTIONS
              error             = 1
              OTHERS            = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.
  ENDIF.

  IF i_wa_user_data-knz_use_multipage = 'X'.
*    PERFORM check_for_multipage.
    CALL FUNCTION '/CIDEON/CHECK_FOR_MULTIPAGE'
         TABLES
              itab_tmp_plotjobs = itab_tmp_plotjobs
         EXCEPTIONS
              error             = 1
              OTHERS            = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
  ENDIF.

*   ask for fitting distributor
  " check for using of CLF / PPL
  " nur relevant für PostProcessoranbindung !!!
  " deshalb nicht mehr implementiert
*Z_CL_GET_VERTEILER
*  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*    IF i_wa_user_data-knz_use_post = 'X'.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDLOOP.
* ask for fitting distributor end


* Kennzeichen Fehlblatt
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-knz_fehl_blatt = p_knz_fehl_blatt.
    IF wa_plotjobs-knz_fehl_blatt = 'X'.
*      wa_plotjobs-light = 1.
      wa_plotjobs-icon_fehlblatt = i_wa_user_data-fehlblatt_icon.
    ELSE.
*      wa_plotjobs-light = 3.
      wa_plotjobs-icon_fehlblatt = ''.
    ENDIF.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

* Spezialdokumente
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    IF wa_plotjobs-knz_spez_dok = 'X'.
      wa_plotjobs-icon_spez_dok = i_wa_user_data-spez_dok_icon.
    ELSE.
      CONTINUE.
    ENDIF.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

* default values
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    " check for using of CLF / PPL
    IF i_wa_user_data-knz_use_post = 'X'.
      EXIT.
    ELSE.
    ENDIF.

    wa_plotjobs-preprocessor = i_wa_user_data-preprocessor.

    "wa_plotjobs-prio = i_wa_default_data-default_prio.
    "wa_plotjobs-kopien = i_wa_default_data-default_kopien.

    " 2009/09/07
    wa_plotjobs-prio = i_wa_user_data-default_prio.
    wa_plotjobs-kopien = i_wa_user_data-default_kopien.
    wa_plotjobs-satzanzahl = i_wa_user_data-default_satzanzahl.

    " 2011/04/18
    IF wa_plotjobs-nr_copies IS INITIAL OR
      wa_plotjobs-nr_copies = 0.
    ELSE.
      wa_plotjobs-kopien = wa_plotjobs-nr_copies.
    ENDIF.

*   möglicherweise schon vorbelegt
    IF wa_plotjobs-verteiler IS INITIAL.
      wa_plotjobs-verteiler = i_wa_user_data-verteiler.
    ELSE.
    ENDIF.

    "MOVE-CORRESPONDING wa_default_verteiler TO wa_plotjobs.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.
* default values ende

* Spezialeinträge
* List & Label Vorlagen
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    " check for using of CLF / PPL
    IF i_wa_user_data-knz_use_post = 'X'.
      EXIT.
    ELSE.
    ENDIF.

    CASE wa_plotjobs-object_type.
      WHEN c_sl_object_type.
        DATA: wa_tmp_prep_usr TYPE zcl_preproz_user.
        DATA: wa_preproz_lal TYPE zcl_preproz_lal.
        CLEAR wa_tmp_prep_usr.
        CLEAR wa_preproz_lal.

        SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_prep_usr
          WHERE uname = sy-uname
          AND status = c_status_aktiv
          .
        IF sy-subrc NE 0.
          "Defaultbenutzer verwenden
          SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_prep_usr
            WHERE uname = i_wa_default_data-default_nutzer
            AND status = c_status_aktiv
            .
          IF sy-subrc NE 0.
          ELSE.
          ENDIF.
        ELSE.
        ENDIF.
*       Lesen der Vorlagendatei
        SELECT SINGLE * FROM zcl_preproz_lal INTO wa_preproz_lal
          WHERE preprozessor = wa_tmp_prep_usr-preprozessor
          AND object_type = c_sl_object_type
          AND status = c_status_aktiv
          .
        IF sy-subrc NE 0.
          MESSAGE s002(zcl_plint_tools)
            WITH 'zcl_preproz_lal' wa_tmp_prep_usr-preprozessor
            c_sl_object_type c_status_aktiv.
        ELSE.
        ENDIF.

        wa_plotjobs-vorlage_l_and_l = wa_preproz_lal-vorlage_l_and_l.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.



*  PERFORM add_compression_field.
*  PERFORM add_special_fields.
*  PERFORM check_priorities.
  CALL FUNCTION '/CIDEON/CHECK_PRIORITIES'
       EXPORTING
            i_wa_user_data    = i_wa_user_data
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* DIS Status Visiualisierung etc.
*  PERFORM get_dok_status.
  CALL FUNCTION '/CIDEON/GET_DOK_STATUS'
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
            itab_search       = itab_search
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


*  PERFORM reindex_table.
  CALL FUNCTION '/CIDEON/REINDEX_TABLE'
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    APPEND wa_plotjobs TO itab_plotjobs.
  ENDLOOP.


ENDFUNCTION.
