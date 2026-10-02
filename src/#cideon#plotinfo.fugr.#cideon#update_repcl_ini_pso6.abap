FUNCTION /cideon/update_repcl_ini_pso6.
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

*Tabelle zusammenbastellen
  CLEAR anzahl_verteiler.
  DESCRIBE TABLE itab_verteiler LINES anzahl_verteiler.

  CLEAR wa_repcl_ini_pr.
* Anzahl der Verteiler
  wa_repcl_ini_pr-preprozessor = i_preprocessor.
  wa_repcl_ini_pr-sektor =  '[Verteiler]'.
  wa_repcl_ini_pr-keyname = 'Zeilen'.
  wa_repcl_ini_pr-keywert = anzahl_verteiler.

  wa_repcl_ini_pr-zclinsname = sy-uname.
  wa_repcl_ini_pr-zclinsdate = sy-datum.
  wa_repcl_ini_pr-zclinstime = sy-uzeit.
  wa_repcl_ini_pr-zclinsprog = sy-repid.
  wa_repcl_ini_pr-zclupdname  = sy-uname.
  wa_repcl_ini_pr-zclupddate = sy-datum.
  wa_repcl_ini_pr-zclupdtime = sy-uzeit.
  wa_repcl_ini_pr-zclupdprog = sy-repid.

  MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
  IF sy-subrc NE 0.
    MESSAGE e000(/cideon/plot_admin)
      WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
      '' ''
      RAISING error.
  ELSE.
  ENDIF.

* Verteiler eintragen
  LOOP AT itab_verteiler INTO wa_verteiler.
    tmp_str = sy-tabix - 1.
    CONCATENATE 'Wert' tmp_str '/' '0' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    wa_repcl_ini_pr-keyname = tmp_keyname.
    wa_repcl_ini_pr-keywert = wa_verteiler.

    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
        '' ''
        RAISING error.
    ELSE.
    ENDIF.
  ENDLOOP.

* anderes Zeug eintragen, wegen Abwärtskompatibilität
* Beschreibung
  LOOP AT itab_verteiler INTO wa_verteiler.
    tmp_str = sy-tabix - 1.
    CONCATENATE 'Wert' tmp_str '/' '1' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    wa_repcl_ini_pr-keyname = tmp_keyname.
    CLEAR wa_repcl_ini_pr-keywert.

    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
        '' ''
        RAISING error.
    ELSE.
    ENDIF.
  ENDLOOP.

* Satzanzahl
  LOOP AT itab_verteiler INTO wa_verteiler.
    tmp_str = sy-tabix - 1.
    CONCATENATE 'Wert' tmp_str '/' '2' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    wa_repcl_ini_pr-keyname = tmp_keyname.
    CLEAR wa_repcl_ini_pr-keywert.

    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
        '' ''
        RAISING error.
    ELSE.
    ENDIF.
  ENDLOOP.

* Deckblatt
  LOOP AT itab_verteiler INTO wa_verteiler.
    tmp_str = sy-tabix - 1.
    CONCATENATE 'Wert' tmp_str '/' '3' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    wa_repcl_ini_pr-keyname = tmp_keyname.
    CLEAR wa_repcl_ini_pr-keywert.

    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
        '' ''
        RAISING error.
    ELSE.
    ENDIF.
  ENDLOOP.

* Endeblatt
  LOOP AT itab_verteiler INTO wa_verteiler.
    tmp_str = sy-tabix - 1.
    CONCATENATE 'Wert' tmp_str '/' '4' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    wa_repcl_ini_pr-keyname = tmp_keyname.
    CLEAR wa_repcl_ini_pr-keywert.

    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
        '' ''
        RAISING error.
    ELSE.
    ENDIF.
  ENDLOOP.

* Kennzeichen Inhaltsverzeichnis
  LOOP AT itab_verteiler INTO wa_verteiler.
    tmp_str = sy-tabix - 1.
    CONCATENATE 'Wert' tmp_str '/' '5' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    wa_repcl_ini_pr-keyname = tmp_keyname.
    CLEAR wa_repcl_ini_pr-keywert.

    MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
    IF sy-subrc NE 0.
      MESSAGE e000(/cideon/plot_admin)
        WITH 'zcl_repcl_ini_pr' '/CIDEON/UPDATE_REPCL_INI_PSO6'
        '' ''
        RAISING error.
    ELSE.
    ENDIF.
  ENDLOOP.



ENDFUNCTION.
