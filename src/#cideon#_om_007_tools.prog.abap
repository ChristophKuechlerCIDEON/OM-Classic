*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_005_TOOLS                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  fill_itab_JOBLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_itab_joblist.
* to test some functionälity
  REFRESH itab_plotjobs.
  CLEAR wa_plotjobs.

  wa_plotjobs-filename = 'c:\boot.ini'.
  APPEND  wa_plotjobs TO itab_plotjobs.
  wa_plotjobs-filename = 'c:\config.sys'.
  APPEND  wa_plotjobs TO itab_plotjobs.
  wa_plotjobs-filename = 'c:\winnt\Install.wri'.
  APPEND  wa_plotjobs TO itab_plotjobs.
  wa_plotjobs-filename = 'c:\winnt\Winnt.bmp'.
  APPEND  wa_plotjobs TO itab_plotjobs.

  CLEAR wa_plotjobs.



ENDFORM.                    " fill_itab_JOBLIST
*&---------------------------------------------------------------------*
*&      Form  get_selected_line_plotjobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_line_plotjobs.
* get the selected line in the plotjob ALV
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
  ELSE.
*   get the content of the selected Line
    CLEAR index_itab_plotjobs.
    READ TABLE itab_et_index_rows_plotlist INDEX 1
      INTO wa_et_index_rows_plotlist.
    index_itab_plotjobs = wa_et_index_rows_plotlist-index.
    READ TABLE itab_plotjobs INDEX index_itab_plotjobs INTO wa_plotjobs.
  ENDIF.

ENDFORM.                    " get_selected_line_plotjobs
*&---------------------------------------------------------------------*
*&      Form  view_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_document.

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
    WHEN 'URL'.
      CALL FUNCTION '/CIDEON/OM_ITEM_SHOW_URL'
           EXPORTING
                i_url = wa_plotjobs-url.
    WHEN OTHERS.
      CALL FUNCTION 'Z_CL_PLINT_TOOLS_VIEW_DOC_001'
           EXPORTING
                filename = wa_plotjobs-filep
           EXCEPTIONS
                error    = 1
                OTHERS   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
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
*  CALL FUNCTION 'Z_CL_PLINT_TOOLS_VIEW_DOC_001'
*       EXPORTING
*            filename = wa_plotjobs-filep
*       EXCEPTIONS
*            error    = 1
*            OTHERS   = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

ENDFORM.                    " view_document
*&---------------------------------------------------------------------*
*&      Form  get_Selected_line_search_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_line_search_list.
  DATA: tmp_char(25) TYPE c.
  DATA: tmp_doknr TYPE doknr.
  DATA: tmp2_doknr TYPE doknr.
  DATA: i TYPE i.
  DATA: numc(25) TYPE n.
  DATA: char1(25) TYPE c.
  DATA: char2(25) TYPE c.
  DATA: laenge TYPE i.


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
*    MESSAGE e001(zcl_plint_message_01)
*      WITH text-051 count_lines '' ''.

* CKR 2007-08-03
* falls keine Selektion vorliegt werden alle Zeilen Selektiert
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
  ELSE.
  ENDIF.
* /CKR 2007-08-03

*   get the content of the selected Line
  CLEAR index_itab_searchlist.
*    LOOP AT itab_et_index_rows_searchlist
*      INTO wa_et_index_rows_searchlist.
*      index_itab_searchlist = wa_et_index_rows_searchlist-index.
*      READ TABLE itab_search INDEX index_itab_searchlist INTO wa_search
  .
*      wa_plotjobs-filename = wa_search-filep.
*      APPEND wa_plotjobs TO itab_plotjobs.
*    ENDLOOP.
  CLEAR itab_search_tmp.
  LOOP AT itab_et_index_rows_searchlist
    INTO wa_et_index_rows_searchlist.
    index_itab_searchlist = wa_et_index_rows_searchlist-index.
    READ TABLE itab_search INDEX index_itab_searchlist INTO wa_search.
*     append to 25digit CHAR field
*     maybe leading zeros
*      tmp_doknr = wa_search-doknr.
*      numc = tmp_doknr.
*      tmp2_doknr = numc.
*
*      CLEAR sy-subrc.
*      CATCH SYSTEM-EXCEPTIONS conversion_errors = 5.
*        char2 = tmp_doknr - numc.
*      ENDCATCH.
*      IF sy-subrc = 5.
*        keine Nummer !
*      ELSE.
*        Nummer also mit Nullen erweitern!
*         wa_search-doknr = numc.
*      ENDIF.

* "Probleme bei Diehl Avionik 2004_02_17
*      IF wa_search-doknr CN '0123456789 '.
    IF wa_search-doknr CN '0123456789'.
    ELSE.
      numc = wa_search-doknr.
      wa_search-doknr = numc.
    ENDIF.

    APPEND wa_search TO itab_search_tmp.
  ENDLOOP.

*    endif.


ENDFORM.                    " get_Selected_line_search_list
*&---------------------------------------------------------------------*
*&      Form  refresh_joblist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_joblist.
* alte Selektion merken und dann wieder setzen

  IF grid_plotlist IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR itab_et_index_rows_plotlist_o.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist_o
*      ET_ROW_NO     =
      .


  CALL METHOD grid_plotlist->refresh_table_display
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

  CALL METHOD grid_plotlist->set_selected_rows
     EXPORTING
       it_index_rows = itab_et_index_rows_plotlist_o
*      IT_ROW_NO     =
      .


ENDFORM.                    " refresh_joblist
*&---------------------------------------------------------------------*
*&      Form  vorgabe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vorgabe.
* füllt die Suchliste mit Vorgaben
  REFRESH itab_search.
  SELECT * FROM draw INTO CORRESPONDING FIELDS OF TABLE itab_search
    WHERE doknr LIKE user_data-vorgabe
    ORDER BY dokar doknr doktl dokvr
   .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.



ENDFORM.                    " vorgabe
*&---------------------------------------------------------------------*
*&      Form  refresh_Searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_searchlist.

  PERFORM make_knz_freigabe_led.
  PERFORM make_mat_status_icon.
  PERFORM make_display_icon.
  PERFORM make_display_version.

  "BADI Aufruf für Kundeneigene Felder
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF badi_main_pre_001 IS INITIAL.
  ELSE.
*    CALL METHOD badi_main_pre_001->chg_dialog_cv04n
*      CHANGING
*        f_skip  = f_skip
*        lt_draw = itab_draw
*        .
    CALL METHOD badi_main_pre_001->add_customer_fields_searchlist
       CHANGING
         lt_searchlist = itab_search
        .



  ENDIF.


  CALL METHOD grid_searchlist->refresh_table_display
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

ENDFORM.                    " refresh_Searchlist
*&---------------------------------------------------------------------*
*&      Form  read_akt_line_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_akt_line_search.
* get the aktual / selected line in the search list
* check is table is empty
  IF itab_search IS INITIAL.
    CLEAR wa_akt_search.
  ELSE.
  ENDIF.

ENDFORM.                    " read_akt_line_search
*&---------------------------------------------------------------------*
*&      Form  add_to_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_to_plotlist USING p_knz_fehl_blatt.
  DATA: index_details TYPE sy-tabix.
  DATA: tmp_uname LIKE sy-uname.
  DATA: tmp_format_ausgabe LIKE zcl_s_plotlist-format_ausgabe.
* adds the items to the plotting list
  REFRESH itab_tmp_plotjobs.
  LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
    index_details = sy-tabix.
    CLEAR wa_plotjobs.
    MOVE-CORRESPONDING wa_zori_doc_files TO wa_plotjobs.
    READ TABLE itab_zori_doc_files_detail INTO wa_zori_doc_files_detail
      INDEX index_details.
    wa_plotjobs-wsapplication = wa_zori_doc_files_detail-wsapplication.
    wa_plotjobs-filename  = wa_zori_doc_files-filep.
    wa_plotjobs-uname  = user_data-uname.
    wa_plotjobs-storagecategory
      = wa_zori_doc_files_detail-storagecategory.

    wa_plotjobs-application_id =
      wa_zori_doc_files_detail-application_id.
    wa_plotjobs-file_id = wa_zori_doc_files_detail-file_id.

    wa_plotjobs-icon_display = icon_doc_item_detail.
    wa_plotjobs-icon_display_dis = icon_doc_header_detail.

    wa_plotjobs-aufnr  = wa_zori_doc_files-aufnr_pp.

    wa_plotjobs-matnr  = wa_zori_doc_files-matnr.
    wa_plotjobs-mat_count  = wa_zori_doc_files-mat_count.

    wa_plotjobs-res4  = wa_zori_doc_files-res4.

    wa_plotjobs-drtxt  = wa_zori_doc_files-drtxt.
    wa_plotjobs-tdotftype  = wa_zori_doc_files-tdotftype.
    wa_plotjobs-tdspoolid  = wa_zori_doc_files-tdspoolid.

    wa_plotjobs-psteu  = wa_zori_doc_files-psteu.
    wa_plotjobs-samlt  = wa_zori_doc_files-samlt.
    wa_plotjobs-pmode  = wa_zori_doc_files-pmode.
    wa_plotjobs-drart  = wa_zori_doc_files-drart.
    wa_plotjobs-ktext  = wa_zori_doc_files-ktext.
    wa_plotjobs-selpr  = wa_zori_doc_files-selpr.
    wa_plotjobs-tcode  = wa_zori_doc_files-tcode.

    wa_plotjobs-pspnr  = wa_zori_doc_files-projn.

    wa_plotjobs-aufnr_cs  = wa_zori_doc_files-aufnr_cs.

    SELECT SINGLE posid FROM prps
      INTO wa_plotjobs-pspid
      WHERE pspnr = wa_plotjobs-pspnr
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    APPEND wa_plotjobs TO itab_tmp_plotjobs.
  ENDLOOP.

