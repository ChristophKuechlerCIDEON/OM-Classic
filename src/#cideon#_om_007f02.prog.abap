*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_007F02                                    *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  only_last_version
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM only_last_version.
* shows in Search_list only the last Version of dokuments
  DATA: index TYPE i.

  REFRESH itab_search_tmp.
  itab_search_tmp[] = itab_search[].

  LOOP AT itab_search_tmp INTO wa_search_tmp.
    IF wa_search_tmp-dokvr > '00'.
      CLEAR wa_search.
      LOOP AT itab_search_tmp INTO wa_search
        WHERE dokar = wa_search_tmp-dokar
        AND doknr = wa_search_tmp-doknr
        AND doktl = wa_search_tmp-doktl
        .
        index = sy-tabix.
        IF wa_search-dokvr < wa_search_tmp-dokvr.
          DELETE itab_search_tmp INDEX index.
        ELSE.
        ENDIF.
      ENDLOOP.
    ELSE.
      CONTINUE.
    ENDIF.

  ENDLOOP.

  REFRESH itab_search.
  itab_search[] = itab_search_tmp[].

ENDFORM.                    " only_last_version


*---------------------------------------------------------------------*
*       FORM only_released_version                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM only_released_version.
* shows in Search_list only the free Versions of dokuments
  DATA: index TYPE i.

  LOOP AT itab_search INTO wa_search.
    index = sy-tabix.
*    IF wa_search-dokst = default_data-freigabe_status.
*    ELSE.
*      DELETE itab_search INDEX index.
*    ENDIF.

    CALL FUNCTION '/CIDEON/CHECK_STATUS_FREIGABE'
      EXPORTING
        i_dokar  = wa_search-dokar
        i_dokst  = wa_search-dokst
      EXCEPTIONS
        error    = 1
        freigabe = 2
        gesperrt = 3
        normal   = 4
        OTHERS   = 5.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 2.
        WHEN OTHERS.
          DELETE itab_search INDEX index.
      ENDCASE.
    ENDIF.


  ENDLOOP.

ENDFORM.                    " ONLY_FREE_VERSION



*&---------------------------------------------------------------------*
*&      Form  ONLY_FREE_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*form only_free_version.
** shows in Search_list only the free Versions of dokuments
*  data: index type i.
*
*  loop at itab_search into wa_search.
*    index = sy-tabix.
**    IF wa_search-dokst = default_data-freigabe_status.
**    ELSE.
**      DELETE itab_search INDEX index.
**    ENDIF.
*
*    call function '/CIDEON/CHECK_STATUS_FREIGABE'
*         exporting
*              i_dokar  = wa_search-dokar
*              i_dokst  = wa_search-dokst
*         exceptions
*              error    = 1
*              freigabe = 2
*              gesperrt = 3
*              normal   = 4
*              others   = 5.
*    if sy-subrc <> 0.
*      case sy-subrc.
*        when 2.
*        when others.
*          delete itab_search index index.
*      endcase.
*    endif.
*
*
*  endloop.
*
*endform.                    " ONLY_FREE_VERSION
*&---------------------------------------------------------------------*
*&      Form  LAST_FREE_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM last_free_version.
* shows only the last free versions
  "perform only_free_version.
  PERFORM only_released_version.
  PERFORM only_last_version.

ENDFORM.                    " LAST_FREE_VERSION
*&---------------------------------------------------------------------*
*&      Form  process_strategy_a
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_strategy_a.

  CALL FUNCTION 'Z_CL_LIST_FAIL_DOCUMENTS'
    EXPORTING
      i_led_style             = 'X'
      i_speicher_ort_fb_liste = user_data-speicher_ort_fb_liste
      i_knz_static            = user_data-knz_static_fb_liste
      i_trennzeichen          = user_data-trennzeichen_fb_liste
      i_dialog                = user_data-knz_dialog_fb_liste
    TABLES
      i_itab_fail_document    = itab_fail_document
      o_itab_fail_document    = itab_fail_document
    EXCEPTIONS
      error                   = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF itab_fail_document[] IS INITIAL.
    EXIT.
  ELSE.
    REFRESH itab_filetype.
    REFRESH itab_search_tmp.
    REFRESH itab_zori_doc_files.
    REFRESH itab_zori_doc_files_detail.
    CLEAR wa_fail_document.
    LOOP AT itab_fail_document INTO wa_fail_document.
      CLEAR wa_search_tmp.
      MOVE-CORRESPONDING wa_fail_document TO wa_search_tmp.
      APPEND wa_search_tmp TO itab_search_tmp.
    ENDLOOP.

    REFRESH itab_fail_document.

    PERFORM search_tmp_to_draw.

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
    ELSE.
    ENDIF.


    PERFORM draw_to_search_tmp.

    DESCRIBE TABLE itab_zori_doc_files LINES count_lines.
    IF count_lines > 0.
      CALL FUNCTION 'Z_CL_ASK_FAIL_DOCUMENTS_NEW'
        TABLES
          i_itab_zori_doc_files        = itab_zori_doc_files
          i_itab_zori_doc_files_detail = itab_zori_doc_files_detail
          o_itab_zori_doc_files        = itab_zori_doc_files
          o_itab_zori_doc_files_detail = itab_zori_doc_files_detail
        EXCEPTIONS
          error                        = 1
          OTHERS                       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*      PERFORM add_to_plotlist USING ''.
      PERFORM add_to_plotlist_2 USING ''.
      PERFORM refresh_joblist.
      PERFORM rebuild_tree_plotlist.
      tabstripcontrol_001-activetab = 'TAB2'.
      PERFORM clear_plot_details.
    ELSE.
      tabstripcontrol_001-activetab = 'TAB1'.
      MESSAGE i011(zcl_plint_message_01)
        WITH '' '' '' ''.
    ENDIF.
  ENDIF.

