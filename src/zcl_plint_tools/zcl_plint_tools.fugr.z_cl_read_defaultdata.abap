FUNCTION z_cl_read_defaultdata.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BATCH) TYPE  CHAR01 DEFAULT ''
*"  EXPORTING
*"     VALUE(O_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 08.09.2003 - Erstellung
* 26.09.2003 - Check / Einbau in andere FBs
* 30.09.2003 - FAUF Integration
* 15.10.2003 - Anmeldung am SMB Share
* 24.10.2003 - Kennzeichen für Check am DIS
* 05.11.2003 - USE_FILTER
* 12.11.2003 - FTP
* 01:12.2003 - KNZ_USE_NEW_ROLES
* 05.12.2003 - KNZ_USE_ADMIN_MODULE
*              KNZ_MAKE_ID_PLOTJOB
* 06.12.2003 - PREPROCESSOR
* 09.12.2003 - ADMIN_ALV_VAR
* 11.12.2003 - TRANS_CV01N
* 15.12.2003 - TRANS_CV01N_SKIP_FIRST_SCREEN
* 01.07.2004 - KNZ_AUTO_CS
*              DEFAULT_VERTEILER_CS
* 20.07.2004 - Erweiterung I_BATCH, wegen möglicher
*              Hintergrundverarbeitung
*              DEFAULT_VERTEILER_DOK_VERTEIL
* 01.11.2004 - KNZ_VIEW_STRUC_PLOTLIST
*              KNZ_VIEW_DRAW_DETAIL
* 26.01.2005 - KNZ_USE_PLOT_RIGHT_1
* 29.01.2005 - KNZ_AUDIT_TRAIL
* 26.02.2005 - MODIFY
* 23.03.2005 - MODIFY 2 Fehlerbehebung
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
* 16.06.2005 - KNZ_USE_STAMP_BEFORE_VIEW (Integration)
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
* 26.04.2007 - SP 36
*            - DEFAULT_VERTEILER_EBELN
*            - DEFAULT_VERTEILER_VBELN
*            - KNZ_VBELN_EXPRESSMAIL
*            - KNZ_VBELN_POS
*            - KNZ_VBELN_MAT
*            - KNZ_VBELN_BOM
*            - KNZ_VBELN_DIALOG
* 27.04.2007 - weitere Integration
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
* 07.08.2007   DEFAULT_VERTEILER_MDR
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
* 17.04.2008 - 'Bitte pflegen' als Text Symbol text-056
* 18.09.2008 - SP 76
*              7.0.02
*              KNZ_PL_NO_DOUBLE
* 07.10.2008 - SP 81
*              KNZ_LINKS
*              KNZ_WHERE_USED
*              KNZ_DELETE_DUPLICATES
*
* 29.01.2009 - SP 88
*              Umbau auf /CIDEON/
*-----------------------------------------------------------------------


  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = i_batch
       IMPORTING
            o_default_data = o_default_data.

  EXIT.



* ITAB
* WA
  DATA: wa TYPE zcl_plint_cfg_00.
* NORMAL
  DATA: default_data TYPE /cideon/plot_defaultdata.

*
  CLEAR wa.
  wa-zclinsname = sy-uname.
  wa-zclinsdate = sy-datum.
  wa-zclinstime = sy-uzeit.
  wa-zclinsprog = 'Z_CL_READ_DEFAULTDATA'.
  wa-zclupdname = wa-zclinsname.
  wa-zclupddate = wa-zclinsdate.
  wa-zclupdtime = wa-zclinstime.
  wa-zclupdprog = wa-zclinsprog.


* get same user values from configuration tables
**
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).

* DEFAULT_NUTZER
  CLEAR tmp_str.
  pname = 'DEFAULT_NUTZER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'SAP*' ''.
    default_data-default_nutzer = 'SAP*'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SAP*' ''.
    wa-pname = pname.
    wa-pwert = 'SAP*'.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_nutzer = tmp_str.
  ENDIF.

  SET PARAMETER ID 'Z_CL_DEF_USER' FIELD default_data-default_nutzer.

*SEARCH_ALV_VAR
  CLEAR tmp_str.
  pname = 'SEARCH_ALV_VAR'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
    default_data-search_alv_var = tmp_str.
  ENDIF.

*PLOT_AVL_VAR
  CLEAR tmp_str.
  pname = 'PLOT_ALV_VAR'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
    default_data-plot_alv_var = tmp_str.
  ENDIF.

*KNZ_USE_POST
  CLEAR tmp_str.
  pname = 'KNZ_USE_POST'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'X' ''.
    default_data-knz_use_post = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pname = pname.
    wa-pwert = ''.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_post = tmp_str.
  ENDIF.

* DEFAULT_KOPIEN
  CLEAR tmp_str.
  pname = 'DEFAULT_KOPIEN'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '1 Kopie' ''.
    default_data-default_kopien = '1'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '1 Kopie' ''.
    wa-pname = pname.
    wa-pwert = '1'.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_kopien = tmp_str.
  ENDIF.

