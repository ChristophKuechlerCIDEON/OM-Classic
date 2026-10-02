*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF10 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_stamp_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stamp_values.
* get the values for the stamps
  DATA: index_itab_plotjobs_2 TYPE sy-tabix.
* itab_tmp_plotjobs_2
* itab_stempel_wert

  CALL FUNCTION '/CIDEON/GET_STAMP_DATA'
       EXPORTING
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            o_itab_stamp_data = itab_stempel_wert
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  EXIT.


  REFRESH itab_stempel_default.
  SELECT * FROM zcl_stamp_defaul
    INTO TABLE itab_stempel_default
    WHERE status = c_status_aktiv
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  REFRESH itab_stempel_user.
  SELECT * FROM zcl_stamp_user
    INTO TABLE itab_stempel_user
    WHERE status = c_status_aktiv
    AND uname = sy-uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


  REFRESH itab_stempel_wert.

  LOOP AT itab_tmp_plotjobs_2 INTO wa_plotjobs.
    REFRESH itab_stempel_voreinstellung.
    SELECT * FROM zcl_stamp_vorein
      INTO TABLE itab_stempel_voreinstellung
      WHERE status = c_status_aktiv
      AND voreinstellung = wa_plotjobs-voreinstellung
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
    IF user_data-knz_use_post = 'X'.
    ELSE.
      "bei CLF bei Voreinstellungen
      REFRESH itab_stempel_voreinstellung.
    ENDIF.

    REFRESH itab_stempel_verteiler.
    SELECT * FROM zcl_stamp_vertei
      INTO TABLE itab_stempel_verteiler
      WHERE status = c_status_aktiv
      AND verteiler = wa_plotjobs-verteiler
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.


    index_itab_plotjobs_2 = sy-tabix.

*   default stamps
    LOOP AT itab_stempel_default INTO wa_stempel_default.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_default-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_default-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_default-fm_name 'zcl_stamp_defaul'  '' ''.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_default-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_default-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   user stamps
    LOOP AT itab_stempel_user INTO wa_stempel_user.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_user-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_user-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_user-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name = wa_stempel_user-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   Voreinstellung stamps
    LOOP AT itab_stempel_voreinstellung INTO wa_stempel_voreinstellung.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_voreinstellung-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_vor'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_voreinstellung-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_voreinstellung-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_voreinstellung-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.

*   Verteiler stamps
    LOOP AT itab_stempel_verteiler INTO wa_stempel_verteiler.
      CLEAR wa_stempel_wert.
*     " check for FB
*     " created
      SELECT SINGLE * FROM tfdir
        WHERE funcname = wa_stempel_verteiler-fm_name
        .
      IF sy-subrc NE 0.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '080' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_vert'  '' ''.
        CONTINUE.
      ELSE.
      ENDIF.
*     " active
      SELECT SINGLE * FROM rsinfdir
        WHERE funcname = wa_stempel_verteiler-fm_name
        .
      IF sy-subrc NE 0.
      ELSE.
        "LOG Eintrag
        PERFORM appl_log_write USING
          'E' '081' 'ZCL_PLINT_MESSAGE_01'
           wa_stempel_verteiler-fm_name 'zcl_stamp_user'  '' ''.
        CONTINUE.
      ENDIF.
      CALL FUNCTION wa_stempel_user-fm_name
           EXPORTING
                i_wa_plotjobs  = wa_plotjobs
           IMPORTING
                o_stempel_wert = wa_stempel_wert-stempel_wert
           EXCEPTIONS
                error          = 1
                OTHERS         = 2.
      IF sy-subrc <> 0.
        "LOG Eintrag
      ELSE.
        wa_stempel_wert-zeile_plotjob = index_itab_plotjobs_2.
        wa_stempel_wert-stempel_name =
          wa_stempel_verteiler-stempel_name.
        APPEND wa_stempel_wert TO itab_stempel_wert .
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " get_stamp_values
