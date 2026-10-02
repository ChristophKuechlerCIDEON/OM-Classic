FUNCTION z_cl_doc_change_event_batch_02.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE OPTIONAL
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"     VALUE(EXCEPTIONS_ALLOWED) LIKE  SWEFLAGS-EXC_OK DEFAULT SPACE
*"     VALUE(WF_ERZEUGER) LIKE  WFSYST-AGENT OPTIONAL
*"  EXPORTING
*"     VALUE(REC_ID) LIKE  SWELOG-RECID
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT OPTIONAL
*"  EXCEPTIONS
*"      ANY_ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*
* Änderer:
*           Christoph Küchler
*           Chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 20.07.2004 - Kopie + Änderungen
*              Anpassung an neue FBs          CKR
*23.07.2004  - Start über WF - Parameteranpassung PRE
*-----------------------------------------------------------------------


* Einstellungen lesen
  CLEAR wa_user_data.
  CLEAR wa_default_data.
  CLEAR:  g_user, g_draw_key,
          wa_draw, wa_item_fauf,
          wa_default_verteiler,
          itab_items_fauf,
          itab_mat_status_exc,
          itab_search.

*  Füllen der globalen Daten aus den WF-Container-Daten
  IF NOT objkey IS INITIAL.
    g_draw_key = objkey.
    IF NOT wf_erzeuger IS INITIAL.
      g_user = wf_erzeuger+2.
    ELSE.
    ENDIF.

*  Füllen der Auftragstab zum Schreiben in temporäre Plotqueue
    PERFORM fill_itab_items_fauf.

*---------------------------------------------------
*  Programmablauf analog
*  ZCL_PLINT_DESIGN_007
*---------------------------------------------------
*  PBO Status 100

    PERFORM read_user_and_default_data.

*  Kommunikation erfolgt für die BATCH Verarbeitung
*  über den PlotOperator !!!
    wa_user_data-knz_use_admin_module = 'X'.

*  Aufruf des FBs
    IF itab_items_fauf[] IS INITIAL.
    ELSE.
*  Schreiben in temporäre Plotqueue (wird im FB
*  '/CIDEON/READ_STORED_SEARCH' wieder gelöscht !)
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

*  automatischer Durchlauf durch PlotInterface ?
      IF wa_user_data-knz_auto_fauf = 'X'.
        SET PARAMETER ID 'Z_PL_BYPASS' FIELD 'X'.
      ELSE.
        SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
      ENDIF.
*  Aufruf des PlotInterfaces
      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
*  weiter mit PBO Status 100:

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


*  UP TO_PLOTLIST:
*  get the allowed filetypes for this special user
        IF wa_user_data-use_filter = 'X'.
          PERFORM get_file_types.
        ELSE.
        ENDIF.
        PERFORM itab_search_to_draw.

*  Verarbeiten von Sondereinträgen

        PERFORM zori_doc_files.

*  Checks if there are any entries available
        DESCRIBE TABLE itab_zori_doc_files LINES count_lines.
        IF count_lines > 0.
          PERFORM add_to_plotlist USING ''.
        ELSE.
        ENDIF.
*  Checks if there are entries in the fail_doc available

        IF itab_fail_document[] IS INITIAL.
        ELSE.
*  Checks what for a strategy shold be used
*  Ask, ignore, list, failure document
          CASE wa_user_data-strategy.
            WHEN 'I'. "Ignore
              REFRESH itab_fail_document.
            WHEN 'F'. "Fail document
              PERFORM create_fail_items.
            WHEN OTHERS. "then ignore
              REFRESH itab_fail_document.
          ENDCASE.
        ENDIF.
*  Check for not existing files
        PERFORM set_knz_use_checked_in.
        PERFORM reindex_table_2.

*  Kundendaten anfügen
        PERFORM add_client_data_3.
*  Kostenstelle einfügen
        PERFORM add_cost_center_2.

*  UP 'SEND':
        PERFORM send_to_preprocessor.

*  Einstellungen zurücksetzen
        SET PARAMETER ID 'Z_PL_BYPASS' FIELD ''.
        SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD ''.

        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
