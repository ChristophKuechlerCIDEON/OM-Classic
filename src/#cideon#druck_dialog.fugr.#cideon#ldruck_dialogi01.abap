*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  IF ok_code = 'ADD_RECIPI'.
    ok_code = 'ADD_RECIPIENT'.
  ELSE.
  ENDIF.

  g_f_code = ok_code.


  CASE ok_code.
    WHEN 'OK'.
      IF rb_k_d = 'X' OR rb_n_d = 'X'.
        IF lt_recipient[] IS INITIAL.
          MESSAGE w008(/cideon/druck_basis) WITH '' '' '' ''.
          "Angabe eines Empfängers notwendig & & & &
          EXIT.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.

      IF wa_akt_plotjobs-verteiler IS INITIAL.
        MESSAGE w009(/cideon/druck_basis) WITH '' '' '' ''.
        EXIT.
      ELSE.
      ENDIF.

      LEAVE TO SCREEN 0.
*      EXIT.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'TAB1'.
      tabstripcontrol_001-activetab = 'TAB1'.
    WHEN 'TAB2'.
      tabstripcontrol_001-activetab = 'TAB2'.
    WHEN 'TAB3'.
      tabstripcontrol_001-activetab = 'TAB3'.
    WHEN 'ADD_RECIPIENT'.
      IF wa_akt_plotjobs-recipient IS INITIAL.
      ELSE.
        ls_recipient-recipient = wa_akt_plotjobs-recipient.
        "Test ob Nutzername vorhanden ist
        DATA: ls_usr02 TYPE usr02.
        CLEAR ls_usr02.
        SELECT SINGLE * FROM usr02 INTO ls_usr02
          WHERE bname = ls_recipient-recipient
          .
        IF sy-subrc NE 0.
        ELSE.
          "Test, auf doppelte Einträge
          APPEND ls_recipient TO lt_recipient.
          SORT lt_recipient BY recipient.
          DELETE ADJACENT DUPLICATES FROM lt_recipient.
          PERFORM refresh_recipient.
        ENDIF.

        CLEAR wa_akt_plotjobs-recipient.
      ENDIF.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

ENDMODULE.                 " USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.

ENDMODULE.                 " USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*&      Module  verteiler  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verteiler INPUT.
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

*   saves the wa
    IF wa_akt_plotjobs IS INITIAL.
      EXIT.
    ELSE.
      IF NOT wa_akt_plotjobs-dokar IS INITIAL
        AND NOT wa_akt_plotjobs-doknr IS INITIAL
        AND NOT wa_akt_plotjobs-dokvr IS INITIAL
        AND NOT wa_akt_plotjobs-doktl IS INITIAL
        .

        wa_akt_plotjobs-verteiler = wa_ret-fieldval.

      ELSE.
      ENDIF.
    ENDIF.
  ENDIF.



ENDMODULE.                 " verteiler  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_values  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_values INPUT.
* Test der Seiten Intervalle
*   WA_AKT_PLOTJOBS-SEITE_VON
*   WA_AKT_PLOTJOBS-SEITE_VON

  IF ok_code = 'CANC'.
    EXIT.
  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_von
    CN ';,0123456789 '.
    CLEAR wa_akt_plotjobs-seite_von.
    CLEAR ok_code.
    MESSAGE e000(/cideon/druck_basis) WITH
      wa_akt_plotjobs-seite_von '' '' ''.

  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_bis
    CN ';,0123456789 '.
    CLEAR wa_akt_plotjobs-seite_bis.
    CLEAR ok_code.
    MESSAGE e000(/cideon/druck_basis) WITH
      wa_akt_plotjobs-seite_bis '' '' ''.

  ELSE.
  ENDIF.


  IF wa_akt_plotjobs-seite_von CA ';,'.
    CLEAR wa_akt_plotjobs-seite_bis.
  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_von IS INITIAL
    AND wa_akt_plotjobs-seite_bis IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  IF ( NOT wa_akt_plotjobs-seite_von IS INITIAL )
    AND wa_akt_plotjobs-seite_bis IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_von <= wa_akt_plotjobs-seite_bis .
    IF wa_akt_plotjobs-seite_von IS INITIAL.
      wa_akt_plotjobs-seite_von = 1.
    ELSE.
    ENDIF.
    EXIT.
  ELSE.
    CLEAR ok_code.
    MESSAGE e001(/cideon/druck_basis) WITH
      '' '' '' ''.
  ENDIF.





ENDMODULE.                 " check_values  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  IF alv_recipient IS INITIAL.
    CREATE OBJECT cont_alv_recipient
      EXPORTING
        container_name = 'CC_RECIPIENT'.
    IF sy-subrc <> 0.
      EXIT.
    ELSE.
    ENDIF.

    CREATE OBJECT alv_recipient
      EXPORTING
        i_parent = cont_alv_recipient.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ELSE.
    ENDIF.

*   Variant
    CLEAR recipient_s_variant.
    recipient_s_variant-report = '0103'."sy-repid.
    recipient_s_variant-username = sy-uname.

    CLEAR lc_tb_ex.
    lc_tb_ex = '&SUM'.
    APPEND lc_tb_ex TO it_tb_ex_recipient.
    lc_tb_ex = '&AUBTOT'.
    APPEND lc_tb_ex TO it_tb_ex_recipient.
    lc_tb_ex = '&AUF'.
    APPEND lc_tb_ex TO it_tb_ex_recipient.
    lc_tb_ex = '&INFO'.
    APPEND lc_tb_ex TO it_tb_ex_recipient.
    lc_tb_ex = '&MB_SUM'.
    APPEND lc_tb_ex TO it_tb_ex_recipient.

    CALL METHOD alv_recipient->set_table_for_first_display
      EXPORTING
        i_structure_name              = '/CIDEON/S_RECIPIENT'
        is_variant                    = recipient_s_variant
        is_layout                     = recipient_s_layo
        i_save                        = 'X'
        i_default                     = 'X'
        it_toolbar_excluding          = it_tb_ex_recipient
      CHANGING
        it_outtab                     = lt_recipient
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD alv_recipient->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.
    CALL METHOD alv_recipient->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2
          .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.


ENDMODULE.                 " STATUS_0103  OUTPUT
