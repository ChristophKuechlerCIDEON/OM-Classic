*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F14 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  start_conversion_by_rule
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_conversion_by_rule.
* NORMAL
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.
  DATA: ausgabe_progress TYPE char100.

  DATA: converter_spec_name TYPE converter_spec_name.

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

* Konvertierungsregel abfragen
  CALL FUNCTION '/CIDEON/ASK_CONVERSION_RULE'
       IMPORTING
            o_conv_rule = converter_spec_name
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

*    SUBMIT conv_convert_document
*      WITH dokar EQ wa_plotjobs-dokar
*      WITH doknr EQ wa_plotjobs-doknr
*      WITH doktl EQ wa_plotjobs-doktl
*      WITH dokvr EQ wa_plotjobs-dokvr
*      WITH dokst EQ wa_plotjobs-dokst
*      AND RETURN
*      .

*    SET PARAMETER ID 'CV1' FIELD wa_plotjobs-doknr.
*    SET PARAMETER ID 'CV2' FIELD wa_plotjobs-dokar.
*    SET PARAMETER ID 'CV4' FIELD wa_plotjobs-doktl.
*    SET PARAMETER ID 'CV3' FIELD wa_plotjobs-dokvr.
*    CALL TRANSACTION 'ZCONV02' AND SKIP FIRST SCREEN.

    DATA: error_message TYPE messages.
    CLEAR error_message.
    CALL FUNCTION 'CONVT_CONVERT_AT_STATUS_CHANGE'
      EXPORTING
        documenttype               = wa_plotjobs-dokar
        documentnumber             = wa_plotjobs-doknr
*   DOCUMENTNUMBER_EXT         = wa_plotjobs-doknr
        documentpart               = wa_plotjobs-doktl
        documentversion            = wa_plotjobs-dokvr
*   DOCUMENTSTATUS_EXT         =
*   DOCUMENTSTATUS             =
*   PF_BATCH                   =
*   CHECK_DOCUMENT_EXIST       =
        use_documentfiles          = ''
        convert_spec_name          = converter_spec_name
  IMPORTING
    error_message              = error_message
* TABLES
*   DOCUMENTFILES              =
              .
    IF error_message IS INITIAL.
    ELSE.
    ENDIF.


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

*                * Erfolgsmeldung
*                  MESSAGE s000(/cideon/plot_basis)
*                    WITH '' '' '' ''.
*                   Änderung ist erfolgt. & & & &
ENDFORM.                    " start_conversion_by_rule
*&---------------------------------------------------------------------*
*&      Form  get_dates_ECN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_dates_ecn.
* Daten für Änderungsnummer holen.

  DATA: wa_aenr TYPE aenr.
  DATA: index TYPE i.

  LOOP AT itab_search INTO wa_search.
    index = sy-tabix.

    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    IF wa_search-aennr IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

*   Daten für Änderungsnummer holen
    CLEAR wa_aenr.
    SELECT SINGLE * FROM aenr INTO wa_aenr
     WHERE aennr = wa_search-aennr
     .
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

    wa_search-datuv =  wa_aenr-datuv.
    wa_search-andat =  wa_aenr-andat.
    wa_search-aedat =  wa_aenr-aedat.

    MODIFY itab_search FROM wa_search INDEX index.
  ENDLOOP.


ENDFORM.                    " get_dates_ECN
*&---------------------------------------------------------------------*
*&      Form  get_note
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_note.
* globale Notizen holen
  DATA: it_notiz_tmp TYPE /cideon/ttype_s_stempel_wert.
  DATA: wa_notiz_tmp TYPE zcl_stempel_wert.
  DATA: answer.

  CLEAR it_notiz_tmp.
  it_notiz_tmp[] = it_notiz[].
  CALL FUNCTION '/CIDEON/GET_NOTES_WITH_EDIT'
       IMPORTING
            o_answer = answer
       TABLES
            it_notiz = it_notiz_tmp
       EXCEPTIONS
            error    = 1
            OTHERS   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF answer = 'X'.
    CLEAR it_notiz.
    LOOP AT it_notiz_tmp INTO wa_notiz_tmp.
      wa_notiz = wa_notiz_tmp.
      APPEND wa_notiz TO it_notiz.
    ENDLOOP.
  ELSE.
  ENDIF.