ENDFORM.                    " process_strategy_a
*&---------------------------------------------------------------------*
*&      Form  process_strategy_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_strategy_l.

  CALL FUNCTION 'Z_CL_LIST_FAIL_DOCUMENTS'
    EXPORTING
      i_led_style             = 'X'
      i_speicher_ort_fb_liste = user_data-speicher_ort_fb_liste
      i_knz_static            = user_data-knz_static_fb_liste
      i_trennzeichen          = user_data-trennzeichen_fb_liste
      i_dialog                = user_data-knz_dialog_fb_liste
    TABLES
      i_itab_fail_document    = itab_fail_document
      o_itab_fail_document    = itab_fail_document
    EXCEPTIONS
      error                   = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " process_strategy_l
*&---------------------------------------------------------------------*
*&      Form  create_fail_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_fail_items.
* creates fail items for the fail documents
  REFRESH itab_zori_doc_files.
  REFRESH itab_zori_doc_files_detail.

  LOOP AT itab_fail_document INTO wa_fail_document.
    CLEAR wa_zori_doc_files.
    CLEAR wa_zori_doc_files_detail.

    MOVE-CORRESPONDING wa_fail_document TO wa_zori_doc_files.
    MOVE-CORRESPONDING wa_fail_document TO wa_zori_doc_files_detail.

*   Dateiname
    IF wa_zori_doc_files-filep IS INITIAL.
      CONCATENATE wa_zori_doc_files-dokar '/' wa_zori_doc_files-doknr
        '/' wa_zori_doc_files-dokvr '/' wa_zori_doc_files-doktl
        INTO wa_zori_doc_files-filep.
    ELSE.
    ENDIF.

    APPEND wa_zori_doc_files TO itab_zori_doc_files.
    APPEND wa_zori_doc_files_detail TO itab_zori_doc_files_detail.
  ENDLOOP.

*  PERFORM add_to_plotlist USING 'X'.
  PERFORM add_to_plotlist_2 USING 'X'.
  PERFORM refresh_joblist.
  PERFORM rebuild_tree_plotlist.
  tabstripcontrol_001-activetab = 'TAB2'.
  PERFORM clear_plot_details.


ENDFORM.                    " create_fail_items
*&---------------------------------------------------------------------*
*&      Form  reload_properties
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reload_properties.
* makes a reload of the properties
* maybe usefull after a change

  PERFORM get_default_values.
  PERFORM get_user_values.
*  PERFORM get_default_verteiler.
  MESSAGE s071(zcl_plint_message_01)
    WITH '' '' '' ''.

ENDFORM.                    " reload_properties
*&---------------------------------------------------------------------*
*&      Form  delete_duplicates_sl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_duplicates_sl.
* deletes Duplicates from search list
  DATA: index_search TYPE sy-tabix.
  DATA: max_lines TYPE i.
  DATA: p TYPE f.
  DATA: tmp_str(3).
  DATA: tmp_str2(3).
  DATA: i TYPE i.
  DATA: text(50).

  CLEAR wa_akt_search.
  LOOP AT itab_search INTO wa_search.
    index_search = sy-tabix.
    DESCRIBE TABLE itab_search LINES max_lines.
    p =  100 * index_search / max_lines.
    i = p.
    CLEAR tmp_str.
    tmp_str = index_search.
    tmp_str2 = max_lines.
    "concatenate tmp_str ' / ' tmp_str2 ''  text-021 into text.
    CONCATENATE '' text-021 INTO text.
    p = index_search MOD 100.
    IF p = 0.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = i
          text       = text.
    ELSE.
    ENDIF.
    LOOP AT itab_search INTO wa_akt_search
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND dokvr = wa_search-dokvr
      AND doktl = wa_search-doktl
      .
      IF sy-tabix = index_search.
      ELSE.
        DELETE itab_search INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  CLEAR wa_akt_search.

