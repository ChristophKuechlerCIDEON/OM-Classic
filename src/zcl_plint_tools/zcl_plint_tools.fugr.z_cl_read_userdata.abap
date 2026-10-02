FUNCTION z_cl_read_userdata.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"     VALUE(I_UNAME) TYPE  XUBNAME OPTIONAL
*"     VALUE(I_BATCH) TYPE  CHAR01 DEFAULT ''
*"  EXPORTING
*"     VALUE(O_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 08.09.2003 - Erstellung
* 30.09.2003 - FAUF
* 15.10.2003 - Anmeldung am SMB Share
* 24.10.2003 - Kennzeichen für Check am DIS
* 05.11.2003 - USE_FILTER
* 12.11.2003 - FTP
* 01.12.2003 - KNZ_USE_NEW_ROLES
* 05.12.2003 - KNZ_USE_ADMIN_MODULE
*              KNZ_MAKE_ID_PLOTJOB
* 06.12.2003 - PREPROCESSOR
* 09.12.2003 - ADMIN_ALV_VAR
* 11.12.2003 - TRANS_CV01N
* 15.12.2003 - TRANS_CV01N_SKIP_FIRST_SCREEN
* 01.07.2004 - KNZ_AUTO_CS
*              DEFAULT_VERTEILER_CS
* 20.07.2004 - Änderungen um FB BATCH-fähig zu machen
*              UNAME
*              DEFAULT_VERTEILER_DOK_VERTEIL
* 06.08.2004 - Zuordnung des PreProcessors über Rolle
* 25.08.2004 - Lesen der Pfade auf Rolle angepaßt
* 12.10.2004 - Integration von Rollen für die Zuordnung
*              Umstellung der FTP Zuordnung über Rolle
* 01.11.2004 - KNZ_VIEW_STRUC_PLOTLIST
*              KNZ_VIEW_DRAW_DETAIL
* 15.12.2004 - FIXED Lesen des PreProcessor im BATCH
* 26.01.2005 - KNZ_USE_PLOT_RIGHT_1
* 29.01.2005 - KNZ_AUDIT_TRAIL
* 14.04.2005 - DEFAULT_VERTEILER_DOK
*              KNZ_AUTO_DOK
* 26.04.2005 - 2D_DERIVATION_LIST
* 10.05.2005 - KNZ_CHECK_EBELN
*              CHECK_EBELN_STRATEGY
* 13.05.2005 - SMARTFORM_CS02	
*              SMARTFORM_CS11	
*              SMARTFORM_CS12	
*              SMARTFORM_CS13	
*              MAT_CAPID	
*              MAT_STPST	
*              MAT_DOKAR_PRIO_LIST
* 19.05.2005 - MAT_TDDEST	
*              MAT_TDPRINTER	
* 16.06.2005 - KNZ_USE_STAMP_BEFORE_VIEW
*              STAMP_PROGRAM
*              STAMP_PARAMETER
*              KNZ_USE_STAMP_CALL_RFC
*              STAMP_RFC_DESTINATION
*              STAMP_FTP_DESTINATION
*              STAMP_FTP_USER
*              STAMP_FTP_PASSWD
*              STAMP_FTP_VERZEICHNIS
*              STAMP_DELAY
* 17.06.2005 - KNZ_PLOT_LOG (SET/GET Z_KNZ_PLOT_LOG)
* 20.06.2005 - BOM_DATUV
*              KNZ_USE_VERT_RIGHTS
* 12.08.2005 - KNZ_CLF_COMMIT	
*              CLF_WAIT_TIME	
* 28.09.2005 - KNZ_COPY_ORIGINAL
* 25.01.2006 - KNZ_SINGLE_ENTRY
* 16.08.2006 - KNZ_CREATE_TOC
*              KNZ_SEND_TOC
* 23.02.2007 - KNZ_EBELN_EXPRESSMAIL
*              KNZ_EBELN_POS
*              KNZ_EBELN_MAT
*              KNZ_EBELN_BOM
*              KNZ_EBELN_DIALOG
* 27.04.2007 - SP 36
*            - DEFAULT_VERTEILER_EBELN
*            - DEFAULT_VERTEILER_VBELN
*            - KNZ_VBELN_EXPRESSMAIL
*            - KNZ_VBELN_POS
*            - KNZ_VBELN_MAT
*            - KNZ_VBELN_BOM
*            - KNZ_VBELN_DIALOG
* 23.07.2007 - SEPARATOR_DIS
*              MDR_FLAG_NAME	
*              MDR_FLAG_VAL	
*              TR_FLAG_NAME	
*              TR_FLAG_VAL	
*              SMARTFORM_MDR	
*              SMARTFORM_TR	
* 31.07.2007 - TOC_DIS
* 06.08.2007 - SP45
*              SRC_FLAG_NAME	
*              SRC_FLAG_VAL	
*              SRC_FLAG_NAME_2	
*              SRC_FLAG_VAL_2	
* 07.08.2007 - DEFAULT_VERTEILER_MDR
*              EASYDMS_FOLDER_TYPE
* 08.08.2007   STORAGE_CAT_TR
*              STORAGE_DIS_TR
* 10.08.2007 - SP 46
*              SMARTFORM_MATLIST
*              SMARTFORM_DOCLIST
* 13.08.2007 - MDR_DIS
* 15.08.2007 - NOTE_DIS
*              NOTE_DIR_STORAGE
* 22.08.2007 - VFTEMPLATE
* 02.09.2007 - VFTEMPLATE_TOC
* 18.09.2007 - KNZ_WSA_TO_PLOTLIST
*              PRIO_WSA_TO_PLOTLIST
*              KNZ_WSA_TO_PLOTLIST_CHECK_FILE
* 21.01.2008 - SP 62
*              KNZ_ME_SEP
*              KNZ_SD_SEP
* 18.09.2008 - SP 76
*              7.0.02
*              KNZ_PL_NO_DOUBLE
*
* 07.10.2008 - SP 81
*              KNZ_LINKS
*              KNZ_WHERE_USED
*              KNZ_DELETE_DUPLICATES
*
*
* 29.01.2009 - SP 88
*              Umbau auf /CIDEON/
*-----------------------------------------------------------------------

  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = i_default_data
            i_uname        = i_uname
            i_batch        = i_batch
       IMPORTING
            o_user_data    = o_user_data.
  EXIT.



* ITAB
  DATA: itab_prioritaeten TYPE TABLE OF zcl_prioritaeten.
  DATA: itab_mat_status_exc TYPE TABLE OF mstae.
  DATA: itab_return TYPE TABLE OF bapiret2.
  DATA: itab_roles TYPE TABLE OF bapiagr.
