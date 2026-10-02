FUNCTION /cideon/get_lifnr_data.
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
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 17.05.2005 - Erstellung / 5. Todesstag
* 21.05.2007 - SP 39
*              Defaulteinträge lesen
* SP 115
* 11.01.2010 - Übernahme der normalen Faxnummer, falls
*              lange Faxnummer nicht vorhanden
*
*-----------------------------------------------------------------------
* holt sich Lieferantendaten zu einer LIFNR etc.
*-----------------------------------------------------------------------

* try to read stored search entries
*ITAB
*WA
  DATA: wa_search LIKE itab_search.
  DATA: wa_pl_log TYPE /cideon/pl_log.
  DATA: wa_lfa1 TYPE lfa1.
  DATA: wa_kompl_adresse TYPE szadr_addr1_complete.
  DATA: wa_adtel TYPE szadr_adtel_line.
  DATA: wa_adfax TYPE szadr_adfax_line.
  DATA: wa_adsmtp TYPE szadr_adsmtp_line.
*NORMAL
  DATA: index TYPE i.


  LOOP AT itab_search INTO wa_search.
*   nur relevante Einträge benutzen
    IF wa_search-lifnr IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

    index = sy-tabix.

*   Adressnummer holen
    CLEAR wa_lfa1.
    SELECT SINGLE * FROM lfa1 INTO wa_lfa1
      WHERE lifnr = wa_search-lifnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

*   ADDR_GET_COMPLETE
    CALL FUNCTION 'ADDR_GET_COMPLETE'
      EXPORTING
        addrnumber                    = wa_lfa1-adrnr
*       ADDRHANDLE                    =
*       ARCHIVE_HANDLE                =
      IMPORTING
        addr1_complete                = wa_kompl_adresse
      EXCEPTIONS
        parameter_error               = 1
        address_not_exist             = 2
        internal_error                = 3
        wrong_access_to_archive       = 4
        OTHERS                        = 5
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      CONTINUE.
    ENDIF.

*   ersten Eintrag der Tabellen lesen
    CLEAR wa_adtel.
    IF wa_kompl_adresse-adtel_tab[] IS INITIAL.
    ELSE.
      READ TABLE wa_kompl_adresse-adtel_tab
        INTO wa_adtel INDEX 1.

      CLEAR wa_adtel.
      LOOP AT wa_kompl_adresse-adtel_tab
        INTO wa_adtel.
        IF wa_adtel-date_from <= sy-datum
          AND wa_adtel-adtel-flgdefault = 'X'.
          EXIT.
        ELSE.
        ENDIF.
      ENDLOOP.
      IF wa_adtel IS INITIAL.
        READ TABLE wa_kompl_adresse-adtel_tab
          INTO wa_adtel INDEX 1.
      ELSE.
      ENDIF.


    ENDIF.

    CLEAR wa_adfax.
    IF wa_kompl_adresse-adfax_tab[] IS INITIAL.
    ELSE.
      READ TABLE wa_kompl_adresse-adfax_tab
        INTO wa_adfax INDEX 1.

      CLEAR wa_adfax.
      LOOP AT wa_kompl_adresse-adfax_tab
        INTO wa_adfax.
        IF wa_adfax-date_from <= sy-datum
          AND wa_adfax-adfax-flgdefault = 'X'.
          EXIT.
        ELSE.
        ENDIF.
      ENDLOOP.
      IF wa_adfax IS INITIAL.
        READ TABLE wa_kompl_adresse-adfax_tab
          INTO wa_adfax INDEX 1.
      ELSE.
      ENDIF.
    ENDIF.

    CLEAR wa_adsmtp.
    IF wa_kompl_adresse-adsmtp_tab[] IS INITIAL.
    ELSE.
      READ TABLE wa_kompl_adresse-adsmtp_tab
        INTO wa_adsmtp INDEX 1.

      CLEAR wa_adsmtp.
      LOOP AT wa_kompl_adresse-adsmtp_tab
        INTO wa_adsmtp.
        IF wa_adsmtp-date_from <= sy-datum
          AND wa_adsmtp-adsmtp-flgdefault = 'X'.
          EXIT.
        ELSE.
        ENDIF.
      ENDLOOP.
      IF wa_adsmtp IS INITIAL.
        READ TABLE wa_kompl_adresse-adsmtp_tab
          INTO wa_adsmtp INDEX 1.
      ELSE.
      ENDIF.
    ENDIF.

*   Übergabe der Werte
    wa_search-lif_tel_number = wa_adtel-adtel-tel_number.
    wa_search-lif_tel_extens = wa_adtel-adtel-tel_extens.
    wa_search-lif_telnr_long = wa_adtel-adtel-telnr_long.
    wa_search-lif_fax_number = wa_adfax-adfax-fax_number.
    wa_search-lif_fax_extens = wa_adfax-adfax-fax_extens.
    wa_search-lif_faxnr_long = wa_adfax-adfax-faxnr_long.
    wa_search-lif_smtp_addr = wa_adsmtp-adsmtp-smtp_addr.
    wa_search-lif_smtp_srch = wa_adsmtp-adsmtp-smtp_srch.

    " 2010/01/11 lange Faxnummer füllen, falls initial
    IF wa_search-lif_faxnr_long IS INITIAL.
      wa_search-lif_faxnr_long = wa_search-lif_fax_number.
    ELSE.
    ENDIF.

    IF wa_search-lif_telnr_long IS INITIAL.
      wa_search-lif_telnr_long = wa_search-lif_tel_number.
    ELSE.
    ENDIF.

    MODIFY itab_search FROM wa_search INDEX index.

  ENDLOOP.


ENDFUNCTION.
