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
form only_last_version.
* shows in Search_list only the last Version of dokuments
  data: index type i.

  refresh itab_search_tmp.
  itab_search_tmp[] = itab_search[].

  loop at itab_search_tmp into wa_search_tmp.
    if wa_search_tmp-dokvr > '00'.
      clear wa_search.
      loop at itab_search_tmp into wa_search
        where dokar = wa_search_tmp-dokar
        and doknr = wa_search_tmp-doknr
        and doktl = wa_search_tmp-doktl
        .
        index = sy-tabix.
        if wa_search-dokvr < wa_search_tmp-dokvr.
          delete itab_search_tmp index index.
        else.
        endif.
      endloop.
    else.
      continue.
    endif.

  endloop.

  refresh itab_search.
  itab_search[] = itab_search_tmp[].

endform.                    " only_last_version
*&---------------------------------------------------------------------*
*&      Form  ONLY_FREE_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form only_free_version.
* shows in Search_list only the free Versions of dokuments
  data: index type i.

  loop at itab_search into wa_search.
    index = sy-tabix.
*    IF wa_search-dokst = default_data-freigabe_status.
*    ELSE.
*      DELETE itab_search INDEX index.
*    ENDIF.

    call function '/CIDEON/CHECK_STATUS_FREIGABE'
         exporting
              i_dokar  = wa_search-dokar
              i_dokst  = wa_search-dokst
         exceptions
              error    = 1
              freigabe = 2
              gesperrt = 3
              normal   = 4
              others   = 5.
    if sy-subrc <> 0.
      case sy-subrc.
        when 2.
        when others.
          delete itab_search index index.
      endcase.
    endif.


  endloop.

endform.                    " ONLY_FREE_VERSION
*&---------------------------------------------------------------------*
*&      Form  LAST_FREE_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form last_free_version.
* shows only the last free versions
  perform only_free_version.
  perform only_last_version.

endform.                    " LAST_FREE_VERSION
*&---------------------------------------------------------------------*
*&      Form  process_strategy_a
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form process_strategy_a.

  call function 'Z_CL_LIST_FAIL_DOCUMENTS'
       exporting
            i_led_style             = 'X'
            i_speicher_ort_fb_liste = user_data-speicher_ort_fb_liste
            i_knz_static            = user_data-knz_static_fb_liste
            i_trennzeichen          = user_data-trennzeichen_fb_liste
            i_dialog                = user_data-knz_dialog_fb_liste
       tables
            i_itab_fail_document    = itab_fail_document
            o_itab_fail_document    = itab_fail_document
       exceptions
            error                   = 1
            others                  = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  if itab_fail_document[] is initial.
    exit.
  else.
    refresh itab_filetype.
    refresh itab_search_tmp.
    refresh itab_zori_doc_files.
    refresh itab_zori_doc_files_detail.
    clear wa_fail_document.
    loop at itab_fail_document into wa_fail_document.
      clear wa_search_tmp.
      move-corresponding wa_fail_document to wa_search_tmp.
      append wa_search_tmp to itab_search_tmp.
    endloop.

    refresh itab_fail_document.

    perform search_tmp_to_draw.

    call function 'Z_DMS_PROC_DOC_FILES'
     exporting
*         CALLED_FROM              =
       testmode                 = ''
     tables
       it_zori_doc_files        = itab_zori_doc_files
       it_bapi_doc_files2       = itab_zori_doc_files_detail
       tdraw                    = itab_draw
       itab_filetype            = itab_filetype
       it_fail_document         = itab_fail_document
     exceptions
       error   = 1
       abort   = 2
       others  = 3
              .
    if sy-subrc ne 0.
    else.
    endif.


    perform draw_to_search_tmp.

    describe table itab_zori_doc_files lines count_lines.
    if count_lines > 0.
      call function 'Z_CL_ASK_FAIL_DOCUMENTS_NEW'
       tables
         i_itab_zori_doc_files              = itab_zori_doc_files
         i_itab_zori_doc_files_detail       = itab_zori_doc_files_detail
         o_itab_zori_doc_files              = itab_zori_doc_files
         o_itab_zori_doc_files_detail       = itab_zori_doc_files_detail
       exceptions
         error                              = 1
         others                             = 2
                .
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