* WA
  DATA: wa_usr_host_cfg LIKE zcl_usr_host_cfg.
  DATA: wa_prioritaeten TYPE zcl_prioritaeten.
  DATA: wa_return TYPE bapiret2.
  DATA: wa_roles TYPE bapiagr.
* NORMAL
  DATA: user_data TYPE /cideon/plot_userdata.
  DATA: default_data TYPE /cideon/plot_defaultdata.

  DATA: uname LIKE sy-uname.

* get same user values from configuration tables
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).

  DATA: f_role_used VALUE 'X'.
  DATA: index TYPE i.


  CLEAR user_data.

  CLEAR default_data.
  default_data = i_default_data.

* Umstellung
  CLEAR uname.

* mglw. noch testen, ob übergebener Nutzer vorhaben ist

  IF i_batch = 'X'.
*   Batchverarbeitung
    IF i_uname IS INITIAL.
      uname = sy-uname.
    ELSE.
      uname = i_uname.
    ENDIF.
  ELSE.
*   normale Dialogverarbeitung
    IF i_uname IS INITIAL.
      uname = sy-uname.
    ELSE.
      uname = i_uname.
    ENDIF.
  ENDIF.

  user_data-uname = uname.

* Lesen der Rollen des Nutzers
  CLEAR itab_roles.
  CLEAR itab_return.
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username             = uname
*   IMPORTING
    TABLES
*     PARAMETER            =
*     PROFILES             =
      activitygroups       = itab_roles
      return               = itab_return
            .
  IF itab_return[] IS INITIAL.
  ELSE.
*   Fehler
    CLEAR itab_roles.
  ENDIF.

* Testen, ob Rollen des Nutzers in der Konfiguration benutzt
* werden, oder nicht
  IF itab_roles[] IS INITIAL.
    CLEAR f_role_used.
  ELSE.
*   Alles aussortieren, was abgelaufen ist.
    LOOP AT itab_roles INTO wa_roles.
      index = sy-tabix.
      IF wa_roles-from_dat <= sy-datum
        AND wa_roles-to_dat >= sy-datum.
      ELSE.
        DELETE itab_roles INDEX index.
      ENDIF.
    ENDLOOP.
*   Alles aussortieren, was nicht benutzt wird
    LOOP AT itab_roles INTO wa_roles.
      index = sy-tabix.
      SELECT SINGLE pwert FROM zcl_plint_config
        INTO tmp_str
        WHERE rolle = wa_roles-agr_name
        .
      IF sy-subrc NE 0.
*       Rolle wird nicht benutzt
        DELETE itab_roles INDEX index.
      ELSE.
      ENDIF.
    ENDLOOP.

    IF itab_roles[] IS INITIAL.
      CLEAR f_role_used.
    ELSE.
    ENDIF.
  ENDIF.



*KNZ_USE_POST
  CLEAR tmp_str.
  pname = 'KNZ_USE_POST'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_post = default_data-knz_use_post.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_post = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_post = tmp_str.
  ENDIF.

*SEARCH_ALV_VAR
  CLEAR tmp_str.
  pname = 'SEARCH_ALV_VAR'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-search_alv_var = default_data-search_alv_var.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-search_alv_var = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-search_alv_var = tmp_str.
  ENDIF.

*PLOT_AVL_VAR
  CLEAR tmp_str.
  pname = 'PLOT_ALV_VAR'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-plot_alv_var = default_data-plot_alv_var.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-plot_alv_var = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-plot_alv_var = tmp_str.
  ENDIF.

**DOWN_PATH
*  CLEAR tmp_str.
*  SELECT klient_down_pfad
*    FROM zcl_preprozessor
*    INTO tmp_str
*    WHERE preprozessor IN
*    (  select PREPROZESSOR
*         from ZCL_PREPROZ_USER
*         WHERE uname = uname
*         AND status = c_status_aktiv
*    ).
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    user_data-down_path = default_data-down_path.
*  ELSE.
*    user_data-down_path = tmp_str.
*  ENDIF.

*PPL_DOWN_PATH
  IF user_data-knz_use_post = 'X'.
    CLEAR tmp_str.
    pname = 'PPL_DOWN_PATH'.
    SELECT pwert FROM zcl_plint_config
      INTO tmp_str
      WHERE uname = uname
      AND pname = pname
      .
    ENDSELECT.
    IF sy-subrc NE 0.
      user_data-ppl_down_path = default_data-ppl_down_path.
      IF f_role_used = 'X'.
        LOOP AT itab_roles INTO wa_roles.
          SELECT SINGLE pwert FROM zcl_plint_config
            INTO tmp_str
            WHERE rolle = wa_roles-agr_name
            AND pname = pname
            .
          IF sy-subrc NE 0.
          ELSE.
*         gefunden
            user_data-ppl_down_path = tmp_str.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
      ENDIF.
    ELSE.
      user_data-ppl_down_path = tmp_str.
    ENDIF.
  ELSE.
  ENDIF.

*VIEW_DOWN_PATH
  CLEAR tmp_str.
  pname = 'VIEW_DOWN_PATH'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-view_down_path = default_data-view_down_path.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-view_down_path = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-view_down_path = tmp_str.
  ENDIF.

**CLF_DOWN_PATH
*  CLEAR tmp_str.
*  SELECT klient_scan_pfad
*    FROM zcl_preprozessor
*    INTO tmp_str
*    WHERE preprozessor IN
*    (  select PREPROZESSOR
*         from ZCL_PREPROZ_USER
*         WHERE uname = uname
*         AND status = c_status_aktiv
*    ).
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    user_data-clf_down_path = default_data-clf_down_path.
*  ELSE.
*    user_data-clf_down_path = tmp_str.
*  ENDIF.

* KNZ_SHOW_HTML_HELP
  CLEAR tmp_str.
  pname = 'KNZ_SHOW_HTML_HELP'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_show_html_help = default_data-knz_show_html_help.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_show_html_help = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_show_html_help = tmp_str.
  ENDIF.

* HTML_HELP_PATH
  CLEAR tmp_str.
  pname = 'HTML_HELP_PATH'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-html_help_path = default_data-html_help_path.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-html_help_path = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-html_help_path = tmp_str.
  ENDIF.


* KNZ_USER_DUMMY
  CLEAR tmp_str.
  pname = 'KNZ_USER_DUMMY'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_user_dummy = default_data-knz_user_dummy.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_user_dummy = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_user_dummy = tmp_str.
  ENDIF.

