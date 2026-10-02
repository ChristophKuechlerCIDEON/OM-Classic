report zcl_batch_clf_down_file_delete .

*-----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
*-----------------------------------------------------------------------

data: pwert type pwert.
data: pname type pname.
data: tmp_str(255).

data: days type i.
data: count type i.
data: down_path type string.
data: clf_down_path type string.





clear tmp_str.
pname = 'DOWN_FILES_DEL_DAYS'.
select single pwert from zcl_plint_cfg_00
  into tmp_str
  where pname = pname
  .
if sy-subrc ne 0.
  days = '4'.
  perform appl_log_write using
    'E' '057' 'ZCL_PLINT_TOOLS'
    'zcl_plint_cfg_00' pname '4' ''.
else.
  days = tmp_str.
endif.

* DOWN_PATH
clear tmp_str.
pname = 'DOWN_PATH'.
select single pwert from zcl_plint_cfg_00
  into tmp_str
  where pname = pname
  .
if sy-subrc ne 0.
  message i017(zcl_plint_tools) with
  pname '' '' ''.
  exit.
else.
  down_path = tmp_str.
endif.

* CLF_DOWN_PATH
clear tmp_str.
pname = 'CLF_DOWN_PATH'.
select single pwert from zcl_plint_cfg_00
  into tmp_str
  where pname = pname
  .
if sy-subrc ne 0.
  message i017(zcl_plint_tools) with
  pname '' '' ''.
  exit.
else.
  clf_down_path = tmp_str.
endif.




*MESSAGE i016(zcl_plint_tools) WITH
*  count '' '' ''.

form appl_log_write using    value(typ)
                             value(nummer)
                             value(klasse)
                             value(message1)
                             value(message2)
                             value(message3)
                             value(message4).
  data: msgv1 type symsgv.
  data: msgv2 type symsgv.
  data: msgv3 type symsgv.
  data: msgv4 type symsgv.

  data: number(3) type n.
  data: msgno type symsgno.

  clear msgv1.
  clear msgv2.
  clear msgv3.
  clear msgv4.
  msgv1 = message1.
  msgv2 = message2.
  msgv3 = message3.
  msgv4 = message4.
  number = nummer.
  msgno = nummer.

  call function '/CIDEON/APPL_LOG_WRITE_2'
       exporting
            i_object   = 'Z_CIDEON'
            i_subobj   = 'Z_PLOT'
            i_number   = msgno
            i_msgtyp   = typ
            i_msgid    = klasse
            i_msgno    = msgno
            i_msgv1    = msgv1
            i_msgv2    = msgv2
            i_msgv3    = msgv3
            i_msgv4    = msgv4
            i_class    = ' '
            i_newhead  = ' '
            i_messhead = ' '
       exceptions
            error      = 1
            others     = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " appl_log_write
