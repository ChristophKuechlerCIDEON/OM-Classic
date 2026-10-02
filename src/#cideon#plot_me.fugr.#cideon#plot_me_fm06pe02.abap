FUNCTION /cideon/plot_me_fm06pe02.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(ENT_RETCO) TYPE  RETCO
*"     VALUE(L_NAST) TYPE  NAST
*"     VALUE(L_DOC) TYPE  MEEIN_PURCHASE_DOC_PRINT
*"     VALUE(L_SPOOLID) TYPE  RSPOID OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
************************************************************************
*        Druckroutinen für Einkaufsbelege                              *
************************************************************************
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:

*-----------------------------------------------------------------------
* Journal
* 23.09.2006 - Erstellung / Kopie
* 26.03.2007 - SP 34
*              BADI Implementierung / falls WA gelöscht wird, dann nicht
*              hinzufügen
* 21.04.2007 - SP 36
*            - Übergabe weiterer Daten an eMail Sendeprogramm
* 26.02.2008 - SP 66
*              Umschalten der Verteiler von FAUF nach EBELN
* 08.04.2008 - SP 72
*              BADI für Einkauf
* 18.08.2010 - SP 132
*              Übergabe der Spoolid
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------


*  break kuechler.

* ent_retco
  IF ent_retco = '0'.
  ELSE.
    EXIT.
  ENDIF.

* syst-msgv1 enthält die Spool ID
* schreiben der spool id in zcl_psb_tmp oder ins memory
* OBJECT_TYPE : SPOOL
* Counter normal gefüllt
*WA
  DATA: wa_default_data TYPE /cideon/plot_defaultdata.
  DATA: wa_user_data TYPE /cideon/plot_userdata.

  DATA: wa_item TYPE zcl_pdm_objects_fa_int.
  DATA: itab_item TYPE TABLE OF zcl_pdm_objects_fa_int.

  DATA: exit_pre TYPE REF TO /cideon/if_ex_pre_main_001.

  DATA: f_cancel.


  CLEAR f_cancel.

* Daten übergeben
  CLEAR wa_item.
  CLEAR itab_item.

* BADI Integrieren

  CLEAR exit_pre.
  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = exit_pre.


  IF exit_pre IS INITIAL.
  ELSE.
    CALL METHOD exit_pre->chg_me_start
      CHANGING
        ent_retco = ent_retco
        l_nast    = l_nast
        cancel    = f_cancel
        .
    IF f_cancel = 'X'.
      EXIT.
    ELSE.
    ENDIF.
  ENDIF.

  IF l_spoolid IS INITIAL.

* Abfangen der Möglichkeit, daß keine Nummer übergeben wird
    IF syst-msgv1 IS INITIAL.
      EXIT.
    ELSE.
    ENDIF.

    IF syst-msgv1 CA sy-abcde.
      EXIT.
    ELSE.
      wa_item-tdspoolid = syst-msgv1.
    ENDIF.
  ELSE.
    wa_item-tdspoolid = l_spoolid.
  ENDIF.

* Einstellungen lesen
  CLEAR wa_user_data.
  CLEAR wa_default_data.


  DATA: f_batch.
  IF sy-cprog = 'RSM13000'.
    f_batch = 'X'.
  ELSE.
    f_batch = 'X'.
  ENDIF.

  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = f_batch
       IMPORTING
            o_default_data = wa_default_data.


  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = wa_default_data
            i_batch        = sy-batch
       IMPORTING
            o_user_data    = wa_user_data.


* Füllen weiterer Felder notwendig
* Einkaufsbelegnummer etc.
* Adressen

  wa_item-ebeln = l_nast-objky.
  wa_item-lifnr = l_nast-parnr.

  DATA: wa_po_header TYPE bapiekkol.
  DATA: po_number TYPE bapiekko-po_number.

  CLEAR po_number.
  CLEAR wa_po_header.

  po_number = wa_item-ebeln.

  CALL FUNCTION 'BAPI_PO_GETDETAIL'
    EXPORTING
     purchaseorder                    = po_number
      items                            = ''
*     ACCOUNT_ASSIGNMENT               = ' '
*     SCHEDULES                        = ' '
*     HISTORY                          = ' '
*     ITEM_TEXTS                       = ' '
*     HEADER_TEXTS                     = ' '
*     SERVICES                         = ' '
*     CONFIRMATIONS                    = ' '
*     SERVICE_TEXTS                    = ' '
*     EXTENSIONS                       = ' '
    IMPORTING
      po_header                        = wa_po_header
*     PO_ADDRESS                       =
*   TABLES
*     PO_HEADER_TEXTS                  =
*     PO_ITEMS                         =
*     PO_ITEM_ACCOUNT_ASSIGNMENT       =
*     PO_ITEM_SCHEDULES                =
*     PO_ITEM_CONFIRMATIONS            =
*     PO_ITEM_TEXTS                    =
*     PO_ITEM_HISTORY                  =
*     PO_ITEM_HISTORY_TOTALS           =
*     PO_ITEM_LIMITS                   =
*     PO_ITEM_CONTRACT_LIMITS          =
*     PO_ITEM_SERVICES                 =
*     PO_ITEM_SRV_ACCASS_VALUES        =
*     RETURN                           =
*     PO_SERVICES_TEXTS                =
*     EXTENSIONOUT                     =
            .

  wa_item-name1_lifnr = wa_po_header-vend_name.


  wa_item-tcode = '/CIDEON/FM06PE02'.


  "wa_item-verteiler = wa_user_data-default_verteiler_fauf.
  wa_item-verteiler = wa_user_data-default_verteiler_ebeln.


  wa_item-knz_marked_ebeln = 'X'.

  APPEND wa_item TO itab_item.


  CALL FUNCTION 'Z_CL_INT_WRITE_PLOT_PSB_SPOOL'
