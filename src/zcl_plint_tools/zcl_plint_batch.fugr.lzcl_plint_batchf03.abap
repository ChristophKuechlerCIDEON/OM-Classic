*----------------------------------------------------------------------*
*   INCLUDE LZCL_PLINT_BATCHF03                                        *
*----------------------------------------------------------------------*
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
    where uname = g_user.
  if sy-subrc ne 0.
  else.
  endif.

* Gruppendaten
  select  * from zcl_group_user
    into wa_group_user
    where uname = g_user
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
    where uname = wa_default_data-default_nutzer
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
*&      Form  itab_search_to_draw
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form itab_search_to_draw.

  refresh itab_draw.

  loop at itab_search into wa_search.
    move-corresponding wa_search to wa_draw.
    append wa_draw to itab_draw.
  endloop.

endform.                    " itab_search_to_draw
*&---------------------------------------------------------------------*
*&      Form  zori_doc_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form zori_doc_files.

  data:   ind_cont,
          incr type n.

  data: zdate(10) type c,
        ztime(8) type c.

  data: tdrad           type drad           occurs 0 with header line.

  data: bapi_doc_draw2  type bapi_doc_draw2 occurs 0 with header line,
        bapiret2        type bapiret2       occurs 0 with header line,
        bapi_doc_tdwa   type bapi_doc_tdwa  occurs 0 with header line,
        t1_bapi_doc_files2 type bapi_doc_files2 occurs 0
                                                     with header line,
        t2_bapi_doc_files2 type bapi_doc_files2 occurs 0
                                                     with header line,
        t1_zori_doc_files type zori_doc_files occurs 0
                                                     with header line.
  data : docfile like bapi_doc_files2-docfile.

  refresh itab_draw_2.
  refresh itab_zori_doc_files_3.
  refresh itab_zori_doc_files_detail_3.
  refresh itab_fail_document_3.

  itab_draw_2[] = itab_draw[].

  loop at itab_draw_2 into wa_draw_2.
    index_itab_draw_2 = sy-tabix.

    refresh itab_draw.
    append wa_draw_2 to itab_draw.

    refresh itab_zori_doc_files.
    refresh itab_zori_doc_files_detail.
    refresh itab_fail_document.

*   Sondereinträge verarbeiten
    read table itab_search into wa_search
      index index_itab_draw_2.
    if wa_search-knz_spez_dok = 'X'.
*         ITAB_ZORI_* manipulieren
      clear wa_zori_doc_files.
      move-corresponding wa_search to wa_zori_doc_files.
      wa_zori_doc_files-cont = 1.
      "concatenate 'c:\' text-F01 into wa_zori_doc_files-filep.
      concatenate 'c:\' wa_search-object_type into
         wa_zori_doc_files-filep.

      clear wa_zori_doc_files_detail.
      wa_zori_doc_files_detail-documenttype = wa_search-dokar.
      wa_zori_doc_files_detail-documentnumber = wa_search-doknr
.
      wa_zori_doc_files_detail-documentpart = wa_search-doktl.
      wa_zori_doc_files_detail-documentversion = wa_search-dokvr.

      append wa_zori_doc_files to itab_zori_doc_files.
      append wa_zori_doc_files_detail to itab_zori_doc_files_detail
.


      loop at itab_zori_doc_files into wa_zori_doc_files.
        append wa_zori_doc_files to itab_zori_doc_files_3.
      endloop.
      loop at itab_zori_doc_files_detail
        into wa_zori_doc_files_detail.
        append wa_zori_doc_files_detail
          to itab_zori_doc_files_detail_3.
      endloop.
      loop at itab_fail_document into wa_fail_document.
        append wa_fail_document to itab_fail_document_3.
      endloop.

      continue.
    else.
    endif.

    if itab_filetype is initial.
    else.
      loop at itab_filetype into wa_filetype.
        move-corresponding wa_filetype to it_tdwp.
        append it_tdwp.
      endloop.
    endif.
    clear wa_filetype.

    loop at itab_draw into wa_draw.

      clear: ind_cont.

      if ind_cont is initial.

        refresh tdrad.

        select * from drad into tdrad where
                       dokar = wa_draw-dokar
                   and doknr = wa_draw-doknr
                   and doktl = wa_draw-doktl
                   and dokvr = wa_draw-dokvr.

          append tdrad.

        endselect.

