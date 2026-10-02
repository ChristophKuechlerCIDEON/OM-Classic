FUNCTION /cideon/clean_up_documents_2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"     VALUE(I_BATCH) TYPE  CHAR01 DEFAULT 'X'
*"  TABLES
*"      ITAB_SEARCH_TMP STRUCTURE  ZCL_S_DOCSEARCH
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
* Author :        C. Küchler  / CKR
*
* Änderungen:
*
* Kontakt über:   https://service.cideon.com
*                 HELPDESK@CIDEON-SOFTWARE.DE
*
*-----------------------------------------------------------------------
* Journal
* 09.07.2004 - Erstellung
* 26.01.2005 - Eingabe einer neuen Berechtigung
* 07.06.2007 - SP 40
*              Update Berechtigungsobjekte
* 13.06.2007 - SP 41
*              Umbau der Fehlermeldungen
*              eine Gesamtmeldung / Eintrag ins Appl. LOG
* 19.06.2007 - C_DRAW_STA aus /CIDEON/CLEAN_UP_DOCUMENTS_2
*              wieder ausbauen
* SP 125
* 7.0.125.1
* 27.05.2010 - CKR
*              J.K. / UGR / Metso
*              Berechtigungsprüfung für DIS ausschalten
*              FB /CIDEON/CLEAN_UP_DOCUMENTS_2
*              -> BADI
*              CHK_AUTH_C_DRAW_BGR    Check auf C_DRAW_BGR
*              CHK_AUTH_SPECIAL	Check auf Spezialberechtigungen
* SP 147
* 06.04.2011 - CKR
*              Anpassung auf Löschkennzeichen LOEDK
*
* 23.05.2011 - CKR
* 7.0.151.3    /CIDEON/CLEAN_UP_DOCUMENTS_2
*              Einbau einer BADI Implementierung, welche eine nutzer
*              definierte Berechtigungsprüfung zuläßt und einen
*              Austausch von Positionen
*              BADI /CIDEON/PRE_MAIN_001
*              Methode CHG_AT_AUTH_CHECK
*              Manz IP Konzept
*
* 7.0.168.2
* 2013/11/21 Madaus
* Kleiner Druckdialog - Prüfung auf Ausgabeberechtigung schlägt fehlt
* trotzdem erfolgt Ausgabe
* FB /CIDEON/CLEAN_UP_DOCUMENTS_2
*
*-----------------------------------------------------------------------

* DIS bereinigen
*ITAB
  DATA: itab_class_data_no_use TYPE TABLE OF zcl_v_ug_cl_n_u.
  DATA: it_fail TYPE TABLE OF zcl_s_docsearch.
*WA
  DATA: wa_draw_check TYPE draw.
  DATA: wa_search TYPE zcl_s_docsearch.
  DATA: wa_fail TYPE zcl_s_docsearch.
*NORMAL
  DATA: akt_index TYPE i.
  DATA: begru TYPE begru.
  DATA: f_silent.

  break kuechler_r1.

* BADI holen
  DATA: exit TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = exit.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF exit IS INITIAL.
  ELSE.
    DATA: lt_search_tmp TYPE /cideon/ttype_s_docsearch.
    CLEAR lt_search_tmp.
    lt_search_tmp[] =   itab_search_tmp[].
    CALL METHOD exit->chg_at_auth_check
      CHANGING
        itab_search_tmp = lt_search_tmp.
    itab_search_tmp[] =   lt_search_tmp[].
  ENDIF.



  f_silent = 'X'.
  CLEAR it_fail.

* Standard SAP Berechtigungen
  LOOP AT itab_search_tmp INTO wa_search.
    akt_index = sy-tabix.

*   Spezialdokumente durchlassen
    IF wa_search-knz_spez_dok = 'X'.
      CONTINUE.
    ELSE.
    ENDIF.

*   C_DRAW_TCD
    AUTHORITY-CHECK OBJECT 'C_DRAW_TCD'
             ID 'DOKAR' FIELD wa_search-dokar
             ID 'ACTVT' FIELD '03'.
    IF sy-subrc NE 0.
      "DELETE itab_search_tmp INDEX akt_index.
      wa_search-loedk = '#'.
      MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

      IF f_silent = 'X'.
        CLEAR wa_fail.
        MOVE-CORRESPONDING wa_search TO wa_fail.
        APPEND wa_fail TO it_fail.
        CONTINUE.
      ELSE.
        MESSAGE i006(/cideon/druck_basis)
          WITH wa_search-dokar wa_search-doknr
           wa_search-doktl wa_search-dokvr.
        CONTINUE.
      ENDIF.
    ELSE.
    ENDIF.