*      PERFORM add_to_plotlist USING ''.
      perform add_to_plotlist_2 using ''.
      perform refresh_joblist.
      perform rebuild_tree_plotlist.
      tabstripcontrol_001-activetab = 'TAB2'.
      perform clear_plot_details.
    else.
      tabstripcontrol_001-activetab = 'TAB1'.
      message i011(zcl_plint_message_01)
        with '' '' '' ''.
    endif.
  endif.

endform.                    " process_strategy_a
*&---------------------------------------------------------------------*
*&      Form  process_strategy_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form process_strategy_l.

  call function 'Z_CL_LIST_FAIL_DOCUMENTS'
       exporting
            i_led_style             = 'X'
            i_speicher_ort_fb_liste = user_data-speicher_ort_fb_liste
            i_knz_static            = user_data-knz_static_fb_liste
            i_trennzeichen          = user_data-trennzeichen_fb_liste
            i_dialog                = user_data-knz_dialog_fb_liste
       tables
            i_itab_fail_document    = itab_fail_document
            o_itab_fail_document    = itab_fail_document
       exceptions
            error                   = 1
            others                  = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " process_strategy_l
*&---------------------------------------------------------------------*
*&      Form  create_fail_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_fail_items.
* creates fail items for the fail documents
  refresh itab_zori_doc_files.
  refresh itab_zori_doc_files_detail.

  loop at itab_fail_document into wa_fail_document.
    clear wa_zori_doc_files.
    clear wa_zori_doc_files_detail.

    move-corresponding wa_fail_document to wa_zori_doc_files.
    move-corresponding wa_fail_document to wa_zori_doc_files_detail.

*   Dateiname
    if wa_zori_doc_files-filep is initial.
      concatenate wa_zori_doc_files-dokar '/' wa_zori_doc_files-doknr
        '/' wa_zori_doc_files-dokvr '/' wa_zori_doc_files-doktl
        into wa_zori_doc_files-filep.
    else.
    endif.

    append wa_zori_doc_files to itab_zori_doc_files.
    append wa_zori_doc_files_detail to itab_zori_doc_files_detail.
  endloop.

*  PERFORM add_to_plotlist USING 'X'.
  perform add_to_plotlist_2 using 'X'.
  perform refresh_joblist.
  perform rebuild_tree_plotlist.
  tabstripcontrol_001-activetab = 'TAB2'.
  perform clear_plot_details.


endform.                    " create_fail_items
*&---------------------------------------------------------------------*
*&      Form  reload_properties
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form reload_properties.
* makes a reload of the properties
* maybe usefull after a change

  perform get_default_values.
  perform get_user_values.
*  PERFORM get_default_verteiler.
  message s071(zcl_plint_message_01)
    with '' '' '' ''.

endform.                    " reload_properties
*&---------------------------------------------------------------------*
*&      Form  delete_duplicates_sl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form delete_duplicates_sl.
* deletes Duplicates from search list
  data: index_search type sy-tabix.
  data: max_lines type i.
  data: p type f.
  data: tmp_str(3).
  data: tmp_str2(3).
  data: i type i.
  data: text(50).

  clear wa_akt_search.
  loop at itab_search into wa_search.
    index_search = sy-tabix.
    describe table itab_search lines max_lines.
    p =  100 * index_search / max_lines.
    i = p.
    clear tmp_str.
    tmp_str = index_search.
    tmp_str2 = max_lines.
    "concatenate tmp_str ' / ' tmp_str2 ''  text-021 into text.
    concatenate '' text-021 into text.
    p = index_search mod 100.
    if p = 0.
      call function 'SAPGUI_PROGRESS_INDICATOR'
           exporting
                percentage = i
                text       = text.
    else.
    endif.
    loop at itab_search into wa_akt_search
      where dokar = wa_search-dokar
      and doknr = wa_search-doknr
      and dokvr = wa_search-dokvr
      and doktl = wa_search-doktl
      .
      if sy-tabix = index_search.
      else.
        delete itab_search index sy-tabix.
      endif.
    endloop.
  endloop.

  clear wa_akt_search.

