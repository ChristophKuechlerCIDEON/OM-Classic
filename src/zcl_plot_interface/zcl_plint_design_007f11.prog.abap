*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F11 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  start_konverting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_konverting.
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


ENDFORM.                    " start_konverting
*&---------------------------------------------------------------------*
*&      Form  refresh_after_converting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_after_converting.
* führt einen REFRESH nach der Konvertierung durch
* um Fehlblätter mit neu entstandenen Originalen abzugleichen
*ITAB
*  DATA: itab_tdwp TYPE TABLE OF tdwp.
  DATA: itab_data TYPE TABLE OF zcl_v_tdwp.
  DATA: itab_ret TYPE TABLE OF ddshretval.
  DATA: documentfiles TYPE TABLE OF bapi_doc_files2.
*WA
  DATA: wa_tdpw TYPE tdwp.
  DATA: wa_ret TYPE ddshretval.
  DATA: return TYPE bapiret2.
  DATA: wa_documentfiles TYPE bapi_doc_files2.
  DATA: wa_filetype TYPE tdwp.
*NORMAL
  DATA: f_found(1).
  DATA: index TYPE i.

* TEST
*  CLEAR itab_filetype.
*  CLEAR user_data-use_filter.
* TEST ENDE

* zuerst die DAPPL holen oder wiederverwenden
  IF itab_filetype[] IS INITIAL.
*   Auswahl anbieten oder erneut laden
*   oder einfach abbrechen
    IF user_data-use_filter = 'X'.
      PERFORM get_file_types.
    ELSE.
*     Selektion anbieten der DAPPL oder der verfügbaren Originale
*     neuen Selectionsdialog schreiben
      CLEAR itab_data.
      CLEAR wa_tdwp.

      SELECT * FROM tdwp INTO
        CORRESPONDING FIELDS OF TABLE itab_data.
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
           EXPORTING
                ddic_structure  = 'ZCL_V_TDWP'
                retfield        = 'DAPPL'
                window_title    = text-075
                value_org       = 'S'
                multiple_choice = 'X'
           TABLES
                value_tab       = itab_data
                return_tab      = itab_ret
           EXCEPTIONS
                parameter_error = 1
                no_values_found = 2
                OTHERS          = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      LOOP AT itab_ret INTO wa_ret.
        CLEAR wa_tdwp.
        wa_tdwp-dappl = wa_ret-fieldval.
        APPEND wa_tdwp TO itab_filetype.
      ENDLOOP.

    ENDIF.
  ELSE.

  ENDIF.

  IF itab_filetype[] IS INITIAL.
    EXIT.
  ELSE.
    SORT itab_filetype BY dappl.
    DELETE ADJACENT DUPLICATES FROM itab_filetype
      COMPARING dappl.
  ENDIF.



* alle Fehlblätter verarbeiten, die keine Datei haben
* KNZ_FEHL_BLATT gesetzt und
* WSAPPLICATION ist leer

  LOOP AT itab_plotjobs INTO wa_plotjobs
    WHERE knz_fehl_blatt = 'X'
    AND wsapplication IS initial.
    index = sy-tabix.
*   Daten für diesen Eintrag recherchieren und einsetzen
    CLEAR return.
    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_plotjobs-dokar
        documentnumber             = wa_plotjobs-doknr
        documentpart               = wa_plotjobs-doktl
        documentversion            = wa_plotjobs-dokvr
        getcomponents              = 'X'
        getactivefiles             = 'X'
      IMPORTING
        return                     = return
      TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
        documentfiles              = documentfiles
*       COMPONENTS                 =
*       CHARACTERISTICVALUES       =
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
              .

    IF return IS INITIAL.
    ELSE.
    ENDIF.

    CLEAR f_found.
    LOOP AT itab_filetype INTO wa_filetype.
      CLEAR f_found.
      LOOP AT documentfiles INTO wa_documentfiles
        WHERE wsapplication = wa_filetype-dappl.
        f_found = 'X'.
      ENDLOOP.

      IF f_found = 'X'.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    IF f_found = 'X'.
*     Fehlblatt wird ersetzt

      wa_plotjobs-checked = wa_documentfiles-checkedin.

      wa_plotjobs-filep = wa_documentfiles-docfile.
      wa_plotjobs-filename = wa_documentfiles-docfile .
      wa_plotjobs-description = wa_documentfiles-description.

      CLEAR wa_plotjobs-knz_fehl_blatt.
      CLEAR wa_plotjobs-icon_fehlblatt.

      wa_plotjobs-wsapplication = wa_documentfiles-wsapplication .
      wa_plotjobs-application_id = wa_documentfiles-application_id .
      wa_plotjobs-file_id = wa_documentfiles-file_id .
      wa_plotjobs-originaltype = wa_documentfiles-originaltype.

      wa_plotjobs-knz_use_checked_in = wa_documentfiles-checkedin.
      wa_plotjobs-storagecategory = wa_documentfiles-storagecategory.

      MODIFY itab_plotjobs FROM wa_plotjobs INDEX index.

    ELSE.
*     Fehlblatt bleibt bestehen ...
      CONTINUE.
    ENDIF.

  ENDLOOP.




