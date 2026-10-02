*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_local_work_path
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_local_work_path.
* holt sich lokalen Arbeitspfad
  DATA: text(60).

* default_data-view_down_path
  CALL FUNCTION 'WS_QUERY'
    EXPORTING
*     ENVIRONMENT          =
*     FILENAME             =
      query                = 'CD'
*     WINID                =
   IMPORTING
      return               = default_data-view_down_path
   EXCEPTIONS
     inv_query            = 1
     no_batch             = 2
     frontend_error       = 3
     OTHERS               = 4
            .
  IF sy-subrc <> 0.
    CLEAR text.

    CASE sy-subrc.
      WHEN '1'.
        text = 'inv_query'.
      WHEN '2'.
        text = 'no_batch'.
      WHEN '3'.
        text = 'frontend_error'.
      WHEN '4'.
        text = 'others'.
      WHEN OTHERS.
        text = '????????'.
    ENDCASE.

    MESSAGE w164(zcl_plint_message_01)
      WITH text '/CIDEON/_OM_007F04' '' ''.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " get_local_work_path
*&---------------------------------------------------------------------*
*&      Form  view_originals_sl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_originals_sl.
* Original aus der Suchliste ansehen

  REFRESH itab_et_index_rows_searchlist.
  CALL METHOD grid_searchlist->get_selected_rows
    IMPORTING
      et_index_rows = itab_et_index_rows_searchlist.
*      ET_ROW_NO     =
  .
  DESCRIBE TABLE itab_et_index_rows_searchlist LINES count_lines.
  IF count_lines <> 1.
    REFRESH itab_et_index_rows_searchlist.
    MESSAGE e000(zcl_plint_message_01)
      WITH text-051 count_lines '' ''.
    EXIT.
  ELSE.
    READ TABLE itab_et_index_rows_searchlist
      INTO wa_et_index_rows_searchlist INDEX 1.
    READ TABLE itab_search INTO wa_search
      INDEX wa_et_index_rows_searchlist-index .
  ENDIF.

  CASE wa_search-object_type.
    WHEN 'SPOOL'.
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
           EXPORTING
                i_spoolid = wa_search-tdspoolid
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
                i_url = wa_search-url.
    WHEN OTHERS.
      SET PARAMETER ID 'CV1' FIELD wa_search-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_search-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_search-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_search-doktl.


* HOSTNAME holen
      DATA: hostname(20).
      CALL FUNCTION 'CV120_GET_HOSTNAME'
           EXPORTING
                pf_batch          = ' '
           IMPORTING
                pfx_host          = hostname
           EXCEPTIONS
                error             = 1
                no_valid_frontend = 2
                OTHERS            = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CALL FUNCTION 'CVAPI_DOC_VIEW'
        EXPORTING
          pf_dokar               = wa_search-dokar
          pf_doknr               = wa_search-doknr
          pf_dokvr               = wa_search-dokvr
          pf_doktl               = wa_search-doktl
          pf_hostname            = hostname
          pf_appl_start          = 'X'
*     PF_GET_URL             = ' '
          pf_apptp               = '1'
*     PF_ASK_FILENAME        = ' '
*     PF_FILENAME            = ' '
*     PS_FILE                =
*     PF_PARENT              =
*     PF_USE_DYNP            = ' '
*     PS_DRAP_AUDIT          =
*   IMPORTING
*     PFX_FILE               =
*     PFX_URL                =
*     PFX_VIEW_INPLACE       =
       EXCEPTIONS
          error                  = 1
          not_found              = 2
          no_auth                = 3
          no_original            = 4
          OTHERS                 = 5
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


  ENDCASE.


