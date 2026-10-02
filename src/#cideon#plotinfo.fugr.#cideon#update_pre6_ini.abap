FUNCTION /cideon/update_pre6_ini.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PREPROCESSOR) TYPE  ZCL_NAME_PREPROZESSOR
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 17.11.2005 - Erstellung
* 18.11.2005 - Meldungen
* 02.12.2005 - COMMIT Problem / SAP DB
* 05.12.2005 - Memory ID
* 13.12.2005 - Änderungen in der Verarbeitung
* 13.02.2007 - kleine Änderungen
*              Maske der Eingabe
* 17.12.2008 - SP87
*              Einlesen der Beschreibung der Verteiler
*              Alte ReproCL.INI Unterstützung kommt raus ..
*
* SP 138
* 29.10.2010 - CKR
*              Umgehung der Temprärtabelle für REPRO_CL_INI
*
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_verteiler	TYPE TABLE OF /cideon/string.
  DATA: itab_description	TYPE TABLE OF /cideon/string.
*WA
*NORMAL
  DATA: url	TYPE	char255.
  DATA: url_spa(249).
  DATA: cfg	TYPE	char255.
  DATA: cfg_spa(249).
  DATA: user	TYPE	char255.
  DATA: user_spa(249).
  DATA: password	TYPE	char255.

*http://192.168.10.240:8080
*pre60-1
*default
*default

* Testeinträge
  url = 'http://192.168.10.240:8080'.
  cfg = 'pre60-1'.
  user = 'default'.
  password = 'default'.

* Testeinträge
  url = 'http://x.x.x.x:8080'.
  cfg = 'cfg'.
  user = 'user'.
  password = 'default'.
  CLEAR password.

  DATA: ls_rfcsi_export TYPE rfcsi.
  CLEAR ls_rfcsi_export.

  CALL FUNCTION 'RFC_SYSTEM_INFO'
    DESTINATION 'SAPGUI'
   IMPORTING
      rfcsi_export             = ls_rfcsi_export
*     RFC_LOGIN_COMPLETE       =
*     DIALOG_USER_TYPE         =
*     CURRENT_RESOURCES        =
*     MAXIMAL_RESOURCES        =
*     RECOMMENDED_DELAY        =
            .


  CONCATENATE 'http://' ls_rfcsi_export-rfcipaddr
    ':8080'
    INTO url.

* Memory IDs lesen
  GET PARAMETER ID 'CIDEON/PLI_URL' FIELD url.
  GET PARAMETER ID 'CIDEON/PLI_CFG' FIELD cfg.
  GET PARAMETER ID 'CIDEON/PLI_USER' FIELD user.

  IF url IS INITIAL.
    url = 'http://xxx.xxx.xxx.xxx:8080'.
  ELSE.
  ENDIF.
  IF cfg IS INITIAL.
    cfg = 'cfg'.
  ELSE.
  ENDIF.
  IF user IS INITIAL.
    user = 'user'.
  ELSE.
  ENDIF.


* Dialog aufrufen
  CALL FUNCTION '/CIDEON/CALL_PLI_DIALOG'
       EXPORTING
            i_url      = url
            i_cfg      = cfg
            i_user     = user
            i_password = password
       IMPORTING
            o_url      = url
            o_cfg      = cfg
            o_user     = user
            o_password = password
       EXCEPTIONS
            error      = 1
            abort      = 2
            OTHERS     = 3.
  IF sy-subrc <> 0.
*    EXIT.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

* Memory IDs setzen
  CLEAR url_spa.
  url_spa = url.
  CLEAR cfg_spa.
  cfg_spa = cfg.
  CLEAR user_spa.
  user_spa = user.
  SET PARAMETER ID 'CIDEON/PLI_URL' FIELD url_spa.
  SET PARAMETER ID 'CIDEON/PLI_CFG' FIELD cfg_spa.
  SET PARAMETER ID 'CIDEON/PLI_USER' FIELD user_spa.

* PlotInfo abfragen
  CLEAR itab_verteiler.
  CALL FUNCTION '/CIDEON/PLI_GET_DIST'
       EXPORTING
            i_url            = url
            i_cfg            = cfg
            i_user           = user
            i_password       = password
       TABLES
            itab_verteiler   = itab_verteiler
            itab_description = itab_description
       EXCEPTIONS
            error            = 1
            http_error       = 2
            OTHERS           = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      RAISING error.
  ENDIF.


* ZCL_REPCL_INI_PR update
*  CALL FUNCTION '/CIDEON/UPDATE_REPCL_INI_PSO6'
*       EXPORTING
*            i_preprocessor = i_preprocessor
*       TABLES
*            itab_verteiler = itab_verteiler
*       EXCEPTIONS
*            error          = 1
*            OTHERS         = 2.
*  IF sy-subrc <> 0.
*    CLEAR ok_code.
*    ROLLBACK WORK.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    CLEAR ok_code.
*  ELSE.
*    COMMIT WORK AND WAIT.
*  ENDIF.

* ZCL_PREPROCESSOR Update erst nach Standard

  "alte Werte lesen
  DATA: ls_preprozessor TYPE zcl_preprozessor.
  CLEAR ls_preprozessor.

  SELECT SINGLE * FROM zcl_preprozessor INTO ls_preprozessor
    WHERE preprozessor = i_preprocessor
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* alles mit PreProcessor löschen
  DELETE FROM zcl_repcl_ini_pr
    WHERE preprozessor = i_preprocessor
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  DELETE FROM zcl_preprozessor
    WHERE preprozessor = i_preprocessor
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  ls_preprozessor-zclinsname = sy-uname.
  ls_preprozessor-zclinsdate = sy-datum.
  ls_preprozessor-zclinstime = sy-uzeit.
  ls_preprozessor-zclinsprog = '/CIDEON/UPDATE_PSO_EMERGENCY'.
  ls_preprozessor-zclupdname  = sy-uname.
  ls_preprozessor-zclupddate = sy-datum.
  ls_preprozessor-zclupdtime = sy-uzeit.
  ls_preprozessor-zclupdprog = '/CIDEON/UPDATE_PSO_EMERGENCY'.

  DATA: index TYPE i.
  CLEAR index.

*  itab_verteiler
*  itab_description

  DATA: lc_verteiler TYPE /cideon/string.
  DATA: lc_description TYPE /cideon/string.

  LOOP AT itab_verteiler INTO lc_verteiler.
    ls_preprozessor-preprozessor = i_preprocessor.
    ls_preprozessor-verteiler = lc_verteiler.

    CLEAR lc_description.
    READ TABLE itab_description INTO lc_description INDEX index.

    ls_preprozessor-beschreibung = lc_description.

    MODIFY zcl_preprozessor FROM ls_preprozessor.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
          WITH 'zcl_preprozessor ' '/CIDEON/UPDATE_PSO_EMERGENCY'
          '' ''
          RAISING error.
    ELSE.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
