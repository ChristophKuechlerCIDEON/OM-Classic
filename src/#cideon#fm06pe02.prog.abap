*----------------------------------------------------------------------*
*   INCLUDE FM06PE02                                                   *
*----------------------------------------------------------------------*
FORM entry_neu USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.



  CALL FUNCTION '/CIDEON/PLOT_ME_FM06PE02'
       EXPORTING
            ent_retco = ent_retco
            l_nast    = l_nast
            l_doc     = l_doc
       EXCEPTIONS
            error     = 1
            OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


**&---------------------------------------------------------------------
**
** CIDEON SAP Plotting Interface
**   Integration
***************
** 28.02.2007 - Übergabe von Lieferantendaten
**----------------------------------------------------------------------
*-
*
**  break kuechler.
*
** ent_retco
*  IF ent_retco = '0'.
*  ELSE.
*    EXIT.
*  ENDIF.
*
** syst-msgv1 enthält die Spool ID
** schreiben der spool id in zcl_psb_tmp oder ins memory
** OBJECT_TYPE : SPOOL
** Counter normal gefüllt
**WA
*  DATA: wa_default_data TYPE /cideon/plot_defaultdata.
*  DATA: wa_user_data TYPE /cideon/plot_userdata.
*
*  DATA: wa_item TYPE zcl_pdm_objects_fa_int.
*  DATA: itab_item TYPE TABLE OF zcl_pdm_objects_fa_int.
*
*  DATA: exit_pre TYPE REF TO /cideon/if_ex_pre_main_001.
*
** Daten übergeben
*  CLEAR wa_item.
*  CLEAR itab_item.
*
** BADI Integrieren
*
*  CLEAR exit_pre.
*  CALL METHOD cl_exithandler=>get_instance
*    CHANGING
*      instance = exit_pre.
*
*
** Abfangen der Möglichkeit, daß keine Nummer übergeben wird
*  IF syst-msgv1 CA sy-abcde.
*    EXIT.
*  ELSE.
*    wa_item-tdspoolid = syst-msgv1.
*  ENDIF.
** Einstellungen lesen
*  CLEAR wa_user_data.
*  CLEAR wa_default_data.
*
*
*  DATA: f_batch.
*  IF sy-cprog = 'RSM13000'.
*    f_batch = 'X'.
*  ELSE.
*  ENDIF.
*
*  CALL FUNCTION 'Z_CL_READ_DEFAULTDATA'
*       EXPORTING
*            i_batch        = f_batch
*       IMPORTING
*            o_default_data = wa_default_data.
*
*
*  CALL FUNCTION 'Z_CL_READ_USERDATA'
*       EXPORTING
*            i_default_data = wa_default_data
*            i_batch        = sy-batch
*       IMPORTING
*            o_user_data    = wa_user_data.
*
*
** Füllen weiterer Felder notwendig
** Einkaufsbelegnummer etc.
** Adressen
*
*  wa_item-ebeln = l_nast-objky.
*  wa_item-lifnr = l_nast-parnr.
*
*  DATA: wa_po_header TYPE bapiekkol.
*  DATA: po_number TYPE bapiekko-po_number.
*
*  CLEAR po_number.
*  CLEAR wa_po_header.
*
*  po_number = wa_item-ebeln.
*
*  CALL FUNCTION 'BAPI_PO_GETDETAIL'
*    EXPORTING
*     purchaseorder                    = po_number
*      items                            = ''
**     ACCOUNT_ASSIGNMENT               = ' '
**     SCHEDULES                        = ' '
**     HISTORY                          = ' '
**     ITEM_TEXTS                       = ' '
**     HEADER_TEXTS                     = ' '
**     SERVICES                         = ' '
**     CONFIRMATIONS                    = ' '
**     SERVICE_TEXTS                    = ' '
**     EXTENSIONS                       = ' '
*    IMPORTING
*      po_header                        = wa_po_header
**     PO_ADDRESS                       =
**   TABLES
**     PO_HEADER_TEXTS                  =
**     PO_ITEMS                         =
**     PO_ITEM_ACCOUNT_ASSIGNMENT       =
**     PO_ITEM_SCHEDULES                =
**     PO_ITEM_CONFIRMATIONS            =
**     PO_ITEM_TEXTS                    =
**     PO_ITEM_HISTORY                  =
**     PO_ITEM_HISTORY_TOTALS           =
**     PO_ITEM_LIMITS                   =
**     PO_ITEM_CONTRACT_LIMITS          =
**     PO_ITEM_SERVICES                 =
**     PO_ITEM_SRV_ACCASS_VALUES        =
**     RETURN                           =
**     PO_SERVICES_TEXTS                =
**     EXTENSIONOUT                     =
*            .
*
*  wa_item-name1_lifnr = wa_po_header-vend_name.
*
*
*  wa_item-tcode = '/CIDEON/FM06PE02'.
*
*
*  wa_item-verteiler = wa_user_data-default_verteiler_fauf.
*
*
*  wa_item-knz_marked_ebeln = 'X'.
*
*  APPEND wa_item TO itab_item.
*
*
*  CALL FUNCTION 'Z_CL_INT_WRITE_PLOT_PSB_SPOOL'
** EXPORTING
**   F_AUT_PROCESS       = 'X'
*    TABLES
*      i_itab_items        = itab_item
*    EXCEPTIONS
*      error               = 1
*      OTHERS              = 2
*            .
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*
*  CLEAR itab_item.
*
*
*  DATA it_xekpo LIKE l_doc-xekpo.
*  DATA: it_drad TYPE TABLE OF drad.
*
*  DATA: wa_ekpo TYPE ekpo.
*  DATA: wa_drad TYPE drad.
*
*  DATA: drad_objky TYPE drad-objky.
*
*  CLEAR it_xekpo.
*  it_xekpo[] = l_doc-xekpo[].
*
*  LOOP AT it_xekpo INTO wa_ekpo.
**   weitere Dokumente berücksichtigen
**   Dokumente zur Bestellung
*    IF wa_user_data-knz_ebeln_pos = 'X'.
**     Lesen der Dokumentverknüpfungen
*      CLEAR it_drad.
*      CLEAR drad_objky.
*
*      CONCATENATE wa_ekpo-ebeln wa_ekpo-ebelp
*        INTO drad_objky.
*
*      SELECT * FROM drad INTO TABLE it_drad
*        WHERE dokob = 'EKPO'
*        AND objky = drad_objky
*        .
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
*
*      LOOP AT it_drad INTO wa_drad.
*        CLEAR wa_item.
*        wa_item-ebeln = l_nast-objky.
*        wa_item-lifnr = l_nast-parnr.
*        wa_item-tcode = '/CIDEON/FM06PE02'.
*
*        wa_item-verteiler = wa_user_data-default_verteiler_fauf.
*
*        wa_item-dokar = wa_drad-dokar.
*        wa_item-doknr = wa_drad-doknr.
*        wa_item-doktl = wa_drad-doktl.
*        wa_item-dokvr = wa_drad-dokvr.
*
**       Nummer der Einkaufsbelegposition
*        wa_item-ebelp = wa_ekpo-ebelp.
*
*        wa_item-name1_lifnr = wa_po_header-vend_name.
*
**       Materialnummer übergeben
*        wa_item-matnr = wa_ekpo-matnr.
*
*        IF exit_pre IS INITIAL.
*        ELSE.
*          CALL METHOD exit_pre->chg_me_doc_ebelnp
*            CHANGING
*              wa_item = wa_item
*              .
*        ENDIF.
*
*        APPEND wa_item TO itab_item.
*      ENDLOOP.
*
*    ELSE.
*    ENDIF.
*
**   Dokumente zum Material
*    IF wa_user_data-knz_ebeln_mat = 'X'.
*      CLEAR it_drad.
*      CLEAR drad_objky.
*
**      CONCATENATE wa_ekpo-ebeln wa_ekpo-ebelp
**        INTO drad_objky.
*
*      drad_objky = wa_ekpo-matnr.
*
*      SELECT * FROM drad INTO TABLE it_drad
*        WHERE dokob = 'MARA'
*        AND objky = drad_objky
*        .
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
*
*      LOOP AT it_drad INTO wa_drad.
*        CLEAR wa_item.
*        wa_item-ebeln = l_nast-objky.
*        wa_item-lifnr = l_nast-parnr.
*        wa_item-tcode = '/CIDEON/FM06PE02'.
*
*        wa_item-verteiler = wa_user_data-default_verteiler_fauf.
*
*        wa_item-dokar = wa_drad-dokar.
*        wa_item-doknr = wa_drad-doknr.
*        wa_item-doktl = wa_drad-doktl.
*        wa_item-dokvr = wa_drad-dokvr.
*
**       Nummer der Einkaufsbelegposition
*        wa_item-ebelp = wa_ekpo-ebelp.
*
*        wa_item-name1_lifnr = wa_po_header-vend_name.
*
**       Materialnummer übergeben
*        wa_item-matnr = wa_ekpo-matnr.
*
*        IF exit_pre IS INITIAL.
*        ELSE.
*          CALL METHOD exit_pre->chg_me_doc_mat_ebelnp
*            CHANGING
*              wa_item = wa_item
*              .
*        ENDIF.
*
*        APPEND wa_item TO itab_item.
*      ENDLOOP.
*
*
*    ELSE.
*    ENDIF.
*
**   Dokumente zu den Materialpositionen
**   Auflösen der Stückliste
*    IF wa_user_data-knz_ebeln_bom = 'X'.
*      IF exit_pre IS INITIAL.
*      ELSE.
*        CALL METHOD exit_pre->chg_me_doc_matpos_ebelnp
*        CHANGING
*          wa_item = wa_item
*          .
*      ENDIF.
*    ELSE.
*    ENDIF.
*
**   spezielles Dokument für Aufruf des Dialoges
**   zur Auswahl der zu druckenden Dokumente
**   siehe Plotservices
*    IF wa_user_data-knz_ebeln_dialog = 'X'.
*      IF exit_pre IS INITIAL.
*      ELSE.
*        CALL METHOD exit_pre->chg_me_doc_dialog_ebelnp
*          CHANGING
*            wa_item = wa_item
*            .
*      ENDIF.
*    ELSE.
*    ENDIF.
*
*  ENDLOOP.
*
*
** Schreiben der Einträge in Übergabetabelle
*  CALL FUNCTION 'Z_CL_INT_WRITE_PLOT_PSB_NO_STR'
*       EXPORTING
*            f_aut_process = ''
*       TABLES
*            i_itab_items  = itab_item
*       EXCEPTIONS
*            error         = 1
*            OTHERS        = 2.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*
*
*  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
*
** Rückmeldung per Expressmail
*  IF wa_user_data-knz_ebeln_expressmail = 'X'.
*    CALL FUNCTION '/CIDEON/SEND_MAIL_EBELN_PLOT'
*         EXPORTING
*              i_user = sy-uname
*         EXCEPTIONS
*              error  = 1
*              OTHERS = 2.
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*
*  ELSE.
*  ENDIF.
*
*
**&---------------------------------------------------------------------
**
** CIDEON SAP Plotting Interface Ende
**
**----------------------------------------------------------------------
*-
*


