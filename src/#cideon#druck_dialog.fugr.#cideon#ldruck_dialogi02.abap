*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGI02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHECK_VALUES_VERTEILER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_values_verteiler INPUT.
  "Check auf zugelassene Verteiler für Nutzer
  DATA lt_verteiler TYPE TABLE OF zcl_v_pre_us_ver.
  CLEAR lt_verteiler.

  CALL FUNCTION '/CIDEON/GET_VERTEILER'
    EXPORTING
      is_default_data = default_data
    TABLES
      et_verteiler    = lt_verteiler.

  READ TABLE lt_verteiler TRANSPORTING NO FIELDS
   WITH KEY verteiler = wa_akt_plotjobs-verteiler
   .
  IF sy-subrc NE 0.
    MESSAGE e010(/cideon/druck_basis) WITH
      '' '' '' ''.
  ELSE.

  ENDIF.
ENDMODULE.                 " CHECK_VALUES_VERTEILER  INPUT
