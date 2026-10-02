FUNCTION z_cvv4_generate_plot.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DDP_ID) LIKE  DRZOC-DDP_ID
*"     VALUE(I_DRZO) LIKE  DRZO STRUCTURE  DRZO
*"     VALUE(I_RECTP) LIKE  DRZOC-RECTP DEFAULT SPACE
*"     VALUE(I_RECID) LIKE  DRZOC-RECID DEFAULT SPACE
*"     VALUE(I_COM_TYPE) LIKE  DRZOC-COM_TYPE DEFAULT SPACE
*"     VALUE(I_DISP_OFF_ID) LIKE  DRZOC-RECID DEFAULT SPACE
*"  EXPORTING
*"     VALUE(MESSAGE_OBJ) LIKE  OBJ_RECORD STRUCTURE  OBJ_RECORD
*"  TABLES
*"      DRZOC_TAB STRUCTURE  DRZOC
*"  EXCEPTIONS
*"      GENERATE_ERROR
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
* Änderer : Dr. Peter Rabe
*-----------------------------------------------------------------------
* Journal
* 26.07.2004 - Erstellung
* 05.08.2004 - Verknüpfung Eingangsparameter CVV4 mit Inhalt
*              entspr. Z_CL_DOC_CHANGE_EVENT_BATCH_02
* 07.12.2004 - Änderungen / Umstellung auf Funktionsbausteine / CKR
* 15.12.2004 - FIXED Übergabe des richtigen Verteilers und Daten des
*              Benutzers
*-----------------------------------------------------------------------

  DATA:  ls_user TYPE soud3,
         lt_user_tab TYPE TABLE OF soud3.
  DATA:  BEGIN OF ls_rec,
         l_rectype(3),
         l_recyear(2),
         l_recnumb(12),
         END OF ls_rec.

* Einstellungen lesen
  CLEAR wa_user_data.
  CLEAR wa_default_data.
  CLEAR:  g_user, g_draw_key,
          wa_draw, wa_item_fauf,
          wa_default_verteiler,
          itab_items_fauf,
          itab_mat_status_exc,
          itab_search.

* Debugging mit
  WAIT UP TO 30 SECONDS.
*  DATA: debugg VALUE 'X'.
*  WAIT UNTIL debug = 'X'.
* dan innerhalb der SM50 / SM51 den Prozeß debuggen


*  Füllen der globalen Daten aus den DRZOC_TAB-Daten
*  1. Objektschlüssel
*  2. Empfänger der geplotteten Pläne
*  3. Anzahl Kopien

  LOOP AT drzoc_tab.
    IF NOT drzoc_tab-objkey IS INITIAL.
      g_draw_key = drzoc_tab-objkey.
      IF NOT drzoc_tab-recid IS INITIAL.
*       Umsetzen der ID in Benutzername
        ls_rec = drzoc_tab-recid.
        ls_user-usrtp = ls_rec-l_rectype.
        ls_user-usryr = ls_rec-l_recyear.
        ls_user-usrno = ls_rec-l_recnumb.

        CALL FUNCTION 'SO_NAMES_GET'
         EXPORTING
*   SAPOFFICE_USER_ONLY               = ' '
*   SINGLE_SELECTION                  = ' '
           user                              = ls_user
*   INTERN_USER                       = 'X'
*   EXTERN_ADDRESS                    = 'X'
*   USE                               = ' '
*   SUPPRESS_DIALOG                   = ' '
* IMPORTING
*   F_CANCELED                        =
          TABLES
            user_tab                          = lt_user_tab
         EXCEPTIONS
           office_name_not_exist             = 1
           parameter_error                   = 2
           sap_name_not_exist                = 3
           user_not_exist                    = 4
           x_error                           = 5
           not_associated_to_sapoffice       = 6
           OTHERS                            = 7
                  .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        IF NOT lt_user_tab IS INITIAL.
          CLEAR ls_user.
          READ TABLE lt_user_tab INTO ls_user INDEX 1.

          g_user = ls_user-usrnam.
        ELSE.
*        kein user gefunden ??
        ENDIF.

*       Füllen der Auftragstab zum Schreiben in temporäre Plotqueue
        PERFORM fill_itab_items_fauf.

