*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TO_JOBLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM to_joblist.
* zur Plottinglist springen / übernehmen
  PERFORM get_selected_line_search_list.
*     call Sri
  REFRESH itab_zori_doc_files.
  REFRESH itab_zori_doc_files_detail.
  REFRESH itab_fail_document.

  CLEAR itab_filetype.

* check for allowed Documents
  "PERFORM clean_up_documents_2.
  PERFORM clean_up_documents_3.

  IF itab_search_tmp[] IS INITIAL.
    MESSAGE w005(/cideon/druck_basis)
      WITH '' '' '' ''.
    EXIT.
  ELSE.
  ENDIF.


* get the allowed filetypes for this special user
  IF user_data-use_filter = 'X'.
    "PERFORM get_file_types.
    PERFORM get_file_types_2.
  ELSE.
  ENDIF.


  PERFORM search_tmp_to_draw.

*     2003_01_17 Begin
  DATA: itab_draw_2 TYPE TABLE OF draw.
  DATA: wa_draw_2 TYPE draw.
  DATA: itab_zori_doc_files_3 TYPE TABLE OF zori_doc_files.
  DATA: itab_zori_doc_files_detail_3 TYPE TABLE OF bapi_doc_files2.
  DATA: itab_fail_document_3 TYPE TABLE OF zcl_s_fail_document.
  DATA: index_itab_draw_2 TYPE sy-tabix.

  REFRESH itab_draw_2.
  REFRESH itab_zori_doc_files_3.
  REFRESH itab_zori_doc_files_detail_3.
  REFRESH itab_fail_document_3.

  itab_draw_2[] = itab_draw[].

* Übernahme von Dateien nach Prioritäten der WSA
  DATA: lt_wsa_prio TYPE TABLE OF dappl.
  DATA: lc_wsa_prio TYPE dappl.

  CLEAR lt_wsa_prio.
  SPLIT user_data-prio_wsa_to_plotlist AT ','
    INTO TABLE lt_wsa_prio.
* falls automatischer Durchlauf, dann die Nachfrage im Dialog
* ausschalten
  IF f_bypass = 'X'.
    IF user_data-knz_wsa_to_plotlist = 'A'.
      user_data-knz_wsa_to_plotlist = 'P'.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


  LOOP AT itab_draw_2 INTO wa_draw_2.
    index_itab_draw_2 = sy-tabix.

    REFRESH itab_draw.
    APPEND wa_draw_2 TO itab_draw.

    REFRESH itab_zori_doc_files.
    REFRESH itab_zori_doc_files_detail.
    REFRESH itab_fail_document.

*   Sondereinträge verarbeiten
    READ TABLE itab_search_tmp INTO wa_search_tmp
      INDEX index_itab_draw_2.
    IF wa_search_tmp-knz_spez_dok = 'X'.
*         ITAB_ZORI_* manipulieren
      CLEAR wa_zori_doc_files.
      MOVE-CORRESPONDING wa_search_tmp TO wa_zori_doc_files.
      wa_zori_doc_files-cont = 1.
      "concatenate 'c:\' text-F01 into wa_zori_doc_files-filep.
      CONCATENATE 'c:\' wa_search_tmp-object_type INTO
         wa_zori_doc_files-filep.

      CLEAR wa_zori_doc_files_detail.
      wa_zori_doc_files_detail-documenttype = wa_search_tmp-dokar.
      wa_zori_doc_files_detail-documentnumber = wa_search_tmp-doknr
.
      wa_zori_doc_files_detail-documentpart = wa_search-doktl.
      wa_zori_doc_files_detail-documentversion = wa_search-dokvr.

      APPEND wa_zori_doc_files TO itab_zori_doc_files.
      APPEND wa_zori_doc_files_detail TO itab_zori_doc_files_detail
.


      LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
        APPEND wa_zori_doc_files TO itab_zori_doc_files_3.
      ENDLOOP.
      LOOP AT itab_zori_doc_files_detail
        INTO wa_zori_doc_files_detail.
        APPEND wa_zori_doc_files_detail
          TO itab_zori_doc_files_detail_3.
      ENDLOOP.
      LOOP AT itab_fail_document INTO wa_fail_document.
        APPEND wa_fail_document TO itab_fail_document_3.
      ENDLOOP.

      CONTINUE.
    ELSE.
    ENDIF.


    CALL FUNCTION 'Z_DMS_PROC_DOC_FILES'
     EXPORTING
*         CALLED_FROM              =
       testmode                 = ''
     TABLES
       it_zori_doc_files        = itab_zori_doc_files
       it_bapi_doc_files2       = itab_zori_doc_files_detail
       tdraw                    = itab_draw
       itab_filetype            = itab_filetype
       it_fail_document         = itab_fail_document
     EXCEPTIONS
       error   = 1
       abort   = 2
       OTHERS  = 3
              .
    IF sy-subrc NE 0.
      IF sy-subrc = 2.
        REFRESH itab_zori_doc_files_3.
        REFRESH itab_zori_doc_files_detail_3.
        REFRESH itab_fail_document_3.
        EXIT.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.

