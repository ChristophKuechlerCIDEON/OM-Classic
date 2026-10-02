*INCLUDE zcl_plot_fertigungsauftrag_con.

*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLOT_FERTIGUNGSAUFTRAG_F01                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_items.
* Items für Fertigungsauftrag recherchieren
* Verknüpfte Dokumente
* .....

* Kopf und Positonen holen
  perform get_afko_afpo.
  if g_exit = 'X'.
    exit.
  else.
  endif.

* direkt mit Auftrag verknüpfte Dokumente
  if wa_fertigung-knz_dok_link = 'X'.
    perform get_dok_link.
  else.
  endif.

* Materialverknüpfungen
  if wa_fertigung-knz_mat_link = 'X'.
    if wa_fertigung-knz_stl_aufl = 'X'.
*     Stückliste auflösen
      perform get_bom.
    else.
*     nur reine Materialverküpfungen
      perform get_matnr.
      perform get_matnr_dok_links.
    endif.
  else.
  endif.

* Textverknüpfungen
  if wa_fertigung-knz_txt_link = 'X'.
  else.
  endif.


* Auflösen der Dokumentenstücklisten
  if wa_fertigung-knz_dok_stl_aufl = 'X'.
    perform dok_stl_aufloesen.
  else.
  endif.

* Einfügen der neuen Verküpfungen an der richtigen Stelle
* unterhalb des Wurzeldokumentes
* Dokument zu Dokumentverknüpfungen.
  if wa_fertigung-knz_dok_link_aufl = 'X'.
    perform dok_link_aufloesen.
  else.
  endif.

* Dokumentenhierachien auflösen
  if wa_fertigung-knz_dok_hier_aufl = 'X'.
    perform dok_hier_aufloesen.
  else.
  endif.

* Arbeitspläne holen
* Vorgange / Folgen / Komponenten
  if wa_fertigung-knz_aufpl_folgen = 'X'.
    perform aufpl_folgen.
  else.
  endif.

  if wa_fertigung-knz_aufpl_vorgaenge = 'X'.
    perform aufpl_vorgaenge.
  else.
  endif.

* Auftragsnummer in Einträge schreiben
  perform auftragsnummer_schreiben.


endform.                    " get_items
*&---------------------------------------------------------------------*
*&      Form  clear_tables
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_tables.
* relevante ITABs löschen

  refresh itab_drad.
  refresh itab_afpo.

  refresh itab_mara.

  refresh itab_drad_to_plot.

  clear itab_zcl_sl_tmp.

  clear wa_drad.
  clear wa_afko.
  clear wa_afpo.

  clear wa_mara.

endform.                    " clear_tables
*&---------------------------------------------------------------------*
*&      Form  get_dok_link
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_dok_link.
* hole mit Auftrag direkt verlinkte Dokumente
  data: objky type drad-objky.

  clear objky.

  call function 'CO_DM_PORDER_OBJECT_KEY_GET'
    exporting
      i_aufnr             = wa_fertigung-aufnr
*     I_TYP               =
*     I_POSNR             =
*     I_FOLNR             =
*     I_VORNR             =
*     I_APLZL             =
*     I_ZAEHL             =
      i_exact             = space
    importing
      e_object_key        = objky
   exceptions
     missing_aufnr       = 1
     others              = 2
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


  select * from drad
    into corresponding fields of table itab_drad
    where dokob = 'PORDER'
    and objky like objky
    .
  if sy-subrc ne 0.
*    MESSAGE w000(zcl_plot_fertigung) WITH
*      'DRAD' wa_fertigung-aufnr 'PORDER' ''.
*    EXIT.
  else.
  endif.

endform.                    " get_dok_link
*&---------------------------------------------------------------------*
*&      Form  get_afko_afpo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_afko_afpo.
* Kopf und Positionen holen

  select * from aufk
    into wa_aufk
    where aufnr = wa_fertigung-aufnr
    .
  endselect.
  if sy-subrc ne 0.
    message w000(zcl_plot_fertigung) with
      'AUFK' wa_fertigung-aufnr '' ''.
    exit.
  else.
  endif.

  select * from afko
    into wa_afko
    where aufnr = wa_fertigung-aufnr
    .
  endselect.
  if sy-subrc ne 0.
    message w000(zcl_plot_fertigung) with
      'AFKO' wa_fertigung-aufnr '' ''.
    exit.
  else.
  endif.

  select * from afpo
    into table itab_afpo
    where aufnr = wa_fertigung-aufnr
    .
  if sy-subrc ne 0.
    message w000(zcl_plot_fertigung) with
      'AFPO' wa_fertigung-aufnr '' ''.
    exit.
  else.
  endif.