*    PERFORM add_objectkey_to_plotlist.
  PERFORM add_objectkey_to_plotlist_2.

  IF user_data-knz_use_merkmal_format = 'X'.
    PERFORM add_format_field.
  ELSE.
  ENDIF.

  IF user_data-knz_use_multipage = 'X'.
*      PERFORM check_for_multipage.
    PERFORM check_for_multipage_2.
  ELSE.
  ENDIF.

*   ask for fitting distributor
*Z_CL_GET_VERTEILER
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.

    " check for using of CLF / PPL
    IF user_data-knz_use_post = 'X'.
    ELSE.
      EXIT.
    ENDIF.

    CALL FUNCTION 'Z_CL_GET_VERTEILER'
         EXPORTING
              i_uname          = user_data-uname
              i_wa_plotjobs    = wa_plotjobs
         IMPORTING
              o_voreinstellung = wa_voreinstellung
              o_verteiler      = wa_verteiler
              o_bedingung      = wa_bedingung
         EXCEPTIONS
              error            = 1
              not_found        = 2
              OTHERS           = 3.
    IF sy-subrc <> 0.
*     try with default_user
      CALL FUNCTION 'Z_CL_GET_VERTEILER'
           EXPORTING
                i_uname          = default_data-default_nutzer
                i_wa_plotjobs    = wa_plotjobs
           IMPORTING
                o_voreinstellung = wa_voreinstellung
                o_verteiler      = wa_verteiler
                o_bedingung      = wa_bedingung
           EXCEPTIONS
                error            = 1
                not_found        = 2
                OTHERS           = 3.
      IF sy-subrc <> 0.
*       get the default values
        CLEAR tmp_uname.
        tmp_uname = wa_plotjobs-uname.
        CLEAR tmp_format_ausgabe.
        tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
        wa_plotjobs-prio = default_data-default_prio.
        wa_plotjobs-kopien = default_data-default_kopien.
        wa_plotjobs-verteiler = user_data-verteiler.
        MOVE-CORRESPONDING wa_default_verteiler TO wa_plotjobs.
        wa_plotjobs-verteiler = default_data-default_verteiler.
        wa_plotjobs-uname = tmp_uname.
        IF tmp_format_ausgabe IS INITIAL.
        ELSE.
          wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
          wa_plotjobs-zielformat = tmp_format_ausgabe.
        ENDIF.
        wa_plotjobs-satzanzahl = default_data-default_satzanzahl.
        wa_plotjobs-deckblatt = default_data-default_deckblatt.
        wa_plotjobs-endeblatt = default_data-default_endeblatt.
        wa_plotjobs-fehlblatt = default_data-default_fehlblatt.
        wa_plotjobs-knz_inhalt_vz = default_data-default_knz_inhalt_vz.
        wa_plotjobs-inhaltsblatt = default_data-default_inhaltsblatt.
      ELSE.
        CLEAR tmp_uname.
        tmp_uname = wa_plotjobs-uname.
        CLEAR tmp_format_ausgabe.
        tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
        MOVE-CORRESPONDING wa_voreinstellung TO wa_plotjobs.
        wa_plotjobs-uname = tmp_uname.
        wa_plotjobs-prio = default_data-default_prio.
        wa_plotjobs-verteiler = wa_verteiler-verteiler.
        IF tmp_format_ausgabe IS INITIAL.
        ELSE.
          wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
          wa_plotjobs-zielformat = tmp_format_ausgabe.
        ENDIF.
        wa_plotjobs-satzanzahl = wa_bedingung-satzanzahl.
        wa_plotjobs-deckblatt = wa_bedingung-deckblatt.
        wa_plotjobs-endeblatt = wa_bedingung-endeblatt.
        wa_plotjobs-fehlblatt = default_data-default_fehlblatt.
        wa_plotjobs-knz_inhalt_vz = wa_bedingung-knz_inhalt_vz.
        wa_plotjobs-inhaltsblatt = wa_bedingung-inhaltsblatt.
      ENDIF.
    ELSE.
      CLEAR tmp_uname.
      tmp_uname = wa_plotjobs-uname.
      CLEAR tmp_format_ausgabe.
      tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
      MOVE-CORRESPONDING wa_voreinstellung TO wa_plotjobs.
      wa_plotjobs-uname = tmp_uname.
      wa_plotjobs-prio = default_data-default_prio.
      wa_plotjobs-verteiler = wa_verteiler-verteiler.
      IF tmp_format_ausgabe IS INITIAL.
      ELSE.
        wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
        wa_plotjobs-zielformat = tmp_format_ausgabe.
      ENDIF.
      wa_plotjobs-satzanzahl = wa_bedingung-satzanzahl.
      wa_plotjobs-deckblatt = wa_bedingung-deckblatt.
      wa_plotjobs-endeblatt = wa_bedingung-endeblatt.
      wa_plotjobs-fehlblatt = wa_bedingung-fehlblatt.
      wa_plotjobs-knz_inhalt_vz = wa_bedingung-knz_inhalt_vz.
      wa_plotjobs-inhaltsblatt = wa_bedingung-inhaltsblatt.
    ENDIF.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.
*   ask for fitting distributor end


* Kennzeichen Fehlblatt
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-knz_fehl_blatt = p_knz_fehl_blatt.
    IF wa_plotjobs-knz_fehl_blatt = 'X'.
*      wa_plotjobs-light = 1.
      wa_plotjobs-icon_fehlblatt = user_data-fehlblatt_icon.
    ELSE.
*      wa_plotjobs-light = 3.
      wa_plotjobs-icon_fehlblatt = ''.
    ENDIF.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

* Spezialdokumente
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    IF wa_plotjobs-knz_spez_dok = 'X'.
      wa_plotjobs-icon_spez_dok = user_data-spez_dok_icon.
    ELSE.
      CONTINUE.
    ENDIF.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

* default values
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    " check for using of CLF / PPL
    IF user_data-knz_use_post = 'X'.
      EXIT.
    ELSE.
    ENDIF.

    wa_plotjobs-preprocessor = user_data-preprocessor.

    wa_plotjobs-prio = default_data-default_prio.
    wa_plotjobs-kopien = default_data-default_kopien.

*   möglicherweise schon vorbelegt
    IF wa_plotjobs-verteiler IS INITIAL.
      wa_plotjobs-verteiler = user_data-verteiler.
    ELSE.
    ENDIF.

    "MOVE-CORRESPONDING wa_default_verteiler TO wa_plotjobs.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.
* default values ende

* Spezialeinträge
* List & Label Vorlagen
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    " check for using of CLF / PPL
    IF user_data-knz_use_post = 'X'.
      EXIT.
    ELSE.
    ENDIF.

    CASE wa_plotjobs-object_type.
      WHEN c_sl_object_type.
        DATA: wa_tmp_prep_usr TYPE zcl_preproz_user.
        DATA: wa_preproz_lal TYPE zcl_preproz_lal.
        CLEAR wa_tmp_prep_usr.
        CLEAR wa_preproz_lal.

        SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_prep_usr
          WHERE uname = sy-uname
          AND status = c_status_aktiv
          .
        IF sy-subrc NE 0.
          "Defaultbenutzer verwenden
          SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_prep_usr
            WHERE uname = default_data-default_nutzer
            AND status = c_status_aktiv
            .
          IF sy-subrc NE 0.
          ELSE.
          ENDIF.
        ELSE.
        ENDIF.
