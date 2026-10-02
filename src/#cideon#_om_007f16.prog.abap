*----------------------------------------------------------------------*
***INCLUDE /CIDEON/_OM_007F16 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  start_konverting_CE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_konverting_ce.
* Start der Konvertierung für einen ausgewählten DIS
* je nachdem, was für eine Konvertierung für diesen Status verfügbar
* ist.* ...

* NORMAL
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.
  DATA: ausgabe_progress TYPE char100.


* neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTVB'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

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

  CLEAR ausgabe_progress.

  "Test, ob Funktionsbaustein aktiv vorhanden ist
  DATA: lc_name_fb TYPE rs38l_fnam.

  CLEAR lc_name_fb.
  lc_name_fb = '/PLMA/MAKE_AP_AT_STATUS'.

  SELECT SINGLE * FROM tfdir
  WHERE funcname = lc_name_fb
  .
  IF sy-subrc NE 0.
    MESSAGE e030(/cideon/plot_basis) WITH lc_name_fb '' '' ''.
  ELSE.
  ENDIF.
*     " active
  SELECT SINGLE * FROM rsinfdir
    WHERE funcname = lc_name_fb
    .
  IF sy-subrc NE 0.
  ELSE.
    MESSAGE e030(/cideon/plot_basis) WITH lc_name_fb '' '' ''.
  ENDIF.



  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.

    "Umbau auf CIDEON CE

    CALL FUNCTION lc_name_fb
    " '/PLMA/MAKE_AP_AT_STATUS'
      EXPORTING
        dokar                 = wa_plotjobs-dokar
        doknr                 = wa_plotjobs-doknr
        doktl                 = wa_plotjobs-doktl
        dokvr                 = wa_plotjobs-dokvr
        dokst                 = wa_plotjobs-dokst
*         IT_DMS_REC_FILE       =
*       TABLES
*         KONVERTIERUNGEN       =
*       EXCEPTIONS
*         ERROR                 = 1
*         NO_CONV_RULE          = 2
*         OTHERS                = 3
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.



*    SUBMIT conv_convert_document
*      WITH dokar EQ wa_plotjobs-dokar
*      WITH doknr EQ wa_plotjobs-doknr
*      WITH doktl EQ wa_plotjobs-doktl
*      WITH dokvr EQ wa_plotjobs-dokvr
*      WITH dokst EQ wa_plotjobs-dokst
*      AND RETURN
*      .

*    SET PARAMETER ID 'CV1' FIELD wa_plotjobs-doknr.
*    SET PARAMETER ID 'CV2' FIELD wa_plotjobs-dokar.
*    SET PARAMETER ID 'CV4' FIELD wa_plotjobs-doktl.
*    SET PARAMETER ID 'CV3' FIELD wa_plotjobs-dokvr.
*    CALL TRANSACTION 'ZCONV02'.

    IF akt_dec <> last_dec.
      prozent = akt_dec * 100.
      CLEAR  ausgabe_progress.
      CONCATENATE text-155 wa_plotjobs-dokar '/' wa_plotjobs-doknr
        '/' wa_plotjobs-doktl '/' wa_plotjobs-dokvr '/'
        wa_plotjobs-dokst
        INTO ausgabe_progress.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = prozent
                text       = ausgabe_progress.
    ELSE.
    ENDIF.
    last = akt.
    last_dec = akt_dec.


  ENDLOOP.





ENDFORM.                    " start_konverting_CE
*&---------------------------------------------------------------------*
*&      Form  start_konverting_CE_MAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_konverting_ce_man.
* Start der Konvertierung für einen ausgewählten DIS
* Manuelle Konvertierung

* NORMAL
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.
  DATA: ausgabe_progress TYPE char100.


* neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTVB'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

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

  CLEAR ausgabe_progress.

  "Test, ob Funktionsbaustein aktiv vorhanden ist
  DATA: lc_name_fb TYPE rs38l_fnam.

  CLEAR lc_name_fb.
  lc_name_fb = '/PLMA/MAKE_AP_AT_CDESK_MANUELL'.

  SELECT SINGLE * FROM tfdir
  WHERE funcname = lc_name_fb
  .
  IF sy-subrc NE 0.
    MESSAGE e030(/cideon/plot_basis) WITH lc_name_fb '' '' ''.
  ELSE.
  ENDIF.
*     " active
  SELECT SINGLE * FROM rsinfdir
    WHERE funcname = lc_name_fb
    .
  IF sy-subrc NE 0.
  ELSE.
    MESSAGE e030(/cideon/plot_basis) WITH lc_name_fb '' '' ''.
  ENDIF.


  DATA: lt_documents TYPE plm_document_tab.
  DATA: lt_documents_add TYPE plm_document_tab.

  DATA: lc_document TYPE plm_document.

  REFRESH lt_documents.
  REFRESH lt_documents_add.




  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.

    "Umbau auf CIDEON CE
    CLEAR lc_document.

    lc_document-documenttype = wa_plotjobs-dokar.
    lc_document-documentnumber = wa_plotjobs-doknr.
    lc_document-documentpart = wa_plotjobs-doktl.
    lc_document-documentversion = wa_plotjobs-dokvr.

    APPEND lc_document TO lt_documents.


    IF akt_dec <> last_dec.
      prozent = akt_dec * 100.
      CLEAR  ausgabe_progress.
      CONCATENATE text-155 wa_plotjobs-dokar '/' wa_plotjobs-doknr
        '/' wa_plotjobs-doktl '/' wa_plotjobs-dokvr '/'
        wa_plotjobs-dokst
        INTO ausgabe_progress.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = prozent
                text       = ausgabe_progress.
    ELSE.
    ENDIF.
    last = akt.
    last_dec = akt_dec.


  ENDLOOP.

  CALL FUNCTION lc_name_fb
    "'/PLMA/MAKE_AP_AT_CDESK_MANUELL'