ENDFORM.                    " delete_duplicates_sl
*&---------------------------------------------------------------------*
*&      Form  search_tmp_to_draw
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_tmp_to_draw.
* from itab_search_tmp to itab_draw
  REFRESH itab_draw.

  LOOP AT itab_search_tmp INTO wa_search_tmp.
    MOVE-CORRESPONDING wa_search_tmp TO wa_draw.
    APPEND wa_draw TO itab_draw.
  ENDLOOP.
ENDFORM.                    " search_tmp_to_draw
*&---------------------------------------------------------------------*
*&      Form  draw_to_search_tmp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM draw_to_search_tmp.
* from itab_search to Itab_search_tmp
  REFRESH itab_search_tmp.

  CLEAR wa_search_tmp.

  LOOP AT itab_draw INTO wa_draw.
    MOVE-CORRESPONDING wa_draw TO wa_search_tmp.
    APPEND wa_search_tmp TO itab_search_tmp.
  ENDLOOP.

ENDFORM.                    " draw_to_search_tmp
*&---------------------------------------------------------------------*
*&      Form  make_knz_freigabe_LED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_knz_freigabe_led.
* updates the LED in the searchlist

*  LOOP AT itab_search INTO wa_search.
*    IF wa_search-dokst = default_data-freigabe_status.
*      wa_search-knz_freigabe = 3.
*    ELSE.
*      IF wa_search-dokst = default_data-sperr_status.
*        wa_search-knz_freigabe = 1.
*      ELSE.
*        wa_search-knz_freigabe = 2.
*      ENDIF.
*    ENDIF.
*    MODIFY itab_search FROM wa_search INDEX sy-tabix.
*  ENDLOOP.

  LOOP AT itab_search INTO wa_search.
    CALL FUNCTION '/CIDEON/CHECK_STATUS_FREIGABE'
      EXPORTING
        i_dokar  = wa_search-dokar
        i_dokst  = wa_search-dokst
      EXCEPTIONS
        error    = 1
        freigabe = 2
        gesperrt = 3
        normal   = 4
        OTHERS   = 5.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 2.
          wa_search-knz_freigabe = 3.
        WHEN 3.
          wa_search-knz_freigabe = 1.
        WHEN OTHERS.
          wa_search-knz_freigabe = 2.
      ENDCASE.
    ENDIF.

    MODIFY itab_search FROM wa_search INDEX sy-tabix.
  ENDLOOP.

* /CIDEON/CHECK_STATUS_FREIGABE

ENDFORM.                    " make_knz_freigabe_LED
*&---------------------------------------------------------------------*
*&      Form  read_repro_ini
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_repro_ini.
* read the repro INI

  CALL TRANSACTION 'ZCL_PLINT_UPD_INI'.

ENDFORM.                    " read_repro_ini
*&---------------------------------------------------------------------*
*&      Form  set_alv_sel_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_alv_sel_lines.
* try to set a selection on the ALV after doubleclick in Tree
* several lines
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




ENDFORM.                    " set_alv_sel_lines
*&---------------------------------------------------------------------*
*&      Form  add_APPL_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_appl_fields.
  DATA: tmp_kompression LIKE zcl_comp_tiff-typ_kompression.
  DATA: langu LIKE sy-langu.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*   TYP
    SET LOCALE LANGUAGE langu.
    TRANSLATE wa_plotjobs-typ TO UPPER CASE.
    SET LOCALE LANGUAGE space.
    SELECT SINGLE * FROM zcl_appl_type
      INTO wa_appl_type
      WHERE typ_tiff = wa_plotjobs-typ
      .
    IF sy-subrc NE 0.
      MESSAGE e068(zcl_plint_message_01)
        WITH 'zcl_appl_type' wa_plotjobs-typ '' ''.
    ELSE.
      wa_plotjobs-appl_type = wa_appl_type-appl_typ.
    ENDIF.
*   COMPRESSION
*    translate wa_plotjobs-kompression to UPPER CASE.
    SELECT SINGLE * FROM zcl_appl_comp
      INTO wa_appl_comp
      WHERE typ_kompression = wa_plotjobs-kompression
      .
    IF sy-subrc NE 0.
      MESSAGE e068(zcl_plint_message_01)
        WITH 'zcl_appl_comp' wa_plotjobs-kompression '' ''.
    ELSE.
      wa_plotjobs-appl_comp = wa_appl_comp-appl_comp.
    ENDIF.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.