*
** Spoolbehandlung
*  if wa_search-object_type = 'SPOOL'.
*    call function '/CIDEON/DISPLAY_SPOOL_ID'
*         exporting
*              i_spoolid = wa_search-tdspoolid
*         exceptions
*              error     = 1
*              others    = 2.
*    if sy-subrc <> 0.
*      exit.
*    endif.
*    exit.
*  else.
*  endif.
*
*
*  set parameter id 'CV1' field wa_search-doknr.
*  set parameter id 'CV2' field wa_search-dokar.
*  set parameter id 'CV3' field wa_search-dokvr.
*  set parameter id 'CV4' field wa_search-doktl.
*
*
** HOSTNAME holen
*  data: hostname(20).
*  call function 'CV120_GET_HOSTNAME'
*       exporting
*            pf_batch          = ' '
*       importing
*            pfx_host          = hostname
*       exceptions
*            error             = 1
*            no_valid_frontend = 2
*            others            = 3.
*  if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
*
*  call function 'CVAPI_DOC_VIEW'
*    exporting
*      pf_dokar               = wa_search-dokar
*      pf_doknr               = wa_search-doknr
*      pf_dokvr               = wa_search-dokvr
*      pf_doktl               = wa_search-doktl
*      pf_hostname            = hostname
*      pf_appl_start          = 'X'
**     PF_GET_URL             = ' '
*      pf_apptp               = '1'
**     PF_ASK_FILENAME        = ' '
**     PF_FILENAME            = ' '
**     PS_FILE                =
**     PF_PARENT              =
**     PF_USE_DYNP            = ' '
**     PS_DRAP_AUDIT          =
**   IMPORTING
**     PFX_FILE               =
**     PFX_URL                =
**     PFX_VIEW_INPLACE       =
*   exceptions
*      error                  = 1
*      not_found              = 2
*      no_auth                = 3
*      no_original            = 4
*      others                 = 5
*            .
*  if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
*
*

ENDFORM.                    " view_originals_sl
*&---------------------------------------------------------------------*
*&      Form  change_fronttype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_fronttype.
  DATA: lf_text LIKE rseu0_fun-short.
** ---------------------------------------------------------------------

  CALL FUNCTION 'CV117_FRONTEND_TYPE_SELECT'
      EXPORTING: pf_hostname           = gs_frontend-hostname
                 pf_frontend_type      = gs_frontend-frontend_type
                 pf_update_db          = 'X'
      IMPORTING: pfx_new_frontend_type = gs_frontend-frontend_type
      EXCEPTIONS: error                 = 1
                  error_update_db       = 2
                  no_change             = 3
                  no_valid_host         = 4
                  not_allowed           = 5
                  OTHERS                = 6.
  CASE sy-subrc.
    WHEN 5.
      PERFORM sys_get_function_text
          USING ok_code
          CHANGING lf_text.

      MESSAGE s163(zcl_plint_message_01) WITH lf_text.
  ENDCASE.

ENDFORM.                    " change_fronttype
*&---------------------------------------------------------------------*
*&      Form  sys_get_function_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*      <--P_LF_TEXT  text
*----------------------------------------------------------------------*
FORM sys_get_function_text USING pf_fcode
                           CHANGING pfx_text.

  DATA: lt_text  LIKE rseu0_fun OCCURS 0 WITH HEADER LINE,
        lf_repid LIKE sy-repid.
** ---------------------------------------------------------------------

  lf_repid = sy-repid.
  CLEAR pfx_text.

  CALL FUNCTION 'RS_CUA_GET_TEXTS'
       EXPORTING: language = sy-langu
                  name     = lf_repid
       TABLES:    texts    = lt_text
       EXCEPTIONS: cua_not_found     = 01
                   no_texts          = 02
                   program_not_found = 03.
  IF sy-subrc = 0.
    READ TABLE lt_text WITH KEY code = pf_fcode.
    IF sy-subrc = 0.
      pfx_text = lt_text-short.
    ENDIF.
  ENDIF.

