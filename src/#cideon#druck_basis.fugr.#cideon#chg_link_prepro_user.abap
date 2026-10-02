FUNCTION /cideon/chg_link_prepro_user.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(USER) TYPE  SY-UNAME OPTIONAL
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*           Christoph.Kuechler@cideon.com
*
* Anpassungen:
*-----------------------------------------------------------------------
* Änderung der Zuordnung zwischen Nutzer und Preprozessor
*-----------------------------------------------------------------------
* Journal
* 28.01.2010 - Erstellung
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------

  .
  INCLUDE /cideon/_konstanten.

  TABLES: zcl_preproz_user.

  DATA: ls_link TYPE zcl_preproz_user.

  IF user IS INITIAL.
    user = sy-uname.
  ELSE.
  ENDIF.

  CLEAR ls_link.
  SELECT SINGLE * FROM zcl_preproz_user INTO ls_link
    WHERE uname = user
    "AND status = c_status_aktiv
    .
  IF sy-subrc NE 0.
    "nichtsgefunden
    " mglw. Zuordnung über Rolle

  ELSE.

  ENDIF.


  "Anzeige der möglichen Prozessoren
  DATA: return_tab TYPE TABLE OF ddshretval.
  DATA: ls_return_tab TYPE ddshretval.

  CLEAR return_tab.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'ZCL_PREPROZ_USER'
      fieldname                 = 'PREPROZESSOR'
*     SEARCHHELP                = ' '
*     SHLPPARAM                 = ' '
*     DYNPPROG                  = ' '
*     DYNPNR                    = ' '
*     DYNPROFIELD               = ' '
*     STEPL                     = 0
*     VALUE                     = ' '
*     MULTIPLE_CHOICE           = ' '
*     DISPLAY                   = ' '
*     SUPPRESS_RECORDLIST       = ' '
*     CALLBACK_PROGRAM          = ' '
*     CALLBACK_FORM             = ' '
    TABLES
      return_tab                = return_tab
*   EXCEPTIONS
*     FIELD_NOT_FOUND           = 1
*     NO_HELP_FOR_FIELD         = 2
*     INCONSISTENT_HELP         = 3
*     NO_VALUES_FOUND           = 4
*     OTHERS                    = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE return_tab INTO ls_return_tab INDEX 1.
  IF sy-subrc NE 0.
    " kein Eintrag
    EXIT.
  ELSE.
    "Änderung der Einstellung.
    " alten Eintrag deaktivieren
    IF ls_link IS INITIAL.
      "noch kein Eintrag vorhanden
      " neuen Erstellen
      CLEAR ls_link.
      ls_link-uname = sy-uname.
      ls_link-preprozessor = ls_return_tab-fieldval.
      ls_link-status = c_status_aktiv.

      ls_link-zclinsname = sy-uname.
      ls_link-zclinsdate = sy-datum.
      ls_link-zclinstime = sy-uzeit.
      ls_link-zclinsprog = '/CIDEON/CHG_LINK_PREPRO_USER'.

      ls_link-zclupdname = sy-uname.
      ls_link-zclupddate = sy-datum.
      ls_link-zclupdtime = sy-uzeit.
      ls_link-zclupdprog = '/CIDEON/CHG_LINK_PREPRO_USER'.

      MODIFY zcl_preproz_user FROM ls_link.
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    ELSE.
      CLEAR ls_link-agr_name.
      ls_link-preprozessor = ls_return_tab-fieldval.
      ls_link-status = c_status_aktiv.


      ls_link-zclupdname = sy-uname.
      ls_link-zclupddate = sy-datum.
      ls_link-zclupdtime = sy-uzeit.
      ls_link-zclupdprog = '/CIDEON/CHG_LINK_PREPRO_USER'.

      MODIFY zcl_preproz_user FROM ls_link.
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.


    ENDIF.

  ENDIF.



  COMMIT WORK AND WAIT.

ENDFUNCTION.
