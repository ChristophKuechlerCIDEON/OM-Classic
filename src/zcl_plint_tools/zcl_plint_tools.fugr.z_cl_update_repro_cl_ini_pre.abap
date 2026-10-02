FUNCTION z_cl_update_repro_cl_ini_pre.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_PREPROZESSOR) TYPE  ZCL_NAME_PREPROZESSOR
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
  DATA: wa_tmp_repcl_ini_pr LIKE zcl_repcl_ini_pr.
  DATA: wa_repcl_ini_pr TYPE zcl_repcl_ini_pr.


  CLEAR wa_repcl_ini_pr.
  wa_repcl_ini_pr-preprozessor = i_preprozessor.
  LOOP AT itab_ini INTO wa_itab_ini.
    IF wa_itab_ini-key(1) = '['.
      wa_repcl_ini_pr-sektor = wa_itab_ini-key.
      CONTINUE.
    ELSE.
      wa_repcl_ini_pr-keyname = wa_itab_ini-key.
      wa_repcl_ini_pr-keywert = wa_itab_ini-value.
      CLEAR wa_tmp_repcl_ini_pr.
      SELECT * FROM  zcl_repcl_ini_pr
        INTO wa_tmp_repcl_ini_pr
        WHERE preprozessor = wa_repcl_ini_pr-preprozessor
        AND sektor = wa_repcl_ini_pr-sektor
        AND keyname = wa_repcl_ini_pr-keyname
        .
      ENDSELECT.
      IF sy-subrc NE 0.
        wa_repcl_ini_pr-zclinsname = sy-uname.
        wa_repcl_ini_pr-zclinsdate = sy-datum.
        wa_repcl_ini_pr-zclinstime = sy-uzeit.
        wa_repcl_ini_pr-zclinsprog = sy-repid.
        wa_repcl_ini_pr-zclupdname  = sy-uname.
        wa_repcl_ini_pr-zclupddate = sy-datum.
        wa_repcl_ini_pr-zclupdtime = sy-uzeit.
        wa_repcl_ini_pr-zclupdprog = sy-repid.
        MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE i051(zcl_plint_tools)
            WITH 'ZCL_REPCL_INI_PR' wa_repcl_ini_pr-preprozessor
            wa_repcl_ini_pr-sektor
            wa_repcl_ini_pr-keyname
            RAISING error.
        ELSE.
        ENDIF.
      ELSE.
        wa_repcl_ini_pr-info = wa_tmp_repcl_ini_pr-info.
        wa_repcl_ini_pr-zclinsname =
          wa_repcl_ini_pr-zclinsname.
        wa_repcl_ini_pr-zclinsdate =
          wa_repcl_ini_pr-zclinsdate.
        wa_repcl_ini_pr-zclinstime =
          wa_repcl_ini_pr-zclinstime.
        wa_repcl_ini_pr-zclinsprog =
          wa_repcl_ini_pr-zclinsprog.
        wa_repcl_ini_pr-zclupdname  = sy-uname.
        wa_repcl_ini_pr-zclupddate = sy-datum.
        wa_repcl_ini_pr-zclupdtime = sy-uzeit.
        wa_repcl_ini_pr-zclupdprog = sy-repid.
        MODIFY zcl_repcl_ini_pr FROM wa_repcl_ini_pr.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE i051(zcl_plint_tools)
            WITH 'ZCL_REPCL_INI_PR' wa_repcl_ini_pr-preprozessor
            wa_repcl_ini_pr-sektor
            wa_repcl_ini_pr-keyname
            RAISING error.
        ELSE.
        ENDIF.
      ENDIF.
    ENDIF.


  ENDLOOP.



ENDFUNCTION.
