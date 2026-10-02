*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  send
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send.
*
* SP 131
* 7.0.131.1
* 14.07.2010  - CLF Counter -> Problem mit Timing
*              RGG / Rössler
*
  break_point.                                             "#EC NOBREAK

  PERFORM get_latest_path_entries.
  PERFORM fill_jobtable_for_plot.

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

  "SP 217
  "Splitten der Selektionen
  "Struktur mit Tabelle
  CLEAR itab_tmp_plotjobs_gbl.
  DATA ls_pl_gbl TYPE /cideon/s_pl_gbl.
  CLEAR ls_pl_gbl.
  ls_pl_gbl-line = 1.
  ls_pl_gbl-it_pl[] = itab_tmp_plotjobs[].
  APPEND ls_pl_gbl TO itab_tmp_plotjobs_gbl.

  DATA: lt_plotjobs_save TYPE TABLE OF  zcl_s_plotlist.
  CLEAR lt_plotjobs_save.
  "lt_plotjobs_save[] = itab_tmp_plotjobs[].

* 7.0.161.1
* 2012/05/15
* Anpassung der Plotliste nach dem Senden, BUG, daß nach dem Senden die
* Liste unnötigerweise bereinigt wird
*
  lt_plotjobs_save[] = itab_plotjobs[].

  "BADI
  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CALL METHOD badi_main_pre_001->chg_pl_global
      CHANGING
        lt_pl_global = itab_tmp_plotjobs_gbl.
  ENDIF.

  DATA: li_counter_clf TYPE i.
  CLEAR li_counter_clf.

  CLEAR ls_pl_gbl.
  LOOP AT itab_tmp_plotjobs_gbl INTO ls_pl_gbl.
    itab_tmp_plotjobs[] = ls_pl_gbl-it_pl[].

* SP 96
    " 2009/07/22
    " BADI für Konfiguration ändern
    " DHE / Medtronic
    IF badi_main_pre_001 IS INITIAL.
    ELSE.
      CALL METHOD badi_main_pre_001->chg_conf_before_send
        CHANGING
          f_dyn_toc    = f_dyn_toc
          f_dyn_cov    = f_dyn_cov
          ls_user_data = user_data
          lt_plotlist  = itab_tmp_plotjobs.
    ENDIF.

* SP 112
    "Integration der Multipage / Verteilertabelle
    DATA: ls_verteiler_mp TYPE /cideon/vert_mp.
    DATA: ls_plotlist TYPE zcl_s_plotlist.
    DATA: index TYPE i.

* SP 118
    " Setzen des Defaults bei mehrfachen Senden der Plotliste
    LOOP AT itab_tmp_plotjobs INTO ls_plotlist.
      index = sy-tabix.
      ls_plotlist-knz_multi_page = user_data-knz_use_multipage.

      MODIFY itab_tmp_plotjobs FROM ls_plotlist INDEX index.
    ENDLOOP.
* /SP 118

    LOOP AT itab_tmp_plotjobs INTO ls_plotlist.
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

      MODIFY itab_tmp_plotjobs FROM ls_plotlist INDEX index.
    ENDLOOP.

* /SP 112

    IF badi_main_pre_001 IS INITIAL.
    ELSE.
      DATA: f_show_message.
      CLEAR f_show_message.

      CALL METHOD badi_main_pre_001->chg_plotlist_before_send
        CHANGING
          itab_plotlist = itab_tmp_plotjobs
          return        = return
          show_message  = f_show_message.
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

      IF f_show_message = 'X'.
        MESSAGE ID return-id TYPE return-type
          NUMBER return-number
        WITH return-message_v1 return-message_v2
          return-message_v3 return-message_v4.
      ELSE.
      ENDIF.
    ENDIF.

    PERFORM make_auth_check_ws.
    IF f_no_auth = 'X'.
      EXIT.
    ELSE.
    ENDIF.

* Checken, ob alle Dateien auch ausgechecked werden können.
* DMS_MAX_TMP_FILES
    CLEAR f_cancel_send.
    PERFORM check_dms_max_tmp_files.

    IF f_cancel_send = 'X'.
      MESSAGE w111(zcl_plint_message_01)
        WITH  '' '' '' ''.
      EXIT.
    ELSE.
    ENDIF.

    CALL FUNCTION 'Z_CL_PLINT_TOOLS_CHECK_PLOTJOB'
      TABLES
        i_itab_plotjobs = itab_tmp_plotjobs
      EXCEPTIONS
        error           = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
