*----------------------------------------------------------------------*
***INCLUDE /CIDEON/SEL_TO_MIGRATE_F2 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  draw_abfragen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM draw_abfragen.
* DRAW mit eigenen Kriterien recherchieren

ENDFORM.                    " draw_abfragen
*&---------------------------------------------------------------------*
*&      Form  read_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_log.
* BALDHRD lesen

  SELECT * FROM balhdr INTO TABLE itab_balhdr
    WHERE object = 'CONV'
    AND aluser IN s_user
    AND aldate IN s_date
    AND altime IN s_time

* ABORT oder EXCEPTION Meldungen
    AND ( msg_cnt_a <> '000000'
          OR msg_cnt_e <> '000000'
        )
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


* alle erfolgreichen Meldung lesen
* it_balhdr_success
  SELECT * FROM balhdr INTO TABLE it_balhdr_success
    WHERE object = 'CONV'
    AND aluser IN s_user
    AND aldate IN s_date
    AND altime IN s_time

* ABORT oder EXCEPTION Meldungen
    AND ( msg_cnt_a = '000000'
          AND msg_cnt_e = '000000'
        )
    and MSG_CNT_S <> '000000'
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

ENDFORM.                    " read_log
