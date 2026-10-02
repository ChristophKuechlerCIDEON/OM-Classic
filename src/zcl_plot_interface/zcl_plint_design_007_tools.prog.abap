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
form fill_itab_joblist.
* to test some functionälity
  refresh itab_plotjobs.
  clear wa_plotjobs.

  wa_plotjobs-filename = 'c:\boot.ini'.
  append  wa_plotjobs to itab_plotjobs.
  wa_plotjobs-filename = 'c:\config.sys'.
  append  wa_plotjobs to itab_plotjobs.
  wa_plotjobs-filename = 'c:\winnt\Install.wri'.
  append  wa_plotjobs to itab_plotjobs.
  wa_plotjobs-filename = 'c:\winnt\Winnt.bmp'.
  append  wa_plotjobs to itab_plotjobs.

  clear wa_plotjobs.



endform.                    " fill_itab_JOBLIST
*&---------------------------------------------------------------------*
*&      Form  get_selected_line_plotjobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_selected_line_plotjobs.
* get the selected line in the plotjob ALV
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines <> 1.
    refresh itab_et_index_rows_plotlist.
    message e000(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
*   get the content of the selected Line
    clear index_itab_plotjobs.
    read table itab_et_index_rows_plotlist index 1
      into wa_et_index_rows_plotlist.
    index_itab_plotjobs = wa_et_index_rows_plotlist-index.
    read table itab_plotjobs index index_itab_plotjobs into wa_plotjobs.
  endif.

endform.                    " get_selected_line_plotjobs
*&---------------------------------------------------------------------*
*&      Form  view_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_document.

* Spoolbehandlung
  if wa_plotjobs-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_plotjobs-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.

  call function 'Z_CL_PLINT_TOOLS_VIEW_DOC_001'
       exporting
            filename = wa_plotjobs-filep
       exceptions
            error    = 1
            others   = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " view_document
*&---------------------------------------------------------------------*
*&      Form  get_Selected_line_search_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_selected_line_search_list.
  data: tmp_char(25) type c.
  data: tmp_doknr type doknr.
  data: tmp2_doknr type doknr.
  data: i type i.
  data: numc(25) type n.
  data: char1(25) type c.
  data: char2(25) type c.
  data: laenge type i.


* get the selected line in the search ALV
  refresh itab_et_index_rows_searchlist.
  call method grid_searchlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_searchlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_searchlist.
*    MESSAGE e001(zcl_plint_message_01)
*      WITH text-051 count_lines '' ''.

* CKR 2007-08-03
* falls keine Selektion vorliegt werden alle Zeilen Selektiert
* alles in Suchliste selektieren
    data: count_lines_suchliste type i.

    refresh itab_et_index_rows_searchlist.
    describe table itab_search lines count_lines_suchliste.

    do count_lines_suchliste times.
      wa_et_index_rows_searchlist-index = sy-index.
      append wa_et_index_rows_searchlist to
        itab_et_index_rows_searchlist.
    enddo.

    call method grid_searchlist->set_selected_rows
        exporting
          it_index_rows = itab_et_index_rows_searchlist
*      IT_ROW_NO     =
         .
  else.
  endif.
* /CKR 2007-08-03

*   get the content of the selected Line
  clear index_itab_searchlist.
*    LOOP AT itab_et_index_rows_searchlist
*      INTO wa_et_index_rows_searchlist.
*      index_itab_searchlist = wa_et_index_rows_searchlist-index.
*      READ TABLE itab_search INDEX index_itab_searchlist INTO wa_search
  .
*      wa_plotjobs-filename = wa_search-filep.
*      APPEND wa_plotjobs TO itab_plotjobs.
*    ENDLOOP.
  clear itab_search_tmp.
  loop at itab_et_index_rows_searchlist
    into wa_et_index_rows_searchlist.
    index_itab_searchlist = wa_et_index_rows_searchlist-index.
    read table itab_search index index_itab_searchlist into wa_search.
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
    if wa_search-doknr cn '0123456789'.
    else.
      numc = wa_search-doknr.
      wa_search-doknr = numc.
    endif.

    append wa_search to itab_search_tmp.
  endloop.

*    endif.


endform.                    " get_Selected_line_search_list
*&---------------------------------------------------------------------*
*&      Form  refresh_joblist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form refresh_joblist.
* alte Selektion merken und dann wieder setzen

  if grid_plotlist is initial.
    exit.
  else.
  endif.

  clear itab_et_index_rows_plotlist_o.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist_o
*      ET_ROW_NO     =
      .


  call method grid_plotlist->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
    exceptions
      finished       = 1
      others         = 2
          .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  call method grid_plotlist->set_selected_rows
     exporting
       it_index_rows = itab_et_index_rows_plotlist_o
*      IT_ROW_NO     =
      .


endform.                    " refresh_joblist
*&---------------------------------------------------------------------*
*&      Form  vorgabe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form vorgabe.
* füllt die Suchliste mit Vorgaben
  refresh itab_search.
  select * from draw into corresponding fields of table itab_search
    where doknr like user_data-vorgabe
    order by dokar doknr doktl dokvr
   .
  if sy-subrc ne 0.
  else.
  endif.



endform.                    " vorgabe
*&---------------------------------------------------------------------*
*&      Form  refresh_Searchlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form refresh_searchlist.

  perform make_knz_freigabe_led.
  perform make_mat_status_icon.
  perform make_display_icon.
  perform make_display_version.

  call method grid_searchlist->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
    exceptions
      finished       = 1
      others         = 2
          .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " refresh_Searchlist
*&---------------------------------------------------------------------*
*&      Form  read_akt_line_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_akt_line_search.
* get the aktual / selected line in the search list
* check is table is empty
  if itab_search is initial.
    clear wa_akt_search.
  else.
  endif.

endform.                    " read_akt_line_search
*&---------------------------------------------------------------------*
*&      Form  add_to_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_to_plotlist using p_knz_fehl_blatt.
  data: index_details type sy-tabix.
  data: tmp_uname like sy-uname.
  data: tmp_format_ausgabe like zcl_s_plotlist-format_ausgabe.
* adds the items to the plotting list
  refresh itab_tmp_plotjobs.
  loop at itab_zori_doc_files into wa_zori_doc_files.
    index_details = sy-tabix.
    clear wa_plotjobs.
    move-corresponding wa_zori_doc_files to wa_plotjobs.
    read table itab_zori_doc_files_detail into wa_zori_doc_files_detail
      index index_details.
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

    select single posid from prps
      into wa_plotjobs-pspid
      where pspnr = wa_plotjobs-pspnr
      .
    if sy-subrc ne 0.
    else.
    endif.

    append wa_plotjobs to itab_tmp_plotjobs.
  endloop.

*    PERFORM add_objectkey_to_plotlist.
  perform add_objectkey_to_plotlist_2.

  if user_data-knz_use_merkmal_format = 'X'.
    perform add_format_field.
  else.
  endif.

  if user_data-knz_use_multipage = 'X'.
*      PERFORM check_for_multipage.
    perform check_for_multipage_2.
  else.
  endif.

*   ask for fitting distributor
*Z_CL_GET_VERTEILER
  loop at itab_tmp_plotjobs into wa_plotjobs.

    " check for using of CLF / PPL
    if user_data-knz_use_post = 'X'.
    else.
      exit.
    endif.

    call function 'Z_CL_GET_VERTEILER'
         exporting
              i_uname          = user_data-uname
              i_wa_plotjobs    = wa_plotjobs
         importing
              o_voreinstellung = wa_voreinstellung
              o_verteiler      = wa_verteiler
              o_bedingung      = wa_bedingung
         exceptions
              error            = 1
              not_found        = 2
              others           = 3.
    if sy-subrc <> 0.
*     try with default_user
      call function 'Z_CL_GET_VERTEILER'
           exporting
                i_uname          = default_data-default_nutzer
                i_wa_plotjobs    = wa_plotjobs
           importing
                o_voreinstellung = wa_voreinstellung
                o_verteiler      = wa_verteiler
                o_bedingung      = wa_bedingung
           exceptions
                error            = 1
                not_found        = 2
                others           = 3.
      if sy-subrc <> 0.
*       get the default values
        clear tmp_uname.
        tmp_uname = wa_plotjobs-uname.
        clear tmp_format_ausgabe.
        tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
        wa_plotjobs-prio = default_data-default_prio.
        wa_plotjobs-kopien = default_data-default_kopien.
        wa_plotjobs-verteiler = user_data-verteiler.
        move-corresponding wa_default_verteiler to wa_plotjobs.
        wa_plotjobs-verteiler = default_data-default_verteiler.
        wa_plotjobs-uname = tmp_uname.
        if tmp_format_ausgabe is initial.
        else.
          wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
          wa_plotjobs-zielformat = tmp_format_ausgabe.
        endif.
        wa_plotjobs-satzanzahl = default_data-default_satzanzahl.
        wa_plotjobs-deckblatt = default_data-default_deckblatt.
        wa_plotjobs-endeblatt = default_data-default_endeblatt.
        wa_plotjobs-fehlblatt = default_data-default_fehlblatt.
        wa_plotjobs-knz_inhalt_vz = default_data-default_knz_inhalt_vz.
        wa_plotjobs-inhaltsblatt = default_data-default_inhaltsblatt.
      else.
        clear tmp_uname.
        tmp_uname = wa_plotjobs-uname.
        clear tmp_format_ausgabe.
        tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
        move-corresponding wa_voreinstellung to wa_plotjobs.
        wa_plotjobs-uname = tmp_uname.
        wa_plotjobs-prio = default_data-default_prio.
        wa_plotjobs-verteiler = wa_verteiler-verteiler.
        if tmp_format_ausgabe is initial.
        else.
          wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
          wa_plotjobs-zielformat = tmp_format_ausgabe.
        endif.
        wa_plotjobs-satzanzahl = wa_bedingung-satzanzahl.
        wa_plotjobs-deckblatt = wa_bedingung-deckblatt.
        wa_plotjobs-endeblatt = wa_bedingung-endeblatt.
        wa_plotjobs-fehlblatt = default_data-default_fehlblatt.
        wa_plotjobs-knz_inhalt_vz = wa_bedingung-knz_inhalt_vz.
        wa_plotjobs-inhaltsblatt = wa_bedingung-inhaltsblatt.
      endif.
    else.
      clear tmp_uname.
      tmp_uname = wa_plotjobs-uname.
      clear tmp_format_ausgabe.
      tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
      move-corresponding wa_voreinstellung to wa_plotjobs.
      wa_plotjobs-uname = tmp_uname.
      wa_plotjobs-prio = default_data-default_prio.
      wa_plotjobs-verteiler = wa_verteiler-verteiler.
      if tmp_format_ausgabe is initial.
      else.
        wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
        wa_plotjobs-zielformat = tmp_format_ausgabe.
      endif.
      wa_plotjobs-satzanzahl = wa_bedingung-satzanzahl.
      wa_plotjobs-deckblatt = wa_bedingung-deckblatt.
      wa_plotjobs-endeblatt = wa_bedingung-endeblatt.
      wa_plotjobs-fehlblatt = wa_bedingung-fehlblatt.
      wa_plotjobs-knz_inhalt_vz = wa_bedingung-knz_inhalt_vz.
      wa_plotjobs-inhaltsblatt = wa_bedingung-inhaltsblatt.
    endif.

    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.
*   ask for fitting distributor end


* Kennzeichen Fehlblatt
  loop at itab_tmp_plotjobs into wa_plotjobs.
    wa_plotjobs-knz_fehl_blatt = p_knz_fehl_blatt.
    if wa_plotjobs-knz_fehl_blatt = 'X'.
*      wa_plotjobs-light = 1.
      wa_plotjobs-icon_fehlblatt = user_data-fehlblatt_icon.
    else.
*      wa_plotjobs-light = 3.
      wa_plotjobs-icon_fehlblatt = ''.
    endif.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.

* Spezialdokumente
  loop at itab_tmp_plotjobs into wa_plotjobs.
    if wa_plotjobs-knz_spez_dok = 'X'.
      wa_plotjobs-icon_spez_dok = user_data-spez_dok_icon.
    else.
      continue.
    endif.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.

* default values
  loop at itab_tmp_plotjobs into wa_plotjobs.
    " check for using of CLF / PPL
    if user_data-knz_use_post = 'X'.
      exit.
    else.
    endif.

    wa_plotjobs-preprocessor = user_data-preprocessor.

    wa_plotjobs-prio = default_data-default_prio.
    wa_plotjobs-kopien = default_data-default_kopien.

*   möglicherweise schon vorbelegt
    if wa_plotjobs-verteiler is initial.
      wa_plotjobs-verteiler = user_data-verteiler.
    else.
    endif.

    "MOVE-CORRESPONDING wa_default_verteiler TO wa_plotjobs.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.
* default values ende

* Spezialeinträge
* List & Label Vorlagen
  loop at itab_tmp_plotjobs into wa_plotjobs.
    " check for using of CLF / PPL
    if user_data-knz_use_post = 'X'.
      exit.
    else.
    endif.

    case wa_plotjobs-object_type.
      when c_sl_object_type.
        data: wa_tmp_prep_usr type zcl_preproz_user.
        data: wa_preproz_lal type zcl_preproz_lal.
        clear wa_tmp_prep_usr.
        clear wa_preproz_lal.

        select single * from zcl_preproz_user into wa_tmp_prep_usr
          where uname = sy-uname
          and status = c_status_aktiv
          .
        if sy-subrc ne 0.
          "Defaultbenutzer verwenden
          select single * from zcl_preproz_user into wa_tmp_prep_usr
            where uname = default_data-default_nutzer
            and status = c_status_aktiv
            .
          if sy-subrc ne 0.
          else.
          endif.
        else.
        endif.
*       Lesen der Vorlagendatei
        select single * from zcl_preproz_lal into wa_preproz_lal
          where preprozessor = wa_tmp_prep_usr-preprozessor
          and object_type = c_sl_object_type
          and status = c_status_aktiv
          .
        if sy-subrc ne 0.
          message s002(zcl_plint_tools)
            with 'zcl_preproz_lal' wa_tmp_prep_usr-preprozessor
            c_sl_object_type c_status_aktiv.
        else.
        endif.

        wa_plotjobs-vorlage_l_and_l = wa_preproz_lal-vorlage_l_and_l.
      when others.
        continue.
    endcase.

    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.


* CKR 12.07.2004 wegen Auslaufen der Postprocessoransteuerung
* abgeschaltet
*    PERFORM add_compression_field.

*    PERFORM add_special_fields.
*    PERFORM check_priorities.
  perform check_priorities_2.

* DIS Status Visiualisierung etc.
*    PERFORM get_dok_status.
  perform get_dok_status_2.

*    PERFORM reindex_table.
  perform reindex_table_3.

*  SORT itab_tmp_plotjobs BY dokar doknr dokvr doktl cont.
  loop at itab_tmp_plotjobs into wa_plotjobs.
    append wa_plotjobs to itab_plotjobs.
  endloop.
endform.                    " add_to_plotlist
*&---------------------------------------------------------------------*
*&      Form  fill_jobtable_for_plot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form fill_jobtable_for_plot.
* get the selected lines in the plotjob ALV
  data: index_itab_plotjobs_tmp type sy-tabix.

  refresh itab_tmp_plotjobs.
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
*    MESSAGE e001(zcl_plint_message_01)
*      WITH text-051 count_lines '' ''.

* CKR 2007-08-04
* alles in Plotliste selektieren
    data: count_lines_plotliste type i.

    refresh itab_et_index_rows_plotlist.
    describe table itab_plotjobs lines count_lines_plotliste.

    do count_lines_plotliste times.
      wa_et_index_rows_plotlist-index = sy-index.
      append wa_et_index_rows_plotlist to
        itab_et_index_rows_plotlist.
    enddo.

    call method grid_plotlist->set_selected_rows
       exporting
         it_index_rows = itab_et_index_rows_plotlist
*      IT_ROW_NO     =
        .
* /CKR 2007-08-04
  else.
  endif.

*   get the content of the selected Lines
  refresh itab_zori_doc_files.
  loop at itab_et_index_rows_plotlist into wa_et_index_rows_plotlist.
    index_itab_plotjobs_tmp = wa_et_index_rows_plotlist-index.
    read table itab_plotjobs index index_itab_plotjobs_tmp
      into wa_plotjobs.
    append wa_plotjobs to itab_tmp_plotjobs .
*     put into an table.
    clear wa_zori_doc_files.
    move-corresponding wa_plotjobs to wa_zori_doc_files.
    append wa_zori_doc_files to itab_zori_doc_files..
  endloop.

  " check for using of CLF / PPL
  if user_data-knz_use_post = 'X'.
*     calculate Kompression
    perform add_compression_field.
*     calculate APPL%TYPE / APPL$COMP
    perform add_appl_fields.
  else.
  endif.

*   Kundendaten anfügen
  " PERFORM add_client_data.
*    PERFORM add_client_data_2
  .
*   Kostenstelle einfügen
*    PERFORM add_cost_center.

*   Prioritäten checken
*    PERFORM check_priorities.
  perform check_priorities_2.

*   Reindizieren der Counter
*    PERFORM reindex_table.
  perform reindex_table_3.

*  ENDIF.


endform.                    " fill_jobtable_for_plot
*&---------------------------------------------------------------------*
*&      Form  on_ctmenu_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
form on_ctmenu_blatt
  using l_menu  type ref to cl_ctmenu.

  call method l_menu->add_function
    exporting fcode = 'DELETE_BLATT'
              text = text-100
              .


endform.                    " on_ctmenu_input
*&---------------------------------------------------------------------*
*&      Form  DELETE_SELECTED_LINE_SEARCH_LI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form del_selected_line_search_list.
* it deletes the selected lines in the search grid
* get the selected line in the search ALV
  refresh itab_et_index_rows_searchlist.
  call method grid_searchlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_searchlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_searchlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    sort itab_et_index_rows_searchlist by index descending.
    loop at itab_et_index_rows_searchlist
      into wa_et_index_rows_searchlist.
      delete itab_search index wa_et_index_rows_searchlist.
    endloop.
  endif.



endform.                    " DELETE_SELECTED_LINE_SEARCH_LI
*&---------------------------------------------------------------------*
*&      Form  clean_up
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clean_up.
* cleans the intances
* Searchlist
  if grid_searchlist is initial.
  else.
    call method grid_searchlist->free
      exceptions
        cntl_error        = 1
        cntl_system_error = 2
        others            = 3
            .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    clear grid_searchlist.
  endif.
  if container_grid_searchlist is initial.
  else.
    call method container_grid_searchlist->free
      exceptions
        cntl_error        = 1
        cntl_system_error = 2
        others            = 3
            .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    clear container_grid_searchlist.
  endif.
* Plotlist
  if grid_plotlist is initial.
  else.
    call method grid_plotlist->free
      exceptions
        cntl_error        = 1
        cntl_system_error = 2
        others            = 3
            .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    clear grid_plotlist.
  endif.
  if container_grid_plotlist is initial.
  else.
    call method container_grid_plotlist->free
      exceptions
        cntl_error        = 1
        cntl_system_error = 2
        others            = 3
            .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    clear container_grid_plotlist.
  endif.
* Listtree
  if container_tree_plotlist is initial.
  else.
    call method container_tree_plotlist->free
      exceptions
        cntl_error        = 1
        cntl_system_error = 2
        others            = 3
            .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    clear container_tree_plotlist.
  endif.


* Tabelleneinträge löschen, die nicht mehr benötigt werden
  perform delete_sl_items.


endform.                    " clean_up
*&---------------------------------------------------------------------*
*&      Form  add_to_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_to_tree_plotlist.
* adds the items to the plotting list tree

* importend !!!!
* this module isn't finished ! dont use it !!!!
* importend !!!!

  data: tmp_str type string.
  data: result_type type i.
  data: result_node_key type tm_nodekey.
  data: start_node type tm_nodekey.
  data: parent_node type tm_nodekey.
  data: key_str type string.
  data: text_str type string.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  loop at itab_zori_doc_files into wa_zori_doc_files.
    clear wa_plotjobs.
    move-corresponding wa_zori_doc_files to wa_plotjobs.
    wa_plotjobs-filename  = wa_zori_doc_files-filep.

*   Search for Dokumentenart
    tmp_str = sy-tabix.
    text_str = wa_plotjobs-dokar.
    concatenate tmp_str text_str into key_str.
    clear result_type.
    clear result_node_key.
    clear start_node.
    clear parent_node.
    call method simple_tree_plotlist->find_first
      exporting
        search_string         = text_str
      importing
        result_type           = result_type
        result_node_key       = result_node_key
      exceptions
        start_node_not_found  = 1
        others                = 2
            .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    if result_type = 0.
*     nothing found
*     add to highest level
*     DOKAR
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
*     DOKNR
      parent_node = key_str.
      text_str = wa_plotjobs-doknr.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
*     DOKVR
      parent_node = key_str.
      text_str = wa_plotjobs-dokvr.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
*     DOKTL
      parent_node = key_str.
      text_str = wa_plotjobs-doktl.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
*     FILEP
      parent_node = key_str.
      text_str = wa_plotjobs-filep.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          isfolder = ''
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    else.
*     Search for Dokument
*     DOKAR found
*     DOKNR
      start_node = result_node_key.
      text_str = wa_plotjobs-doknr.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->find_first
        exporting
          search_string         = text_str
         start_node            = start_node
        importing
          result_type           = result_type
          result_node_key       = result_node_key
        exceptions
          start_node_not_found  = 1
          others                = 2
              .
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
      if result_type = 0.
*       DOKNR einfügen
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = start_node
            isfolder = 'X'
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
*       DOKVR einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-dokvr.
        concatenate tmp_str text_str into key_str.
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = parent_node
            isfolder = 'X'
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
*       DOKTL einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-doktl.
        concatenate tmp_str text_str into key_str.
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = parent_node
            isfolder = 'X'
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
*       FILEP einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-filep.
        concatenate tmp_str text_str into key_str.
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = parent_node
            isfolder = ''
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      else.
*       Search for Dokument
*       DOKAR found
*       DOKNR found
*       DOKVR
        start_node = result_node_key.
        text_str = wa_plotjobs-dokvr.
        call method simple_tree_plotlist->find_first
          exporting
            search_string         = text_str
            start_node            = start_node
          importing
            result_type           = result_type
            result_node_key       = result_node_key
          exceptions
            start_node_not_found  = 1
            others                = 2
                .
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
        if result_type = 0.
*         DOKVR einfügen
          parent_node = start_node.
          text_str = wa_plotjobs-dokvr.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->add_node
            exporting
              node_key = key_str
              relative_node_key = parent_node
              isfolder = 'X'
              text = text_str
            exceptions
              others = 1.
          if sy-subrc <> 0.
            message id sy-msgid type sy-msgty number sy-msgno
                       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          endif.
*         DOKTL einfügen
          parent_node = key_str.
          text_str = wa_plotjobs-doktl.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->add_node
            exporting
              node_key = key_str
              relative_node_key = parent_node
              isfolder = 'X'
              text = text_str
            exceptions
              others = 1.
          if sy-subrc <> 0.
            message id sy-msgid type sy-msgty number sy-msgno
                       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          endif.
*         FILEP einfügen
          parent_node = key_str.
          text_str = wa_plotjobs-filep.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->add_node
            exporting
              node_key = key_str
              relative_node_key = parent_node
              isfolder = ''
              text = text_str
            exceptions
              others = 1.
          if sy-subrc <> 0.
            message id sy-msgid type sy-msgty number sy-msgno
                       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          endif.
        else.
*         Search for Dokument
*         DOKAR found
*         DOKNR found
*         DOKVR found
*         DOKTL
          start_node = result_node_key.
          text_str = wa_plotjobs-doktl.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->find_first
            exporting
              search_string         = text_str
             start_node            = start_node
            importing
              result_type           = result_type
              result_node_key       = result_node_key
            exceptions
              start_node_not_found  = 1
              others                = 2
                  .
          if sy-subrc <> 0.
            message id sy-msgid type sy-msgty number sy-msgno
                       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          endif.
          if result_type = 0.
*           DOKTL einfügen
            parent_node = key_str.
            text_str = wa_plotjobs-doktl.
            concatenate tmp_str text_str into key_str.
            call method simple_tree_plotlist->add_node
              exporting
                node_key = key_str
                relative_node_key = parent_node
                isfolder = 'X'
                text = text_str
              exceptions
                others = 1.
            if sy-subrc <> 0.
              message id sy-msgid type sy-msgty number sy-msgno
                         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.
*           FILEP einfügen
            parent_node = key_str.
            text_str = wa_plotjobs-filep.
            concatenate tmp_str text_str into key_str.
            call method simple_tree_plotlist->add_node
              exporting
                node_key = key_str
                relative_node_key = parent_node
                isfolder = ''
                text = text_str
              exceptions
                others = 1.
            if sy-subrc <> 0.
              message id sy-msgid type sy-msgty number sy-msgno
                         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.
          else.
*           Search for Dokument
*           DOKAR found
*           DOKNR found
*           DOKVR found
*           DOKTL found
*           FILEP
            start_node = result_node_key.
            text_str = wa_plotjobs-filep.
            concatenate tmp_str text_str into key_str.
            call method simple_tree_plotlist->find_first
              exporting
                search_string         = text_str
               start_node            = start_node
              importing
                result_type           = result_type
                result_node_key       = result_node_key
              exceptions
                start_node_not_found  = 1
                others                = 2
                    .
            if sy-subrc <> 0.
              message id sy-msgid type sy-msgty number sy-msgno
                         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.
            if result_type = 0.
*             FILEP einfügen
              parent_node = start_node.
              text_str = wa_plotjobs-filep.
              concatenate tmp_str text_str into key_str.
              call method simple_tree_plotlist->add_node
                exporting
                  node_key = key_str
                  relative_node_key = parent_node
                  isfolder = ''
                  text = text_str
                exceptions
                  others = 1.
              if sy-subrc <> 0.
*                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                message i050(zcl_plint_message_01)
                  with '' '' '' ''.
              endif.
            else.
*            it should never happens
              message i051(zcl_plint_message_01)
                with key_str text_str start_node  ''.
            endif.

          endif.
        endif.
      endif.
    endif.

*   Search for Dokument

*   Version

*   Teil

*   Filename


*    APPEND wa_plotjobs TO itab_plotjobs.
  endloop.

endform.                    " add_to_tree_plotlist
*&---------------------------------------------------------------------*
*&      Form  rebuild_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form rebuild_tree_plotlist.
* adds the items to the plotting list tree
  data: tmp_str type string.
  data: result_type type i.
  data: result_node_key type tm_nodekey.
  data: start_node type tm_nodekey.
  data: parent_node type tm_nodekey.
  data: key_str type string.
  data: text_str type string.
  data: f_all_nodes_expanded(1).

  if simple_tree_plotlist is initial.
    exit.
  else.
  endif.

* alle Knoten löschen
  call method simple_tree_plotlist->delete_all_nodes
      .

* TESTENTRY BEGIN
  perform rebuild_tree_plotlist_2.
  exit.
* TESTENTRY END

  loop at itab_plotjobs into wa_plotjobs.
*   Search for Dokumentenart
    tmp_str = sy-tabix.
    text_str = wa_plotjobs-dokar.
    concatenate tmp_str text_str into key_str.
    clear result_type.
    clear result_node_key.
    clear start_node.
    clear parent_node.
    call method simple_tree_plotlist->find_first
      exporting
        search_string         = text_str
      importing
        result_type           = result_type
        result_node_key       = result_node_key
      exceptions
        start_node_not_found  = 1
        others                = 2
            .
    if sy-subrc <> 0.
      message i053(zcl_plint_message_01)
        with '' text_str '' ''.
    endif.
    if result_type = 0.
*     nothing found
*     add to highest level
*     DOKAR
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message i054(zcl_plint_message_01)
          with key_str text_str 'root' ''.
      endif.
*     DOKNR
      parent_node = key_str.
      text_str = wa_plotjobs-doknr.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          relationship = cl_tree_model=>relat_last_child
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message i054(zcl_plint_message_01)
          with key_str text_str parent_node ''.
      endif.
*     DOKVR
      parent_node = key_str.
      text_str = wa_plotjobs-dokvr.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          relationship = cl_tree_model=>relat_last_child
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message i054(zcl_plint_message_01)
          with key_str text_str parent_node ''.
      endif.
*     DOKTL
      parent_node = key_str.
      text_str = wa_plotjobs-doktl.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          relationship = cl_tree_model=>relat_last_child
          isfolder = 'X'
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message i054(zcl_plint_message_01)
          with key_str text_str parent_node ''.
      endif.
*     FILEP
      parent_node = key_str.
      text_str = wa_plotjobs-filep.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->add_node
        exporting
          node_key = key_str
          relative_node_key = parent_node
          relationship = cl_tree_model=>relat_last_child
          isfolder = ''
          text = text_str
        exceptions
          others = 1.
      if sy-subrc <> 0.
        message i054(zcl_plint_message_01)
          with key_str text_str parent_node ''.
      endif.
    else.
*     Search for Dokument
*     DOKAR found
*     DOKNR
      start_node = result_node_key.
      text_str = wa_plotjobs-doknr.
      concatenate tmp_str text_str into key_str.
      call method simple_tree_plotlist->find_first
        exporting
          search_string         = text_str
         start_node            = start_node
        importing
          result_type           = result_type
          result_node_key       = result_node_key
        exceptions
          start_node_not_found  = 1
          others                = 2
              .
      if sy-subrc <> 0.
        message i053(zcl_plint_message_01)
          with start_node text_str '' ''.
      endif.
      if result_type = 0.
*       DOKNR einfügen
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = start_node
            relationship = cl_tree_model=>relat_last_child
            isfolder = 'X'
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message i054(zcl_plint_message_01)
            with key_str text_str parent_node ''.
        endif.
*       DOKVR einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-dokvr.
        concatenate tmp_str text_str into key_str.
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = parent_node
            relationship = cl_tree_model=>relat_last_child
            isfolder = 'X'
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message i054(zcl_plint_message_01)
            with key_str text_str parent_node ''.
        endif.
*       DOKTL einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-doktl.
        concatenate tmp_str text_str into key_str.
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = parent_node
            relationship = cl_tree_model=>relat_last_child
            isfolder = 'X'
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message i054(zcl_plint_message_01)
            with key_str text_str parent_node ''.
        endif.
*       FILEP einfügen
        parent_node = key_str.
        text_str = wa_plotjobs-filep.
        concatenate tmp_str text_str into key_str.
        call method simple_tree_plotlist->add_node
          exporting
            node_key = key_str
            relative_node_key = parent_node
            isfolder = ''
            text = text_str
          exceptions
            others = 1.
        if sy-subrc <> 0.
          message i054(zcl_plint_message_01)
            with key_str text_str parent_node ''.
        endif.
      else.
*       Search for Dokument
*       DOKAR found
*       DOKNR found
*       DOKVR
        start_node = result_node_key.
        text_str = wa_plotjobs-dokvr.
        call method simple_tree_plotlist->find_first
          exporting
            search_string         = text_str
            start_node            = start_node
          importing
            result_type           = result_type
            result_node_key       = result_node_key
          exceptions
            start_node_not_found  = 1
            others                = 2
                .
        if sy-subrc <> 0.
          message i053(zcl_plint_message_01)
            with start_node text_str '' ''.
        endif.
        if result_type = 0.
*         DOKVR einfügen
          parent_node = start_node.
          text_str = wa_plotjobs-dokvr.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->add_node
            exporting
              node_key = key_str
              relative_node_key = parent_node
              relationship = cl_tree_model=>relat_last_child
              isfolder = 'X'
              text = text_str
            exceptions
              others = 1.
          if sy-subrc <> 0.
            message i054(zcl_plint_message_01)
              with key_str text_str parent_node ''.
          endif.
*         DOKTL einfügen
          parent_node = key_str.
          text_str = wa_plotjobs-doktl.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->add_node
            exporting
              node_key = key_str
              relative_node_key = parent_node
              relationship = cl_tree_model=>relat_last_child
              isfolder = 'X'
              text = text_str
            exceptions
              others = 1.
          if sy-subrc <> 0.
            message i054(zcl_plint_message_01)
              with key_str text_str parent_node ''.
          endif.
*         FILEP einfügen
          parent_node = key_str.
          text_str = wa_plotjobs-filep.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->add_node
            exporting
              node_key = key_str
              relative_node_key = parent_node
              relationship = cl_tree_model=>relat_last_child
              isfolder = ''
              text = text_str
            exceptions
              others = 1.
          if sy-subrc <> 0.
            message i054(zcl_plint_message_01)
              with key_str text_str parent_node ''.
          endif.
        else.
*         Search for Dokument
*         DOKAR found
*         DOKNR found
*         DOKVR found
*         DOKTL
          start_node = result_node_key.
          text_str = wa_plotjobs-doktl.
          concatenate tmp_str text_str into key_str.
          call method simple_tree_plotlist->find_first
            exporting
              search_string         = text_str
             start_node            = start_node
            importing
              result_type           = result_type
              result_node_key       = result_node_key
            exceptions
              start_node_not_found  = 1
              others                = 2
                  .
          if sy-subrc <> 0.
            message i053(zcl_plint_message_01)
              with start_node text_str '' ''.
          endif.
          if result_type = 0.
*           DOKTL einfügen
            parent_node = key_str.
            text_str = wa_plotjobs-doktl.
            concatenate tmp_str text_str into key_str.
            call method simple_tree_plotlist->add_node
              exporting
                node_key = key_str
                relative_node_key = parent_node
                relationship = cl_tree_model=>relat_last_child
                isfolder = 'X'
                text = text_str
              exceptions
                others = 1.
            if sy-subrc <> 0.
              message i054(zcl_plint_message_01)
                with key_str text_str parent_node ''.
            endif.
*           FILEP einfügen
            parent_node = key_str.
            text_str = wa_plotjobs-filep.
            concatenate tmp_str text_str into key_str.
            call method simple_tree_plotlist->add_node
              exporting
                node_key = key_str
                relative_node_key = parent_node
                relationship = cl_tree_model=>relat_last_child
                isfolder = ''
                text = text_str
              exceptions
                others = 1.
            if sy-subrc <> 0.
              message i054(zcl_plint_message_01)
                with key_str text_str parent_node ''.
            endif.
          else.
*           Search for Dokument
*           DOKAR found
*           DOKNR found
*           DOKVR found
*           DOKTL found
*           FILEP
            start_node = result_node_key.
            text_str = wa_plotjobs-filep.
            concatenate tmp_str text_str into key_str.
            call method simple_tree_plotlist->find_first
              exporting
                search_string         = text_str
               start_node            = start_node
              importing
                result_type           = result_type
                result_node_key       = result_node_key
              exceptions
                start_node_not_found  = 1
                others                = 2
                    .
            if sy-subrc <> 0.
              message i053(zcl_plint_message_01)
                with start_node text_str '' ''.
            endif.
            if result_type = 0.
*             FILEP einfügen
              parent_node = start_node.
              text_str = wa_plotjobs-filep.
              concatenate tmp_str text_str into key_str.
              call method simple_tree_plotlist->add_node
                exporting
                  node_key = key_str
                  relative_node_key = parent_node
                  relationship = cl_tree_model=>relat_last_child
                  isfolder = ''
                  text = text_str
                exceptions
                  others = 1.
              if sy-subrc <> 0.
                message i054(zcl_plint_message_01)
                  with key_str text_str parent_node ''.
              endif.
            else.
*             FILEP einfügen
              parent_node = start_node.
              text_str = wa_plotjobs-filep.
              concatenate tmp_str text_str into key_str.
              call method simple_tree_plotlist->add_node
                exporting
                  node_key = key_str
                  relative_node_key = parent_node
                  relationship = cl_tree_model=>relat_last_child
                  isfolder = ''
                  text = text_str
                exceptions
                  others = 1.
              if sy-subrc <> 0.
                message i054(zcl_plint_message_01)
                  with key_str text_str parent_node ''.
              endif.
**            it should never happens
*                MESSAGE i051(zcl_plint_message_01)
*                  WITH key_str text_str start_node  ''.
            endif.
          endif.
        endif.
      endif.
    endif.
  endloop.

* alle expandieren
  call method simple_tree_plotlist->save_expand_all_nodes
    importing
      all_nodes_expanded = f_all_nodes_expanded.
  .


endform.                    " rebuild_tree_plotlist
*&---------------------------------------------------------------------*
*&      Form  get_file_types
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_file_types.
* read the allowed filetypes for this user
  data: lines type i.

  refresh itab_plint_usr_tdwp.
  clear itab_plint_usr_tdwp.
  clear wa_plint_usr_tdwp.


  data: wa_group_user like zcl_group_user.

* Vorgehen
* Einzeldaten lesen
* Gruppendaten lesen
* SAP* Daten lesen
*

* Einzeldaten
  select  *  from zplint_usr_tdwp
    into table itab_plint_usr_tdwp
    where uname = sy-uname.
  if sy-subrc ne 0.
  else.
  endif.

* Gruppendaten
  select  * from zcl_group_user
    into wa_group_user
    where uname = sy-uname
    and status = c_status_aktiv
    .
    select * from zcl_group_tdwp
      appending corresponding fields of table itab_plint_usr_tdwp
      where user_group = wa_group_user-user_group
      and status = c_status_aktiv.
    .
    if sy-subrc ne 0.
    else.
    endif.
  endselect.
  if sy-subrc ne 0.
  else.
  endif.

* SAP* Daten
  select  * from zcl_group_user
    into wa_group_user
    where uname = default_data-default_nutzer
    and status = c_status_aktiv
    .
    select * from zcl_group_tdwp
      appending corresponding fields of table itab_plint_usr_tdwp
      where user_group = wa_group_user-user_group
      and status = c_status_aktiv.
    .
    if sy-subrc ne 0.
    else.
    endif.
  endselect.
  if sy-subrc ne 0.
  else.
  endif.

  refresh itab_filetype.
  loop at itab_plint_usr_tdwp into wa_plint_usr_tdwp.
    clear wa_tdwp.
    move-corresponding wa_plint_usr_tdwp to wa_tdwp.
    append wa_tdwp to itab_filetype.
  endloop.

  sort itab_filetype by dappl.
  delete adjacent duplicates from itab_filetype
    comparing dappl.


endform.                    " get_file_types
*&---------------------------------------------------------------------*
*&      Form  read_akt_line_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_akt_line_plotlist.
* get the aktual / selected line in the plot list
* check is table is empty
  if itab_plotjobs is initial.
    clear wa_akt_plotjobs.
  else.
    clear wa_akt_plotjobs.
    read table itab_plotjobs index index_itab_plotjobs into
      wa_akt_plotjobs.
  endif.


endform.                    " read_akt_line_plotlist
*&---------------------------------------------------------------------*
*&      Form  refresh_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form refresh_plotlist.

  if grid_plotlist is initial.
    exit.
  else.
  endif.

  call method grid_plotlist->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
    exceptions
      finished       = 1
      others         = 2
          .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " refresh_plotlist
*&---------------------------------------------------------------------*
*&      Form  del_selected_line_plot_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form del_selected_line_plot_list.
* it deletes the selected lines in the plot grid
* get the selected line in the plot ALV
  refresh itab_et_index_rows_plotlist.
  call method grid_plotlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_plotlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_plotlist lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_plotlist.
    message e001(zcl_plint_message_01)
      with text-051 count_lines '' ''.
  else.
    sort itab_et_index_rows_plotlist by index descending.
    loop at itab_et_index_rows_plotlist
      into wa_et_index_rows_plotlist.
      delete itab_plotjobs index wa_et_index_rows_plotlist.
    endloop.
  endif.



endform.                    " del_selected_line_plot_list
*&---------------------------------------------------------------------*
*&      Form  get_user_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_user_values.
* get same user values from configuration tables
**
  data: pwert type pwert.
  data: pname type pname.
  data: tmp_str(255).

  clear user_data.
  user_data-uname = sy-uname.


  call function '/CIDEON/READ_USERDATA'
       exporting
            i_default_data = default_data
       importing
            o_user_data    = user_data.


  g_repid = sy-repid.

  user_data-modus = 'NORMAL'.
  authority-check object 'ZCL_PLOT_2'
           id 'ZCL_TA' field sy-tcode
           id 'ACTVT' field 'L0'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
  .
  if sy-subrc ne 0.
  else.
    user_data-modus =  'SUPER'.
  endif.


  init = 'X'.

endform.                    " get_user_values
*&---------------------------------------------------------------------*
*&      Form  get_DBCLK_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_dbclk_node.
* try to get the double clicked node
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).
  data: itab_nodes type treemsnota.
  data: itab_nodes_tmp type treemsnota.
  data: wa_nodes type treemsnodt.
  data: wa_nodes_tmp type treemsnodt.
  data: node_key_tmp type string.
  data: itab_tree_source type treemsnota.
  data: itab_found_1 type treemsnota.
  data: itab_found_2 type treemsnota.
  data: itab_result type treemsnota.
  data: wa_tree_source type treemsnodt.
  data: wa_found_1 type treemsnodt.
  data: wa_found_2 type treemsnodt.
  data: wa_result type treemsnodt.

  data: itab_sel_tree type treemnotab.
  data: wa_sel_tree type tm_nodekey.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  node_key = g_node_key.
  clear properties.

  call method simple_tree_plotlist->node_get_properties
    exporting
      node_key       = node_key
    importing
      properties     = properties
    exceptions
      node_not_found = 1
      others         = 2
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    message i055(zcl_plint_message_01)
        with node_key ''  '' ''.
    clear properties.
    exit.
  else.
    if properties-isfolder = 'X'.