ENDFORM.                    " add_APPL_fields
*&---------------------------------------------------------------------*
*&      Form  get_dok_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_dok_text.
* ergänzt Dokumententexte
  DATA: wa_drat TYPE drat.

  LOOP AT itab_search INTO wa_search.
    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM drat INTO wa_drat
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND dokvr = wa_search-dokvr
      AND doktl = wa_search-doktl
      AND langu = sy-langu
      .
    IF sy-subrc NE 0.
    ELSE.
      wa_search-dktxt = wa_drat-dktxt.
      wa_search-dktxt_uc = wa_drat-dktxt_uc.
      MODIFY itab_search FROM wa_search INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_dok_text
*&---------------------------------------------------------------------*
*&      Form  save_searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_searchlist.
* saves the Searchlist into a local file
  CALL FUNCTION 'Z_CL_WRITE_SEARCH_FILE'
    EXPORTING
      i_filename        = user_data-searchlist_file
      i_trennzeichen    = user_data-trennzeichen  "'/'
    TABLES
      i_itab_searchlist = itab_search
    EXCEPTIONS
      error             = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " save_searchlist
*&---------------------------------------------------------------------*
*&      Form  open_searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_searchlist.
* read thze searchlist
  DATA: itab_searchlist TYPE TABLE OF zcl_s_docsearch.
  DATA: wa_itab_searchlist TYPE zcl_s_docsearch.

  REFRESH itab_searchlist.

  CALL FUNCTION 'Z_CL_READ_SEARCH_FILE'
    EXPORTING
      i_filename     = user_data-searchlist_file
      i_trennzeichen = user_data-trennzeichen  "'/'
    TABLES
      o_itab_search  = itab_searchlist
    EXCEPTIONS
      error          = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT itab_searchlist INTO wa_itab_searchlist.
    "2014/11/10 - Setzen des SL Kennzeichens
    wa_itab_searchlist-f_from_sl_csv = abap_true.
    APPEND wa_itab_searchlist TO itab_search.
  ENDLOOP.

ENDFORM.                    " open_searchlist
*&---------------------------------------------------------------------*
*&      Form  recalc_searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM recalc_searchlist.
* recalculates the searchlist
  DATA: index_search TYPE sy-tabix.

  LOOP AT itab_search INTO wa_search.
    index_search = sy-tabix.
    SELECT SINGLE * FROM draw INTO wa_draw
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND dokvr = wa_search-dokvr
      AND doktl = wa_search-doktl
      .
    IF sy-subrc NE 0.
    ELSE.
      MOVE-CORRESPONDING wa_draw TO wa_search.
      MODIFY itab_search FROM wa_search INDEX index_search.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " recalc_searchlist
*&---------------------------------------------------------------------*
*&      Form  appl_log_write
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3339   text
*      -->P_3340   text
*      -->P_3341   text
*      -->P_3342   text
*      -->P_PNAME  text
*      -->P_3344   text
*      -->P_3345   text
*----------------------------------------------------------------------*
FORM appl_log_write USING    value(typ)
                             value(nummer)
                             value(klasse)
                             value(message1)
                             value(message2)
                             value(message3)
                             value(message4).
  DATA: number(3) TYPE n.
  DATA: msgno TYPE symsgno.

  CLEAR msgv1.
  CLEAR msgv2.
  CLEAR msgv3.
  CLEAR msgv4.
  msgv1 = message1.
  msgv2 = message2.
  msgv3 = message3.
  msgv4 = message4.
  number = nummer.
  msgno = nummer.

  CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
    EXPORTING
      i_object   = 'Z_CIDEON'
      i_subobj   = 'Z_PLOT'
      i_number   = msgno
      i_msgtyp   = typ
      i_msgid    = klasse
      i_msgno    = msgno
      i_msgv1    = msgv1
      i_msgv2    = msgv2
      i_msgv3    = msgv3
      i_msgv4    = msgv4
      i_class    = ' '
      i_newhead  = ' '
      i_messhead = ' '
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " appl_log_write
*&---------------------------------------------------------------------*
*&      Form  get_stamp_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stamp_values.
* get the values for the stamps
  DATA: index_itab_plotjobs_2 TYPE sy-tabix.
* itab_tmp_plotjobs_2
* itab_stempel_wert

  CALL FUNCTION '/CIDEON/GET_STAMP_DATA'
    EXPORTING
      i_nutzer          = sy-uname
      i_default_nutzer  = default_data-default_nutzer
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
  EXIT.