*   CKR 28.09.2009 Einbau Ausgabe per Satzanzahl
      DATA: counter_set TYPE i.
      CLEAR counter_set.

      counter_set = count_satz_c.

      IF counter_set IS INITIAL.
        counter_set = 1.
      ELSE.
      ENDIF.

      "AO$_JOBCOUNT
      IF user_data-ao$_jobcount = 'X'.
        "neue Version
        "Satzanzahl in Einträgen setzen
        LOOP AT itab_tmp_plotjobs INTO ls_plotlist.
          index = sy-tabix.
          ls_plotlist-satzanzahl = counter_set.
          MODIFY itab_tmp_plotjobs FROM ls_plotlist INDEX index.
        ENDLOOP.

        counter_set = 1.
      ELSE.
        "Kopie

      ENDIF.


      " itab_tmp_plotjobs wegspeichern
      DATA: lt_plotjobs_for_set LIKE itab_tmp_plotjobs.
      CLEAR lt_plotjobs_for_set.
      lt_plotjobs_for_set[] = itab_tmp_plotjobs[].

      DO counter_set TIMES.

        "CKR
        itab_tmp_plotjobs[] = lt_plotjobs_for_set[].

*   Anmeldung an einem SMB Share
        IF user_data-knz_anmeldung_am_server = 'X'.
          CALL FUNCTION '/CIDEON/ANMELDUNG_AN_SERVER'
            EXPORTING
              i_anmeldestring_server         = user_data-anmeldestring_server
              i_anmeldestring_server_voher   = user_data-anmeldestring_server_vorher
              i_anmeldestring_server_nachher = user_data-anmeldestring_server_nachher
            EXCEPTIONS
              error                          = 1
              OTHERS                         = 2.
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ELSE.
        ENDIF.

        PERFORM make_send_log_entries.

        str_down_path = user_data-down_path.
        str_ppl_down_path = user_data-ppl_down_path.

        IF user_data-knz_use_post = 'X'.
*       Senden an PostProzessor   PPl-Dateien
          LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs.
            REFRESH itab_tmp_plotjobs_2.
            LOOP AT itab_tmp_plotjobs INTO wa_plotjobs
              WHERE voreinstellung = wa_tmp_plotjobs-voreinstellung.
              index_itab_tmp_plotjobs_2 = sy-tabix.
              APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
              DELETE itab_tmp_plotjobs INDEX index_itab_tmp_plotjobs_2.
            ENDLOOP.

            CALL FUNCTION 'Z_DMS_NEW_PLOT_LIST'
              EXPORTING
                i_down_path     = str_down_path
                filter          = '*.*'
                test            = ''
                i_ppl_down_path = str_ppl_down_path
                default_user    = default_data-default_nutzer
              TABLES
                itab_test       = itab_tmp_plotjobs_2
              EXCEPTIONS
                error           = 1.
            IF sy-subrc NE 0.
            ELSE.
              COMMIT WORK AND WAIT.
            ENDIF.
          ENDLOOP.
        ELSE.
*     Senden an PreProzessor CLF-Dateien

          LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs.
            " 2009/08/14
            " Zähler
            "li_counter_clf = sy-tabix.
            "li_counter_clf = li_counter_clf + 1.


            REFRESH itab_tmp_plotjobs_2.
*       Für jede Datei eine eigene CLF erzeugen lassen
*       KNZ_SINGLE_EINTRY
            IF user_data-knz_single_entry = 'X'.
              LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*            WHERE
*            verteiler = wa_tmp_plotjobs-verteiler.
                index_itab_tmp_plotjobs_2 = sy-tabix.
                APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
                DELETE itab_tmp_plotjobs INDEX index_itab_tmp_plotjobs_2.
                EXIT.
              ENDLOOP.

              LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
                index_itab_tmp_plotjobs_2 = sy-tabix.
                wa_plotjobs-cont = index_itab_tmp_plotjobs_2.
                wa_plotjobs-status = c_status_created_plot.

                MODIFY itab_tmp_plotjobs_2 FROM wa_plotjobs
                  INDEX index_itab_tmp_plotjobs_2.
              ENDLOOP.
            ELSE.
*
              "Aufteilen der Einträge auf unterschiedliche Verteiler
              "Nur Jobs mit gleichen Verteiler werden gesendet

              "Einbau, daß auch separiert werden kann nach EBELN
              "und VBELN
              CASE user_data-knz_me_sep.
                WHEN 'X'.
                  CASE user_data-knz_sd_sep.
                    WHEN 'X'.
                      "X X
                      LOOP AT itab_tmp_plotjobs INTO wa_plotjobs
                        WHERE
                        verteiler = wa_tmp_plotjobs-verteiler
                        AND ebeln = wa_tmp_plotjobs-ebeln
                        AND vbeln = wa_tmp_plotjobs-vbeln.

                        index_itab_tmp_plotjobs_2 = sy-tabix.
                        APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
                        DELETE itab_tmp_plotjobs
                          INDEX index_itab_tmp_plotjobs_2.
                      ENDLOOP.
                    WHEN OTHERS.
                      "X 0
                      LOOP AT itab_tmp_plotjobs INTO wa_plotjobs
                       WHERE
                       verteiler = wa_tmp_plotjobs-verteiler
                       AND ebeln = wa_tmp_plotjobs-ebeln.

                        index_itab_tmp_plotjobs_2 = sy-tabix.
                        APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
                        DELETE itab_tmp_plotjobs
                          INDEX index_itab_tmp_plotjobs_2.
                      ENDLOOP.
                  ENDCASE.
                WHEN OTHERS.
                  CASE user_data-knz_sd_sep.
                    WHEN 'X'.
                      "0 X
                      LOOP AT itab_tmp_plotjobs INTO wa_plotjobs
                        WHERE
                        verteiler = wa_tmp_plotjobs-verteiler
                        AND vbeln = wa_tmp_plotjobs-vbeln.

                        index_itab_tmp_plotjobs_2 = sy-tabix.
                        APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
                        DELETE itab_tmp_plotjobs
                          INDEX index_itab_tmp_plotjobs_2.
                      ENDLOOP.
                    WHEN OTHERS.
                      "0 0
                      LOOP AT itab_tmp_plotjobs INTO wa_plotjobs
                        WHERE
                       " voreinstellung = wa_tmp_plotjobs-voreinstellung
                        verteiler = wa_tmp_plotjobs-verteiler.
                        index_itab_tmp_plotjobs_2 = sy-tabix.
                        APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
                        DELETE itab_tmp_plotjobs
                          INDEX index_itab_tmp_plotjobs_2.
                      ENDLOOP.
                  ENDCASE.
              ENDCASE.