* DEFAULT_PRIO
  CLEAR tmp_str.
  pname = 'DEFAULT_PRIO'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'Prio 5' ''.
    default_data-default_prio = '5'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'Prio 5' ''.
    wa-pwert = '5'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_prio = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s052(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      ''

      text-056
      .
    PERFORM appl_log_write USING
      'E' '052' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' text-056 .
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler = tmp_str.
  ENDIF.

* DEFAULT_VOREINSTELLUNG
  CLEAR tmp_str.
  pname = 'DEFAULT_VOREINSTELLUNG'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s052(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '' text-056
      .
    PERFORM appl_log_write USING
      'E' '052' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' text-056 .
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_voreinstellung = tmp_str.
  ENDIF.

* MERKMAL_FORMAT
  CLEAR tmp_str.
  pname = 'MERKMAL_FORMAT'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s052(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '' text-056.
    PERFORM appl_log_write USING
      'E' '052' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' text-056.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-merkmal_format = tmp_str.
  ENDIF.

* DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_cfg_00
*    INTO tmp_str
*    WHERE pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    MESSAGE s057(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      'c:\temp\' ''.
*    default_data-down_path = 'c:\temp\'.
*    PERFORM appl_log_write USING
*      'E' '057' 'ZCL_PLINT_TOOLS'
*      'zcl_plint_cfg_00' pname 'C:\temp' '' .
*  ELSE.
*    default_data-down_path = tmp_str.
*  ENDIF.

  CLEAR tmp_str.
  SELECT klient_down_pfad
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'c:\temp\' ''.
    default_data-down_path = 'c:\temp\'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-default_nutzer 'C:\temp' '' .
    wa-pwert = 'C:\temp'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-down_path = tmp_str.
  ENDIF.

* PPL_DOWN_PATH
  IF default_data-knz_use_post = 'X'.
    CLEAR tmp_str.
    pname = 'PPL_DOWN_PATH'.
    SELECT pwert FROM zcl_plint_cfg_00
      INTO tmp_str
      WHERE pname = pname
      .
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE s057(zcl_plint_tools)
        WITH 'zcl_plint_cfg_00' pname
        'C:\temp\' ''.
      default_data-ppl_down_path = 'c:\temp\*'.
      PERFORM appl_log_write USING
        'E' '057' 'ZCL_PLINT_TOOLS'
        'zcl_plint_cfg_00' pname 'C:\temp' '' .
      wa-pwert = 'c:\temp'.
      wa-pname = pname.
      MODIFY zcl_plint_cfg_00 FROM wa.
    ELSE.
      default_data-ppl_down_path = tmp_str.
    ENDIF.
  ELSE.
  ENDIF.

* VIEW_DOWN_PATH
  CLEAR tmp_str.
  pname = 'VIEW_DOWN_PATH'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    PERFORM get_local_work_path
*      CHANGING default_data-view_down_path.
    PERFORM get_local_work_path
      CHANGING default_data-view_down_path.
    IF default_data-view_down_path IS INITIAL.
      default_data-view_down_path = 'c:\temp\'.
    ELSE.
    ENDIF.

    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      default_data-view_down_path ''.
    "default_data-view_down_path = 'c:\temp\'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname default_data-view_down_path '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-view_down_path = tmp_str.
  ENDIF.

  IF default_data-view_down_path IS INITIAL.
    IF i_batch = 'X'.
      default_data-view_down_path = 'c:\temp\'.
    ELSE.
      PERFORM get_local_work_path
        CHANGING default_data-view_down_path.
      IF default_data-view_down_path IS INITIAL.
        default_data-view_down_path = 'c:\temp\'.
      ELSE.
      ENDIF.
    ENDIF.
  ELSE.
  ENDIF.

* CLF_DOWN_PATH
*  CLEAR tmp_str.
*  pname = 'CLF_DOWN_PATH'.
*  SELECT pwert FROM zcl_plint_cfg_00
*    INTO tmp_str
*    WHERE pname = pname
*    .
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    MESSAGE s057(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      'c:\temp\' ''.
*    default_data-clf_down_path = 'c:\temp\'.
*    PERFORM appl_log_write USING
*      'E' '057' 'ZCL_PLINT_TOOLS'
*      'zcl_plint_cfg_00' pname 'C:\temp' '' .
*  ELSE.
*    default_data-clf_down_path = tmp_str.
*  ENDIF.
  CLEAR tmp_str.
  SELECT klient_scan_pfad
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'c:\temp\' ''.
    default_data-clf_down_path = 'c:\temp\'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-default_nutzer 'C:\temp' '' .
  ELSE.
    default_data-clf_down_path = tmp_str.
  ENDIF.

* KNZ_SHOW_HTML_HELP
  CLEAR tmp_str.
  pname = 'KNZ_SHOW_HTML_HELP'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'space' ''.
    default_data-knz_show_html_help = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_show_html_help = tmp_str.
  ENDIF.

* HTML_HELP_PATH
  CLEAR tmp_str.
  pname = 'HTML_HELP_PATH'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'c:\temp\' ''.
    default_data-html_help_path = 'c:\temp\'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'C:\temp' '' .
    wa-pwert = 'c:\temp\'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-html_help_path = tmp_str.
  ENDIF.


* KNZ_USER_DUMMY
  CLEAR tmp_str.
  pname = 'KNZ_USER_DUMMY'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    default_data-knz_user_dummy = ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_user_dummy = tmp_str.
*   USER_DUMMY_KUNNR
    CLEAR tmp_str.
    pname = 'USER_DUMMY_KUNNR'.
    SELECT pwert FROM zcl_plint_cfg_00
      INTO tmp_str
      WHERE pname = pname
      .
    ENDSELECT.
    IF sy-subrc NE 0.
      default_data-user_dummy_kunnr = ''.
    ELSE.
      default_data-user_dummy_kunnr = tmp_str.
    ENDIF.

  ENDIF.

*DEFAULT_SATZANZAHL
  CLEAR tmp_str.
  pname = 'DEFAULT_SATZANZAHL'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-default_satzanzahl = 1.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '1' '' .
    wa-pwert = '1'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_satzanzahl = tmp_str.
  ENDIF.

*DEFAULT_DECKBLATT
  CLEAR tmp_str.
  pname = 'DEFAULT_DECKBLATT'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-default_deckblatt = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_deckblatt = tmp_str.
  ENDIF.

*DEFAULT_ENDEBLATT
  CLEAR tmp_str.
  pname = 'DEFAULT_ENDEBLATT'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-default_endeblatt = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_endeblatt = tmp_str.
  ENDIF.

*DEFAULT_FEHLBLATT
  CLEAR tmp_str.
  pname = 'DEFAULT_FEHLBLATT'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-default_fehlblatt = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_fehlblatt = tmp_str.
  ENDIF.

*DEFAULT_KNZ_INHALT_VZ
  CLEAR tmp_str.
  pname = 'DEFAULT_KNZ_INHALT_VZ'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-default_knz_inhalt_vz = 'NEIN'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'NEIN' '' .
    wa-pwert = 'NEIN'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_knz_inhalt_vz = tmp_str.
  ENDIF.

*DEFAULT_INHALTSBLATT
  CLEAR tmp_str.
  pname = 'DEFAULT_INHALTSBLATT'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-default_inhaltsblatt = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_inhaltsblatt = tmp_str.
  ENDIF.

*DELETE_TMP_SEARCH
  CLEAR tmp_str.
  pname = 'DELETE_TMP_SEARCH'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-delete_tmp_search = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-delete_tmp_search = tmp_str.
  ENDIF.

*READ_TMP_SEARCH
  CLEAR tmp_str.
  pname = 'READ_TMP_SEARCH'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-read_tmp_search = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-read_tmp_search = tmp_str.
  ENDIF.

*FREIGABE_STATUS
  CLEAR tmp_str.
  pname = 'FREIGABE_STATUS'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-freigabe_status = 'FR'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'FR' '' .
    wa-pwert = 'FR'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-freigabe_status = tmp_str.
  ENDIF.

*SPERR_STATUS
  CLEAR tmp_str.
  pname = 'SPERR_STATUS'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-sperr_status = 'SP'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SP' '' .
    wa-pwert = 'SP'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-sperr_status = tmp_str.
  ENDIF.

*EXCP_LED
  CLEAR tmp_str.
  pname = 'EXCP_LED'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
*    MESSAGE e052(zcl_plint_tools)
*      WITH 'zcl_plint_cfg_00' pname
*      '' ''.
    default_data-excp_led = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-excp_led = tmp_str.
  ENDIF.

*STRATEGY
  CLEAR tmp_str.
  pname = 'STRATEGY'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'F' ''.
    default_data-strategy = 'F'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'F' '' .
    wa-pwert = 'F'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-strategy = tmp_str.
  ENDIF.

* KNZ_AUTO_PROCESS
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_PROCESS'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'space' ''.
    default_data-knz_auto_process = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_auto_process = tmp_str.
  ENDIF.

* SEARCHLIST_FILE
  CLEAR tmp_str.
  pname = 'SEARCHLIST_FILE'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'C:\temp\Searchlist.lst' ''.
    default_data-searchlist_file = 'C:\temp\Searchlist.lst'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'C:\temp\Searchlist.lst' '' .
    wa-pwert = 'C:\temp\Searchlist.lst'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-searchlist_file = tmp_str.
  ENDIF.

* PLOTLIST_FILE
  CLEAR tmp_str.
  pname = 'PLOTLIST_FILE'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'C:\temp\Plotlist.lst' ''.
    default_data-searchlist_file = 'C:\temp\Plotlist.lst'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'C:\temp\Plotlist.lst' ''.
    wa-pwert = 'C:\temp\Plotlist.lst'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-plotlist_file = tmp_str.
  ENDIF.

* DELETE_ITEM
  CLEAR tmp_str.
  pname = 'DELETE_ITEM'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '0' ''.
    default_data-delete_item = '0'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '=' '' .
    wa-pwert = '0'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-delete_item = tmp_str.
  ENDIF.

* DELETE_STATUS
  CLEAR tmp_str.
  pname = 'DELETE_STATUS'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '0' ''.
    default_data-delete_status = '0'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '0' '' .
    wa-pwert = '0'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-delete_status = tmp_str.
  ENDIF.

*KNZ_FORMAT_CHECKING
  CLEAR tmp_str.
  pname = 'KNZ_FORMAT_CHECKING'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '0' ''.
    default_data-knz_format_checking = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pwert = '0'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_format_checking = tmp_str.
  ENDIF.

* KNZ_USE_MERKMAL_FORMAT
  CLEAR tmp_str.
  pname = 'KNZ_USE_MERKMAL_FORMAT'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '0' ''.
    default_data-knz_use_merkmal_format = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_merkmal_format = tmp_str.
  ENDIF.

* knz_use_multipage
  CLEAR tmp_str.
  pname = 'KNZ_USE_MULTIPAGE'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '0' ''.
    default_data-knz_use_multipage = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_multipage = tmp_str.
  ENDIF.

* KNZ_ASK_BEFORE_LEAVE
  CLEAR tmp_str.
  pname = 'KNZ_ASK_BEFORE_LEAVE'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      '0' ''.
    default_data-knz_ask_before_leave = 'X'.
    PERFORM appl_log_write USING
      'W' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'X' '' .
    wa-pwert = 'X'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_ask_before_leave = tmp_str.
  ENDIF.

* KNZ_ASK_BEFORE_DELETE
  CLEAR tmp_str.
  pname = 'KNZ_ASK_BEFORE_DELETE'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'X' ''.
    default_data-knz_ask_before_delete = 'X'.
    PERFORM appl_log_write USING
      'W' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'X' '' .
    wa-pwert = 'X'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_ask_before_delete = tmp_str.
  ENDIF.

* KNZ_GET_MATERIAL
  CLEAR tmp_str.
  pname = 'KNZ_GET_MATERIAL'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'SPACE' ''.
    default_data-knz_get_material = ''.
    PERFORM appl_log_write USING
      'W' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_get_material = tmp_str.
  ENDIF.

* KNZ_USE_KOSTL
  CLEAR tmp_str.
  pname = 'KNZ_USE_KOSTL'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'SPACE' ''.
    default_data-knz_use_kostl = ''.
    PERFORM appl_log_write USING
      'W' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_kostl = tmp_str.
  ENDIF.

* VORGABE für Strg-Shift-F12
  CLEAR tmp_str.
  pname = 'VORGABE'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    default_data-vorgabe = ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-vorgabe = tmp_str.
  ENDIF.

* MAT_STATUS_EXC
  CLEAR tmp_str.
  pname = 'MAT_STATUS_EXC'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'SPACE' ''.
    default_data-mat_status_exc = ''.
    PERFORM appl_log_write USING
      'W' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' '' .
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mat_status_exc = tmp_str.
  ENDIF.

* TRENNZEICHEN
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_plint_cfg_00' pname
      'SPACE' ''.
    default_data-trennzeichen = ','.
    PERFORM appl_log_write USING
      'W' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname ',' '' .
    wa-pwert = ','.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-trennzeichen = tmp_str.
  ENDIF.

* MAT_STATUS_ICON
  CLEAR tmp_str.
  pname = 'MAT_STATUS_ICON'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    default_data-mat_status_icon = '@0W@'.
    wa-pwert = '@0W@'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mat_status_icon = tmp_str.
  ENDIF.

* FEHLBLATT_ICON
  CLEAR tmp_str.
  pname = 'FEHLBLATT_ICON'.
  SELECT pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    default_data-fehlblatt_icon = '@BA@'.
    wa-pwert = '@BA@'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-fehlblatt_icon = tmp_str.
  ENDIF.

* KNZ_DOWN_FILES_DEL
  CLEAR tmp_str.
  pname = 'KNZ_DOWN_FILES_DEL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_down_files_del = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_down_files_del = tmp_str.
  ENDIF.

* KNZ_USE_CHECKED_IN
  CLEAR tmp_str.
  pname = 'KNZ_USE_CHECKED_IN'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_checked_in = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_checked_in = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-spez_dok_icon = '@BA@'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname '@BA@' ''.
    wa-pwert = '@BA@'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-spez_dok_icon = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_STUECKLIST
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_STUECKLIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-spez_dok_icon_stuecklist = default_data-spez_dok_icon.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname default_data-spez_dok_icon ''.
    wa-pwert = default_data-spez_dok_icon.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-spez_dok_icon_stuecklist = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_FOLGE
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_FOLGE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-spez_dok_icon_folge = default_data-spez_dok_icon.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname default_data-spez_dok_icon ''.
    wa-pwert = default_data-spez_dok_icon.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-spez_dok_icon_folge = tmp_str.
  ENDIF.

* SPEZ_DOK_ICON_VORGANG
  CLEAR tmp_str.
  pname = 'SPEZ_DOK_ICON_VORGANG'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-spez_dok_icon_vorgang = default_data-spez_dok_icon.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname default_data-spez_dok_icon ''.
    wa-pwert = default_data-spez_dok_icon.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-spez_dok_icon_vorgang = tmp_str.
  ENDIF.

* KNZ_USE_NEW_CLF_TYPE
  CLEAR tmp_str.
  pname = 'KNZ_USE_NEW_CLF_TYPE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_new_clf_type = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname 'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_new_clf_type = tmp_str.
  ENDIF.

* USER_GROUP_WSAPP_SELECTION
  CLEAR tmp_str.
  pname = 'USER_GROUP_WSAPP_SELECTION'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-user_group_wsapp_selection =
      c_user_group_wsapp_selection.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      c_user_group_wsapp_selection ''.
    wa-pwert = c_user_group_wsapp_selection.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-user_group_wsapp_selection = tmp_str.
  ENDIF.

* SPEICHER_ORT_FB_LISTE
  CLEAR tmp_str.
  pname = 'SPEICHER_ORT_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-speicher_ort_fb_liste =
      'C:\fb_liste.txt'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'c:\fb_liste.txt' ''.
    wa-pwert = 'c:\temp\fb_liste.txt'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-speicher_ort_fb_liste = tmp_str.
  ENDIF.

* KNZ_STATIC_FB_LISTE
  CLEAR tmp_str.
  pname = 'KNZ_STATIC_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_static_fb_liste = 'X'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'X' ''.
    wa-pwert = 'X'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_static_fb_liste = tmp_str.
  ENDIF.

* TRENNZEICHEN_FB_LISTE
  CLEAR tmp_str.
  pname = 'TRENNZEICHEN_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-trennzeichen_fb_liste = ';'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      ';' ''.
    wa-pwert = ';'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-trennzeichen_fb_liste = tmp_str.
  ENDIF.

* KNZ_DIALOG_FB_LISTE
  CLEAR tmp_str.
  pname = 'KNZ_DIALOG_FB_LISTE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_dialog_fb_liste = 'X'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'X' ''.
    wa-pwert = 'X'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_dialog_fb_liste = tmp_str.
  ENDIF.

* KNZ_ANMELDUNG_AM_SERVER
  CLEAR tmp_str.
  pname = 'KNZ_ANMELDUNG_AM_SERVER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_anmeldung_am_server = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_anmeldung_am_server = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-anmeldestring_server = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-anmeldestring_server = tmp_str.
  ENDIF.


* KNZ_USE_CONVERTE
  CLEAR tmp_str.
  SELECT knz_use_converte
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'c:\temp\' ''.
    default_data-knz_use_converte = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-knz_use_converte 'SPACE' '' .
  ELSE.
    default_data-knz_use_converte = tmp_str.
  ENDIF.

* CONVERTER_NAME
  CLEAR tmp_str.
  SELECT converter_name
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'SPACE' ''.
    default_data-converter_name = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-converter_name 'SPACE' '' .
  ELSE.
    default_data-converter_name = tmp_str.
  ENDIF.

* CONVERTER_NUMBER
  CLEAR tmp_str.
  SELECT converter_number
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'SPACE' ''.
    default_data-converter_number = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-converter_number 'SPACE' '' .
  ELSE.
    default_data-converter_number = tmp_str.
  ENDIF.

* KNZ_AUTO_FAUF
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_FAUF'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_auto_fauf = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_auto_fauf = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_FAUF
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_FAUF'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_verteiler_fauf = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler_fauf = tmp_str.
  ENDIF.

* KNZ_ALV_PATCH
  CLEAR tmp_str.
  pname = 'KNZ_ALV_PATCH'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_alv_patch = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_alv_patch = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER_VORHER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER_VORHER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-anmeldestring_server_vorher = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-anmeldestring_server_vorher = tmp_str.
  ENDIF.

* ANMELDESTRING_SERVER_NACHHER
  CLEAR tmp_str.
  pname = 'ANMELDESTRING_SERVER_NACHHER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-anmeldestring_server_nachher = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-anmeldestring_server_nachher = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_check_dis = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_check_dis = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS_CLASS
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS_CLASS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_check_dis_class = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_check_dis_class = tmp_str.
  ENDIF.

* KNZ_CHECK_DIS_DOKAR
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_DIS_DOKAR'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_check_dis_dokar = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_check_dis_dokar = tmp_str.
  ENDIF.

* USE_FILTER
  CLEAR tmp_str.
  pname = 'USE_FILTER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-use_filter = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-use_filter = tmp_str.
  ENDIF.

* FTP_DESTINATION
  CLEAR tmp_str.
  SELECT ftp_destination
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'SPACE' ''.
    default_data-ftp_destination = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' 'default_data-FTP_DESTINATION' 'SPACE' '' .
  ELSE.
    default_data-ftp_destination = tmp_str.
  ENDIF.


* FTP_USER
  CLEAR tmp_str.
  SELECT ftp_user
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'SPACE' ''.
    default_data-ftp_user = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-default_nutzer 'SPACE' '' .
  ELSE.
    default_data-ftp_user = tmp_str.
  ENDIF.

* FTP_PASSWD
  CLEAR tmp_str.
  SELECT ftp_passwd
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'SPACE' ''.
    default_data-ftp_passwd = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-default_nutzer 'SPACE' '' .
  ELSE.
    default_data-ftp_passwd = tmp_str.
  ENDIF.

* FTP_DOWN
  CLEAR tmp_str.
  SELECT ftp_down
    FROM zcl_preprozessor
    INTO tmp_str
    WHERE preprozessor IN
    (  select PREPROZESSOR
         from ZCL_PREPROZ_USER
         WHERE uname = default_data-default_nutzer
         AND status = c_status_aktiv
    ).
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE s057(zcl_plint_tools)
      WITH 'zcl_preprozessor' default_data-default_nutzer
      'SPACE' ''.
    default_data-ftp_down = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_preprozessor' default_data-default_nutzer 'SPACE' '' .
  ELSE.
    default_data-ftp_down = tmp_str.
  ENDIF.

* KNZ_USE_NEW_ROLES
  CLEAR tmp_str.
  pname = 'KNZ_USE_NEW_ROLES'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_new_roles = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_new_roles = tmp_str.
  ENDIF.

* KNZ_USE_ADMIN_MODULE
  CLEAR tmp_str.
  pname = 'KNZ_USE_ADMIN_MODULE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_admin_module = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_admin_module = tmp_str.
  ENDIF.

* KNZ_MAKE_ID_PLOTJOB
  CLEAR tmp_str.
  pname = 'KNZ_MAKE_ID_PLOTJOB'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_make_id_plotjob = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_make_id_plotjob = tmp_str.
  ENDIF.

* PREPROCESSOR
  CLEAR tmp_str.
  SELECT SINGLE preprozessor FROM zcl_preproz_user
    INTO tmp_str
    WHERE uname = default_data-default_nutzer
    AND status = c_status_aktiv
    .
  IF sy-subrc NE 0.
  ELSE.
    default_data-preprocessor = tmp_str.
  ENDIF.

* ADMIN_ALV_VAR
  CLEAR tmp_str.
  pname = 'ADMIN_ALV_VAR'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-admin_alv_var = ' '.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-admin_alv_var = tmp_str.
  ENDIF.

* TRANS_CV01N
  CLEAR tmp_str.
  pname = 'TRANS_CV01N'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-trans_cv01n = 'CV01N'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'CV01N' ''.
    wa-pwert = 'CV01N'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-trans_cv01n = tmp_str.
  ENDIF.

* TRANS_CV01N_SKIP_FIRST_SCREEN
  CLEAR tmp_str.
  pname = 'TRANS_CV01N_SKIP_FIRST_SCREEN'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-trans_cv01n = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-trans_cv01n_skip_first_screen = tmp_str.
  ENDIF.

* KNZ_AUTO_CS
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_CS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_auto_cs = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_auto_cs = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_CS
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_CS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_verteiler_cs = text-050.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      text-050 ''.
    wa-pwert = text-050.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler_cs = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_DOK_VERTEIL
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_DOK_VERTEIL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_verteiler_dok_verteil = text-052.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      text-052 ''.
    wa-pwert = text-052.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler_dok_verteil = tmp_str.
  ENDIF.

* KNZ_VIEW_DRAW_DETAIL
  CLEAR tmp_str.
  pname = 'KNZ_VIEW_DRAW_DETAIL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_view_draw_detail = 'X'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'X' ''.
    wa-pwert = 'X'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_view_draw_detail = tmp_str.
  ENDIF.

* KNZ_VIEW_STRUC_PLOTLIST
  CLEAR tmp_str.
  pname = 'KNZ_VIEW_STRUC_PLOTLIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_view_struc_plotlist = 'X'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'X' ''.
    wa-pwert = 'X'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_view_struc_plotlist = tmp_str.
  ENDIF.

* KNZ_USE_PLOT_RIGHT_1
  CLEAR tmp_str.
  pname = 'KNZ_USE_PLOT_RIGHT_1'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_plot_right_1 = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_plot_right_1 = tmp_str.
  ENDIF.

* KNZ_AUDIT_TRAIL
  CLEAR tmp_str.
  pname = 'KNZ_AUDIT_TRAIL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_audit_trail = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_audit_trail = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_DOK
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_DOK'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_verteiler_dok = text-053.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      text-052 ''.
    wa-pwert = text-053.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler_dok = tmp_str.
  ENDIF.

* KNZ_AUTO_DOK
  CLEAR tmp_str.
  pname = 'KNZ_AUTO_DOK'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_auto_dok = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_auto_dok = tmp_str.
  ENDIF.

* 2D_DERIVATION_LIST
  CLEAR tmp_str.
  pname = '2D_DERIVATION_LIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-2d_derivation_list = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-2d_derivation_list = tmp_str.
  ENDIF.

* KNZ_CHECK_EBELN
  CLEAR tmp_str.
  pname = 'KNZ_CHECK_EBELN'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_check_ebeln = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_check_ebeln = tmp_str.
  ENDIF.

* CHECK_EBELN_STRATEGY
  CLEAR tmp_str.
  pname = 'CHECK_EBELN_STRATEGY'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-check_ebeln_strategy = 'I'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'I' ''.
    wa-pwert = 'I'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-check_ebeln_strategy = tmp_str.
  ENDIF.

* SMARTFORM_CS02	
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS02'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_cs02 = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_cs02 = tmp_str.
  ENDIF.

* SMARTFORM_CS11	
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS11'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_cs11 = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_cs11 = tmp_str.
  ENDIF.

* SMARTFORM_CS12	
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS12'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_cs12 = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_cs12 = tmp_str.
  ENDIF.

* SMARTFORM_CS13
  CLEAR tmp_str.
  pname = 'SMARTFORM_CS13'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_cs13 = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_cs13 = tmp_str.
  ENDIF.

* MAT_CAPID	
  CLEAR tmp_str.
  pname = 'MAT_CAPID'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_capid = 'PP01'.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'PP01' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mat_capid = tmp_str.
  ENDIF.

* MAT_STPST	
  CLEAR tmp_str.
  pname = 'MAT_STPST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_stpst = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mat_stpst = tmp_str.
  ENDIF.

* MAT_DOKAR_PRIO_LIST
  CLEAR tmp_str.
  pname = 'MAT_DOKAR_PRIO_LIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_dokar_prio_list = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mat_dokar_prio_list = tmp_str.
  ENDIF.

* MAT_TDDEST	
  CLEAR tmp_str.
  pname = 'MAT_TDDEST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_tddest = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mat_tddest = tmp_str.
  ENDIF.

* MAT_TDPRINTER
  CLEAR tmp_str.
  pname = 'MAT_TDPRINTER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_tdprinter = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mat_tdprinter = tmp_str.
  ENDIF.

* KNZ_USE_STAMP_BEFORE_VIEW
  CLEAR tmp_str.
  pname = 'KNZ_USE_STAMP_BEFORE_VIEW'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_stamp_before_view = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_stamp_before_view = tmp_str.
  ENDIF.

* STAMP_PROGRAM
  CLEAR tmp_str.
  pname = 'STAMP_PROGRAM'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_program = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_program = tmp_str.
  ENDIF.

* STAMP_PARAMETER
  CLEAR tmp_str.
  pname = 'STAMP_PARAMETER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_parameter = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_parameter = tmp_str.
  ENDIF.

* KNZ_USE_STAMP_CALL_RFC
  CLEAR tmp_str.
  pname = 'KNZ_USE_STAMP_CALL_RFC'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_stamp_call_rfc = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_stamp_call_rfc = tmp_str.
  ENDIF.

* STAMP_RFC_DESTINATION
  CLEAR tmp_str.
  pname = 'STAMP_RFC_DESTINATION'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_rfc_destination = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_rfc_destination = tmp_str.
  ENDIF.


* STAMP_FTP_DESTINATION
  CLEAR tmp_str.
  pname = 'STAMP_FTP_DESTINATION'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_ftp_destination = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_ftp_destination = tmp_str.
  ENDIF.

* STAMP_FTP_USER
  CLEAR tmp_str.
  pname = 'STAMP_FTP_USER'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_ftp_user = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_ftp_user = tmp_str.
  ENDIF.

* STAMP_FTP_PASSWD
  CLEAR tmp_str.
  pname = 'STAMP_FTP_PASSWD'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_ftp_passwd = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_ftp_passwd = tmp_str.
  ENDIF.

* STAMP_FTP_VERZEICHNIS
  CLEAR tmp_str.
  pname = 'STAMP_FTP_VERZEICHNIS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_ftp_verzeichnis = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_ftp_verzeichnis = tmp_str.
  ENDIF.

* STAMP_DELAY
  CLEAR tmp_str.
  pname = 'STAMP_DELAY'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-stamp_delay = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-stamp_delay = tmp_str.
  ENDIF.

* KNZ_PLOT_LOG
  CLEAR tmp_str.
  pname = 'KNZ_PLOT_LOG'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_plot_log = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_plot_log = tmp_str.
  ENDIF.

* BOM_DATUV
  CLEAR tmp_str.
  pname = 'BOM_DATUV'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-bom_datuv = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      '99991230' ''.
    wa-pwert = '99991230'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-bom_datuv = tmp_str.
  ENDIF.

* KNZ_USE_VERT_RIGHTS
  CLEAR tmp_str.
  pname = 'KNZ_USE_VERT_RIGHTS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_vert_rights = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_vert_rights = tmp_str.
  ENDIF.

* KNZ_CLF_COMMIT	
  CLEAR tmp_str.
  pname = 'KNZ_CLF_COMMIT'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_clf_commit = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_clf_commit = tmp_str.
  ENDIF.

* CLF_WAIT_TIME	
  CLEAR tmp_str.
  pname = 'CLF_WAIT_TIME'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-clf_wait_time = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = '0'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-clf_wait_time = tmp_str.
  ENDIF.

* KNZ_COPY_ORIGINAL
  CLEAR tmp_str.
  pname = 'KNZ_COPY_ORIGINAL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_copy_original = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_copy_original = tmp_str.
  ENDIF.

* KNZ_SINGLE_ENTRY
  CLEAR tmp_str.
  pname = 'KNZ_SINGLE_ENTRY'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_single_entry = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_single_entry = tmp_str.
  ENDIF.

* KNZ_CREATE_TOC
  CLEAR tmp_str.
  pname = 'KNZ_CREATE_TOC'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_create_toc = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_create_toc = tmp_str.
  ENDIF.

* KNZ_SEND_TOC
  CLEAR tmp_str.
  pname = 'KNZ_SEND_TOC'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_send_toc = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_send_toc = tmp_str.
  ENDIF.

* KNZ_EBELN_EXPRESSMAIL
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_EXPRESSMAIL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_ebeln_expressmail = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_ebeln_expressmail = tmp_str.
  ENDIF.

* KNZ_EBELN_POS
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_POS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_ebeln_pos = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_ebeln_pos = tmp_str.
  ENDIF.


* KNZ_EBELN_MAT
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_MAT'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_ebeln_mat = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_ebeln_mat = tmp_str.
  ENDIF.


* KNZ_EBELN_BOM
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_BOM'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_ebeln_bom = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_ebeln_bom = tmp_str.
  ENDIF.

* KNZ_EBELN_DIALOG
  CLEAR tmp_str.
  pname = 'KNZ_EBELN_DIALOG'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_ebeln_dialog = ''.
    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_ebeln_dialog = tmp_str.
  ENDIF.


* DEFAULT_VERTEILER_EBELN
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_EBELN'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_verteiler_ebeln = ''.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      text-020 ''.
    wa-pwert = text-020.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler_ebeln = tmp_str.
  ENDIF.

* DEFAULT_VERTEILER_VBELN
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_VBELN'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_verteiler_vbeln = ''.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      text-020 ''.
    wa-pwert = text-020.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler_vbeln = tmp_str.
  ENDIF.


* KNZ_VBELN_EXPRESSMAIL
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_EXPRESSMAIL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_vbeln_expressmail = ''.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_vbeln_expressmail = tmp_str.
  ENDIF.

* KNZ_VBELN_POS
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_POS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_vbeln_pos = ''.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_vbeln_pos = tmp_str.
  ENDIF.

* KNZ_VBELN_MAT
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_MAT'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_vbeln_mat = ''.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_vbeln_mat = tmp_str.
  ENDIF.

* KNZ_VBELN_BOM
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_BOM'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_vbeln_bom = ''.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_vbeln_bom = tmp_str.
  ENDIF.

* KNZ_VBELN_DIALOG
  CLEAR tmp_str.
  pname = 'KNZ_VBELN_DIALOG'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_vbeln_dialog = ''.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_vbeln_dialog = tmp_str.
  ENDIF.

* SEPARATOR_DIS
  CLEAR tmp_str.
  pname = 'SEPARATOR_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-separator_dis = text-055.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-055.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-separator_dis = tmp_str.
  ENDIF.

* MDR_FLAG_NAME	
  CLEAR tmp_str.
  pname = 'MDR_FLAG_NAME'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mdr_flag_name = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mdr_flag_name = tmp_str.
  ENDIF.

* MDR_FLAG_VAL	
  CLEAR tmp_str.
  pname = 'MDR_FLAG_VAL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mdr_flag_val = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mdr_flag_val = tmp_str.
  ENDIF.

* TR_FLAG_NAME	
  CLEAR tmp_str.
  pname = 'TR_FLAG_NAME'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-tr_flag_name = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-tr_flag_name = tmp_str.
  ENDIF.

* TR_FLAG_VAL	
  CLEAR tmp_str.
  pname = 'TR_FLAG_VAL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-tr_flag_val = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-tr_flag_val = tmp_str.
  ENDIF.

* SMARTFORM_MDR	
  CLEAR tmp_str.
  pname = 'SMARTFORM_MDR'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_mdr = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_mdr = tmp_str.
  ENDIF.

* SMARTFORM_TR	
  CLEAR tmp_str.
  pname = 'SMARTFORM_TR'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_tr = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_tr = tmp_str.
  ENDIF.

* TOC_DIS
  CLEAR tmp_str.
  pname = 'TOC_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-toc_dis = text-057.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-057.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-toc_dis = tmp_str.
  ENDIF.

* SRC_FLAG_NAME
  CLEAR tmp_str.
  pname = 'SRC_FLAG_NAME'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-src_flag_name = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-src_flag_name = tmp_str.
  ENDIF.

* SRC_FLAG_VAL	
  CLEAR tmp_str.
  pname = 'SRC_FLAG_VAL'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-src_flag_val = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-src_flag_val = tmp_str.
  ENDIF.

* SRC_FLAG_NAME_2	
  CLEAR tmp_str.
  pname = 'SRC_FLAG_NAME_2	'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-src_flag_name_2 = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-src_flag_name_2 = tmp_str.
  ENDIF.

* SRC_FLAG_VAL_2	
  CLEAR tmp_str.
  pname = 'SRC_FLAG_VAL_2'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-src_flag_val_2 = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-src_flag_val_2 = tmp_str.
  ENDIF.


* DEFAULT_VERTEILER_MDR
  CLEAR tmp_str.
  pname = 'DEFAULT_VERTEILER_MDR'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-default_verteiler_mdr = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-default_verteiler_mdr = tmp_str.
  ENDIF.

* EASYDMS_FOLDER_TYPE
  CLEAR tmp_str.
  pname = 'EASYDMS_FOLDER_TYPE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-easydms_folder_type = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-easydms_folder_type = tmp_str.
  ENDIF.

* STORAGE_CAT_TR
  CLEAR tmp_str.
  pname = 'STORAGE_CAT_TR'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-storage_cat_tr = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-storage_cat_tr = tmp_str.
  ENDIF.


* STORAGE_DIS_TR
  CLEAR tmp_str.
  pname = 'STORAGE_DIS_TR'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-storage_dis_tr = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-storage_dis_tr = tmp_str.
  ENDIF.

* SMARTFORM_MATLIST
  CLEAR tmp_str.
  pname = 'SMARTFORM_MATLIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_matlist = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_matlist = tmp_str.
  ENDIF.

* SMARTFORM_DOCLIST
  CLEAR tmp_str.
  pname = 'SMARTFORM_DOCLIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-smartform_doclist = text-056.

    PERFORM appl_log_write USING
      'E' '057' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-smartform_doclist = tmp_str.
  ENDIF.

* MDR_DIS
  CLEAR tmp_str.
  pname = 'MDR_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mdr_dis = text-058.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-058.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-mdr_dis = tmp_str.
  ENDIF.

* NOTE_DIS
  CLEAR tmp_str.
  pname = 'NOTE_DIS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-note_dis = text-060.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-060.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-note_dis = tmp_str.
  ENDIF.

* NOTE_DIR_STORAGE
  CLEAR tmp_str.
  pname = 'NOTE_DIR_STORAGE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-note_dir_storage = text-060.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-060.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-note_dir_storage = tmp_str.
  ENDIF.

* VFTEMPLATE
  CLEAR tmp_str.
  pname = 'VFTEMPLATE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-vftemplate = text-056.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-vftemplate = tmp_str.
  ENDIF.

* VFTEMPLATE_TOC
  CLEAR tmp_str.
  pname = 'VFTEMPLATE_TOC'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-vftemplate_toc = text-056.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = text-056.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-vftemplate_toc = tmp_str.
  ENDIF.

* KNZ_WSA_TO_PLOTLIST
  CLEAR tmp_str.
  pname = 'KNZ_WSA_TO_PLOTLIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_wsa_to_plotlist = 'I'.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'I' ''.
    wa-pwert = 'I'.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_wsa_to_plotlist = tmp_str.
  ENDIF.

* PRIO_WSA_TO_PLOTLIST
  CLEAR tmp_str.
  pname = 'PRIO_WSA_TO_PLOTLIST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-prio_wsa_to_plotlist = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-prio_wsa_to_plotlist = tmp_str.
  ENDIF.

* KNZ_WSA_TO_PLOTLIST_CHECK_FILE
  CLEAR tmp_str.
  pname = 'KNZ_WSA_TO_PLOTLIST_CHECK_FILENAME'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_wsa_to_plotlist_check_file = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_wsa_to_plotlist_check_file = tmp_str.
  ENDIF.

* KNZ_ME_SEP
  CLEAR tmp_str.
  pname = 'KNZ_ME_SEP'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_me_sep = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_me_sep = tmp_str.
  ENDIF.

* KNZ_SD_SEP
  CLEAR tmp_str.
  pname = 'KNZ_SD_SEP'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_sd_sep = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_sd_sep = tmp_str.
  ENDIF.

* KNZ_PL_NO_DOUBLE
  CLEAR tmp_str.
  pname = 'KNZ_PL_NO_DOUBLE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_pl_no_double = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_pl_no_double = tmp_str.
  ENDIF.

* KNZ_LINKS
  CLEAR tmp_str.
  pname = 'KNZ_LINKS'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_links = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_links = tmp_str.
  ENDIF.

* KNZ_WHERE_USED
  CLEAR tmp_str.
  pname = 'KNZ_WHERE_USED'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_where_used = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_where_used = tmp_str.
  ENDIF.

* KNZ_DELETE_DUPLICATES
  CLEAR tmp_str.
  pname = 'KNZ_PL_NO_DOUBLE'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_pl_no_double = ''.

    PERFORM appl_log_write USING
      'E' '058' 'ZCL_PLINT_TOOLS'
      'zcl_plint_cfg_00' pname
      'SPACE' ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_pl_no_double = tmp_str.
  ENDIF.




* Rückgabe
  o_default_data = default_data.


ENDFUNCTION.
