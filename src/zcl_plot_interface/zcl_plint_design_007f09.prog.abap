*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F09 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_aufnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_aufnr.
* Screen Attribute für AUFNR setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_aufnr = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTFA'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_aufnr = '0'.
    else.
      edit_aufnr = '1'.
    endif.

    init_aufnr = 'X'.
  else.
  endif.

  if edit_aufnr = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-AUFNR'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-AUFNR'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.



endform.                    " set_scr_attr_aufnr
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_vbeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_vbeln.
* Screen Attribute für VBELn setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_vbeln = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTVB'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_vbeln = '0'.
    else.
      edit_vbeln = '1'.
    endif.

    init_vbeln = 'X'.
  else.
  endif.

  if edit_vbeln = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-VBELN'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-VBELN'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.

endform.                    " set_scr_attr_vbeln
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
      username             = sy-uname
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

  if user_data-knz_use_kostl = 'X'.
  else.
    exit.
  endif.


  call function 'Z_CL_ASK_FOR_COSTCENTER'
       exporting
            i_user          = sy-uname
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
    clear msgv1.
    clear msgv2.
    clear msgv3.
    clear msgv4.
    msgv1 = sy-uname.
    call function '/CIDEON/APPL_LOG_WRITE_2'
         exporting
              i_object   = 'Z_CIDEON'
              i_subobj   = 'Z_PLOT'
              i_number   = 067
              i_msgtyp   = 'W'
              i_msgid    = 'ZCL_PLINT_MESSAGE_01'
              i_msgno    = 067
              i_msgv1    = msgv1
              i_msgv2    = msgv2
              i_msgv3    = msgv3
              i_msgv4    = msgv4
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
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_firma
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_firma.
* Screen Attribute für FIRMA setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_firma = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTFI'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_firma = '0'.
    else.
      edit_firma = '1'.
    endif.

    init_firma = 'X'.
  else.
  endif.

  if edit_firma = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-FIRMA'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-FIRMA'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.

endform.                    " set_scr_attr_firma
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_kostl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_kostl.
* Screen Attribute für KOSTENSTELLE setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_kostl = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTKS'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_kostl = '0'.
    else.
      edit_kostl = '1'.
    endif.

    init_kostl = 'X'.
  else.
  endif.

  if edit_kostl = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-KOSTL'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-KOSTL'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.

endform.                    " set_scr_attr_kostl
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_id_plotjob
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_id_plotjob.
* Screen Attribute für ID_PLOTJOB setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_id_plotjob = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTJN'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_id_plotjob = '0'.
    else.
      edit_id_plotjob = '1'.
    endif.

    init_id_plotjob = 'X'.
  else.
  endif.

  if edit_id_plotjob = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-ID_PLOTJOB'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-ID_PLOTJOB'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.

endform.                    " set_scr_attr_id_plotjob
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_pspid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_pspid.
* Screen Attribute für PSPID setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_pspid = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTPS'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_pspid = '0'.
    else.
      edit_pspid = '1'.
    endif.

    init_pspid = 'X'.
  else.
  endif.

  if edit_pspid = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-PSPID'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-PSPID'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.

endform.                    " set_scr_attr_pspid
*&---------------------------------------------------------------------*
*&      Form  get_special_dis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_special_dis.
* holt sich die Schlüsselfelder für einen nicht existenten DIS
  data: document type csap_dbom-doknr.
  data: doc_type type csap_dbom-dokar.
  data: doc_vers type csap_dbom-dokvr.
  data: doc_part type csap_dbom-doktl.

*NORMAL
  call function 'Z_CL_PLINT_ASK_DOCUMENT_NR'
       importing
            o_doknr = document
            o_dokar = doc_type
            o_dokvr = doc_vers
            o_doktl = doc_part
       exceptions
            error   = 1
            others  = 2.
  if sy-subrc <> 0.
    exit.
  endif.

  clear wa_search.

  wa_search-dokar = doc_type.
  wa_search-doknr = document.
  wa_search-dokvr = doc_vers.
  wa_search-doktl = doc_part.

  wa_search-knz_spez_dok = 'X'.

* Eintragen am Ende der Liste, falls nichts anderes markiert
  refresh itab_et_index_rows_searchlist.
  call method grid_searchlist->get_selected_rows
    importing
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  describe table itab_et_index_rows_searchlist lines count_lines.

  read table itab_et_index_rows_searchlist
    into wa_et_index_rows_searchlist index 1..
  if sy-subrc ne 0.
    append wa_search to itab_search.
  else.
    insert wa_search into itab_search index wa_et_index_rows_searchlist.
  endif.

**  IF count_lines = 1.
*    READ TABLE itab_et_index_rows_searchlist
*      INTO wa_et_index_rows_searchlist INDEX 1..
*    INSERT wa_search INTO itab_search INDEX wa_et_index_rows_searchlist
*.
**  ELSE.
**    APPEND wa_search TO itab_search.
**  ENDIF.



endform.                    " get_special_dis
*&---------------------------------------------------------------------*
*&      Form  get_DOKST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_dokst.
* holt sich erneut die Dokumentenstati
  data: dokst_tmp type draw-dokst.

  loop at itab_search into wa_search.

    if wa_search-knz_spez_dok = 'X' .
      continue.
    else.
    endif.

    select single dokst from draw into dokst_tmp
      where dokar = wa_search-dokar
      and doknr = wa_search-doknr
      and dokvr = wa_search-dokvr
      and doktl = wa_search-doktl
      .
    if sy-subrc ne 0.
    else.
      wa_search-dokst = dokst_tmp.
      modify itab_search from wa_search index sy-tabix.
    endif.

  endloop.


endform.                    " get_DOKST
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_lifnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_lifnr.
* Screen Attribute für LIFNR / NAME1_LIFNR setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_lifnr = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTLF'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_lifnr = '0'.
    else.
      edit_lifnr = '1'.
    endif.

    init_lifnr = 'X'.
  else.
  endif.

  if edit_lifnr = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-LIFNR'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
      if screen-name = 'WA_AKT_PLOTJOBS-NAME1_LIFNR'.
        screen-input = '0'.
        modify screen.
      else.
      endif.

    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-LIFNR'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
      if screen-name = 'WA_AKT_PLOTJOBS-NAME1_LIFNR'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.

endform.                    " set_scr_attr_lifnr
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_ebeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_scr_attr_ebeln.
* Screen Attribute für EBELN setzen

* neues Rollenkonzept eingeschaltet?
  if user_data-knz_use_new_roles = 'X'.
  else.
    exit.
  endif.

  if init_pspid = ''.
*   Berechtigung testen
*   Ändern des Feldes
    authority-check object 'ZCL_PLOTEB'
             id 'ZCL_TA' field sy-tcode
             id 'ACTVT' field '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    if sy-subrc ne 0.
      edit_pspid = '0'.
    else.
      edit_pspid = '1'.
    endif.

    init_pspid = 'X'.
  else.
  endif.

  if edit_pspid = 0.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-EBELN'.
        screen-input = '0'.
        modify screen.
      else.
      endif.
    endloop.
  else.
    loop at screen.
      if screen-name = 'WA_AKT_PLOTJOBS-EBELN'.
        screen-input = '1'.
        modify screen.
      else.
      endif.
    endloop.
  endif.

endform.                    " set_scr_attr_ebeln