*  refresh itab_stempel_default.
*  select * from zcl_stamp_defaul
*    into table itab_stempel_default
*    where status = c_status_aktiv
*    .
*  if sy-subrc ne 0.
*  else.
*  endif.
*
*  refresh itab_stempel_user.
*  select * from zcl_stamp_user
*    into table itab_stempel_user
*    where status = c_status_aktiv
*    and uname = sy-uname
*    .
*  if sy-subrc ne 0.
*  else.
*  endif.
*
*
*  refresh itab_stempel_wert.
*
*  loop at itab_tmp_plotjobs_2 into wa_plotjobs.
*    refresh itab_stempel_voreinstellung.
*    select * from zcl_stamp_vorein
*      into table itab_stempel_voreinstellung
*      where status = c_status_aktiv
*      and voreinstellung = wa_plotjobs-voreinstellung
*      .
*    if sy-subrc ne 0.
*    else.
*    endif.
*    if user_data-knz_use_post = 'X'.
*    else.
*      "bei CLF bei Voreinstellungen
*      refresh itab_stempel_voreinstellung.
*    endif.
*
*    refresh itab_stempel_verteiler.
*    select * from zcl_stamp_vertei
*      into table itab_stempel_verteiler
*      where status = c_status_aktiv
*      and verteiler = wa_plotjobs-verteiler
*      .
*    if sy-subrc ne 0.
*    else.
*    endif.
*
*
*    index_itab_plotjobs_2 = sy-tabix.
*
**   default stamps
*    loop at itab_stempel_default into wa_stempel_default.
*      clear wa_stempel_wert.
**     " check for FB
**     " created
*      select single * from tfdir
*        where funcname = wa_stempel_default-fm_name
*        .
*      if sy-subrc ne 0.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '080' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
*        continue.
*      else.
*      endif.
**     " active
*      select single * from rsinfdir
*        where funcname = wa_stempel_default-fm_name
*        .
*      if sy-subrc ne 0.
*      else.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '081' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
*        continue.
*      endif.
*      call function wa_stempel_default-fm_name
*           exporting
*                i_wa_plotjobs  = wa_plotjobs
*           importing
*                o_stempel_wert = wa_stempel_wert-stempel_wert
*           exceptions
*                error          = 1
*                others         = 2.
*      if sy-subrc <> 0.
*        "LOG Eintrag
*      else.
*        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
*        wa_stempel_wert-stempel_name = wa_stempel_default-stempel_name.
*        append wa_stempel_wert to itab_stempel_wert .
*      endif.
*    endloop.
*
**   user stamps
*    loop at itab_stempel_user into wa_stempel_user.
*      clear wa_stempel_wert.
**     " check for FB
**     " created
*      select single * from tfdir
*        where funcname = wa_stempel_user-fm_name
*        .
*      if sy-subrc ne 0.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '080' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
*        continue.
*      else.
*      endif.
**     " active
*      select single * from rsinfdir
*        where funcname = wa_stempel_user-fm_name
*        .
*      if sy-subrc ne 0.
*      else.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '081' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
*        continue.
*      endif.
*      call function wa_stempel_user-fm_name
*           exporting
*                i_wa_plotjobs  = wa_plotjobs
*           importing
*                o_stempel_wert = wa_stempel_wert-stempel_wert
*           exceptions
*                error          = 1
*                others         = 2.
*      if sy-subrc <> 0.
*        "LOG Eintrag
*      else.
*        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
*        wa_stempel_wert-stempel_name = wa_stempel_user-stempel_name.
*        append wa_stempel_wert to itab_stempel_wert .
*      endif.
*    endloop.
*
**   Voreinstellung stamps
*    loop at itab_stempel_voreinstellung into wa_stempel_voreinstellung.
*      clear wa_stempel_wert.
**     " check for FB
**     " created
*      select single * from tfdir
*        where funcname = wa_stempel_voreinstellung-fm_name
*        .
*      if sy-subrc ne 0.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '080' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_voreinstellung-fm_name 'zcl_stamp_vor'  '' ''.
*        continue.
*      else.
*      endif.
**     " active
*      select single * from rsinfdir
*        where funcname = wa_stempel_voreinstellung-fm_name
*        .
*      if sy-subrc ne 0.
*      else.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '081' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_voreinstellung-fm_name 'zcl_stamp_user'  '' ''.
*        continue.
*      endif.
*      call function wa_stempel_user-fm_name
*           exporting
*                i_wa_plotjobs  = wa_plotjobs
*           importing
*                o_stempel_wert = wa_stempel_wert-stempel_wert
*           exceptions
*                error          = 1
*                others         = 2.
*      if sy-subrc <> 0.
*        "LOG Eintrag
*      else.
*        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
*        wa_stempel_wert-stempel_name =
*          wa_stempel_voreinstellung-stempel_name.
*        append wa_stempel_wert to itab_stempel_wert .
*      endif.
*    endloop.
*
**   Verteiler stamps
*    loop at itab_stempel_verteiler into wa_stempel_verteiler.
*      clear wa_stempel_wert.
**     " check for FB
**     " created
*      select single * from tfdir
*        where funcname = wa_stempel_verteiler-fm_name
*        .
*      if sy-subrc ne 0.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '080' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_verteiler-fm_name 'zcl_stamp_vert'  '' ''.
*        continue.
*      else.
*      endif.
**     " active
*      select single * from rsinfdir
*        where funcname = wa_stempel_verteiler-fm_name
*        .
*      if sy-subrc ne 0.
*      else.
*        "LOG Eintrag
*        perform appl_log_write using
*          'E' '081' 'ZCL_PLINT_MESSAGE_01'
*           wa_stempel_verteiler-fm_name 'zcl_stamp_user'  '' ''.
*        continue.
*      endif.
*      call function wa_stempel_user-fm_name
*           exporting
*                i_wa_plotjobs  = wa_plotjobs
*           importing
*                o_stempel_wert = wa_stempel_wert-stempel_wert
*           exceptions
*                error          = 1
*                others         = 2.
*      if sy-subrc <> 0.
*        "LOG Eintrag
*      else.
*        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
*        wa_stempel_wert-stempel_name =
*          wa_stempel_verteiler-stempel_name.
*        append wa_stempel_wert to itab_stempel_wert .
*      endif.
*    endloop.
*  endloop.
ENDFORM.                    " get_stamp_values
*&---------------------------------------------------------------------*
*&      Form  show_dokumentation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_dokumentation.
  DATA: url TYPE filep.

  IF user_data-knz_show_html_help = 'X'.
    url = user_data-html_help_path.
    CALL FUNCTION 'Z_CL_VIEW_HTML_HELP'
      EXPORTING
        i_filename = url
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    CALL FUNCTION 'HELPSCREEN_CREATE'
      EXPORTING
        doku_id           = 'RE'
        doku_objekt       = 'ZCL_PLINT_DESIGN_007'