endform.                    " delete_duplicates_sl
*&---------------------------------------------------------------------*
*&      Form  search_tmp_to_draw
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form search_tmp_to_draw.
* from itab_search_tmp to itab_draw
  refresh itab_draw.

  loop at itab_search_tmp into wa_search_tmp.
    move-corresponding wa_search_tmp to wa_draw.
    append wa_draw to itab_draw.
  endloop.
endform.                    " search_tmp_to_draw
*&---------------------------------------------------------------------*
*&      Form  draw_to_search_tmp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form draw_to_search_tmp.
* from itab_search to Itab_search_tmp
  refresh itab_search_tmp.

  clear wa_search_tmp.

  loop at itab_draw into wa_draw.
    move-corresponding wa_draw to wa_search_tmp.
    append wa_search_tmp to itab_search_tmp.
  endloop.

endform.                    " draw_to_search_tmp
*&---------------------------------------------------------------------*
*&      Form  make_knz_freigabe_LED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_knz_freigabe_led.
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

  loop at itab_search into wa_search.
    call function '/CIDEON/CHECK_STATUS_FREIGABE'
         exporting
              i_dokar  = wa_search-dokar
              i_dokst  = wa_search-dokst
         exceptions
              error    = 1
              freigabe = 2
              gesperrt = 3
              normal   = 4
              others   = 5.
    if sy-subrc <> 0.
      case sy-subrc.
        when 2.
          wa_search-knz_freigabe = 3.
        when 3.
          wa_search-knz_freigabe = 1.
        when others.
          wa_search-knz_freigabe = 2.
      endcase.
    endif.

    modify itab_search from wa_search index sy-tabix.
  endloop.

* /CIDEON/CHECK_STATUS_FREIGABE

endform.                    " make_knz_freigabe_LED
*&---------------------------------------------------------------------*
*&      Form  read_repro_ini
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_repro_ini.
* read the repro INI

  call transaction 'ZCL_PLINT_UPD_INI'.

endform.                    " read_repro_ini
*&---------------------------------------------------------------------*
*&      Form  set_alv_sel_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_alv_sel_lines.
* try to set a selection on the ALV after doubleclick in Tree
* several lines
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).

  node_key = g_node_key.
  clear properties.
  split node_key at '' into text1 text2.
  index_itab_plotjobs = text1.

  refresh itab_et_index_rows_plotlist.
  clear wa_et_index_rows_plotlist.
  wa_et_index_rows_plotlist-index := index_itab_plotjobs.
  append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist .
  call method grid_plotlist->set_selected_rows
    exporting
      it_index_rows = itab_et_index_rows_plotlist
*      IT_ROW_NO     =
      .




endform.                    " set_alv_sel_lines
*&---------------------------------------------------------------------*
*&      Form  add_APPL_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_appl_fields.
  data: tmp_kompression like zcl_comp_tiff-typ_kompression.
  data: langu like sy-langu.

  loop at itab_tmp_plotjobs into wa_plotjobs.
*   TYP
    set locale language langu.
    translate wa_plotjobs-typ to upper case.
    set locale language space.
    select single * from zcl_appl_type
      into wa_appl_type
      where typ_tiff = wa_plotjobs-typ
      .
    if sy-subrc ne 0.
      message e068(zcl_plint_message_01)
        with 'zcl_appl_type' wa_plotjobs-typ '' ''.
    else.
      wa_plotjobs-appl_type = wa_appl_type-appl_typ.
    endif.