*  Get the complete details of the documents that R selected.
        call function 'BAPI_DOCUMENT_GETDETAIL2'
          exporting
            documenttype               = wa_draw-dokar
            documentnumber             = wa_draw-doknr
            documentpart               = wa_draw-doktl
            documentversion            = wa_draw-dokvr
*         GETOBJECTLINKS             = ' '
*         GETCOMPONENTS              = ' '
*         GETSTATUSLOG               = ' '
*         GETLONGTEXTS               = ' '
*         GETACTIVEFILES             = 'X'
          importing
            documentdata               = bapi_doc_draw2
            return                     = bapiret2
          tables
*         OBJECTLINKS                =
*         DOCUMENTDESCRIPTIONS       =
*         LONGTEXTS                  =
*         STATUSLOG                  =
            documentfiles              = t1_bapi_doc_files2
*         COMPONENTS                 =
                  .

        clear bapiret2.


* Move the values from the internal table t1_bapi_doc_files2 to
* t2_bapi_doc_files2 for the purpose of allowing to fill it again
* with other values and clear the internal table t1_bapi_doc_files2.
        loop at t1_bapi_doc_files2.

          move t1_bapi_doc_files2 to t2_bapi_doc_files2.

          move wa_draw-dokar to t2_bapi_doc_files2-documenttype.
          move wa_draw-doknr to t2_bapi_doc_files2-documentnumber.
          move wa_draw-doktl to t2_bapi_doc_files2-documentpart.
          move wa_draw-dokvr to t2_bapi_doc_files2-documentversion.

          append t2_bapi_doc_files2.
          delete t1_bapi_doc_files2.
          clear t1_bapi_doc_files2.

        endloop.

        if sy-subrc ne 0.
          move wa_draw-dokar to wa_fail_document-dokar.
          move wa_draw-doknr to wa_fail_document-doknr.
          move wa_draw-dokvr to wa_fail_document-dokvr.
          move wa_draw-doktl to wa_fail_document-doktl.
          move 'X' to wa_fail_document-knz_kein_file.
          move 'X' to wa_fail_document-knz_garkein_file.

          append wa_fail_document to itab_fail_document.
        endif.


      endif.
    endloop.

* Process from here only when there is some data available
* in the table t2_bapi_doc_files2.
    if not ( t2_bapi_doc_files2[] is initial ).
      sort t2_bapi_doc_files2 by documentnumber.

*   Looping at the detatiled doc values where the WSA is a value
*   from the it_tdwp.
      clear t2_bapi_doc_files2.
      loop at t2_bapi_doc_files2 . "WHERE wsapplication = it_tdwp-dappl.

*     Looping at the selected Work Station Application(WSA) table .
        loop at it_tdwp where dappl = t2_bapi_doc_files2-wsapplication.

          incr = incr + 1.

          move incr to t1_zori_doc_files-cont.

          move t2_bapi_doc_files2-documenttype
                             to t1_zori_doc_files-dokar.
          move t2_bapi_doc_files2-documentnumber
                             to t1_zori_doc_files-doknr.
          move t2_bapi_doc_files2-documentpart
                             to t1_zori_doc_files-doktl.
          move t2_bapi_doc_files2-documentversion
                             to t1_zori_doc_files-dokvr.
          move t2_bapi_doc_files2-originaltype
                             to t1_zori_doc_files-cont.

      concatenate t2_bapi_doc_files2-docpath t2_bapi_doc_files2-docfile
                                                           into docfile.

          move docfile to t2_bapi_doc_files2-docfile.

          move t2_bapi_doc_files2-docfile
                             to t1_zori_doc_files-filep.

          move t2_bapi_doc_files2-checkedin
                             to t1_zori_doc_files-checked.