* USER_DUMMY_KUNNR
  CLEAR tmp_str.
  pname = 'KNZ_USER_DUMMY'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-user_dummy_kunnr = default_data-user_dummy_kunnr.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-user_dummy_kunnr = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-user_dummy_kunnr = tmp_str.
  ENDIF.

* VERTEILER
  CLEAR tmp_str.
  pname = 'VERTEILER'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-verteiler = default_data-default_verteiler.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-verteiler = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-verteiler = tmp_str.
  ENDIF.

* VOREINSTELLUNG
  CLEAR tmp_str.
  pname = 'VOREINSTELLUNG'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-voreinstellung = default_data-default_voreinstellung.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-voreinstellung  = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-voreinstellung = tmp_str.
  ENDIF.

*DELETE_TMP_SEARCH
  CLEAR tmp_str.
  pname = 'DELETE_TMP_SEARCH'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-delete_tmp_search = default_data-delete_tmp_search.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-delete_tmp_search = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-delete_tmp_search = tmp_str.
  ENDIF.

*READ_TMP_SEARCH
  CLEAR tmp_str.
  pname = 'READ_TMP_SEARCH'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-read_tmp_search =
       default_data-read_tmp_search.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-read_tmp_search = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-read_tmp_search = tmp_str.
  ENDIF.

*USE_HOSTNAME
  CLEAR tmp_str.
  pname = 'USE_HOSTNAME'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-use_hostname = ''.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-use_hostname = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-use_hostname = tmp_str.
  ENDIF.

*set Hostname
  DATA: pf_batch(1).
  IF i_batch = 'X'.
    pf_batch = 'X'.
  ELSE.
    CLEAR pf_batch.
  ENDIF.

* Problem der Verbuchung, kein gesetzter sy-batch
  IF sy-cprog = 'RSM13000'.
    pf_batch = 'X'.
  ELSE.
  ENDIF.

  CALL FUNCTION 'CV120_GET_HOSTNAME'
       EXPORTING
            pf_batch          = pf_batch
       IMPORTING
            pfx_host          = user_data-hostname
       EXCEPTIONS
            error             = 1
            no_valid_frontend = 2
            OTHERS            = 3.

  IF sy-subrc <> 0.
    user_data-hostname = ''.
  ELSE.
    CLEAR wa_usr_host_cfg.
    SELECT SINGLE * FROM zcl_usr_host_cfg
      INTO wa_usr_host_cfg
      WHERE uname = uname
      AND host = user_data-hostname
      .
    IF sy-subrc NE 0.
*   APPL-LOG
    ELSE.
      user_data-ppl_down_path = wa_usr_host_cfg-ppl_down_path.
      user_data-down_path = wa_usr_host_cfg-down_path.
    ENDIF.
  ENDIF.

*USE_FILTER
  CLEAR tmp_str.
  pname = 'USE_FILTER'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-use_filter = default_data-use_filter.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-use_filter = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-use_filter = tmp_str.
  ENDIF.

*get user_prios
  user_data-prio_von = '00'.
  user_data-prio_bis = '00'.
  REFRESH itab_prioritaeten.
  SELECT * FROM zcl_prioritaeten
    INTO TABLE itab_prioritaeten.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
  LOOP AT itab_prioritaeten INTO wa_prioritaeten.
    AUTHORITY-CHECK OBJECT 'ZCL_PLOT_3'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD wa_prioritaeten-id
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
    ELSE.
      user_data-prio_von =  wa_prioritaeten-prio_von.
      user_data-prio_bis =  wa_prioritaeten-prio_bis.
    ENDIF.
  ENDLOOP.

*get user strategy
  CLEAR tmp_str.
  pname = 'STRATEGY'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-strategy = default_data-strategy.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-strategy = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-strategy = tmp_str.
  ENDIF.

* KNZ_AUTO_PROCESS
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_PROCESS'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_auto_process = default_data-knz_auto_process.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_auto_process = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_auto_process = tmp_str.
  ENDIF.

* SEARCHLIST_FILE
  CLEAR tmp_str.
  pname = 'SEARCHLIST_FILE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-searchlist_file = default_data-searchlist_file.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-searchlist_file = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-searchlist_file = tmp_str.
  ENDIF.

* PLOTLIST_FILE
  CLEAR tmp_str.
  pname = 'PLOTLIST_FILE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-plotlist_file = default_data-plotlist_file.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-plotlist_file = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-plotlist_file = tmp_str.
  ENDIF.

* DELETE_ITEM
  CLEAR tmp_str.
  pname = 'DELETE_ITEM'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-delete_item = default_data-delete_item.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-delete_item = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-delete_item = tmp_str.
  ENDIF.

* DELETE_STATUS
  CLEAR tmp_str.
  pname = 'DELETE_STATUS'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-delete_status = default_data-delete_status.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-delete_status = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-delete_status = tmp_str.
  ENDIF.

* KNZ_FORMAT_CHECKING
  CLEAR tmp_str.
  pname = 'KNZ_FORMAT_CHECKING'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_format_checking = default_data-knz_format_checking.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_format_checking = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_format_checking = tmp_str.
  ENDIF.

* KNZ_USE_MERKMAL_FORMAT
  CLEAR tmp_str.
  pname = 'KNZ_USE_MERKMAL_FORMAT'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_merkmal_format =
      default_data-knz_use_merkmal_format.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_merkmal_format = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_merkmal_format = tmp_str.
  ENDIF.

* KNZ_USE_MULTIPAGE
  CLEAR tmp_str.
  pname = 'KNZ_USE_MULTIPAGE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_multipage =
      default_data-knz_use_multipage.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_multipage = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_multipage = tmp_str.
  ENDIF.

* KNZ_ASK_BEFORE_LEAVE
  CLEAR tmp_str.
  pname = 'KNZ_ASK_BEFORE_LEAVE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_ask_before_leave =
      default_data-knz_ask_before_leave.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_ask_before_leave = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_ask_before_leave = tmp_str.
  ENDIF.

* KNZ_ASK_BEFORE_DELETE
  CLEAR tmp_str.
  pname = 'KNZ_ASK_BEFORE_DELETE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_ask_before_delete =
      default_data-knz_ask_before_delete.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_ask_before_delete = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_ask_before_delete = tmp_str.
  ENDIF.

* KNZ_GET_MATERIAL
  CLEAR tmp_str.
  pname = 'KNZ_GET_MATERIAL'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_get_material =
      default_data-knz_get_material.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_get_material = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_get_material = tmp_str.
  ENDIF.

* KNZ_USE_KOSTL
  CLEAR tmp_str.
  pname = 'KNZ_USE_KOSTL'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_kostl =
      default_data-knz_use_kostl.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_kostl = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_kostl = tmp_str.
  ENDIF.

