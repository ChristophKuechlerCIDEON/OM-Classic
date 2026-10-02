FUNCTION /cideon/to_joblist_batch .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"     VALUE(I_UNAME) TYPE  BUNAME
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
* 05.07.2004 - Erstellung
*-----------------------------------------------------------------------

*TYPES
*ITAB
  DATA: itab_plotjobs TYPE TABLE OF zcl_s_plotlist.
  DATA: itab_tmp_plotjobs TYPE TABLE OF zcl_s_plotlist.
  DATA: itab_search_tmp TYPE TABLE OF zcl_s_docsearch.
  DATA: itab_zori_doc_files TYPE TABLE OF zori_doc_files.
  DATA: itab_zori_doc_files_detail TYPE TABLE OF bapi_doc_files2.
  DATA: itab_fail_document TYPE TABLE OF zcl_s_fail_document.
  DATA: itab_plint_usr_tdwp TYPE TABLE OF zplint_usr_tdwp.
  DATA: itab_filetype TYPE TABLE OF tdwp.
  DATA: itab_draw TYPE TABLE OF draw.
*WA
  DATA: wa_plotjobs TYPE zcl_s_plotlist.
  DATA: wa_search TYPE zcl_s_docsearch.
  DATA: wa_search_tmp LIKE zcl_s_docsearch. "draw.
  DATA: wa_draw TYPE draw.
  DATA: wa_zori_doc_files TYPE zori_doc_files.
  DATA: wa_zori_doc_files_detail TYPE bapi_doc_files2.
  DATA: wa_fail_document TYPE zcl_s_fail_document.
*NORMAL
  DATA: numc(15) TYPE n.
  DATA: count_lines TYPE i .

* alles aus der Suchliste wird übernommen
  CLEAR itab_search_tmp.
  itab_search_tmp[] = itab_search[].

  LOOP AT itab_search_tmp INTO wa_search.
    IF wa_search-doknr CN '0123456789'.
    ELSE.
      numc = wa_search-doknr.
      wa_search-doknr = numc.
    ENDIF.
    MODIFY itab_search_tmp FROM wa_search INDEX sy-tabix.
  ENDLOOP.

* call Sri
  REFRESH itab_zori_doc_files.
  REFRESH itab_zori_doc_files_detail.
  REFRESH itab_fail_document.


* check for allowed Documents
  CALL FUNCTION '/CIDEON/CLEAN_UP_DOCUMENTS_2'
       EXPORTING
            i_wa_default_data = i_wa_default_data
            i_wa_user_data    = i_wa_user_data
            i_batch           = 'X'
       TABLES
            itab_search_tmp   = itab_search_tmp
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF itab_search_tmp[] IS INITIAL.
    ROLLBACK WORK.
    CLEAR text1.
    CLEAR text2.
    CLEAR text3.
    CLEAR text4.
    CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
         EXPORTING
              i_object   = 'Z_CIDEON'
              i_subobj   = 'Z_PLOT'
              i_number   = 101
              i_msgtyp   = 'W'
              i_msgid    = '/cideon/druck_basis'
              i_msgno    = 005
              i_msgv1    = text1
              i_msgv2    = text2
              i_msgv3    = text3
              i_msgv4    = text4
              i_class    = ' '
              i_newhead  = 'X'
              i_messhead = 'X'
         EXCEPTIONS
              error      = 1
              OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    COMMIT WORK AND WAIT.
    MESSAGE w005(/cideon/druck_basis)
      WITH '' '' '' ''.
    EXIT.
  ELSE.
  ENDIF.


* get the allowed filetypes for this special user
  IF i_wa_user_data-use_filter = 'X'.
    CALL FUNCTION '/CIDEON/GET_FILE_TYPES'
         EXPORTING
              i_wa_default_data   = i_wa_default_data
              i_wa_user_data      = i_wa_user_data
              i_uname             = i_uname
         TABLES
              itab_plint_usr_tdwp = itab_plint_usr_tdwp
              itab_filetype       = itab_filetype
         EXCEPTIONS
              error               = 1
              OTHERS              = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.

* from itab_search_tmp to itab_draw
  REFRESH itab_draw.

  LOOP AT itab_search_tmp INTO wa_search_tmp.
    MOVE-CORRESPONDING wa_search_tmp TO wa_draw.
    APPEND wa_draw TO itab_draw.
  ENDLOOP.


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


*   normale Weitergabe von Informationen speziellen Felder des
*   Fertigungsauftrages / CS Auftrages
    CALL FUNCTION '/CIDEON/MAP_INFORMATION'
         EXPORTING
              wa_search_tmp       = wa_search_tmp
         TABLES
              itab_zori_doc_files = itab_zori_doc_files
         EXCEPTIONS
              error               = 1
              OTHERS              = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


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