*       Lesen der Vorlagendatei
        SELECT SINGLE * FROM zcl_preproz_lal INTO wa_preproz_lal
          WHERE preprozessor = wa_tmp_prep_usr-preprozessor
          AND object_type = c_sl_object_type
          AND status = c_status_aktiv
          .
        IF sy-subrc NE 0.
          MESSAGE s002(zcl_plint_tools)
            WITH 'zcl_preproz_lal' wa_tmp_prep_usr-preprozessor
            c_sl_object_type c_status_aktiv.
        ELSE.
        ENDIF.

        wa_plotjobs-vorlage_l_and_l = wa_preproz_lal-vorlage_l_and_l.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.


* CKR 12.07.2004 wegen Auslaufen der Postprocessoransteuerung
* abgeschaltet
*    PERFORM add_compression_field.

*    PERFORM add_special_fields.
*    PERFORM check_priorities.
  PERFORM check_priorities_2.

* DIS Status Visiualisierung etc.
*    PERFORM get_dok_status.
  PERFORM get_dok_status_2.

*    PERFORM reindex_table.
  PERFORM reindex_table_3.

*  SORT itab_tmp_plotjobs BY dokar doknr dokvr doktl cont.
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    APPEND wa_plotjobs TO itab_plotjobs.
  ENDLOOP.
ENDFORM.                    " add_to_plotlist
*&---------------------------------------------------------------------*
*&      Form  fill_jobtable_for_plot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_jobtable_for_plot.
* get the selected lines in the plotjob ALV
  DATA: index_itab_plotjobs_tmp TYPE sy-tabix.

  REFRESH itab_tmp_plotjobs.
  REFRESH itab_et_index_rows_plotlist.
  CALL METHOD grid_plotlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_plotlist LINES count_lines.
  IF count_lines < 1.
    REFRESH itab_et_index_rows_plotlist.
*    MESSAGE e001(zcl_plint_message_01)
*      WITH text-051 count_lines '' ''.

* CKR 2007-08-04
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
* /CKR 2007-08-04
  ELSE.
  ENDIF.

*   get the content of the selected Lines
  REFRESH itab_zori_doc_files.
  LOOP AT itab_et_index_rows_plotlist INTO wa_et_index_rows_plotlist.
    index_itab_plotjobs_tmp = wa_et_index_rows_plotlist-index.
    READ TABLE itab_plotjobs INDEX index_itab_plotjobs_tmp
      INTO wa_plotjobs.
    APPEND wa_plotjobs TO itab_tmp_plotjobs .
*     put into an table.
    CLEAR wa_zori_doc_files.
    MOVE-CORRESPONDING wa_plotjobs TO wa_zori_doc_files.
    APPEND wa_zori_doc_files TO itab_zori_doc_files..
  ENDLOOP.

  " check for using of CLF / PPL
  IF user_data-knz_use_post = 'X'.
*     calculate Kompression
    PERFORM add_compression_field.
*     calculate APPL%TYPE / APPL$COMP
    PERFORM add_appl_fields.
  ELSE.
  ENDIF.

*   Kundendaten anfügen
  " PERFORM add_client_data.
*    PERFORM add_client_data_2
  .
*   Kostenstelle einfügen
*    PERFORM add_cost_center.

*   Prioritäten checken
*    PERFORM check_priorities.
  PERFORM check_priorities_2.

*   Reindizieren der Counter
*    PERFORM reindex_table.
  PERFORM reindex_table_3.

*  ENDIF.


ENDFORM.                    " fill_jobtable_for_plot
*&---------------------------------------------------------------------*
*&      Form  on_ctmenu_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM on_ctmenu_blatt
  USING l_menu  TYPE REF TO cl_ctmenu.

  CALL METHOD l_menu->add_function
    EXPORTING fcode = 'DELETE_BLATT'
              text = text-100
              .


ENDFORM.                    " on_ctmenu_input
*&---------------------------------------------------------------------*
*&      Form  DELETE_SELECTED_LINE_SEARCH_LI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_selected_line_search_list.
* it deletes the selected lines in the search grid
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
  ELSE.
    SORT itab_et_index_rows_searchlist BY index DESCENDING.
    LOOP AT itab_et_index_rows_searchlist
      INTO wa_et_index_rows_searchlist.
      DELETE itab_search INDEX wa_et_index_rows_searchlist.
    ENDLOOP.
  ENDIF.



ENDFORM.                    " DELETE_SELECTED_LINE_SEARCH_LI
*&---------------------------------------------------------------------*
*&      Form  clean_up
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clean_up.
* cleans the intances
* Searchlist
  IF grid_searchlist IS INITIAL.
  ELSE.
    CALL METHOD grid_searchlist->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CLEAR grid_searchlist.
  ENDIF.
  IF container_grid_searchlist IS INITIAL.
  ELSE.
    CALL METHOD container_grid_searchlist->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CLEAR container_grid_searchlist.
  ENDIF.
* Plotlist
  IF grid_plotlist IS INITIAL.
  ELSE.
    CALL METHOD grid_plotlist->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CLEAR grid_plotlist.
  ENDIF.
  IF container_grid_plotlist IS INITIAL.
  ELSE.
    CALL METHOD container_grid_plotlist->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CLEAR container_grid_plotlist.
  ENDIF.
* Listtree
  IF container_tree_plotlist IS INITIAL.
  ELSE.
    CALL METHOD container_tree_plotlist->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CLEAR container_tree_plotlist.
  ENDIF.


* Tabelleneinträge löschen, die nicht mehr benötigt werden
  PERFORM delete_sl_items.


ENDFORM.                    " clean_up
*&---------------------------------------------------------------------*
*&      Form  add_to_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_to_tree_plotlist.
* adds the items to the plotting list tree

* importend !!!!
* this module isn't finished ! dont use it !!!!
* importend !!!!

  DATA: tmp_str TYPE string.
  DATA: result_type TYPE i.
  DATA: result_node_key TYPE tm_nodekey.
  DATA: start_node TYPE tm_nodekey.
  DATA: parent_node TYPE tm_nodekey.
  DATA: key_str TYPE string.
  DATA: text_str TYPE string.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  LOOP AT itab_zori_doc_files INTO wa_zori_doc_files.
    CLEAR wa_plotjobs.
    MOVE-CORRESPONDING wa_zori_doc_files TO wa_plotjobs.
    wa_plotjobs-filename  = wa_zori_doc_files-filep.

*   Search for Dokumentenart
    tmp_str = sy-tabix.
    text_str = wa_plotjobs-dokar.
    CONCATENATE tmp_str text_str INTO key_str.
    CLEAR result_type.
    CLEAR result_node_key.
    CLEAR start_node.
    CLEAR parent_node.
    CALL METHOD simple_tree_plotlist->find_first
      EXPORTING
        search_string         = text_str
      IMPORTING
        result_type           = result_type
        result_node_key       = result_node_key
      EXCEPTIONS
        start_node_not_found  = 1
        OTHERS                = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF result_type = 0.