* VORGABE für Strg-Shift-F12
  CLEAR tmp_str.
  pname = 'VORGABE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-vorgabe =
      default_data-vorgabe.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-vorgabe = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-vorgabe = tmp_str.
  ENDIF.

* MAT_STATUS_EXC
  CLEAR tmp_str.
  pname = 'MAT_STATUS_EXC'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_status_exc =
      default_data-mat_status_exc.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mat_status_exc = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mat_status_exc = tmp_str.
  ENDIF.

* TRENNZEICHEN
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-trennzeichen =
      default_data-trennzeichen.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-trennzeichen = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-trennzeichen = tmp_str.
  ENDIF.

* MAT_STATUS_ICON
  CLEAR tmp_str.
  pname = 'MAT_STATUS_ICON'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_status_icon =
      default_data-mat_status_icon.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mat_status_icon = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mat_status_icon = tmp_str.
  ENDIF.
****
  REFRESH itab_mat_status_exc.
  SPLIT user_data-mat_status_exc AT user_data-trennzeichen
    INTO TABLE itab_mat_status_exc.
***

* FEHLBLATT_ICON
  CLEAR tmp_str.
  pname = 'FEHLBLATT_ICON'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-fehlblatt_icon =
      default_data-fehlblatt_icon.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-fehlblatt_icon = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-fehlblatt_icon = tmp_str.
  ENDIF.

* KNZ_DOWN_FILES_DEL
  CLEAR tmp_str.
  pname = 'KNZ_DOWN_FILES_DEL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_down_files_del =
      default_data-knz_down_files_del.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_down_files_del = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_down_files_del = tmp_str.
  ENDIF.

* KNZ_USE_CHECKED_IN
  CLEAR tmp_str.
  pname = 'KNZ_USE_CHECKED_IN'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_checked_in =
      default_data-knz_use_checked_in.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_checked_in = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_checked_in = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon =
      default_data-spez_dok_icon.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-spez_dok_icon = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-spez_dok_icon = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_STUECKLIST
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_STUECKLIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon_stuecklist =
      default_data-spez_dok_icon_stuecklist.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-spez_dok_icon_stuecklist = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-spez_dok_icon_stuecklist = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_FOLGE
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_FOLGE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon_folge =
      default_data-spez_dok_icon_folge.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-spez_dok_icon_folge = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-spez_dok_icon_folge = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_VORGANG
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_VORGANG'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon_vorgang =
      default_data-spez_dok_icon_vorgang.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-spez_dok_icon_vorgang = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-spez_dok_icon_vorgang = tmp_str.
  ENDIF.

* KNZ_USE_NEW_CLF_TYPE
  CLEAR tmp_str.
  pname = 'KNZ_USE_NEW_CLF_TYPE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_new_clf_type =
      default_data-knz_use_new_clf_type.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_new_clf_type = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_new_clf_type = tmp_str.
  ENDIF.

* SPEICHER_ORT_FB_LISTE
  CLEAR tmp_str.
  pname = 'SPEICHER_ORT_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-speicher_ort_fb_liste =
      default_data-speicher_ort_fb_liste.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-speicher_ort_fb_liste = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-speicher_ort_fb_liste = tmp_str.
  ENDIF.

* KNZ_STATIC_FB_LISTE
  CLEAR tmp_str.
  pname = 'KNZ_STATIC_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_static_fb_liste =
      default_data-knz_static_fb_liste.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_static_fb_liste = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_static_fb_liste = tmp_str.
  ENDIF.

* TRENNZEICHEN_FB_LISTE
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-trennzeichen_fb_liste =
      default_data-trennzeichen_fb_liste.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-trennzeichen_fb_liste = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-trennzeichen_fb_liste = tmp_str.
  ENDIF.

* KNZ_DIALOG_FB_LISTE
  CLEAR tmp_str.
  pname = 'KNZ_DIALOG_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_dialog_fb_liste =
      default_data-knz_dialog_fb_liste.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_dialog_fb_liste = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_dialog_fb_liste = tmp_str.
  ENDIF.

* KNZ_ANMELDUNG_AM_SERVER
  CLEAR tmp_str.
  pname = 'KNZ_ANMELDUNG_AM_SERVER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_anmeldung_am_server =
      default_data-knz_anmeldung_am_server.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_anmeldung_am_server = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_anmeldung_am_server = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-anmeldestring_server =
      default_data-anmeldestring_server.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-anmeldestring_server = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-anmeldestring_server = tmp_str.
  ENDIF.

* KNZ_USE_CONVERTE
  CLEAR tmp_str.
  SELECT knz_use_converte
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_converte = default_data-knz_use_converte.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_converte = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_converte = tmp_str.
  ENDIF.

* CONVERTER_NAME
  CLEAR tmp_str.
  SELECT converter_name
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-converter_name = default_data-converter_name.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-converter_name = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-converter_name = tmp_str.
  ENDIF.

* CONVERTER_NUMBER
  CLEAR tmp_str.
  SELECT converter_number
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-converter_number = default_data-converter_number.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-converter_number = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-converter_number = tmp_str.
  ENDIF.

* KNZ_AUTO_FAUF
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_FAUF'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_auto_fauf =
      default_data-knz_auto_fauf.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_auto_fauf = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_auto_fauf = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_FAUF
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_FAUF'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_fauf =
      default_data-default_verteiler_fauf.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-default_verteiler_fauf = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-default_verteiler_fauf = tmp_str.
  ENDIF.

* KNZ_ALV_PATCH
  CLEAR tmp_str.
  pname = 'KNZ_ALV_PATCH'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_alv_patch =
      default_data-knz_alv_patch.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_alv_patch = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_alv_patch = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER_VORHER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER_VORHER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-anmeldestring_server_vorher =
      default_data-anmeldestring_server_vorher.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-anmeldestring_server_vorher = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-anmeldestring_server_vorher = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER_NACHHER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER_NACHHER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-anmeldestring_server_nachher =
      default_data-anmeldestring_server_nachher.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-anmeldestring_server_nachher = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-anmeldestring_server_nachher = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_check_dis =
      default_data-knz_check_dis.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_check_dis = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_check_dis = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS_CLASS
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS_CLASS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_check_dis_class =
      default_data-knz_check_dis_class.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_check_dis_class = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_check_dis_class = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS_DOKAR
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS_DOKAR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_check_dis_dokar =
      default_data-knz_check_dis_dokar.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_check_dis_dokar = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_check_dis_dokar = tmp_str.
  ENDIF.


