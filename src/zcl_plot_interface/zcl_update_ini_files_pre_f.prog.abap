*----------------------------------------------------------------------*
***INCLUDE ZCL_UPDATE_INI_FILES_PRE_F .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  transportieren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transportieren.
* Einträge transportieren

  DATA: i LIKE e071-as4pos,
        korrnum LIKE e070-trkorr VALUE space,
        lt_e071 LIKE e071 OCCURS 0 WITH HEADER LINE,
        lt_e071k LIKE e071k OCCURS 0 WITH HEADER LINE.

  TYPES :
  BEGIN OF t_tabkey,
    mandt LIKE zcl_repcl_ini_pr-mandt,
    preprozessor LIKE zcl_repcl_ini_pr-preprozessor,
    sektor LIKE zcl_repcl_ini_pr-sektor,
    keyname LIKE zcl_repcl_ini_pr-keyname,
  END OF t_tabkey.

  DATA : tabkey TYPE t_tabkey.

  TYPES :
  BEGIN OF t_tabkey2,
    mandt LIKE zcl_preprozessor-mandt,
    preprozessor LIKE zcl_preprozessor-preprozessor,
    verteiler  LIKE zcl_preprozessor-verteiler,
  END OF t_tabkey2.

  DATA : tabkey2 TYPE t_tabkey2.

  DATA: it_det TYPE TABLE OF zcl_repcl_ini_pr.
  DATA: it_det2 TYPE TABLE OF zcl_preprozessor.

  DATA: wa TYPE zcl_repcl_ini_pr.
  DATA: wa2 TYPE zcl_preprozessor.

* get data
  CLEAR it_det.
  REFRESH it_det.

  SELECT * FROM zcl_repcl_ini_pr
    INTO TABLE it_det.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CLEAR it_det2.
  REFRESH it_det2.

  SELECT * FROM zcl_preprozessor
    INTO TABLE it_det2.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


* Set constant values in transport tables
  CLEAR lt_e071k.
  lt_e071k-pgmid = 'R3TR'.
  lt_e071k-object = 'TABU'.
  lt_e071k-objname = 'ZCL_REPCL_INI_PR'.
  lt_e071k-mastertype = 'TABU'.
  lt_e071k-mastername = lt_e071k-objname.
  lt_e071k-objfunc = space.

  CLEAR lt_e071.
  lt_e071-pgmid = 'R3TR'.
  lt_e071-object = 'TABU'.
  lt_e071-obj_name = lt_e071k-objname.
  lt_e071-objfunc = 'K'.

  APPEND lt_e071.

* copy Tabkeys into transport tables.
  IF it_det IS INITIAL.
    CLEAR tabkey.
    tabkey = wa.
    MOVE tabkey TO lt_e071k-tabkey.
    APPEND lt_e071k.
  ELSE.
    LOOP AT it_det INTO wa.
      CLEAR tabkey.
      tabkey = wa.
      MOVE tabkey TO lt_e071k-tabkey.
      APPEND lt_e071k.
    ENDLOOP.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.


* Get task from popup
  IF korrnum IS INITIAL.
    CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
         EXPORTING
              iv_category            = 'SYST'
         IMPORTING
              ev_task                = korrnum
         EXCEPTIONS
              invalid_category       = 1
              no_correction_selected = 2
              OTHERS                 = 3.
    IF sy-subrc = 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING no_correction_selected.
    ELSEIF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING tr_system_error.
    ENDIF.
  ENDIF.

* Append sets to task
  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
       EXPORTING
            wi_trkorr = korrnum
       TABLES
            wt_e071   = lt_e071
            wt_e071k  = lt_e071k
       EXCEPTIONS
            OTHERS    = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING tr_system_error.
  ELSE.
  ENDIF.

* zweite Tabelle
  REFRESH lt_e071k.
  REFRESH lt_e071.
* Set constant values in transport tables
  CLEAR lt_e071k.
  lt_e071k-pgmid = 'R3TR'.
  lt_e071k-object = 'TABU'.
  lt_e071k-objname = 'ZCL_PREPROZESSOR'.
  lt_e071k-mastertype = 'TABU'.
  lt_e071k-mastername = lt_e071k-objname.
  lt_e071k-objfunc = space.

  CLEAR lt_e071.
  lt_e071-pgmid = 'R3TR'.
  lt_e071-object = 'TABU'.
  lt_e071-obj_name = lt_e071k-objname.
  lt_e071-objfunc = 'K'.

  APPEND lt_e071.

* copy Tabkeys into transport tables.
  IF it_det2 IS INITIAL.
    CLEAR tabkey2.
    tabkey2 = wa2.
    MOVE tabkey2 TO lt_e071k-tabkey.

    APPEND lt_e071k.

  ELSE.
    LOOP AT it_det2 INTO wa2.
      CLEAR tabkey2.
      tabkey2 = wa2.
      MOVE tabkey2 TO lt_e071k-tabkey.

      APPEND lt_e071k.
    ENDLOOP.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.

* Append sets to task
  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
       EXPORTING
            wi_trkorr = korrnum
       TABLES
            wt_e071   = lt_e071
            wt_e071k  = lt_e071k
       EXCEPTIONS
            OTHERS    = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING tr_system_error.
  ELSE.
  ENDIF.


ENDFORM.                    " transportieren
*&---------------------------------------------------------------------*
*&      Form  read_dirs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_dirs.
* Pfade lesen
  CLEAR wa_pre_processor_rfc.

  preprozessor = wa_work_normal-preprozessor.
  SELECT SINGLE klient_scan_pfad FROM zcl_preprozessor
    INTO wa_work_normal-scan_pfad_pre
    WHERE preprozessor = preprozessor
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
  SELECT SINGLE klient_down_pfad FROM zcl_preprozessor
    INTO wa_work_normal-down_pfad_pre
    WHERE preprozessor = preprozessor
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.
  SELECT SINGLE knz_use_converte converter_name converter_number
    ftp_destination ftp_user ftp_passwd ftp_down
    FROM zcl_preprozessor
    INTO (wa_pre_processor_rfc-knz_use_converter,
      wa_pre_processor_rfc-converter_name,
      wa_pre_processor_rfc-converter_number,
      wa_pre_processor_rfc-ftp_destination,
      wa_pre_processor_rfc-ftp_user,
      wa_pre_processor_rfc-ftp_passwd,
      wa_pre_processor_rfc-ftp_down)
    WHERE preprozessor = preprozessor
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

ENDFORM.                    " read_dirs
