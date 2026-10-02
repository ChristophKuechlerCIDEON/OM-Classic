FUNCTION z_cl_upd_stempel_klassen.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 05.09.2002 Erstellung
* ZCL_STAMP_CL_INI
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_stempel_feld TYPE TABLE OF zcl_stamp_field.
  DATA: itab_stempel_stempel TYPE TABLE OF zcl_stamp_stamp.
  DATA: itab_stempel_gruppe TYPE TABLE OF zcl_stamp_group.
  DATA: itab_group TYPE TABLE OF char30.
  DATA: itab_stamp TYPE TABLE OF char30.
  DATA: itab_field TYPE TABLE OF char30.
* WA
  DATA: wa_stamp_cl_ini LIKE zcl_stamp_cl_ini.
  DATA: wa_stempel_klasse LIKE zcl_stamp_class.
  DATA: wa_stempel_gruppe LIKE zcl_stamp_group.
  DATA: wa_stempel_stempel LIKE zcl_stamp_stamp.
  DATA: wa_stempel_feld LIKE zcl_stamp_field.
  DATA: wa_group TYPE char30.
  DATA: wa_stamp TYPE char30.
  DATA: wa_field TYPE char30.
* NORMAL
  DATA: count TYPE i.
  DATA: tmp_str(10).
  DATA: tmp_keyname(30).
  DATA: tmp_feld(120).
  DATA: index_itab_field TYPE i.
  DATA: text1(60).
  DATA: text2(60).

  DELETE FROM zcl_stamp_class
    WHERE uname = i_uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  DELETE FROM zcl_stamp_group
    WHERE uname = i_uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  DELETE FROM zcl_stamp_stamp
    WHERE uname = i_uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  DELETE FROM zcl_stamp_field
    WHERE uname = i_uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
    WHERE uname = i_uname
    AND sektor = '[General]'
    AND keyname = 'StampsGroupsClassesCount'.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i052(zcl_plint_tools)
      WITH 'zcl_repro_cl_ini' i_uname
      '[General]' 'StampsCount'
      RAISING error.
  ELSE.
  ENDIF.

  CLEAR count.
  count = wa_stamp_cl_ini-keywert.
  CLEAR wa_stempel_klasse.
  wa_stempel_klasse-uname = i_uname.

  DO count TIMES.
    CLEAR tmp_keyname.
    tmp_str = sy-index - 1.
    CONCATENATE '[StampsGroupsClass' tmp_str ']' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.
    SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
      WHERE uname = i_uname
      AND sektor = tmp_keyname
      AND keyname = 'Name'.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_stamp_cl_ini' i_uname
        tmp_keyname 'Name'
        RAISING error.
    ELSE.
      wa_stempel_klasse-stempel_klasse = wa_stamp_cl_ini-keywert.
      wa_stempel_klasse-zclinsname = sy-uname.
      wa_stempel_klasse-zclinsdate = sy-datum.
      wa_stempel_klasse-zclinstime = sy-uzeit.
      wa_stempel_klasse-zclinsprog = sy-repid.
      wa_stempel_klasse-zclupdname  = sy-uname.
      wa_stempel_klasse-zclupddate = sy-datum.
      wa_stempel_klasse-zclupdtime = sy-uzeit.
      wa_stempel_klasse-zclupdprog = sy-repid.
    ENDIF.

*   Update zcl_stamp_class
    MODIFY zcl_stamp_class FROM wa_stempel_klasse.
    IF sy-subrc NE 0.
      MESSAGE i051(zcl_plint_tools)
        WITH 'zcl_stamp_class' i_uname
        wa_stempel_klasse-stempel_klasse ''
        RAISING error.
    ELSE.
    ENDIF.