* KNZ_USE_NEW_ROLES
  CLEAR tmp_str.
  pname = 'KNZ_USE_NEW_ROLES'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_new_roles =
      default_data-knz_use_new_roles.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_new_roles = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_new_roles = tmp_str.
  ENDIF.

* KNZ_USE_ADMIN_MODULE
  CLEAR tmp_str.
  pname = 'KNZ_USE_ADMIN_MODULE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_admin_module =
      default_data-knz_use_admin_module.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_admin_module = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_admin_module = tmp_str.
  ENDIF.

* KNZ_MAKE_ID_PLOTJOB
  CLEAR tmp_str.
  pname = 'KNZ_MAKE_ID_PLOTJOB'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_make_id_plotjob =
      default_data-knz_make_id_plotjob.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_make_id_plotjob = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_make_id_plotjob = tmp_str.
  ENDIF.

* PREPROCESSOR
  CLEAR tmp_str.
  SELECT SINGLE preprozessor FROM zcl_preproz_user
    INTO tmp_str
    WHERE uname = uname
    AND status = c_status_aktiv
    .
  IF sy-subrc NE 0.
*   Testen, ob eine Zuordnung über eine Rolle vorliegt
    DATA: uname_prepro TYPE xubname.
    CLEAR uname_prepro.
    CALL FUNCTION '/CIDEON/CHECK_ROLES_FOR_USER'
         EXPORTING
              i_uname        = uname
         IMPORTING
              o_uname_prepro = uname_prepro
         EXCEPTIONS
              no_role        = 1
              error          = 2
              OTHERS         = 3.
    IF sy-subrc <> 0.
      user_data-preprocessor =
        default_data-preprocessor.
    ELSE.
*     Lesen des PrePro mit Nutzernamen der Rolle
      CLEAR tmp_str.
      SELECT SINGLE preprozessor FROM zcl_preproz_user
        INTO tmp_str
        WHERE uname = uname_prepro
        AND status = c_status_aktiv
        .
      IF sy-subrc NE 0.
        user_data-preprocessor =
          default_data-preprocessor.
      ELSE.
        user_data-preprocessor = tmp_str.
      ENDIF.
    ENDIF.
  ELSE.
    user_data-preprocessor = tmp_str.
  ENDIF.

* ADMIN_ALV_VAR
  CLEAR tmp_str.
  pname = 'ADMIN_ALV_VAR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-admin_alv_var =
      default_data-admin_alv_var.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-admin_alv_var = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-admin_alv_var = tmp_str.
  ENDIF.

* TRANS_CV01N
  CLEAR tmp_str.
  pname = 'TRANS_CV01N'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-trans_cv01n =
      default_data-trans_cv01n.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-trans_cv01n = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-trans_cv01n = tmp_str.
  ENDIF.

* TRANS_CV01N_SKIP_FIRST_SCREEN
  CLEAR tmp_str.
  pname = 'TRANS_CV01N_SKIP_FIRST_SCREEN'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-trans_cv01n_skip_first_screen =
      default_data-trans_cv01n_skip_first_screen.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-trans_cv01n_skip_first_screen = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-trans_cv01n_skip_first_screen = tmp_str.
  ENDIF.

* KNZ_AUTO_CS
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_CS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_auto_cs =
      default_data-knz_auto_cs.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_auto_cs = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_auto_cs = tmp_str.
  ENDIF.


* DEFAULT_VERTEILER_CS
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_CS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_cs =
      default_data-default_verteiler_cs.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-default_verteiler_cs = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-default_verteiler_cs = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_DOK_VERTEIL
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_DOK_VERTEIL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_dok_verteil =
      default_data-default_verteiler_dok_verteil.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-default_verteiler_dok_verteil = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-default_verteiler_dok_verteil = tmp_str.
  ENDIF.


*DOWN_PATH
  CLEAR tmp_str.
  SELECT klient_down_pfad
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor = user_data-preprocessor
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-down_path = default_data-down_path.
  ELSE.
    user_data-down_path = tmp_str.
  ENDIF.


*CLF_DOWN_PATH
  CLEAR tmp_str.
  SELECT klient_scan_pfad
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor = user_data-preprocessor
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-clf_down_path = default_data-clf_down_path.
  ELSE.
    user_data-clf_down_path = tmp_str.
  ENDIF.


* FTP_DESTINATION
  CLEAR tmp_str.
  SELECT ftp_destination
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor = user_data-preprocessor
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-ftp_destination = default_data-ftp_destination.
  ELSE.
    user_data-ftp_destination = tmp_str.
  ENDIF.

* FTP_USER
  CLEAR tmp_str.
  SELECT ftp_user
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor = user_data-preprocessor
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-ftp_user = default_data-ftp_user.
  ELSE.
    user_data-ftp_user = tmp_str.
  ENDIF.

* FTP_PASSWD
  CLEAR tmp_str.
  SELECT ftp_passwd
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor = user_data-preprocessor
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-ftp_passwd = default_data-ftp_passwd.
  ELSE.
    user_data-ftp_passwd = tmp_str.
  ENDIF.

* FTP_DOWN
  CLEAR tmp_str.
  SELECT ftp_down
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor = user_data-preprocessor
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-ftp_down = default_data-ftp_down.
  ELSE.
    user_data-ftp_down = tmp_str.
  ENDIF.

* KNZ_VIEW_STRUC_PLOTLIST
  CLEAR tmp_str.
  pname = 'KNZ_VIEW_STRUC_PLOTLIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_view_struc_plotlist =
      default_data-knz_view_struc_plotlist.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_view_struc_plotlist = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_view_struc_plotlist = tmp_str.
  ENDIF.

* KNZ_VIEW_DRAW_DETAIL
  CLEAR tmp_str.
  pname = 'KNZ_VIEW_DRAW_DETAIL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_view_draw_detail =
      default_data-knz_view_draw_detail.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_view_draw_detail = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_view_draw_detail = tmp_str.
  ENDIF.

* KNZ_USE_PLOT_RIGHT_1
  CLEAR tmp_str.
  pname = 'KNZ_USE_PLOT_RIGHT_1'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_plot_right_1 =
      default_data-knz_use_plot_right_1.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_plot_right_1 = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_plot_right_1 = tmp_str.
  ENDIF.

* KNZ_AUDIT_TRAIL
  CLEAR tmp_str.
  pname = 'KNZ_AUDIT_TRAIL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_audit_trail =
      default_data-knz_audit_trail.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_audit_trail = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_audit_trail = tmp_str.
  ENDIF.

