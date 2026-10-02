FUNCTION /cideon/druck_ansteuerung.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PS_DRAW) TYPE  DRAW
*"     VALUE(PF_APPNR) TYPE  C
*"     VALUE(PF_DAPPL) TYPE  DRAW-DAPPL
*"     VALUE(PF_APPTP) TYPE  TDWX-APPTP
*"     VALUE(PF_FILE) TYPE  C
*"     VALUE(PF_URL) TYPE  MCDOK-URL
*"  TABLES
*"      PT_COMPONENT TYPE  DMS_TBL_COMP
*"      PT_DRAZ STRUCTURE  DRAZ
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*
*
* Kontakt über:   https://service.cideon.com
*                 HELPDESK@CIDEON-SOFTWARE.DE
*-----------------------------------------------------------------------
* Hinweise:
*   - benutzt zur Zeit nur die CLF Integration
*
*-----------------------------------------------------------------------
* Journal
* 17.03.2003 Erstellung
* 10.06.2003 Anpassungen
* 18.06.2003 Multipage
* 19.06.2003 Multipage
* 23.06.2003
* 24.07.2003 Erweiterung Willy Vogel
*            - Anmeldung an einem SMB Share
* 06.08.2003 - resultierende Stempel eingebaut
* 08.09.2003 - neue und alte CLFs werden jetzt unterstützt
* 26.09.2003 - FB für Defaultwerte einlesen
* 29.09.2003 - FB für Nutzerwerte einlesen
* 30.10.2003 - keine DIS mit bestimmten Merkmalen Plotten
* 05.11.2003 - keine DIS plotten, falls nicht in bestimmter Nutzergruppe
*            - siehe PlotInterface (Willy Vogel)
* 07.11.2003 - Formatfeld auslesen
* 13.01.2004 - Erweiterung um verschiedene Felder
* 19.01.2004 - Problem, da bei RFC/FTP Checkout die Datei nicht gefunden
*              wird
* 26.01.2005 - Benutzung von '/CIDEON/CLEAN_UP_DOCUMENTS_2' für alle
*              Tests auf nicht zu plottende Dokumente
* 29.01.2005 - Audit Trail / Bestätigung
* 09.02.2005 - Stempel : Statustext
* 14.06.2005 - Übergabe der ID der Plotjobs
* 10.04.2007 - SP 34
*            - Übergabe der ID der Plotjobs
*              KNZ_CREATE_TOC
*              KNZ_SEND_TOC
*              EMAIL_TOC
* 23.04.2008 - SP 073
*              BADI Integration - Vor Senden
* 06.05.2008 - SP 074
*              Refreshproblem itab_tmp_plotjobs
* 29.09.2008 - SP 78
*              kontrollierter Druck / kontrollierter Nachdruck
* 30.09.2008
* 04.10.2008 - Kopienanzahl bein kontrollierten Druck
* 07.10.2008 - SP 81
*              falls kontrollierter Druck, dann nur eine Kopie zulassen
*              wahrscheinlich das gleiche beim Nachdruck
* SP 100
* 03.08.2009 - Geburtstag T.R.
*              Seitenausdruck
* 04.08.2009 - Übergabe f_dyn_toc etc.
* SP 101
* 05.08.2009 - Übersetzungen
*              AutoORG Löschung im Titel
* SP 103
* 02.09.2009 -
*
* SP 115
* 12.01.2010 - Multipage
*              - für einzelne Intervalle
*              - Nutzerdefaults
*              - Tabelle mit Verteilern
*
* SP 147
* 25.02.2011 - CKR
* 7.0.147.1   /CIDEON/DRUCK_ANSTEUERUNG
*             Übergabe der Materialnummer im kleinen Druckdialog
*             SR 11211 Beim kleinen Druckdialog wird keine verknüpfte
*             Materialnummber übergeben
*
* 7.0.147.5   - CKR
* 12.04.2011 Satzanzahl
*            Kopienanzahl
*
* 7.0.153.2
* 24.06.2011 - CKR
*              Dokumentenstatus und Beschreibung auch in kleinem
*              Druckdialog
*
* 7.0.155.1
* 28.06.2011 - CKR
*              Integration in Kleinen Druckdialog
*              FB /CIDEON/DRUCK_ANSTEUERUNG
*              Einbau des Sendens der CLF über einen BADI parallel zu
*              dem Senden zum Plot Operator
*              Möglichkeit der Anbindung an OM 7.5 / 8.0
*              BADI /CIDEON/PRE_MAIN_001
*              Methode SEND_TO_BADI
*
* 7.0.170.1
* 2014/10/02 - APEX
* Anpassung der Sourcen auf Ersetzung von FB GUID_CREATE