*          LOOP AT itab_tmp_plotjobs INTO wa_plotjobs
*            WHERE
*            " voreinstellung = wa_tmp_plotjobs-voreinstellung
*            verteiler = wa_tmp_plotjobs-verteiler.
*            index_itab_tmp_plotjobs_2 = sy-tabix.
*            APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
*            DELETE itab_tmp_plotjobs INDEX index_itab_tmp_plotjobs_2.
*          ENDLOOP.

              LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
                index_itab_tmp_plotjobs_2 = sy-tabix.
                wa_plotjobs-cont = index_itab_tmp_plotjobs_2.
                wa_plotjobs-status = c_status_created_plot.

                MODIFY itab_tmp_plotjobs_2 FROM wa_plotjobs
                  INDEX index_itab_tmp_plotjobs_2.
              ENDLOOP.
            ENDIF.
            str_ppl_down_path = user_data-clf_down_path.

            PERFORM get_stamp_values.

            PERFORM get_class_data.

            PERFORM get_result_stamp_values.


*       BADI für Manipulation der Stempelwerte etc.
            CALL METHOD cl_exithandler=>get_instance
              CHANGING
                instance = badi_main_pre_001.
            IF sy-subrc NE 0.
            ELSE.
              CALL METHOD badi_main_pre_001->chg_after_get_stamps
                CHANGING
                  itab_plotlist     = itab_tmp_plotjobs_2
                  return            = return
                  itab_stamp_values = itab_stempel_wert.
            ENDIF.

            IF user_data-knz_use_admin_module = 'X'.
*         auf jeden Fall Job ID erzeugen!!!
              user_data-knz_make_id_plotjob = 'X'.
            ELSE.
            ENDIF.

*       ID des Plotjobs erzeugen
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

                MODIFY itab_tmp_plotjobs_2 FROM wa_plotjobs
                  INDEX index_itab_tmp_plotjobs_2.
              ENDLOOP.
            ELSE.
            ENDIF.

*       GUID des Plotjobs erzeugen
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
              wa_plotjobs-id_plotjob_32 = g_id_plotjob_32.

              MODIFY itab_tmp_plotjobs_2 FROM wa_plotjobs
                INDEX index_itab_tmp_plotjobs_2.
            ENDLOOP.

*       Update des Plot - Logs
            DATA: wa_pl_log TYPE /cideon/pl_log.
            DATA: wa_pl_log_2 TYPE /cideon/pl_log2.
            LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
              index_itab_tmp_plotjobs_2 = sy-tabix.
              CLEAR wa_pl_log.
              CLEAR wa_pl_log_2.
              SELECT SINGLE * FROM /cideon/pl_log
                INTO wa_pl_log
                WHERE id = wa_plotjobs-id_plotlog
                .
              IF sy-subrc NE 0.
                CONTINUE.
              ELSE.
                SELECT SINGLE * FROM /cideon/pl_log2
                  INTO wa_pl_log_2
                  WHERE id = wa_plotjobs-id_plotlog
                  .
                IF sy-subrc NE 0.
                ELSE.
                ENDIF.

                wa_pl_log-id_plotjob = wa_plotjobs-id_plotjob.
                wa_pl_log-id_plotjob_32 = wa_plotjobs-id_plotjob_32.

                wa_pl_log_2-id_plotjob = wa_plotjobs-id_plotjob.
                wa_pl_log_2-id_plotjob_32 = wa_plotjobs-id_plotjob_32.

