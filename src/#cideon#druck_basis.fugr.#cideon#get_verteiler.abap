FUNCTION /cideon/get_verteiler.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"       OPTIONAL
*"  TABLES
*"      ET_VERTEILER STRUCTURE  ZCL_V_PRE_US_VER
*"----------------------------------------------------------------------
* 7.0.166.1
* 2012/11/01 CKR
* Übergabe von Struktur DEFAULT_DATA, um auf korrekten Daten zu
* arbeiten

  IF is_default_data IS INITIAL.
    "nichts tun
  ELSE.
    "Übergabe
    default_data = is_default_data.
  ENDIF.


  CLEAR et_verteiler[].

  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
  DATA: uname_prepro TYPE xubname.
  DATA: wa_tmp_preproz_user TYPE zcl_preproz_user.

* F4 Help.
  DATA: tmp_sy_repid LIKE sy-repid.

  IF wa_akt_plotjobs-uname IS INITIAL.
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
      WHERE uname = wa_akt_plotjobs-uname
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
      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD wa_akt_plotjobs-uname.
    ENDIF.
  ENDIF.

  tmp_sy_repid = sy-repid.

*  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
*       EXPORTING
*            tabname     = 'ZCL_S_PLOTLIST'
*            fieldname   = 'VERTEILER'
*            dynpprog    = tmp_sy_repid
*            dynpnr      = sy-dynnr
*            dynprofield = 'WA_PLOTJOBS-VERTEILER'.

*  f_f4_voreinstellung = 'X'.

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

  SORT itab_data BY preprozessor verteiler .



  et_verteiler[] = itab_data[].


ENDFUNCTION.