*   COMPRESSION
*    translate wa_plotjobs-kompression to UPPER CASE.
    select single * from zcl_appl_comp
      into wa_appl_comp
      where typ_kompression = wa_plotjobs-kompression
      .
    if sy-subrc ne 0.
      message e068(zcl_plint_message_01)
        with 'zcl_appl_comp' wa_plotjobs-kompression '' ''.
    else.
      wa_plotjobs-appl_comp = wa_appl_comp-appl_comp.
    endif.

    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.


endform.                    " add_APPL_fields
*&---------------------------------------------------------------------*
*&      Form  get_dok_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_dok_text.
* ergänzt Dokumententexte
  data: wa_drat type drat.

  loop at itab_search into wa_search.
    if wa_search-knz_spez_dok = 'X' .
      continue.
    else.
    endif.

    select single * from drat into wa_drat
      where dokar = wa_search-dokar
      and doknr = wa_search-doknr
      and dokvr = wa_search-dokvr
      and doktl = wa_search-doktl
      and langu = sy-langu
      .
    if sy-subrc ne 0.
    else.
      wa_search-dktxt = wa_drat-dktxt.
      wa_search-dktxt_uc = wa_drat-dktxt_uc.
      modify itab_search from wa_search index sy-tabix.
    endif.
  endloop.

endform.                    " get_dok_text
*&---------------------------------------------------------------------*
*&      Form  save_searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_searchlist.
* saves the Searchlist into a local file
  call function 'Z_CL_WRITE_SEARCH_FILE'
       exporting
            i_filename        = user_data-searchlist_file
            i_trennzeichen    = user_data-trennzeichen  "'/'
       tables
            i_itab_searchlist = itab_search
       exceptions
            error             = 1
            others            = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " save_searchlist
*&---------------------------------------------------------------------*
*&      Form  open_searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form open_searchlist.
* read thze searchlist
  data: itab_searchlist type table of zcl_s_docsearch.
  data: wa_itab_searchlist type zcl_s_docsearch.

  refresh itab_searchlist.

  call function 'Z_CL_READ_SEARCH_FILE'
       exporting
            i_filename     = user_data-searchlist_file
            i_trennzeichen = user_data-trennzeichen  "'/'
       tables
            o_itab_search  = itab_searchlist
       exceptions
            error          = 1
            others         = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  loop at itab_searchlist into wa_itab_searchlist.
    append wa_itab_searchlist to itab_search.
  endloop.

endform.                    " open_searchlist
*&---------------------------------------------------------------------*
*&      Form  recalc_searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form recalc_searchlist.
* recalculates the searchlist
  data: index_search type sy-tabix.

  loop at itab_search into wa_search.
    index_search = sy-tabix.
    select single * from draw into wa_draw
      where dokar = wa_search-dokar
      and doknr = wa_search-doknr
      and dokvr = wa_search-dokvr
      and doktl = wa_search-doktl
      .
    if sy-subrc ne 0.
    else.
      move-corresponding wa_draw to wa_search.
      modify itab_search from wa_search index index_search.
    endif.
  endloop.

endform.                    " recalc_searchlist
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
form appl_log_write using    value(typ)
                             value(nummer)
                             value(klasse)
                             value(message1)
                             value(message2)
                             value(message3)
                             value(message4).
  data: number(3) type n.
  data: msgno type symsgno.

  clear msgv1.
  clear msgv2.
  clear msgv3.
  clear msgv4.
  msgv1 = message1.
  msgv2 = message2.
  msgv3 = message3.
  msgv4 = message4.
  number = nummer.
  msgno = nummer.

  call function '/CIDEON/APPL_LOG_WRITE_2'
       exporting
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
       exceptions
            error      = 1
            others     = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " appl_log_write
*&---------------------------------------------------------------------*
*&      Form  get_stamp_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_stamp_values.
* get the values for the stamps
  data: index_itab_plotjobs_2 type sy-tabix.