*     try to get the tree
      refresh itab_tree_source.
      refresh itab_found_1.
      refresh itab_found_2.
      call method simple_tree_plotlist->get_tree
        importing
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      loop at itab_tree_source into wa_tree_source
        where relatkey = node_key.
        append wa_tree_source to itab_found_1 .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     second step
*     copy
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     third step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fourth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fifth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.

      refresh itab_et_index_rows_plotlist.
      clear wa_et_index_rows_plotlist.
      loop at itab_result into wa_result.
        split wa_result-node_key at '' into text1 text2.
        index_itab_plotjobs_tmp = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs_tmp.
        append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.
      endloop.

      call method grid_plotlist->set_selected_rows
        exporting
          it_index_rows = itab_et_index_rows_plotlist
*          IT_ROW_NO     =
          .

      clear wa_akt_plotjobs.

      refresh itab_sel_tree.
      clear wa_sel_tree.
      loop at itab_result into wa_result.
        wa_sel_tree = wa_result-node_key.
        append wa_sel_tree to itab_sel_tree.
      endloop.
      call method simple_tree_plotlist->select_nodes
        exporting
          node_key_table               = itab_sel_tree
        exceptions
          multiple_node_selection_only = 1
          error_in_node_key_table      = 2
          others                       = 3
              .
      if sy-subrc <> 0.
        message id 'W' type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.