*       weitere Felder mitgeben
*        t1_zori_doc_files-
*        = t2_bapi_doc_files2-.
          t1_zori_doc_files-originaltype
            = t2_bapi_doc_files2-originaltype.
          t1_zori_doc_files-sourcedatacarrie
            = t2_bapi_doc_files2-sourcedatacarrier.
          t1_zori_doc_files-storagecategory
            = t2_bapi_doc_files2-storagecategory.
          t1_zori_doc_files-wsapplication
            = t2_bapi_doc_files2-wsapplication.
          t1_zori_doc_files-application_id
            = t2_bapi_doc_files2-application_id.
          t1_zori_doc_files-file_id
            = t2_bapi_doc_files2-file_id.
          t1_zori_doc_files-description
            = t2_bapi_doc_files2-description.
          t1_zori_doc_files-language
            = t2_bapi_doc_files2-language.
          t1_zori_doc_files-active_version
                  = t2_bapi_doc_files2-active_version.
          t1_zori_doc_files-created_at
                  = t2_bapi_doc_files2-created_at.
          t1_zori_doc_files-changed_at
                  = t2_bapi_doc_files2-changed_at.
* Problem mit SPs, kommt wahrscheinlich erst bei SP43/44/45
*        t1_zori_doc_files-created_by
*                = t2_bapi_doc_files2-created_by.
*        t1_zori_doc_files-changed_by
*                = t2_bapi_doc_files2-changed_by.
*        t1_zori_doc_files-content_descript
*                = t2_bapi_doc_files2-content_description.


*       Split the TIMESTAMP into date and time, as we need only date.
          split t2_bapi_doc_files2-created_at at ' ' into zdate ztime.

          move zdate to t1_zori_doc_files-cdate.

          append t1_zori_doc_files.

          move t2_bapi_doc_files2 to wa_zori_doc_files_detail.
          append wa_zori_doc_files_detail to itab_zori_doc_files_detail.

          move t1_zori_doc_files to wa_zori_doc_files.
          append wa_zori_doc_files to itab_zori_doc_files.

          clear : zdate, ztime.
          clear wa_zori_doc_files-cdate.

        endloop.

        if sy-subrc ne 0.
          move t2_bapi_doc_files2-documenttype
                                  to wa_fail_document-dokar.
          move t2_bapi_doc_files2-documentnumber
                                  to wa_fail_document-doknr.
          move t2_bapi_doc_files2-documentversion
                                  to wa_fail_document-dokvr.
          move t2_bapi_doc_files2-documentpart
                                  to wa_fail_document-doktl.
          move 'X'                to wa_fail_document-knz_kein_file.
          move ' '                to wa_fail_document-knz_garkein_file.

          append wa_fail_document to itab_fail_document.
        endif.

      endloop.

    endif.

**...§§ Commented on 15.01.2003...begin..
*
* Sort the internal table to eliminate the dupllicate values.
* sort with this values and delete the duplicates.
    sort itab_fail_document ascending.
    delete adjacent duplicates from itab_fail_document
                        comparing dokar
                                  doknr
                                  dokvr
                                  doktl
                                  knz_kein_file
                                  knz_garkein_file.

* Sort the internal table to eliminate the dupllicate values.
* As here only Paths of the files (i.e filep) unique value
* sort with this values and delete the duplicates.
    sort itab_zori_doc_files by dokar
                                doknr
                                dokvr
                                doktl
                                filep
                                checked.

    delete adjacent duplicates from itab_zori_doc_files
                        comparing dokar
                                  doknr
                                  dokvr
                                  doktl
                                  filep
                                  checked.

* Sort the internal table to eliminate the dupllicate values.
* As here only Paths of the files (i.e docfile) unique value
* sort with this values and delete the duplicates.
    sort itab_zori_doc_files_detail by documenttype
                                 documentnumber
                                 documentversion
                                 documentpart
                                 docfile
                                 checkedin.

    delete adjacent duplicates from itab_zori_doc_files_detail
                      comparing documenttype
                                documentnumber
                                documentversion
                                documentpart
                                docfile
                                checkedin.


*...§§ Commented on 15.01.2003...begin..

    data: index_fail type sy-tabix.

    loop at itab_fail_document into wa_fail_document.
      index_fail = sy-tabix.
      loop at itab_zori_doc_files into wa_zori_doc_files
                                where dokar = wa_fail_document-dokar
                                and   doknr = wa_fail_document-doknr
                                and   dokvr = wa_fail_document-dokvr
                                and   doktl = wa_fail_document-doktl.

        delete itab_fail_document index index_fail.
      endloop.
    endloop.

    clear it_tdwp.
    refresh it_tdwp.
    clear it_tdwp[].
    .
    if sy-subrc ne 0.
      if sy-subrc = 2.
        refresh itab_zori_doc_files_3.
        refresh itab_zori_doc_files_detail_3.
        refresh itab_fail_document_3.
        exit.
      else.
      endif.
    else.
    endif.


