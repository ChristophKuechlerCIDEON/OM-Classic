FUNCTION Z_CL_READ_USERDATA_2_CLASS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
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
* 19.01.2003 - Umstellung auf Nutzergruppen
*-----------------------------------------------------------------------

* ITAB
  DATA: itab_prioritaeten TYPE TABLE OF zcl_prioritaeten.
  DATA: itab_mat_status_exc TYPE TABLE OF mstae.
* WA
  DATA: wa_usr_host_cfg LIKE zcl_usr_host_cfg.
  DATA: wa_prioritaeten TYPE zcl_prioritaeten.
* NORMAL
  DATA: user_data TYPE /cideon/plot_userdata.
  DATA: default_data TYPE /cideon/plot_defaultdata.



* get same user values from configuration tables
**
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).

  CLEAR user_data.
  user_data-uname = sy-uname.

  CLEAR default_data.
  default_data = i_default_data.


*KNZ_USE_POST
  CLEAR tmp_str.
  pname = 'KNZ_USE_POST'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_post = default_data-knz_use_post.
  ELSE.
    user_data-knz_use_post = tmp_str.
  ENDIF.

*SEARCH_ALV_VAR
  CLEAR tmp_str.
  pname = 'SEARCH_ALV_VAR'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-search_alv_var = default_data-search_alv_var.
  ELSE.
    user_data-search_alv_var = tmp_str.
  ENDIF.
*PLOT_AVL_VAR
  CLEAR tmp_str.
  pname = 'PLOT_ALV_VAR'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-plot_alv_var = default_data-plot_alv_var.
  ELSE.
    user_data-plot_alv_var = tmp_str.
  ENDIF.

*DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_config
*    INTO tmp_str
*    WHERE uname = sy-uname
*    AND pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    user_data-down_path = default_data-down_path.
*  ELSE.
*    user_data-down_path = tmp_str.
*  ENDIF.
  CLEAR tmp_str.
  SELECT klient_down_pfad
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-down_path = default_data-down_path.
  ELSE.
    user_data-down_path = tmp_str.
  ENDIF.

*PPL_DOWN_PATH
  IF user_data-knz_use_post = 'X'.
    CLEAR tmp_str.
    pname = 'PPL_DOWN_PATH'.
    SELECT pwert FROM zcl_plint_config
      INTO tmp_str
      WHERE uname = sy-uname
      AND pname = pname
      .
    ENDSELECT.
    IF sy-subrc NE 0.
      user_data-ppl_down_path = default_data-ppl_down_path.
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
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-view_down_path = default_data-view_down_path.
  ELSE.
    user_data-view_down_path = tmp_str.
  ENDIF.

*CLF_DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'CLF_DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_config
*    INTO tmp_str
*    WHERE uname = sy-uname
*    AND pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    user_data-clf_down_path = default_data-clf_down_path.
*  ELSE.
*    user_data-clf_down_path = tmp_str.
*  ENDIF.
  CLEAR tmp_str.
  SELECT klient_scan_pfad
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-clf_down_path = default_data-clf_down_path.
  ELSE.
    user_data-clf_down_path = tmp_str.
  ENDIF.

* KNZ_SHOW_HTML_HELP
  CLEAR tmp_str.
  pname = 'KNZ_SHOW_HTML_HELP'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_show_html_help = default_data-knz_show_html_help.
  ELSE.
    user_data-knz_show_html_help = tmp_str.
  ENDIF.

* HTML_HELP_PATH
  CLEAR tmp_str.
  pname = 'HTML_HELP_PATH'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-html_help_path = default_data-html_help_path.
  ELSE.
    user_data-html_help_path = tmp_str.
  ENDIF.


* KNZ_USER_DUMMY
  CLEAR tmp_str.
  pname = 'KNZ_USER_DUMMY'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_user_dummy = default_data-knz_user_dummy.
  ELSE.
    user_data-knz_user_dummy = tmp_str.
  ENDIF.

* USER_DUMMY_KUNNR
  CLEAR tmp_str.
  pname = 'KNZ_USER_DUMMY'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-user_dummy_kunnr = default_data-user_dummy_kunnr.
  ELSE.
    user_data-user_dummy_kunnr = tmp_str.
  ENDIF.

* VERTEILER
  CLEAR tmp_str.
  pname = 'VERTEILER'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-verteiler = default_data-default_verteiler.
  ELSE.
    user_data-verteiler = tmp_str.
  ENDIF.

* VOREINSTELLUNG
  CLEAR tmp_str.
  pname = 'VOREINSTELLUNG'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-voreinstellung = default_data-default_voreinstellung.
  ELSE.
    user_data-voreinstellung = tmp_str.
  ENDIF.

