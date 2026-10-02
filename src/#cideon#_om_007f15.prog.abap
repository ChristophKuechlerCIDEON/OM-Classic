*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F15 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  read_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_selection.



ENDFORM.                    " read_selection
*&---------------------------------------------------------------------*
*&      Form  read_selection_search_gl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_selection_search_gl.
  CLEAR lt_sel_searchlist_gl.

  CALL METHOD grid_searchlist->get_selected_rows
    IMPORTING
      et_index_rows = lt_sel_searchlist_gl
*      ET_ROW_NO     =
      .

ENDFORM.                    " read_selection_search_gl
*&---------------------------------------------------------------------*
*&      Form  set_selection_search_gl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_selection_search_gl.
* Globale Selektion für Suchliste setzen

  IF lt_sel_searchlist_gl[] IS INITIAL.
  ELSE.
    CALL METHOD grid_searchlist->set_selected_rows
      EXPORTING
        it_index_rows = lt_sel_searchlist_gl[]
*        IT_ROW_NO     =
        .
  ENDIF.


ENDFORM.                    " set_selection_search_gl
*&---------------------------------------------------------------------*
*&      Form  export_cfolders
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM export_cfolders.
* Export von Dateien nach cFolders

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

  DATA: lt_plotjob TYPE TABLE OF zcl_s_plotlist.
  CLEAR lt_plotjob.

  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.

    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.
    APPEND wa_plotjobs TO lt_plotjob.
  ENDLOOP.


* BADI
* /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND
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
    CLEAR return.
    CALL METHOD badi_main_pre_001->cfolders_ausgabe_01
      CHANGING
        i_plotjob = lt_plotjob
        return    = return
        .

  ENDIF.



ENDFORM.                    " export_cfolders
*&---------------------------------------------------------------------*
*&      Form  cleanup_with_options
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cleanup_with_options.
* Suchliste mit gesetzen Optionen bereinigen
*      only_last_version,
*      last_free_version,
*      only_free_version,
*      only_good_material,
*      no_duplicates_sl,

  IF g_optionen-only_last_version = 'X'.
    PERFORM only_last_version.
  ELSE.
  ENDIF.

  IF g_optionen-last_free_version = 'X'.
    PERFORM last_free_version.
  ELSE.
  ENDIF.

  IF g_optionen-only_free_version = 'X'.
    "perform only_free_version.
    PERFORM only_released_version.
  ELSE.
  ENDIF.

  IF g_optionen-only_good_material = 'X'.
    PERFORM only_good_material.
  ELSE.
  ENDIF.

  IF g_optionen-no_duplicates_sl = 'X'.
    PERFORM delete_duplicates_sl.
  ELSE.
  ENDIF.

ENDFORM.                    " cleanup_with_options
*&---------------------------------------------------------------------*
*&      Form  view_document_pl_standard
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_document_pl_standard.
  "Anzeige eine Dokumentes über das Standard SAP Cust.
  "wa_plotjobs

  CASE wa_plotjobs-object_type.
    WHEN 'SPOOL'.
* Spoolbehandlung
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
* HOSTNAME holen
      DATA: hostname(20).
      CLEAR hostname.
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

      DATA: lt_files TYPE TABLE OF cvapi_doc_file.
      DATA: ls_files TYPE cvapi_doc_file.


      CLEAR lt_files.
      CLEAR ls_files.

      CALL FUNCTION 'CVAPI_DOC_GETDETAIL'
        EXPORTING
*   PF_BATCHMODE          = ' '
*   PF_HOSTNAME           = ' '
          pf_dokar              = wa_plotjobs-dokar
          pf_doknr              = wa_plotjobs-doknr
          pf_dokvr              = wa_plotjobs-dokvr
          pf_doktl              = wa_plotjobs-doktl
*   PF_READ_DRAD          = ' '
*   PF_READ_DRAP          = ' '
         pf_active_files       = 'X'
*   PF_READ_COMP          = ' '
         pf_read_kpro          = 'X'
         pf_read_drat          = 'X'
* IMPORTING
*   PSX_DRAW              =
*   PFX_DESCRIPTION       =
       TABLES
         pt_files              = lt_files
*   PT_COMP               =
*   PT_DRAP               =
*   PT_DRAD               =
*   PT_DRAT               =
       EXCEPTIONS
         not_found             = 1
         no_auth               = 2
         error                 = 3
         OTHERS                = 4
                .
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      READ TABLE lt_files INTO ls_files
        WITH KEY appnr = wa_plotjobs-originaltype.


      CALL FUNCTION 'CVAPI_DOC_VIEW'
        EXPORTING
          pf_dokar               = wa_plotjobs-dokar
          pf_doknr               = wa_plotjobs-doknr
          pf_dokvr               = wa_plotjobs-dokvr
          pf_doktl               = wa_plotjobs-doktl
          pf_hostname            = hostname
          pf_appl_start          = 'X'