*     nothing found
*     add to highest level
*     DOKAR
      CALL METHOD simple_tree_plotlist->add_node
        EXPORTING
          node_key = key_str
          isfolder = 'X'
          text = text_str
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
*     DOKNR
      parent_node = key_str.
      text_str = wa_plotjobs-doknr.
      CONCATENATE tmp_str text_str INTO key_str.
      CALL METHOD simple_tree_plotlist->add_node
        EXPORTING
          node_key = key_str
          relative_node_key = parent_node
          isfolder = 'X'
          text = text_str
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
*     DOKVR
      parent_node = key_str.
      text_str = wa_plotjobs-dokvr.
      CONCATENATE tmp_str text_str INTO key_str.
      CALL METHOD simple_tree_plotlist->add_node
        EXPORTING
          node_key = key_str
          relative_node_key = parent_node
          isfolder = 'X'
          text = text_str
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
*     DOKTL
      parent_node = key_str.
      text_str = wa_plotjobs-doktl.
      CONCATENATE tmp_str text_str INTO key_str.
      CALL METHOD simple_tree_plotlist->add_node
        EXPORTING
          node_key = key_str
          relative_node_key = parent_node
          isfolder = 'X'
          text = text_str
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
*     FILEP
      parent_node = key_str.
      text_str = wa_plotjobs-filep.
      CONCATENATE tmp_str text_str INTO key_str.
      CALL METHOD simple_tree_plotlist->add_node
        EXPORTING
          node_key = key_str
          relative_node_key = parent_node
          isfolder = ''
          text = text_str
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
*     Search for Dokument
*     DOKAR found
*     DOKNR
      start_node = result_node_key.
      text_str = wa_plotjobs-doknr.
      CONCATENATE tmp_str text_str INTO key_str.
      CALL METHOD simple_tree_plotlist->find_first
        EXPORTING
          search_string         = text_str
         start_node            = start_node
        IMPORTING
          result_type           = result_type
          result_node_key       = result_node_key
        EXCEPTIONS
          start_node_not_found  = 1
          OTHERS                = 2
              .
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      IF result_type = 0.
*       DOKNR einfügen
        CALL METHOD simple_tree_plotlist->add_node
          EXPORTING
            node_key = key_str
            relative_node_key = start_node
            isfolder = 'X'
            text = text_str
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*       DOKVR einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-dokvr.
        CONCATENATE tmp_str text_str INTO key_str.
        CALL METHOD simple_tree_plotlist->add_node
          EXPORTING
            node_key = key_str
            relative_node_key = parent_node
            isfolder = 'X'
            text = text_str
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*       DOKTL einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-doktl.
        CONCATENATE tmp_str text_str INTO key_str.
        CALL METHOD simple_tree_plotlist->add_node
          EXPORTING
            node_key = key_str
            relative_node_key = parent_node
            isfolder = 'X'
            text = text_str
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*       FILEP einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-filep.
        CONCATENATE tmp_str text_str INTO key_str.
        CALL METHOD simple_tree_plotlist->add_node
          EXPORTING
            node_key = key_str
            relative_node_key = parent_node
            isfolder = ''
            text = text_str
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ELSE.
*       Search for Dokument
*       DOKAR found
*       DOKNR found
*       DOKVR
        start_node = result_node_key.
        text_str = wa_plotjobs-dokvr.
        CALL METHOD simple_tree_plotlist->find_first
          EXPORTING
            search_string         = text_str
            start_node            = start_node
          IMPORTING
            result_type           = result_type
            result_node_key       = result_node_key
          EXCEPTIONS
            start_node_not_found  = 1
            OTHERS                = 2
                .
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        IF result_type = 0.
*         DOKVR einfügen
          parent_node = start_node.
          text_str = wa_plotjobs-dokvr.
          CONCATENATE tmp_str text_str INTO key_str.
          CALL METHOD simple_tree_plotlist->add_node
            EXPORTING
              node_key = key_str
              relative_node_key = parent_node
              isfolder = 'X'
              text = text_str
            EXCEPTIONS
              OTHERS = 1.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
*         DOKTL einfügen
          parent_node = key_str.
          text_str = wa_plotjobs-doktl.
          CONCATENATE tmp_str text_str INTO key_str.
          CALL METHOD simple_tree_plotlist->add_node
            EXPORTING
              node_key = key_str
              relative_node_key = parent_node
              isfolder = 'X'
              text = text_str
            EXCEPTIONS
              OTHERS = 1.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
*         FILEP einfügen
          parent_node = key_str.
          text_str = wa_plotjobs-filep.
          CONCATENATE tmp_str text_str INTO key_str.
          CALL METHOD simple_tree_plotlist->add_node
            EXPORTING
              node_key = key_str
              relative_node_key = parent_node
              isfolder = ''
              text = text_str
            EXCEPTIONS
              OTHERS = 1.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ELSE.
*         Search for Dokument
*         DOKAR found
*         DOKNR found
*         DOKVR found
*         DOKTL
          start_node = result_node_key.
          text_str = wa_plotjobs-doktl.
          CONCATENATE tmp_str text_str INTO key_str.
          CALL METHOD simple_tree_plotlist->find_first
            EXPORTING
              search_string         = text_str
             start_node            = start_node
            IMPORTING
              result_type           = result_type
              result_node_key       = result_node_key
            EXCEPTIONS
              start_node_not_found  = 1
              OTHERS                = 2
                  .
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          IF result_type = 0.
*           DOKTL einfügen
            parent_node = key_str.
            text_str = wa_plotjobs-doktl.
            CONCATENATE tmp_str text_str INTO key_str.
            CALL METHOD simple_tree_plotlist->add_node
              EXPORTING
                node_key = key_str
                relative_node_key = parent_node
                isfolder = 'X'
                text = text_str
              EXCEPTIONS
                OTHERS = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
*           FILEP einfügen
            parent_node = key_str.
            text_str = wa_plotjobs-filep.
            CONCATENATE tmp_str text_str INTO key_str.
            CALL METHOD simple_tree_plotlist->add_node
              EXPORTING
                node_key = key_str
                relative_node_key = parent_node
                isfolder = ''
                text = text_str
              EXCEPTIONS
                OTHERS = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ELSE.
*           Search for Dokument
*           DOKAR found
*           DOKNR found
*           DOKVR found
*           DOKTL found
*           FILEP
            start_node = result_node_key.
            text_str = wa_plotjobs-filep.
            CONCATENATE tmp_str text_str INTO key_str.
            CALL METHOD simple_tree_plotlist->find_first
              EXPORTING
                search_string         = text_str
               start_node            = start_node
              IMPORTING
                result_type           = result_type
                result_node_key       = result_node_key
              EXCEPTIONS
                start_node_not_found  = 1
                OTHERS                = 2
                    .
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            IF result_type = 0.
*             FILEP einfügen
              parent_node = start_node.
              text_str = wa_plotjobs-filep.
              CONCATENATE tmp_str text_str INTO key_str.
              CALL METHOD simple_tree_plotlist->add_node
                EXPORTING
                  node_key = key_str
                  relative_node_key = parent_node
                  isfolder = ''
                  text = text_str
                EXCEPTIONS
                  OTHERS = 1.
              IF sy-subrc <> 0.
*                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                MESSAGE i050(zcl_plint_message_01)
                  WITH '' '' '' ''.
              ENDIF.
            ELSE.
*            it should never happens
              MESSAGE i051(zcl_plint_message_01)
                WITH key_str text_str start_node  ''.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*   Search for Dokument

*   Version

*   Teil

*   Filename


*    APPEND wa_plotjobs TO itab_plotjobs.
  ENDLOOP.

ENDFORM.                    " add_to_tree_plotlist
*&---------------------------------------------------------------------*
*&      Form  rebuild_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rebuild_tree_plotlist.
* adds the items to the plotting list tree
  DATA: tmp_str TYPE string.
  DATA: result_type TYPE i.
  DATA: result_node_key TYPE tm_nodekey.
  DATA: start_node TYPE tm_nodekey.
  DATA: parent_node TYPE tm_nodekey.
  DATA: key_str TYPE string.
  DATA: text_str TYPE string.
  DATA: f_all_nodes_expanded(1).

  IF simple_tree_plotlist IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

* alle Knoten löschen
  CALL METHOD simple_tree_plotlist->delete_all_nodes
      .

* TESTENTRY BEGIN
  PERFORM rebuild_tree_plotlist_2.
  EXIT.
* TESTENTRY END

