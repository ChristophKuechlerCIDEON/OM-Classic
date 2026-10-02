*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F10 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_actual_DIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_actual_dis.
* hole für selettierte Einträge die aktuellste DIS Version
* ITAB
  DATA: itab_version_draw TYPE TABLE OF draw.
* WA
  DATA: wa_version_draw TYPE draw.
* NORMAL
  DATA: nummer_letzter_eintrag TYPE i.

* get the selected line in the search ALV
  REFRESH itab_et_index_rows_searchlist.
  CALL METHOD grid_searchlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_searchlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_searchlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_et_index_rows_searchlist
      INTO wa_et_index_rows_searchlist.

    index_itab_searchlist = wa_et_index_rows_searchlist-index.
    READ TABLE itab_search INDEX index_itab_searchlist INTO wa_search.

    CLEAR wa_version_draw.
    CLEAR itab_version_draw.

    SELECT * FROM draw INTO TABLE itab_version_draw
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND doktl = wa_search-doktl
      .
    IF sy-subrc NE 0.
*     nichts gefunden, möglicherweise Spezialeintrag
      CONTINUE.
    ELSE.
    ENDIF.

*    LOOP AT itab_version_draw INTO wa_version_draw.
*    ENDLOOP.
    DESCRIBE TABLE itab_version_draw LINES nummer_letzter_eintrag.
    IF nummer_letzter_eintrag = 0.
      CONTINUE.
    ELSE.
    ENDIF.

    READ TABLE itab_version_draw INTO wa_version_draw
      INDEX nummer_letzter_eintrag.

    MOVE-CORRESPONDING wa_version_draw TO wa_search.
    MODIFY itab_search FROM wa_search INDEX index_itab_searchlist.

  ENDLOOP.

ENDFORM.                    " get_actual_DIS
*&---------------------------------------------------------------------*
*&      Form  get_actual_released_DIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_actual_released_dis.
* Hole für selektierte Einträge die aktuellste freigegebene
* DIS Version

* ITAB
  DATA: itab_version_draw TYPE TABLE OF draw.
* WA
  DATA: wa_version_draw TYPE draw.
  DATA: wa_last_version_draw TYPE draw.
* NORMAL
  DATA: nummer_letzter_eintrag TYPE i.
  DATA: frknz TYPE tdws-frknz.

* get the selected line in the search ALV
  REFRESH itab_et_index_rows_searchlist.
  CALL METHOD grid_searchlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_searchlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_searchlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_et_index_rows_searchlist
      INTO wa_et_index_rows_searchlist.

    index_itab_searchlist = wa_et_index_rows_searchlist-index.
    READ TABLE itab_search INDEX index_itab_searchlist INTO wa_search.

    CLEAR wa_version_draw.
    CLEAR itab_version_draw.

    SELECT * FROM draw INTO TABLE itab_version_draw
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND doktl = wa_search-doktl
      .
    IF sy-subrc NE 0.
*     nichts gefunden, möglicherweise Spezialeintrag
      CONTINUE.
    ELSE.
    ENDIF.

    DESCRIBE TABLE itab_version_draw LINES nummer_letzter_eintrag.
    IF nummer_letzter_eintrag = 0.
      CONTINUE.
    ELSE.
    ENDIF.

*   Testen, ob der letzte Eintrag freigegeben ist
    CLEAR wa_last_version_draw.
    LOOP AT itab_version_draw INTO wa_version_draw.
      CLEAR frknz.
      SELECT SINGLE frknz FROM tdws
        INTO frknz
        WHERE dokar = wa_version_draw-dokar
        AND dokst = wa_version_draw-dokst
        .
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
      ENDIF.

      IF frknz = 'X'.
        CLEAR wa_last_version_draw.
        wa_last_version_draw = wa_version_draw.
      ELSE.
      ENDIF.

    ENDLOOP.

    IF wa_last_version_draw IS INITIAL.
*     keine letzte freigegebene Version gefunden
      CONTINUE.
    ELSE.
      MOVE-CORRESPONDING wa_last_version_draw TO wa_search.
      MODIFY itab_search FROM wa_search INDEX index_itab_searchlist.
    ENDIF.


  ENDLOOP.

ENDFORM.                    " get_actual_released_DIS
*&---------------------------------------------------------------------*
*&      Form  download_to_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_to_local USING p_get_structure TYPE char1.
* Ablegen auf lokalen Verzeichnis
* es werden nur im Contentserver abgelegt Dateien benutzt