*     DYNPRO            = ' '
*     HEADERTEXT        = ' '
        langu             = sy-langu
*     PFKEY             = ' '
*     PROGRAMM          = ' '
        titel             = sy-title
              .
  ENDIF.

ENDFORM.                    " show_dokumentation
*&---------------------------------------------------------------------*
*&      Form  reindex_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reindex_table.
* make an reindex for the plot table
  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-cont = sy-tabix.
    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.
ENDFORM.                    " reindex_table
*&---------------------------------------------------------------------*
*&      Form  check_exist_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_exist_files.
* checks if there are not existing files in the plotjob entries like
* local files that are not checked in
  DATA: f_exist(1) VALUE ''.
  DATA: f_isdir(1) VALUE ''.
  DATA: filename_tmp TYPE file_name.
  DATA: index_plotjobs TYPE sy-tabix.

  LOOP AT itab_plotjobs INTO wa_plotjobs.
    index_plotjobs = sy-tabix.
    IF wa_plotjobs-checked IS INITIAL.
*     check for existenz
      IF wa_plotjobs-knz_spez_dok = 'X'.
        CONTINUE.
      ELSE.
      ENDIF.

      filename_tmp = wa_plotjobs-filep.
      CLEAR f_exist.
      CLEAR f_isdir.

      CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
        EXPORTING
          fname          = filename_tmp
        IMPORTING
          exist          = f_exist
          isdir          = f_isdir
        EXCEPTIONS
          fileinfo_error = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        "APPL LOG

        "MESSAGE s072(zcl_plint_message_01)
        "  WITH filename_tmp '' '' ''.
      ELSE.
        IF f_exist IS INITIAL.
          "MESSAGE s061(zcl_plint_message_01)
          " WITH filename_tmp '' '' ''.
          wa_plotjobs-knz_fehl_blatt = 'X'.
          "wa_plotjobs-light = 1.
          wa_plotjobs-icon_fehlblatt = user_data-fehlblatt_icon.
          MODIFY itab_plotjobs FROM wa_plotjobs INDEX index_plotjobs.
        ELSE.
        ENDIF.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " check_exist_files
*&---------------------------------------------------------------------*
*&      Form  reselect_plotlist_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reselect_plotlist_entries.
* make an Reselect after the Refresh of the internal table
  CALL METHOD grid_plotlist->set_selected_rows
    EXPORTING
      it_index_rows = itab_et_index_rows_plotlist
*      IT_ROW_NO     =
      .


ENDFORM.                    " reselect_plotlist_entries
*&---------------------------------------------------------------------*
*&      Form  ask_before_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ask_before_delete CHANGING  value(answer).
  DATA: ev_answer(1).

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel          = text-pt3
      textline1      = text-p04
      defaultoption  = 'J'
      cancel_display = ''
    IMPORTING
      answer         = ev_answer.

  CLEAR answer.
  answer = ev_answer.