*           BADI
                IF badi_main_pre_001 IS INITIAL.
                ELSE.
                  CALL METHOD badi_main_pre_001->chg_log_at_set_id
                    CHANGING
                      plot_item  = wa_plotjobs
                      log_item   = wa_pl_log
                      log_item_2 = wa_pl_log_2.
                ENDIF.

                MODIFY /cideon/pl_log FROM wa_pl_log.
                IF sy-subrc NE 0.
                ELSE.
                ENDIF.

                MODIFY /cideon/pl_log2 FROM wa_pl_log_2.
                IF sy-subrc NE 0.
                ELSE.
                ENDIF.
              ENDIF.
            ENDLOOP.
            COMMIT WORK AND WAIT.

*       Verarbeitung mit ADMIN Module
            CASE user_data-knz_use_admin_module.
              WHEN 'X'.
                CALL FUNCTION '/CIDEON/WRITE_DATA_TO_ADMIN'
                  EXPORTING
                    i_wa_user_data      = user_data
                    i_wa_default_data   = default_data
                    i_programm          = 'ZCL_PLINT_DESIGN_007F03'
                    i_id_plotjob        = g_id_plotjob
                    i_str_down_path     = str_down_path
                    i_str_ppl_down_path = str_ppl_down_path
                  TABLES
                    itab_plotjobs       = itab_tmp_plotjobs_2
                    itab_stempel_wert   = itab_stempel_wert
                    it_notiz            = it_notiz
                  EXCEPTIONS
                    error               = 1
                    OTHERS              = 2.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF.
*               mit nächstem Datensatz fortfahren
                CONTINUE.
              WHEN 'B'.
                "BADI - OM 7.5
                IF badi_main_pre_001 IS INITIAL.
                ELSE.
                  "Aufruf des BADIS mit Informationen
                  DATA: lc_programm TYPE programm.
                  lc_programm = 'ZCL_PLINT_DESIGN_007F03'.

                  CALL METHOD exit->send_to_badi
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
                      error                = 1
                      OTHERS               = 2.
                  .
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
*               mit nächstem datensatz fortfahren
                  CONTINUE.
                ENDIF.
              WHEN OTHERS.
            ENDCASE.

*            IF user_data-knz_use_admin_module = 'X'.
*              CALL FUNCTION '/CIDEON/WRITE_DATA_TO_ADMIN'
*                   EXPORTING
*                        i_wa_user_data      = user_data
*                        i_wa_default_data   = default_data
*                        i_programm          = 'ZCL_PLINT_DESIGN_007F03'
*                        i_id_plotjob        = g_id_plotjob
*                        i_str_down_path     = str_down_path
*                        i_str_ppl_down_path = str_ppl_down_path
*                   TABLES
*                        itab_plotjobs       = itab_tmp_plotjobs_2
*                        itab_stempel_wert   = itab_stempel_wert
*                        it_notiz            = it_notiz
*                   EXCEPTIONS
*                        error               = 1
*                        OTHERS              = 2.
*              IF sy-subrc <> 0.
*                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*              ENDIF.
*
*
**         mit nächstem Datensatz fortfahren
*              CONTINUE.
*            ELSE.
*            ENDIF.

*       SP 100
            " Seitenzahlen berücksichtigen
            " 2009/08/03
            " Seitenzahlen nochmals anpassen
            " Corden Pharma
            "
            " wa_test-seite ist ausschlaggebend

            DATA: lt_plotjobs_pages LIKE itab_tmp_plotjobs_2.
            "DATA: ls_plotjobs_pages LIKE wa_plotjobs.

            CLEAR lt_plotjobs_pages.
            "CLEAR ls_plotjobs_pages.

            LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
              " Fehlerbehandlung integrieren
*           SP115
              " , und ; in SEITE_VON integrieren
              " freie Intervalle
              DATA: lt_seiten TYPE TABLE OF zcl_seite_von.
              DATA: lt_seiten_all TYPE TABLE OF zcl_seite_von.
              DATA: lt_seiten_tmp TYPE TABLE OF zcl_seite_von.

              DATA: ls_seiten TYPE zcl_seite_von.

              CLEAR lt_seiten.

              IF wa_plotjobs-seite_von CA ';,'.
                CLEAR lt_plotjobs_pages.
                "CLEAR ls_plotjobs_pages.

                SPLIT wa_plotjobs-seite_von AT ';' INTO TABLE lt_seiten.
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

                LOOP AT lt_seiten_all INTO ls_seiten.
                  wa_plotjobs-seite_von = ls_seiten.
                  wa_plotjobs-seite_bis = ls_seiten.
                  APPEND wa_plotjobs TO lt_plotjobs_pages.
                ENDLOOP.

                CONTINUE.
              ENDIF.
*           /SP115

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

            li_counter_clf = li_counter_clf + 1.