endform.                    " get_afko_afpo
*&---------------------------------------------------------------------*
*&      Form  make_plot_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_plot_entries.
* plot Einträge in DB (was auch immer) stellen
  data: itab_objects type table of zcl_pdm_exp_objects.
  data: wa_objects type zcl_pdm_exp_objects.

  refresh itab_objects.

  loop at itab_drad_to_plot into wa_drad.
    move-corresponding wa_drad to wa_objects.

    wa_objects-object_type = 'DOCUMENT'.
    if wa_drad-object_type = c_sl_object_type.
      wa_objects-object_type = c_sl_object_type.
      wa_objects-id_sl = wa_drad-id_sl.
    else.
    endif.

    if wa_drad-object_type = c_fg_object_type.
      wa_objects-object_type = c_fg_object_type.
    else.
    endif.

    if wa_drad-object_type = c_vg_object_type.
      wa_objects-object_type = c_vg_object_type.
    else.
    endif.

    wa_objects-id_sl = wa_drad-id_sl.

    append wa_objects to itab_objects.
  endloop.

*  CHECK g_exit = 'X'.

*  CALL FUNCTION 'Z_CL_PSBRW_WRITE_PSB_TMP'
*       TABLES
*            i_itab_objects = itab_objects
*       EXCEPTIONS
*            error          = 1
*            OTHERS         = 2.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

  call function '/CIDEON/PSBRW_WRT_PSB_TMP_FRTA'
       tables
            i_itab_objects = itab_objects
       exceptions
            error          = 1
            others         = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.



endform.                    " make_plot_entries
*&---------------------------------------------------------------------*
*&      Form  get_bom
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_bom.
* Materialstücklisten auflösen
  data: itab_matnr type table of mara.
  data: itab_doknr type table of stpox.
  data: itab_txtnr type table of stpox.

  data: wa_matnr type mara.
  data: wa_doknr type stpox.
  data: wa_txtnr type stpox.

  data: lines_zcl_sl_tmp type i.

  refresh itab_matnr.
  refresh itab_doknr.
  refresh itab_txtnr.

  loop at itab_afpo into wa_afpo.
    call function 'Z_CL_PLOT_AUFK_BILLOFMAT_ALL'
         exporting
              i_matnr      = wa_afpo-matnr
              i_stlan      = wa_capid-stlan
              i_stlal      = wa_capid-stlal
              i_stufe      = wa_stpos-stufe
              i_capid      = wa_capid-capid
         tables
              o_itab_matnr = itab_matnr
              o_itab_dok   = itab_doknr
              o_itab_txt   = itab_txtnr
              o_itab_stpox = itab_zcl_sl_tmp
         exceptions
              error        = 1
              others       = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    else.
*     Texteinträge verarbeiten
      loop at itab_txtnr into wa_txtnr.
      endloop.

*     Pseudo-Eintrag für Zugriff auf Stücklistenstruktur erstellen
*     ID erstellen zu Zugriff auf ZCL_SL_TMP
      clear lines_zcl_sl_tmp.
      describe table itab_zcl_sl_tmp lines lines_zcl_sl_tmp.

      if lines_zcl_sl_tmp > 0.
*       ID holen
        perform make_id_sl_tmp.

        clear wa_drad.
        wa_drad-object_type = c_sl_object_type.

        clear wa_zcl_sl_tmp.
        read table itab_zcl_sl_tmp into wa_zcl_sl_tmp index 1.
        wa_drad-id_sl = wa_zcl_sl_tmp-id_sl.

        append wa_drad to itab_drad.
      else.
      endif.


*     Ergebnisse auf globale Tabellen mappen
*     DRAD
      loop at itab_doknr into wa_doknr.
        clear wa_drad.
        move-corresponding wa_doknr to wa_drad.
        append wa_drad to itab_drad.
      endloop.

*     MARA
      clear wa_mara.
      wa_mara-matnr = wa_afpo-matnr.
      append wa_mara to itab_mara.
