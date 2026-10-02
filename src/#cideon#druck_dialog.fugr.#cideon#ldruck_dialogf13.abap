*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/LDRUCK_DIALOGF13                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_result_stamp_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_result_stamp_values.
* besorgt die resultierenden Stempeldaten, welche aus den normalen
* Stempelwerten und den Klassifizierungswerten gebildet werden können

  DATA: itab_res_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: wa_res_data TYPE zcl_s_stempel_value.
  DATA: wa_stempel_wert TYPE zcl_s_stempel_value..
*
*  CLEAR itab_class_data.

  CALL FUNCTION '/CIDEON/GET_RESULT_STAMP_DATA'
       EXPORTING
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            i_itab_stamp_data = itab_stempel_wert
            o_itab_stamp_data = itab_res_data
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Anhängen, dann Sortieren
  LOOP AT itab_res_data INTO wa_res_data.
    CLEAR wa_stempel_wert.
    MOVE-CORRESPONDING wa_res_data TO wa_stempel_wert.
    APPEND wa_stempel_wert TO itab_stempel_wert.
  ENDLOOP.

  SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.
*  DELETE ADJACENT DUPLICATES FROM itab_class_data.

* /CIDEON/GET_RESULT_STAMP_DATA
* View ZCL_V_USR_GRP_RS


ENDFORM.                    " get_result_stamp_values
*&---------------------------------------------------------------------*
*&      Form  get_file_types
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file_types.
* read the allowed filetypes for this user
  DATA: lines TYPE i.

  REFRESH itab_plint_usr_tdwp.
  CLEAR itab_plint_usr_tdwp.
  CLEAR wa_plint_usr_tdwp.


  DATA: wa_group_user LIKE zcl_group_user.

* Vorgehen
* Einzeldaten lesen
* Gruppendaten lesen
* SAP* Daten lesen
*

* Einzeldaten
  SELECT  *  FROM zplint_usr_tdwp
    INTO TABLE itab_plint_usr_tdwp
    WHERE uname = sy-uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Gruppendaten
  SELECT  * FROM zcl_group_user
    INTO wa_group_user
    WHERE uname = sy-uname
    AND status = c_status_aktiv
    .
    SELECT * FROM zcl_group_tdwp
      APPENDING CORRESPONDING FIELDS OF TABLE itab_plint_usr_tdwp
      WHERE user_group = wa_group_user-user_group
      AND status = c_status_aktiv.
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

*SAP* Daten
  SELECT  * FROM zcl_group_user
    INTO wa_group_user
    WHERE uname = default_data-default_nutzer
    AND status = c_status_aktiv
    .
    SELECT * FROM zcl_group_tdwp
      APPENDING CORRESPONDING FIELDS OF TABLE itab_plint_usr_tdwp
      WHERE user_group = wa_group_user-user_group
      AND status = c_status_aktiv.
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* wenn alles leer, also nichts erlaubt ...
  IF itab_plint_usr_tdwp[] IS INITIAL.
    MESSAGE e002(/cideon/druck_basis) WITH '' '' '' ''.
  ELSE.
  ENDIF.


ENDFORM.                    " get_file_types
*&---------------------------------------------------------------------*
*&      Form  add_format_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_format_field.
  DATA: tmp_atwrt LIKE ausp-atwrt.

  CLEAR tmp_atwrt.
  SELECT SINGLE atwrt FROM ausp
    INTO tmp_atwrt
    WHERE objek = wa_plotjobs-objky
    AND atinn = default_data-merkmal_format
    .
  IF sy-subrc NE 0.
    PERFORM appl_log_write USING
      'W' '022' 'ZCL_PLINT_MESSAGE_01'
       wa_plotjobs-dokar wa_plotjobs-doknr
       wa_plotjobs-dokvr wa_plotjobs-doktl.
  ELSE.
    wa_plotjobs-format_ausgabe = tmp_atwrt.
  ENDIF.


