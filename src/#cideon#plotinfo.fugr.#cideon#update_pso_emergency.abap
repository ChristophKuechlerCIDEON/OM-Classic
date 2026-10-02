FUNCTION /cideon/update_pso_emergency.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PREPROCESSOR) TYPE  ZCL_NAME_PREPROZESSOR
*"  TABLES
*"      ITAB_VERTEILER STRUCTURE  /CIDEON/STRING
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
* 17.11.2005 Erstellung
* 13.02.2007 - Kopie
*
*  20.10.2010 - MBH
*               Pflege der Verteiler geändert
*
* 29.10.2010 - CKR
*              Verteiler werden direkt in ZCL_PREPROZESSOR
*              geschrieben
*
*-----------------------------------------------------------------------
*ITAB
*  DATA: itab_verteiler	TYPE TABLE OF /cideon/string.
*WA
  DATA: wa_repcl_ini_pr TYPE zcl_repcl_ini_pr.
  DATA: wa_verteiler TYPE /cideon/string.
*NORMAL
  DATA: anzahl_verteiler TYPE i.
  DATA: count TYPE i.
  DATA: tmp_str(10).
  DATA: tmp_keyname(30).
  DATA: answer.

  DATA: ls_outtab TYPE /cideon/s_verteiler.
* Ablauf
* Anzeige der Verteiler in einer BOX
* Update der Tabellen nach Bestätigung

  CLEAR answer.
  CALL FUNCTION '/CIDEON/GET_DISTRIB_WITH_EDIT'
       EXPORTING
            i_preprocessor = i_preprocessor
       IMPORTING
            o_answer       = answer
       TABLES
            it_verteiler   = itab_verteiler
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ELSE.

  ENDIF.

  IF answer = 'X'.
  ELSE.
    EXIT.
  ENDIF.

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
*   Es kann vorkommen, dass noch kein PreProcessor unter diesem
*   Namen angelegt ist
*    MESSAGE e000(/cideon/plot_admin)
*      WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*      '' ''
*      RAISING error.
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

  LOOP AT gt_outtab INTO ls_outtab.
    ls_preprozessor-preprozessor = i_preprocessor.
    ls_preprozessor-verteiler = ls_outtab-verteiler.
    ls_preprozessor-beschreibung = ls_outtab-beschreibung.

    MODIFY zcl_preprozessor FROM ls_preprozessor.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
          WITH 'zcl_preprozessor ' '/CIDEON/UPDATE_PSO_EMERGENCY'
          '' ''
          RAISING error.
    ELSE.
    ENDIF.

  ENDLOOP.


**Tabelle zusammenbastellen
*  CLEAR anzahl_verteiler.
*  DESCRIBE TABLE itab_verteiler LINES anzahl_verteiler.
*
*                                                            "2010/10/28
*  DESCRIBE TABLE gt_outtab LINES anzahl_verteiler.
*
*
*  CLEAR wa_repcl_ini_pr.
** Anzahl der Verteiler
*  wa_repcl_ini_pr-preprozessor = i_preprocessor.
*  wa_repcl_ini_pr-sektor =  '[Verteiler]'.
*  wa_repcl_ini_pr-keyname = 'Zeilen'.
*  wa_repcl_ini_pr-keywert = anzahl_verteiler.
*  CONDENSE wa_repcl_ini_pr-keywert.
*  "WRITE anzahl_verteiler TO wa_repcl_ini_pr-keywert.
*
*
*  wa_repcl_ini_pr-zclinsname = sy-uname.
*  wa_repcl_ini_pr-zclinsdate = sy-datum.
*  wa_repcl_ini_pr-zclinstime = sy-uzeit.
*  wa_repcl_ini_pr-zclinsprog = sy-repid.
*  wa_repcl_ini_pr-zclupdname  = sy-uname.
*  wa_repcl_ini_pr-zclupddate = sy-datum.
*  wa_repcl_ini_pr-zclupdtime = sy-uzeit.
*  wa_repcl_ini_pr-zclupdprog = sy-repid.
*
*  MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*  IF sy-subrc NE 0.
*    MESSAGE e000(/cideon/plot_admin)
*      WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*      '' ''
*      RAISING error.
*  ELSE.
*  ENDIF.

* Verteiler eintragen
*  LOOP AT itab_verteiler INTO wa_verteiler.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '0' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    wa_repcl_ini_pr-keywert = wa_verteiler.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.

*  LOOP AT gt_outtab INTO ls_outtab.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '0' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    wa_repcl_ini_pr-keywert = ls_outtab-verteiler.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.



* anderes Zeug eintragen, wegen Abwärtskompatibilität
* Beschreibung
*  LOOP AT itab_verteiler INTO wa_verteiler.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '1' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    CLEAR wa_repcl_ini_pr-keywert.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.

*  LOOP AT gt_outtab INTO ls_outtab.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '1' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    wa_repcl_ini_pr-keywert = ls_outtab-beschreibung.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.
*
*
** Satzanzahl
*  LOOP AT itab_verteiler INTO wa_verteiler.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '2' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    CLEAR wa_repcl_ini_pr-keywert.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.
*
** Deckblatt
*  LOOP AT itab_verteiler INTO wa_verteiler.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '3' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    CLEAR wa_repcl_ini_pr-keywert.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.
*
** Endeblatt
*  LOOP AT itab_verteiler INTO wa_verteiler.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '4' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    CLEAR wa_repcl_ini_pr-keywert.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.
*
** Kennzeichen Inhaltsverzeichnis
*  LOOP AT itab_verteiler INTO wa_verteiler.
*    tmp_str = sy-tabix - 1.
*    CONCATENATE 'Wert' tmp_str '/' '5' INTO tmp_keyname.
*    CONDENSE tmp_keyname NO-GAPS.
*
*    wa_repcl_ini_pr-keyname = tmp_keyname.
*    CLEAR wa_repcl_ini_pr-keywert.
*
*    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
*    IF sy-subrc NE 0.
*      MESSAGE e000(/cideon/plot_admin)
*        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
*        '' ''
*        RAISING error.
*    ELSE.
*    ENDIF.
*  ENDLOOP.



ENDFUNCTION.