*     Direkte Dok-Verknüpfung mit Kopfmaterial
      select * from drad
        appending corresponding fields of table itab_drad
        where dokob = 'MARA'
        and objky like wa_mara-matnr
        .

      if sy-subrc ne 0.
      else.
      endif.

      loop at itab_matnr into wa_matnr.
        clear wa_mara.
        wa_mara-matnr = wa_matnr-matnr.
        append wa_mara to itab_mara.
      endloop.
*     Dok-Verknüpfungen für Materialien der Stückliste
      loop at itab_matnr into wa_matnr.
        select * from drad
          appending corresponding fields of table itab_drad
          where dokob = 'MARA'
          and objky like wa_matnr-matnr
          .
        if sy-subrc ne 0.
        else.
        endif.
      endloop.


    endif.
  endloop.

endform.                    " get_bom
*&---------------------------------------------------------------------*
*&      Form  get_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_matnr.
* reine Materialnummern bekommen

  loop at itab_afpo into wa_afpo.
    clear wa_mara.
    move-corresponding wa_afpo to wa_mara.
    append wa_mara to itab_mara.
  endloop.

endform.                    " get_matnr
*&---------------------------------------------------------------------*
*&      Form  check_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_values.
* checkt auf verschiedene Inhalte
  if wa_fertigung-knz_stl_aufl = 'X'.
    if wa_capid-capid is initial.
      clear ok_code.
      message e001(zcl_plot_fertigung) with '' '' '' ''.
      "EXIT.
    endif.
  else.
  endif.
endform.                    " check_values
*&---------------------------------------------------------------------*
*&      Form  get_matnr_dok_links
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_matnr_dok_links.
* besorgt Dokumentverküpfungen zu Materialnummern

  loop at itab_mara into wa_mara.

    select * from drad
      appending corresponding fields of table itab_drad
      where dokob = 'MARA'
      and objky like wa_mara-matnr
      .
    if sy-subrc ne 0.
      message w000(zcl_plot_fertigung) with
        'DRAD' wa_mara-matnr 'MARA' ''.
      exit.
    else.
    endif.

  endloop.

endform.                    " get_matnr_dok_links
*&---------------------------------------------------------------------*
*&      Form  call_plot_interface
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form call_plot_interface.
* ruft PlotINterface auf

  set parameter id 'Z_PL_READ_AKT_QUEUE' field'X'.
  call transaction 'ZCL_PLOT_INTERFACE'.

endform.                    " call_plot_interface
*&---------------------------------------------------------------------*
*&      Form  get_sel_drad
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_sel_drad.
* holt sich die selektierten Einträge

  refresh itab_et_index_rows_drad.
  call method alv_drad->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_drad.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_drad lines count_lines.
  if count_lines < 1.
    refresh itab_et_index_rows_drad.
    message e002(zcl_plot_fertigung)
      with text-000 count_lines '' ''.
  else.

    refresh itab_drad_to_plot.

    clear index_itab_drad.
    loop at itab_et_index_rows_drad into
      wa_et_index_rows_drad-index.

      index_itab_drad = wa_et_index_rows_drad-index.
      read table itab_drad index index_itab_drad into wa_drad.

      append wa_drad to itab_drad_to_plot.

    endloop.
  endif.


endform.                    " get_sel_drad
*&---------------------------------------------------------------------*
*&      Form  make_itab_drad_plot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_itab_drad_plot.


endform.                    " make_itab_drad_plot
*&---------------------------------------------------------------------*
*&      Form  make_itab_drad_to_plot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_itab_drad_to_plot.

  itab_drad_to_plot[] = itab_drad[].

endform.                    " make_itab_drad_to_plot
*&---------------------------------------------------------------------*
*&      Form  dok_stl_aufloesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form dok_stl_aufloesen.
* versuche Dokumentenstücklisten aufzulösen
*ITAB
  data: itab_stb type table of stpox.
  data: itab_doccat type table of cscdoc.

  data: itab_stpo type table of stpo_api02.
  data: itab_stko type table of stko_api02.

  data: itab_drad_tmp like itab_drad.

  data: wa_stpo type stpo_api02.
  data: wa_stko type stko_api02.
  data: wa_drad_tmp like wa_drad.
  data: wa_stb type stpox.


  data: index_drad type i.

  clear itab_drad_tmp.

  loop at itab_drad into wa_drad.
    index_drad = sy-tabix.