* KNZ_AUTO_DOK
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_DOK'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_auto_dok =
      default_data-knz_auto_dok.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_auto_dok = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_auto_dok = tmp_str.
  ENDIF.


* DEFAULT_VERTEILER_DOK
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_DOK'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_dok =
      default_data-default_verteiler_dok.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-default_verteiler_dok = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-default_verteiler_dok = tmp_str.
  ENDIF.

* 2D_DERIVATION_LIST
  CLEAR tmp_str.
  pname = '2D_DERIVATION_LIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-2d_derivation_list =
      default_data-2d_derivation_list.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-2d_derivation_list = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-2d_derivation_list = tmp_str.
  ENDIF.

* KNZ_CHECK_EBELN
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_EBELN'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_check_ebeln =
      default_data-knz_check_ebeln.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_check_ebeln = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_check_ebeln = tmp_str.
  ENDIF.

* CHECK_EBELN_STRATEGY
  CLEAR tmp_str.
  pname = 'CHECK_EBELN_STRATEGY'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-check_ebeln_strategy =
      default_data-check_ebeln_strategy.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-check_ebeln_strategy = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-check_ebeln_strategy = tmp_str.
  ENDIF.

* SMARTFORM_CS02	
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS02'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_cs02 =
      default_data-smartform_cs02.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_cs02 = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_cs02 = tmp_str.
  ENDIF.

* SMARTFORM_CS11	
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS11'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_cs11 =
      default_data-smartform_cs11.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_cs11 = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_cs11 = tmp_str.
  ENDIF.

* SMARTFORM_CS12	
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS12'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_cs12 =
      default_data-smartform_cs12.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_cs12 = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_cs12 = tmp_str.
  ENDIF.

* SMARTFORM_CS13	
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS13'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_cs13 =
      default_data-smartform_cs13.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_cs13 = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_cs13 = tmp_str.
  ENDIF.

* MAT_CAPID	
  CLEAR tmp_str.
  pname = 'MAT_CAPID'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mat_capid =
      default_data-mat_capid.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mat_capid = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mat_capid = tmp_str.
  ENDIF.

* MAT_STPST	
  CLEAR tmp_str.
  pname = 'MAT_STPST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mat_stpst =
      default_data-mat_stpst.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mat_stpst = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mat_stpst = tmp_str.
  ENDIF.

* MAT_DOKAR_PRIO_LIST
  CLEAR tmp_str.
  pname = 'MAT_DOKAR_PRIO_LIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mat_dokar_prio_list =
      default_data-mat_dokar_prio_list.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mat_dokar_prio_list = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mat_dokar_prio_list = tmp_str.
  ENDIF.

* MAT_TDDEST	
  CLEAR tmp_str.
  pname = 'MAT_TDDEST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mat_tddest =
      default_data-mat_tddest.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mat_tddest = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mat_tddest = tmp_str.
  ENDIF.

* MAT_TDPRINTER	
  CLEAR tmp_str.
  pname = 'MAT_TDPRINTER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mat_tdprinter =
      default_data-mat_tdprinter.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mat_tdprinter = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mat_tdprinter = tmp_str.
  ENDIF.

* KNZ_USE_STAMP_BEFORE_VIEW
  CLEAR tmp_str.
  pname = 'KNZ_USE_STAMP_BEFORE_VIEW'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_stamp_before_view =
      default_data-knz_use_stamp_before_view.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_stamp_before_view = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_stamp_before_view = tmp_str.
  ENDIF.

* STAMP_PROGRAM
  CLEAR tmp_str.
  pname = 'STAMP_PROGRAM'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_program =
      default_data-stamp_program.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_program = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_program = tmp_str.
  ENDIF.

* STAMP_PARAMETER
  CLEAR tmp_str.
  pname = 'STAMP_PARAMETER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_parameter =
      default_data-stamp_parameter.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_parameter = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_parameter = tmp_str.
  ENDIF.

* KNZ_USE_STAMP_CALL_RFC
  CLEAR tmp_str.
  pname = 'KNZ_USE_STAMP_CALL_RFC'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_stamp_call_rfc =
      default_data-knz_use_stamp_call_rfc.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_stamp_call_rfc = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_stamp_call_rfc = tmp_str.
  ENDIF.

* STAMP_RFC_DESTINATION
  CLEAR tmp_str.
  pname = 'STAMP_RFC_DESTINATION'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_rfc_destination =
      default_data-stamp_rfc_destination.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_rfc_destination = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_rfc_destination = tmp_str.
  ENDIF.

* STAMP_FTP_DESTINATION
  CLEAR tmp_str.
  pname = 'STAMP_FTP_DESTINATION'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_ftp_destination =
      default_data-stamp_ftp_destination.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_ftp_destination = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_ftp_destination = tmp_str.
  ENDIF.

* STAMP_FTP_USER
  CLEAR tmp_str.
  pname = 'STAMP_FTP_USER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_ftp_user =
      default_data-stamp_ftp_user.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_ftp_user = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_ftp_user = tmp_str.
  ENDIF.


* STAMP_FTP_PASSWD
  CLEAR tmp_str.
  pname = 'STAMP_FTP_PASSWD'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_ftp_passwd =
      default_data-stamp_ftp_passwd.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_ftp_passwd = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_ftp_passwd = tmp_str.
  ENDIF.


* STAMP_FTP_VERZEICHNIS
  CLEAR tmp_str.
  pname = 'STAMP_FTP_VERZEICHNIS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_ftp_verzeichnis =
      default_data-stamp_ftp_verzeichnis.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_ftp_verzeichnis = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_ftp_verzeichnis = tmp_str.
  ENDIF.

* STAMP_DELAY
  CLEAR tmp_str.
  pname = 'STAMP_DELAY'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-stamp_delay =
      default_data-stamp_delay.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-stamp_delay = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-stamp_delay = tmp_str.
  ENDIF.

* KNZ_PLOT_LOG
  CLEAR tmp_str.
  pname = 'KNZ_PLOT_LOG'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_plot_log =
      default_data-knz_plot_log.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_plot_log = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_plot_log = tmp_str.
  ENDIF.
* Setzen der Parameter ID
  SET PARAMETER ID 'Z_KNZ_PLOT_LOG' FIELD user_data-knz_plot_log.

* BOM_DATUV
  CLEAR tmp_str.
  pname = 'BOM_DATUV'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-bom_datuv =
      default_data-bom_datuv.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-bom_datuv = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-bom_datuv = tmp_str.
  ENDIF.
* Bereinigung BOMDATUV
  IF user_data-bom_datuv = ''.
    CLEAR user_data-bom_datuv.
  ELSE.
  ENDIF.