*---------------------------------------------------
*  Programmablauf analog
*  ZCL_PLINT_DESIGN_007
*---------------------------------------------------
*  PBO Status 100

*        DATA: dsn(20) VALUE 'verteilung.txt'.
*        OPEN DATASET dsn FOR INPUT.
*        TRANSFER g_user TO dsn.
*        CLOSE DATASET dsn.


        PERFORM read_user_and_default_data.

*  DATA: dsn(20) VALUE 'verteilung3.txt'.
*  OPEN DATASET dsn FOR INPUT.
*  TRANSFER wa_user_data-preprocessor TO dsn.
*  CLOSE DATASET dsn.


*  Kommunikation erfolgt für die BATCH Verarbeitung
*  über den PlotOperator !!!
        wa_user_data-knz_use_admin_module = 'X'.

*       Aufruf des FBs
        IF itab_items_fauf[] IS INITIAL.
        ELSE.
*         Schreiben in temporäre Plotqueue (wird im FB
*         '/CIDEON/READ_STORED_SEARCH' wieder gelöscht !)
          CALL FUNCTION 'Z_CL_WRITE_PLOT_PSB_NOSTR_BTCH'
               EXPORTING
                    f_aut_process = 'X'
                    g_user        = g_user
               TABLES
                    i_itab_items  = itab_items_fauf
               EXCEPTIONS
                    error         = 1
                    OTHERS        = 2.
          IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
          COMMIT WORK.

*         automatischer Durchlauf durch PlotInterface ?
          IF wa_user_data-knz_auto_fauf = 'X'.
            SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
          ELSE.
            SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
          ENDIF.
*         Aufruf des PlotInterfaces
          SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
*         weiter mit PBO Status 100:

          PERFORM read_default_verteiler.
          PERFORM read_mat_status_exc.
          PERFORM read_stored_search.

          IF itab_search[] IS INITIAL.
          ELSE.

            PERFORM get_dok_text.
            PERFORM get_matnr.
            PERFORM make_knz_freigabe_led.
            PERFORM make_mat_status_icon.
            PERFORM make_display_icon.


*           UP TO_PLOTLIST:
*           get the allowed filetypes for this special user
            IF wa_user_data-use_filter = 'X'.
*              PERFORM get_file_types.
              PERFORM get_file_types_2.
            ELSE.
            ENDIF.
            PERFORM itab_search_to_draw.

*           Verarbeiten von Sondereinträgen

            PERFORM zori_doc_files.

*           Checks if there are any entries available
            DESCRIBE TABLE itab_zori_doc_files LINES count_lines.
            IF count_lines > 0.
              PERFORM add_to_plotlist USING ''.
            ELSE.
            ENDIF.
*           Checks if there are entries in the fail_doc available

            IF itab_fail_document[] IS INITIAL.
            ELSE.
*           Checks what for a strategy shold be used
*           Ask, ignore, list, failure document
              CASE wa_user_data-strategy.
                WHEN 'I'. "Ignore
                  REFRESH itab_fail_document.
                WHEN 'F'. "Fail document
                  PERFORM create_fail_items.
                WHEN OTHERS. "then ignore
                  REFRESH itab_fail_document.
              ENDCASE.
            ENDIF.
*           Check for not existing files
*            PERFORM set_knz_use_checked_in.
            PERFORM set_knz_use_checked_in_2.
            PERFORM reindex_table_2.

*           Kundendaten anfügen
*            PERFORM add_client_data_3.
            PERFORM add_client_data_4.
*           Kostenstelle einfügen
*            PERFORM add_cost_center_2.
            PERFORM add_cost_center_3.

*           Update parameter copies
            PERFORM update_copies USING drzoc_tab-num_copies.
*           UP 'SEND':

            PERFORM send_to_preprocessor.

*           Einstellungen zurücksetzen
            SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
            SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.

            COMMIT WORK.
          ENDIF.
        ENDIF.
      ELSE.
*  kein Empfänger angegeben ? - geht eigentlich nicht.
      ENDIF.
    ELSE.
*  kein Dokument angegeben ? geht eigentlich nicht !
    ENDIF.
    PERFORM initialize_itabs.

  ENDLOOP.

  PERFORM initialize_itabs.

ENDFUNCTION.
