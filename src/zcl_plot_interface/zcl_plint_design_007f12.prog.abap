*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F12 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_dok_text_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_dok_text_2.
  CALL FUNCTION '/CIDEON/GET_DOK_TEXT'
       TABLES
            itab_search = itab_search
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " get_dok_text_2
*&---------------------------------------------------------------------*
*&      Form  get_matnr_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_matnr_2.
  CALL FUNCTION '/CIDEON/GET_MATNR'
       EXPORTING
            i_wa_user_data = user_data
       TABLES
            itab_search    = itab_search
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " get_matnr_2
*&---------------------------------------------------------------------*
*&      Form  make_knz_freigabe_led_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_knz_freigabe_led_2.
  CALL FUNCTION '/CIDEON/MAKE_KNZ_FREIGABE_LED'
       TABLES
            itab_search = itab_search
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " make_knz_freigabe_led_2
*&---------------------------------------------------------------------*
*&      Form  make_mat_status_icon_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_mat_status_icon_2.
  CALL FUNCTION '/CIDEON/MAKE_MAT_STATUS_ICON'
       EXPORTING
            i_wa_user_data      = user_data
       TABLES
            itab_search         = itab_search
            itab_mat_status_exc = itab_mat_status_exc
       EXCEPTIONS
            error               = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " make_mat_status_icon_2
*&---------------------------------------------------------------------*
*&      Form  proc_mat_status_exc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proc_mat_status_exc.
  CALL FUNCTION '/CIDEON/PROC_MAT_STATUS_EXC'
       EXPORTING
            i_wa_user_data      = user_data
       TABLES
            itab_mat_status_exc = itab_mat_status_exc
       EXCEPTIONS
            error               = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " proc_mat_status_exc
*&---------------------------------------------------------------------*
*&      Form  make_display_icon_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_display_icon_2.
  CALL FUNCTION '/CIDEON/MAKE_DISPLAY_ICON'
       TABLES
            itab_search = itab_search
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " make_display_icon_2
*&---------------------------------------------------------------------*
*&      Form  clean_up_documents_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clean_up_documents_3.
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

ENDFORM.                    " clean_up_documents_3
*&---------------------------------------------------------------------*
*&      Form  get_file_types_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file_types_2.
  CALL FUNCTION '/CIDEON/GET_FILE_TYPES'
       EXPORTING
            i_wa_default_data   = default_data
            i_wa_user_data      = user_data
            i_uname             = sy-uname
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

ENDFORM.                    " get_file_types_2
*&---------------------------------------------------------------------*
*&      Form  map_information_fauf_cs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM map_information_fauf_cs.
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

ENDFORM.                    " map_information_fauf_cs
*&---------------------------------------------------------------------*
*&      Form  check_priorities_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_priorities_2.
  CALL FUNCTION '/CIDEON/CHECK_PRIORITIES'
       EXPORTING
            i_wa_user_data    = user_data
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " check_priorities_2
*&---------------------------------------------------------------------*
*&      Form  get_dok_status_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_dok_status_2.
  CALL FUNCTION '/CIDEON/GET_DOK_STATUS'
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
            itab_search       = itab_search
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " get_dok_status_2
*&---------------------------------------------------------------------*
*&      Form  reindex_table_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reindex_table_3.
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

ENDFORM.                    " reindex_table_3
*&---------------------------------------------------------------------*
*&      Form  add_objectkey_to_plotlist_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_objectkey_to_plotlist_2.
  CALL FUNCTION '/CIDEON/ADD_OBJECTKEY_TO_PLOTL'
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " add_objectkey_to_plotlist_2
*&---------------------------------------------------------------------*
*&      Form  check_for_multipage_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_multipage_2.
  CALL FUNCTION '/CIDEON/CHECK_FOR_MULTIPAGE'
       TABLES
            itab_tmp_plotjobs = itab_tmp_plotjobs
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " check_for_multipage_2
*&---------------------------------------------------------------------*
*&      Form  add_to_plotlist_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0297   text
*----------------------------------------------------------------------*
FORM add_to_plotlist_2 USING p_knz_fehl_blatt.
  CALL FUNCTION '/CIDEON/ADD_TO_PLOTLIST'
       EXPORTING
            p_knz_fehl_blatt           = p_knz_fehl_blatt
            i_wa_user_data             = user_data
            i_wa_default_data          = default_data
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