*      perform set_alv_sel_lines.
      exit.
    else.
*     try to get the whole Information
      split node_key at '' into text1 text2.
      index_itab_plotjobs = text1.
      read table itab_plotjobs index index_itab_plotjobs
        into wa_akt_plotjobs.
      perform set_alv_sel_line.
    endif.
  endif.



endform.                    " get_DBCLK_node
*&---------------------------------------------------------------------*
*&      Form  rebuild_tree_plotlist_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form rebuild_tree_plotlist_2.
* rebuild the plot list tree with Gruppenstufenverarbeitung
  data: l_node_table type treemsnota,
        l_node type treemsnodt,
        l_spfli type spfli,
        l_spfli_tab type sorted table of spfli
                    with unique key carrid connid.
  data: tmp_str type string.
  data: text_str type string.
  data: key_str type string.
  data: itab_plotjobs_tmp type table of zcl_s_plotlist_1.
  data: wa_plotjobs_tmp type zcl_s_plotlist_1.
  data: last_dokar type string.
  data: last_doknr type string.
  data: last_dokvr type string.
  data: last_doktl type string.
  data: last_filep type string.
  data: f_all_nodes_expanded(1).
  data: saved_index type string.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  refresh itab_plotjobs_tmp.
  clear wa_plotjobs_tmp.
  clear itab_plotjobs_tmp.

  loop at itab_plotjobs into wa_plotjobs.
    move-corresponding wa_plotjobs to wa_plotjobs_tmp.
    append wa_plotjobs_tmp to itab_plotjobs_tmp.
  endloop.

  l_node-hidden = ' '.               " All nodes are visible,
  l_node-disabled = ' '.             " selectable,
  l_node-isfolder = 'X'.             " a folder,
  l_node-expander = ' '.             " have no '+' sign for expansion.

  loop at itab_plotjobs_tmp into wa_plotjobs_tmp.
    saved_index = sy-tabix.
    at new dokar.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-dokar.
      concatenate tmp_str text_str into key_str.
      l_node-node_key = key_str.
      clear l_node-relatkey.
      clear l_node-relatship.