ENDFORM.                    " ask_before_delete
*&---------------------------------------------------------------------*
*&      Form  ask_before_leave
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ask_before_leave .
  DATA: ev_answer(1).

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel          = text-pt3
      textline1      = text-p05                       "text-p01
      textline2      = text-p02
      defaultoption  = 'N'
      cancel_display = ''
    IMPORTING
      answer         = ev_answer.

  IF ev_answer = 'J'.
    PERFORM clean_up.
    LEAVE TO SCREEN 0.
  ELSE.
  ENDIF.

ENDFORM.                    " ask_before_leave
*&---------------------------------------------------------------------*
*&      Form  check_for_multipage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_multipage.
*
*ITAB
  DATA: itab_page_format TYPE TABLE OF zcl_orig_format.
*WA
  DATA: wa_page_format TYPE zcl_orig_format.

  REFRESH itab_tmp_plotjobs_3.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*   Check for existence
    SELECT SINGLE * FROM zcl_orig_format INTO wa_page_format
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      AND wsapplication = wa_plotjobs-wsapplication
      AND docfile  = wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    IF sy-subrc NE 0.
      APPEND wa_plotjobs TO itab_tmp_plotjobs_3.
      CONTINUE.
    ELSE.
    ENDIF.

    REFRESH itab_page_format.
*   get the intervals
    SELECT * FROM zcl_orig_format INTO TABLE itab_page_format
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      AND wsapplication = wa_plotjobs-wsapplication
      AND docfile  = wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
    ENDIF.

    LOOP AT itab_page_format INTO wa_page_format.
      wa_plotjobs-knz_multi_page = 'X'.
      wa_plotjobs-seite_von = wa_page_format-pagefrom.
      wa_plotjobs-seite_bis = wa_page_format-pageto.
      wa_plotjobs-format_ausgabe = wa_page_format-pageformat.
      APPEND wa_plotjobs TO itab_tmp_plotjobs_3.
    ENDLOOP.


  ENDLOOP.

  REFRESH itab_tmp_plotjobs.
  LOOP AT itab_tmp_plotjobs_3 INTO wa_plotjobs.
    APPEND wa_plotjobs TO itab_tmp_plotjobs.
  ENDLOOP.

  REFRESH itab_tmp_plotjobs_3.

ENDFORM.                    " check_for_multipage
*&---------------------------------------------------------------------*
*&      Form  reindex_table_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reindex_table_2.
* make an reindex for the plot table
  LOOP AT itab_plotjobs INTO wa_plotjobs.
    wa_plotjobs-cont = sy-tabix.
    MODIFY itab_plotjobs FROM wa_plotjobs INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " reindex_table_2
*&---------------------------------------------------------------------*
*&      Form  show_versions_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_versions_info.
* shows the version informations


  CALL FUNCTION 'Z_CL_SHOW_VERSIONS_INFO_SCREEN'
   EXPORTING
     id                = 'PLOT_001'
     i_wa_info         = wa_info
*     I_USE_TILL        = g_USE_TILL
*   IMPORTING
*     O_URL             = ''
   TABLES
     i_itab_info       = itab_info
     i_itab_info_pa    = itab_info_pa
   EXCEPTIONS
     error             = 1
     OTHERS            = 2
            .
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " show_versions_info
*&---------------------------------------------------------------------*
*&      Form  ask_for_filter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ask_for_filter.
* get the filter values
  DATA: format_ausgabe TYPE zcl_s_plotlist-format_ausgabe.
  DATA: count TYPE i.

  CALL FUNCTION 'Z_CL_ASK_FOR_SELECTION'
    IMPORTING
      o_format_ausgabe = format_ausgabe
    EXCEPTIONS
      error            = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF format_ausgabe IS INITIAL.
  ELSE.
    REFRESH itab_et_index_rows_plotlist .
    CLEAR wa_et_index_rows_plotlist.
    LOOP AT itab_plotjobs INTO wa_plotjobs
      WHERE format_ausgabe = format_ausgabe.
      wa_et_index_rows_plotlist-index =  sy-tabix.
      APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist .
    ENDLOOP.

    IF itab_et_index_rows_plotlist[] IS INITIAL.
      MESSAGE s090(zcl_plint_message_01)
        WITH text-090 format_ausgabe '' ''.
    ELSE.
      CALL METHOD grid_plotlist->set_selected_rows
        EXPORTING
          it_index_rows = itab_et_index_rows_plotlist.
      DESCRIBE TABLE itab_et_index_rows_plotlist LINES count.
      MESSAGE s091(zcl_plint_message_01)
        WITH count text-090 format_ausgabe '' .
    ENDIF.
  ENDIF.