* itab_tmp_plotjobs_2
* itab_stempel_wert

  call function '/CIDEON/GET_STAMP_DATA'
       exporting
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       tables
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            o_itab_stamp_data = itab_stempel_wert
       exceptions
            error             = 1
            others            = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  exit.


  refresh itab_stempel_default.
  select * from zcl_stamp_defaul
    into table itab_stempel_default
    where status = c_status_aktiv
    .
  if sy-subrc ne 0.
  else.
  endif.

  refresh itab_stempel_user.
  select * from zcl_stamp_user
    into table itab_stempel_user
    where status = c_status_aktiv
    and uname = sy-uname
    .
  if sy-subrc ne 0.
  else.
  endif.


  refresh itab_stempel_wert.

  loop at itab_tmp_plotjobs_2 into wa_plotjobs.
    refresh itab_stempel_voreinstellung.
    select * from zcl_stamp_vorein
      into table itab_stempel_voreinstellung
      where status = c_status_aktiv
      and voreinstellung = wa_plotjobs-voreinstellung
      .
    if sy-subrc ne 0.
    else.
    endif.
    if user_data-knz_use_post = 'X'.
    else.
      "bei CLF bei Voreinstellungen
      refresh itab_stempel_voreinstellung.
    endif.

    refresh itab_stempel_verteiler.
    select * from zcl_stamp_vertei
      into table itab_stempel_verteiler
      where status = c_status_aktiv
      and verteiler = wa_plotjobs-verteiler
      .
    if sy-subrc ne 0.
    else.
    endif.


    index_itab_plotjobs_2 = sy-tabix.

*   default stamps
    loop at itab_stempel_default into wa_stempel_default.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_default-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_default-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        continue.
      endif.
      call function wa_stempel_default-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_default-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.

*   user stamps
    loop at itab_stempel_user into wa_stempel_user.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_user-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_user-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      endif.
      call function wa_stempel_user-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_user-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.

*   Voreinstellung stamps
    loop at itab_stempel_voreinstellung into wa_stempel_voreinstellung.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_voreinstellung-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_vor'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_voreinstellung-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      endif.
      call function wa_stempel_user-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_voreinstellung-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.

*   Verteiler stamps
    loop at itab_stempel_verteiler into wa_stempel_verteiler.
      clear wa_stempel_wert.
*     " check for FB
*     " created
      select single * from tfdir
        where funcname = wa_stempel_verteiler-fm_name
        .
      if sy-subrc ne 0.
        "LOG Eintrag
        perform appl_log_write using
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_vert'  '' ''.
        continue.
      else.
      endif.
*     " active
      select single * from rsinfdir
        where funcname = wa_stempel_verteiler-fm_name
        .
      if sy-subrc ne 0.
      else.
        "LOG Eintrag
        perform appl_log_write using
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_user'  '' ''.
        continue.
      endif.
      call function wa_stempel_user-fm_name
           exporting
                i_wa_plotjobs  = wa_plotjobs
           importing
                o_stempel_wert = wa_stempel_wert-stempel_wert
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        "LOG Eintrag
      else.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_verteiler-stempel_name.
        append wa_stempel_wert to itab_stempel_wert .
      endif.
    endloop.
  endloop.
endform.                    " get_stamp_values
*&---------------------------------------------------------------------*
*&      Form  show_dokumentation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form show_dokumentation.
  data: url type filep.

  if user_data-knz_show_html_help = 'X'.
    url = user_data-html_help_path.
    call function 'Z_CL_VIEW_HTML_HELP'
         exporting
              i_filename = url
         exceptions
              error      = 1
              others     = 2.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.

  else.
    call function 'HELPSCREEN_CREATE'
      exporting
        doku_id           = 'RE'
        doku_objekt       = 'ZCL_PLINT_DESIGN_007'
*     DYNPRO            = ' '
*     HEADERTEXT        = ' '
        langu             = sy-langu
*     PFKEY             = ' '
*     PROGRAMM          = ' '
        titel             = sy-title
              .
  endif.