*-----------------------------------------------------------------------
* to do
*            - Anpassung auf Parameter %NO-CHECKOUT%
*              beachten, daß die Funktionalität auch aus
*              CV04N und CC04 etc, aufgerufen werden kann
*              -> Auswirkungen auf dynamische Zuweiseung
*-----------------------------------------------------------------------

* ITAB
  DATA: itab_class_data_no_use TYPE TABLE OF zcl_v_ug_cl_n_u.

  DATA: lt_plotjobs_pages LIKE itab_tmp_plotjobs_2.
  DATA: ls_plotjobs_pages LIKE wa_plotjobs.

* WA
  DATA: wa_draw_check TYPE draw.
* NORMAL
  DATA: g_seite_von LIKE wa_plotjobs-seite_von.
  DATA: g_seite_bis LIKE wa_plotjobs-seite_bis.
  DATA: f_found(1).

  DATA: index TYPE i.

* Initialisieren
  REFRESH itab_tmp_plotjobs.
  REFRESH itab_tmp_plotjobs_2.

* Kontrollierter Druck
  CLEAR rb_k_d.
  CLEAR rb_n_d.
  CLEAR rb_charge.
  CLEAR rb_u_d.

  rb_u_d = 'X'.


* Test für dynamisches Assign, falls durch den Parameter %NO-CHECKOUT%
* keine Information über das Original (außer WSAPPL) übergeben wurde
*
  IF pf_file IS INITIAL.
*    DATA: ls_doc_file TYPE dms_doc_file.
*    FIELD-SYMBOLS: <fs_doc_file> TYPE ANY.
*    CLEAR ls_doc_file.
** LCV110F32
*    ASSIGN ('(SAPLCV110)ls_doc_file')
*      TO <fs_doc_file>.
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.
**    assign

**   Screen holen
*    FIELD-SYMBOLS: <gf_dynp> TYPE ANY.
*    ASSIGN ('(SAPLCV110)gf_dynp')
*      TO <gf_dynp>.
*    IF sy-subrc NE 0.
*    ELSE.
**     Tree holen
*      FIELD-SYMBOLS: <gf_dynp> TYPE ANY.
*        gf_doc_tree1
*  gf_doc_tree2
*  gf_splitter1
*
*    ENDIF.
*
  ELSE.
  ENDIF.

* get INI Values for USer
  IF init <> 'X'.

*  Zur Zeit nicht notwendig, da für den Ausdruck das Recht des Ansehens
*  in der CV03N vorhanden sein muß .... also eine Rechteprüfung schon
*  durch SAP erfolgt ..

** Berechtigungscheck
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '16'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc > 0.
*      MESSAGE s099(zcl_plint_tools)
*        WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
*      LEAVE PROGRAM.
*    ELSE.
*    ENDIF.
  ENDIF.


* BADI
* /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.



* break kuechler.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = '15'  " Balkenanzeige
            text       = text-011.


* analog zum PlotInterface werden die Einstellungsdaten aus dem
* PlotInterface ausgelesen

  PERFORM get_default_values.
  PERFORM get_user_values.
  PERFORM get_default_verteiler.

* Audit Trail
  IF user_data-knz_audit_trail = 'X'
    AND NOT f_audit_trail_confirm_no = 'X' .
*     Daten recherchieren für Nutzer
    CALL FUNCTION '/CIDEON/CHECK_ITEM_TO_CONFIRM'
         EXPORTING
              i_uname = sy-uname
         EXCEPTIONS
              error   = 1
              exit    = 2
              OTHERS  = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      CASE sy-subrc.
        WHEN '2'.
          f_audit_trail_confirm_no = 'X'.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
  ELSE.
  ENDIF.



* Berechtigungscheck, für Plotten entsprechender
* Workstationapplikationen
  IF user_data-use_filter = 'X'.
    PERFORM get_file_types.

*   testen, ob erlaubt
    CLEAR f_found.
    LOOP AT itab_plint_usr_tdwp INTO wa_plint_usr_tdwp.
      IF wa_plint_usr_tdwp-dappl = pf_dappl.
        f_found = 'X'.
      ELSE.
      ENDIF.
    ENDLOOP.

    IF f_found = 'X'.
    ELSE.
      MESSAGE e002(/cideon/druck_basis) WITH '' '' '' ''.
    ENDIF.
  ELSE.
  ENDIF.