*  loop at itab_plotjobs into wa_plotjobs.
**   Search for Dokumentenart
*    tmp_str = sy-tabix.
*    text_str = wa_plotjobs-dokar.
*    concatenate tmp_str text_str into key_str.
*    clear result_type.
*    clear result_node_key.
*    clear start_node.
*    clear parent_node.
*    call method simple_tree_plotlist->find_first
*      exporting
*        search_string         = text_str
*      importing
*        result_type           = result_type
*        result_node_key       = result_node_key
*      exceptions
*        start_node_not_found  = 1
*        others                = 2
*            .
*    if sy-subrc <> 0.
*      message i053(zcl_plint_message_01)
*        with '' text_str '' ''.
*    endif.
*    if result_type = 0.
**     nothing found
**     add to highest level
**     DOKAR
*      call method simple_tree_plotlist->add_node
*        exporting
*          node_key = key_str
*          isfolder = 'X'
*          text = text_str
*        exceptions
*          others = 1.
*      if sy-subrc <> 0.
*        message i054(zcl_plint_message_01)
*          with key_str text_str 'root' ''.
*      endif.
**     DOKNR
*      parent_node = key_str.
*      text_str = wa_plotjobs-doknr.
*      concatenate tmp_str text_str into key_str.
*      call method simple_tree_plotlist->add_node
*        exporting
*          node_key = key_str
*          relative_node_key = parent_node
*          relationship = cl_tree_model=>relat_last_child
*          isfolder = 'X'
*          text = text_str
*        exceptions
*          others = 1.
*      if sy-subrc <> 0.
*        message i054(zcl_plint_message_01)
*          with key_str text_str parent_node ''.
*      endif.
**     DOKVR
*      parent_node = key_str.
*      text_str = wa_plotjobs-dokvr.
*      concatenate tmp_str text_str into key_str.
*      call method simple_tree_plotlist->add_node
*        exporting
*          node_key = key_str
*          relative_node_key = parent_node
*          relationship = cl_tree_model=>relat_last_child
*          isfolder = 'X'
*          text = text_str
*        exceptions
*          others = 1.
*      if sy-subrc <> 0.
*        message i054(zcl_plint_message_01)
*          with key_str text_str parent_node ''.
*      endif.
**     DOKTL
*      parent_node = key_str.
*      text_str = wa_plotjobs-doktl.
*      concatenate tmp_str text_str into key_str.
*      call method simple_tree_plotlist->add_node
*        exporting
*          node_key = key_str
*          relative_node_key = parent_node
*          relationship = cl_tree_model=>relat_last_child
*          isfolder = 'X'
*          text = text_str
*        exceptions
*          others = 1.
*      if sy-subrc <> 0.
*        message i054(zcl_plint_message_01)
*          with key_str text_str parent_node ''.
*      endif.
**     FILEP
*      parent_node = key_str.
*      text_str = wa_plotjobs-filep.
*      concatenate tmp_str text_str into key_str.
*      call method simple_tree_plotlist->add_node
*        exporting
*          node_key = key_str
*          relative_node_key = parent_node
*          relationship = cl_tree_model=>relat_last_child
*          isfolder = ''
*          text = text_str
*        exceptions
*          others = 1.
*      if sy-subrc <> 0.
*        message i054(zcl_plint_message_01)
*          with key_str text_str parent_node ''.
*      endif.
*    else.
**     Search for Dokument
**     DOKAR found
**     DOKNR
*      start_node = result_node_key.
*      text_str = wa_plotjobs-doknr.
*      concatenate tmp_str text_str into key_str.
*      call method simple_tree_plotlist->find_first
*        exporting
*          search_string         = text_str
*         start_node            = start_node
*        importing
*          result_type           = result_type
*          result_node_key       = result_node_key
*        exceptions
*          start_node_not_found  = 1
*          others                = 2
*              .
*      if sy-subrc <> 0.
*        message i053(zcl_plint_message_01)
*          with start_node text_str '' ''.
*      endif.
*      if result_type = 0.
**       DOKNR einfügen
*        call method simple_tree_plotlist->add_node
*          exporting
*            node_key = key_str
*            relative_node_key = start_node
*            relationship = cl_tree_model=>relat_last_child
*            isfolder = 'X'
*            text = text_str
*          exceptions
*            others = 1.
*        if sy-subrc <> 0.
*          message i054(zcl_plint_message_01)
*            with key_str text_str parent_node ''.
*        endif.
**       DOKVR einfügen
*        parent_node = key_str.
*        text_str = wa_plotjobs-dokvr.
*        concatenate tmp_str text_str into key_str.
*        call method simple_tree_plotlist->add_node
*          exporting
*            node_key = key_str
*            relative_node_key = parent_node
*            relationship = cl_tree_model=>relat_last_child
*            isfolder = 'X'
*            text = text_str
*          exceptions
*            others = 1.
*        if sy-subrc <> 0.
*          message i054(zcl_plint_message_01)
*            with key_str text_str parent_node ''.
*        endif.
**       DOKTL einfügen
*        parent_node = key_str.
*        text_str = wa_plotjobs-doktl.
*        concatenate tmp_str text_str into key_str.
*        call method simple_tree_plotlist->add_node
*          exporting
*            node_key = key_str
*            relative_node_key = parent_node
*            relationship = cl_tree_model=>relat_last_child
*            isfolder = 'X'
*            text = text_str
*          exceptions
*            others = 1.
*        if sy-subrc <> 0.
*          message i054(zcl_plint_message_01)
*            with key_str text_str parent_node ''.
*        endif.
**       FILEP einfügen
*        parent_node = key_str.
*        text_str = wa_plotjobs-filep.
*        concatenate tmp_str text_str into key_str.
*        call method simple_tree_plotlist->add_node
*          exporting
*            node_key = key_str
*            relative_node_key = parent_node
*            isfolder = ''
*            text = text_str
*          exceptions
*            others = 1.
*        if sy-subrc <> 0.
*          message i054(zcl_plint_message_01)
*            with key_str text_str parent_node ''.
*        endif.
*      else.
**       Search for Dokument
**       DOKAR found
**       DOKNR found
**       DOKVR
*        start_node = result_node_key.
*        text_str = wa_plotjobs-dokvr.
*        call method simple_tree_plotlist->find_first
*          exporting
*            search_string         = text_str
*            start_node            = start_node
*          importing
*            result_type           = result_type
*            result_node_key       = result_node_key
*          exceptions
*            start_node_not_found  = 1
*            others                = 2
*                .
*        if sy-subrc <> 0.
*          message i053(zcl_plint_message_01)
*            with start_node text_str '' ''.
*        endif.
*        if result_type = 0.
**         DOKVR einfügen
*          parent_node = start_node.
*          text_str = wa_plotjobs-dokvr.
*          concatenate tmp_str text_str into key_str.
*          call method simple_tree_plotlist->add_node
*            exporting
*              node_key = key_str
*              relative_node_key = parent_node
*              relationship = cl_tree_model=>relat_last_child
*              isfolder = 'X'
*              text = text_str
*            exceptions
*              others = 1.
*          if sy-subrc <> 0.
*            message i054(zcl_plint_message_01)
*              with key_str text_str parent_node ''.
*          endif.
**         DOKTL einfügen
*          parent_node = key_str.
*          text_str = wa_plotjobs-doktl.
*          concatenate tmp_str text_str into key_str.
*          call method simple_tree_plotlist->add_node
*            exporting
*              node_key = key_str
*              relative_node_key = parent_node
*              relationship = cl_tree_model=>relat_last_child
*              isfolder = 'X'
*              text = text_str
*            exceptions
*              others = 1.
*          if sy-subrc <> 0.
*            message i054(zcl_plint_message_01)
*              with key_str text_str parent_node ''.
*          endif.
**         FILEP einfügen
*          parent_node = key_str.
*          text_str = wa_plotjobs-filep.
*          concatenate tmp_str text_str into key_str.
*          call method simple_tree_plotlist->add_node
*            exporting
*              node_key = key_str
*              relative_node_key = parent_node
*              relationship = cl_tree_model=>relat_last_child
*              isfolder = ''
*              text = text_str
*            exceptions
*              others = 1.
*          if sy-subrc <> 0.
*            message i054(zcl_plint_message_01)
*              with key_str text_str parent_node ''.
*          endif.
*        else.
**         Search for Dokument
**         DOKAR found
**         DOKNR found
**         DOKVR found
**         DOKTL
*          start_node = result_node_key.
*          text_str = wa_plotjobs-doktl.
*          concatenate tmp_str text_str into key_str.
*          call method simple_tree_plotlist->find_first
*            exporting
*              search_string         = text_str
*             start_node            = start_node
*            importing
*              result_type           = result_type
*              result_node_key       = result_node_key
*            exceptions
*              start_node_not_found  = 1
*              others                = 2
*                  .
*          if sy-subrc <> 0.
*            message i053(zcl_plint_message_01)
*              with start_node text_str '' ''.
*          endif.
*          if result_type = 0.
**           DOKTL einfügen
*            parent_node = key_str.
*            text_str = wa_plotjobs-doktl.
*            concatenate tmp_str text_str into key_str.
*            call method simple_tree_plotlist->add_node
*              exporting
*                node_key = key_str
*                relative_node_key = parent_node
*                relationship = cl_tree_model=>relat_last_child
*                isfolder = 'X'
*                text = text_str
*              exceptions
*                others = 1.
*            if sy-subrc <> 0.
*              message i054(zcl_plint_message_01)
*                with key_str text_str parent_node ''.
*            endif.
**           FILEP einfügen
*            parent_node = key_str.
*            text_str = wa_plotjobs-filep.
*            concatenate tmp_str text_str into key_str.
*            call method simple_tree_plotlist->add_node
*              exporting
*                node_key = key_str
*                relative_node_key = parent_node
*                relationship = cl_tree_model=>relat_last_child
*                isfolder = ''
*                text = text_str
*              exceptions
*                others = 1.
*            if sy-subrc <> 0.
*              message i054(zcl_plint_message_01)
*                with key_str text_str parent_node ''.
*            endif.
*          else.
**           Search for Dokument
**           DOKAR found
**           DOKNR found
**           DOKVR found
**           DOKTL found
**           FILEP
*            start_node = result_node_key.
*            text_str = wa_plotjobs-filep.
*            concatenate tmp_str text_str into key_str.
*            call method simple_tree_plotlist->find_first
*              exporting
*                search_string         = text_str
*               start_node            = start_node
*              importing
*                result_type           = result_type
*                result_node_key       = result_node_key
*              exceptions
*                start_node_not_found  = 1
*                others                = 2
*                    .
*            if sy-subrc <> 0.
*              message i053(zcl_plint_message_01)
*                with start_node text_str '' ''.
*            endif.
*            if result_type = 0.
**             FILEP einfügen
*              parent_node = start_node.
*              text_str = wa_plotjobs-filep.
*              concatenate tmp_str text_str into key_str.
*              call method simple_tree_plotlist->add_node
*                exporting
*                  node_key = key_str
*                  relative_node_key = parent_node
*                  relationship = cl_tree_model=>relat_last_child
*                  isfolder = ''
*                  text = text_str
*                exceptions
*                  others = 1.
*              if sy-subrc <> 0.
*                message i054(zcl_plint_message_01)
*                  with key_str text_str parent_node ''.
*              endif.
*            else.
**             FILEP einfügen
*              parent_node = start_node.
*              text_str = wa_plotjobs-filep.
*              concatenate tmp_str text_str into key_str.
*              call method simple_tree_plotlist->add_node
*                exporting
*                  node_key = key_str
*                  relative_node_key = parent_node
*                  relationship = cl_tree_model=>relat_last_child
*                  isfolder = ''
*                  text = text_str
*                exceptions
*                  others = 1.
*              if sy-subrc <> 0.
*                message i054(zcl_plint_message_01)
*                  with key_str text_str parent_node ''.
*              endif.
***            it should never happens
**                MESSAGE i051(zcl_plint_message_01)
**                  WITH key_str text_str start_node  ''.
*            endif.
*          endif.
*        endif.
*      endif.
*    endif.
*  endloop.
*
** alle expandieren
*  call method simple_tree_plotlist->save_expand_all_nodes
*    importing
*      all_nodes_expanded = f_all_nodes_expanded.
*  .
*