ENDFORM.                    " ask_for_filter
*&---------------------------------------------------------------------*
*&      Form  get_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_matnr.
* get the material and the status
  DATA: wa_drad TYPE drad.
  DATA: mat_count TYPE i.

  IF user_data-knz_get_material IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_search INTO wa_search.

    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    CLEAR wa_drad.
    SELECT SINGLE  * FROM drad INTO wa_drad
      WHERE dokar = wa_search-dokar
      AND doknr = wa_search-doknr
      AND dokvr = wa_search-dokvr
      AND doktl = wa_search-doktl
      AND dokob = 'MARA'
      .
    IF sy-subrc NE 0.
    ELSE.
      CLEAR mat_count.
      mat_count = 1.
      SELECT COUNT( * ) FROM drad INTO mat_count
        WHERE dokar = wa_search-dokar
        AND doknr = wa_search-doknr
        AND dokvr = wa_search-dokvr
        AND doktl = wa_search-doktl
        AND dokob = 'MARA'
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
      wa_search-mat_count = mat_count.

      " KMO
      " 2009/07/22
      " Materialnummer wird nur
      IF mat_count = '1'.
        wa_search-matnr = wa_drad-objky.
      ELSE.
        IF wa_search-matnr IS INITIAL.
          wa_search-matnr = wa_drad-objky.
        ELSE.
        ENDIF.
      ENDIF.

      SELECT SINGLE mstae mstde  FROM mara
        INTO (wa_search-mstae, wa_search-mstde )
        WHERE matnr = wa_search-matnr.
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      MODIFY itab_search FROM wa_search INDEX sy-tabix.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " get_matnr
*&---------------------------------------------------------------------*
*&      Form  make_mat_status_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_mat_status_icon.
* updates the Icon in the searchlist for Material Status
  DATA: index_search TYPE sy-tabix.
  DATA: f_found.

  LOOP AT itab_search INTO wa_search.
    index_search = sy-tabix.
    IF wa_search-matnr IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

    IF wa_search-mstde <= sy-datum.
    ELSE.
      CONTINUE.
    ENDIF.

    CLEAR f_found.
    LOOP AT itab_mat_status_exc INTO wa_mat_status_exc.
      IF wa_mat_status_exc = wa_search-mstae.
        wa_search-mat_status = user_data-mat_status_icon.
        "03/05/0A/0W/BA
        f_found = 'X'.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    IF f_found IS INITIAL.
    ELSE.
      MODIFY itab_search FROM wa_search INDEX index_search.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " make_mat_status_icon
*&---------------------------------------------------------------------*
*&      Form  ONLY_GOOD_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM only_good_material.
* shows in Search_list only documents that related to good materials
  DATA: index TYPE i.

  LOOP AT itab_search INTO wa_search.
    index = sy-tabix.
    IF wa_search-mat_status IS INITIAL.
    ELSE.
      DELETE itab_search INDEX index.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ONLY_GOOD_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  sel_tree_to_sel_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_tree_to_sel_list.
* get the selection from the tree and change the corresponding in the
* plotlist
  DATA: itab_node_key TYPE treemnotab.
  DATA: wa_node_key TYPE tm_nodekey .
  DATA: text1(10).
  DATA: text2(10).
  DATA: index_itab_plotjobs_tmp TYPE sy-tabix.

  IF simple_tree_plotlist IS INITIAL.
    PERFORM create_and_init_tree.
  ELSE.
  ENDIF.

  REFRESH itab_node_key.

  CALL METHOD simple_tree_plotlist->get_selected_nodes
    IMPORTING
      node_key_table               = itab_node_key
    EXCEPTIONS
      control_not_existing         = 1
      control_dead                 = 2
      cntl_system_error            = 3
      failed                       = 4
      multiple_node_selection_only = 5
      OTHERS                       = 6.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  REFRESH itab_et_index_rows_plotlist.
  CLEAR wa_et_index_rows_plotlist.
  LOOP AT itab_node_key INTO wa_node_key.
    SPLIT wa_node_key AT '' INTO text1 text2.
    index_itab_plotjobs_tmp = text1.
    wa_et_index_rows_plotlist-index = index_itab_plotjobs_tmp.
    APPEND wa_et_index_rows_plotlist TO itab_et_index_rows_plotlist.
  ENDLOOP.

  CALL METHOD grid_plotlist->set_selected_rows
    EXPORTING
      it_index_rows = itab_et_index_rows_plotlist
*          IT_ROW_NO     =
      .



ENDFORM.                    " sel_tree_to_sel_list
*&---------------------------------------------------------------------*
*&      Form  get_sel_tree_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sel_tree_2.

ENDFORM.                    " get_sel_tree_2
*&---------------------------------------------------------------------*
*&      Form  maintain_prio
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_prio.
  CALL TRANSACTION 'Z_CL_MAINT_PRIO'.
ENDFORM.                    " maintain_prio