* Testen, ob der DIS geplottet werden darf
*  IF user_data-knz_check_dis = 'X'.
*    IF user_data-knz_check_dis_class = 'X'.
*      CLEAR itab_class_data_no_use.
*      CALL FUNCTION '/CIDEON/GET_CLASS_NO_USE'
*           EXPORTING
*                i_nutzer                 = sy-uname
*                i_default_nutzer         = default_data-default_nutzer
*           TABLES
*                o_itab_class_data_no_use = itab_class_data_no_use
*           EXCEPTIONS
*                error                    = 1
*                OTHERS                   = 2.
*      IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*
*      IF itab_class_data_no_use IS INITIAL.
*      ELSE.
*        CLEAR wa_draw_check.
*        wa_draw_check = ps_draw.
*        CALL FUNCTION '/CIDEON/CHECK_DIS_FOR_CLASS'
*             EXPORTING
*                  i_wa_draw                = wa_draw_check
*             TABLES
*                  i_itab_class_data_no_use = itab_class_data_no_use
*             EXCEPTIONS
*                  error                    = 1
*                  do_not_use_dis           = 2
*                  OTHERS                   = 3.
*        IF sy-subrc <> 0.
*          IF sy-subrc = 2.
*            MESSAGE e002(/cideon/druck_basis) WITH '' '' '' ''.
**           DIS ist nicht zum Plotten vorgesehen! & & & &
*          ELSE.
*          ENDIF.
*        ENDIF.
*
*      ENDIF.
*
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

* Testen, ob der DIS geplottet werden darf
  CLEAR wa_search_tmp.
  MOVE-CORRESPONDING ps_draw TO wa_search_tmp.
  CLEAR itab_search_tmp.
  APPEND wa_search_tmp TO itab_search_tmp.

  CALL FUNCTION '/CIDEON/CLEAN_UP_DOCUMENTS_2'
       EXPORTING
            i_wa_default_data = default_data
            i_wa_user_data    = user_data
            i_batch           = ''
       TABLES
            itab_search_tmp   = itab_search_tmp
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION '/CIDEON/GET_MATNR'
       EXPORTING
            i_wa_user_data = user_data
       TABLES
            itab_search    = itab_search_tmp
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION '/CIDEON/GET_DOK_TEXT'
       TABLES
            itab_search = itab_search_tmp
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION '/CIDEON/GET_DOK_TEXT'
       TABLES
            itab_search = itab_search_tmp
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  IF itab_search_tmp[] IS INITIAL.
*   Lokale Datei löschen ?
*    DATA: tmp_file TYPE rlgrap-filename.
*    tmp_file = pf_file.
*    CALL FUNCTION 'GUI_DELETE_FILE'
*         EXPORTING
*              file_name = tmp_file
*         EXCEPTIONS
*              failed    = 1
*              OTHERS    = 2.
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

    EXIT.
  ELSE.
  ENDIF.


  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = '30'  " Balkenanzeige
            text       = text-011.


  CLEAR wa_plotjobs.
  CLEAR wa_search_tmp.
  READ TABLE itab_search_tmp INTO wa_search_tmp INDEX 1.
  MOVE-CORRESPONDING wa_search_tmp TO wa_plotjobs.

  MOVE-CORRESPONDING ps_draw TO wa_plotjobs.
  wa_plotjobs-filep = pf_file.

  wa_plotjobs-kopien = default_data-default_kopien.
  wa_plotjobs-verteiler = user_data-verteiler.
  wa_plotjobs-prio = default_data-default_prio.
  wa_plotjobs-uname = sy-uname.

* TOC
  wa_plotjobs-knz_create_toc = user_data-knz_create_toc.
  wa_plotjobs-knz_send_toc = user_data-knz_send_toc.


  PERFORM add_object_key.
  PERFORM add_compression_field.
  PERFORM check_prio.

*  PERFORM get_dokst.
  PERFORM get_dok_text.


* Formatkennzeichen lesen
  IF user_data-knz_use_merkmal_format = 'X'.
    PERFORM add_format_field.
  ELSE.
  ENDIF.

  wa_plotjobs-cont = 1.
  wa_plotjobs-checked = ''.

  wa_plotjobs-wsapplication = pf_dappl.

  wa_plotjobs-satzanzahl = user_data-default_satzanzahl.
  wa_plotjobs-kopien = user_data-default_kopien.

* Wegen Checkout per RFC testen, andere Implementation erstellen
* kann lokale Dateien nicht per RFC übergeben
  wa_plotjobs-knz_use_checked_in = ''.
*  wa_plotjobs-knz_use_checked_in = user_data-knz_use_checked_in.

  DATA: lt_recipient TYPE TABLE OF /cideon/s_recipient.
  DATA: ls_recipient TYPE /cideon/s_recipient.

  CLEAR lt_recipient.

* Aufruf des Druckdialoges
  CALL FUNCTION '/CIDEON/CALL_DRUCK_DIALOG_1'
       EXPORTING
            i_wa_plotjobs  = wa_plotjobs
       IMPORTING
            o_wa_plotjobs  = wa_plotjobs
       TABLES
            o_lt_recipient = lt_recipient
       EXCEPTIONS
            error          = 1
            abort          = 2
            OTHERS         = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.