ENDFORM.                    " sys_get_function_text
*&---------------------------------------------------------------------*
*&      Form  add_client_data_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_client_data_2.
* Adds special client data to plotjobs
  DATA: wa_kna1 LIKE kna1.
  DATA: mailadresse TYPE ad_smtpadr.
  DATA: n10(10) TYPE n.

  CLEAR wa_kna1.
  CLEAR mailadresse.


  DATA: rc TYPE TABLE OF bapiret2.
  DATA: wa_address TYPE bapiaddr3.
  DATA: wa_company TYPE bapiuscomp.

  DATA: itab_addtel TYPE TABLE OF bapiadtel.
  DATA: itab_addsmtp TYPE TABLE OF bapiadsmtp.

  CLEAR rc.
  CLEAR wa_address.
  CLEAR wa_company.
  CLEAR itab_addtel.
  CLEAR itab_addsmtp.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username             = sy-uname
   IMPORTING
*     LOGONDATA            =
*     DEFAULTS             =
     address              = wa_address
     company              = wa_company
*     SNC                  =
*     REF_USER             =
*     alias                = wa_alias
    TABLES
*     PARAMETER            =
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



*  IF user_data-knz_user_dummy = 'X'.
*    IF user_data-user_dummy_kunnr IS INITIAL.
*      MESSAGE i020(zcl_plint_message_01) WITH '' '' '' ''.
*      EXIT.
*    ELSE.
*      n10 = user_data-user_dummy_kunnr.
*      SELECT SINGLE * FROM kna1 INTO wa_kna1
*        WHERE kunnr = n10
*        .
*      IF sy-subrc NE 0.
*        MESSAGE i021(zcl_plint_message_01)
*          WITH user_data-user_dummy_kunnr '' '' ''.
*        EXIT.
*      ELSE.
*        SELECT SINGLE smtp_addr FROM adr6
*          INTO mailadresse
*          WHERE addrnumber = wa_kna1-adrnr.
*        IF sy-subrc NE 0.
*        ELSE.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ELSE.
*  ENDIF.

  LOOP AT itab_tmp_plotjobs INTO wa_plotjobs.
    wa_plotjobs-name1 = wa_address-firstname.
    wa_plotjobs-name2 = wa_address-lastname.
*    "wa_plotjobs-firma = wa_kna1-
*    "wa_plotjobs-abteilung = wa_kna1-
*    wa_plotjobs-stras = wa_kna1-stras.
*    wa_plotjobs-ort1 = wa_kna1-ort01.
*    wa_plotjobs-pstlz = wa_kna1-pstlz.
    CONCATENATE wa_address-tel1_numbr ' / ' wa_address-tel1_ext
      INTO wa_plotjobs-telf1.
*    wa_plotjobs-telf1 = .
*    wa_plotjobs-telfx = wa_kna1-telfx.
    wa_plotjobs-smtp_addr = wa_address-e_mail.
*
*
    wa_plotjobs-firma = wa_company-company.

    MODIFY itab_tmp_plotjobs FROM wa_plotjobs INDEX sy-tabix.

  ENDLOOP.


ENDFORM.                    " add_client_data_2
*&---------------------------------------------------------------------*
*&      Form  del_down_files_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_down_files_2.
  DATA: down_path TYPE string.
  DATA: clf_down_path TYPE string.

  clf_down_path = user_data-clf_down_path.
  down_path = user_data-down_path.


  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = '20'  " Balkenanzeige
            text       = text-040.


  CALL FUNCTION 'Z_CL_DEL_TMP_DIR_BY_NAMES'
       EXPORTING
            i_clf_down_path = clf_down_path
            i_down_path     = down_path
            i_test          = ''
       EXCEPTIONS
            error           = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " del_down_files_2
*&---------------------------------------------------------------------*
*&      Form  delete_sl_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_sl_items.
* alte Einträge aus der Tabelle ZCL_SL_TMP löschen.

  DELETE  FROM  zcl_sl_tmp
    WHERE uname = sy-uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


ENDFORM.                    " delete_sl_items
*&---------------------------------------------------------------------*
*&      Form  make_display_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_display_icon.
* updates the DISPLAY_ICON in the searchlist
  LOOP AT itab_search INTO wa_search.
    wa_search-icon_display = icon_doc_item_detail.

    wa_search-icon_display_dis = icon_doc_header_detail.

    MODIFY itab_search FROM wa_search INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " make_display_icon
