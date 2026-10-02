*----------------------------------------------------------------------*
***INCLUDE /CIDEON/MNT_CIDEON_PL_LOG_FM02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  make_dunning
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_dunning.
  IF it_det IS INITIAL.
*  Alles selektieren zum Job
* Übergabe zur Smartformserstellung
    CALL FUNCTION '/CIDEON/MAKE_DUNNING'
         EXPORTING
              id_plotjob_32 = wa-id_plotjob_32
         EXCEPTIONS
              error         = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.



  ELSE.
*   Bereinigen, falls mehrere Einträge zu einem Ausgabeauftrag
*
    SORT it_det BY id_plotjob_32.
    DELETE ADJACENT DUPLICATES
      FROM it_det COMPARING id_plotjob_32.

    LOOP AT it_det INTO wa.
      CALL FUNCTION '/CIDEON/MAKE_DUNNING'
           EXPORTING
                id_plotjob_32 = wa-id_plotjob_32
           EXCEPTIONS
                error         = 1
                OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " make_dunning
*&---------------------------------------------------------------------*
*&      Form  show_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_info.
* Versionsinformationen anzeigen
  DATA: versionsinfo TYPE REF TO /cideon/cl_versionsinfo.
  DATA: version(20).

  version = text-v00.

  CREATE OBJECT versionsinfo.
  CALL METHOD versionsinfo->get_info_lvc
    EXPORTING
      objtype = 'REPS'
      objname = '/CIDEON/MNT_CIDEON_PL_LOG'
      version = version
      .
ENDFORM.                    " show_info
*&---------------------------------------------------------------------*
*&      Form  set_marked_job
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_marked_job.
* ganzen Job Markieren
  DATA: wa2 LIKE wa.

  READ TABLE it INTO wa
             INDEX index.
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  REFRESH it_selected_rows.
  CLEAR wa_selected_rows.

  LOOP AT it INTO wa2
    WHERE id_plotjob = wa-id_plotjob.
    wa_selected_rows-index = sy-tabix.
    APPEND wa_selected_rows TO it_selected_rows.
  ENDLOOP.


*  REFRESH it_selected_rows.
*  CLEAR wa_selected_rows.
*
*  wa_selected_rows-index = index.
*  APPEND wa_selected_rows TO it_selected_rows.
*

  CALL METHOD ref_alv->set_selected_rows
    EXPORTING
      it_index_rows = it_selected_rows
*      IT_ROW_NO     =
      .



ENDFORM.                    " set_marked_job
*&---------------------------------------------------------------------*
*&      Form  ask_for_whole_job
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ask_for_whole_job.
* Abfrage für gesamten Job

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*   TITLEBAR                    = ' '
*   DIAGNOSE_OBJECT             = ' '
      text_question               = text-045
     text_button_1               = 'Ja'(046)
*   ICON_BUTTON_1               = ' '
     text_button_2               = 'Nein'(047)
*   ICON_BUTTON_2               = ' '
*   DEFAULT_BUTTON              = '1'
      display_cancel_button       = ''
*   USERDEFINED_F1_HELP         = ' '
*   START_COLUMN                = 25
*   START_ROW                   = 6
*   POPUP_TYPE                  =
    IMPORTING
      answer                      = f_whole_job
* TABLES
*   PARAMETER                   =
* EXCEPTIONS
*   TEXT_NOT_FOUND              = 1
*   OTHERS                      = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " ask_for_whole_job
*&---------------------------------------------------------------------*
*&      Form  reprint_job
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reprint_job USING p_start_occ TYPE c.
* Job erneut ausgeben
  DATA: wa_objects LIKE LINE OF it_objects.

  IF it_det IS INITIAL.
    "wa benutzen
  ELSE.
    LOOP AT it_det INTO wa.
      MOVE-CORRESPONDING wa TO wa_objects.

      IF wa-dokar = 'SPZ'.
        wa_objects-object_type = 'SPOOL'.
      ELSE.
        wa_objects-object_type = 'DOCUMENT'.
      ENDIF.

      wa_objects-id_ref = wa-id.
      wa_objects-id_plotjob_ref = wa-id_plotjob.
      wa_objects-id_plotjob_32_re = wa-id_plotjob_32.

      APPEND wa_objects TO it_objects.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION '/CIDEON/_WRT_PSB_TMP_SD_CS'
    EXPORTING
      i_dateiname_ziel          = ' '
     i_knz_start_output        = p_start_occ
*     I_KNZ_MERGE               = 'X'
*     I_KNZ_MERGE_GROUP         = ''
*     I_KNZ_DYN_COV             = ''
*     I_BYPASS_SEARCHLIST       = ''
*     I_KNZ_USE_FILTER          = ''
*     I_BYPASS_PLOTLIST         = ''
*     I_USE_OPERATOR_MODE       = ''
*     I_BATCH                   = ''
    TABLES
      i_itab_objects            = it_objects
*     I_LT_DAPPL                =
   EXCEPTIONS
     error                     = 1
     OTHERS                    = 2
            .

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  "Programm verlassen und SPSO starten
  "CALL Stack lesen
*  DATA: lt_callstack TYPE sys_callst.
*  DATA: ls_callstack TYPE sys_calls.
*
*  CLEAR lt_callstack.
*  CLEAR ls_callstack.
*
*  CALL FUNCTION 'SYSTEM_CALLSTACK'
*       IMPORTING
*            et_callstack = lt_callstack.



ENDFORM.                    " reprint_job