ENDFORM.                    " add_format_field
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_aufnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_scr_attr_aufnr.
* Screen Attribute für AUFNR setzen

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF init_aufnr = ''.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFA'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
      edit_aufnr = '0'.
    ELSE.
      edit_aufnr = '1'.
    ENDIF.

    init_aufnr = 'X'.
  ELSE.
  ENDIF.

  IF edit_aufnr = 0.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-AUFNR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-AUFNR'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_scr_attr_aufnr
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_vbeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_scr_attr_vbeln.
* Screen Attribute für VBELn setzen

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF init_vbeln = ''.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTVB'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
      edit_vbeln = '0'.
    ELSE.
      edit_vbeln = '1'.
    ENDIF.

    init_vbeln = 'X'.
  ELSE.
  ENDIF.

  IF edit_vbeln = 0.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-VBELN'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-VBELN'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_scr_attr_vbeln
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_firma
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_scr_attr_firma.
* Screen Attribute für FIRMA setzen

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF init_firma = ''.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTFI'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
      edit_firma = '0'.
    ELSE.
      edit_firma = '1'.
    ENDIF.

    init_firma = 'X'.
  ELSE.
  ENDIF.

  IF edit_firma = 0.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-FIRMA'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-FIRMA'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_scr_attr_firma
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_kostl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_scr_attr_kostl.
* Screen Attribute für KOSTENSTELLE setzen

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF init_kostl = ''.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTKS'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
      edit_kostl = '0'.
    ELSE.
      edit_kostl = '1'.
    ENDIF.

    init_kostl = 'X'.
  ELSE.
  ENDIF.

  IF edit_kostl = 0.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-KOSTL'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-KOSTL'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_scr_attr_kostl
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_id_plotjob
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_scr_attr_id_plotjob.
* Screen Attribute für ID_PLOTJOB setzen

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF init_id_plotjob = ''.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTJN'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
      edit_id_plotjob = '0'.
    ELSE.
      edit_id_plotjob = '1'.
    ENDIF.

    init_id_plotjob = 'X'.
  ELSE.
  ENDIF.

  IF edit_id_plotjob = 0.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-ID_PLOTJOB'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-ID_PLOTJOB'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_scr_attr_id_plotjob
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_pspid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_scr_attr_pspid.
* Screen Attribute für PSPID setzen

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF init_pspid = ''.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTPS'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
      edit_pspid = '0'.
    ELSE.
      edit_pspid = '1'.
    ENDIF.

    init_pspid = 'X'.
  ELSE.
  ENDIF.

  IF edit_pspid = 0.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-PSPID'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-PSPID'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_scr_attr_pspid
*&---------------------------------------------------------------------*
*&      Form  set_screen_attributes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_screen_attributes.
  IF user_data-knz_use_post = 'X'.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group3 = 'POS'.
        screen-input = '1'.
      ELSE.
      ENDIF.
      IF screen-group3 = 'PRE'.
        screen-input = '0'.
        screen-invisible = '1'.
      ELSE.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  CASE user_data-modus.
    WHEN 'SUPER'.
    WHEN 'ADMIN'.
    WHEN 'NORMAL'.
      LOOP AT SCREEN.
        IF screen-group2 = 'NRM'.
          screen-input = '0'.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group3 = 'INV'.
      screen-invisible = '1'.
      screen-input = '0'.
      screen-output = '0'.
    ELSE.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " set_screen_attributes
*&---------------------------------------------------------------------*
*&      Form  set_scr_attr_lifnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_scr_attr_lifnr.
* Screen Attribute für LIFNR / NAME1_LIFNR setzen

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
  ELSE.
    EXIT.
  ENDIF.

  IF init_lifnr = ''.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTLF'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
      edit_lifnr = '0'.
    ELSE.
      edit_lifnr = '1'.
    ENDIF.

    init_lifnr = 'X'.
  ELSE.
  ENDIF.

  IF edit_lifnr = 0.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-LIFNR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
      IF screen-name = 'WA_AKT_PLOTJOBS-NAME1_LIFNR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.

    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'WA_AKT_PLOTJOBS-LIFNR'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
      IF screen-name = 'WA_AKT_PLOTJOBS-NAME1_LIFNR'.
        screen-input = '1'.
        MODIFY SCREEN.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_scr_attr_lifnr
