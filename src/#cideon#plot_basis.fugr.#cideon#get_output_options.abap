FUNCTION /cideon/get_output_options.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_USER) TYPE  SY-UNAME OPTIONAL
*"  EXPORTING
*"     VALUE(O_SCAN_PATH) TYPE  /CIDEON/PLOT_USERDATA-CLF_DOWN_PATH
*"     VALUE(O_DOWNLOAD_PATH) TYPE  /CIDEON/PLOT_USERDATA-DOWN_PATH
*"     VALUE(O_OM_DEVICE) TYPE  ZCL_NAME_VERTEILER
*"  EXCEPTIONS
*"      CANCEL
*"----------------------------------------------------------------------
* CIDEON SAP / OM
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
*
***********************************************************************
* Journal
* 24.10.2008 - Erstellung / Kopie
* 27.10.2008 - weitere Bearbeitung
*
***********************************************************************

  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
  DATA: wa_tmp_preproz_user TYPE zcl_preproz_user.
  DATA: uname_prepro TYPE xubname.
* F4 Help.


  "Einstellungen lesen
  DATA: user_data TYPE /cideon/plot_userdata. "t_userdata.
  DATA: default_data TYPE /cideon/plot_defaultdata. "t_defaultdata.

  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = ''
       IMPORTING
            o_default_data = default_data.

  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = default_data
       IMPORTING
            o_user_data    = user_data.



  IF i_user IS INITIAL.
    SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
      WHERE uname = sy-uname
      AND status = c_status_aktiv
      .
    IF sy-subrc NE 0.
*     Testen, ob eine Zuordnung über eine Rolle vorliegt
      CLEAR uname_prepro.
      CALL FUNCTION '/CIDEON/CHECK_ROLES_FOR_USER'
           EXPORTING
                i_uname        = sy-uname
           IMPORTING
                o_uname_prepro = uname_prepro
           EXCEPTIONS
                no_role        = 1
                error          = 2
                OTHERS         = 3.
      IF sy-subrc <> 0.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD default_data-default_nutzer.
      ELSE.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD uname_prepro.
      ENDIF.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD sy-uname.
    ENDIF.
  ELSE.
    SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
      WHERE uname = i_user
      AND status = c_status_aktiv
      .
    IF sy-subrc NE 0.
*     Testen, ob eine Zuordnung über eine Rolle vorliegt
      CLEAR uname_prepro.
      CALL FUNCTION '/CIDEON/CHECK_ROLES_FOR_USER'
           EXPORTING
                i_uname        = sy-uname
           IMPORTING
                o_uname_prepro = uname_prepro
           EXCEPTIONS
                no_role        = 1
                error          = 2
                OTHERS         = 3.
      IF sy-subrc <> 0.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD default_data-default_nutzer.
      ELSE.
        SET PARAMETER ID 'ZCL_UNAME_GET'
          FIELD uname_prepro.
      ENDIF.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD i_user.
    ENDIF.
  ENDIF.

  "tmp_sy_repid = sy-repid.


* ZCL_V_PRE_US_VER
  DATA: itab_data TYPE TABLE OF zcl_v_pre_us_ver.
  DATA: itab_ret TYPE TABLE OF ddshretval.
  DATA: wa_ret TYPE ddshretval.
  DATA: wa_data TYPE zcl_v_pre_us_ver.
  DATA: tmp_get_uname TYPE xubname.

  CLEAR tmp_get_uname.
  GET PARAMETER ID 'ZCL_UNAME_GET' FIELD tmp_get_uname.

  SELECT * FROM zcl_v_pre_us_ver INTO TABLE itab_data
    WHERE uname = tmp_get_uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Testen, ob für die Verteiler überhaupt die Berechtigungen
* vorliegen
* Parameter: KNZ_USE_VERT_RIGHTS
  IF user_data-knz_use_vert_rights = 'X'.
    DATA: index_data TYPE i.
    CLEAR index_data.
    LOOP AT itab_data INTO wa_data.
      index_data = sy-tabix.

      AUTHORITY-CHECK OBJECT 'ZCL_PLOTVT'
               ID 'ZCL_TA' FIELD 'ZCL_PLOT_INTERFACE'
               ID 'ZCL_NAMEVT' FIELD wa_data-verteiler.
      IF sy-subrc NE 0.
        DELETE itab_data INDEX index_data.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      ddic_structure         = 'ZCL_V_PRE_US_VER'
      retfield               = 'VERTEILER'
*           PVALKEY                = ' '
*           DYNPPROG               = ' '
*           DYNPNR                 = ' '
*           DYNPROFIELD            = ' '
*           STEPL                  = 0
*           WINDOW_TITLE           =
*           VALUE                  = ' '
      value_org              = 'S'
*           MULTIPLE_CHOICE        = ' '
*           DISPLAY                = ' '
*           CALLBACK_PROGRAM       = ' '
*           CALLBACK_FORM          = ' '
    TABLES
      value_tab              = itab_data
*           FIELD_TAB              =
      return_tab             = itab_ret
*           DYNPFLD_MAPPING        =
    EXCEPTIONS
      parameter_error        = 1
      no_values_found        = 2
      OTHERS                 = 3
            .

  IF itab_ret[] IS INITIAL.
    RAISE cancel.
  ELSE.
    READ TABLE itab_ret INTO wa_ret INDEX 1.
    IF sy-subrc NE 0.
      RAISE cancel.
    ELSE.
    ENDIF.

  ENDIF.

  o_scan_path = user_data-clf_down_path.
  o_download_path = user_data-down_path.
  o_om_device = wa_ret-fieldval.



ENDFUNCTION.
