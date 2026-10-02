class /CIDEON/CL_PLOT_FAUF_001 definition
  public
  inheriting from /CIDEON/CLA_PLOT_FAUF
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_FAUF_001
*"* do not include other source files here!!!
public section.

  methods EXECUTE
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_FAUF_001
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_FAUF_001
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_FAUF_001 IMPLEMENTATION.


METHOD execute.
* ...

  INCLUDE /cideon/_konstanten.

  "break kuechler.

  DATA: index TYPE i.
  DATA: answer(1).


  "Lesen der Dokumente zum Fertigungsauftrag

  DATA: lt_afdld TYPE TABLE OF afdld.
  DATA: lt_objects TYPE TABLE OF zcl_pdm_exp_objects.

  DATA: ls_objects TYPE zcl_pdm_exp_objects.
  DATA: ls_afdld TYPE afdld.

  DATA: aufnr TYPE aufnr.


  CLEAR aufnr.
  aufnr = gs_object.
  IF gs_object IS INITIAL.
    aufnr = gp_def_attrib.
  ELSE.
  ENDIF.

  CLEAR lt_afdld.

  CALL FUNCTION 'CO_DM_AFDLD_READ_KEY'
    EXPORTING
      i_aufnr        = aufnr
*     I_TYP          =
*     I_POSNR        =
*     I_AUFPL        =
*     I_APLZL        =
*     I_ZAEHL        =
    TABLES
      et_afdld       = lt_afdld
            .

  IF lt_afdld[] IS INITIAL.
    MESSAGE s001(/cideon/om_fertigung)
      WITH aufnr '' '' ''.
    EXIT.
  ELSE.
  ENDIF.


  "Dialog bringen
  DATA: default_data TYPE /cideon/plot_defaultdata.
  DATA: user_data TYPE /cideon/plot_userdata.

  CLEAR default_data.
  CLEAR user_data.
  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
       EXPORTING
            i_batch        = ''
       IMPORTING
            o_default_data = default_data.


  CLEAR user_data.
  user_data-uname = sy-uname.


  CALL FUNCTION '/CIDEON/READ_USERDATA'
       EXPORTING
            i_default_data = default_data
       IMPORTING
            o_user_data    = user_data.



  "Verteiler
  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
  DATA: wa_tmp_preproz_user TYPE zcl_preproz_user.
  DATA: uname_prepro TYPE xubname.
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

  DATA: tmp_sy_repid LIKE sy-repid.
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
    EXIT.
  ELSE.
    LOOP AT itab_ret INTO wa_ret.
    ENDLOOP.

  ENDIF.


  "experimentelles Programm

  DATA: lc_exp_program TYPE /cideon/exp_program.
  CLEAR lc_exp_program.

  DATA: returncode.
  DATA: lt_fields TYPE TABLE OF sval.
  DATA: ls_fields TYPE sval.

  CLEAR lt_fields.
  CLEAR ls_fields.

  ls_fields-tabname = '/CIDEON/PL_LOG'.
  ls_fields-fieldname = 'EXP_PROGRAM'.
  ls_fields-value = ''.
  APPEND ls_fields TO lt_fields.

  CLEAR returncode.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*           NO_VALUE_CHECK        = ' '
      popup_title           = 'Experimentelles Programm'(001)
*           START_COLUMN          = '5'
*           START_ROW             = '5'
    IMPORTING
      returncode            = returncode
    TABLES
      fields                = lt_fields
    EXCEPTIONS
      error_in_fields       = 1
      OTHERS                = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF returncode = 'A'.
    CLEAR lc_exp_program.
  ELSE.
    CLEAR ls_fields.
    READ TABLE lt_fields INTO ls_fields INDEX 1.
    lc_exp_program = ls_fields-value..
  ENDIF.


  "Übergabe der Charge
  "Tabelle AFPO benutzen
  DATA: ls_afpo TYPE afpo.
  CLEAR ls_afpo.
  SELECT SINGLE * FROM afpo
    INTO ls_afpo
    WHERE aufnr = aufnr
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* BADI für Chargenermittlung
* BADI
* /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND
  DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
  DATA: return TYPE bapiret2.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF badi_main_pre_001 IS INITIAL.
  ELSE.
    CALL METHOD badi_main_pre_001->chg_fauf_charge
       EXPORTING
         aufnr  = aufnr
      CHANGING
        charg  = ls_afpo-charg
        .
  ENDIF.


*
  CLEAR lt_objects.
  CLEAR ls_objects.

  LOOP AT lt_afdld INTO ls_afdld.
    CLEAR ls_objects.
    ls_objects-object_type = 'DOCUMENT'.

    ls_objects-dokar = ls_afdld-dokar.
    ls_objects-doknr = ls_afdld-doknr.
    ls_objects-doktl = ls_afdld-doktl.
    ls_objects-dokvr = ls_afdld-dokvr.

    ls_objects-verteiler = wa_ret-fieldval.

    "CKR 2007/10/15
    "MATNR
    ls_objects-matnr = ls_afpo-matnr.

    "AUFNR
    ls_objects-aufnr = aufnr.
    ls_objects-aufnr_pp = aufnr.

    "CHARGE
    ls_objects-charg = ls_afpo-charg.
    "ls_objects-charg = '0815'.

    "exp. Programm
    ls_objects-exp_program = lc_exp_program.

    "Drucktyp
    ls_objects-print_type = 'C'.

    APPEND ls_objects TO lt_objects.
  ENDLOOP.