*   normale Weitergabe von Informationen speziellen Felder des
*   Fertigungsauftrages / CS Auftrages
    loop at itab_zori_doc_files into wa_zori_doc_files.
      wa_zori_doc_files-aufnr_pp = wa_search-aufnr_pp.
      wa_zori_doc_files-aufpl = wa_search-aufpl.
      wa_zori_doc_files-aplzl = wa_search-aplzl.
      wa_zori_doc_files-knz_affl = wa_search-knz_affl.
      wa_zori_doc_files-knz_afvc = wa_search-knz_afvc.
      wa_zori_doc_files-verteiler = wa_search-verteiler.

      wa_zori_doc_files-folnr = wa_search-folnr.
      wa_zori_doc_files-vornr = wa_search-vornr.

      wa_zori_doc_files-matnr = wa_search-matnr.

      wa_zori_doc_files-res4 = wa_search-res4.

      wa_zori_doc_files-drtxt = wa_search-drtxt.
      wa_zori_doc_files-tdotftype = wa_search-tdotftype.
      wa_zori_doc_files-tdspoolid = wa_search-tdspoolid.

      wa_zori_doc_files-psteu = wa_search-psteu.
      wa_zori_doc_files-samlt = wa_search-samlt.
      wa_zori_doc_files-pmode = wa_search-pmode.
      wa_zori_doc_files-drart = wa_search-drart.
      wa_zori_doc_files-ktext = wa_search-ktext.
      wa_zori_doc_files-selpr = wa_search-selpr.
      wa_zori_doc_files-tcode = wa_search-tcode.

      wa_zori_doc_files-projn = wa_search-projn.

      wa_zori_doc_files-aufnr_cs = wa_search-aufnr_cs.

      modify itab_zori_doc_files from wa_zori_doc_files index sy-tabix.
    endloop.


    loop at itab_zori_doc_files into wa_zori_doc_files.
      append wa_zori_doc_files to itab_zori_doc_files_3.
    endloop.
    loop at itab_zori_doc_files_detail
      into wa_zori_doc_files_detail.
      append wa_zori_doc_files_detail
        to itab_zori_doc_files_detail_3.
    endloop.
    loop at itab_fail_document into wa_fail_document.
      append wa_fail_document to itab_fail_document_3.
    endloop.

  endloop.

  itab_draw[] = itab_draw_2[].
  itab_zori_doc_files[] = itab_zori_doc_files_3[].
  itab_zori_doc_files_detail[] = itab_zori_doc_files_detail_3[].
  itab_fail_document[] = itab_fail_document_3[].

endform.                    " zori_doc_files
*&---------------------------------------------------------------------*
*&      Form  add_to_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0265   text
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
    wa_plotjobs-uname  = wa_user_data-uname.
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


  call function '/CIDEON/ADD_OBJECTKEY_TO_PLOTL'
       tables
            itab_tmp_plotjobs = itab_tmp_plotjobs
       exceptions
            error             = 1
            others            = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


  if wa_user_data-knz_use_merkmal_format = 'X'.
    data: tmp_atwrt like ausp-atwrt.

    loop at itab_tmp_plotjobs into wa_plotjobs.
      clear tmp_atwrt.
      select single atwrt from ausp
        into tmp_atwrt
        where objek = wa_plotjobs-objky
        and atinn = wa_default_data-merkmal_format
        .
      if sy-subrc ne 0.
        perform appl_log_write using
          'W' '022' 'ZCL_PLINT_MESSAGE_01'
           wa_plotjobs-dokar wa_plotjobs-doknr
           wa_plotjobs-dokvr wa_plotjobs-doktl.
      else.
        wa_plotjobs-format_ausgabe = tmp_atwrt.
        modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
      endif.
    endloop.
  else.
  endif.

  if wa_user_data-knz_use_multipage = 'X'.
    perform check_for_multipage.
  else.
  endif.

