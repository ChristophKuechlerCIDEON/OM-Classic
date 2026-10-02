FUNCTION /cideon/get_file_types.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"     VALUE(I_UNAME) TYPE  SYUNAME
*"  TABLES
*"      ITAB_PLINT_USR_TDWP STRUCTURE  ZPLINT_USR_TDWP
*"      ITAB_FILETYPE STRUCTURE  TDWP
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 12.07.2004 - Erstellung
*-----------------------------------------------------------------------

*WA
  DATA: wa_plint_usr_tdwp TYPE zplint_usr_tdwp.
  DATA: wa_tdwp TYPE tdwp.

* read the allowed filetypes for this user
  DATA: lines TYPE i.

  REFRESH itab_plint_usr_tdwp.
  CLEAR itab_plint_usr_tdwp.
  CLEAR wa_plint_usr_tdwp.


  DATA: wa_group_user LIKE zcl_group_user.

* Vorgehen
* Einzeldaten lesen
* Gruppendaten lesen
* SAP* Daten lesen
*

  IF i_uname IS INITIAL.
    i_uname = sy-uname.
  ELSE.
  ENDIF.



* Einzeldaten
  SELECT  *  FROM zplint_usr_tdwp
    INTO TABLE itab_plint_usr_tdwp
    WHERE uname = i_uname.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Gruppendaten
  SELECT  * FROM zcl_group_user
    INTO wa_group_user
    WHERE uname = i_uname
    AND status = c_status_aktiv
    .
    SELECT * FROM zcl_group_tdwp
      APPENDING CORRESPONDING FIELDS OF TABLE itab_plint_usr_tdwp
      WHERE user_group = wa_group_user-user_group
      AND status = c_status_aktiv.
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* SAP* Daten
  SELECT  * FROM zcl_group_user
    INTO wa_group_user
    WHERE uname = i_wa_default_data-default_nutzer
    AND status = c_status_aktiv
    .
    SELECT * FROM zcl_group_tdwp
      APPENDING CORRESPONDING FIELDS OF TABLE itab_plint_usr_tdwp
      WHERE user_group = wa_group_user-user_group
      AND status = c_status_aktiv.
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDSELECT.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  REFRESH itab_filetype.
  LOOP AT itab_plint_usr_tdwp INTO wa_plint_usr_tdwp.
    CLEAR wa_tdwp.
    MOVE-CORRESPONDING wa_plint_usr_tdwp TO wa_tdwp.
    APPEND wa_tdwp TO itab_filetype.
  ENDLOOP.

  SORT itab_filetype BY dappl.
  DELETE ADJACENT DUPLICATES FROM itab_filetype
    COMPARING dappl.



ENDFUNCTION.