* EXPORTING
*   PARAM1              =
*   PARAM2              =
*   PARAM3              =
*   PARAM4              =
    TABLES
      documents           = lt_documents
      documents_add       = lt_documents
            .



ENDFORM.                    " start_konverting_CE_MAN
*&---------------------------------------------------------------------*
*&      Form  only_valid_version
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM only_valid_version.
  " nur aktuell gültige und freigegebene Versionen zulassen
  DATA: index TYPE i.

  LOOP AT itab_search INTO wa_search.
    index = sy-tabix.

    IF wa_search-knz_spez_dok = 'X'.
      CONTINUE.
    ELSE.
    ENDIF.

    index = sy-tabix.

    "check auf Datum
    DATA: lc_act_version TYPE draw-dokvr.
    DATA: ls_return TYPE bapiret2.

    CLEAR lc_act_version.
    CLEAR ls_return.

    CALL FUNCTION 'BAPI_DOCUMENT_GETACTVERSION'
         EXPORTING
              documenttype    = wa_search-dokar
              documentnumber  = wa_search-doknr
              documentpart    = wa_search-doktl
              documentversion = wa_search-dokvr
              date            = sy-datum
              releaseonly     = 'X'
         IMPORTING
              return          = ls_return
              actualversion   = lc_act_version.
    IF ls_return-type CA 'EA'.
      "Fehler
      DELETE itab_search INDEX index.
      CONTINUE.
    ELSE.
    ENDIF.

    IF lc_act_version = wa_search-dokvr.
    ELSE.
      "nicht gültig
      DELETE itab_search INDEX index.
      CONTINUE.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " only_valid_version
*&---------------------------------------------------------------------*
*&      Form  set_ao_merge_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_ao_merge_2.
*Setzen des Parameters AO_MERGE -> Zurücknehmen

* AO$_MERGE: 0 = kein
*            1 = 1. Wert
*            2 = letzter Wert
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

** neues Rollenkonzept eingeschaltet?
*  IF user_data-knz_use_new_roles = 'X'.
**   Berechtigung testen
**   Ändern des Feldes
*    AUTHORITY-CHECK OBJECT 'ZCL_PLOTDN'
*             ID 'ZCL_TA' FIELD sy-tcode
*             ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*    .
*    IF sy-subrc NE 0.
**     keine Berechtigung
*      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
**     Sie haben keine Berechtigung für diese Funktion! & & & &
*      EXIT.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.

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


  LOOP AT itab_et_index_rows_plotlist
    INTO wa_et_index_rows_plotlist.
    READ TABLE itab_plotjobs INTO wa_plotjobs
      INDEX wa_et_index_rows_plotlist-index.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

*   Setzen des AO_MERGE
* AO$_MERGE: 0 = kein
*            1 = 1. Wert
*            2 = letzter Wert
    wa_plotjobs-ao_merge = '0'.
    MODIFY itab_plotjobs FROM wa_plotjobs INDEX
      wa_et_index_rows_plotlist-index.


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


ENDFORM.                    " set_ao_merge_2
*&---------------------------------------------------------------------*
*&      Form  view_info_journal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_info_journal.

* Journal der Änderungen anzeigen
  CALL FUNCTION 'RS_TOOL_ACCESS'
    EXPORTING
      operation                 = 'SHOW'
      object_name               = '/CIDEON/_OM_007'
      object_type               = 'REPS'
*     ENCLOSING_OBJECT          =
*     POSITION                  = ' '
*     DEVCLASS                  =
*     INCLUDE                   =
*     VERSION                   = ' '
*     MONITOR_ACTIVATION        = 'X'
*     WB_MANAGER                =
*     IN_NEW_WINDOW             =
*     WITH_OBJECTLIST           = ' '
*   IMPORTING
*     NEW_NAME                  =
*     WB_TODO_REQUEST           =
*   TABLES
*     OBJLIST                   =
*   CHANGING
*     P_REQUEST                 = ' '
*   EXCEPTIONS
*     NOT_EXECUTED              = 1
*     INVALID_OBJECT_TYPE       = 2
*     OTHERS                    = 3
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " view_info_journal
*&---------------------------------------------------------------------*
*&      Form  maintain_verteiler_multipage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_verteiler_multipage.

  CALL TRANSACTION '/CIDEON/MAINT_VRT_MP'.

ENDFORM.                    " maintain_verteiler_multipage
*&---------------------------------------------------------------------*
*&      Form  change_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_set.
* Ändere Satzanzahl
  DATA: lc_answer.

  CALL FUNCTION 'POPUP_TO_GET_VALUE'
       EXPORTING
            fieldname           = 'DEFAULT_SATZANZAHL'
            tabname             = '/CIDEON/PLOT_USERDATA'
            titel               = text-120
            valuein             = count_satz_c
       IMPORTING
            answer              = lc_answer
            valueout            = count_satz_c
       EXCEPTIONS
            fieldname_not_found = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " change_set
*&---------------------------------------------------------------------*
*&      Form  invert_plotlist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM invert_plotlist.

  SORT itab_plotjobs BY cont DESCENDING.

ENDFORM.                    " invert_plotlist