* Stückliste abfragen
    clear itab_stb.
    clear itab_doccat.
*   Spezialdokumente
    if wa_drad-doknr is initial or
      wa_drad-dokar is initial or
      wa_drad-doktl is initial or
      wa_drad-dokvr is initial.
      append wa_drad to itab_drad_tmp .
      continue.
    else.
    endif.


    call function 'CS_BOM_EXPL_DOC_V1'
      exporting
        datuv                          = sy-datum
        docnr                          = wa_drad-doknr
        docar                          = wa_drad-dokar
        doctl                          = wa_drad-doktl
        docvr                          = wa_drad-dokvr
        mehrs                          =
                  wa_fertigung-knz_dok_stl_aufl_mehrst
*     MMORY                          = ' '
*     POSTP                          = ' '
*     RLDET                          = ' '
*     SANKO                          = ' '
*     SANIN                          = ' '
*     EMENG                          = 0
*     VDTON                          = ' '
*     VDTAO                          = 'X'
*     VDTRO                          = 'X'
*   IMPORTING
*     TOPDOC                         =
      tables
        stb                            = itab_stb
        doccat                         = itab_doccat
     exceptions
       call_invalid                   = 1
       document_not_found             = 2
       missing_authorization          = 3
       no_bom_found                   = 4
       no_suitable_bom_found          = 5
       bom_not_active                 = 6
       bom_flagged_for_deletion       = 7
       bom_without_positions          = 8
       others                         = 9
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      append wa_drad to itab_drad_tmp .
      continue.
    else.
      append wa_drad to itab_drad_tmp .
    endif.


    loop at itab_stb into wa_stb .
      clear wa_drad_tmp.
      wa_drad_tmp-doknr = wa_stb-doknr.
      wa_drad_tmp-dokar = wa_stb-dokar.
      wa_drad_tmp-doktl = wa_stb-doktl.
      wa_drad_tmp-dokvr = wa_stb-dokvr.
      append wa_drad_tmp to itab_drad_tmp .
    endloop.

*    INSERT LINES OF itab_drad_tmp
*             INTO itab_drad INDEX index_drad.

*    LOOP AT itab_stb INTO wa_stb .
*      CLEAR wa_drad_tmp.
*      wa_drad_tmp-doknr = wa_stb-doknr.
*      wa_drad_tmp-dokar = wa_stb-dokar.
*      wa_drad_tmp-doktl = wa_stb-doktl.
*      wa_drad_tmp-dokvr = wa_stb-dokvr.
*      INSERT wa_drad_tmp INTO itab_drad INDEX index_drad.
*    ENDLOOP.

  endloop.

  itab_drad[] = itab_drad_tmp[].

*  LOOP AT itab_drad INTO wa_drad.
*    index_drad = sy-tabix.
*    CLEAR itab_stko.
*    CLEAR itab_stpo.
*    CLEAR wa_stko.
*    CLEAR wa_stpo.
*
*    CALL FUNCTION 'CSAP_DOC_BOM_READ'
*      EXPORTING
*        document             = wa_drad-doknr
*        doc_type             = wa_drad-dokar
*        doc_part             = wa_drad-doktl
*        doc_vers             = wa_drad-dokvr
**       VALID_FROM           =
**       VALID_TO             =
**       CHANGE_NO            =
**       REVISION_LEVEL       =
**     IMPORTING
**       FL_WARNING           =
*      TABLES
*        t_stpo               = itab_stpo
*        t_stko               = itab_stko
*      EXCEPTIONS
*        error                = 1
*        OTHERS               = 2
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      CONTINUE.
*    ELSE.
*      LOOP AT itab_stpo INTO wa_stpo.
*        CLEAR wa_drad_tmp.
*        wa_drad_tmp-doknr = wa_stpo-document.
*        wa_drad_tmp-dokar = wa_stpo-doc_type.
*        wa_drad_tmp-doktl = wa_stpo-doc_part.
*        wa_drad_tmp-dokvr = wa_stpo-doc_vers.
*        INSERT wa_drad_tmp INTO itab_drad INDEX index_drad.
*      ENDLOOP.
*    ENDIF.
*  ENDLOOP.