*       normale Verarbeitung
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
                  li_counter_clf     = li_counter_clf
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

          ENDLOOP.

          COMMIT WORK AND WAIT.
          REFRESH itab_tmp_plotjobs_2.
        ENDIF.

      ENDDO.

      "MESSAGE i100(zcl_plint_message_01) WITH '' '' '' ''.
      COMMIT WORK AND WAIT.

      " BADI um etwas nach dem Senden zu tun
      " -> Corden Pharma

      IF badi_main_pre_001 IS INITIAL.
      ELSE.
        CALL METHOD badi_main_pre_001->chg_plotlist_after_send
          CHANGING
            itab_plotlist = lt_plotjobs_for_set
            return        = return.                             "itab_tmp_plotjobs

        IF return-type CA 'EA'.
          " Fehler
        ELSE.
          " Übergabe der Werte
          "itab_plotjobs
          "itab_et_index_rows_plotlist

          DATA: index_rows TYPE i.
          DATA: ls_plotlist_tmp TYPE zcl_s_plotlist.

          CLEAR index_rows.
          CLEAR ls_plotlist_tmp.

          CLEAR wa_et_index_rows_plotlist.
          LOOP AT itab_et_index_rows_plotlist INTO
            wa_et_index_rows_plotlist.
            index_rows = sy-tabix.

            "selektierte lesen
            READ TABLE lt_plotjobs_for_set
              INTO ls_plotlist_tmp INDEX index_rows.
            IF sy-subrc NE 0.
            ELSE.
            ENDIF.

            " normale Plotliste aktualisieren
            MODIFY itab_plotjobs FROM ls_plotlist_tmp
              INDEX wa_et_index_rows_plotlist-index.
            IF sy-subrc NE 0.
            ELSE.
            ENDIF.

          ENDLOOP.

        ENDIF.
      ENDIF.

    ENDIF.
  ENDLOOP.


  itab_plotjobs[] = lt_plotjobs_save[].

  "7.0.127.4
  "Verlagerung der Meldung
  "7.0.137.1
  DATA: f_skip_message TYPE char1.
  CLEAR f_skip_message.

  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CALL METHOD badi_main_pre_001->skip_message_after_send
      CHANGING
        itab_plotlist   = itab_plotjobs[]
        itab_searchlist = itab_search_tmp[]
        f_skip_message  = f_skip_message
      EXCEPTIONS
        cancel          = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    ENDIF.
  ENDIF.

  IF f_skip_message = 'X'.
  ELSE.
    MESSAGE i100(zcl_plint_message_01) WITH '' '' '' ''.
  ENDIF.
  "7.0.132.5
** CHG MBH - BAdI zum Leeren der Plot- und Searchlist sowie Verlassen
**            des Programms,
  IF badi_main_pre_001 IS INITIAL.
  ELSE.

    CALL METHOD badi_main_pre_001->chg_plotlist_after_send2
      CHANGING
        itab_plotlist   = itab_plotjobs[]
        itab_searchlist = itab_search_tmp[]
      EXCEPTIONS
        cancel          = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      LEAVE PROGRAM.
    ENDIF.

  ENDIF.

  "7.0.128.1
  PERFORM reindex_table_3.
ENDFORM.                    " send
*&---------------------------------------------------------------------*
*&      Form  reselect_tree_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reselect_tree_entries.
* try to select the corresponding nodes
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1 TYPE string.
  DATA: text2(10).
  DATA: itab_sel_tree TYPE treemnotab.
  DATA: wa_sel_tree TYPE tm_nodekey .

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.


  REFRESH itab_sel_tree.

  LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
    CLEAR properties.
    CLEAR node_key.
    text1 = wa_et_index_rows_plotlist-index.
    index_itab_plotjobs_tmp = wa_et_index_rows_plotlist-index.
    text1 = index_itab_plotjobs_tmp.
    SHIFT text1 LEFT DELETING LEADING space.
    CLEAR wa_plotjobs.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

    CONCATENATE text1 wa_plotjobs-filep
      INTO node_key.

    CLEAR wa_sel_tree.
    wa_sel_tree = node_key.
    APPEND wa_sel_tree TO itab_sel_tree.
  ENDLOOP.

  CALL METHOD simple_tree_plotlist->unselect_all
    .

  CALL METHOD simple_tree_plotlist->select_nodes
    EXPORTING
      node_key_table               = itab_sel_tree
    EXCEPTIONS
      multiple_node_selection_only = 1
      error_in_node_key_table      = 2
      OTHERS                       = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID 'W' TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " reselect_tree_entries
*&---------------------------------------------------------------------*
*&      Form  maintain_default_stamps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_default_stamps.
  CALL TRANSACTION 'Z_CL_MNTN_STAMPS_DEF'.
ENDFORM.                    " maintain_default_stamps
*&---------------------------------------------------------------------*
*&      Form  maintain_user_stamps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_user_stamps.
  CALL TRANSACTION 'Z_CL_MNTN_STAMPS_USR'.
ENDFORM.                    " maintain_user_stamps
*&---------------------------------------------------------------------*
*&      Form  maintain_voreinstell_stamps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_voreinstell_stamps.
  CALL TRANSACTION 'Z_CL_MNTN_STAMPS_VOR'.