*7.0.174.1
*C15K915166       KUECHLER     S-PSO / Änderungen 174
*2015/05/28
* SM 8000033972 Spezial Dokumente ablegen
* Netstal
* Erweiterung um hier mit und ohne Stückliste lokal ablegen zu können
*

*ITAB
*WA
  DATA: return TYPE bapiret2.
  DATA: wa_documentfiles TYPE bapi_doc_files2.
*NORMAL
  DATA: checkout_path TYPE bapi_doc_aux-filename.
  DATA: ausgabe_progress TYPE char100.
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTDN'
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

  DATA lt_row_no TYPE lvc_t_roid.
  CLEAR lt_row_no.

  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist
      et_row_no     = lt_row_no.

  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
    MESSAGE e001(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.


  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
    EXPORTING
      window_title          = text-070
*      INITIAL_FOLDER        =
    IMPORTING
      selected_folder       = checkout_path
    EXCEPTIONS
      cntl_error            = 1
      OTHERS                = 2
            .
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  IF checkout_path IS INITIAL.
    EXIT.
  ELSE.
    CONCATENATE checkout_path '\' INTO checkout_path.
  ENDIF.

  MESSAGE s350(zcl_plint_message_01)
    WITH '' '' '' ''.


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

*   Test auf Spooldokumente
    IF wa_plotjobs-object_type = 'SPOOL'.
*     PDF erstellen
      DATA: tmp_destiny TYPE string.
      CLEAR tmp_destiny.
      tmp_destiny = checkout_path.

      CALL FUNCTION '/CIDEON/OTF_2_PDF'
        EXPORTING
          i_pfad      = tmp_destiny
          i_tdspoolid = wa_plotjobs-tdspoolid
          i_tdotftype = wa_plotjobs-tdotftype
        IMPORTING
          o_filep     = wa_plotjobs-filep
        EXCEPTIONS
          error       = 1
          no_spool    = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
      ENDIF.
      CONTINUE.
    ELSE.
    ENDIF.


*   Test auf Spezialdokumente
    IF wa_plotjobs-knz_spez_dok = 'X'.
      CONTINUE.
    ELSE.
    ENDIF.

    IF wa_plotjobs-knz_fehl_blatt = 'X'.
      CONTINUE.
    ELSE.
    ENDIF.


    CLEAR ausgabe_progress.
    CONCATENATE text-071 wa_plotjobs-filep
      INTO ausgabe_progress.
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*      EXPORTING
**        PERCENTAGE       = 0
*        text             = ausgabe_progress
*              .
*

*   Ablegen
    CLEAR wa_documentfiles.

    wa_documentfiles-documenttype = wa_plotjobs-dokar.
    wa_documentfiles-documentnumber = wa_plotjobs-doknr.
    wa_documentfiles-documentversion = wa_plotjobs-dokvr.
    wa_documentfiles-documentpart = wa_plotjobs-doktl.

    wa_documentfiles-wsapplication = wa_plotjobs-wsapplication.
    wa_documentfiles-docfile = wa_plotjobs-filep.

    DATA lc_get_structure TYPE char1.
    CLEAR lc_get_structure.
    lc_get_structure = '0'.

    lc_get_structure = p_get_structure.

    CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
      EXPORTING
        documenttype              = wa_plotjobs-dokar
        documentnumber            = wa_plotjobs-doknr
        documentpart              = wa_plotjobs-doktl
        documentversion           = wa_plotjobs-dokvr
        documentfile              = wa_documentfiles
        getstructure              = lc_get_structure "'1'
        getcomponents             = 'X'
        originalpath              = checkout_path
*     HOSTNAME                  = ' '
        getheader                 = 'X'
*     DOCBOMCHANGENUMBER        =
*     DOCBOMVALIDFROM           =
*     DOCBOMREVISIONLEVEL       =
      IMPORTING
        return                    = return
*   TABLES
*     DOCUMENTSTRUCTURE         =
*     DOCUMENTFILES             =
*     COMPONENTS                =
              .

    IF return IS INITIAL.
    ELSE.
    ENDIF.

    IF akt_dec <> last_dec.
      prozent = akt_dec * 100.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = prozent
          text       = ausgabe_progress.
    ELSE.
    ENDIF.
    last = akt.
    last_dec = akt_dec.

  ENDLOOP.


ENDFORM.                    " download_to_local
