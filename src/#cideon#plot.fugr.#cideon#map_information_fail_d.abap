FUNCTION /cideon/map_information_fail_d.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(WA_SEARCH_TMP) TYPE  ZCL_S_DOCSEARCH
*"  TABLES
*"      ITAB_ZORI_DOC_FILES STRUCTURE  ZCL_S_FAIL_DOCUMENT
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
* 12.07.2004 - Erstellung
* 23.08.2004 - Dokumentationsdruck
* 31.03.2005 - DKTXT / DKTXT_UC
* 06.04.2005 - Lieferantenanbindung (LIFNR, NAME1_LIFNR)
* 11.04.2005 - Lieferantenanbindung (EBELN)
* 14.04.2005 - DATEINAME_ZIEL für Dokumentationsdruck AMMANN
*              SEITE_VON, SEITE_BIS
* 18.04.2005 - AO$_MERGE
* 19.09.2005 - QMNUM / Meldung / Sask
* 28.11.2005 - VBELN / Mikron
* 24.01.2006 - Kopie / Umbau auf FAIL_DOKUMENTE
* 30.03.2006 - AENNR
* 31.03.2006 - STLNR
* 09.08.2006 - Stücklisteninformationen / oberstes Element
* 17.10.2006 - Daten der Änderungsnummer
* 23.02.2007 - Einkaufsbelegnummer
* 01.08.2007 - VBELN POSNR
* 07.08.2007 - SP 45
*              Kapitel
* 13.08.2007 - SP 46
*              MDR_DIS
*              ROOT_DIS
* 22.08.2007 - F_DYN_TOC
* 20.09.2007 - PSP_HIERACHY
* 17.01.2008 - SP 62
*              PARA1 bis 4
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
* SP 136
* 7.0.136.1  - CKR
*              Einführung eines MOVE-CORRESPONDING
*              Teile der ZORI_DOC_FILES wegspeichern
*
*-----------------------------------------------------------------------
* Bitte Änderungen parallell halten zu /CIDEON/MAP_INFORMATION
*-----------------------------------------------------------------------
*WA
*  DATA: wa_zori_doc_files TYPE zori_doc_files.
  DATA: wa_zori_doc_files TYPE zcl_s_fail_document.
  DATA: ls_zori_doc_files_tmp TYPE zcl_s_fail_document.



*   normale Weitergabe von Informationen speziellen Felder des
*   Fertigungsauftrages / CS Auftrages
  LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
    "temporäres Speichern
    CLEAR ls_zori_doc_files_tmp.
    ls_zori_doc_files_tmp = wa_zori_doc_files.

    MOVE-CORRESPONDING wa_search_tmp TO wa_zori_doc_files.

    "alte Werte wieder übergeben
    "wa_zori_doc_files-cont = ls_zori_doc_files_tmp-cont.
    wa_zori_doc_files-dokar = ls_zori_doc_files_tmp-dokar.
    wa_zori_doc_files-doknr = ls_zori_doc_files_tmp-doknr.
    wa_zori_doc_files-dokvr = ls_zori_doc_files_tmp-dokvr.
    wa_zori_doc_files-doktl = ls_zori_doc_files_tmp-doktl.
    wa_zori_doc_files-cdate = ls_zori_doc_files_tmp-cdate.
    wa_zori_doc_files-checked = ls_zori_doc_files_tmp-checked.
    wa_zori_doc_files-sheet = ls_zori_doc_files_tmp-sheet.
    wa_zori_doc_files-filep = ls_zori_doc_files_tmp-filep.
    wa_zori_doc_files-knz_spez_dok = ls_zori_doc_files_tmp-knz_spez_dok.
    wa_zori_doc_files-object_type = ls_zori_doc_files_tmp-object_type.
    wa_zori_doc_files-id_sl = ls_zori_doc_files_tmp-id_sl.
    wa_zori_doc_files-originaltype = ls_zori_doc_files_tmp-originaltype.
    wa_zori_doc_files-sourcedatacarrie =
      ls_zori_doc_files_tmp-sourcedatacarrie.
    wa_zori_doc_files-storagecategory =
      ls_zori_doc_files_tmp-storagecategory.
    wa_zori_doc_files-wsapplication =
      ls_zori_doc_files_tmp-wsapplication.
    wa_zori_doc_files-application_id =
      ls_zori_doc_files_tmp-application_id.
    wa_zori_doc_files-file_id = ls_zori_doc_files_tmp-file_id.
    wa_zori_doc_files-description = ls_zori_doc_files_tmp-description.
    wa_zori_doc_files-language = ls_zori_doc_files_tmp-language.
    wa_zori_doc_files-active_version =
      ls_zori_doc_files_tmp-active_version.
    wa_zori_doc_files-created_at = ls_zori_doc_files_tmp-created_at.
    wa_zori_doc_files-changed_at = ls_zori_doc_files_tmp-changed_at.
    wa_zori_doc_files-created_by = ls_zori_doc_files_tmp-created_by.
    wa_zori_doc_files-changed_by = ls_zori_doc_files_tmp-changed_by.
    wa_zori_doc_files-content_descript =
      ls_zori_doc_files_tmp-content_descript.