endform.                    " dok_stl_aufloesen
*&---------------------------------------------------------------------*
*&      Form  make_ID_SL_TMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_id_sl_tmp.
* ID erstellen
  data: id type zcl_sl_tmp-id_sl.

  clear id.

  call function 'Z_CL_PLOT_ID_SL_GET_NEXT'
       exporting
            i_numrange_object   = 'ZCL_ID_SL'
            i_numrange_interval = '01'
       importing
            e_number            = id.

  loop at itab_zcl_sl_tmp into wa_zcl_sl_tmp.
    wa_zcl_sl_tmp-id_sl = id.
    modify itab_zcl_sl_tmp from wa_zcl_sl_tmp
      index sy-tabix.
  endloop.

endform.                    " make_ID_SL_TMP
*&---------------------------------------------------------------------*
*&      Form  make_sl_tmp_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form make_sl_tmp_entries.
* Einträge in ZCL_SL_TMP vornehmen

  loop at itab_zcl_sl_tmp into wa_zcl_sl_tmp.
    wa_zcl_sl_tmp-uname = sy-uname.
    wa_zcl_sl_tmp-id_sl_pos = sy-tabix.
    wa_zcl_sl_tmp-object_type = c_sl_object_type.

    wa_zcl_sl_tmp-zclinsname = sy-uname.
    wa_zcl_sl_tmp-zclinsdate = sy-datum.
    wa_zcl_sl_tmp-zclinstime = sy-uzeit.
    wa_zcl_sl_tmp-zclinsprog = sy-repid.
    wa_zcl_sl_tmp-zclupdname = wa_zcl_sl_tmp-zclinsname.
    wa_zcl_sl_tmp-zclupddate = wa_zcl_sl_tmp-zclinsdate.
    wa_zcl_sl_tmp-zclupdtime = wa_zcl_sl_tmp-zclinstime.
    wa_zcl_sl_tmp-zclupdprog = wa_zcl_sl_tmp-zclinsprog.


    insert into zcl_sl_tmp values wa_zcl_sl_tmp.
    if sy-subrc ne 0.
      message e003(zcl_plot_fertigung) with
        'ZCL_SL_TMP'  wa_zcl_sl_tmp-uname
        wa_zcl_sl_tmp-id_sl wa_zcl_sl_tmp-id_sl_pos.

    else.
    endif.

  endloop.

endform.                    " make_sl_tmp_entries
*&---------------------------------------------------------------------*
*&      Form  dok_link_aufloesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form dok_link_aufloesen.
* hole mit Dokument direkt verlinkte Dokumente
  data: itab_drad_tmp like itab_drad.
  data: itab_drad_tmp_2 type table of  drad.

  data: wa_drad_tmp like wa_drad.
  data: wa_drad_tmp_2 type drad.
  data: wa_draw_keys type draw.

  data: index_drad type i.

  clear itab_drad_tmp.

  loop at itab_drad into wa_drad.
    index_drad = sy-tabix.


    append wa_drad to itab_drad_tmp .

    clear itab_drad_tmp_2.
    clear wa_drad_tmp_2.

    select * from drad
      into corresponding fields of table itab_drad_tmp_2
      where dokar = wa_drad-dokar
      and doknr = wa_drad-doknr
      and dokvr = wa_drad-dokvr
      and doktl = wa_drad-doktl
      and dokob = 'DRAW'
      .
    if sy-subrc ne 0.
*    MESSAGE w000(zcl_plot_fertigung) WITH
*      'DRAD' wa_fertigung-aufnr 'PORDER' ''.
*    EXIT.
      continue.
    else.
      loop at itab_drad_tmp_2 into wa_drad_tmp_2.
        clear wa_draw_keys.
        wa_draw_keys+3 = wa_drad_tmp_2-objky.
        clear wa_drad_tmp.
        move-corresponding wa_draw_keys to wa_drad_tmp.
        wa_drad_tmp-object_type = c_lk_object_type.
        append wa_drad_tmp to itab_drad_tmp.
      endloop.
    endif.
  endloop.

  itab_drad[] = itab_drad_tmp[].