*   Groups
    SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
      WHERE uname = i_uname
      AND sektor = tmp_keyname
      AND keyname = 'StampsGroupsList'.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_stamp_cl_ini' i_uname
        tmp_keyname 'StampsGroupsList'
        RAISING error.
    ELSE.
    ENDIF.

    CLEAR wa_group.
    REFRESH itab_group.
    SPLIT wa_stamp_cl_ini-keywert AT ',' INTO TABLE itab_group.

    CLEAR wa_stempel_gruppe.
    REFRESH itab_stempel_gruppe.

    LOOP AT itab_group INTO wa_group.
      wa_stempel_gruppe-uname = wa_stempel_klasse-uname.
      wa_stempel_gruppe-stempel_klasse
        = wa_stempel_klasse-stempel_klasse.
      wa_stempel_gruppe-stempel_gruppe = wa_group.

      wa_stempel_gruppe-zclinsname = sy-uname.
      wa_stempel_gruppe-zclinsdate = sy-datum.
      wa_stempel_gruppe-zclinstime = sy-uzeit.
      wa_stempel_gruppe-zclinsprog = sy-repid.
      wa_stempel_gruppe-zclupdname  = sy-uname.
      wa_stempel_gruppe-zclupddate = sy-datum.
      wa_stempel_gruppe-zclupdtime = sy-uzeit.
      wa_stempel_gruppe-zclupdprog = sy-repid.

*     Update zcl_stamp_group
      MODIFY zcl_stamp_group FROM wa_stempel_gruppe.
      IF sy-subrc NE 0.
        MESSAGE i051(zcl_plint_tools)
          WITH 'zcl_stamp_group' i_uname
          wa_stempel_gruppe-stempel_klasse
          wa_stempel_gruppe-stempel_gruppe
          RAISING error.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDDO.

* Update zcl_stamp_group
  SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
    WHERE uname = i_uname
    AND sektor = '[General]'
    AND keyname = 'StampsGroupsCount'.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i052(zcl_plint_tools)
      WITH 'zcl_repro_cl_ini' i_uname
      '[General]' 'StampsGroupsCount'
      RAISING error.
  ELSE.
  ENDIF.

  CLEAR count.
  count = wa_stamp_cl_ini-keywert.
  CLEAR wa_stempel_gruppe.
  wa_stempel_gruppe-uname = i_uname.

  DO count TIMES.
    CLEAR tmp_keyname.
    tmp_str = sy-index - 1.
    CONCATENATE '[StampsGroup' tmp_str ']' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
      WHERE uname = i_uname
      AND sektor = tmp_keyname
      AND keyname = 'Name'.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_stamp_cl_ini' i_uname
        tmp_keyname 'Name'
        RAISING error.
    ELSE.
      SELECT * FROM zcl_stamp_group INTO wa_stempel_gruppe
        WHERE uname = i_uname
        AND stempel_gruppe = wa_stamp_cl_ini-keywert
        .
        SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
          WHERE uname = i_uname
          AND sektor = tmp_keyname
          AND keyname = 'StampsList'.
          wa_stempel_gruppe-stempel_liste = wa_stamp_cl_ini-keywert.
          UPDATE zcl_stamp_group FROM wa_stempel_gruppe.
          IF sy-subrc NE 0.
          ELSE.
          ENDIF.

          CLEAR wa_stamp.
          REFRESH itab_stamp.
          SPLIT wa_stempel_gruppe-stempel_liste
            AT ',' INTO TABLE itab_stamp.

          CLEAR wa_stempel_stempel.

          LOOP AT itab_stamp INTO wa_stamp.
            wa_stempel_stempel-uname = wa_stempel_gruppe-uname.
            wa_stempel_stempel-stempel_klasse =
              wa_stempel_gruppe-stempel_klasse.
            wa_stempel_stempel-stempel_gruppe =
              wa_stempel_gruppe-stempel_gruppe.
            wa_stempel_stempel-stempel_name = wa_stamp.

            wa_stempel_stempel-zclinsname = sy-uname.
            wa_stempel_stempel-zclinsdate = sy-datum.
            wa_stempel_stempel-zclinstime = sy-uzeit.
            wa_stempel_stempel-zclinsprog = sy-repid.
            wa_stempel_stempel-zclupdname  = sy-uname.
            wa_stempel_stempel-zclupddate = sy-datum.
            wa_stempel_stempel-zclupdtime = sy-uzeit.
            wa_stempel_stempel-zclupdprog = sy-repid.

*           Update zcl_stamp_stempel
            MODIFY zcl_stamp_stamp FROM wa_stempel_stempel.
            IF sy-subrc NE 0.
              MESSAGE i051(zcl_plint_tools)
                WITH 'zcl_stamp_stamp' i_uname
                wa_stempel_gruppe-stempel_klasse
                wa_stempel_gruppe-stempel_gruppe
                RAISING error.
            ELSE.
            ENDIF.
          ENDLOOP.

        ENDSELECT.
      ENDSELECT.
    ENDIF.
  ENDDO.

