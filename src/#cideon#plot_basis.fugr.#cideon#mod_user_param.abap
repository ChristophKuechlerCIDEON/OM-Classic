FUNCTION /cideon/mod_user_param.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PNAME) TYPE  ZCL_PNAME
*"     VALUE(I_PWERT) TYPE  ZCL_PWERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 22.08.2005 - Erstellung
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------

* Vorgehen
* Wert für Parameter lesen
* falls vorhanden, dann Ändern,
* falls nicht vorhanden, dann updaten

  DATA: wa_user_data TYPE zcl_plint_config.


  SELECT SINGLE * FROM zcl_plint_config
    INTO wa_user_data
    WHERE uname = sy-uname
    AND pname = i_pname
    .
  IF sy-subrc NE 0.
*   kein Eintrag vorhanden, dann einen erstellen
    CLEAR wa_user_data.
    wa_user_data-uname = sy-uname.
    wa_user_data-pname = i_pname.
    wa_user_data-pwert = i_pwert.

    wa_user_data-zclinsname = sy-uname.
    wa_user_data-zclinsdate = sy-datum.
    wa_user_data-zclinstime = sy-uzeit.
    wa_user_data-zclinsprog = '/CIDEON/MOD_USER_PARAM'.
    wa_user_data-zclupdname = sy-uname.
    wa_user_data-zclupddate = sy-datum.
    wa_user_data-zclupdtime = sy-uzeit.
    wa_user_data-zclupdprog = '/CIDEON/MOD_USER_PARAM'.

  ELSE.
*   Eintrag updaten
    wa_user_data-pwert = i_pwert.

    wa_user_data-zclupdname = sy-uname.
    wa_user_data-zclupddate = sy-datum.
    wa_user_data-zclupdtime = sy-uzeit.
    wa_user_data-zclupdprog = '/CIDEON/MOD_USER_PARAM'.
  ENDIF.

  MODIFY zcl_plint_config FROM
    wa_user_data.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.



ENDFUNCTION.