*&---------------------------------------------------------------------*
*&      Form  view_originals_sl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_originals_sl_hot.
* Originale in der Suchliste per HOTSPOT ansehen

  CASE wa_akt_search-object_type.
    WHEN 'SPOOL'.
      "spoolbehandlung
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
           EXPORTING
                i_spoolid = wa_akt_search-tdspoolid
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
                i_url = wa_akt_search-url.

    WHEN OTHERS.
      SET PARAMETER ID 'CV1' FIELD wa_akt_search-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_akt_search-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_akt_search-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_akt_search-doktl.


* HOSTNAME holen
      DATA: hostname(20).
      CALL FUNCTION 'CV120_GET_HOSTNAME'
           EXPORTING
                pf_batch          = ' '
           IMPORTING
                pfx_host          = hostname
           EXCEPTIONS
                error             = 1
                no_valid_frontend = 2
                OTHERS            = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CALL FUNCTION 'CVAPI_DOC_VIEW'
        EXPORTING
          pf_dokar               = wa_akt_search-dokar
          pf_doknr               = wa_akt_search-doknr
          pf_dokvr               = wa_akt_search-dokvr
          pf_doktl               = wa_akt_search-doktl
          pf_hostname            = hostname
          pf_appl_start          = 'X'
*     PF_GET_URL             = ' '
          pf_apptp               = '1'
*     PF_ASK_FILENAME        = ' '
*     PF_FILENAME            = ' '
*     PS_FILE                =
*     PF_PARENT              =
*     PF_USE_DYNP            = ' '
*     PS_DRAP_AUDIT          =
*   IMPORTING
*     PFX_FILE               =
*     PFX_URL                =
*     PFX_VIEW_INPLACE       =
       EXCEPTIONS
          error                  = 1
          not_found              = 2
          no_auth                = 3
          no_original            = 4
          OTHERS                 = 5
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


  ENDCASE.


** Spoolbehandlung
*  IF wa_akt_search-object_type = 'SPOOL'.
*    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
*         EXPORTING
*              i_spoolid = wa_akt_search-tdspoolid
*         EXCEPTIONS
*              error     = 1
*              OTHERS    = 2.
*    IF sy-subrc <> 0.
*      EXIT.
*    ENDIF.
*    EXIT.
*  ELSE.
*  ENDIF.


*  SET PARAMETER ID 'CV1' FIELD wa_akt_search-doknr.
*  SET PARAMETER ID 'CV2' FIELD wa_akt_search-dokar.
*  SET PARAMETER ID 'CV3' FIELD wa_akt_search-dokvr.
*  SET PARAMETER ID 'CV4' FIELD wa_akt_search-doktl.
*
*
** HOSTNAME holen
*  DATA: hostname(20).
*  CALL FUNCTION 'CV120_GET_HOSTNAME'
*       EXPORTING
*            pf_batch          = ' '
*       IMPORTING
*            pfx_host          = hostname
*       EXCEPTIONS
*            error             = 1
*            no_valid_frontend = 2
*            OTHERS            = 3.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  CALL FUNCTION 'CVAPI_DOC_VIEW'
*    EXPORTING
*      pf_dokar               = wa_akt_search-dokar
*      pf_doknr               = wa_akt_search-doknr
*      pf_dokvr               = wa_akt_search-dokvr
*      pf_doktl               = wa_akt_search-doktl
*      pf_hostname            = hostname
*      pf_appl_start          = 'X'
**     PF_GET_URL             = ' '
*      pf_apptp               = '1'
**     PF_ASK_FILENAME        = ' '
**     PF_FILENAME            = ' '
**     PS_FILE                =
**     PF_PARENT              =
**     PF_USE_DYNP            = ' '
**     PS_DRAP_AUDIT          =
**   IMPORTING
**     PFX_FILE               =
**     PFX_URL                =
**     PFX_VIEW_INPLACE       =
*   EXCEPTIONS
*      error                  = 1
*      not_found              = 2
*      no_auth                = 3
*      no_original            = 4
*      OTHERS                 = 5
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*