* Mappen der Informationen

* Aufruf der CLF Funktionalität von Sri
* PERFORM get_latest_path_entries.
* nicht unbedingt notwendig, da Druck sehr zeitnah erfolgt ..

  str_down_path = user_data-down_path.
  str_ppl_down_path = user_data-clf_down_path.

  CLEAR wa_tmp_plotjobs.
  REFRESH itab_tmp_plotjobs_2.



  MOVE-CORRESPONDING wa_plotjobs TO wa_tmp_plotjobs.

  CLEAR g_seite_von.
  CLEAR g_seite_bis.
  g_seite_von = wa_tmp_plotjobs-seite_von.
  g_seite_bis = wa_tmp_plotjobs-seite_bis.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = g_seite_von
       IMPORTING
            output = g_seite_von.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = g_seite_bis
       IMPORTING
            output = g_seite_bis.

  wa_tmp_plotjobs-seite_von = g_seite_von.
  wa_tmp_plotjobs-seite_bis = g_seite_bis.

* "Berücksichtigung des kontrollierten Druckes
  "Rezipienten
  "Gesamtzahl der Kopien
  "

  IF lt_recipient[] IS INITIAL.
    APPEND wa_tmp_plotjobs TO itab_tmp_plotjobs.
  ELSE.
    LOOP AT lt_recipient INTO ls_recipient.
      wa_tmp_plotjobs-recipient = ls_recipient-recipient.
      APPEND wa_tmp_plotjobs TO itab_tmp_plotjobs.
    ENDLOOP.
  ENDIF.


  "Seitenintervalle aufschlüsseln
*  clear itab_tmp_plotjobs_2.
*  LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs.
*    if wa_tmp_plotjobs-seite_von
*  ENDLOOP.




  "Test, ob Dokument schon für diesen Empfänger kontrolliert
  "gedruckt wurde
  DATA: ls_pl_log TYPE /cideon/pl_log.


  CLEAR index.
  LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs.
    "
    index = sy-tabix.

    "nur für kontrolierten Druck
    IF wa_tmp_plotjobs-print_type = 'K'.
    ELSE.
      CONTINUE.
    ENDIF.

    CLEAR ls_pl_log.
    SELECT SINGLE * FROM /cideon/pl_log
      INTO ls_pl_log
      WHERE
      dokar = wa_tmp_plotjobs-dokar
      AND doknr = wa_tmp_plotjobs-doknr
      AND doktl = wa_tmp_plotjobs-doktl
      AND dokvr = wa_tmp_plotjobs-dokvr
      AND filep = wa_tmp_plotjobs-filep
      AND wsapplication = wa_tmp_plotjobs-wsapplication
      AND recipient = wa_tmp_plotjobs-recipient
      AND print_type = 'K'
      .
    IF sy-subrc NE 0.
    ELSE.
      "Meldung, daß nur noch ein unkontrolierter Druck möglich ist
      CLEAR answer.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar                    = 'Kontrollierter Druck'(001)
*         DIAGNOSE_OBJECT             = ' '
          text_question               = text-002
*          TEXT_BUTTON_1               = 'Ja'(001)
          icon_button_1               = 'ICON_OKAY'
*          TEXT_BUTTON_2               = 'Nein'(002)
          icon_button_2               = 'ICON_CANCEL'
*         DEFAULT_BUTTON              = '1'
          display_cancel_button       = ''
*         USERDEFINED_F1_HELP         = ' '
*         START_COLUMN                = 25
*         START_ROW                   = 6
*         POPUP_TYPE                  =
        IMPORTING
          answer                      = answer
*       TABLES
*         PARAMETER                   =
        EXCEPTIONS
          text_not_found              = 1
          OTHERS                      = 2
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF answer = '2'.
        "Löschen, des Eintrages
        DELETE itab_tmp_plotjobs INDEX index.
      ELSE.
        "Eingabefeld für Grund
        DATA: returncode.
        DATA: lt_fields TYPE TABLE OF sval.
        DATA: ls_fields TYPE sval.

        CLEAR lt_fields.
        CLEAR ls_fields.

        ls_fields-tabname = '/CIDEON/PL_LOG'.
        ls_fields-fieldname = 'PRINT_CAUSE'.
        ls_fields-value = 'Bitte Grund eingeben!'(004).
        APPEND ls_fields TO lt_fields.

        CLEAR returncode.

        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
*           NO_VALUE_CHECK        = ' '
            popup_title           = text-003