*  this have to be inserted definitly, cause otherwise it appends in
*  wrong order
      l_node-relatship = simple_tree_plotlist->relat_last_child.
*
      l_node-text = text_str.
      l_node-n_image =   ' '.
      l_node-exp_image = ' '.
      append l_node to l_node_table.
      last_dokar = key_str.
    endat.
    at new doknr.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-doknr.
      concatenate tmp_str text_str into key_str.
      l_node-node_key = key_str.
      l_node-relatkey = last_dokar.
      l_node-relatship = simple_tree_plotlist->relat_last_child.
      l_node-text = text_str.
      append l_node to l_node_table.
      last_doknr = key_str.
    endat.
    at new dokvr.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-dokvr.
      concatenate tmp_str text_str into key_str.
      l_node-node_key = key_str.
      l_node-relatkey = last_doknr.
      l_node-relatship = simple_tree_plotlist->relat_last_child.
      l_node-text = text_str.
      append l_node to l_node_table.
      last_dokvr = key_str.
    endat.
    at new doktl.
      tmp_str = saved_index.
      text_str = wa_plotjobs_tmp-doktl.
      concatenate tmp_str text_str into key_str.
      l_node-node_key = key_str.
      l_node-relatkey = last_dokvr.
      l_node-relatship = simple_tree_plotlist->relat_last_child.
      l_node-text = text_str.
      append l_node to l_node_table.
      last_doktl = key_str.
    endat.
    at new filep.
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
    endat.