endform.                    " show_dokumentation
*&---------------------------------------------------------------------*
*&      Form  reindex_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form reindex_table.
* make an reindex for the plot table
  loop at itab_tmp_plotjobs into wa_plotjobs.
    wa_plotjobs-cont = sy-tabix.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.
endform.                    " reindex_table
*&---------------------------------------------------------------------*
*&      Form  check_exist_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_exist_files.
* checks if there are not existing files in the plotjob entries like
* local files that are not checked in
  data: f_exist(1) value ''.
  data: f_isdir(1) value ''.
  data: filename_tmp type file_name.
  data: index_plotjobs type sy-tabix.

  loop at itab_plotjobs into wa_plotjobs.
    index_plotjobs = sy-tabix.
    if wa_plotjobs-checked is initial.
*     check for existenz
      if wa_plotjobs-knz_spez_dok = 'X'.
        continue.
      else.
      endif.

      filename_tmp = wa_plotjobs-filep.
      clear f_exist.
      clear f_isdir.

      call function 'TMP_GUI_GET_FILE_EXIST'
           exporting
                fname          = filename_tmp
           importing
                exist          = f_exist
                isdir          = f_isdir
           exceptions
                fileinfo_error = 1
                others         = 2.
      if sy-subrc <> 0.
        "APPL LOG

        "MESSAGE s072(zcl_plint_message_01)
        "  WITH filename_tmp '' '' ''.
      else.
        if f_exist is initial.
          "MESSAGE s061(zcl_plint_message_01)
          " WITH filename_tmp '' '' ''.
          wa_plotjobs-knz_fehl_blatt = 'X'.
          "wa_plotjobs-light = 1.
          wa_plotjobs-icon_fehlblatt = user_data-fehlblatt_icon.
          modify itab_plotjobs from wa_plotjobs index index_plotjobs.
        else.
        endif.
      endif.
    else.
      continue.
    endif.
  endloop.


endform.                    " check_exist_files
*&---------------------------------------------------------------------*
*&      Form  reselect_plotlist_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form reselect_plotlist_entries.
* make an Reselect after the Refresh of the internal table
  call method grid_plotlist->set_selected_rows
    exporting
      it_index_rows = itab_et_index_rows_plotlist
*      IT_ROW_NO     =
      .


endform.                    " reselect_plotlist_entries
*&---------------------------------------------------------------------*
*&      Form  ask_before_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ask_before_delete changing  value(answer).
  data: ev_answer(1).

  call function 'POPUP_TO_CONFIRM_STEP'
       exporting
            titel          = text-pt3
            textline1      = text-p04
            defaultoption  = 'J'
            cancel_display = ''
       importing
            answer         = ev_answer.

  clear answer.
  answer = ev_answer.


endform.                    " ask_before_delete
*&---------------------------------------------------------------------*
*&      Form  ask_before_leave
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ask_before_leave .
  data: ev_answer(1).

  call function 'POPUP_TO_CONFIRM_STEP'
       exporting
            titel          = text-pt3
            textline1      = text-p05                       "text-p01
            textline2      = text-p02
            defaultoption  = 'N'
            cancel_display = ''
       importing
            answer         = ev_answer.

  if ev_answer = 'J'.
    perform clean_up.
    leave to screen 0.
  else.
  endif.

endform.                    " ask_before_leave
*&---------------------------------------------------------------------*
*&      Form  check_for_multipage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_for_multipage.
*
*ITAB
  data: itab_page_format type table of zcl_orig_format.
*WA
  data: wa_page_format type zcl_orig_format.

  refresh itab_tmp_plotjobs_3.

  loop at itab_tmp_plotjobs into wa_plotjobs.
*   Check for existence
    select single * from zcl_orig_format into wa_page_format
      where dokar = wa_plotjobs-dokar
      and doknr = wa_plotjobs-doknr
      and dokvr = wa_plotjobs-dokvr
      and doktl = wa_plotjobs-doktl
      and wsapplication = wa_plotjobs-wsapplication
      and docfile  = wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    if sy-subrc ne 0.
      append wa_plotjobs to itab_tmp_plotjobs_3.
      continue.
    else.
    endif.

    refresh itab_page_format.