*  PERFORM draw_to_search_tmp.
* from itab_search to Itab_search_tmp
  REFRESH itab_search_tmp.
  CLEAR wa_search_tmp.
  LOOP AT itab_draw INTO wa_draw.
    MOVE-CORRESPONDING wa_draw TO wa_search_tmp.
    APPEND wa_search_tmp TO itab_search_tmp.
  ENDLOOP.


  DESCRIBE TABLE itab_zori_doc_files LINES count_lines.
  IF count_lines > 0.
*    PERFORM add_to_plotlist USING ''.
    CALL FUNCTION '/CIDEON/ADD_TO_PLOTLIST'
         EXPORTING
              p_knz_fehl_blatt           = ''
              i_wa_user_data             = i_wa_user_data
              i_wa_default_data          = i_wa_default_data
         TABLES
              itab_tmp_plotjobs          = itab_tmp_plotjobs
              itab_zori_doc_files        = itab_zori_doc_files
              itab_plotjobs              = itab_plotjobs
              itab_zori_doc_files_detail = itab_zori_doc_files_detail
              itab_search                = itab_search
         EXCEPTIONS
              error                      = 1
              OTHERS                     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*    PERFORM refresh_joblist.
*    PERFORM rebuild_tree_plotlist.
*    PERFORM clear_plot_details.
  ELSE.
    IF itab_fail_document[] IS INITIAL.
*      MESSAGE i011(zcl_plint_message_01)
*        WITH '' '' '' ''.
      PERFORM appl_log_write USING
        'I' '011' 'ZCL_PLINT_MESSAGE_01'
         '' '' '' ''.
    ELSE.
    ENDIF.
  ENDIF.
* checks if there are entries in the fail_doc available
  IF itab_fail_document[] IS INITIAL.
  ELSE.
*       checks what for a strategy shold be used
*       ask, ignore, list, failure document
*   quasi alles auf Fehlblatt umgestellt
    CASE i_wa_user_data-strategy.
      WHEN 'I'. "Ignore
        REFRESH itab_fail_document.
        IF count_lines = 0.
*          MESSAGE i011(zcl_plint_message_01)
*            WITH '' '' '' ''.
          PERFORM appl_log_write USING
            'I' '011' 'ZCL_PLINT_MESSAGE_01'
             '' '' '' ''.
        ENDIF.
      WHEN 'F' OR 'A' OR 'L'. "Fail document
*       PERFORM create_fail_items.
*       creates fail items for the fail documents
        REFRESH itab_zori_doc_files.
        REFRESH itab_zori_doc_files_detail.

        LOOP AT itab_fail_document INTO wa_fail_document.
          CLEAR wa_zori_doc_files.
          CLEAR wa_zori_doc_files_detail.

          MOVE-CORRESPONDING wa_fail_document TO wa_zori_doc_files.
          MOVE-CORRESPONDING wa_fail_document
            TO wa_zori_doc_files_detail.
*         Dateiname
          IF wa_zori_doc_files-filep IS INITIAL.
            CONCATENATE wa_zori_doc_files-dokar '/'
              wa_zori_doc_files-doknr
              '/' wa_zori_doc_files-dokvr '/' wa_zori_doc_files-doktl
              INTO wa_zori_doc_files-filep.
          ELSE.
          ENDIF.

          APPEND wa_zori_doc_files TO itab_zori_doc_files.
          APPEND wa_zori_doc_files_detail TO itab_zori_doc_files_detail.
        ENDLOOP.

      WHEN OTHERS. "then ignore
        REFRESH itab_fail_document.
    ENDCASE.
  ENDIF.

* Daten in ITAB_PLOTJOBS verarbeiten
* check for not existing files
* PERFORM check_exist_files.
  CALL FUNCTION '/CIDEON/CHECK_EXIST_FILES'
       EXPORTING
            i_wa_user_data = i_wa_user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  PERFORM set_knz_use_checked_in.
  CALL FUNCTION '/CIDEON/SET_KNZ_USE_CHECKED_IN'
       EXPORTING
            i_wa_user_data = i_wa_user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*  PERFORM reindex_table_2.
  LOOP AT itab_plotjobs INTO wa_plotjobs.
    wa_plotjobs-cont = sy-tabix.
    MODIFY itab_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

* GUI Refresh ist hier nicht notwendig
* Neuaufbau des Baums ist auch nicht notwendig
  "PERFORM refresh_joblist.
  "PERFORM rebuild_tree_plotlist.

* Kundendaten anfügen
  "PERFORM add_client_data_3.
  CALL FUNCTION '/CIDEON/ADD_CLIENT_DATA_3'
       EXPORTING
            i_batch               = 'X'
            i_user                = i_uname
       IMPORTING
            o_g_dms_max_tmp_files = g_dms_max_tmp_files
       TABLES
            itab_plotjobs         = itab_plotjobs
       EXCEPTIONS
            error                 = 1
            OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Kostenstelle einfügen
  "PERFORM add_cost_center_2.
  CALL FUNCTION '/CIDEON/ADD_COST_CENTER_2'
       EXPORTING
            i_wa_user_data = i_wa_user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  "PERFORM clear_plot_details.



ENDFUNCTION.