*     PF_GET_URL             = ' '
          pf_apptp               = '1'
*     PF_ASK_FILENAME        = ' '
*     PF_FILENAME            = ' '
          ps_file                = ls_files
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

** HOSTNAME holen
*  DATA: hostname(20).
*  CLEAR hostname.
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
*  DATA: lt_files TYPE TABLE OF cvapi_doc_file.
*  DATA: ls_files TYPE cvapi_doc_file.
*
*
*  CLEAR lt_files.
*  CLEAR ls_files.
*
*  CALL FUNCTION 'CVAPI_DOC_GETDETAIL'
*    EXPORTING
**   PF_BATCHMODE          = ' '
**   PF_HOSTNAME           = ' '
*      pf_dokar              = wa_plotjobs-dokar
*      pf_doknr              = wa_plotjobs-doknr
*      pf_dokvr              = wa_plotjobs-dokvr
*      pf_doktl              = wa_plotjobs-doktl
**   PF_READ_DRAD          = ' '
**   PF_READ_DRAP          = ' '
*     pf_active_files       = 'X'
**   PF_READ_COMP          = ' '
*     pf_read_kpro          = 'X'
*     pf_read_drat          = 'X'
** IMPORTING
**   PSX_DRAW              =
**   PFX_DESCRIPTION       =
*   TABLES
*     pt_files              = lt_files
**   PT_COMP               =
**   PT_DRAP               =
**   PT_DRAD               =
**   PT_DRAT               =
*   EXCEPTIONS
*     not_found             = 1
*     no_auth               = 2
*     error                 = 3
*     OTHERS                = 4
*            .
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*  READ TABLE lt_files INTO ls_files
*    WITH KEY appnr = wa_plotjobs-originaltype.
*
*
*  CALL FUNCTION 'CVAPI_DOC_VIEW'
*    EXPORTING
*      pf_dokar               = wa_plotjobs-dokar
*      pf_doknr               = wa_plotjobs-doknr
*      pf_dokvr               = wa_plotjobs-dokvr
*      pf_doktl               = wa_plotjobs-doktl
*      pf_hostname            = hostname
*      pf_appl_start          = 'X'
**     PF_GET_URL             = ' '
*      pf_apptp               = '1'
**     PF_ASK_FILENAME        = ' '
**     PF_FILENAME            = ' '
*      ps_file                = ls_files
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
*


ENDFORM.                    " view_document_pl_standard
*&---------------------------------------------------------------------*
*&      Form  del_dublicates_pl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_dublicates_pl.
* doppelte Einträge in Plotliste löschen

  DATA: index_pl TYPE sy-tabix.
  DATA: max_lines TYPE i.
  DATA: p TYPE f.
  DATA: tmp_str(3).
  DATA: tmp_str2(3).
  DATA: i TYPE i.
  DATA: text(50).

  CLEAR wa_akt_plotjobs.
  LOOP AT itab_plotjobs INTO wa_plotjobs.
    index_pl = sy-tabix.
    DESCRIBE TABLE itab_plotjobs LINES max_lines.
    p =  100 * index_pl / max_lines.
    i = p.
    CLEAR tmp_str.
    tmp_str = index_pl.
    tmp_str2 = max_lines.
    "concatenate tmp_str ' / ' tmp_str2 ''  text-021 into text.
    CONCATENATE '' text-021 INTO text.
    p = index_pl MOD 100.
    IF p = 0.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = i
                text       = text.
    ELSE.
    ENDIF.
    LOOP AT itab_plotjobs INTO wa_akt_plotjobs
      WHERE dokar = wa_plotjobs-dokar
      AND doknr = wa_plotjobs-doknr
      AND dokvr = wa_plotjobs-dokvr
      AND doktl = wa_plotjobs-doktl
      AND originaltype = wa_plotjobs-originaltype
      .
      IF sy-tabix = index_pl.
      ELSE.
        DELETE itab_plotjobs INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  CLEAR wa_akt_plotjobs.




ENDFORM.                    " del_dublicates_pl
*&---------------------------------------------------------------------*
*&      Form  clear_pl_doubles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_pl_doubles.
* Dubblikate in Plotliste bereinigen

  IF user_data-knz_pl_no_double = 'X'.
    PERFORM del_dublicates_pl.
  ELSE.
  ENDIF.

ENDFORM.                    " clear_pl_doubles