*   normale Verarbeitung
    tmp_str = saved_index.
    text_str = wa_plotjobs_tmp-filep.
    concatenate tmp_str text_str into key_str.
    l_node-node_key = key_str.
    l_node-relatkey = last_doktl.
    l_node-relatship = simple_tree_plotlist->relat_last_child.
    l_node-text = text_str.
    l_node-isfolder = ''.

*   Failblatt
    if wa_plotjobs_tmp-knz_fehl_blatt = 'X'.
      l_node-style = cl_tree_model=>style_intensifd_critical.
      l_node-n_image = '@BA@'.  "03/05/0A/0W/BA
      l_node-n_image = user_data-fehlblatt_icon.
    else.
    endif.

*   Spezialdokument
    if wa_plotjobs_tmp-knz_spez_dok = 'X'.
      l_node-style = cl_tree_model=>style_intensified.
      l_node-n_image = '@03@'.  "03/05/0A/0W/BA
      l_node-n_image = user_data-spez_dok_icon.

      case wa_plotjobs_tmp-object_type.
        when c_sl_object_type.
          l_node-style = cl_tree_model=>style_intensified.
          l_node-n_image = user_data-spez_dok_icon_stuecklist.
        when c_fg_object_type.
          l_node-style = cl_tree_model=>style_intensified.
          l_node-n_image = user_data-spez_dok_icon_folge.
        when c_vg_object_type.
          l_node-style = cl_tree_model=>style_intensified.
          l_node-n_image = user_data-spez_dok_icon_vorgang.
        when others.
      endcase.
    else.
    endif.