*   C_DRAW_TCS
    AUTHORITY-CHECK OBJECT 'C_DRAW_TCS'
             ID 'DOKAR' FIELD wa_search-dokar
             ID 'DOKST' FIELD wa_search-dokst
             ID 'ACTVT' FIELD '03'.

    IF sy-subrc NE 0.
      "DELETE itab_search_tmp INDEX akt_index.
      wa_search-loedk = '#'.
      MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

      IF f_silent = 'X'.
        CLEAR wa_fail.
        MOVE-CORRESPONDING wa_search TO wa_fail.
        APPEND wa_fail TO it_fail.
        CONTINUE.
      ELSE.
        MESSAGE i006(/cideon/druck_basis)
          WITH wa_search-dokar wa_search-doknr
           wa_search-doktl wa_search-dokvr.
        CONTINUE.
      ENDIF.
    ELSE.
    ENDIF.

*   C_DRAW_STA
* Die nachfolgende Tabelle zeigt das Berechtigungsobjekt C_DRAW_STA.
* Dieses Objekt steuert, für welche Dokumentart ein bestimmter Status
* gesetzt werden darf.

* zu harte Prüfung
* wird wieder ausgebaut ...


*    AUTHORITY-CHECK OBJECT 'C_DRAW_STA'
*             ID 'DOKAR' FIELD wa_search-dokar
*             ID 'DOKST' FIELD wa_search-dokst.
*
*    IF sy-subrc NE 0.
*      IF f_silent = 'X'.
*        DELETE itab_search_tmp INDEX akt_index.
*        CLEAR wa_fail.
*        MOVE-CORRESPONDING wa_search TO wa_fail.
*        APPEND wa_fail TO it_fail.
*        CONTINUE.
*      ELSE.
*        DELETE itab_search_tmp INDEX akt_index.
*        MESSAGE i006(/cideon/druck_basis)
*          WITH wa_search-dokar wa_search-doknr
*           wa_search-doktl wa_search-dokvr.
*        CONTINUE.
*      ENDIF.
*    ELSE.
*    ENDIF.

*   C_DRAW_BGR
* Die nachfolgende Tabelle zeigt das Berechtigungsobjekt C_DRAW_STA.
* Dieses Objekt steuert, für welche Dokumentart ein bestimmter Status
* gesetzt werden darf.

    "CKR 2010/05/27