ENDFORM.                    " rebuild_tree_plotlist
*&---------------------------------------------------------------------*
*&      Form  get_file_types
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file_types.
* read the allowed filetypes for this user
  DATA: lines TYPE i.

  REFRESH itab_plint_usr_tdwp.
  CLEAR itab_plint_usr_tdwp.
  CLEAR wa_plint_usr_tdwp.


  DATA: wa_group_user LIKE zcl_group_user.

* Vorgehen
* Einzeldaten lesen
* Gruppendaten lesen
* SAP* Daten lesen
*

* Einzeldaten
  SELECT  *  FROM zplint_usr_tdwp
    INTO TABLE itab_plint_usr_tdwp
    WHERE uname = sy-uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Gruppendaten
  SELECT  * FROM zcl_group_user
    INTO wa_group_user
    WHERE uname = sy-uname
    AND status = c_status_aktiv
    .
    SELECT * FROM zcl_group_tdwp
      APPENDING CORRESPONDING FIELDS OF TABLE itab_plint_usr_tdwp
      WHERE user_group = wa_group_user-user_group
      AND status = c_status_aktiv.
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* SAP* Daten
  SELECT  * FROM zcl_group_user
    INTO wa_group_user
    WHERE uname = default_data-default_nutzer
    AND status = c_status_aktiv
    .
    SELECT * FROM zcl_group_tdwp
      APPENDING CORRESPONDING FIELDS OF TABLE itab_plint_usr_tdwp
      WHERE user_group = wa_group_user-user_group
      AND status = c_status_aktiv.
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  REFRESH itab_filetype.
  LOOP AT itab_plint_usr_tdwp INTO wa_plint_usr_tdwp.
    CLEAR wa_tdwp.
    MOVE-CORRESPONDING wa_plint_usr_tdwp TO wa_tdwp.
    APPEND wa_tdwp TO itab_filetype.
  ENDLOOP.

  SORT itab_filetype BY dappl.
  DELETE ADJACENT DUPLICATES FROM itab_filetype
    COMPARING dappl.


ENDFORM.                    " get_file_types
*&---------------------------------------------------------------------*
*&      Form  read_akt_line_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_akt_line_plotlist.
* get the aktual / selected line in the plot list
* check is table is empty
  IF itab_plotjobs IS INITIAL.
    CLEAR wa_akt_plotjobs.
  ELSE.
    CLEAR wa_akt_plotjobs.
    READ TABLE itab_plotjobs INDEX index_itab_plotjobs INTO
      wa_akt_plotjobs.
  ENDIF.


ENDFORM.                    " read_akt_line_plotlist
*&---------------------------------------------------------------------*
*&      Form  refresh_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_plotlist.

  IF grid_plotlist IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CALL METHOD grid_plotlist->refresh_table_display
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


ENDFORM.                    " refresh_plotlist
*&---------------------------------------------------------------------*
*&      Form  del_selected_line_plot_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_selected_line_plot_list.
* it deletes the selected lines in the plot grid
* get the selected line in the plot ALV
  REFRESH itab_et_index_rows_plotlist.
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
  ELSE.
    SORT itab_et_index_rows_plotlist BY index DESCENDING.
    LOOP AT itab_et_index_rows_plotlist
      INTO wa_et_index_rows_plotlist.
      DELETE itab_plotjobs INDEX wa_et_index_rows_plotlist.
    ENDLOOP.
  ENDIF.



ENDFORM.                    " del_selected_line_plot_list
*&---------------------------------------------------------------------*
*&      Form  get_user_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user_values.
* get same user values from configuration tables
**
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).

  CLEAR user_data.
  user_data-uname = sy-uname.


  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = default_data
       IMPORTING
            o_user_data    = user_data.


  g_repid = sy-repid.

  user_data-modus = 'NORMAL'.
  AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
           ID 'ZCL_TA' FIELD sy-tcode
           ID 'ACTVT' FIELD 'L0'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
  .
  IF sy-subrc NE 0.
  ELSE.
    user_data-modus =  'SUPER'.
  ENDIF.


  init = 'X'.

ENDFORM.                    " get_user_values
*&---------------------------------------------------------------------*
*&      Form  get_DBCLK_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_dbclk_node.
* try to get the double clicked node
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).
  DATA: itab_nodes TYPE treemsnota.
  DATA: itab_nodes_tmp TYPE treemsnota.
  DATA: wa_nodes TYPE treemsnodt.
  DATA: wa_nodes_tmp TYPE treemsnodt.
  DATA: node_key_tmp TYPE string.
  DATA: itab_tree_source TYPE treemsnota.
  DATA: itab_found_1 TYPE treemsnota.
  DATA: itab_found_2 TYPE treemsnota.
  DATA: itab_result TYPE treemsnota.
  DATA: wa_tree_source TYPE treemsnodt.
  DATA: wa_found_1 TYPE treemsnodt.
  DATA: wa_found_2 TYPE treemsnodt.
  DATA: wa_result TYPE treemsnodt.

  DATA: itab_sel_tree TYPE treemnotab.
  DATA: wa_sel_tree TYPE tm_nodekey.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  node_key = g_node_key.
  CLEAR properties.

  CALL METHOD simple_tree_plotlist->node_get_properties
    EXPORTING
      node_key       = node_key
    IMPORTING
      properties     = properties
    EXCEPTIONS
      node_not_found = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE i055(zcl_plint_message_01)
        WITH node_key ''  '' ''.
    CLEAR properties.
    EXIT.
  ELSE.
    IF properties-isfolder = 'X'.
*     try to get the tree
      REFRESH itab_tree_source.
      REFRESH itab_found_1.
      REFRESH itab_found_2.
      CALL METHOD simple_tree_plotlist->get_tree
        IMPORTING
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      LOOP AT itab_tree_source INTO wa_tree_source
        WHERE relatkey = node_key.
        APPEND wa_tree_source TO itab_found_1 .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     second step
*     copy
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     third step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fourth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fifth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.

      REFRESH itab_et_index_rows_plotlist.
      CLEAR wa_et_index_rows_plotlist.
      LOOP AT itab_result INTO wa_result.
        SPLIT wa_result-node_key AT '' INTO text1 text2.
        index_itab_plotjobs_tmp = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs_tmp.
        APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.
      ENDLOOP.

      CALL METHOD grid_plotlist->set_selected_rows
        EXPORTING
          it_index_rows = itab_et_index_rows_plotlist
*          IT_ROW_NO     =
          .

      CLEAR wa_akt_plotjobs.

      REFRESH itab_sel_tree.
      CLEAR wa_sel_tree.
      LOOP AT itab_result INTO wa_result.
        wa_sel_tree = wa_result-node_key.
        APPEND wa_sel_tree TO itab_sel_tree.
      ENDLOOP.
      CALL METHOD simple_tree_plotlist->select_nodes
        EXPORTING
          node_key_table               = itab_sel_tree
        EXCEPTIONS
          multiple_node_selection_only = 1
          error_in_node_key_table      = 2
          OTHERS                       = 3
              .
      IF sy-subrc <> 0.
        MESSAGE ID 'W' TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