*    wa_zori_doc_files-aufnr_pp = wa_search_tmp-aufnr_pp.
*    wa_zori_doc_files-aufpl = wa_search_tmp-aufpl.
*    wa_zori_doc_files-aplzl = wa_search_tmp-aplzl.
*    wa_zori_doc_files-knz_affl = wa_search_tmp-knz_affl.
*    wa_zori_doc_files-knz_afvc = wa_search_tmp-knz_afvc.
*    wa_zori_doc_files-verteiler = wa_search_tmp-verteiler.
*
*    wa_zori_doc_files-folnr = wa_search_tmp-folnr.
*    wa_zori_doc_files-vornr = wa_search_tmp-vornr.
*
*    wa_zori_doc_files-matnr = wa_search_tmp-matnr.
*
*    wa_zori_doc_files-res4 = wa_search_tmp-res4.
*
*    wa_zori_doc_files-drtxt = wa_search_tmp-drtxt.
*    wa_zori_doc_files-tdotftype = wa_search_tmp-tdotftype.
*    wa_zori_doc_files-tdspoolid = wa_search_tmp-tdspoolid.
*
*    wa_zori_doc_files-psteu = wa_search_tmp-psteu.
*    wa_zori_doc_files-samlt = wa_search_tmp-samlt.
*    wa_zori_doc_files-pmode = wa_search_tmp-pmode.
*    wa_zori_doc_files-drart = wa_search_tmp-drart.
*    wa_zori_doc_files-ktext = wa_search_tmp-ktext.
*    wa_zori_doc_files-selpr = wa_search_tmp-selpr.
*    wa_zori_doc_files-tcode = wa_search_tmp-tcode.
*
*    wa_zori_doc_files-projn = wa_search_tmp-projn.
*
*    wa_zori_doc_files-aufnr_cs = wa_search_tmp-aufnr_cs.
*
*    wa_zori_doc_files-seitennummer = wa_search_tmp-seitennummer.
*    wa_zori_doc_files-dateiname_ziel = wa_search_tmp-dateiname_ziel.
*    wa_zori_doc_files-seite_von = wa_search_tmp-seite_von.
*    wa_zori_doc_files-seite_bis = wa_search_tmp-seite_bis.
*    wa_zori_doc_files-ao_merge = wa_search_tmp-ao_merge.
*
*
*    wa_zori_doc_files-dktxt = wa_search_tmp-dktxt.
*    wa_zori_doc_files-dktxt_uc = wa_search_tmp-dktxt_uc.
*
*    wa_zori_doc_files-lifnr = wa_search_tmp-lifnr.
*    wa_zori_doc_files-name1_lifnr = wa_search_tmp-name1_lifnr.
*    wa_zori_doc_files-ebeln = wa_search_tmp-ebeln.
*
*    wa_zori_doc_files-lif_tel_number = wa_search_tmp-lif_tel_number.
*    wa_zori_doc_files-lif_tel_extens = wa_search_tmp-lif_tel_extens.
*    wa_zori_doc_files-lif_telnr_long = wa_search_tmp-lif_telnr_long.
*    wa_zori_doc_files-lif_fax_number = wa_search_tmp-lif_fax_number.
*    wa_zori_doc_files-lif_fax_extens = wa_search_tmp-lif_fax_extens.
*    wa_zori_doc_files-lif_faxnr_long = wa_search_tmp-lif_faxnr_long.
*    wa_zori_doc_files-lif_smtp_addr = wa_search_tmp-lif_smtp_addr.
*    wa_zori_doc_files-lif_smtp_srch = wa_search_tmp-lif_smtp_srch.
*
*    wa_zori_doc_files-qmnum = wa_search_tmp-qmnum.
*
*    wa_zori_doc_files-vbeln = wa_search_tmp-vbeln.
*
**   Änderungsnummer
*    wa_zori_doc_files-aennr = wa_search_tmp-aennr.
*
**   Stücklistennummer
*    wa_zori_doc_files-stlnr = wa_search_tmp-stlnr.
*
**   oberstes Element / Dokumentenstückliste
*    wa_zori_doc_files-dokar_bom = wa_search_tmp-dokar_bom.
*    wa_zori_doc_files-doknr_bom = wa_search_tmp-doknr_bom.
*    wa_zori_doc_files-doktl_bom = wa_search_tmp-doktl_bom.
*    wa_zori_doc_files-dokvr_bom = wa_search_tmp-dokvr_bom.
*
**   Daten der Änderungsnummer
*    wa_zori_doc_files-datuv = wa_search_tmp-datuv.
*    wa_zori_doc_files-andat = wa_search_tmp-andat.
*    wa_zori_doc_files-aedat = wa_search_tmp-aedat.
*
**   Einkaufsbelegsnummer
*    wa_zori_doc_files-ebelp = wa_search_tmp-ebelp.
*
**   VBELN POSNR
*    wa_zori_doc_files-posnr = wa_search_tmp-posnr.
*
**   Kapitel
*    wa_zori_doc_files-kapitel = wa_search_tmp-kapitel.
*
**   MDR_DIS / ROOT_DIS
*    wa_zori_doc_files-mdr_dokar = wa_search_tmp-mdr_dokar.
*    wa_zori_doc_files-mdr_doknr = wa_search_tmp-mdr_doknr.
*    wa_zori_doc_files-mdr_doktl = wa_search_tmp-mdr_doktl.
*    wa_zori_doc_files-mdr_dokvr = wa_search_tmp-mdr_dokvr.
*
*    wa_zori_doc_files-root_dokar = wa_search_tmp-root_dokar.
*    wa_zori_doc_files-root_doknr = wa_search_tmp-root_doknr.
*    wa_zori_doc_files-root_doktl = wa_search_tmp-root_doktl.
*    wa_zori_doc_files-root_dokvr = wa_search_tmp-root_dokvr.
*
**   F_DYN_TOC
*    wa_zori_doc_files-f_dyn_toc = wa_search_tmp-f_dyn_toc.
*
**   PSP_HIERACHY
*    wa_zori_doc_files-psp_hierachy = wa_search_tmp-psp_hierachy.
*
**   PARA1 bis 4
*    wa_zori_doc_files-para1 = wa_search_tmp-para1.
*    wa_zori_doc_files-para2 = wa_search_tmp-para2.
*    wa_zori_doc_files-para3 = wa_search_tmp-para3.
*    wa_zori_doc_files-para4 = wa_search_tmp-para4.
*
**   kontrollierter Druck
*    wa_zori_doc_files-print_type = wa_search_tmp-print_type.
*    wa_zori_doc_files-recipient = wa_search_tmp-recipient.
*    wa_zori_doc_files-nr_copies = wa_search_tmp-nr_copies.
*    wa_zori_doc_files-print_cause = wa_search_tmp-print_cause.
*    wa_zori_doc_files-charg = wa_search_tmp-charg.
*    wa_zori_doc_files-date_exterm = wa_search_tmp-date_exterm.
*    wa_zori_doc_files-time_exterm = wa_search_tmp-time_exterm.
*    wa_zori_doc_files-user_exterm = wa_search_tmp-user_exterm.
*    wa_zori_doc_files-cause_exterm = wa_search_tmp-cause_exterm.
*
**   experimentelles Programm
*    wa_zori_doc_files-exp_program = wa_search_tmp-exp_program.

    MODIFY itab_zori_doc_files FROM wa_zori_doc_files INDEX sy-tabix.
  ENDLOOP.



ENDFUNCTION.