ENDFORM.                    " maintain_voreinstell_stamps
*&---------------------------------------------------------------------*
*&      Form  maintain_verteiler_stamps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_verteiler_stamps.
  CALL TRANSACTION 'Z_CL_MNTN_STAMPS_VER'.
ENDFORM.                    " maintain_verteiler_stamps
*&---------------------------------------------------------------------*
*&      Form  check_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_date.

  IF wa_info-gueltig_bis < sy-datum.
    MESSAGE e997(zcl_plint_message_01) WITH
      wa_info-gueltig_bis '' '' ''.
  ELSE.
    IF wa_info-gueltig_bis = '99991231'.
    ELSE.
      MESSAGE i998(zcl_plint_message_01) WITH
        wa_info-gueltig_bis '' '' ''.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_date
*&---------------------------------------------------------------------*
*&      Form  change_vbeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_vbeln.
* changes the VBELN
  DATA: vbeln TYPE vbak-vbeln.

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTVB'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
*     keine Berechtigung
      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
*     Sie haben keine Berechtigung für diese Funktion! & & & &
      EXIT.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.


  CLEAR vbeln.

  CALL FUNCTION 'Z_CL_PLINT_TOOLS_ASK_FOR_VBELN'
    IMPORTING
      o_vbeln = vbeln
    EXCEPTIONS
      error   = 1
      forget  = 2
      OTHERS  = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.

  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-vbeln = vbeln.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.


ENDFORM.                    " change_vbeln
*&---------------------------------------------------------------------*
*&      Form  change_vbeln_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_vbeln_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_vbeln.

ENDFORM.                    " change_vbeln_tree
*&---------------------------------------------------------------------*
*&      Form  get_stabk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stabk.
* ergänzt STABK / Sprachabhängige Stati
  DATA: wa_tdwst TYPE tdwst.

  LOOP AT itab_search INTO wa_search.
    SELECT SINGLE * FROM tdwst INTO wa_tdwst
      WHERE  cvlang = sy-langu
      AND dokst = wa_search-dokst
      .
    IF sy-subrc NE 0.
    ELSE.
      wa_search-stabk = wa_tdwst-stabk.
      wa_search-dostx = wa_tdwst-dostx.
      MODIFY itab_search FROM wa_search INDEX sy-tabix.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " get_stabk
*&---------------------------------------------------------------------*
*&      Form  get_dok_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_dok_status.
* DOKST, STABK, TXT
  DATA: index_tab TYPE sy-tabix.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    index_tab = sy-tabix.

    LOOP AT itab_search INTO wa_search_tmp
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      .
    ENDLOOP.

    IF sy-subrc NE 0.
    ELSE.
      wa_plotjobs-dokst = wa_search_tmp-dokst.
      wa_plotjobs-stabk = wa_search_tmp-stabk.
      wa_plotjobs-dostx = wa_search_tmp-dostx.
      wa_plotjobs-mstae = wa_search_tmp-mstae.
      wa_plotjobs-mstde = wa_search_tmp-mstde.
      wa_plotjobs-mat_count = wa_search_tmp-mat_count.

      wa_plotjobs-light = wa_search_tmp-knz_freigabe.

      MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX index_tab.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_dok_status
*&---------------------------------------------------------------------*
*&      Form  change_verteiler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_verteiler.
  DATA: verteiler TYPE zcl_name_verteiler.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR verteiler.

  CALL FUNCTION 'Z_CL_PLINT_TOOLS_ASK_FOR_VERT2'
    EXPORTING
      i_uname          = user_data-uname
      i_default_nutzer = default_data-default_nutzer
      i_user_data      = user_data
    IMPORTING
      o_verteiler      = verteiler
    EXCEPTIONS
      error            = 1
      forget           = 2
      OTHERS           = 3.

  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.

  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-verteiler = verteiler.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

ENDFORM.                    " change_verteiler
*&---------------------------------------------------------------------*
*&      Form  change_verteiler_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_verteiler_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_verteiler.

ENDFORM.                    " change_verteiler_tree
*&---------------------------------------------------------------------*
*&      Form  save_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_plotlist.
* saves the Searchlist into a local file
  CALL FUNCTION 'Z_CL_WRITE_PLOT_FILE'
    EXPORTING
      i_filename              = user_data-plotlist_file
*     I_TRENNZEICHEN          = '/'
    TABLES
      i_itab_plotlist       = itab_plotjobs
   EXCEPTIONS
     error                   = 1
     OTHERS                  = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " save_plotlist
*&---------------------------------------------------------------------*
*&      Form  open_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_plotlist.
  DATA: itab_plotlist TYPE TABLE OF zcl_s_plotlist.
  DATA: wa_itab_plotlist TYPE zcl_s_plotlist.

  REFRESH itab_plotlist.

  CALL FUNCTION 'Z_CL_READ_PLOT_FILE'
    EXPORTING
      i_filename           = user_data-plotlist_file