ENDFORM.                    " refresh_after_converting
*
*&---------------------------------------------------------------------*
*&      Form  check_verteiler_on_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_OLD_PLOTJOBS  text
*----------------------------------------------------------------------*
FORM check_verteiler_on_update
  CHANGING wa_old_plotjobs TYPE zcl_s_plotlist.
  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
  DATA: wa_tmp_preproz_user TYPE zcl_preproz_user.

  IF wa_akt_plotjobs-uname IS INITIAL.
    SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
      WHERE uname = sy-uname
      AND status = c_status_aktiv
      .
    IF sy-subrc NE 0.
     SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_data-default_nutzer.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD sy-uname.
    ENDIF.
  ELSE.
    SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
      WHERE uname = wa_akt_plotjobs-uname
      AND status = c_status_aktiv
      .
    IF sy-subrc NE 0.
     SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_data-default_nutzer.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD wa_akt_plotjobs-uname.
    ENDIF.
  ENDIF.

* ZCL_V_PRE_US_VER
  DATA: itab_data TYPE TABLE OF zcl_v_pre_us_ver.
  DATA: wa_data TYPE zcl_v_pre_us_ver.
  DATA: itab_ret TYPE TABLE OF ddshretval.
  DATA: wa_ret TYPE ddshretval.
  DATA: tmp_get_uname TYPE xubname.

  CLEAR tmp_get_uname.
  GET PARAMETER ID 'ZCL_UNAME_GET' FIELD tmp_get_uname.

  SELECT * FROM zcl_v_pre_us_ver INTO TABLE itab_data
    WHERE uname = tmp_get_uname
    .
  IF sy-subrc NE 0.
*   alten Verteiler setzen
    wa_akt_plotjobs-verteiler = wa_old_plotjobs-verteiler.
    EXIT.
  ELSE.
  ENDIF.

* Test, ob Verteiler in Tabelle enthalten ist
  DATA: f_found(1).
  CLEAR f_found.

  LOOP AT itab_data INTO wa_data.
    IF wa_data-verteiler = wa_akt_plotjobs-verteiler.
      f_found = 'X'.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.

  IF f_found = 'X'.
*   alles ok
    EXIT.
  ELSE.
    wa_akt_plotjobs-verteiler = wa_old_plotjobs-verteiler.
  ENDIF.

ENDFORM.                    " check_verteiler_on_update

*&---------------------------------------------------------------------*
*&      Form  check_dms_max_tmp_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_dms_max_tmp_files.
* Testen auf DMS_MAX_TMP_FILES
* ist die Anzahl der selektierten Einträge größer als die in
* DMS_MAX_TMP_FILES angegebenen, dann Hinweis

  DATA: anzahl_zeilen TYPE i.

  IF g_dms_max_tmp_files IS INITIAL.
*   dann Standardwert setzen
    g_dms_max_tmp_files = 20.

*   alles in Ordnung
*    EXIT.
  ELSE.
  ENDIF.

*itab_tmp_plotjobs
  DESCRIBE TABLE itab_tmp_plotjobs LINES anzahl_zeilen.

  IF anzahl_zeilen > g_dms_max_tmp_files.
    MESSAGE i110(zcl_plint_message_01)
      WITH  anzahl_zeilen g_dms_max_tmp_files.
*   Anzahl Dateien & > Parameter DMS_MAX_TMP_FILES &. SAP Basis verständ

*   Abfrage, ob der Job abgebrochen werden soll
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar                    = text-081
*       DIAGNOSE_OBJECT             = ' '
        text_question               = text-080
*       TEXT_BUTTON_1               = 'Ja'(001)
*       ICON_BUTTON_1               = ' '
*       TEXT_BUTTON_2               = 'Nein'(002)
*       ICON_BUTTON_2               = ' '
*       DEFAULT_BUTTON              = '1'
        display_cancel_button       = ''
*       USERDEFINED_F1_HELP         = ' '
*       START_COLUMN                = 25
*       START_ROW                   = 6
*       POPUP_TYPE                  =
      IMPORTING
        answer                      = f_cancel_send
*     TABLES
*       PARAMETER                   =
      EXCEPTIONS
        text_not_found              = 1
        OTHERS                      = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.

    ENDIF.

    IF f_cancel_send = '1'.
      f_cancel_send = 'X'.
    ELSE.
      CLEAR f_cancel_send.
    ENDIF.

  ELSE.
  ENDIF.

ENDFORM.                    " check_dms_max_tmp_files
*&---------------------------------------------------------------------*
*&      Form  get_relation_drawing_model
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_relation_drawing_model.
* Inhaltsverzeichnis Zeichung/Modell erstellen

  SUBMIT /cideon/modell_in_zeichnung_03
    AND RETURN.

ENDFORM.                    " get_relation_drawing_model
*&---------------------------------------------------------------------*
*&      Form  read_stored_search_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_stored_search_2.
  CALL FUNCTION '/CIDEON/READ_STORED_SEARCH'
       EXPORTING
            i_wa_user_data    = user_data
            i_wa_default_data = default_data
       TABLES
            itab_search       = itab_search
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


* F_DYN_TOC lesen und global setzen
  LOOP AT itab_search INTO wa_search
    WHERE f_dyn_toc = '1'.
  ENDLOOP.
  IF sy-subrc NE 0.
    CLEAR f_dyn_toc.
  ELSE.
    f_dyn_toc = '1'.
  ENDIF.

  LOOP AT itab_search INTO wa_search
    WHERE f_dyn_cov = '1'.
  ENDLOOP.
  IF sy-subrc NE 0.
    CLEAR f_dyn_cov.
  ELSE.
    f_dyn_cov = '1'.
  ENDIF.

ENDFORM.                    " read_stored_search_2