*DELETE_TMP_SEARCH
  CLEAR tmp_str.
  pname = 'DELETE_TMP_SEARCH'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-delete_tmp_search = default_data-delete_tmp_search.
  ELSE.
    user_data-delete_tmp_search = tmp_str.
  ENDIF.

*READ_TMP_SEARCH
  CLEAR tmp_str.
  pname = 'READ_TMP_SEARCH'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-read_tmp_search =
       default_data-read_tmp_search.
  ELSE.
    user_data-read_tmp_search = tmp_str.
  ENDIF.

*USE_HOSTNAME
  CLEAR tmp_str.
  pname = 'USE_HOSTNAME'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-use_hostname = ''.
  ELSE.
    user_data-use_hostname = tmp_str.
  ENDIF.

*set Hostname
  CALL FUNCTION 'CV120_GET_HOSTNAME'
       EXPORTING
            pf_batch          = ' '
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
      WHERE uname = sy-uname
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
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-use_filter = default_data-use_filter.
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
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-strategy = default_data-strategy.
  ELSE.
    user_data-strategy = tmp_str.
  ENDIF.
* grayed out, cause of problems with SAP* users
* 01-ASK
* 02-LIST
* 03-IGNORE
* 04-Faildocument
*  AUTHORITY-CHECK OBJECT 'ZCL_PLOT_4'
*           ID 'ZCL_TA' FIELD sy-tcode
*           ID 'ACTVT' FIELD '01'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*  .
*  IF sy-subrc NE 0.
*  ELSE.
*    user_data-strategy = 'A'.
*  ENDIF.
*  AUTHORITY-CHECK OBJECT 'ZCL_PLOT_4'
*           ID 'ZCL_TA' FIELD sy-tcode
*           ID 'ACTVT' FIELD '02'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*  .
*  IF sy-subrc NE 0.
*  ELSE.
*    user_data-strategy = 'L'.
*  ENDIF.
*  AUTHORITY-CHECK OBJECT 'ZCL_PLOT_4'
*         ID 'ZCL_TA' FIELD sy-tcode
*         ID 'ACTVT' FIELD '03'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*.
*  IF sy-subrc NE 0.
*  ELSE.
*    user_data-strategy = 'I'.
*  ENDIF.
*  AUTHORITY-CHECK OBJECT 'ZCL_PLOT_4'
*         ID 'ZCL_TA' FIELD sy-tcode
*         ID 'ACTVT' FIELD '04'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*.
*  IF sy-subrc NE 0.
*  ELSE.
*    user_data-strategy = 'F'.
*  ENDIF.


* KNZ_AUTO_PROCESS
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_PROCESS'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_auto_process = default_data-knz_auto_process.
  ELSE.
    user_data-knz_auto_process = tmp_str.
  ENDIF.

* SEARCHLIST_FILE
  CLEAR tmp_str.
  pname = 'SEARCHLIST_FILE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-searchlist_file = default_data-searchlist_file.
  ELSE.
    user_data-searchlist_file = tmp_str.
  ENDIF.

* PLOTLIST_FILE
  CLEAR tmp_str.
  pname = 'PLOTLIST_FILE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-plotlist_file = default_data-plotlist_file.
  ELSE.
    user_data-plotlist_file = tmp_str.
  ENDIF.

* DELETE_ITEM
  CLEAR tmp_str.
  pname = 'DELETE_ITEM'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-delete_item = default_data-delete_item.
  ELSE.
    user_data-delete_item = tmp_str.
  ENDIF.

* DELETE_STATUS
  CLEAR tmp_str.
  pname = 'DELETE_STATUS'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-delete_status = default_data-delete_status.
  ELSE.
    user_data-delete_status = tmp_str.
  ENDIF.

* KNZ_FORMAT_CHECKING
  CLEAR tmp_str.
  pname = 'KNZ_FORMAT_CHECKING'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_format_checking = default_data-knz_format_checking.
  ELSE.
    user_data-knz_format_checking = tmp_str.
  ENDIF.

* KNZ_USE_MERKMAL_FORMAT
  CLEAR tmp_str.
  pname = 'KNZ_USE_MERKMAL_FORMAT'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_merkmal_format =
      default_data-knz_use_merkmal_format.
  ELSE.
    user_data-knz_use_merkmal_format = tmp_str.
  ENDIF.

* KNZ_USE_MULTIPAGE
  CLEAR tmp_str.
  pname = 'KNZ_USE_MULTIPAGE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_multipage =
      default_data-knz_use_multipage.
  ELSE.
    user_data-knz_use_multipage = tmp_str.
  ENDIF.