*   Multipage
    if wa_plotjobs_tmp-knz_multi_page = 'X'.
      "l_node-style = cl_tree_model=>style_intensifd_critical.
      "l_node-style = cl_tree_model=>STYLE_EMPHASIZED.
      "l_node-style = cl_tree_model=>STYLE_EMPHASIZED_NEGATIVE.
      "l_node-style = cl_tree_model=>STYLE_EMPHASIZED_POSITIVE.
      "l_node-style = cl_tree_model=>STYLE_INACTIVE.
      "l_node-style = cl_tree_model=>STYLE_INHERITED.
      l_node-style = cl_tree_model=>style_intensified.
      l_node-n_image = '@JG@'.                              "N1/3M/JG
    else.
    endif.

    append l_node to l_node_table.
    l_node-isfolder = 'X'.
    l_node-style = cl_tree_model=>style_default.
    clear l_node-n_image.
    last_filep = key_str.

  endloop.

*  LOOP AT l_spfli_tab INTO l_spfli.
*    APPEND l_node TO l_node_table.
*  ENDLOOP.

*  CALL METHOD simple_tree_plotlist->add_nodes
*       EXPORTING table_structure_name = 'ABDEMONODE'
*                 node_table = l_node_table.

*  CALL METHOD simple_tree_plotlist->delete_all_nodes
*      .
*

  call method simple_tree_plotlist->add_nodes
    exporting
      node_table          = l_node_table
    exceptions
      error_in_node_table = 1
      others              = 2
          .
  if sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* alle expandieren
  call method simple_tree_plotlist->save_expand_all_nodes
    importing
      all_nodes_expanded = f_all_nodes_expanded.
  .