**   ask for fitting distributor
**Z_CL_GET_VERTEILER
*  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
*
*    " check for using of CLF / PPL
*    IF wa_user_data-knz_use_post = 'X'.
*    ELSE.
*      EXIT.
*    ENDIF.
*
*    CALL FUNCTION 'Z_CL_GET_VERTEILER'
*         EXPORTING
*              i_uname          = wa_user_data-uname
*              i_wa_plotjobs    = wa_plotjobs
*         IMPORTING
*              o_voreinstellung = wa_voreinstellung
*              o_verteiler      = wa_verteiler
*              o_bedingung      = wa_bedingung
*         EXCEPTIONS
*              error            = 1
*              not_found        = 2
*              OTHERS           = 3.
*    IF sy-subrc <> 0.
**     try with default_user
*      CALL FUNCTION 'Z_CL_GET_VERTEILER'
*           EXPORTING
*                i_uname          = wa_default_data-default_nutzer
*                i_wa_plotjobs    = wa_plotjobs
*           IMPORTING
*                o_voreinstellung = wa_voreinstellung
*                o_verteiler      = wa_verteiler
*                o_bedingung      = wa_bedingung
*           EXCEPTIONS
*                error            = 1
*                not_found        = 2
*                OTHERS           = 3.
*      IF sy-subrc <> 0.
**       get the default values
*        CLEAR tmp_uname.
*        tmp_uname = wa_plotjobs-uname.
*        CLEAR tmp_format_ausgabe.
*        tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
*        wa_plotjobs-prio = wa_default_data-default_prio.
*        wa_plotjobs-kopien = wa_default_data-default_kopien.
*        wa_plotjobs-verteiler = wa_user_data-verteiler.
*        MOVE-CORRESPONDING wa_default_verteiler TO wa_plotjobs.
*        wa_plotjobs-verteiler = wa_default_data-default_verteiler.
*        wa_plotjobs-uname = tmp_uname.
*        IF tmp_format_ausgabe IS INITIAL.
*        ELSE.
*          wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
*          wa_plotjobs-zielformat = tmp_format_ausgabe.
*        ENDIF.
*        wa_plotjobs-satzanzahl = wa_default_data-default_satzanzahl.
*        wa_plotjobs-deckblatt = wa_default_data-default_deckblatt.
*        wa_plotjobs-endeblatt = wa_default_data-default_endeblatt.
*        wa_plotjobs-fehlblatt = wa_default_data-default_fehlblatt.
*      wa_plotjobs-knz_inhalt_vz = wa_default_data-default_knz_inhalt_vz
*.
*        wa_plotjobs-inhaltsblatt = wa_default_data-default_inhaltsblatt
*.
*      ELSE.
*        CLEAR tmp_uname.
*        tmp_uname = wa_plotjobs-uname.
*        CLEAR tmp_format_ausgabe.
*        tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
*        MOVE-CORRESPONDING wa_voreinstellung TO wa_plotjobs.
*        wa_plotjobs-uname = tmp_uname.
*        wa_plotjobs-prio = wa_default_data-default_prio.
*        wa_plotjobs-verteiler = wa_verteiler-verteiler.
*        IF tmp_format_ausgabe IS INITIAL.
*        ELSE.
*          wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
*          wa_plotjobs-zielformat = tmp_format_ausgabe.
*        ENDIF.
*        wa_plotjobs-satzanzahl = wa_bedingung-satzanzahl.
*        wa_plotjobs-deckblatt = wa_bedingung-deckblatt.
*        wa_plotjobs-endeblatt = wa_bedingung-endeblatt.
*        wa_plotjobs-fehlblatt = wa_default_data-default_fehlblatt.
*        wa_plotjobs-knz_inhalt_vz = wa_bedingung-knz_inhalt_vz.
*        wa_plotjobs-inhaltsblatt = wa_bedingung-inhaltsblatt.
*      ENDIF.
*    ELSE.
*      CLEAR tmp_uname.
*      tmp_uname = wa_plotjobs-uname.
*      CLEAR tmp_format_ausgabe.
*      tmp_format_ausgabe = wa_plotjobs-format_ausgabe.
*      MOVE-CORRESPONDING wa_voreinstellung TO wa_plotjobs.
*      wa_plotjobs-uname = tmp_uname.
*      wa_plotjobs-prio = wa_default_data-default_prio.
*      wa_plotjobs-verteiler = wa_verteiler-verteiler.
*      IF tmp_format_ausgabe IS INITIAL.
*      ELSE.
*        wa_plotjobs-format_ausgabe = tmp_format_ausgabe.
*        wa_plotjobs-zielformat = tmp_format_ausgabe.
*      ENDIF.
*      wa_plotjobs-satzanzahl = wa_bedingung-satzanzahl.
*      wa_plotjobs-deckblatt = wa_bedingung-deckblatt.
*      wa_plotjobs-endeblatt = wa_bedingung-endeblatt.
*      wa_plotjobs-fehlblatt = wa_bedingung-fehlblatt.
*      wa_plotjobs-knz_inhalt_vz = wa_bedingung-knz_inhalt_vz.
*      wa_plotjobs-inhaltsblatt = wa_bedingung-inhaltsblatt.
*    ENDIF.
*
*    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.
*  ENDLOOP.
**   ask for fitting distributor end