* BADI
*    DATA: exit TYPE REF TO /cideon/if_ex_pre_main_001.
*    DATA: return TYPE bapiret2.
*
*    CALL METHOD cl_exithandler=>get_instance
*      CHANGING
*        instance = exit.
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.


    DATA: f_use_standard.
    DATA: f_success.

    CLEAR f_use_standard.
    f_use_standard = 'X'.
    CLEAR f_success.

    IF exit IS INITIAL.
    ELSE.
      CALL METHOD exit->chk_auth_c_draw_bgr
        CHANGING
          f_use_standard = f_use_standard
          f_success      = f_success
          ls_docsearch   = wa_search.

    ENDIF.

    IF f_use_standard = 'X'.
      CLEAR begru.
      SELECT SINGLE begru FROM draw INTO begru
        WHERE dokar = wa_search-dokar
         AND doknr = wa_search-doknr
         AND doktl = wa_search-doktl
         AND dokvr = wa_search-dokvr
         .
      IF sy-subrc NE 0.
      ELSE.
        IF begru IS INITIAL.
        ELSE.
          AUTHORITY-CHECK OBJECT 'C_DRAW_BGR'
             ID 'BEGRU' FIELD begru.

          IF sy-subrc NE 0.
            "DELETE itab_search_tmp INDEX akt_index.
            wa_search-loedk = '#'.
            MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

            IF f_silent = 'X'.
              CLEAR wa_fail.
              MOVE-CORRESPONDING wa_search TO wa_fail.
              APPEND wa_fail TO it_fail.
              CONTINUE.
            ELSE.
              MESSAGE i006(/cideon/druck_basis)
                WITH wa_search-dokar wa_search-doknr
                 wa_search-doktl wa_search-dokvr.
              CONTINUE.
            ENDIF.
          ELSE.
          ENDIF.

        ENDIF.
      ENDIF.
    ELSE.
      IF f_success = 'X'.
      ELSE.
        "DELETE itab_search_tmp INDEX akt_index.
        wa_search-loedk = '#'.
        MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

        IF f_silent = 'X'.
          CLEAR wa_fail.
          MOVE-CORRESPONDING wa_search TO wa_fail.
          APPEND wa_fail TO it_fail.
          CONTINUE.
        ELSE.
          MESSAGE i006(/cideon/druck_basis)
            WITH wa_search-dokar wa_search-doknr
             wa_search-doktl wa_search-dokvr.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    "Spezialberechtigungen
    IF exit IS INITIAL.
    ELSE.
      f_success = 'X'.
      CALL METHOD exit->chk_auth_special
        CHANGING
          f_success    = f_success
          ls_docsearch = wa_search.
      IF f_success = 'X'.
      ELSE.
        "DELETE itab_search_tmp INDEX akt_index.
        wa_search-loedk = '#'.
        MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

        IF f_silent = 'X'.
          CLEAR wa_fail.
          MOVE-CORRESPONDING wa_search TO wa_fail.
          APPEND wa_fail TO it_fail.
          CONTINUE.
        ELSE.
          MESSAGE i006(/cideon/druck_basis)
            WITH wa_search-dokar wa_search-doknr
             wa_search-doktl wa_search-dokvr.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.


*   C_DRAW_DOK
    AUTHORITY-CHECK OBJECT 'C_DRAW_DOK'
             ID 'DOKAR' FIELD wa_search-dokar
             ID 'ACTVT' FIELD '53'.
    IF sy-subrc NE 0.
      "DELETE itab_search_tmp INDEX akt_index.
      wa_search-loedk = '#'.
      MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

      IF f_silent = 'X'.
        CLEAR wa_fail.
        MOVE-CORRESPONDING wa_search TO wa_fail.
        APPEND wa_fail TO it_fail.
        CONTINUE.
      ELSE.
        MESSAGE i006(/cideon/druck_basis)
          WITH wa_search-dokar wa_search-doknr
           wa_search-doktl wa_search-dokvr.
        CONTINUE.
      ENDIF.
    ELSE.
    ENDIF.

*  C_DRAW_OBJ
*  wird zur Zeit nicht berücksichtigt

  ENDLOOP.

* Meldungen
  IF it_fail IS INITIAL.
  ELSE.

    LOOP AT it_fail INTO wa_fail.

      CLEAR text1.
      CLEAR text2.
      CLEAR text3.
      CLEAR text4.

      text1 = wa_fail-dokar.
      text2 = wa_fail-doknr.
      text3 = wa_fail-doktl.
      text4 = wa_fail-dokvr.

      CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
        EXPORTING
          i_object   = 'Z_CIDEON'
          i_subobj   = 'Z_PLOT'
          i_number   = 006
          i_msgtyp   = 'W'
          i_msgid    = '/cideon/druck_basis'
          i_msgno    = 004
          i_msgv1    = text1
          i_msgv2    = text2
          i_msgv3    = text3
          i_msgv4    = text4
          i_class    = ' '
          i_newhead  = 'X'
          i_messhead = 'X'
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      COMMIT WORK AND WAIT.

    ENDLOOP.
    MESSAGE w007(/cideon/druck_basis)
      WITH '' '' '' ''.
*   Einige Dokumente wurden nicht übernommen. Siehe Appl. LOG & & & &


  ENDIF.


* Test der DIS auf Berechtigung des Nutzers
  IF i_wa_user_data-knz_use_plot_right_1 = 'X'.
    LOOP AT itab_search_tmp INTO wa_search.
      akt_index = sy-tabix.
      AUTHORITY-CHECK OBJECT 'ZCL_PLOTAU'