* Update zcl_stamp_stamp
  SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
    WHERE uname = i_uname
    AND sektor = '[General]'
    AND keyname = 'StampsCount'.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i052(zcl_plint_tools)
      WITH 'zcl_repro_cl_ini' i_uname
      '[General]' 'StampsCount'
      RAISING error.
  ELSE.
  ENDIF.

  CLEAR count.
  count = wa_stamp_cl_ini-keywert.
  CLEAR wa_stempel_stempel.
  wa_stempel_stempel-uname = i_uname.

  DO count TIMES.
    CLEAR tmp_keyname.
    tmp_str = sy-index - 1.
    CONCATENATE '[Stamp' tmp_str ']' INTO tmp_keyname.
    CONDENSE tmp_keyname NO-GAPS.

    SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
      WHERE uname = i_uname
      AND sektor = tmp_keyname
      AND keyname = 'Name'.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i052(zcl_plint_tools)
        WITH 'zcl_stamp_cl_ini' i_uname
        tmp_keyname 'Name'
        RAISING error.
    ELSE.
      SELECT * FROM zcl_stamp_stamp INTO wa_stempel_stempel
        WHERE uname = i_uname
        AND stempel_name = wa_stamp_cl_ini-keywert
        .
        SELECT * FROM zcl_stamp_cl_ini INTO wa_stamp_cl_ini
          WHERE uname = i_uname
          AND sektor = tmp_keyname
          AND keyname = 'Text'.
          wa_stempel_stempel-feld_liste = wa_stamp_cl_ini-keywert.
          UPDATE zcl_stamp_stamp FROM wa_stempel_stempel.
          IF sy-subrc NE 0.
          ELSE.
          ENDIF.

        ENDSELECT.
      ENDSELECT.
    ENDIF.
  ENDDO.

  REFRESH itab_stempel_stempel.

  SELECT * FROM zcl_stamp_stamp INTO TABLE itab_stempel_stempel
   WHERE uname = i_uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  LOOP AT itab_stempel_stempel INTO wa_stempel_stempel.
    CLEAR tmp_feld.
    tmp_feld = wa_stempel_stempel-feld_liste.
    IF tmp_feld CS 'STAMPFIELD'.
      CLEAR wa_field.
      REFRESH itab_field.
      SPLIT tmp_feld AT '%STAMPFIELD' INTO TABLE itab_field.
    ELSE.
    ENDIF.

    LOOP AT itab_field INTO wa_field.
      index_itab_field = sy-tabix.
      IF wa_field IS INITIAL.
        DELETE itab_field INDEX index_itab_field.
        CONTINUE.
      ELSE.
      ENDIF.
      IF wa_field CS '%'.
        CLEAR text1. CLEAR text2.
        SPLIT wa_field AT '%' INTO text1 text2.
        wa_field = text1.
      ELSE.
      ENDIF.
      MODIFY itab_field FROM wa_field INDEX index_itab_field.
    ENDLOOP.

    CLEAR wa_stempel_feld.
    wa_stempel_feld-uname = wa_stempel_stempel-uname.
    wa_stempel_feld-stempel_klasse =
      wa_stempel_stempel-stempel_klasse.
    wa_stempel_feld-stempel_gruppe =
      wa_stempel_stempel-stempel_gruppe.
    wa_stempel_feld-stempel_name =
      wa_stempel_stempel-stempel_name.

    LOOP AT itab_field INTO wa_field.
      wa_stempel_feld-stempel_feld = wa_field.
      MODIFY zcl_stamp_field FROM wa_stempel_feld.
      IF sy-subrc NE 0.
        MESSAGE i051(zcl_plint_tools)
          WITH 'zcl_stamp_field' i_uname
          wa_stempel_gruppe-stempel_klasse
          wa_stempel_gruppe-stempel_gruppe
          RAISING error.
      ELSE.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

  MESSAGE i056(zcl_plint_tools) WITH '' '' '' ''.

ENDFUNCTION.