* KNZ_ASK_BEFORE_LEAVE
  CLEAR tmp_str.
  pname = 'KNZ_ASK_BEFORE_LEAVE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_ask_before_leave =
      default_data-knz_ask_before_leave.
  ELSE.
    user_data-knz_ask_before_leave = tmp_str.
  ENDIF.

* KNZ_ASK_BEFORE_DELETE
  CLEAR tmp_str.
  pname = 'KNZ_ASK_BEFORE_DELETE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_ask_before_delete =
      default_data-knz_ask_before_delete.
  ELSE.
    user_data-knz_ask_before_delete = tmp_str.
  ENDIF.

* KNZ_GET_MATERIAL
  CLEAR tmp_str.
  pname = 'KNZ_GET_MATERIAL'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_get_material =
      default_data-knz_get_material.
  ELSE.
    user_data-knz_get_material = tmp_str.
  ENDIF.

* KNZ_USE_KOSTL
  CLEAR tmp_str.
  pname = 'KNZ_USE_KOSTL'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_kostl =
      default_data-knz_use_kostl.
  ELSE.
    user_data-knz_use_kostl = tmp_str.
  ENDIF.

* VORGABE für Strg-Shift-F12
  CLEAR tmp_str.
  pname = 'VORGABE'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-vorgabe =
      default_data-vorgabe.
  ELSE.
    user_data-vorgabe = tmp_str.
  ENDIF.

* MAT_STATUS_EXC
  CLEAR tmp_str.
  pname = 'MAT_STATUS_EXC'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_status_exc =
      default_data-mat_status_exc.
  ELSE.
    user_data-mat_status_exc = tmp_str.
  ENDIF.

* TRENNZEICHEN
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-trennzeichen =
      default_data-trennzeichen.
  ELSE.
    user_data-trennzeichen = tmp_str.
  ENDIF.

* MAT_STATUS_ICON
  CLEAR tmp_str.
  pname = 'MAT_STATUS_ICON'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_status_icon =
      default_data-mat_status_icon.
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
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-fehlblatt_icon =
      default_data-fehlblatt_icon.
  ELSE.
    user_data-fehlblatt_icon = tmp_str.
  ENDIF.

* KNZ_DOWN_FILES_DEL
  CLEAR tmp_str.
  pname = 'KNZ_DOWN_FILES_DEL'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_down_files_del =
      default_data-knz_down_files_del.
  ELSE.
    user_data-knz_down_files_del = tmp_str.
  ENDIF.

* KNZ_USE_CHECKED_IN
  CLEAR tmp_str.
  pname = 'KNZ_USE_CHECKED_IN'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_checked_in =
      default_data-knz_use_checked_in.
  ELSE.
    user_data-knz_use_checked_in = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon =
      default_data-spez_dok_icon.
  ELSE.
    user_data-spez_dok_icon = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_STUECKLIST
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_STUECKLIST'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon_stuecklist =
      default_data-spez_dok_icon_stuecklist.
  ELSE.
    user_data-spez_dok_icon_stuecklist = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_FOLGE
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_FOLGE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon_folge =
      default_data-spez_dok_icon_folge.
  ELSE.
    user_data-spez_dok_icon_folge = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_VORGANG
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_VORGANG'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-spez_dok_icon_vorgang =
      default_data-spez_dok_icon_vorgang.
  ELSE.
    user_data-spez_dok_icon_vorgang = tmp_str.
  ENDIF.

* KNZ_USE_NEW_CLF_TYPE
  CLEAR tmp_str.
  pname = 'KNZ_USE_NEW_CLF_TYPE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_new_clf_type =
      default_data-knz_use_new_clf_type.
  ELSE.
    user_data-knz_use_new_clf_type = tmp_str.
  ENDIF.

* SPEICHER_ORT_FB_LISTE
  CLEAR tmp_str.
  pname = 'SPEICHER_ORT_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-speicher_ort_fb_liste =
      default_data-speicher_ort_fb_liste.
  ELSE.
    user_data-speicher_ort_fb_liste = tmp_str.
  ENDIF.

* KNZ_STATIC_FB_LISTE
  CLEAR tmp_str.
  pname = 'KNZ_STATIC_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_static_fb_liste =
      default_data-knz_static_fb_liste.
  ELSE.
    user_data-knz_static_fb_liste = tmp_str.
  ENDIF.

* TRENNZEICHEN_FB_LISTE
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-trennzeichen_fb_liste =
      default_data-trennzeichen_fb_liste.
  ELSE.
    user_data-trennzeichen_fb_liste = tmp_str.
  ENDIF.

* KNZ_DIALOG_FB_LISTE
  CLEAR tmp_str.
  pname = 'KNZ_DIALOG_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_dialog_fb_liste =
      default_data-knz_dialog_fb_liste.
  ELSE.
    user_data-knz_dialog_fb_liste = tmp_str.
  ENDIF.

