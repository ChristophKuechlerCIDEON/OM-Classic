FUNCTION z_cl_update_repro_cl_ini_stamp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
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
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------

  DATA: wa_itab_ini TYPE t_itab_ini.
  DATA: wa_tmp_stamp_cl_ini LIKE zcl_stamp_cl_ini.

* ZCL_STAMP_CL_INI

* Tabelle säubern
  delete from zcl_stamp_cl_ini
    where uname = user_name
    .
  if sy-subrc ne 0.
  else.
  endif.

  CLEAR wa_stamp_cl_ini.
  wa_stamp_cl_ini-uname = user_name.
  LOOP AT itab_ini INTO wa_itab_ini.
    IF wa_itab_ini-key(1) = '['.
      wa_stamp_cl_ini-sektor = wa_itab_ini-key.
      CONTINUE.
    ELSE.
      wa_stamp_cl_ini-keyname = wa_itab_ini-key.
      wa_stamp_cl_ini-keywert = wa_itab_ini-value.
      CLEAR wa_tmp_stamp_cl_ini.
      SELECT * FROM zcl_stamp_cl_ini
        INTO wa_tmp_stamp_cl_ini
        WHERE uname = wa_stamp_cl_ini-uname
        AND sektor = wa_stamp_cl_ini-sektor
        AND keyname = wa_stamp_cl_ini-keyname
        .
      ENDSELECT.
      IF sy-subrc NE 0.
        wa_stamp_cl_ini-zclinsname = sy-uname.
        wa_stamp_cl_ini-zclinsdate = sy-datum.
        wa_stamp_cl_ini-zclinstime = sy-uzeit.
        wa_stamp_cl_ini-zclinsprog = sy-repid.
        wa_stamp_cl_ini-zclupdname  = sy-uname.
        wa_stamp_cl_ini-zclupddate = sy-datum.
        wa_stamp_cl_ini-zclupdtime = sy-uzeit.
        wa_stamp_cl_ini-zclupdprog = sy-repid.
        MODIFY zcl_stamp_cl_ini FROM wa_stamp_cl_ini.
        IF sy-subrc NE 0.
          rollback work.
          MESSAGE i051(zcl_plint_tools)
            WITH 'zcl_stamp_cl_ini' wa_stamp_cl_ini-uname
            wa_stamp_cl_ini-sektor
            wa_stamp_cl_ini-keyname
            RAISING error.
        ELSE.
        ENDIF.
      ELSE.
        wa_stamp_cl_ini-info = wa_tmp_stamp_cl_ini-info.
        wa_stamp_cl_ini-zclinsname =
          wa_tmp_stamp_cl_ini-zclinsname.
        wa_stamp_cl_ini-zclinsdate =
          wa_tmp_stamp_cl_ini-zclinsdate.
        wa_stamp_cl_ini-zclinstime =
          wa_tmp_stamp_cl_ini-zclinstime.
        wa_stamp_cl_ini-zclinsprog =
          wa_tmp_stamp_cl_ini-zclinsprog.
        wa_stamp_cl_ini-zclupdname  = sy-uname.
        wa_stamp_cl_ini-zclupddate = sy-datum.
        wa_stamp_cl_ini-zclupdtime = sy-uzeit.
        wa_stamp_cl_ini-zclupdprog = sy-repid.
        MODIFY zcl_stamp_cl_ini FROM wa_stamp_cl_ini.
        IF sy-subrc NE 0.
          rollback work.
          MESSAGE i051(zcl_plint_tools)
            WITH 'zcl_stamp_cl_ini' wa_stamp_cl_ini-uname
            wa_stamp_cl_ini-sektor
            wa_stamp_cl_ini-keyname
            RAISING error.
        ELSE.
        ENDIF.
      ENDIF.
    ENDIF.


  ENDLOOP.



ENDFUNCTION.
