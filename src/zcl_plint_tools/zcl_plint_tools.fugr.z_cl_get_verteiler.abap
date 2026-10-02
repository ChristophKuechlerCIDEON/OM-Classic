FUNCTION z_cl_get_verteiler.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME
*"     REFERENCE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_VOREINSTELLUNG) TYPE  ZCL_VOREINSTELL
*"     VALUE(O_VERTEILER) TYPE  ZCL_VERTEILER
*"     VALUE(O_BEDINGUNG) TYPE  ZCL_BEDINGUNG
*"  EXCEPTIONS
*"      ERROR
*"      NOT_FOUND
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 13.08.2002 Erstellung
*-----------------------------------------------------------------------
* search for the fitting distributor
*
***********************************************************************
*FIELD-SYMBOLS
  FIELD-SYMBOLS: <fs> TYPE ANY.
*ITAB
  DATA: itab_verteiler TYPE TABLE OF zcl_verteiler.
  DATA: itab_schluessel TYPE TABLE OF zcl_schluessel.
  DATA: itab_bedingung TYPE TABLE OF zcl_bedingung.
  DATA: itab_beding_set TYPE TABLE OF zcl_beding_set.
*WA
  DATA: wa_verteiler TYPE zcl_verteiler.
  DATA: wa_schluessel TYPE zcl_schluessel.
  DATA: wa_bedingung TYPE zcl_bedingung.
  DATA: wa_beding_set TYPE zcl_beding_set.
*NORMAL
  DATA: f_exit_verteiler(1).
  DATA: f_exit_schluessel(1).
  DATA: f_exit_bedingung(1).
  DATA: f_exit_beding_set(1).
  DATA: name_data_field TYPE string.
  DATA: f_found(1).



  CLEAR o_voreinstellung.
  CLEAR f_found.

  REFRESH itab_verteiler.
  CLEAR wa_verteiler.

  SELECT * FROM zcl_verteiler
    INTO TABLE itab_verteiler
    WHERE uname = i_uname
    ORDER BY prio
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  LOOP AT itab_verteiler INTO wa_verteiler.
    o_verteiler = wa_verteiler.
    REFRESH itab_schluessel.
    SELECT * FROM zcl_schluessel
      INTO TABLE itab_schluessel
      WHERE uname = wa_verteiler-uname
      AND verteiler = wa_verteiler-verteiler
      ORDER BY prio
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
    LOOP AT itab_schluessel INTO wa_schluessel.
      REFRESH itab_bedingung.
      CLEAR wa_bedingung.
      SELECT * FROM zcl_bedingung
        INTO TABLE itab_bedingung
        WHERE uname = wa_schluessel-uname
        AND verteiler = wa_schluessel-verteiler
        AND id_schluessel = wa_schluessel-id_schluessel
        ORDER BY prio
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      LOOP AT itab_bedingung INTO wa_bedingung.
        REFRESH itab_beding_set.
        CLEAR wa_beding_set.
        SELECT * FROM zcl_beding_set
          INTO TABLE itab_beding_set
          WHERE uname = wa_bedingung-uname
          AND verteiler = wa_bedingung-verteiler
          AND id_schluessel = wa_bedingung-id_schluessel
          AND id_bedingung = wa_bedingung-id_bedingung
          ORDER BY prio
          .
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
        IF itab_beding_set[] IS INITIAL.
          CONTINUE.
        ELSE.
        ENDIF.

        CLEAR f_found.
        LOOP AT itab_beding_set INTO wa_beding_set.
          CONCATENATE 'I_WA_PLOTJOBS-'  wa_beding_set-bedingungsfeld
            INTO name_data_field.
          ASSIGN (name_data_field) TO <fs>.
          CASE wa_beding_set-operator.
            WHEN '='.
              IF <fs> = wa_beding_set-vergleichswert.
                f_found = 'X'.
              ELSE.
                CLEAR f_found.
                EXIT.
              ENDIF.
            WHEN '<>'.
              IF <fs> <> wa_beding_set-vergleichswert.
                f_found = 'X'.
              ELSE.
                CLEAR f_found.
                EXIT.
              ENDIF.
            WHEN '>='.
              IF <fs> >= wa_beding_set-vergleichswert.
                f_found = 'X'.
              ELSE.
                CLEAR f_found.
                EXIT.
              ENDIF.
            WHEN '<='.
              IF <fs> <= wa_beding_set-vergleichswert.
                f_found = 'X'.
              ELSE.
                CLEAR f_found.
                EXIT.
              ENDIF.
            WHEN '>'.
              IF <fs> > wa_beding_set-vergleichswert.
                f_found = 'X'.
              ELSE.
                CLEAR f_found.
                EXIT.
              ENDIF.
            WHEN '<'.
              IF <fs> < wa_beding_set-vergleichswert.
                f_found = 'X'.
              ELSE.
                CLEAR f_found.
                EXIT.
              ENDIF.
            WHEN OTHERS.
*             kein gültiger Operator
          ENDCASE.
        ENDLOOP.
        IF f_found = 'X'.
          CLEAR o_bedingung.
          o_bedingung = wa_bedingung.
          CLEAR o_voreinstellung.
          SELECT SINGLE * FROM zcl_voreinstell
            INTO o_voreinstellung
            WHERE uname = i_uname
            AND voreinstellung = wa_bedingung-voreinstellung
            .
          IF sy-subrc NE 0.
            RAISE not_found.
          ELSE.
          ENDIF.
          EXIT.
        ELSE.
        ENDIF.
      ENDLOOP.
      IF f_found = 'X'.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.
    IF f_found = 'X'.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.
  IF f_found = 'X'.
    EXIT.
  ELSE.
  ENDIF.

  IF NOT f_found = 'X'.
    RAISE not_found.
  ELSE.
  ENDIF.


ENDFUNCTION.
