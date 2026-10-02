FUNCTION /cideon/make_auth_check_ws.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BATCH) TYPE  CHAR01 DEFAULT ''
*"  EXPORTING
*"     VALUE(F_NO_AUTH) TYPE  CHAR01
*"  TABLES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  C. Küchler
*
* Anpassungen:
*           H. Hänsel
*           Dr. P. Rabe
*           M. Bartsch
*
* Kontakt:
*           helpdesk@cideon-software.com
*
*-----------------------------------------------------------------------
* Journal
* 19.07.2004 - Erstellung
* 27.08.2004 - Test auf Applikationsstart
*
* 30.11.2010 - CKR
* 7.0.141.2    Berechtigung für Spezialdokumente SPZ
*              ausschalten
*              /CIDEON/MAKE_AUTH_CHECK_WS
*
*-----------------------------------------------------------------------

* macht einen Check, ob der Nutzer überhaupt die Originaldatei ansehen
* darf! kein Ansehen -> kein Drucken
  DATA: wa_plotjobs_auth LIKE zcl_s_plotlist.

  CLEAR f_no_auth.

  LOOP AT itab_plotjobs INTO wa_plotjobs_auth.

    IF wa_plotjobs_auth-knz_spez_dok = 'X'.
      "
      CONTINUE.
    ELSE.
    ENDIF.

*   Berechtigungscheck
*   Aktivitäten zu Dokumenten
    AUTHORITY-CHECK OBJECT 'C_DRAW_DOK'
             ID 'DOKAR' FIELD wa_plotjobs_auth-dokar
             ID 'ACTVT' FIELD '53'
    .
    IF sy-subrc > 0.
      IF i_batch = 'X'.
        PERFORM appl_log_write USING
          'I' '099' 'ZCL_PLINT_TOOLS'
           'C_DRAW_DOK' '53' wa_plotjobs_auth-dokar ''.
      ELSE.
        MESSAGE e099(zcl_plint_tools)
          WITH 'C_DRAW_DOK' '53' wa_plotjobs_auth-dokar ''.
        "Sie haben keine Berechtigung ..
      ENDIF.
      f_no_auth = 'X'.
      EXIT.
    ELSE.
    ENDIF.

*   Statusabhängige Berechtigung
*   Bearbeiten
    AUTHORITY-CHECK OBJECT 'C_DRAW_TCS'
             ID 'DOKAR' FIELD wa_plotjobs_auth-dokar
             ID 'DOKST' FIELD wa_plotjobs_auth-dokst
             ID 'ACTVT' FIELD '03'
    .
    IF sy-subrc > 0.
      IF i_batch = 'X'.
        PERFORM appl_log_write USING
          'I' '099' 'ZCL_PLINT_TOOLS'
           'C_DRAW_TCS' '03'
          wa_plotjobs_auth-dokar wa_plotjobs_auth-dokst.
      ELSE.
        MESSAGE e099(zcl_plint_tools)
          WITH 'C_DRAW_TCS' '03'
          wa_plotjobs_auth-dokar wa_plotjobs_auth-dokst.
        "Sie haben keine Berechtigung ..
      ENDIF.
      f_no_auth = 'X'.
      EXIT.
    ELSE.
    ENDIF.

*   Bearbeiten
    AUTHORITY-CHECK OBJECT 'C_DRAW_TCS'
             ID 'DOKAR' FIELD wa_plotjobs_auth-dokar
             ID 'DOKST' FIELD wa_plotjobs_auth-dokst
             ID 'ACTVT' FIELD '53'
    .
    IF sy-subrc > 0.
      IF i_batch = 'X'.
        PERFORM appl_log_write USING
          'I' '099' 'ZCL_PLINT_TOOLS'
           'C_DRAW_TCS' '53'
          wa_plotjobs_auth-dokar wa_plotjobs_auth-dokst.
      ELSE.
        MESSAGE e099(zcl_plint_tools)
          WITH 'C_DRAW_TCS' '53'
          wa_plotjobs_auth-dokar wa_plotjobs_auth-dokst.
        "Sie haben keine Berechtigung ..
      ENDIF.
      f_no_auth = 'X'.
      EXIT.
    ELSE.
    ENDIF.

  ENDLOOP.


ENDFUNCTION.