* KNZ_ANMELDUNG_AM_SERVER
  CLEAR tmp_str.
  pname = 'KNZ_ANMELDUNG_AM_SERVER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_anmeldung_am_server =
      default_data-knz_anmeldung_am_server.
  ELSE.
    user_data-knz_anmeldung_am_server = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-anmeldestring_server =
      default_data-anmeldestring_server.
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
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-knz_use_converte = default_data-knz_use_converte.
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
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-converter_name = default_data-converter_name.
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
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-converter_number = default_data-converter_number.
  ELSE.
    user_data-converter_number = tmp_str.
  ENDIF.

* KNZ_AUTO_FAUF
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_FAUF'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_auto_fauf =
      default_data-knz_auto_fauf.
  ELSE.
    user_data-knz_auto_fauf = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_FAUF
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_FAUF'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-default_verteiler_fauf =
      default_data-default_verteiler_fauf.
  ELSE.
    user_data-default_verteiler_fauf = tmp_str.
  ENDIF.

* KNZ_ALV_PATCH
  CLEAR tmp_str.
  pname = 'KNZ_ALV_PATCH'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_alv_patch =
      default_data-knz_alv_patch.
  ELSE.
    user_data-knz_alv_patch = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER_VORHER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER_VORHER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-anmeldestring_server_vorher =
      default_data-anmeldestring_server_vorher.
  ELSE.
    user_data-anmeldestring_server_vorher = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER_NACHHER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER_NACHHER'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-anmeldestring_server_nachher =
      default_data-anmeldestring_server_nachher.
  ELSE.
    user_data-anmeldestring_server_nachher = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_check_dis =
      default_data-knz_check_dis.
  ELSE.
    user_data-knz_check_dis = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS_CLASS
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS_CLASS'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_check_dis_class =
      default_data-knz_check_dis_class.
  ELSE.
    user_data-knz_check_dis_class = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS_DOKAR
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS_DOKAR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_check_dis_dokar =
      default_data-knz_check_dis_dokar.
  ELSE.
    user_data-knz_check_dis_dokar = tmp_str.
  ENDIF.

* FTP_DESTINATION
  CLEAR tmp_str.
  SELECT ftp_destination
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
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
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
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
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
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
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = sy-uname
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-ftp_down = default_data-ftp_down.
  ELSE.
    user_data-ftp_down = tmp_str.
  ENDIF.

* KNZ_USE_NEW_ROLES
  CLEAR tmp_str.
  pname = 'KNZ_USE_NEW_ROLES'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_new_roles =
      default_data-knz_use_new_roles.
  ELSE.
    user_data-knz_use_new_roles = tmp_str.
  ENDIF.

* KNZ_USE_ADMIN_MODULE
  CLEAR tmp_str.
  pname = 'KNZ_USE_ADMIN_MODULE'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_admin_module =
      default_data-knz_use_admin_module.
  ELSE.
    user_data-knz_use_admin_module = tmp_str.
  ENDIF.

* KNZ_MAKE_ID_PLOTJOB
  CLEAR tmp_str.
  pname = 'KNZ_MAKE_ID_PLOTJOB'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_make_id_plotjob =
      default_data-knz_make_id_plotjob.
  ELSE.
    user_data-knz_make_id_plotjob = tmp_str.
  ENDIF.

* PREPROCESSOR
  CLEAR tmp_str.
  SELECT SINGLE preprozessor FROM zcl_preproz_user
    INTO tmp_str
    WHERE uname = sy-uname
    AND status = c_status_aktiv
    .
  IF sy-subrc NE 0.
    user_data-preprocessor =
      default_data-preprocessor.
  ELSE.
    user_data-preprocessor = tmp_str.
  ENDIF.

* ADMIN_ALV_VAR
  CLEAR tmp_str.
  pname = 'ADMIN_ALV_VAR'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-admin_alv_var =
      default_data-admin_alv_var.
  ELSE.
    user_data-admin_alv_var = tmp_str.
  ENDIF.

* TRANS_CV01N
  CLEAR tmp_str.
  pname = 'TRANS_CV01N'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-trans_cv01n =
      default_data-trans_cv01n.
  ELSE.
    user_data-trans_cv01n = tmp_str.
  ENDIF.

* TRANS_CV01N_SKIP_FIRST_SCREEN
  CLEAR tmp_str.
  pname = 'TRANS_CV01N_SKIP_FIRST_SCREEN'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-trans_cv01n_skip_first_screen =
      default_data-trans_cv01n_skip_first_screen.
  ELSE.
    user_data-trans_cv01n_skip_first_screen = tmp_str.
  ENDIF.

* Rückgabe

  o_user_data = user_data.


ENDFUNCTION.
