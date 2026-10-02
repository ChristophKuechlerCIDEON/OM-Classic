FUNCTION z_cl_psbrw_change_capid_user.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FUNCTION) TYPE  SYST-UCOMM
*"  TABLES
*"      SELECTED_OBJECTS STRUCTURE  PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
********************************************
* ACHTUNG !  Parallel-FB Z_CL_PSBRW_CHANGE_CAPID_USER_Z
*            bitte gleichlautend anpassen !
***********************************************************************

* Journal

**TYPES
*  TYPES:
*    BEGIN OF t_default_data,
*      mat_capid TYPE tc04-capid,
*    END OF t_default_data.
*  TYPES:
*    BEGIN OF t_user_data,
*      mat_capid TYPE tc04-capid,
*      uname TYPE sy-uname,
*    END OF t_user_data.
**WA
*  DATA: default_data TYPE t_default_data.
*  DATA: user_data TYPE t_user_data.
  DATA wa_config TYPE zcl_plint_config.

*NORMAL
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).
  DATA: i TYPE i.


  CLEAR wa_objects.
  REFRESH itab_objects.

* Einstellungen einlesen
  CLEAR user_data.
  CLEAR default_data.
  user_data-uname = sy-uname.
* MAT_CAPID
  CLEAR tmp_str.
  pname = 'MAT_CAPID'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_capid = 'PP01'.
  ELSE.
    default_data-mat_capid = tmp_str.
  ENDIF.

  CLEAR tmp_str.
  pname = 'MAT_CAPID'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_capid = default_data-mat_capid.
  ELSE.
    user_data-mat_capid = tmp_str.
  ENDIF.

* MAT_STPST
  CLEAR tmp_str.
  pname = 'MAT_STPST'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-mat_stpst = '0'.
  ELSE.
    default_data-mat_stpst = tmp_str.
  ENDIF.

  CLEAR tmp_str.
  pname = 'MAT_STPST'.
  SELECT pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  ENDSELECT.
  IF sy-subrc NE 0.
    user_data-mat_stpst = default_data-mat_stpst.
  ELSE.
    user_data-mat_stpst = tmp_str.
  ENDIF.




  CLEAR wa_capid.
  CLEAR wa_stpos.
  wa_capid-capid = user_data-mat_capid.
  wa_stpos-stufe = user_data-mat_stpst.

  CALL SCREEN 200 STARTING AT 10 10 ENDING AT 55 14.

* MAT_CAPID
  CLEAR wa_config.
  pname = 'MAT_CAPID'.
  SELECT SINGLE * FROM zcl_plint_config
    INTO wa_config
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    wa_config-uname = sy-uname.
    wa_config-pname = 'MAT_CAPID'.
    wa_config-pwert = wa_capid-capid.
    wa_config-zclinsname = sy-uname.
    wa_config-zclinsdate = sy-datum.
    wa_config-zclinstime = sy-uzeit.
    wa_config-zclinsprog = 'Z_CL_PSBRW_CHANGE_CAPID_USER'.
    wa_config-zclupdname = sy-uname.
    wa_config-zclupddate = sy-datum.
    wa_config-zclupdtime = sy-uzeit.
    wa_config-zclupdprog = 'Z_CL_PSBRW_CHANGE_CAPID_USER'.
  ELSE.
    wa_config-uname = sy-uname.
    wa_config-pname = 'MAT_CAPID'.
    wa_config-pwert = wa_capid-capid.
    wa_config-zclupdname = sy-uname.
    wa_config-zclupddate = sy-datum.
    wa_config-zclupdtime = sy-uzeit.
    wa_config-zclupdprog = 'Z_CL_PSBRW_CHANGE_CAPID_USER'.
  ENDIF.

  MODIFY zcl_plint_config FROM wa_config.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* MAT_STPST
  CLEAR i.
  "i = wa_stpos-stufe.
  CLEAR wa_config.
  pname = 'MAT_STPST'.
  SELECT SINGLE * FROM zcl_plint_config
    INTO wa_config
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    wa_config-uname = sy-uname.
    wa_config-pname = 'MAT_STPST'.
    wa_config-pwert = wa_stpos-stufe.
    wa_config-zclinsname = sy-uname.
    wa_config-zclinsdate = sy-datum.
    wa_config-zclinstime = sy-uzeit.
    wa_config-zclinsprog = 'Z_CL_PSBRW_CHANGE_CAPID_USER'.
    wa_config-zclupdname = sy-uname.
    wa_config-zclupddate = sy-datum.
    wa_config-zclupdtime = sy-uzeit.
    wa_config-zclupdprog = 'Z_CL_PSBRW_CHANGE_CAPID_USER'.
  ELSE.
    wa_config-uname = sy-uname.
    wa_config-pname = 'MAT_STPST'.
    wa_config-pwert = wa_stpos-stufe.
    wa_config-zclupdname = sy-uname.
    wa_config-zclupddate = sy-datum.
    wa_config-zclupdtime = sy-uzeit.
    wa_config-zclupdprog = 'Z_CL_PSBRW_CHANGE_CAPID_USER'.
  ENDIF.

  SHIFT wa_config-pwert LEFT DELETING LEADING space.

  MODIFY zcl_plint_config FROM wa_config.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


ENDFUNCTION.