ENDFORM.                    " get_note
*&---------------------------------------------------------------------*
*&      Form  set_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_selection.
* Selektion setzen bei Übernahme aus Bestellung etc.
  DATA: index TYPE i.

  CLEAR itab_et_index_rows_searchlist.
  LOOP AT itab_search INTO wa_search.
    IF wa_search-knz_marked_ebeln = 'X'.
    ELSE.
      CONTINUE.
    ENDIF.

    index = sy-tabix.
    CLEAR wa_et_index_rows_searchlist.
    wa_et_index_rows_searchlist-index = index.
    APPEND wa_et_index_rows_searchlist TO
      itab_et_index_rows_searchlist.

  ENDLOOP.

  IF itab_et_index_rows_searchlist[] IS INITIAL.
  ELSE.
    CALL METHOD grid_searchlist->set_selected_rows
       EXPORTING
         it_index_rows = itab_et_index_rows_searchlist
*      IT_ROW_NO     =
        .
  ENDIF.

ENDFORM.                    " set_selection
*&---------------------------------------------------------------------*
*&      Form  lese_sdpartner
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lese_sdpartner.
* SD Partner lesen

  IF wa_plotjobs IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.


  IF wa_plotjobs-vbeln IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

* Partner lesen
  CLEAR it_vbpa.
  SELECT * FROM vbpa
    INTO TABLE it_vbpa
    WHERE vbeln = wa_plotjobs-vbeln
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.


  DATA: addr1_complete TYPE szadr_addr1_complete.
  CLEAR addr1_complete.

* Kommunikationsdaten der Partner lesen
  CLEAR it_sdpartner.
  LOOP AT it_vbpa INTO wa_vbpa.
*   Adressdaten holen
    CLEAR wa_sdpartner.
    MOVE-CORRESPONDING wa_vbpa TO wa_sdpartner.

    CALL FUNCTION 'ADDR_GET_COMPLETE'
      EXPORTING
        addrnumber                    = wa_vbpa-adrnr
*       ADDRHANDLE                    =
*       ARCHIVE_HANDLE                =
      IMPORTING
        addr1_complete                = addr1_complete
      EXCEPTIONS
        parameter_error               = 1
        address_not_exist             = 2
        internal_error                = 3
        wrong_access_to_archive       = 4
        OTHERS                        = 5
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF sy-subrc NE 0.
*      APPEND wa_sdpartner TO it_sdpartner.
*      CONTINUE.
    ELSE.
    ENDIF.

    DATA: wa_szadr_addr1_line TYPE szadr_addr1_line.

    LOOP AT addr1_complete-addr1_tab INTO wa_szadr_addr1_line.
      IF wa_szadr_addr1_line-data-date_from <= sy-datum
        AND wa_szadr_addr1_line-data-date_to >= sy-datum.
        MOVE-CORRESPONDING wa_szadr_addr1_line-data
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    DATA: wa_szadr_adtel_line TYPE szadr_adtel_line.
    LOOP AT addr1_complete-adtel_tab INTO wa_szadr_adtel_line.
      IF wa_szadr_adtel_line-date_from <= sy-datum
        .
        MOVE-CORRESPONDING wa_szadr_adtel_line-adtel
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    DATA: wa_szadr_adfax_line TYPE szadr_adfax_line.
    LOOP AT addr1_complete-adfax_tab INTO wa_szadr_adfax_line.
      IF wa_szadr_adfax_line-date_from <= sy-datum
        .
        MOVE-CORRESPONDING wa_szadr_adfax_line-adfax
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    DATA: wa_szadr_adsmtp_line TYPE szadr_adsmtp_line.
    LOOP AT addr1_complete-adsmtp_tab INTO wa_szadr_adsmtp_line.
      IF wa_szadr_adsmtp_line-date_from <= sy-datum
        .
        MOVE-CORRESPONDING wa_szadr_adsmtp_line-adsmtp
          TO wa_sdpartner.

        "APPEND wa_sdpartner TO it_sdpartner.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.


    APPEND wa_sdpartner TO it_sdpartner.

  ENDLOOP.