*   Überarbeitung der Tabellen auf Priorität der WSA
*   falls mehrere WSA am gleichen DIS, dann nur die erste nehmen
*   Check auf Dateinamen - KNZ_WSA_TO_PLOTLIST_CHECK_FILE
*

    CASE user_data-knz_wsa_to_plotlist.
      WHEN 'I'.
        "keine Aktion
      WHEN 'A'.
      WHEN 'P'.
        "nach Priorität verarbeiten
        DATA: line TYPE i.
        DESCRIBE TABLE itab_zori_doc_files LINES line.
        IF line > '1'.
          IF user_data-knz_wsa_to_plotlist_check_file = 'X'.
            "Dateinamen beachten
            DATA: wa_zori_doc_files_tmp TYPE zori_doc_files.
            LOOP AT lt_wsa_prio INTO lc_wsa_prio.
              LOOP AT itab_zori_doc_files INTO wa_zori_doc_files
                WHERE wsapplication = lc_wsa_prio.

                DATA: pf_path TYPE filep.
                DATA: pf_file TYPE filep.
                DATA: pfx_path TYPE filep.
                DATA: pfx_file TYPE filep.

                CLEAR pf_path.
                CLEAR pfx_path.
                CLEAR pfx_file.

                pf_path = wa_zori_doc_files-filep.
                CALL FUNCTION 'CV120_SPLIT_PATH'
                     EXPORTING
                          pf_path  = pf_path
                     IMPORTING
                          pfx_path = pfx_path
                          pfx_file = pfx_file.

                pf_file = pfx_file.
                CALL FUNCTION 'CV120_SPLIT_FILE'
                  EXPORTING
                    pf_file                = pf_file
                  IMPORTING
                    pfx_file               = pfx_file
*                    PFX_EXTENSION          =
*                    PFX_DOTEXTENSION       =
                          .
                DATA: check_filename TYPE filep.
                CLEAR check_filename.
                check_filename = pfx_file.

                DATA: index TYPE i.
                LOOP AT itab_zori_doc_files INTO wa_zori_doc_files_tmp.
                  index = sy-tabix.
                  IF wa_zori_doc_files_tmp-filep =
                    wa_zori_doc_files-filep.
                    CONTINUE.
                  ELSE.
                  ENDIF.

                  CLEAR pf_path.
                  CLEAR pfx_path.
                  CLEAR pfx_file.

                  pf_path = wa_zori_doc_files_tmp-filep.
                  CALL FUNCTION 'CV120_SPLIT_PATH'
                       EXPORTING
                            pf_path  = pf_path
                       IMPORTING
                            pfx_path = pfx_path
                            pfx_file = pfx_file.

                  pf_file = pfx_file.
                  CALL FUNCTION 'CV120_SPLIT_FILE'
                    EXPORTING
                      pf_file                = pf_file
                    IMPORTING
                      pfx_file               = pfx_file
*                    PFX_EXTENSION          =
*                    PFX_DOTEXTENSION       =
                            .
                  IF check_filename = pfx_file.
                    DELETE itab_zori_doc_files INDEX index.
                    DELETE itab_zori_doc_files_detail INDEX index.
                  ELSE.
                  ENDIF.
                ENDLOOP.
              ENDLOOP.
            ENDLOOP.
          ELSE.
            "nur Prio beachten
            LOOP AT lt_wsa_prio INTO lc_wsa_prio.
              LOOP AT itab_zori_doc_files INTO wa_zori_doc_files
                WHERE wsapplication = lc_wsa_prio.
              ENDLOOP.
              IF sy-subrc NE 0.
              ELSE.
                "etwas gefunden
                LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
                  IF wa_zori_doc_files-wsapplication = lc_wsa_prio.
                  ELSE.
                    DELETE itab_zori_doc_files INDEX sy-tabix.
                    DELETE itab_zori_doc_files_detail INDEX sy-tabix.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
        ENDIF.
*        LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
*        ENDLOOP.
      WHEN OTHERS.
        "ignorieren
    ENDCASE.




*   normale Weitergabe von Informationen speziellen Felder des
*   Fertigungsauftrages / CS Auftrages
    PERFORM map_information_fauf_cs.
*   Verarbeitung von Fehldokumenten
    PERFORM map_information_fauf_cs_f.


    LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
      APPEND wa_zori_doc_files TO itab_zori_doc_files_3.
    ENDLOOP.
    LOOP AT itab_zori_doc_files_detail
      INTO wa_zori_doc_files_detail.
      APPEND wa_zori_doc_files_detail
        TO itab_zori_doc_files_detail_3.
    ENDLOOP.
    LOOP AT itab_fail_document INTO wa_fail_document.
      APPEND wa_fail_document TO itab_fail_document_3.
    ENDLOOP.

  ENDLOOP.

  itab_draw[] = itab_draw_2[].
  itab_zori_doc_files[] = itab_zori_doc_files_3[].
  itab_zori_doc_files_detail[] = itab_zori_doc_files_detail_3[].
  itab_fail_document[] = itab_fail_document_3[].