endform.                    " dok_link_aufloesen
*&---------------------------------------------------------------------*
*&      Form  dok_hier_aufloesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form dok_hier_aufloesen.
* löse Hierachie auf
  types: begin of tp_documents.
  types:   step type i.
          include structure draw.
  types:  end of tp_documents.

  data: itab_drad_tmp like itab_drad.
  data: itab_docs type table of tp_documents.
  data: itab_draw type table of draw.

  data: wa_drad_tmp like wa_drad.
  data: wa_draw_keys type draw.
  data: wa_draw type draw.
  data: wa_docs type tp_documents.

  data: index_drad type i.
  data: f_hierachie(1).

  clear itab_drad_tmp.

  loop at itab_drad into wa_drad.
    index_drad = sy-tabix.

    append wa_drad to itab_drad_tmp .

*   Spezialdokumente
    if wa_drad-doknr is initial or
      wa_drad-dokar is initial or
      wa_drad-doktl is initial or
      wa_drad-dokvr is initial.
      continue.
    else.
    endif.

*   Einstufig oder mehrstufig auflösen ?
    if wa_fertigung-knz_dok_hier_aufl_mehrst = 'X'.
      clear f_hierachie.
      call function 'CV115_DOC_HIERARCHIE_CHECK'
        exporting
          pf_dokar                  = wa_drad-dokar
          pf_doknr                  = wa_drad-doknr
          pf_dokvr                  = wa_drad-dokvr
          pf_doktl                  = wa_drad-doktl
*         PS_DRAW                   =
        importing
          pfx_hierarchie_flag       = f_hierachie
        exceptions
          not_found                 = 1
          others                    = 2
                .
      if sy-subrc <> 0.
        continue.
      else.
        if f_hierachie = 'X'.
          clear itab_docs.
          clear wa_docs.

          call function 'CV115_DOC_HIERARCHIE_GET'
               exporting
                    pf_dokar      = wa_drad-dokar
                    pf_doknr      = wa_drad-doknr
                    pf_dokvr      = wa_drad-dokvr
                    pf_doktl      = wa_drad-doktl
                    pf_direction  = 'DOWN'
               tables
                    ptx_documents = itab_docs
               exceptions
                    error         = 1
                    others        = 2.
          if sy-subrc <> 0.
            continue.
          else.
            loop at itab_docs into wa_docs.
              clear wa_drad_tmp.
              move-corresponding wa_docs to wa_drad_tmp.
*              wa_drad_tmp-object_type = c_hr_object_type.
              append wa_drad_tmp to itab_drad_tmp.
            endloop.
          endif.

        else. " is Hierachie Ende
          continue.
        endif.
      endif.
    else.
*     einstufig auflösen
      clear itab_draw.
      clear wa_draw.

      select * from draw into table itab_draw
        where prear = wa_drad-dokar
        and prenr = wa_drad-doknr
        and prevr = wa_drad-dokvr
        and pretl = wa_drad-doktl
        .
      if sy-subrc ne 0.
      else.
        loop at itab_draw into wa_draw.
          clear wa_drad_tmp.
          move-corresponding wa_draw to wa_drad_tmp.
*         wa_drad_tmp-object_type = c_hr_object_type.
          append wa_drad_tmp to itab_drad_tmp.
        endloop.
      endif.

    endif.

**   Test, ob übergeordnetes Dokument vorhanden.
*    SELECT SINGLE * FROM draw INTO wa_draw
*      WHERE dokar = wa_drad-dokar
*      AND doknr = wa_drad-doknr
*      AND dokvr = wa_drad-dokvr
*      AND doktl = wa_drad-doktl.
*    IF sy-subrc NE 0.
*    ELSE.
*      IF wa_draw-prenr IS INITIAL OR
*        wa_draw-prear IS INITIAL OR
*        wa_draw-pretl IS INITIAL OR
*        wa_draw-prevr IS INITIAL.
*      ELSE.
*        CLEAR wa_drad_tmp.
*        wa_drad_tmp-dokar = wa_draw-prear.
*        wa_drad_tmp-doknr = wa_draw-prenr.
*        wa_drad_tmp-dokvr = wa_draw-prevr.
*        wa_drad_tmp-doktl = wa_draw-pretl.
*
*        wa_drad_tmp-object_type = c_hr_object_type.
*        APPEND wa_drad_tmp TO itab_drad_tmp.
*      ENDIF.
*    ENDIF.
  endloop.

  itab_drad[] = itab_drad_tmp[].

endform.                    " dok_hier_aufloesen