* default values
  loop at itab_tmp_plotjobs into wa_plotjobs.
    " check for using of CLF / PPL
    if wa_user_data-knz_use_post = 'X'.
      exit.
    else.
    endif.

    wa_plotjobs-preprocessor = wa_user_data-preprocessor.

    wa_plotjobs-prio = wa_default_data-default_prio.
    wa_plotjobs-kopien = wa_default_data-default_kopien.

*   möglicherweise schon vorbelegt
    if wa_plotjobs-verteiler is initial.
      wa_plotjobs-verteiler = wa_user_data-verteiler.
    else.
    endif.

    "MOVE-CORRESPONDING wa_default_verteiler TO wa_plotjobs.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.
* default values ende



* Kennzeichen Fehlblatt
  loop at itab_tmp_plotjobs into wa_plotjobs.
    wa_plotjobs-knz_fehl_blatt = p_knz_fehl_blatt.
    if wa_plotjobs-knz_fehl_blatt = 'X'.
*      wa_plotjobs-light = 1.
      wa_plotjobs-icon_fehlblatt = wa_user_data-fehlblatt_icon.
    else.
*      wa_plotjobs-light = 3.
      wa_plotjobs-icon_fehlblatt = ''.
    endif.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.

* Spezialdokumente
  loop at itab_tmp_plotjobs into wa_plotjobs.
    if wa_plotjobs-knz_spez_dok = 'X'.
      wa_plotjobs-icon_spez_dok = wa_user_data-spez_dok_icon.
    else.
      continue.
    endif.
    modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
  endloop.

* default values
  loop at itab_tmp_plotjobs into wa_plotjobs.
    " check for using of CLF / PPL
    if wa_user_data-knz_use_post = 'X'.
      exit.
    else.
    endif.

    wa_plotjobs-preprocessor = wa_user_data-preprocessor.

    wa_plotjobs-prio = wa_default_data-default_prio.
    wa_plotjobs-kopien = wa_default_data-default_kopien.

*   möglicherweise schon vorbelegt
    if wa_plotjobs-verteiler is initial.
      wa_plotjobs-verteiler = wa_user_data-verteiler.
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
    if wa_user_data-knz_use_post = 'X'.
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
          where uname = g_user
          and status = c_status_aktiv
          .
        if sy-subrc ne 0.
          "Defaultbenutzer verwenden
          select single * from zcl_preproz_user into wa_tmp_prep_usr
            where uname = wa_default_data-default_nutzer
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



  perform add_compression_field.
*  PERFORM add_special_fields.
  perform check_priorities.
* DIS Status Visiualisierung etc.
  perform get_dok_status.

  perform reindex_table.
*  SORT itab_tmp_plotjobs BY dokar doknr dokvr doktl cont.
  loop at itab_tmp_plotjobs into wa_plotjobs.
    append wa_plotjobs to itab_plotjobs.
  endloop.

