FUNCTION /cideon/plot_va_get_addr_.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_VBELN) TYPE  VBELN
*"     VALUE(I_PARVW) TYPE  PARVW_4
*"  EXPORTING
*"     VALUE(O_PARTNER_ADDR) TYPE  /CIDEON/SDPARTNER
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 05.07.2006 - Erstellung
*-----------------------------------------------------------------------
* Adresse für VBELN und Partnerrolle holen
*-----------------------------------------------------------------------
*ITAB
  DATA: it_sdpartner TYPE TABLE OF /cideon/sdpartner. "sdpartnerlist.
  DATA: it_vbpa TYPE TABLE OF vbpa.

*WA
  DATA: wa_sdpartner TYPE /cideon/sdpartner. "sdpartnerlist.
  DATA: wa_vbpa TYPE vbpa.

  IF i_vbeln IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  IF i_parvw IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.


* Partner lesen
  CLEAR it_vbpa.
  SELECT * FROM vbpa
    INTO TABLE it_vbpa
    WHERE vbeln = i_vbeln
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

* Tabelle bereinigen
  LOOP AT it_vbpa INTO wa_vbpa.
    IF wa_vbpa-parvw = i_parvw.
    ELSE.
      DELETE it_vbpa INDEX sy-tabix.
    ENDIF.
  ENDLOOP.


  IF it_vbpa[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.


  DATA: addr1_complete TYPE szadr_addr1_complete.
  CLEAR addr1_complete.

* Kommunikationsdaten der Partner lesen
  CLEAR it_sdpartner.
  LOOP AT it_vbpa INTO wa_vbpa.
*   Adressdaten holen
    CLEAR wa_sdpartner.
    MOVE-CORRESPONDING wa_vbpa TO wa_sdpartner.

    CALL FUNCTION 'ADDR_GET_COMPLETE'
      EXPORTING
        addrnumber                    = wa_vbpa-adrnr
*       ADDRHANDLE                    =
*       ARCHIVE_HANDLE                =
      IMPORTING
        addr1_complete                = addr1_complete
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
    ENDIF.

    IF sy-subrc NE 0.
*      APPEND wa_sdpartner TO it_sdpartner.
*      CONTINUE.
    ELSE.
    ENDIF.

    DATA: wa_szadr_addr1_line TYPE szadr_addr1_line.

    LOOP AT addr1_complete-addr1_tab INTO wa_szadr_addr1_line.
      IF wa_szadr_addr1_line-data-date_from <= sy-datum
        AND wa_szadr_addr1_line-data-date_to >= sy-datum.
        MOVE-CORRESPONDING wa_szadr_addr1_line-data
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    DATA: wa_szadr_adtel_line TYPE szadr_adtel_line.
    LOOP AT addr1_complete-adtel_tab INTO wa_szadr_adtel_line.
      IF wa_szadr_adtel_line-date_from <= sy-datum
        .
        MOVE-CORRESPONDING wa_szadr_adtel_line-adtel
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    DATA: wa_szadr_adfax_line TYPE szadr_adfax_line.
    LOOP AT addr1_complete-adfax_tab INTO wa_szadr_adfax_line.
      IF wa_szadr_adfax_line-date_from <= sy-datum
        .
        MOVE-CORRESPONDING wa_szadr_adfax_line-adfax
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    DATA: wa_szadr_adsmtp_line TYPE szadr_adsmtp_line.
    LOOP AT addr1_complete-adsmtp_tab INTO wa_szadr_adsmtp_line.
      IF wa_szadr_adsmtp_line-date_from <= sy-datum
        .
        MOVE-CORRESPONDING wa_szadr_adsmtp_line-adsmtp
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.


    APPEND wa_sdpartner TO it_sdpartner.

  ENDLOOP.

  READ TABLE it_sdpartner INTO o_partner_addr
    INDEX 1.




*  break kuechler.


ENDFUNCTION.