*
  "Angabe des Grundes zum Nachdruck, falls Verbindung
  "FAUF und Dokument schon gedruck wurde
  "Suche -> Chargendruck
  DATA: ls_pl_log TYPE /cideon/pl_log.

  LOOP AT lt_objects INTO ls_objects.
    index = sy-tabix.

    CLEAR ls_pl_log.
    SELECT SINGLE * FROM /cideon/pl_log
      INTO ls_pl_log
      WHERE
      dokar = ls_objects-dokar
      AND doknr = ls_objects-doknr
      AND doktl = ls_objects-doktl
      AND dokvr = ls_objects-dokvr
      "AND filep = wa_tmp_plotjobs-filep
      "AND wsapplication = wa_tmp_plotjobs-wsapplication
      "AND recipient = wa_tmp_plotjobs-recipient
      AND print_type = 'C'
      AND aufnr = aufnr
      .
    IF sy-subrc NE 0.
      "nichts gefunden - noch nicht gedruckt
    ELSE.
      "Dialog für Grund des Nachdruckes bringen
      DATA: text255(255).
      CLEAR text255.
      CONCATENATE 'Chargendruck schon erfolgt! - Nachdruck? '
        ls_objects-dokar '/'
        ls_objects-doknr '/'
        ls_objects-doktl '/'
        ls_objects-dokvr '/'
        INTO text255.

      CLEAR answer.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar                    = 'Chargen Druck'(002)
*         DIAGNOSE_OBJECT             = ' '
          text_question               =
            "'Chargendruck schon erfolgt! - Nachdruck? '(002)
            text255
*          TEXT_BUTTON_1               = 'Ja'(001)
          icon_button_1               = 'ICON_OKAY'
*          TEXT_BUTTON_2               = 'Nein'(002)
          icon_button_2               = 'ICON_CANCEL'
*         DEFAULT_BUTTON              = '1'
          display_cancel_button       = ''
*         USERDEFINED_F1_HELP         = ' '
*         START_COLUMN                = 25
*         START_ROW                   = 6
*         POPUP_TYPE                  =
        IMPORTING
          answer                      = answer
*       TABLES
*         PARAMETER                   =
        EXCEPTIONS
          text_not_found              = 1
          OTHERS                      = 2
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF answer = '2'.
        "Löschen, des Eintrages
        DELETE lt_objects INDEX index.
        CONTINUE.
      ELSE.
      ENDIF.

      "Eingabefeld für Grund
      CLEAR lt_fields.
      CLEAR ls_fields.

      ls_fields-tabname = '/CIDEON/PL_LOG'.
      ls_fields-fieldname = 'PRINT_CAUSE'.
      ls_fields-value = 'Bitte Grund eingeben!'(004).
      APPEND ls_fields TO lt_fields.

      CLEAR returncode.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
*           NO_VALUE_CHECK        = ' '
          popup_title           = 'Grund des Chargennachdruckes'(005)
*           START_COLUMN          = '5'
*           START_ROW             = '5'
        IMPORTING
          returncode            = returncode
        TABLES
          fields                = lt_fields
        EXCEPTIONS
          error_in_fields       = 1
          OTHERS                = 2
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF returncode = 'A'.
        "Löschen, des Eintrages
        DELETE lt_objects INDEX index.
      ELSE.
        CLEAR ls_fields.
        READ TABLE lt_fields INTO ls_fields INDEX 1.
        IF ls_fields-value IS INITIAL.
          "Löschen, des Eintrages
          DELETE lt_objects INDEX index.
        ELSE.
          ls_objects-print_cause = ls_fields-value.
        ENDIF.

      ENDIF.

      ls_objects-print_type = 'F'.

      MODIFY lt_objects FROM ls_objects INDEX index.
    ENDIF.

  ENDLOOP.

  " keine Dokumente mehr vorhanden
  " break kuechler.

  IF lt_objects IS INITIAL.
    "Meldung und raus
    MESSAGE i001(/cideon/om_fertigung) WITH '' '' '' ''.
    EXIT.
  ELSE.
  ENDIF.


  "Übergabe an Druck
  CALL FUNCTION '/CIDEON/PSBRW_WRT_PSB_TMP_FRTA'
    TABLES
      i_itab_objects       = lt_objects
*   EXCEPTIONS
*     ERROR                = 1
*     OTHERS               = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.
  CALL TRANSACTION '/CIDEON/SPSO'.



ENDMETHOD.
ENDCLASS.