*           START_COLUMN          = '5'
*           START_ROW             = '5'
          IMPORTING
            returncode            = returncode
          TABLES
            fields                = lt_fields
          EXCEPTIONS
            error_in_fields       = 1
            OTHERS                = 2
                  .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        IF returncode = 'A'.
          "Löschen, des Eintrages
          DELETE itab_tmp_plotjobs INDEX index.
        ELSE.
          CLEAR ls_fields.
          READ TABLE lt_fields INTO ls_fields INDEX 1.
          IF ls_fields-value IS INITIAL.
            "Löschen, des Eintrages
            DELETE itab_tmp_plotjobs INDEX index.
          ELSE.
            wa_tmp_plotjobs-print_cause = ls_fields-value.
          ENDIF.

        ENDIF.

        "Ausgabetyp ändern
        wa_tmp_plotjobs-print_type = 'N'.
        MODIFY itab_tmp_plotjobs FROM wa_tmp_plotjobs INDEX index.

      ENDIF.
    ENDIF.

  ENDLOOP.

* Kopienanzahl beim kontrollierten Druck
  "Kopienanzahl wird nur beim kontrollierten Druck gesetzt
  "Aussage betrifft immer Nummer des ersten kontrollierten Druckes
  "Empfänger behält auch beim Nachruck die Kopienzahl
  "
  "falls kontrolliert, dann immer der erste Druck

  DATA: nr_kopie TYPE i.
  CLEAR nr_kopie.

  CLEAR ls_pl_log.
  SELECT MAX( nr_copies ) FROM /cideon/pl_log
    INTO nr_kopie
    WHERE
    dokar = wa_tmp_plotjobs-dokar
    AND doknr = wa_tmp_plotjobs-doknr
    AND doktl = wa_tmp_plotjobs-doktl
    AND dokvr = wa_tmp_plotjobs-dokvr
    AND filep = wa_tmp_plotjobs-filep
    AND wsapplication = wa_tmp_plotjobs-wsapplication
    "AND recipient = wa_tmp_plotjobs-recipient
    AND print_type = 'K'
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CLEAR index.
  LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs
    WHERE print_type = 'K'.
    index = sy-tabix.
    nr_kopie = nr_kopie + 1.

    wa_tmp_plotjobs-nr_copies = nr_kopie.
    MODIFY itab_tmp_plotjobs FROM wa_tmp_plotjobs INDEX index.

  ENDLOOP.

  "Kopien / Referenz auf Originaldruck
  CLEAR index.
  LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs
    WHERE print_type = 'N'.
    index = sy-tabix.

    CLEAR nr_kopie.
    SELECT SINGLE nr_copies FROM /cideon/pl_log
      INTO nr_kopie
      WHERE
      dokar = wa_tmp_plotjobs-dokar
      AND doknr = wa_tmp_plotjobs-doknr
      AND doktl = wa_tmp_plotjobs-doktl
      AND dokvr = wa_tmp_plotjobs-dokvr
      AND filep = wa_tmp_plotjobs-filep
      AND wsapplication = wa_tmp_plotjobs-wsapplication
      AND recipient = wa_tmp_plotjobs-recipient
      AND print_type = 'K'
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    wa_tmp_plotjobs-nr_copies = nr_kopie.
    MODIFY itab_tmp_plotjobs FROM wa_tmp_plotjobs INDEX index.
  ENDLOOP.


  "Kopien bei kontrolierten Druck und Nachdruck auf eine Kopie
  "beschränken

  CLEAR index.
  LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs
    WHERE print_type = 'K'
      OR print_type = 'N'.
    index = sy-tabix.

    wa_tmp_plotjobs-kopien = '1'.
    MODIFY itab_tmp_plotjobs FROM wa_tmp_plotjobs INDEX index.
  ENDLOOP.


  IF itab_tmp_plotjobs[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.







* nach Multipage checken
* falls notwendig dann mehrere Einträge vornehmen
  IF user_data-knz_use_multipage = 'X'.
    PERFORM check_for_multipage.
  ELSE.
  ENDIF.

* falls Multipage, dann Seiten Intervalle anpassen
*

* SP 115
  " freie Intervalle
  DATA: lt_seiten TYPE TABLE OF zcl_seite_von.
  DATA: lt_seiten_all TYPE TABLE OF zcl_seite_von.
  DATA: lt_seiten_tmp TYPE TABLE OF zcl_seite_von.

  DATA: ls_seiten TYPE zcl_seite_von.

  CLEAR lt_seiten.
  CLEAR lt_seiten_all.
  CLEAR lt_seiten_tmp.

  IF g_seite_von CA ';,'.
    " beachten, daß mehrere Recipienten vorhanden sein können
    CLEAR lt_plotjobs_pages.
    CLEAR ls_plotjobs_pages.

    SPLIT g_seite_von AT ';' INTO TABLE lt_seiten.
    LOOP AT lt_seiten INTO ls_seiten.
      IF ls_seiten CS ','.
        CLEAR lt_seiten_tmp.
        SPLIT ls_seiten AT ',' INTO TABLE lt_seiten_tmp.
        LOOP AT lt_seiten_tmp INTO ls_seiten.
          APPEND ls_seiten TO lt_seiten_all.
        ENDLOOP.
      ELSE.
        " schon alles OK
        APPEND ls_seiten TO lt_seiten_all.
      ENDIF.
    ENDLOOP.

    LOOP AT itab_tmp_plotjobs[] INTO ls_plotjobs_pages.
      LOOP AT lt_seiten_all INTO ls_seiten.
        ls_plotjobs_pages-seite_von = ls_seiten.
        ls_plotjobs_pages-seite_bis = ls_seiten.
        APPEND ls_plotjobs_pages TO lt_plotjobs_pages.
      ENDLOOP.
    ENDLOOP.

    CLEAR g_seite_von.
    CLEAR g_seite_bis.

    itab_tmp_plotjobs[] = lt_plotjobs_pages[].




  ELSE.
  ENDIF.



  " andere Zeichen noch beachten
  " am besten schon vorher rauswerfen


  IF NOT lt_seiten_all[] IS INITIAL.
    "Einträge vorhanden
    "keine Seiten behandlung


  ELSE.

    CALL FUNCTION '/CIDEON/CHG_INTERVAL_MLTPAGE'
         EXPORTING
              i_wa_plotjobs    = wa_tmp_plotjobs
              i_seite_von      = g_seite_von
              i_seite_bis      = g_seite_bis
         TABLES
              io_itab_plotjobs = itab_tmp_plotjobs[]
         EXCEPTIONS
              error            = 1
              OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

*  itab_tmp_plotjobs_2[] = itab_tmp_plotjobs[].
*
*  PERFORM reindex_table_2.



* Kostenstelle einfügen
*  PERFORM add_cost_center.
* Prioritäten checken
*  PERFORM check_priorities.

  PERFORM add_client_data_2.


  itab_tmp_plotjobs_2[] = itab_tmp_plotjobs[].

  PERFORM reindex_table_2.
  PERFORM get_stamp_values.
  PERFORM get_class_data.
  PERFORM get_result_stamp_values.

* Anmeldung an einem SMB Share
  IF user_data-knz_anmeldung_am_server = 'X'.
    CALL FUNCTION '/CIDEON/ANMELDUNG_AN_SERVER'
         EXPORTING
              i_anmeldestring_server = user_data-anmeldestring_server
              i_anmeldestring_server_voher
                = user_data-anmeldestring_server_vorher
              i_anmeldestring_server_nachher
                = user_data-anmeldestring_server_nachher
         EXCEPTIONS
              error                  = 1
              OTHERS                 = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.

  IF user_data-knz_make_id_plotjob = 'X'.
    CLEAR g_id_plotjob.
    CALL FUNCTION '/CIDEON/ID_PLOTJOB_GET_NEXT'
         EXPORTING
              i_numrange_object   = '/CIDEON/PJ'
              i_numrange_interval = '01'
         IMPORTING
              e_number            = g_id_plotjob.

    LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
      index_itab_tmp_plotjobs_2 = sy-tabix.
      wa_plotjobs-id_plotjob = g_id_plotjob.
      wa_plotjobs-id_plotjob_32 = g_id_plotjob.

      MODIFY itab_tmp_plotjobs_2 FROM wa_plotjobs
        INDEX index_itab_tmp_plotjobs_2.
    ENDLOOP.
  ELSE.
  ENDIF.

  "GUID 32 des Plotjobs erzeugen
  CLEAR g_id_plotjob_32.
  "CALL FUNCTION 'GUID_CREATE'
  CALL FUNCTION '/CIDEON/OM_CLASSIC_GUID_CREATE'
    IMPORTING
*           EV_GUID_16       =
*           EV_GUID_22       =
      ev_guid_32       = g_id_plotjob_32
            .

  LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
    index_itab_tmp_plotjobs_2 = sy-tabix.
    .
    wa_plotjobs-id_plotjob_32 = g_id_plotjob_32.

    MODIFY itab_tmp_plotjobs_2 FROM wa_plotjobs
      INDEX index_itab_tmp_plotjobs_2.
  ENDLOOP.


  PERFORM make_send_log_entries.

  " 2009/07/22
  " BADI für Konfiguration ändern
  " DHE / Medtronic
  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CALL METHOD badi_main_pre_001->chg_conf_before_send
       CHANGING
         f_dyn_toc     = f_dyn_toc
         f_dyn_cov     = f_dyn_cov
         ls_user_data  = user_data
         lt_plotlist   = itab_tmp_plotjobs
        .
  ENDIF.

  " 2009/08/03
  " Seitenzahlen nochmals anpassen
  " Corden Pharma
  "
  " wa_test-seite ist ausschlaggebend



  CLEAR lt_plotjobs_pages.
  CLEAR ls_plotjobs_pages.

  LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
    " Fehlerbehandlung integrieren

    IF wa_plotjobs-seite_von = wa_plotjobs-seite_bis.
      APPEND wa_plotjobs TO lt_plotjobs_pages.
      CONTINUE.
    ELSE.
    ENDIF.

    " Fehler
    " alle ausdrucken
    IF wa_plotjobs-seite_von > wa_plotjobs-seite_bis.
      APPEND wa_plotjobs TO lt_plotjobs_pages.
      CONTINUE.
    ELSE.
    ENDIF.

    " normaler Fall
    DATA: count TYPE i.
    IF wa_plotjobs-seite_von < wa_plotjobs-seite_bis.
      CLEAR count.
      count = wa_plotjobs-seite_bis - wa_plotjobs-seite_von + 1.

      DO count TIMES.
        wa_plotjobs-seite = wa_plotjobs-seite_von - 1 + sy-index
  .
        APPEND wa_plotjobs TO lt_plotjobs_pages.
      ENDDO.
      CONTINUE.
    ELSE.
    ENDIF.

  ENDLOOP.

  itab_tmp_plotjobs_2[] = lt_plotjobs_pages[].


* SP 115
* Multipage
  DATA: ls_plotlist TYPE zcl_s_plotlist.

  " Nutzereinstellungen
  LOOP AT itab_tmp_plotjobs_2 INTO ls_plotlist.
    index = sy-tabix.

    ls_plotlist-knz_multi_page = user_data-knz_use_multipage.
    MODIFY itab_tmp_plotjobs_2 FROM ls_plotlist INDEX index.
  ENDLOOP.


  "Integration der Multipage / Verteilertabelle
  DATA: ls_verteiler_mp TYPE /cideon/vert_mp.


  LOOP AT itab_tmp_plotjobs_2 INTO ls_plotlist.
    index = sy-tabix.

    CLEAR ls_verteiler_mp.
    SELECT SINGLE * FROM /cideon/vert_mp
      INTO ls_verteiler_mp
      WHERE status = '10'
      AND verteiler = ls_plotlist-verteiler
      .
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
      ls_plotlist-knz_multi_page = ls_verteiler_mp-knz_multipage.
    ENDIF.

    MODIFY itab_tmp_plotjobs_2 FROM ls_plotlist INDEX index.
  ENDLOOP.

  "generell setzen, falls Angabe von Intervallen
  LOOP AT itab_tmp_plotjobs_2 INTO ls_plotlist.
    index = sy-tabix.
    IF ls_plotlist-seite_von IS INITIAL.
    ELSE.
      ls_plotlist-knz_multi_page = 'X'.
      MODIFY itab_tmp_plotjobs_2 FROM ls_plotlist INDEX index.
    ENDIF.
  ENDLOOP.

* /SP 115





* BADI
  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    DATA: f_show_message.
    CLEAR f_show_message.

    CALL METHOD badi_main_pre_001->chg_plotlist_before_send
      CHANGING
        itab_plotlist = itab_tmp_plotjobs_2
        return        = return
        show_message  = f_show_message
        .
    IF return-type CA 'EA'.
      IF f_show_message = 'X'.
        MESSAGE ID return-id TYPE return-type
          NUMBER return-number
        WITH return-message_v1 return-message_v2
          return-message_v3 return-message_v4.
      ELSE.
      ENDIF.

      EXIT.
    ELSE.
    ENDIF.
  ENDIF.






  "Integrationsvorbereitung für OM 7.5 - 8.0
  IF user_data-knz_use_admin_module = 'B'.
    IF badi_main_pre_001 IS INITIAL.
    ELSE.
      "Lesen der Informationen über FILE_ID etc.
      "PF_APPNR
      DATA: lt_documentfiles TYPE TABLE OF bapi_doc_files2.
      DATA: ls_documentfiles TYPE bapi_doc_files2.

      LOOP AT itab_tmp_plotjobs_2 INTO ls_plotlist.
        index = sy-tabix.

        CLEAR lt_documentfiles.
        CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
          EXPORTING
            documenttype               = ls_plotlist-dokar
            documentnumber             = ls_plotlist-doknr
            documentpart               = ls_plotlist-doktl
            documentversion            = ls_plotlist-dokvr
*         GETOBJECTLINKS             = ' '
*         GETCOMPONENTS              = ' '
*         GETSTATUSLOG               = ' '
*         GETLONGTEXTS               = ' '
          getactivefiles             = 'X'
          getdocdescriptions         = ''
          getdocfiles                = 'X'
*         GETCLASSIFICATION          = ' '
*         GETSTRUCTURE               = ' '
*         GETWHEREUSED               = ' '
*         HOSTNAME                   = ' '
*       IMPORTING
*         DOCUMENTDATA               =
*         RETURN                     =
        TABLES
*         OBJECTLINKS                =
*         DOCUMENTDESCRIPTIONS       =
*         LONGTEXTS                  =
*         STATUSLOG                  =
          documentfiles              = lt_documentfiles
*         COMPONENTS                 =
*         CHARACTERISTICVALUES       =
*         CLASSALLOCATIONS           =
*         DOCUMENTSTRUCTURE          =
*         WHEREUSEDLIST              =
                  .

        "lesen der Dateien
        READ TABLE lt_documentfiles INTO ls_documentfiles
          WITH KEY originaltype = pf_appnr.
        IF sy-subrc NE 0.
          "nichts gefunden, weil villeicht 4.6c, dann mit Datei lesen

        ELSE.
        ENDIF.


      ENDLOOP.





      DATA: lc_programm TYPE programm.
      lc_programm = '/CIDEON/DRUCK_ANSTEUERUNG'.

      CALL METHOD badi_main_pre_001->send_to_badi
        CHANGING
          is_user_data         = user_data
          is_default_data      = default_data
          ic_program           = lc_programm
          ic_id_plotjob        = g_id_plotjob
          ic_str_down_path     = str_down_path
          ic_str_ppl_down_path = str_ppl_down_path
          it_plotjobs          = itab_tmp_plotjobs_2
          it_stempel_wert      = itab_stempel_wert
          it_notiz             = it_notiz
        EXCEPTIONS
              error               = 1
              OTHERS              = 2.
      .
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDIF.
  ELSE.
    "normale Integration
    IF user_data-knz_use_new_clf_type = 'X'.
      CALL FUNCTION 'ZCL_CLF10_PROCESS_PLOT_LIST'
           EXPORTING
                default_user       = default_data-default_nutzer
                i_down_path        = str_down_path
                i_clf_down_path    = str_ppl_down_path
                filter             = '*.*'
                i_out_proc         = user_data-knz_auto_process
                i_delete_item      = user_data-delete_item
                i_delete_status    = user_data-delete_status
                i_format_checking  = user_data-knz_format_checking
                i_knz_use_converte = user_data-knz_use_converte
                i_converter_name   = user_data-converter_name
                i_converter_number = user_data-converter_number
                i_ftp_destination  = user_data-ftp_destination
                i_ftp_user         = user_data-ftp_user
                i_ftp_passwd       = user_data-ftp_passwd
                i_ftp_down         = user_data-ftp_down
                i_user_data        = user_data
                f_dyn_toc          = f_dyn_toc
                f_dyn_cov          = f_dyn_cov
           TABLES
                itab_test          = itab_tmp_plotjobs_2
                itab_stamps        = itab_stempel_wert
                it_notiz           = it_notiz
           EXCEPTIONS
                error              = 1
                OTHERS             = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.
    ELSE.
      CALL FUNCTION 'Z_CL_NEW_PLOT_LIST_CLF'
           EXPORTING
                default_user       = default_data-default_nutzer
                i_down_path        = str_down_path
                i_clf_down_path    = str_ppl_down_path
                filter             = '*.*'
                i_out_proc         = user_data-knz_auto_process
                i_delete_item      = user_data-delete_item
                i_delete_status    = user_data-delete_status
                i_format_checking  = user_data-knz_format_checking
                i_knz_use_converte = user_data-knz_use_converte
                i_converter_name   = user_data-converter_name
                i_converter_number = user_data-converter_number
                i_ftp_destination  = user_data-ftp_destination
                i_ftp_user         = user_data-ftp_user
                i_ftp_passwd       = user_data-ftp_passwd
                i_ftp_down         = user_data-ftp_down
           TABLES
                itab_test          = itab_tmp_plotjobs_2
                itab_stamps        = itab_stempel_wert
           EXCEPTIONS
                error              = 1
                OTHERS             = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
  ENDIF.






*  break kuechler.

* Audit Trail
  IF user_data-knz_audit_trail = 'X'
    AND NOT f_audit_trail_confirm_no = 'X' .
*     Daten recherchieren für Nutzer
    CALL FUNCTION '/CIDEON/CHECK_ITEM_TO_CONFIRM'
         EXPORTING
              i_uname = sy-uname
         EXCEPTIONS
              error   = 1
              exit    = 2
              OTHERS  = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      CASE sy-subrc.
        WHEN '2'.
          f_audit_trail_confirm_no = 'X'.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
  ELSE.
  ENDIF.


* Tabellen wieder frei machen
  CLEAR itab_plotjobs.
  CLEAR itab_tmp_plotjobs.
  CLEAR itab_tmp_plotjobs_2.
  CLEAR itab_tmp_plotjobs_3.


ENDFUNCTION.
