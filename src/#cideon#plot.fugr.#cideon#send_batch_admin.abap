FUNCTION /cideon/send_batch_admin.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) LIKE  /CIDEON/PLOT_USERDATA STRUCTURE
*"        /CIDEON/PLOT_USERDATA
*"     VALUE(I_WA_DEFAULT_DATA) LIKE  /CIDEON/PLOT_DEFAULTDATA
*"       STRUCTURE  /CIDEON/PLOT_DEFAULTDATA
*"     VALUE(I_UNAME) LIKE  SYST-UNAME DEFAULT ''
*"     VALUE(I_PROGRAMM) TYPE  PROGRAMM OPTIONAL
*"  TABLES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
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
* 19.07.2004 - Erstellung
* 26.07.2004 -
*  mglw. Probleme mit sy-uname
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_tmp_plotjobs TYPE TABLE OF zcl_s_plotlist.
  DATA: itab_tmp_plotjobs_2 TYPE TABLE OF zcl_s_plotlist.
  DATA: itab_stempel_wert TYPE TABLE OF zcl_s_stempel_value.
  DATA: it_notiz type table of ZCL_STEMPEL_WERT.
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.
  DATA: wa_tmp_plotjobs LIKE zcl_s_plotlist.

*NORMAL
  DATA: f_no_auth VALUE ''.
  DATA: str_down_path TYPE string.
  DATA: str_ppl_down_path TYPE string.
  DATA: index_itab_tmp_plotjobs_2 TYPE sy-tabix.
  DATA: g_id_plotjob TYPE zcl_s_plotlist-id_plotjob.


*  break_point.                                             "#EC NOBREAK

  i_wa_user_data-knz_use_admin_module = 'X'.

  IF i_uname IS INITIAL.
    i_uname = sy-uname.
  ELSE.
  ENDIF.


*  PERFORM get_latest_path_entries.
*  PERFORM fill_jobtable_for_plot.
  CLEAR itab_tmp_plotjobs.
  CLEAR itab_tmp_plotjobs_2.
  itab_tmp_plotjobs[] = itab_plotjobs[].
  CALL FUNCTION '/CIDEON/REINDEX_TABLE'
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



* PERFORM make_auth_check_ws.
  CALL FUNCTION '/CIDEON/MAKE_AUTH_CHECK_WS'
       EXPORTING
            i_batch       = ''
       IMPORTING
            f_no_auth     = f_no_auth
       TABLES
            itab_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF f_no_auth = 'X'.
    EXIT.
  ELSE.
  ENDIF.

* Checken, ob alle Dateien auch ausgechecked werden können.
* DMS_MAX_TMP_FILES
*  PERFORM check_dms_max_tmp_files.
* nicht mehr von Interesse, weil Kommunikation über PlotOperator erfolgt

  CALL FUNCTION 'Z_CL_PLINT_TOOLS_CHECK_PLOTJOB'
       TABLES
            i_itab_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error           = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
    PERFORM appl_log_write USING
      sy-msgty  sy-msgno sy-msgid
       sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
*   Anmeldung an einem SMB Share
*   nicht mehr von Interesse, weil Kommunikation
*   über PlotOperator erfolgt

*    PERFORM make_send_log_entries.
    CALL FUNCTION '/CIDEON/MAKE_SEND_LOG_ENTRIES'
         EXPORTING
              i_msgid         = 'ZCL_PLINT_MESSAGE_01'
              i_msgno         = '101'
         TABLES
              i_itab_plotjobs = itab_tmp_plotjobs
         EXCEPTIONS
              error           = 1
              OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    str_down_path = i_wa_user_data-down_path.
    str_ppl_down_path = i_wa_user_data-ppl_down_path.

    IF i_wa_user_data-knz_use_post = 'X'.
*       Senden an PostProzessor   PPl-Dateien
*       keine Unterstützung für PPL mehr !!!
    ELSE.
