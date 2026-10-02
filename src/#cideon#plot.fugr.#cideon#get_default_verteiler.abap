FUNCTION /cideon/get_default_verteiler.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"     VALUE(I_WA_DEFAULT_DATA) TYPE  /CIDEON/PLOT_DEFAULTDATA
*"  EXPORTING
*"     VALUE(O_WA_DEFAULT_VERTEILER) TYPE  ZCL_VOREINSTELL
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
* 05.07.2004 - Erstellung
*-----------------------------------------------------------------------

*TYPES
*ITAB
*WA
*NORMAL

* try to get the default distributor
  CLEAR o_wa_default_verteiler.
  SELECT SINGLE * FROM zcl_voreinstell
    INTO o_wa_default_verteiler
    WHERE uname = i_wa_default_data-default_nutzer
    AND voreinstellung = i_wa_default_data-default_voreinstellung
    .
  IF sy-subrc NE 0.
    IF i_wa_user_data-knz_use_post = 'X'.
    ELSE.
      EXIT.
    ENDIF.
    MESSAGE s052(zcl_plint_tools)
      WITH 'zcl_voreinstell' text-050
      i_wa_default_data-default_nutzer
      i_wa_default_data-default_verteiler
      .
  ELSE.
    SET PARAMETER ID 'ZCL_UNAME_GET'
      FIELD i_wa_default_data-default_nutzer.
  ENDIF.

ENDFUNCTION.
