FUNCTION z_cl_psbrw_write_psb_tmp_batch.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       TABLES
*"              I_ITAB_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*  Schreibt Einträge in Tabelle ZCL_PSB_TMP
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 03.09.2002  -Erstellung
* 23.03.2004 - Erweiterung um Spooleinträge
* 11.05.2007 - Erweiterung um Druckparameter (Nachdruck, etc.)
* 06.04.2005 - Erweiterung um Lieferantendinge (LIFNR, NAME1)
* 18.04.2005 - AO$_MERGE
* 07.08.2007 - SP 45
*            - KAPITEL
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_objects TYPE TABLE OF zcl_pdm_exp_objects.
*WA
  DATA: wa_objects TYPE zcl_pdm_exp_objects.
*NORMAL
  DATA: counter TYPE zcl_psb_tmp-counter.


  REFRESH itab_objects.
  CLEAR wa_objects.

  itab_objects[] = i_itab_objects[].

  CLEAR wa_stored_search.
  wa_stored_search-uname = sy-uname.
  wa_stored_search-zclinsname = sy-uname.
  wa_stored_search-zclinsdate = sy-datum.
  wa_stored_search-zclinstime = sy-uzeit.
  wa_stored_search-zclinsprog = sy-repid.
  wa_stored_search-zclupdname = sy-uname.
  wa_stored_search-zclupddate = sy-datum.
  wa_stored_search-zclupdtime = sy-uzeit.
  wa_stored_search-zclupdprog = sy-repid.

  LOOP AT itab_objects INTO wa_objects.
    wa_stored_search-dokar = wa_objects-dokar.
    wa_stored_search-doknr = wa_objects-doknr.
    wa_stored_search-dokvr = wa_objects-dokvr.
    wa_stored_search-doktl = wa_objects-doktl.
    wa_stored_search-object_type = wa_objects-object_type.

    wa_stored_search-id_sl = wa_objects-id_sl.
    wa_stored_search-aufnr_pp = wa_objects-aufnr_pp.
    wa_stored_search-aufpl = wa_objects-aufpl.

    wa_stored_search-aplzl = wa_objects-aplzl.
    wa_stored_search-knz_affl = wa_objects-knz_affl.
    wa_stored_search-knz_afvc = wa_objects-knz_afvc.
    wa_stored_search-verteiler = wa_objects-verteiler.

    wa_stored_search-folnr = wa_objects-folnr.
    wa_stored_search-vornr = wa_objects-vornr.

*   SPOOL
    wa_stored_search-drtxt = wa_objects-drtxt.
    wa_stored_search-tdotftype = wa_objects-tdotftype.
    wa_stored_search-tdspoolid = wa_objects-tdspoolid.

*   Druck
    wa_stored_search-psteu = wa_objects-psteu.
    wa_stored_search-samlt = wa_objects-samlt.
    wa_stored_search-pmode = wa_objects-pmode.
    wa_stored_search-drart = wa_objects-drart.
    wa_stored_search-ktext = wa_objects-ktext.
    wa_stored_search-selpr = wa_objects-selpr.
    wa_stored_search-tcode = wa_objects-tcode.

*   Projektsystem
    wa_stored_search-projn = wa_objects-projn.

*   CS Integration
    wa_stored_search-aufnr_cs = wa_objects-aufnr_cs.

*   Dokumentationsdruck
    wa_stored_search-seitennummer = wa_objects-seitennummer.
    wa_stored_search-dateiname_ziel = wa_objects-dateiname_ziel.
    wa_stored_search-seite_von = wa_objects-seite_von.
    wa_stored_search-seite_bis = wa_objects-seite_bis.
    wa_stored_search-ao_merge = wa_objects-ao_merge.

*   Lieferantenanbindung
    wa_stored_search-lifnr = wa_objects-lifnr.
    wa_stored_search-name1_lifnr = wa_objects-name1_lifnr.
    wa_stored_search-ebeln = wa_objects-ebeln.

*   VBELN Anbindung
    wa_stored_search-vbeln = wa_objects-vbeln.


*   Änderungsnummer
    wa_stored_search-aennr = wa_objects-aennr.

*   Stücklistennummer
    wa_stored_search-stlnr = wa_objects-stlnr.

*   Einkaufsbeleg Position
    wa_stored_search-ebelp = wa_objects-ebelp.

*   KNZ_MARKED_EBELN	
    wa_stored_search-knz_marked_ebeln = wa_objects-knz_marked_ebeln.

*   VBELN POSNR
    wa_stored_search-posnr = wa_objects-posnr.

*   Kapitel
    wa_stored_search-kapitel = wa_objects-kapitel.

    CLEAR counter.

    CALL FUNCTION 'Z_CL_PLOT_ID_SL_GET_NEXT'
         EXPORTING
              i_numrange_object   = 'ZCL_ID_PSB'
              i_numrange_interval = '01'
         IMPORTING
              e_number            = counter.


*    SELECT MAX( counter ) FROM zcl_psb_tmp
*      INTO counter
*      WHERE uname = wa_stored_search-uname
*      AND dokar = wa_stored_search-dokar
*      AND doknr = wa_stored_search-doknr
*      AND dokvr = wa_stored_search-dokvr
*      AND doktl = wa_stored_search-doktl
*      .
*    IF sy-subrc NE 0.
*      CLEAR counter.
*    ELSE.
*      counter = counter + 1.
*    ENDIF.

    wa_stored_search-counter = counter.

    INSERT zcl_psb_tmp FROM wa_stored_search.
*    MODIFY zcl_psb_tmp FROM wa_stored_search.
    IF sy-subrc NE 0.
      CLEAR text1. CLEAR text2. CLEAR text3. CLEAR text4.
      text1 = 'ZCL_PSB_TMP'.
      CONCATENATE wa_stored_search-dokar wa_stored_search-doknr
        wa_stored_search-dokvr wa_stored_search-doktl
        INTO text2.
      CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
           EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = 150
                i_msgtyp   = 'S'
                i_msgid    = 'ZCL_PLINT_MESSAGE_01'
                i_msgno    = 150
                i_msgv1    = text1
                i_msgv2    = text2
                i_msgv3    = text3
                i_msgv4    = text4
                i_class    = ' '
                i_newhead  = 'X'
                i_messhead = 'X'
           EXCEPTIONS
                error      = 1
                OTHERS     = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