endform.                    " rebuild_tree_plotlist_2
*&---------------------------------------------------------------------*
*&      Form  del_item_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form del_item_tree_plotlist.
* deletes Items from Plottree
* try to get the double clicked node
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).
  data: itab_tree_source type treemsnota.
  data: itab_found_1 type treemsnota.
  data: itab_found_2 type treemsnota.
  data: itab_result type treemsnota.
  data: wa_tree_source type treemsnodt.
  data: wa_found_1 type treemsnodt.
  data: wa_found_2 type treemsnodt.
  data: wa_result type treemsnodt.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  node_key = g_node_key.
  clear properties.

  call method simple_tree_plotlist->node_get_properties
    exporting
      node_key       = node_key
    importing
      properties     = properties
    exceptions
      node_not_found = 1
      others         = 2
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    message i055(zcl_plint_message_01)
        with node_key ''  '' ''.
    clear properties.
    exit.
  else.
    if properties-isfolder = 'X'.
*     try to get the tree
      refresh itab_tree_source.
      refresh itab_found_1.
      refresh itab_found_2.
      call method simple_tree_plotlist->get_tree
        importing
          node_table = itab_tree_source
          .
*     we should seach in 3 or 4 levels
*     found all with node_key as parent
      loop at itab_tree_source into wa_tree_source
        where relatkey = node_key.
        append wa_tree_source to itab_found_1 .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     second step