ENDFORM.

*eject
*----------------------------------------------------------------------*
* Umlagerungsbestellung,  Hinweis 670912                               *
*----------------------------------------------------------------------*
FORM entry_neu_sto USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print,
        f_sto.                                              "670912


  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

  f_sto = 'X'.                                              "670912

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
            ix_sto         = f_sto                          "670912
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.


*eject
*----------------------------------------------------------------------*
* Mahnung
*----------------------------------------------------------------------*
FORM entry_mahn USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '3'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.

*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*   Integration
**************
* 28.02.2007 - Übergabe von Lieferantendaten
* 20.03.2007 - BADI und Markierungen
*-----------------------------------------------------------------------
* keine Mitagbe von Dokumenten beu Mahnungen
* -> Kundenwunsch
*-----------------------------------------------------------------------


  CALL FUNCTION '/CIDEON/PLOT_ME_FM06PE02'
       EXPORTING
            ent_retco = ent_retco
            l_nast    = l_nast
            l_doc     = l_doc
       EXCEPTIONS
            error     = 1
            OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface Ende
*
*-----------------------------------------------------------------------




ENDFORM.

*eject
*----------------------------------------------------------------------*
* Auftragsbestätigungsmahnung
*----------------------------------------------------------------------*
FORM entry_aufb USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '7'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.

