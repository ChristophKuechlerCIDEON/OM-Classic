FUNCTION /cideon/check_roles_for_user.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME
*"  EXPORTING
*"     VALUE(O_UNAME_PREPRO) TYPE  XUBNAME
*"  EXCEPTIONS
*"      NO_ROLE
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&     *
*&                                                                     *
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
* 22.05.2004 - Erstellung
*-----------------------------------------------------------------------

*TYPES
*ITAB
  DATA: itab_agr_users TYPE TABLE OF  agr_users.
*WA
  DATA: wa_agr_users TYPE agr_users.
  DATA: wa_preproz_user TYPE zcl_preproz_user.
*NORMAL
  DATA: f_found.

* Lesen der Rollenzuordnungen des Nutzers
  CLEAR wa_agr_users.
  CLEAR itab_agr_users.

  SELECT * FROM agr_users
    INTO TABLE itab_agr_users
    WHERE uname = i_uname
    AND from_dat <= sy-datum
    AND to_dat >= sy-datum
    .
  IF sy-subrc NE 0.
    RAISE no_role.
  ELSE.
  ENDIF.

* Testen ob eine der Rollen innerhalb der Zuordnung zu einem
* PreProcessor benutzt wird
  CLEAR f_found.
  LOOP AT itab_agr_users INTO wa_agr_users.
    CLEAR wa_preproz_user.
    SELECT SINGLE * FROM zcl_preproz_user
      INTO wa_preproz_user
      WHERE agr_name = wa_agr_users-agr_name
      AND status = c_status_aktiv
      .
    IF sy-subrc NE 0.
    ELSE.
      f_found = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF f_found = 'X'.
    o_uname_prepro = wa_preproz_user-uname.
  ELSE.
    RAISE no_role.
  ENDIF.

* falls eine aktive Rolle gefunden wurde dann Übergabe des Nutzers
* der Rolle für die F4-Hilfe















ENDFUNCTION.