* KNZ_USE_VERT_RIGHTS
  CLEAR tmp_str.
  pname = 'KNZ_USE_VERT_RIGHTS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_vert_rights =
      default_data-knz_use_vert_rights.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_vert_rights = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_vert_rights = tmp_str.
  ENDIF.

* KNZ_CLF_COMMIT	
  CLEAR tmp_str.
  pname = 'KNZ_CLF_COMMIT'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_clf_commit =
      default_data-knz_clf_commit.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_clf_commit = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_clf_commit = tmp_str.
  ENDIF.
* Setzen der Parameter ID
  SET PARAMETER ID 'Z_KNZ_CLF_COMMIT' FIELD user_data-knz_clf_commit.

* CLF_WAIT_TIME	
  CLEAR tmp_str.
  pname = 'CLF_WAIT_TIME'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-clf_wait_time =
      default_data-clf_wait_time.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-clf_wait_time = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-clf_wait_time = tmp_str.
  ENDIF.
* Setzen der Parameter ID
  SET PARAMETER ID 'Z_CLF_WAIT_TIME' FIELD user_data-clf_wait_time.

* KNZ_COPY_ORIGINAL
  CLEAR tmp_str.
  pname = 'KNZ_COPY_ORIGINAL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_copy_original =
      default_data-knz_copy_original.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_copy_original = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_copy_original = tmp_str.
  ENDIF.
* Setzen der Parameter ID
  SET PARAMETER ID 'Z_COPY_ORIGINAL' FIELD user_data-knz_copy_original.

* KNZ_SINGLE_ENTRY
  CLEAR tmp_str.
  pname = 'KNZ_SINGLE_ENTRY'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_single_entry =
      default_data-knz_single_entry.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_single_entry = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_single_entry = tmp_str.
  ENDIF.

* KNZ_CREATE_TOC
  CLEAR tmp_str.
  pname = 'KNZ_CREATE_TOC'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_create_toc =
      default_data-knz_create_toc.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_create_toc = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_create_toc = tmp_str.
  ENDIF.

* KNZ_SEND_TOC
  CLEAR tmp_str.
  pname = 'KNZ_SEND_TOC'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_send_toc =
      default_data-knz_send_toc.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_send_toc = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_send_toc = tmp_str.
  ENDIF.

* KNZ_EBELN_EXPRESSMAIL
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_EXPRESSMAIL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_ebeln_expressmail =
      default_data-knz_ebeln_expressmail.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_ebeln_expressmail = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_ebeln_expressmail = tmp_str.
  ENDIF.

* KNZ_EBELN_POS
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_POS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_ebeln_pos =
      default_data-knz_ebeln_pos.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_ebeln_pos = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_ebeln_pos = tmp_str.
  ENDIF.

* KNZ_EBELN_MAT
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_MAT'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_ebeln_mat =
      default_data-knz_ebeln_mat.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_ebeln_mat = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_ebeln_mat = tmp_str.
  ENDIF.

* KNZ_EBELN_BOM
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_BOM'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_ebeln_bom =
      default_data-knz_ebeln_bom.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_ebeln_bom = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_ebeln_bom = tmp_str.
  ENDIF.

* KNZ_EBELN_DIALOG
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_DIALOG'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_ebeln_dialog =
      default_data-knz_ebeln_dialog.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_ebeln_dialog = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_ebeln_dialog = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_EBELN
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_EBELN'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_ebeln =
      default_data-default_verteiler_ebeln.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-default_verteiler_ebeln = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-default_verteiler_ebeln = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_VBELN
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_VBELN'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_vbeln =
      default_data-default_verteiler_vbeln.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-default_verteiler_vbeln = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-default_verteiler_vbeln = tmp_str.
  ENDIF.

* KNZ_VBELN_EXPRESSMAIL
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_EXPRESSMAIL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_vbeln_expressmail =
      default_data-knz_vbeln_expressmail.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_vbeln_expressmail = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_vbeln_expressmail = tmp_str.
  ENDIF.

* KNZ_VBELN_POS
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_POS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_vbeln_pos =
      default_data-knz_vbeln_pos.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_vbeln_pos = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_vbeln_pos = tmp_str.
  ENDIF.

* KNZ_VBELN_MAT
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_MAT'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_vbeln_mat =
      default_data-knz_vbeln_mat.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_vbeln_mat = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_vbeln_mat = tmp_str.
  ENDIF.

* KNZ_VBELN_BOM
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_BOM'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_vbeln_bom =
      default_data-knz_vbeln_bom.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_vbeln_bom = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_vbeln_bom = tmp_str.
  ENDIF.

* KNZ_VBELN_DIALOG
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_DIALOG'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_vbeln_dialog =
      default_data-knz_vbeln_dialog.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_vbeln_dialog = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_vbeln_dialog = tmp_str.
  ENDIF.

* SEPARATOR_DIS
  CLEAR tmp_str.
  pname = 'SEPARATOR_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-separator_dis =
      default_data-separator_dis.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-separator_dis = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-separator_dis = tmp_str.
  ENDIF.

* MDR_FLAG_NAME	
  CLEAR tmp_str.
  pname = 'MDR_FLAG_NAME'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mdr_flag_name =
      default_data-mdr_flag_name.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mdr_flag_name = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mdr_flag_name = tmp_str.
  ENDIF.

* MDR_FLAG_VAL	
  CLEAR tmp_str.
  pname = 'MDR_FLAG_VAL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mdr_flag_val =
      default_data-mdr_flag_val.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mdr_flag_val = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mdr_flag_val = tmp_str.
  ENDIF.

* TR_FLAG_NAME	
  CLEAR tmp_str.
  pname = 'TR_FLAG_NAME'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-tr_flag_name =
      default_data-tr_flag_name.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-tr_flag_name = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-tr_flag_name = tmp_str.
  ENDIF.

* TR_FLAG_VAL	
  CLEAR tmp_str.
  pname = 'TR_FLAG_VAL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-tr_flag_val =
      default_data-tr_flag_val.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-tr_flag_val = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-tr_flag_val = tmp_str.
  ENDIF.

* SMARTFORM_MDR	
  CLEAR tmp_str.
  pname = 'SMARTFORM_MDR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_mdr =
      default_data-smartform_mdr.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_mdr = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_mdr = tmp_str.
  ENDIF.

* SMARTFORM_TR	
  CLEAR tmp_str.
  pname = 'SMARTFORM_TR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_tr =
      default_data-smartform_tr.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_tr = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_tr = tmp_str.
  ENDIF.

