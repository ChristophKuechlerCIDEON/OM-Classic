*&---------------------------------------------------------------------*
*& Report  /CIDEON/MNT_PLOT_LOG_M0                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  /cideon/mnt_plot_log_m1       .

TYPES:
BEGIN OF t_sel ,
         sign(1),
         option(2),
         low  LIKE /cideon/pl_log-id,
         high LIKE /cideon/pl_log-id,
      END   OF t_sel.


DATA: sel TYPE TABLE OF t_sel.
DATA: lc_sel TYPE t_sel.

* Mahnstufe 0 für aktuellen Nutzer
DATA: lt_log TYPE TABLE OF /cideon/pl_log.
DATA: lc_log TYPE /cideon/pl_log.

DATA: date TYPE sy-datum.
date = sy-datum - 10.

* BADI Aufruf
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
  CALL METHOD badi_main_pre_001->chg_m1_date
    CHANGING
      date   = date
      .
ENDIF.


CLEAR lt_log.
SELECT * FROM /cideon/pl_log
  INTO TABLE lt_log
  WHERE duedate <= sy-datum
  AND duedate <> '00000000'
  AND m1date <= date
  AND m1date <> '00000000'
  AND m2date = '00000000'
  AND status = '00'
  AND lifnr <> ''
    AND zclinsname = sy-uname
  .
IF sy-subrc NE 0.
ELSE.
ENDIF.

IF lt_log[] IS INITIAL.
  EXIT.
ELSE.
ENDIF.

CLEAR sel.
CLEAR lc_sel.
lc_sel-sign = 'I'.
lc_sel-option = 'EQ'.
LOOP AT lt_log INTO lc_log.
  lc_sel-low = lc_log-id.
  lc_sel-high = lc_log-id.
  APPEND lc_sel TO sel.
ENDLOOP.


SUBMIT /cideon/mnt_cideon_pl_log
  WITH s_id IN sel
  WITH tbmaxsel = '10000'
  AND RETURN
  .