*       Senden an PreProzessor CLF-Dateien
      LOOP AT itab_tmp_plotjobs INTO wa_tmp_plotjobs.
        REFRESH itab_tmp_plotjobs_2.
        LOOP AT itab_tmp_plotjobs INTO wa_plotjobs
          WHERE
          " voreinstellung = wa_tmp_plotjobs-voreinstellung
          verteiler = wa_tmp_plotjobs-verteiler.
          index_itab_tmp_plotjobs_2 = sy-tabix.
          APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
          DELETE itab_tmp_plotjobs INDEX index_itab_tmp_plotjobs_2.
        ENDLOOP.

        LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
          index_itab_tmp_plotjobs_2 = sy-tabix.
          wa_plotjobs-cont = index_itab_tmp_plotjobs_2.
          wa_plotjobs-status = c_status_created_plot.

          MODIFY itab_tmp_plotjobs_2 FROM wa_plotjobs
            INDEX index_itab_tmp_plotjobs_2.
        ENDLOOP.

        str_ppl_down_path = i_wa_user_data-clf_down_path.

*       PERFORM get_stamp_values.
        CALL FUNCTION '/CIDEON/GET_STAMP_DATA'
             EXPORTING
                  i_nutzer          = i_uname
                  i_default_nutzer  = i_wa_default_data-default_nutzer
             TABLES
                  i_itab_plotjobs   = itab_tmp_plotjobs_2
                  o_itab_stamp_data = itab_stempel_wert
             EXCEPTIONS
                  error             = 1
                  OTHERS            = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.


*       PERFORM get_class_data.
*       Klassendaten holen und in Stempel Tabelle einfügen
        DATA: itab_class_data TYPE TABLE OF zcl_s_stempel_value.
        DATA: wa_class_data TYPE zcl_s_stempel_value.
        DATA: wa_stempel_wert TYPE zcl_s_stempel_value..

        CLEAR itab_class_data.

        CALL FUNCTION '/CIDEON/GET_CLASS_DATA'
             EXPORTING
                  i_nutzer          = i_uname
                  i_default_nutzer  = i_wa_default_data-default_nutzer
             TABLES
                  i_itab_plotjobs   = itab_tmp_plotjobs_2
                  o_itab_class_data = itab_class_data
             EXCEPTIONS
                  error             = 1
                  OTHERS            = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*       Anhängen, dann Sortieren
        LOOP AT itab_class_data INTO wa_class_data.
          CLEAR wa_stempel_wert.
          MOVE-CORRESPONDING wa_class_data TO wa_stempel_wert.
          APPEND wa_stempel_wert TO itab_stempel_wert.
        ENDLOOP.
        SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.


*       PERFORM get_result_stamp_values.
*       Klassendaten holen und in Stempel Tabelle einfügen
        CLEAR itab_class_data.

        CALL FUNCTION '/CIDEON/GET_CLASS_DATA'
             EXPORTING
                  i_nutzer          = i_uname
                  i_default_nutzer  = i_wa_default_data-default_nutzer
             TABLES
                  i_itab_plotjobs   = itab_tmp_plotjobs_2
                  o_itab_class_data = itab_class_data
             EXCEPTIONS
                  error             = 1
                  OTHERS            = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*       Anhängen, dann Sortieren
        LOOP AT itab_class_data INTO wa_class_data.
          CLEAR wa_stempel_wert.
          MOVE-CORRESPONDING wa_class_data TO wa_stempel_wert.
          APPEND wa_stempel_wert TO itab_stempel_wert.
        ENDLOOP.
        SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.


        IF i_wa_user_data-knz_use_admin_module = 'X'.
*         auf jeden Fall Job ID erzeugen!!!
          i_wa_user_data-knz_make_id_plotjob = 'X'.
        ELSE.
        ENDIF.

        IF i_wa_user_data-knz_make_id_plotjob = 'X'.
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

*       Verarbeitung mit ADMIN Module
        IF i_wa_user_data-knz_use_admin_module = 'X'.
          CALL FUNCTION '/CIDEON/WRITE_DATA_TO_ADMIN'
               EXPORTING
                    i_wa_user_data      = i_wa_user_data
                    i_wa_default_data   = i_wa_default_data
                    i_programm          = i_programm
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

*         mit nächstem Datensatz fortfahren
          CONTINUE.
        ELSE.
        ENDIF.

*       normale Verarbeitung
        IF i_wa_user_data-knz_use_new_clf_type = 'X'.
        ELSE.
        ENDIF.

      ENDLOOP.

      COMMIT WORK AND WAIT.
      REFRESH itab_tmp_plotjobs_2.
    ENDIF.

*   MESSAGE i100(zcl_plint_message_01) WITH '' '' '' ''.
    PERFORM appl_log_write USING
      'I' '100' 'ZCL_PLINT_MESSAGE_01'
       '' '' '' ''.

    COMMIT WORK AND WAIT.

  ENDIF.


ENDFUNCTION.
