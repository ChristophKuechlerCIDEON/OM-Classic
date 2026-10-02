*&---------------------------------------------------------------------*
*& Report  /CIDEON/MNT_PLOT_LOG_M0                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

report  /cideon/mnt_plot_log_m0       .

types:
begin of t_sel ,
         sign(1),
         option(2),
         low  like /cideon/pl_log-id,
         high like /cideon/pl_log-id,
      end   of t_sel.


data: sel type table of t_sel.
data: lc_sel type t_sel.

* Mahnstufe 0 für aktuellen Nutzer
data: lt_log type table of /cideon/pl_log.
data: lc_log type /cideon/pl_log.

clear lt_log.
select * from /cideon/pl_log
  into table lt_log
  where duedate <= sy-datum
  and duedate <> '00000000'
  and m1date = '00000000'
*  AND m2date = '00000000'
  and status = '00'
  and lifnr <> ''
  and zclinsname = sy-uname
  .
if sy-subrc ne 0.
else.
endif.

if lt_log[] is initial.
  exit.
else.
endif.

clear sel.
clear lc_sel.
lc_sel-sign = 'I'.
lc_sel-option = 'EQ'.
loop at lt_log into lc_log.
  lc_sel-low = lc_log-id.
  lc_sel-high = lc_log-id.
  append lc_sel to sel.
endloop.



submit /cideon/mnt_cideon_pl_log
  with s_id in sel
  with tbmaxsel = '10000'
  and return
  .