*      perform set_alv_sel_lines.
      EXIT.
    ELSE.
*     try to get the whole Information
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs = text1.
      READ TABLE itab_plotjobs INDEX index_itab_plotjobs
        INTO wa_akt_plotjobs.
      PERFORM set_alv_sel_line.
    ENDIF.
  ENDIF.



ENDFORM.                    " get_DBCLK_node
*&---------------------------------------------------------------------*
*&      Form  rebuild_tree_plotlist_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rebuild_tree_plotlist_2.
* rebuild the plot list tree with Gruppenstufenverarbeitung
  DATA: l_node_table TYPE treemsnota,
        l_node TYPE treemsnodt,
        l_spfli TYPE spfli,
        l_spfli_tab TYPE SORTED TABLE OF spfli
                    WITH UNIQUE KEY carrid connid.
  DATA: tmp_str TYPE string.
  DATA: text_str TYPE string.
  DATA: key_str TYPE string.
  DATA: itab_plotjobs_tmp TYPE TABLE OF zcl_s_plotlist_1.
  DATA: wa_plotjobs_tmp TYPE zcl_s_plotlist_1.
  DATA: last_dokar TYPE string.
  DATA: last_doknr TYPE string.
  DATA: last_dokvr TYPE string.
  DATA: last_doktl TYPE string.
  DATA: last_filep TYPE string.
  DATA: f_all_nodes_expanded(1).
  DATA: saved_index TYPE string.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  REFRESH itab_plotjobs_tmp.
  CLEAR wa_plotjobs_tmp.
  CLEAR itab_plotjobs_tmp.

  LOOP AT itab_plotjobs INTO wa_plotjobs.
    MOVE-CORRESPONDING wa_plotjobs TO wa_plotjobs_tmp.
    APPEND wa_plotjobs_tmp TO itab_plotjobs_tmp.
  ENDLOOP.

  l_node-hidden = ' '.               " All nodes are visible,
  l_node-disabled = ' '.             " selectable,
  l_node-isfolder = 'X'.             " a folder,
  l_node-expander = ' '.             " have no '+' sign for expansion.

  LOOP AT itab_plotjobs_tmp INTO wa_plotjobs_tmp.
    saved_index = sy-tabix.
    AT NEW dokar.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-dokar.
      CONCATENATE tmp_str text_str INTO key_str.
      l_node-node_key = key_str.
      CLEAR l_node-relatkey.
      CLEAR l_node-relatship.
*  this have to be inserted definitly, cause otherwise it appends in
*  wrong order
      l_node-relatship = simple_tree_plotlist->relat_last_child.
*
      l_node-text = text_str.
      l_node-n_image =   ' '.
      l_node-exp_image = ' '.
      APPEND l_node TO l_node_table.
      last_dokar = key_str.
    ENDAT.
    AT NEW doknr.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-doknr.
      CONCATENATE tmp_str text_str INTO key_str.
      l_node-node_key = key_str.
      l_node-relatkey = last_dokar.
      l_node-relatship = simple_tree_plotlist->relat_last_child.
      l_node-text = text_str.
      APPEND l_node TO l_node_table.
      last_doknr = key_str.
    ENDAT.
    AT NEW dokvr.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-dokvr.
      CONCATENATE tmp_str text_str INTO key_str.
      l_node-node_key = key_str.
      l_node-relatkey = last_doknr.
      l_node-relatship = simple_tree_plotlist->relat_last_child.
      l_node-text = text_str.
      APPEND l_node TO l_node_table.
      last_dokvr = key_str.
    ENDAT.
    AT NEW doktl.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-doktl.
      CONCATENATE tmp_str text_str INTO key_str.
      l_node-node_key = key_str.
      l_node-relatkey = last_dokvr.
      l_node-relatship = simple_tree_plotlist->relat_last_child.
      l_node-text = text_str.
      APPEND l_node TO l_node_table.
      last_doktl = key_str.
    ENDAT.
    AT NEW filep.
*      tmp_str = saved_index.
*      text_str = wa_plotjobs_tmp-filep.
*      CONCATENATE tmp_str text_str INTO key_str.
*      l_node-node_key = key_str.
*      l_node-relatkey = last_doktl.
*      l_node-relatship = simple_tree_plotlist->relat_last_child.
*      l_node-text = text_str.
*      l_node-isfolder = ''.
*      APPEND l_node TO l_node_table.
*      l_node-isfolder = 'X'.
*      last_filep = key_str.
    ENDAT.
*   normale Verarbeitung
    tmp_str = saved_index.
    text_str = wa_plotjobs_tmp-filep.
    CONCATENATE tmp_str text_str INTO key_str.
    l_node-node_key = key_str.
    l_node-relatkey = last_doktl.
    l_node-relatship = simple_tree_plotlist->relat_last_child.
    l_node-text = text_str.
    l_node-isfolder = ''.

*   Failblatt
    IF wa_plotjobs_tmp-knz_fehl_blatt = 'X'.
      l_node-style = cl_tree_model=>style_intensifd_critical.
      l_node-n_image = '@BA@'.  "03/05/0A/0W/BA
      l_node-n_image = user_data-fehlblatt_icon.
    ELSE.
    ENDIF.

*   Spezialdokument
    IF wa_plotjobs_tmp-knz_spez_dok = 'X'.
      l_node-style = cl_tree_model=>style_intensified.
      l_node-n_image = '@03@'.  "03/05/0A/0W/BA
      l_node-n_image = user_data-spez_dok_icon.

      CASE wa_plotjobs_tmp-object_type.
        WHEN c_sl_object_type.
          l_node-style = cl_tree_model=>style_intensified.
          l_node-n_image = user_data-spez_dok_icon_stuecklist.
        WHEN c_fg_object_type.
          l_node-style = cl_tree_model=>style_intensified.
          l_node-n_image = user_data-spez_dok_icon_folge.
        WHEN c_vg_object_type.
          l_node-style = cl_tree_model=>style_intensified.
          l_node-n_image = user_data-spez_dok_icon_vorgang.
        WHEN OTHERS.
      ENDCASE.
    ELSE.
    ENDIF.

*   Multipage
    IF wa_plotjobs_tmp-knz_multi_page = 'X'.
      "l_node-style = cl_tree_model=>style_intensifd_critical.
      "l_node-style = cl_tree_model=>STYLE_EMPHASIZED.
      "l_node-style = cl_tree_model=>STYLE_EMPHASIZED_NEGATIVE.
      "l_node-style = cl_tree_model=>STYLE_EMPHASIZED_POSITIVE.
      "l_node-style = cl_tree_model=>STYLE_INACTIVE.
      "l_node-style = cl_tree_model=>STYLE_INHERITED.
      l_node-style = cl_tree_model=>style_intensified.
      l_node-n_image = '@JG@'.                              "N1/3M/JG
    ELSE.
    ENDIF.

    APPEND l_node TO l_node_table.
    l_node-isfolder = 'X'.
    l_node-style = cl_tree_model=>style_default.
    CLEAR l_node-n_image.
    last_filep = key_str.

  ENDLOOP.

*  LOOP AT l_spfli_tab INTO l_spfli.
*    APPEND l_node TO l_node_table.
*  ENDLOOP.

*  CALL METHOD simple_tree_plotlist->add_nodes
*       EXPORTING table_structure_name = 'ABDEMONODE'
*                 node_table = l_node_table.

*  CALL METHOD simple_tree_plotlist->delete_all_nodes
*      .
*

  CALL METHOD simple_tree_plotlist->add_nodes
    EXPORTING
      node_table          = l_node_table
    EXCEPTIONS
      error_in_node_table = 1
      OTHERS              = 2
          .
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* alle expandieren
  CALL METHOD simple_tree_plotlist->save_expand_all_nodes
    IMPORTING
      all_nodes_expanded = f_all_nodes_expanded.
  .


ENDFORM.                    " rebuild_tree_plotlist_2
*&---------------------------------------------------------------------*
*&      Form  del_item_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_item_tree_plotlist.
* deletes Items from Plottree
* try to get the double clicked node
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).
  DATA: itab_tree_source TYPE treemsnota.
  DATA: itab_found_1 TYPE treemsnota.
  DATA: itab_found_2 TYPE treemsnota.
  DATA: itab_result TYPE treemsnota.
  DATA: wa_tree_source TYPE treemsnodt.
  DATA: wa_found_1 TYPE treemsnodt.
  DATA: wa_found_2 TYPE treemsnodt.
  DATA: wa_result TYPE treemsnodt.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  node_key = g_node_key.
  CLEAR properties.

  CALL METHOD simple_tree_plotlist->node_get_properties
    EXPORTING
      node_key       = node_key
    IMPORTING
      properties     = properties
    EXCEPTIONS
      node_not_found = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE i055(zcl_plint_message_01)
        WITH node_key ''  '' ''.
    CLEAR properties.
    EXIT.
  ELSE.
    IF properties-isfolder = 'X'.