* TOC_DIS
  CLEAR tmp_str.
  pname = 'TOC_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-toc_dis =
      default_data-toc_dis.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-toc_dis = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-toc_dis = tmp_str.
  ENDIF.

* SRC_FLAG_NAME	
  CLEAR tmp_str.
  pname = 'SRC_FLAG_NAME'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-src_flag_name =
      default_data-src_flag_name.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-src_flag_name = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-src_flag_name = tmp_str.
  ENDIF.

* SRC_FLAG_VAL	
  CLEAR tmp_str.
  pname = 'SRC_FLAG_VAL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-src_flag_val =
      default_data-src_flag_val.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-src_flag_val = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-src_flag_val = tmp_str.
  ENDIF.

* SRC_FLAG_NAME_2	
  CLEAR tmp_str.
  pname = 'SRC_FLAG_NAME_2	'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-src_flag_name_2	 =
      default_data-src_flag_name_2	.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-src_flag_name_2 = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-src_flag_name_2 = tmp_str.
  ENDIF.

* SRC_FLAG_VAL_2	
  CLEAR tmp_str.
  pname = 'SRC_FLAG_VAL_2'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-src_flag_val_2 =
      default_data-src_flag_val_2.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-src_flag_val_2 = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-src_flag_val_2 = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_MDR
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_MDR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_mdr =
      default_data-default_verteiler_mdr.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-default_verteiler_mdr = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-default_verteiler_mdr = tmp_str.
  ENDIF.

* EASYDMS_FOLDER_TYPE
  CLEAR tmp_str.
  pname = 'EASYDMS_FOLDER_TYPE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-easydms_folder_type =
      default_data-easydms_folder_type.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-easydms_folder_type = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-easydms_folder_type = tmp_str.
  ENDIF.

* STORAGE_CAT_TR
  CLEAR tmp_str.
  pname = 'STORAGE_CAT_TR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-storage_cat_tr =
      default_data-storage_cat_tr.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-storage_cat_tr = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-storage_cat_tr = tmp_str.
  ENDIF.


* STORAGE_DIS_TR
  CLEAR tmp_str.
  pname = 'STORAGE_DIS_TR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-storage_dis_tr =
      default_data-storage_dis_tr.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-storage_dis_tr = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-storage_dis_tr = tmp_str.
  ENDIF.

* SMARTFORM_MATLIST
  CLEAR tmp_str.
  pname = 'SMARTFORM_MATLIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_matlist =
      default_data-smartform_matlist.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_matlist = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_matlist = tmp_str.
  ENDIF.

* SMARTFORM_DOCLIST
  CLEAR tmp_str.
  pname = 'SMARTFORM_DOCLIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-smartform_doclist =
      default_data-smartform_doclist.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-smartform_doclist = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-smartform_doclist = tmp_str.
  ENDIF.

* MDR_DIS
  CLEAR tmp_str.
  pname = 'MDR_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-mdr_dis =
      default_data-mdr_dis.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-mdr_dis = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-mdr_dis = tmp_str.
  ENDIF.

* NOTE_DIS
  CLEAR tmp_str.
  pname = 'NOTE_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-note_dis =
      default_data-note_dis.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-note_dis = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-note_dis = tmp_str.
  ENDIF.

* NOTE_DIR_STORAGE
  CLEAR tmp_str.
  pname = 'NOTE_DIR_STORAGE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-note_dir_storage =
      default_data-note_dir_storage.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-note_dir_storage = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-note_dir_storage = tmp_str.
  ENDIF.

* VFTEMPLATE
  CLEAR tmp_str.
  pname = 'VFTEMPLATE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-vftemplate =
      default_data-vftemplate.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-vftemplate = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-vftemplate = tmp_str.
  ENDIF.

* VFTEMPLATE_TOC
  CLEAR tmp_str.
  pname = 'VFTEMPLATE_TOC'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-vftemplate_toc =
      default_data-vftemplate_toc.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-vftemplate_toc = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-vftemplate_toc = tmp_str.
  ENDIF.

* KNZ_WSA_TO_PLOTLIST
  CLEAR tmp_str.
  pname = 'KNZ_WSA_TO_PLOTLIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_wsa_to_plotlist =
      default_data-knz_wsa_to_plotlist.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_wsa_to_plotlist = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_wsa_to_plotlist = tmp_str.
  ENDIF.



* PRIO_WSA_TO_PLOTLIST
  CLEAR tmp_str.
  pname = 'PRIO_WSA_TO_PLOTLIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-prio_wsa_to_plotlist =
      default_data-prio_wsa_to_plotlist.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-prio_wsa_to_plotlist = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-prio_wsa_to_plotlist = tmp_str.
  ENDIF.


* KNZ_WSA_TO_PLOTLIST_CHECK_FILE
  CLEAR tmp_str.
  pname = 'KNZ_WSA_TO_PLOTLIST_CHECK_FILE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_wsa_to_plotlist_check_file =
      default_data-knz_wsa_to_plotlist_check_file.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_wsa_to_plotlist_check_file = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_wsa_to_plotlist_check_file = tmp_str.
  ENDIF.


* KNZ_ME_SEP
  CLEAR tmp_str.
  pname = 'KNZ_ME_SEP'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_me_sep =
      default_data-knz_me_sep.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_me_sep = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_me_sep = tmp_str.
  ENDIF.


* KNZ_SD_SEP
  CLEAR tmp_str.
  pname = 'KNZ_SD_SEP'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_sd_sep =
      default_data-knz_sd_sep.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_sd_sep = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_sd_sep = tmp_str.
  ENDIF.

* KNZ_PL_NO_DOUBLE
  CLEAR tmp_str.
  pname = 'KNZ_PL_NO_DOUBLE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_pl_no_double =
      default_data-knz_pl_no_double.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_pl_no_double = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_pl_no_double = tmp_str.
  ENDIF.

* KNZ_LINKS
  CLEAR tmp_str.
  pname = 'KNZ_LINKS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_links =
      default_data-knz_links.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_links = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_links = tmp_str.
  ENDIF.

* KNZ_WHERE_USED
  CLEAR tmp_str.
  pname = 'KNZ_WHERE_USED'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_where_used =
      default_data-knz_where_used.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_where_used = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_where_used = tmp_str.
  ENDIF.

* KNZ_DELETE_DUPLICATES
  CLEAR tmp_str.
  pname = 'KNZ_DELETE_DUPLICATES'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_delete_duplicates =
      default_data-knz_delete_duplicates.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_delete_duplicates = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_delete_duplicates = tmp_str.
  ENDIF.


* Rückgabe
  o_user_data = user_data.


ENDFUNCTION.