*     2003_01_17 Ende

  PERFORM draw_to_search_tmp.

* checks if there are any entries available
  DESCRIBE TABLE itab_zori_doc_files LINES count_lines.
  IF count_lines > 0.
*    PERFORM add_to_plotlist USING ''.

*   Anzeige zur Übernahme
    CASE user_data-knz_wsa_to_plotlist.
      WHEN 'A'.
        CALL FUNCTION '/CIDEON/ASK_AT_TO_PLOTLIST'
             TABLES
                  lt_files        = itab_zori_doc_files
                  lt_files_detail = itab_zori_doc_files_detail
             EXCEPTIONS
                  error           = 1
                  OTHERS          = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

    ENDCASE.

    PERFORM add_to_plotlist_2 USING ''.
    PERFORM refresh_joblist.
    PERFORM rebuild_tree_plotlist.
    PERFORM clear_plot_details.
  ELSE.
    tabstripcontrol_001-activetab = 'TAB1'.
    IF itab_fail_document[] IS INITIAL.
      MESSAGE i011(zcl_plint_message_01)
        WITH '' '' '' ''.
    ELSE.
    ENDIF.
  ENDIF.

* checks if there are entries in the fail_doc available
  IF itab_fail_document[] IS INITIAL.
  ELSE.
*       checks what for a strategy shold be used
*       ask, ignore, list, failure document
    CASE user_data-strategy.
      WHEN 'I'. "Ignore
        REFRESH itab_fail_document.
        IF count_lines = 0.
          MESSAGE i011(zcl_plint_message_01)
            WITH '' '' '' ''.
          tabstripcontrol_001-activetab = 'TAB1'.
        ENDIF.
      WHEN 'A'. "Ask
        MESSAGE i200(zcl_plint_message_01)
          WITH '' '' '' ''.
        PERFORM process_strategy_a.
      WHEN 'F'. "Fail document
        PERFORM create_fail_items.
      WHEN 'L'. "List
        MESSAGE i201(zcl_plint_message_01)
          WITH '' '' '' ''.
        PERFORM process_strategy_l.
        REFRESH itab_fail_document.
      WHEN OTHERS. "then ignore
        REFRESH itab_fail_document.
    ENDCASE.
  ENDIF.

* check for not existing files
  "PERFORM check_exist_files.
  PERFORM check_exist_files_2.

  "PERFORM set_knz_use_checked_in.
  PERFORM set_knz_use_checked_in_2.

  PERFORM reindex_table_2.
  PERFORM refresh_joblist.
  PERFORM rebuild_tree_plotlist.

* Kundendaten anfügen
  "PERFORM add_client_data_3.
  PERFORM add_client_data_4.
* Kostenstelle einfügen
  "PERFORM add_cost_center_2.
  PERFORM add_cost_center_3.

  PERFORM clear_plot_details.

ENDFORM.                    " TO_JOBLIST
*&---------------------------------------------------------------------*
*&      Form  SEL_ALL_SERACH_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_all_search_list.
* alles in Suchliste selektieren
  DATA: count_lines_suchliste TYPE i.

  REFRESH itab_et_index_rows_searchlist.
  DESCRIBE TABLE itab_search LINES count_lines_suchliste.

  DO count_lines_suchliste TIMES.
    wa_et_index_rows_searchlist-index = sy-index.
    APPEND wa_et_index_rows_searchlist TO
      itab_et_index_rows_searchlist.
  ENDDO.



  CALL METHOD grid_searchlist->set_selected_rows
     EXPORTING
       it_index_rows = itab_et_index_rows_searchlist
*      IT_ROW_NO     =
      .



ENDFORM.                    " SEL_ALL_SERACH_LIST
*&---------------------------------------------------------------------*
*&      Form  sel_all_plot_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_all_plot_list.
* alles in Plotliste selektieren
  DATA: count_lines_plotliste TYPE i.

  REFRESH itab_et_index_rows_plotlist.
  DESCRIBE TABLE itab_plotjobs LINES count_lines_plotliste.

  DO count_lines_plotliste TIMES.
    wa_et_index_rows_plotlist-index = sy-index.
    APPEND wa_et_index_rows_plotlist TO
      itab_et_index_rows_plotlist.
  ENDDO.



  CALL METHOD grid_plotlist->set_selected_rows
     EXPORTING
       it_index_rows = itab_et_index_rows_plotlist
*      IT_ROW_NO     =
      .


ENDFORM.                    " sel_all_plot_list