endform.                    " add_to_plotlist
*&---------------------------------------------------------------------*
*&      Form  add_compression_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_compression_field.
  data: tmp_kompression like zcl_comp_tiff-typ_kompression.
  data: langu type sy-langu.


  loop at itab_tmp_plotjobs into wa_plotjobs.
    if wa_plotjobs-kompression is initial.
    else.
      continue.
    endif.
    clear tmp_kompression.
    set locale language langu.
    translate wa_plotjobs-typ to upper case.
    set locale language space.
    select single typ_kompression from zcl_comp_tiff
      into tmp_kompression
      where typ_tiff = wa_plotjobs-typ
      .
    if sy-subrc ne 0.
      wa_plotjobs-kompression = 'KEINE'.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    else.
      wa_plotjobs-kompression = tmp_kompression.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    endif.
  endloop.


endform.                    " add_compression_field
*&---------------------------------------------------------------------*
*&      Form  check_for_multipage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_for_multipage.
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
*&      Form  check_priorities
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_priorities.
* sets the priorities to allowed values
  loop at itab_tmp_plotjobs into wa_plotjobs.
    if wa_plotjobs-prio > wa_user_data-prio_bis.
      wa_plotjobs-prio = wa_user_data-prio_bis.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    else.
    endif.
    if wa_plotjobs-prio < wa_user_data-prio_von.
      wa_plotjobs-prio = wa_user_data-prio_von.
      modify itab_tmp_plotjobs from wa_plotjobs index sy-tabix.
    else.
    endif.
  endloop.

endform.                    " check_priorities
*&---------------------------------------------------------------------*
*&      Form  get_dok_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_dok_status.
* DOKST, STABK, TXT
  data: index_tab type sy-tabix.

  loop at itab_tmp_plotjobs into wa_plotjobs.
    index_tab = sy-tabix.

    loop at itab_search into wa_search
      where dokar = wa_plotjobs-dokar
      and doknr = wa_plotjobs-doknr
      and dokvr = wa_plotjobs-dokvr
      and doktl = wa_plotjobs-doktl
      .
    endloop.

    if sy-subrc ne 0.
    else.
      wa_plotjobs-dokst = wa_search-dokst.
      wa_plotjobs-stabk = wa_search-stabk.
      wa_plotjobs-dostx = wa_search-dostx.
      wa_plotjobs-mstae = wa_search-mstae.
      wa_plotjobs-mstde = wa_search-mstde.
      wa_plotjobs-mat_count = wa_search-mat_count.

      wa_plotjobs-light = wa_search-knz_freigabe.

      modify itab_tmp_plotjobs from wa_plotjobs index index_tab.
    endif.
  endloop.


endform.                    " get_dok_status
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

  perform add_to_plotlist using 'X'.


endform.                    " create_fail_items
*&---------------------------------------------------------------------*
*&      Form  set_knz_use_checked_in
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_knz_use_checked_in.
* abgelegte Dateien bevorzugen?
  data: index_plotjobs type sy-tabix.

  if wa_user_data-knz_use_checked_in = 'X'.
    loop at itab_plotjobs into wa_plotjobs.
      index_plotjobs = sy-tabix.
*     Testen ob abgelegte Version benutzt werden kann
      if wa_plotjobs-checked is initial.
        if wa_plotjobs-storagecategory is initial.
          clear wa_plotjobs-knz_use_checked_in.
        else.
          wa_plotjobs-knz_use_checked_in = 'X'.
          clear wa_plotjobs-knz_fehl_blatt.
*          wa_plotjobs-light = '3'.
          clear wa_plotjobs-icon_fehlblatt.
        endif.
      else.
        wa_plotjobs-knz_use_checked_in = 'X'.
      endif.
      modify itab_plotjobs from wa_plotjobs index index_plotjobs.
    endloop.
  else.
    loop at itab_plotjobs into wa_plotjobs.
      index_plotjobs = sy-tabix.
      if wa_plotjobs-checked is initial.
        clear wa_plotjobs-knz_use_checked_in.
      else.
        wa_plotjobs-knz_use_checked_in = 'X'.
      endif.
      modify itab_plotjobs from wa_plotjobs index index_plotjobs.
    endloop.
  endif.