ENDFORM.                    " add_to_plotlist_2
*&---------------------------------------------------------------------*
*&      Form  check_exist_files_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_exist_files_2.
  CALL FUNCTION '/CIDEON/CHECK_EXIST_FILES'
       EXPORTING
            i_wa_user_data = user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " check_exist_files_2
*&---------------------------------------------------------------------*
*&      Form  set_knz_use_checked_in_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_knz_use_checked_in_2.
  CALL FUNCTION '/CIDEON/SET_KNZ_USE_CHECKED_IN'
       EXPORTING
            i_wa_user_data = user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " set_knz_use_checked_in_2
*&---------------------------------------------------------------------*
*&      Form  add_client_data_4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_client_data_4.
  CALL FUNCTION '/CIDEON/ADD_CLIENT_DATA_3'
       EXPORTING
            i_batch       = ''
            i_user        = ''
       IMPORTING
            o_g_dms_max_tmp_files = g_dms_max_tmp_files
       TABLES
            itab_plotjobs = itab_plotjobs
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " add_client_data_4
*&---------------------------------------------------------------------*
*&      Form  add_cost_center_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cost_center_3.
  CALL FUNCTION '/CIDEON/ADD_COST_CENTER_2'
       EXPORTING
            i_wa_user_data = user_data
       TABLES
            itab_plotjobs  = itab_plotjobs
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " add_cost_center_3
*&---------------------------------------------------------------------*
*&      Form  editor_suchliste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM editor_suchliste.
* Suchliste per Editor aufrufen

*  EDITOR-CALL FOR itab_search.

ENDFORM.                    " editor_suchliste
*&---------------------------------------------------------------------*
*&      Form  start_zkonverting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_zkonverting.
* Start der Konvertierung für einen ausgewählten DIS
* je nachdem, was für eine Konvertierung für diesen Status verfügbar
* ist.* ...

* NORMAL
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.
  DATA: ausgabe_progress TYPE char100.


* neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTVB'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

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

  CLEAR ausgabe_progress.

  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.

    SUBMIT conv_convert_document
      WITH dokar EQ wa_plotjobs-dokar
      WITH doknr EQ wa_plotjobs-doknr
      WITH doktl EQ wa_plotjobs-doktl
      WITH dokvr EQ wa_plotjobs-dokvr
      WITH dokst EQ wa_plotjobs-dokst
      VIA SELECTION-SCREEN
      AND RETURN
      .

*    SET PARAMETER ID 'CV1' FIELD wa_plotjobs-doknr.
*    SET PARAMETER ID 'CV2' FIELD wa_plotjobs-dokar.
*    SET PARAMETER ID 'CV4' FIELD wa_plotjobs-doktl.
*    SET PARAMETER ID 'CV3' FIELD wa_plotjobs-dokvr.
*    CALL TRANSACTION 'ZCONV02'.

    IF akt_dec <> last_dec.
      prozent = akt_dec * 100.
      CLEAR  ausgabe_progress.
      CONCATENATE text-155 wa_plotjobs-dokar '/' wa_plotjobs-doknr
        '/' wa_plotjobs-doktl '/' wa_plotjobs-dokvr '/'
        wa_plotjobs-dokst
        INTO ausgabe_progress.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = prozent
                text       = ausgabe_progress.
    ELSE.
    ENDIF.
    last = akt.
    last_dec = akt_dec.

  ENDLOOP.

ENDFORM.                    " start_zkonverting