*   get the intervals
    select * from zcl_orig_format into table itab_page_format
      where dokar = wa_plotjobs-dokar
      and doknr = wa_plotjobs-doknr
      and dokvr = wa_plotjobs-dokvr
      and doktl = wa_plotjobs-doktl
      and wsapplication = wa_plotjobs-wsapplication
      and docfile  = wa_plotjobs-filep

*      AND application_id = wa_plotjobs-application_id
*      AND file_id = wa_plotjobs-file_id
      .
    if sy-subrc ne 0.
      continue.
    else.
    endif.

    loop at itab_page_format into wa_page_format.
      wa_plotjobs-knz_multi_page = 'X'.
      wa_plotjobs-seite_von = wa_page_format-pagefrom.
      wa_plotjobs-seite_bis = wa_page_format-pageto.
      wa_plotjobs-format_ausgabe = wa_page_format-pageformat.
      append wa_plotjobs to itab_tmp_plotjobs_3.
    endloop.


  endloop.

  refresh itab_tmp_plotjobs.
  loop at itab_tmp_plotjobs_3 into wa_plotjobs.
    append wa_plotjobs to itab_tmp_plotjobs.
  endloop.

  refresh itab_tmp_plotjobs_3.

endform.                    " check_for_multipage
*&---------------------------------------------------------------------*
*&      Form  reindex_table_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form reindex_table_2.
* make an reindex for the plot table
  loop at itab_plotjobs into wa_plotjobs.
    wa_plotjobs-cont = sy-tabix.
    modify itab_plotjobs from wa_plotjobs index sy-tabix.
  endloop.

endform.                    " reindex_table_2
*&---------------------------------------------------------------------*
*&      Form  show_versions_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form show_versions_info.
* shows the version informations


  call function 'Z_CL_SHOW_VERSIONS_INFO_SCREEN'
   exporting
     id                = 'PLOT_001'
     i_wa_info         = wa_info
*     I_USE_TILL        = g_USE_TILL
*   IMPORTING
*     O_URL             = ''
   tables
     i_itab_info       = itab_info
     i_itab_info_pa    = itab_info_pa
   exceptions
     error             = 1
     others            = 2
            .
  if sy-subrc <> 0.
  endif.

endform.                    " show_versions_info
*&---------------------------------------------------------------------*
*&      Form  ask_for_filter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ask_for_filter.
* get the filter values
  data: format_ausgabe type zcl_s_plotlist-format_ausgabe.
  data: count type i.

  call function 'Z_CL_ASK_FOR_SELECTION'
       importing
            o_format_ausgabe = format_ausgabe
       exceptions
            error            = 1
            others           = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  if format_ausgabe is initial.
  else.
    refresh itab_et_index_rows_plotlist .
    clear wa_et_index_rows_plotlist.
    loop at itab_plotjobs into wa_plotjobs
      where format_ausgabe = format_ausgabe.
      wa_et_index_rows_plotlist-index =  sy-tabix.
      append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist .
    endloop.

    if itab_et_index_rows_plotlist[] is initial.
      message s090(zcl_plint_message_01)
        with text-090 format_ausgabe '' ''.
    else.
      call method grid_plotlist->set_selected_rows
        exporting
          it_index_rows = itab_et_index_rows_plotlist
          .
      describe table itab_et_index_rows_plotlist lines count.
      message s091(zcl_plint_message_01)
        with count text-090 format_ausgabe '' .
    endif.
  endif.