*     I_TRENNZEICHEN       = '/'
    TABLES
      o_itab_plotjobs        = itab_plotlist
   EXCEPTIONS
     error                = 1
     OTHERS               = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT itab_plotlist INTO wa_itab_plotlist.
    "2014/11/10 Setzen des Kennzeichens Laden aus Plotliste
    wa_itab_plotlist-f_from_pl_csv = abap_true.
    APPEND wa_itab_plotlist TO itab_plotjobs.
  ENDLOOP.

ENDFORM.                    " open_plotlist
*&---------------------------------------------------------------------*
*&      Form  check_version_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_version_type.
* Version type check
  DATA: anzahl_user_version TYPE i.
  DATA: anzahl_user TYPE i.

  IF wa_info-versions_typ = '*'.
    "no check needed, unlimited version!
    EXIT.
  ELSE.
    CLEAR anzahl_user.
    anzahl_user_version = wa_info-versions_typ.

    SELECT COUNT(*) FROM usr02
      INTO anzahl_user
      WHERE ustyp = 'A'
      .
    IF sy-subrc NE 0.
      EXIT.
    ELSE.
    ENDIF.

    IF anzahl_user > anzahl_user_version.
      MESSAGE e996(zcl_plint_message_01) WITH
        anzahl_user_version anzahl_user '' .
    ELSE.
    ENDIF.


  ENDIF.
ENDFORM.                    " check_version_type
*&---------------------------------------------------------------------*
*&      Form  maintain_neutral_format
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_neutral_format.
  CALL TRANSACTION 'Z_CL_MAINT_OR_FORMAT'.
ENDFORM.                    " maintain_neutral_format
*&---------------------------------------------------------------------*
*&      Form  only_checked_in_pl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM only_checked_in_pl.
* remove all items in the plotlist if they are not checked in
  DATA: wa TYPE zcl_s_plotlist.


  LOOP AT itab_plotjobs INTO wa.
    IF wa-checked = 'X'.
    ELSE.
      DELETE itab_plotjobs INDEX sy-tabix.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " only_checked_in_pl
*&---------------------------------------------------------------------*
*&      Form  delete_old_jobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_old_jobs.
* Lösche nicht mehr benötigte Dateien in den Download Verzeichnissen

*  SUBMIT zcl_batch_clf_down_file_delete AND RETURN.

  PERFORM del_down_files_2.

ENDFORM.                    " delete_old_jobs
*&---------------------------------------------------------------------*
*&      Form  maintain_groups_appl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_groups_appl.
  CALL TRANSACTION 'Z_CL_MNTN_GROUP_TDWP'.
ENDFORM.                    " maintain_groups_appl
*&---------------------------------------------------------------------*
*&      Form  maintain_user_groups
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_user_groups.
  CALL TRANSACTION 'Z_CL_MNTN_GROUP_USER'.
ENDFORM.                    " maintain_user_groups
*&---------------------------------------------------------------------*
*&      Form  change_AUFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_aufnr.
* changes the AUFNR
  DATA: aufnr TYPE zcl_s_plotlist-aufnr.
  DATA: wa_tmp_plotlist_aufnr TYPE zcl_s_plotlist.

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFA'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
*     keine Berechtigung
      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
*     Sie haben keine Berechtigung für diese Funktion! & & & &
      EXIT.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CLEAR f_paste.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

  IF count_lines = 1.
    CLEAR wa_tmp_plotlist_aufnr.
    LOOP AT itab_et_index_rows_plotlist
       INTO wa_et_index_rows_plotlist.
      READ TABLE itab_plotjobs INTO wa_tmp_plotlist_aufnr
        INDEX wa_et_index_rows_plotlist-index.
    ENDLOOP.
  ELSE.
  ENDIF.

  CLEAR aufnr.

  CALL FUNCTION 'Z_CL_PLINT_TOOLS_ASK_FOR_AUFNR'
    EXPORTING
      i_aufnr = wa_tmp_plotlist_aufnr-aufnr
    IMPORTING
      o_aufnr = aufnr
    EXCEPTIONS
      error   = 1
      forget  = 2
      OTHERS  = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 2.
      EXIT.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.

  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    wa_plotjobs-aufnr = aufnr.
    MODIFY itab_plotjobs FROM wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
  ENDLOOP.

ENDFORM.                    " change_AUFNR
*&---------------------------------------------------------------------*
*&      Form  change_aufnr_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_aufnr_tree.

  PERFORM sel_tree_to_sel_list.
  PERFORM change_aufnr.