* EXPORTING
*   F_AUT_PROCESS       = 'X'
    TABLES
      i_itab_items        = itab_item
    EXCEPTIONS
      error               = 1
      OTHERS              = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CLEAR itab_item.


  DATA it_xekpo LIKE l_doc-xekpo.
  DATA: it_drad TYPE TABLE OF drad.

  DATA: wa_ekpo TYPE ekpo.
  DATA: wa_drad TYPE drad.

  DATA: drad_objky TYPE drad-objky.

  CLEAR it_xekpo.
  it_xekpo[] = l_doc-xekpo[].

  LOOP AT it_xekpo INTO wa_ekpo.
*   weitere Dokumente berücksichtigen
*   Dokumente zur Bestellung
    IF wa_user_data-knz_ebeln_pos = 'X'.
*     Lesen der Dokumentverknüpfungen
      CLEAR it_drad.
      CLEAR drad_objky.

      CONCATENATE wa_ekpo-ebeln wa_ekpo-ebelp
        INTO drad_objky.

      SELECT * FROM drad INTO TABLE it_drad
        WHERE dokob = 'EKPO'
        AND objky = drad_objky
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT it_drad INTO wa_drad.
        CLEAR wa_item.
        wa_item-ebeln = l_nast-objky.
        wa_item-lifnr = l_nast-parnr.
        wa_item-tcode = '/CIDEON/FM06PE02'.

        "wa_item-verteiler = wa_user_data-default_verteiler_fauf.
        wa_item-verteiler = wa_user_data-default_verteiler_ebeln.

        wa_item-dokar = wa_drad-dokar.
        wa_item-doknr = wa_drad-doknr.
        wa_item-doktl = wa_drad-doktl.
        wa_item-dokvr = wa_drad-dokvr.

*       Nummer der Einkaufsbelegposition
        wa_item-ebelp = wa_ekpo-ebelp.

        wa_item-name1_lifnr = wa_po_header-vend_name.

*       Materialnummer übergeben
        wa_item-matnr = wa_ekpo-matnr.

        IF exit_pre IS INITIAL.
        ELSE.
          CALL METHOD exit_pre->chg_me_doc_ebelnp
            CHANGING
              wa_item = wa_item
              .
        ENDIF.

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

        APPEND wa_item TO itab_item.
      ENDLOOP.

    ELSE.
    ENDIF.

*   Dokumente zum Material
    IF wa_user_data-knz_ebeln_mat = 'X'.
      CLEAR it_drad.
      CLEAR drad_objky.

*      CONCATENATE wa_ekpo-ebeln wa_ekpo-ebelp
*        INTO drad_objky.

      drad_objky = wa_ekpo-matnr.

      SELECT * FROM drad INTO TABLE it_drad
        WHERE dokob = 'MARA'
        AND objky = drad_objky
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT it_drad INTO wa_drad.
        CLEAR wa_item.
        wa_item-ebeln = l_nast-objky.
        wa_item-lifnr = l_nast-parnr.
        wa_item-tcode = '/CIDEON/FM06PE02'.

        "wa_item-verteiler = wa_user_data-default_verteiler_fauf.
        wa_item-verteiler = wa_user_data-default_verteiler_ebeln.

        wa_item-dokar = wa_drad-dokar.
        wa_item-doknr = wa_drad-doknr.
        wa_item-doktl = wa_drad-doktl.
        wa_item-dokvr = wa_drad-dokvr.

*       Nummer der Einkaufsbelegposition
        wa_item-ebelp = wa_ekpo-ebelp.

        wa_item-name1_lifnr = wa_po_header-vend_name.

*       Materialnummer übergeben
        wa_item-matnr = wa_ekpo-matnr.

        IF exit_pre IS INITIAL.
        ELSE.
          CALL METHOD exit_pre->chg_me_doc_mat_ebelnp
            CHANGING
              wa_item = wa_item
              .
        ENDIF.

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

        APPEND wa_item TO itab_item.
      ENDLOOP.


    ELSE.
    ENDIF.

*   Dokumente zu den Materialpositionen
*   Auflösen der Stückliste
    IF wa_user_data-knz_ebeln_bom = 'X'.
      IF exit_pre IS INITIAL.
      ELSE.
        CALL METHOD exit_pre->chg_me_doc_matpos_ebelnp
        CHANGING
          wa_item = wa_item
          .

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

      ENDIF.
    ELSE.
    ENDIF.

*   spezielles Dokument für Aufruf des Dialoges
*   zur Auswahl der zu druckenden Dokumente
*   siehe Plotservices
    IF wa_user_data-knz_ebeln_dialog = 'X'.
      IF exit_pre IS INITIAL.
      ELSE.
        CALL METHOD exit_pre->chg_me_doc_dialog_ebelnp
          CHANGING
            wa_item = wa_item
            .

        IF wa_item IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

      ENDIF.
    ELSE.
    ENDIF.

  ENDLOOP.


* Schreiben der Einträge in Übergabetabelle
  CALL FUNCTION 'Z_CL_INT_WRITE_PLOT_PSB_NO_STR'
       EXPORTING
            f_aut_process = ''
       TABLES
            i_itab_items  = itab_item
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.

* Rückmeldung per Expressmail
  IF wa_user_data-knz_ebeln_expressmail = 'X'.
    CALL FUNCTION '/CIDEON/SEND_MAIL_EBELN_PLOT'
         EXPORTING
              i_user      = sy-uname
              i_po_header = wa_po_header
         TABLES
              it_ekpo     = it_xekpo
         EXCEPTIONS
              error       = 1
              OTHERS      = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
  ENDIF.



ENDFUNCTION.