*     try to get the tree
      REFRESH itab_tree_source.
      REFRESH itab_found_1.
      REFRESH itab_found_2.
      CALL METHOD simple_tree_plotlist->get_tree
        IMPORTING
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      LOOP AT itab_tree_source INTO wa_tree_source
        WHERE relatkey = node_key.
        APPEND wa_tree_source TO itab_found_1 .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     second step
*     copy
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     third step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fourth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.
*     fifth step
      REFRESH itab_found_2.
      itab_found_2[] = itab_found_1[].
      REFRESH itab_found_1.
      LOOP AT itab_found_2 INTO wa_found_2.
        LOOP AT itab_tree_source INTO wa_tree_source
          WHERE relatkey = wa_found_2-node_key.
          APPEND wa_tree_source TO itab_found_1 .
        ENDLOOP.
      ENDLOOP.
      REFRESH itab_found_2.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        APPEND wa_found_1 TO itab_result .
      ENDLOOP.
      LOOP AT itab_found_1 INTO wa_found_1
        WHERE isfolder = ''.
        DELETE itab_found_1 INDEX sy-tabix.
      ENDLOOP.

*     delete entries
      REFRESH itab_et_index_rows_plotlist.
      CLEAR wa_et_index_rows_plotlist.
      LOOP AT itab_result INTO wa_result.
        SPLIT wa_result-node_key AT '' INTO text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.

*        DELETE itab_plotjobs INDEX index_itab_plotjobs.
      ENDLOOP.
      SORT itab_et_index_rows_plotlist BY index DESCENDING.
      LOOP AT itab_et_index_rows_plotlist
        INTO wa_et_index_rows_plotlist.
        DELETE itab_plotjobs INDEX wa_et_index_rows_plotlist.
      ENDLOOP.

      EXIT.
    ELSE.
*     try to get the whole Information
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs = text1.
      DELETE itab_plotjobs INDEX index_itab_plotjobs.
    ENDIF.
  ENDIF.


ENDFORM.                    " del_item_tree_plotlist
*&---------------------------------------------------------------------*
*&      Form  clear_plot_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_plot_details.
  CLEAR wa_akt_plotjobs.
ENDFORM.                    " clear_plot_details
*&---------------------------------------------------------------------*
*&      Form  clear_search_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_search_details.
  CLEAR wa_akt_search.
ENDFORM.                    " clear_search_details
*&---------------------------------------------------------------------*
*&      Form  view_document_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_document_02.
* try to view the document

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
      CALL FUNCTION 'Z_CL_PLINT_TOOLS_VIEW_DOC_002'
           EXPORTING
                i_wa_plotjobs = wa_plotjobs
           EXCEPTIONS
                error         = 1
                OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
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

*  CALL FUNCTION 'Z_CL_PLINT_TOOLS_VIEW_DOC_002'
*       EXPORTING
*            i_wa_plotjobs = wa_plotjobs
*       EXCEPTIONS
*            error         = 1
*            OTHERS        = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

ENDFORM.                    " view_document_02
*&---------------------------------------------------------------------*
*&      Form  set_alv_sel_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_alv_sel_line.
* try to set a selection on the ALV after doubleclick in Tree
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).

  node_key = g_node_key.
  CLEAR properties.
  SPLIT node_key AT '' INTO text1 text2.
  index_itab_plotjobs = text1.

  REFRESH itab_et_index_rows_plotlist.
  CLEAR wa_et_index_rows_plotlist.
  wa_et_index_rows_plotlist-index := index_itab_plotjobs.
  APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist .
  CALL METHOD grid_plotlist->set_selected_rows
    EXPORTING
      it_index_rows = itab_et_index_rows_plotlist
*      IT_ROW_NO     =
      .




ENDFORM.                    " set_alv_sel_line
*&---------------------------------------------------------------------*
*&      Form  set_tree_sel_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_tree_sel_node.
* try to select the corresponding node after doublecklick one row in ALV
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1 TYPE string.
  DATA: text2(10).
  DATA: itab_sel_tree TYPE treemnotab.
  DATA: wa_sel_tree TYPE tm_nodekey .

  IF g_show_struktur = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

*  node_key = g_node_key.
  CLEAR properties.
  CLEAR node_key.
  text1 = index_itab_plotjobs.
  SHIFT text1 LEFT DELETING LEADING space.
  CONCATENATE text1 wa_akt_plotjobs-filep
    INTO node_key.
  g_node_key = node_key.

*  CALL METHOD simple_tree_plotlist->set_selected_node
*    EXPORTING
*      node_key                   = node_key
*    EXCEPTIONS
*      single_node_selection_only = 1
*      node_not_found             = 2
*      OTHERS                     = 3
*          .
*  IF sy-subrc <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

  CALL METHOD simple_tree_plotlist->unselect_all
      .

  REFRESH itab_sel_tree.
  CLEAR wa_sel_tree.
  wa_sel_tree = node_key.
  APPEND wa_sel_tree TO itab_sel_tree.

  CALL METHOD simple_tree_plotlist->select_nodes
    EXPORTING
      node_key_table               = itab_sel_tree
    EXCEPTIONS
      multiple_node_selection_only = 1
      error_in_node_key_table      = 2
      OTHERS                       = 3
          .
  IF sy-subrc <> 0.
*    MESSAGE ID 'S' TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



*  SPLIT node_key AT '' INTO text1 text2.
*  index_itab_plotjobs = text1.

ENDFORM.                    " set_tree_sel_node
*&---------------------------------------------------------------------*
*&      Form  get_set_view_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_set_view_program.
* read the filetypes for viewing by this user
  CLEAR wa_view_program.
  SELECT * FROM zcl_plint_usr_vw
  INTO wa_view_program
    WHERE uname = sy-uname
    AND dappl = wa_plotjobs-wsapplication
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    SELECT * FROM zcl_plint_usr_vw
    INTO wa_view_program
      WHERE uname = default_data-default_nutzer
      AND dappl = wa_plotjobs-wsapplication
      .
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i060(zcl_plint_message_01) WITH '2D' '' '' ''.
      wa_view_program-programm = 'EAI 2D'.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

ENDFORM.                    " get_set_view_program
*&---------------------------------------------------------------------*
*&      Form  view_document_03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_document_03.
* try to view the document

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
    WHEN 'URLS'.
      CALL FUNCTION '/CIDEON/OM_ITEM_SHOW_URL'
           EXPORTING
                i_url = wa_plotjobs-url.
    WHEN OTHERS.
      CALL FUNCTION 'Z_CL_PLINT_TOOLS_VIEW_DOC_003'
           EXPORTING
                i_wa_plotjobs = wa_plotjobs
           EXCEPTIONS
                error         = 1
                OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

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

*  CALL FUNCTION 'Z_CL_PLINT_TOOLS_VIEW_DOC_003'
*       EXPORTING
*            i_wa_plotjobs = wa_plotjobs
*       EXCEPTIONS
*            error         = 1
*            OTHERS        = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.


ENDFORM.                    " view_document_03
*&---------------------------------------------------------------------*
*&      Form  view_item_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_item_tree_plotlist.
* deletes Items from Plottree
* try to get the double clicked node
  DATA: properties TYPE treemsnodt.
  DATA: node_key TYPE string.
  DATA: text1(10).
  DATA: text2(10).

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  node_key = g_node_key.
  CLEAR properties.

  CALL METHOD simple_tree_plotlist->node_get_properties
    EXPORTING
      node_key       = node_key
    IMPORTING
      properties     = properties
    EXCEPTIONS
      node_not_found = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE i055(zcl_plint_message_01)
        WITH node_key ''  '' ''.
    CLEAR properties.
    EXIT.
  ELSE.
    IF properties-isfolder = 'X'.
*     try to get the whole Information
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs = text1.
      READ TABLE itab_plotjobs INDEX index_itab_plotjobs
        INTO wa_plotjobs.
    ELSE.
*     try to get the whole Information
      SPLIT node_key AT '' INTO text1 text2.
      index_itab_plotjobs = text1.
      READ TABLE itab_plotjobs INDEX index_itab_plotjobs
        INTO wa_plotjobs.
    ENDIF.
  ENDIF.


ENDFORM.                    " view_item_tree_plotlist