ENDFORM.                    " change_aufnr_tree
*&---------------------------------------------------------------------*
*&      Form  cv03n_view_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cv03n_view_list.
* calls Transactionb 'cv03n'
  DATA: count_lines TYPE i.
  DATA: wa_tmp_plotlist TYPE zcl_s_plotlist.

  CLEAR wa_tmp_plotlist.
  REFRESH itab_et_index_rows_plotlist.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines <> 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e000(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
    READ TABLE itab_et_index_rows_plotlist
      INTO wa_et_index_rows_plotlist INDEX 1.
    READ TABLE itab_plotjobs INTO wa_tmp_plotlist
      INDEX wa_et_index_rows_plotlist-index .
  ENDIF.

  CASE wa_tmp_plotlist-object_type.
    WHEN 'SPOOL'.
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
        EXPORTING
          i_spoolid = wa_tmp_plotlist-tdspoolid
        EXCEPTIONS
          error     = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      EXIT.

    WHEN 'URL'.
      CALL FUNCTION '/CIDEON/OM_ITEM_SHOW_URL'
        EXPORTING
          i_url = wa_tmp_plotlist-url.

    WHEN OTHERS.
      SET PARAMETER ID 'CV1' FIELD wa_tmp_plotlist-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_tmp_plotlist-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_tmp_plotlist-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_tmp_plotlist-doktl.

      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
  ENDCASE.


** Spoolbehandlung
*  IF wa_tmp_plotlist-object_type = 'SPOOL'.
*    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
*         EXPORTING
*              i_spoolid = wa_tmp_plotlist-tdspoolid
*         EXCEPTIONS
*              error     = 1
*              OTHERS    = 2.
*    IF sy-subrc <> 0.
*      EXIT.
*    ENDIF.
*    EXIT.
*  ELSE.
*  ENDIF.
*
*  SET PARAMETER ID 'CV1' FIELD wa_tmp_plotlist-doknr.
*  SET PARAMETER ID 'CV2' FIELD wa_tmp_plotlist-dokar.
*  SET PARAMETER ID 'CV3' FIELD wa_tmp_plotlist-dokvr.
*  SET PARAMETER ID 'CV4' FIELD wa_tmp_plotlist-doktl.
*
*  CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
*

ENDFORM.                    " cv03n_view_list
*&---------------------------------------------------------------------*
*&      Form  cv03n_view_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cv03n_view_tree.

  CASE wa_plotjobs-object_type.
    WHEN 'SPOOL'.
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
        EXPORTING
          i_spoolid = wa_plotjobs-tdspoolid
        EXCEPTIONS
          error     = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      EXIT.
    WHEN 'URL'.
      CALL FUNCTION '/CIDEON/OM_ITEM_SHOW_URL'
        EXPORTING
          i_url = wa_plotjobs-url.
    WHEN OTHERS.

      SET PARAMETER ID 'CV1' FIELD wa_plotjobs-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_plotjobs-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_plotjobs-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_plotjobs-doktl.

      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

  ENDCASE.


** Spoolbehandlung
*  IF wa_plotjobs-object_type = 'SPOOL'.
*    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
*         EXPORTING
*              i_spoolid = wa_plotjobs-tdspoolid
*         EXCEPTIONS
*              error     = 1
*              OTHERS    = 2.
*    IF sy-subrc <> 0.
*      EXIT.
*    ENDIF.
*    EXIT.
*  ELSE.
*  ENDIF.

*
*  SET PARAMETER ID 'CV1' FIELD wa_plotjobs-doknr.
*  SET PARAMETER ID 'CV2' FIELD wa_plotjobs-dokar.
*  SET PARAMETER ID 'CV3' FIELD wa_plotjobs-dokvr.
*  SET PARAMETER ID 'CV4' FIELD wa_plotjobs-doktl.
*
*  CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

ENDFORM.                    " cv03n_view_tree
*&---------------------------------------------------------------------*
*&      Form  read_repro_ini2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_repro_ini2.
* read the repro INI / Update der PreProzessoren

  CALL TRANSACTION 'ZCL_PLINT_UPD_INI_PR'.

ENDFORM.                    " read_repro_ini2
*&---------------------------------------------------------------------*
*&      Form  preproz_to_user
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM preproz_to_user.
* einem Nutzer einen PreProzessor Zuordnen

  CALL TRANSACTION 'Z_CL_MNTN_PREPR_USER'.

ENDFORM.                    " preproz_to_user
*&---------------------------------------------------------------------*
*&      Form  DEL_DOWN_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_down_files.
  DATA: down_path TYPE string.
  DATA: clf_down_path TYPE string.

  clf_down_path = user_data-clf_down_path.
  down_path = user_data-down_path.

  IF user_data-knz_down_files_del = 'X'.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = '20'  " Balkenanzeige
        text       = text-040.


    CALL FUNCTION 'Z_CL_DEL_TMP_DIR_BY_NAMES'
      EXPORTING
        i_clf_down_path = clf_down_path
        i_down_path     = down_path
        i_test          = ''
      EXCEPTIONS
        error           = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
  ENDIF.

ENDFORM.                    " DEL_DOWN_FILES
*&---------------------------------------------------------------------*
*&      Form  set_stamp_language
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_stamp_language.
* setzt die Sprache für sprachabhängige Stempelfunktionen
  CALL FUNCTION 'Z_CL_SET_ACTUAL_STAMP_LANGUAGE'
    EXCEPTIONS
      error  = 1
      OTHERS = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " set_stamp_language
