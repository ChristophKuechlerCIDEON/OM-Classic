*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_default_verteiler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_default_verteiler.
* try to get the default distributor
  CLEAR wa_default_verteiler.
  SELECT SINGLE * FROM zcl_voreinstell
    INTO wa_default_verteiler
    WHERE uname = default_data-default_nutzer
    AND voreinstellung = default_data-default_voreinstellung
    .
  IF sy-subrc NE 0.
    IF user_data-knz_use_post = 'X'.
    ELSE.
      EXIT.
    ENDIF.
    MESSAGE s052(zcl_plint_tools)
      WITH 'zcl_voreinstell' text-050
      default_data-default_nutzer
      default_data-default_verteiler
      .
  ELSE.
    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_data-default_nutzer.
  ENDIF.


ENDFORM.                    " get_default_verteiler