*               ID 'ZCL_TA' FIELD sy-tcode
               ID 'ACTVT' FIELD '03'
               ID 'DOKAR' FIELD wa_search-dokar
               ID 'DOKST' FIELD wa_search-dokst
      .
      IF sy-subrc NE  0.
      ELSE.
        CONTINUE.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCL_PLOTAU'
*               ID 'ZCL_TA' FIELD sy-tcode
               ID 'ACTVT' FIELD '02'
               ID 'DOKAR' FIELD wa_search-dokar
               ID 'DOKST' FIELD wa_search-dokst
      .
      IF sy-subrc NE  0.
      ELSE.
        CONTINUE.
      ENDIF.

      "DELETE itab_search_tmp INDEX akt_index.
      wa_search-loedk = '#'.
      MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

      MESSAGE i006(/cideon/druck_basis)
        WITH wa_search-dokar wa_search-doknr
         wa_search-doktl wa_search-dokvr.

    ENDLOOP.
  ELSE.
  ENDIF.

* 7.0.168.2
* 2013/11/21 Madaus
  " Tabelle bereinigen
  DELETE itab_search_tmp WHERE loedk = '#'.



* Testen des DIS / Merkmale, welche nicht erlaubt
  IF i_wa_user_data-knz_check_dis = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF i_wa_user_data-knz_check_dis_class = 'X'.
  ELSE.
    EXIT.
  ENDIF.

* Merkmale für die nicht geplottet werden soll
  CLEAR itab_class_data_no_use.
  CALL FUNCTION '/CIDEON/GET_CLASS_NO_USE'
    EXPORTING
      i_nutzer                 = sy-uname
      i_default_nutzer         = i_wa_default_data-default_nutzer
    TABLES
      o_itab_class_data_no_use = itab_class_data_no_use
    EXCEPTIONS
      error                    = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF itab_class_data_no_use IS INITIAL.
*   halt nichts zu tun
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_search_tmp INTO wa_search.
    akt_index = sy-tabix.

    IF wa_search-knz_spez_dok = 'X' .
      CONTINUE.
    ELSE.
    ENDIF.

    CLEAR wa_draw_check.
    wa_draw_check-dokar = wa_search-dokar.
    wa_draw_check-doknr = wa_search-doknr.
    wa_draw_check-doktl = wa_search-doktl.
    wa_draw_check-dokvr = wa_search-dokvr.

    CALL FUNCTION '/CIDEON/CHECK_DIS_FOR_CLASS'
      EXPORTING
        i_wa_draw                = wa_draw_check
      TABLES
        i_itab_class_data_no_use = itab_class_data_no_use
      EXCEPTIONS
        error                    = 1
        do_not_use_dis           = 2
        OTHERS                   = 3.
    IF sy-subrc <> 0.
      IF sy-subrc = 2.
        ROLLBACK WORK.
        CLEAR text1.
        CLEAR text2.
        CLEAR text3.
        CLEAR text4.

        text1 = wa_draw_check-dokar.
        text2 = wa_draw_check-doknr.
        text3 = wa_draw_check-doktl.
        text4 = wa_draw_check-dokvr.

        CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
          EXPORTING
            i_object   = 'Z_CIDEON'
            i_subobj   = 'Z_PLOT'
            i_number   = 101
            i_msgtyp   = 'I'
            i_msgid    = '/cideon/druck_basis'
            i_msgno    = 004
            i_msgv1    = text1
            i_msgv2    = text2
            i_msgv3    = text3
            i_msgv4    = text4
            i_class    = ' '
            i_newhead  = 'X'
            i_messhead = 'X'
          EXCEPTIONS
            error      = 1
            OTHERS     = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        COMMIT WORK AND WAIT.

        IF i_batch = 'X'.
        ELSE.
          MESSAGE i004(/cideon/druck_basis)
            WITH wa_draw_check-dokar wa_draw_check-doknr
            wa_draw_check-doktl wa_draw_check-dokvr.
        ENDIF.
        "DELETE itab_search_tmp INDEX akt_index.
        wa_search-loedk = '#'.
        MODIFY itab_search_tmp FROM wa_search INDEX akt_index.

      ELSE.
      ENDIF.
    ENDIF.

  ENDLOOP.

  " Tabelle bereinigen
  DELETE itab_search_tmp WHERE loedk = '#'.

ENDFUNCTION.