* Refreshen des ALV
  CALL METHOD grid_sdpartner->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " lese_sdpartner
*&---------------------------------------------------------------------*
*&      Form  vermessung
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vermessung.
* Schreibt Vermessungsdaten

  DATA wa_meas TYPE /cideon/meas.

  wa_meas-prodkey = 'S-SPSO'.
  wa_meas-userid = sy-uname.
  wa_meas-udate = sy-datum.

  MODIFY /cideon/meas FROM wa_meas.

ENDFORM.                    " vermessung
*&---------------------------------------------------------------------*
*&      Form  add_note_dir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_note_dir.
* Notiz DIS einfügen

  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.

  SET PARAMETER ID 'CV1' FIELD ''.
  SET PARAMETER ID 'CV2' FIELD ''.
  SET PARAMETER ID 'CV3' FIELD ''.
  SET PARAMETER ID 'CV4' FIELD ''.

  CLEAR document.
  CLEAR doc_type.
  CLEAR doc_vers.
  CLEAR doc_part.

  SPLIT user_data-note_dis AT ','
    INTO  doc_type document doc_part doc_vers
    .

  SET PARAMETER ID 'CV1' FIELD document.
  SET PARAMETER ID 'CV2' FIELD doc_type.
  SET PARAMETER ID 'CV3' FIELD doc_vers.
  SET PARAMETER ID 'CV4' FIELD doc_part.



* NORMAL
  CALL FUNCTION 'Z_CL_PLINT_ASK_DOCUMENT_NR'
       IMPORTING
            o_doknr = document
            o_dokar = doc_type
            o_dokvr = doc_vers
            o_doktl = doc_part
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

* Test auf Existenz, falls nicht existent, dann anlegen lassen
  DATA: wa_draw TYPE draw.
  DATA: answer.

  SELECT SINGLE * FROM draw INTO wa_draw
    WHERE dokar = doc_type
    AND doknr = document
    AND doktl = doc_part
    AND dokvr = doc_vers
    .
  IF sy-subrc NE 0.
    CLEAR answer.
    CALL FUNCTION 'DD_POPUP_TO_CONFIRM_CANCEL'
      EXPORTING
        textline1          = text-200
        textline2          = text-203
        title              = text-201
*        START_COLUMN       = 25
*        START_ROW          = 6
*        DEFAULTPOS         = 'C'
      IMPORTING
        answer             = answer
              .
    IF answer = 'C'.
*     Notiz DIS mit Vorgaben anlegen
      CLEAR wa_draw.
      SPLIT user_data-note_dis AT ','
        INTO wa_draw-dokar wa_draw-doknr
        wa_draw-doktl wa_draw-dokvr.

      CALL FUNCTION '/CIDEON/NOTE_DIR_CREATE'
           EXPORTING
                i_storagecat = user_data-note_dir_storage
           CHANGING
                wa_draw      = wa_draw
           EXCEPTIONS
                error        = 1
                OTHERS       = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


    ELSE.
      EXIT.
    ENDIF.
  ELSE.
  ENDIF.


  CLEAR wa_search.

*  wa_search-dokar = doc_type.
*  wa_search-doknr = document.
*  wa_search-dokvr = doc_vers.
*  wa_search-doktl = doc_part.

  MOVE-CORRESPONDING wa_draw TO wa_search.


*  wa_search-knz_spez_dok = 'X'.

* Eintragen am Ende der Liste, falls nichts anderes markiert
  REFRESH itab_et_index_rows_searchlist.
  CALL METHOD grid_searchlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_searchlist LINES count_lines.

  READ TABLE itab_et_index_rows_searchlist
    INTO wa_et_index_rows_searchlist INDEX 1.
  IF sy-subrc NE 0.
    APPEND wa_search TO itab_search.
  ELSE.
    INSERT wa_search INTO itab_search INDEX wa_et_index_rows_searchlist.
  ENDIF.


*    APPEND wa_search TO itab_search.

ENDFORM.                    " add_note_dir