ENDFORM.                    " view_originals_sl_hot
*&---------------------------------------------------------------------*
*&      Form  cv03n_view_sl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cv03n_view_sl_hot.
* DIS aus HOTSPOT ansehen

  CASE wa_akt_search-object_type.
    WHEN 'SPOOL'.
      "spoolbehandlung
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
           EXPORTING
                i_spoolid = wa_akt_search-tdspoolid
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
                i_url = wa_akt_search-url.

    WHEN OTHERS.
      SET PARAMETER ID 'CV1' FIELD wa_akt_search-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_akt_search-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_akt_search-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_akt_search-doktl.

      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

  ENDCASE.


** Spoolbehandlung
*  IF wa_akt_search-object_type = 'SPOOL'.
*    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
*         EXPORTING
*              i_spoolid = wa_akt_search-tdspoolid
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
*  SET PARAMETER ID 'CV1' FIELD wa_akt_search-doknr.
*  SET PARAMETER ID 'CV2' FIELD wa_akt_search-dokar.
*  SET PARAMETER ID 'CV3' FIELD wa_akt_search-dokvr.
*  SET PARAMETER ID 'CV4' FIELD wa_akt_search-doktl.
*
*  CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

ENDFORM.                    " cv03n_view_sl_hot
*&---------------------------------------------------------------------*
*&      Form  view_originals_pl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_originals_pl_hot.

  PERFORM read_akt_line_plotlist.
  PERFORM set_tree_sel_node.

  wa_plotjobs = wa_akt_plotjobs.


  " CKR 2008/09/18
  " Anpassung auf aktuellen Viewer in Customizing
  PERFORM view_document_pl_standard.
*
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
**     Dokument in der Plottingliste ansehen
**  PERFORM get_selected_line_plotjobs.
*  PERFORM get_set_view_program.
*  PERFORM check_kapro.
*
*  PERFORM stamp_before_view.
*
*  CASE wa_view_program-programm.
*    WHEN 'EAI 2D'.
*      PERFORM view_document_02.
*    WHEN 'EAI 3D'.
*      PERFORM view_document_03.
*    WHEN 'OFFICE'.
*      PERFORM view_document.
*  ENDCASE.
*  PERFORM delete_after_view.
*

ENDFORM.                    " view_originals_pl_hot
*&---------------------------------------------------------------------*
*&      Form  cv03n_view_pl_hot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cv03n_view_pl_hot.
  PERFORM read_akt_line_plotlist.
  PERFORM set_tree_sel_node.

  CASE wa_akt_plotjobs-object_type.
    WHEN 'SPOOL'.
      CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
           EXPORTING
                i_spoolid = wa_akt_plotjobs-tdspoolid
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
                i_url = wa_akt_plotjobs-url.
    WHEN OTHERS.
      SET PARAMETER ID 'CV1' FIELD wa_akt_plotjobs-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_akt_plotjobs-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_akt_plotjobs-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_akt_plotjobs-doktl.

      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

  ENDCASE.

** Spoolbehandlung
*  IF wa_akt_plotjobs-object_type = 'SPOOL'.
*    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
*         EXPORTING
*              i_spoolid = wa_akt_plotjobs-tdspoolid
*         EXCEPTIONS
*              error     = 1
*              OTHERS    = 2.
*    IF sy-subrc <> 0.
*      EXIT.
*    ENDIF.
*    EXIT.
*  ELSE.
*  ENDIF.

*  SET PARAMETER ID 'CV1' FIELD wa_akt_plotjobs-doknr.
*  SET PARAMETER ID 'CV2' FIELD wa_akt_plotjobs-dokar.
*  SET PARAMETER ID 'CV3' FIELD wa_akt_plotjobs-dokvr.
*  SET PARAMETER ID 'CV4' FIELD wa_akt_plotjobs-doktl.
*
*  CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.


ENDFORM.                    " cv03n_view_pl_hot