*     copy
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     third step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fourth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.
*     fifth step
      refresh itab_found_2.
      itab_found_2[] = itab_found_1[].
      refresh itab_found_1.
      loop at itab_found_2 into wa_found_2.
        loop at itab_tree_source into wa_tree_source
          where relatkey = wa_found_2-node_key.
          append wa_tree_source to itab_found_1 .
        endloop.
      endloop.
      refresh itab_found_2.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        append wa_found_1 to itab_result .
      endloop.
      loop at itab_found_1 into wa_found_1
        where isfolder = ''.
        delete itab_found_1 index sy-tabix.
      endloop.

*     delete entries
      refresh itab_et_index_rows_plotlist.
      clear wa_et_index_rows_plotlist.
      loop at itab_result into wa_result.
        split wa_result-node_key at '' into text1 text2.
        index_itab_plotjobs = text1.
        wa_et_index_rows_plotlist-index = index_itab_plotjobs.
        append wa_et_index_rows_plotlist to itab_et_index_rows_plotlist.

*        DELETE itab_plotjobs INDEX index_itab_plotjobs.
      endloop.
      sort itab_et_index_rows_plotlist by index descending.
      loop at itab_et_index_rows_plotlist
        into wa_et_index_rows_plotlist.
        delete itab_plotjobs index wa_et_index_rows_plotlist.
      endloop.

      exit.
    else.
*     try to get the whole Information
      split node_key at '' into text1 text2.
      index_itab_plotjobs = text1.
      delete itab_plotjobs index index_itab_plotjobs.
    endif.
  endif.


endform.                    " del_item_tree_plotlist
*&---------------------------------------------------------------------*
*&      Form  clear_plot_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_plot_details.
  clear wa_akt_plotjobs.
endform.                    " clear_plot_details
*&---------------------------------------------------------------------*
*&      Form  clear_search_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_search_details.
  clear wa_akt_search.
endform.                    " clear_search_details
*&---------------------------------------------------------------------*
*&      Form  view_document_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_document_02.
* try to view the document

* Spoolbehandlung
  if wa_plotjobs-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_plotjobs-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.

  call function 'Z_CL_PLINT_TOOLS_VIEW_DOC_002'
       exporting
            i_wa_plotjobs = wa_plotjobs
       exceptions
            error         = 1
            others        = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " view_document_02
*&---------------------------------------------------------------------*
*&      Form  set_alv_sel_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_alv_sel_line.
* try to set a selection on the ALV after doubleclick in Tree
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




endform.                    " set_alv_sel_line
*&---------------------------------------------------------------------*
*&      Form  set_tree_sel_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_tree_sel_node.
* try to select the corresponding node after doublecklick one row in ALV
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1 type string.
  data: text2(10).
  data: itab_sel_tree type treemnotab.
  data: wa_sel_tree type tm_nodekey .

  if g_show_struktur = 'X'.
  else.
    exit.
  endif.

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

*  node_key = g_node_key.
  clear properties.
  clear node_key.
  text1 = index_itab_plotjobs.
  shift text1 left deleting leading space.
  concatenate text1 wa_akt_plotjobs-filep
    into node_key.
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

  call method simple_tree_plotlist->unselect_all
      .

  refresh itab_sel_tree.
  clear wa_sel_tree.
  wa_sel_tree = node_key.
  append wa_sel_tree to itab_sel_tree.

  call method simple_tree_plotlist->select_nodes
    exporting
      node_key_table               = itab_sel_tree
    exceptions
      multiple_node_selection_only = 1
      error_in_node_key_table      = 2
      others                       = 3
          .
  if sy-subrc <> 0.
*    MESSAGE ID 'S' TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.



*  SPLIT node_key AT '' INTO text1 text2.
*  index_itab_plotjobs = text1.

endform.                    " set_tree_sel_node
*&---------------------------------------------------------------------*
*&      Form  get_set_view_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_set_view_program.
* read the filetypes for viewing by this user
  clear wa_view_program.
  select * from zcl_plint_usr_vw
  into wa_view_program
    where uname = sy-uname
    and dappl = wa_plotjobs-wsapplication
    .
  endselect.
  if sy-subrc ne 0.
    select * from zcl_plint_usr_vw
    into wa_view_program
      where uname = default_data-default_nutzer
      and dappl = wa_plotjobs-wsapplication
      .
    endselect.
    if sy-subrc ne 0.
      message i060(zcl_plint_message_01) with '2D' '' '' ''.
      wa_view_program-programm = 'EAI 2D'.
    else.
    endif.
  else.
  endif.

endform.                    " get_set_view_program
*&---------------------------------------------------------------------*
*&      Form  view_document_03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_document_03.
* try to view the document

* Spoolbehandlung
  if wa_plotjobs-object_type = 'SPOOL'.
    call function '/CIDEON/DISPLAY_SPOOL_ID'
         exporting
              i_spoolid = wa_plotjobs-tdspoolid
         exceptions
              error     = 1
              others    = 2.
    if sy-subrc <> 0.
      exit.
    endif.
    exit.
  else.
  endif.

  call function 'Z_CL_PLINT_TOOLS_VIEW_DOC_003'
       exporting
            i_wa_plotjobs = wa_plotjobs
       exceptions
            error         = 1
            others        = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " view_document_03
*&---------------------------------------------------------------------*
*&      Form  view_item_tree_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form view_item_tree_plotlist.
* deletes Items from Plottree
* try to get the double clicked node
  data: properties type treemsnodt.
  data: node_key type string.
  data: text1(10).
  data: text2(10).

  if simple_tree_plotlist is initial.
    perform create_and_init_tree.
  else.
  endif.

  node_key = g_node_key.
  clear properties.

  call method simple_tree_plotlist->node_get_properties
    exporting
      node_key       = node_key
    importing
      properties     = properties
    exceptions
      node_not_found = 1
      others         = 2
          .
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    message i055(zcl_plint_message_01)
        with node_key ''  '' ''.
    clear properties.
    exit.
  else.
    if properties-isfolder = 'X'.
*     try to get the whole Information
      split node_key at '' into text1 text2.
      index_itab_plotjobs = text1.
      read table itab_plotjobs index index_itab_plotjobs
        into wa_plotjobs.
    else.
*     try to get the whole Information
      split node_key at '' into text1 text2.
      index_itab_plotjobs = text1.
      read table itab_plotjobs index index_itab_plotjobs
        into wa_plotjobs.
    endif.
  endif.


endform.                    " view_item_tree_plotlist
