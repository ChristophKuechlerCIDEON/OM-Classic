*&---------------------------------------------------------------------*
*& Report  /CIDEON/SET_WORK_ENTRY_CSS_REP                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  /cideon/set_work_entry_css_rep.

AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD '/CIDEON/SET_WORK_ENT'.
IF sy-subrc NE 0.
  MESSAGE e172(00) WITH '/cideon/set_work_ent'.
*   Keine Berechtigung für Transaktion &
ELSE.
ENDIF.



CALL FUNCTION '/CIDEON/SET_WORK_ENTRY_CSS'
  EXCEPTIONS
    kein_eintrag = 1
    error        = 2
    gesperrt     = 3
    OTHERS       = 4.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