endform.                    " set_knz_use_checked_in
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
*&      Form  add_client_data_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_client_data_3.
* Adds special client data to plotjobs
  data: wa_kna1 like kna1.
  data: mailadresse type ad_smtpadr.
  data: n10(10) type n.

  clear wa_kna1.
  clear mailadresse.


  data: rc type table of bapiret2.
  data: wa_address type bapiaddr3.
  data: wa_company type bapiuscomp.

  data: itab_addtel type table of bapiadtel.
  data: itab_addsmtp type table of bapiadsmtp.

* Parameter
  data: itab_parameter type table of bapiparam.
  data: wa_parameter type bapiparam.

  clear rc.
  clear wa_address.
  clear wa_company.
  clear itab_addtel.
  clear itab_addsmtp.

  clear wa_parameter.
  clear itab_parameter.

  call function 'BAPI_USER_GET_DETAIL'
    exporting
      username             = g_user
   importing
*     LOGONDATA            =
*     DEFAULTS             =
     address              = wa_address
     company              = wa_company
*     SNC                  =
*     REF_USER             =
*     alias                = wa_alias
    tables
      parameter            = itab_parameter
*     PROFILES             =
*     ACTIVITYGROUPS       =
      return               = rc
      addtel               = itab_addtel
*     ADDFAX               =
*     ADDTTX               =
*     ADDTLX               =
      addsmtp              = itab_addsmtp
*     ADDRML               =
*     ADDX400              =
*     ADDRFC               =
*     ADDPRT               =
*     ADDSSF               =
*     ADDURI               =
*     ADDPAG               =
*     ADDCOMREM            =
*     GROUPS               =
            .

  clear g_dms_max_tmp_files.
  loop at itab_parameter into wa_parameter.
    if wa_parameter-parid = 'DMS_MAX_TMP_FILES'.
      g_dms_max_tmp_files = wa_parameter-parva.
    else.
    endif.
  endloop.

  loop at itab_plotjobs into wa_plotjobs.
    wa_plotjobs-name1 = wa_address-firstname.
    wa_plotjobs-name2 = wa_address-lastname.
*    "wa_plotjobs-firma = wa_kna1-
*    "wa_plotjobs-abteilung = wa_kna1-
*    wa_plotjobs-stras = wa_kna1-stras.
*    wa_plotjobs-ort1 = wa_kna1-ort01.
*    wa_plotjobs-pstlz = wa_kna1-pstlz.
    concatenate wa_address-tel1_numbr ' / ' wa_address-tel1_ext
      into wa_plotjobs-telf1.
*    wa_plotjobs-telf1 = .
*    wa_plotjobs-telfx = wa_kna1-telfx.
    wa_plotjobs-smtp_addr = wa_address-e_mail.
*
*
    wa_plotjobs-firma = wa_company-company.

    modify itab_plotjobs from wa_plotjobs index sy-tabix.

  endloop.

endform.                    " add_client_data_3
*&---------------------------------------------------------------------*
*&      Form  add_cost_center_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_cost_center_2.
* try to get the cost center for the user
  data: kostl like wa_plotjobs-kostl.

  if wa_user_data-knz_use_kostl = 'X'.
  else.
    exit.
  endif.


  call function 'Z_CL_ASK_FOR_COSTCENTER'
       exporting
            i_user          = g_user
       importing
            o_kostl         = kostl
       exceptions
            error           = 1
            pernr_not_found = 2
            kostl_not_found = 3
            others          = 4.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  make LOG entry
    clear text1.
    clear text2.
    clear text3.
    clear text4.
    text1 = g_user.
    call function '/CIDEON/APPL_LOG_WRITE_2'
         exporting
              i_object   = 'Z_CIDEON'
              i_subobj   = 'Z_PLOT'
              i_number   = 067
              i_msgtyp   = 'W'
              i_msgid    = 'ZCL_PLINT_MESSAGE_01'
              i_msgno    = 067
              i_msgv1    = text1
              i_msgv2    = text2
              i_msgv3    = text3
              i_msgv4    = text4
              i_class    = ' '
              i_newhead  = 'X'
              i_messhead = 'X'
         exceptions
              error      = 1
              others     = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

    exit.
  endif.


  loop at itab_plotjobs into wa_plotjobs.
    wa_plotjobs-kostl = kostl.
    modify itab_plotjobs from wa_plotjobs index sy-tabix.
  endloop.


endform.                    " add_cost_center_2