*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*   Integration
**************
* 28.02.2007 - Übergabe von Lieferantendaten
*-----------------------------------------------------------------------
* keine Mitagbe von Dokumenten bei Mahnungen
* -> Kundenwunsch
*-----------------------------------------------------------------------

  CALL FUNCTION '/CIDEON/PLOT_ME_FM06PE02'
       EXPORTING
            ent_retco = ent_retco
            l_nast    = l_nast
            l_doc     = l_doc
       EXCEPTIONS
            error     = 1
            OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface Ende
*
*-----------------------------------------------------------------------




ENDFORM.
*eject
*----------------------------------------------------------------------*
* Lieferabrufdruck für Formular MEDRUCK mit Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lphe USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '9'.
  l_xfz = 'X'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_xfz         = l_xfz
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
* Lieferabrufdruck für Formular MEDRUCK ohne Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lphe_cd USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '9'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
* Feinabrufdruck für Formular MEDRUCK mit Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lpje USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = 'A'.
  l_xfz = 'X'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_xfz         = l_xfz
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
* Feinabrufdruck für Formular MEDRUCK ohne Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lpje_cd USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = 'A'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
*   INCLUDE FM06PE02                                                   *
*----------------------------------------------------------------------*
FORM entry_neu_matrix USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_mflag       = 'X'
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
* Angebotsabsage
*----------------------------------------------------------------------*
FORM entry_absa USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  l_druvo = '4'.
  CLEAR ent_retco.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
* Lieferplaneinteilung
*----------------------------------------------------------------------*
FORM entry_lpet USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '5'.
  ELSE.
    l_druvo = '8'.
  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
* Lieferplaneinteilung
*----------------------------------------------------------------------*
FORM entry_lpfz USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '5'.
  ELSE.
    l_druvo = '8'.
  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_xfz         = 'X'
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
*eject
*----------------------------------------------------------------------*
* Mahnung
*----------------------------------------------------------------------*
FORM entry_lpma USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '6'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
       EXPORTING
            ix_nast        = nast
            ix_screen      = ent_screen
       IMPORTING
            ex_retco       = ent_retco
            ex_nast        = l_nast
            doc            = l_doc
       CHANGING
            cx_druvo       = l_druvo
            cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
       EXPORTING
            ix_nast        = l_nast
            ix_druvo       = l_druvo
            doc            = l_doc
            ix_screen      = ent_screen
            ix_from_memory = l_from_memory
            ix_toa_dara    = toa_dara
            ix_arc_params  = arc_params
            ix_fonam       = tnapr-fonam                    "HW 214570
       IMPORTING
            ex_retco       = ent_retco.
ENDFORM.
