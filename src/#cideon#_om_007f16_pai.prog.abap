*----------------------------------------------------------------------*
***INCLUDE /CIDEON/_OM_007F16_PAI .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  check_values  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_values INPUT.

  IF ok_code = 'CANC'.
    EXIT.
  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_von
    CN ';,0123456789 '.
    CLEAR wa_akt_plotjobs-seite_von.
    CLEAR ok_code.
    MESSAGE e000(/cideon/druck_basis) WITH
      wa_akt_plotjobs-seite_von '' '' ''.

  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_bis
    CN ';,0123456789 '.
    CLEAR wa_akt_plotjobs-seite_bis.
    CLEAR ok_code.
    MESSAGE e000(/cideon/druck_basis) WITH
      wa_akt_plotjobs-seite_bis '' '' ''.

  ELSE.
  ENDIF.


  IF wa_akt_plotjobs-seite_von CA ';,'.
    CLEAR wa_akt_plotjobs-seite_bis.
  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_von IS INITIAL
    AND wa_akt_plotjobs-seite_bis IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  IF ( NOT wa_akt_plotjobs-seite_von IS INITIAL )
    AND wa_akt_plotjobs-seite_bis IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  IF wa_akt_plotjobs-seite_von <= wa_akt_plotjobs-seite_bis .
    IF wa_akt_plotjobs-seite_von IS INITIAL.
      wa_akt_plotjobs-seite_von = 1.
    ELSE.
    ENDIF.
    EXIT.
  ELSE.
    CLEAR ok_code.
    MESSAGE e001(/cideon/druck_basis) WITH
      '' '' '' ''.
  ENDIF.





ENDMODULE.                 " check_values  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_VALUES_VERTEILER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_values_verteiler INPUT.

  IF wa_akt_plotjobs-verteiler IS INITIAL.
    EXIT.
  ELSE.

  ENDIF.

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
