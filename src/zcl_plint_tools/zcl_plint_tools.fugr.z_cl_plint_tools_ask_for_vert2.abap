FUNCTION z_cl_plint_tools_ask_for_vert2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  SY-UNAME
*"     VALUE(I_DEFAULT_NUTZER) TYPE  SY-UNAME
*"     VALUE(I_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  EXPORTING
*"     VALUE(O_VERTEILER) TYPE  ZCL_NAME_VERTEILER
*"  EXCEPTIONS
*"      ERROR
*"      FORGET
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 28.09.2004 - Kopie
* 20.06.2005 - Anpassung auf KNZ_USE_VERT_RIGHTS
*              Rechte auf Verteiler
*-----------------------------------------------------------------------

  DATA: user_data TYPE /cideon/plot_userdata.

  CLEAR user_data.
  user_data = i_user_data.

  CLEAR ask_verteiler.

  uname = i_uname.
  default_nutzer = i_default_nutzer.


  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
  DATA: uname_prepro TYPE xubname.
  DATA: wa_tmp_preproz_user TYPE zcl_preproz_user.
* F4 Help.

  SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
    WHERE uname = uname
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
        FIELD default_nutzer.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET'
        FIELD uname_prepro.
    ENDIF.
  ELSE.
    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD uname.
  ENDIF.


  tmp_sy_repid = sy-repid.


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

* testen, ob für die verteiler überhaupt die berechtigungen
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
  ELSE.
    LOOP AT itab_ret INTO wa_ret.
    ENDLOOP.

    ask_verteiler = wa_ret-fieldval.
  ENDIF.

  IF ask_verteiler IS INITIAL.
    RAISE forget.
  ELSE.
  ENDIF.

  o_verteiler = ask_verteiler.


ENDFUNCTION.