endform.                    " ask_for_filter
*&---------------------------------------------------------------------*
*&      Form  get_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_matnr.
* get the material and the status
  data: wa_drad type drad.
  data: mat_count type i.

  if user_data-knz_get_material is initial.
    exit.
  else.
  endif.

  loop at itab_search into wa_search.

    if wa_search-knz_spez_dok = 'X' .
      continue.
    else.
    endif.

    clear wa_drad.
    select single  * from drad into wa_drad
      where dokar = wa_search-dokar
      and doknr = wa_search-doknr
      and dokvr = wa_search-dokvr
      and doktl = wa_search-doktl
      and dokob = 'MARA'
      .
    if sy-subrc ne 0.
    else.
      clear mat_count.
      mat_count = 1.
      select count( * ) from drad into mat_count
        where dokar = wa_search-dokar
        and doknr = wa_search-doknr
        and dokvr = wa_search-dokvr
        and doktl = wa_search-doktl
        and dokob = 'MARA'
        .
      if sy-subrc ne 0.
      else.
      endif.
      wa_search-mat_count = mat_count.

      wa_search-matnr = wa_drad-objky.

      select single mstae mstde  from mara
        into (wa_search-mstae, wa_search-mstde )
        where matnr = wa_search-matnr.
      if sy-subrc ne 0.
      else.
      endif.

      modify itab_search from wa_search index sy-tabix.
    endif.

  endloop.


endform.                    " get_matnr
*&---------------------------------------------------------------------*
*&      Form  make_mat_status_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_mat_status_icon.
* updates the Icon in the searchlist for Material Status
  data: index_search type sy-tabix.
  data: f_found.

  loop at itab_search into wa_search.
    index_search = sy-tabix.
    if wa_search-matnr is initial.
      continue.
    else.
    endif.

    if wa_search-mstde <= sy-datum.
    else.
      continue.
    endif.

    clear f_found.
    loop at itab_mat_status_exc into wa_mat_status_exc.
      if wa_mat_status_exc = wa_search-mstae.
        wa_search-mat_status = user_data-mat_status_icon.
        "03/05/0A/0W/BA
        f_found = 'X'.
        exit.
      else.
      endif.
    endloop.

    if f_found is initial.
    else.
      modify itab_search from wa_search index index_search.
    endif.
  endloop.
endform.                    " make_mat_status_icon
*&---------------------------------------------------------------------*
*&      Form  ONLY_GOOD_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form only_good_material.
* shows in Search_list only documents that related to good materials
  data: index type i.

  loop at itab_search into wa_search.
    index = sy-tabix.
    if wa_search-mat_status is initial.
    else.
      delete itab_search index index.
    endif.
  endloop.

endform.                    " ONLY_GOOD_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  sel_tree_to_sel_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form sel_tree_to_sel_list.
* get the selection from the tree and change the corresponding in the
* plotlist
  data: itab_node_key type treemnotab.
  data: wa_node_key type tm_nodekey .
  data: text1(10).
  data: text2(10).
  data: index_itab_plotjobs_tmp type sy-tabix.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  refresh itab_node_key.

  call method simple_tree_plotlist->get_selected_nodes
    importing
      node_key_table               = itab_node_key
    exceptions
      control_not_existing         = 1
      control_dead                 = 2
      cntl_system_error            = 3
      failed                       = 4
      multiple_node_selection_only = 5
      others                       = 6
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  refresh itab_et_index_rows_plotlist.
  clear wa_et_index_rows_plotlist.
  loop at itab_node_key into wa_node_key.
    split wa_node_key at '' into text1 text2.
    index_itab_plotjobs_tmp = text1.
    wa_et_index_rows_plotlist-index = index_itab_plotjobs_tmp.
    append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.
  endloop.

  call method grid_plotlist->set_selected_rows
    exporting
      it_index_rows = itab_et_index_rows_plotlist
*          IT_ROW_NO     =
      .



endform.                    " sel_tree_to_sel_list
*&---------------------------------------------------------------------*
*&      Form  get_sel_tree_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_sel_tree_2.

endform.                    " get_sel_tree_2
*&---------------------------------------------------------------------*
*&      Form  maintain_prio
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form maintain_prio.
  call transaction 'Z_CL_MAINT_PRIO'.
endform.                    " maintain_prio
