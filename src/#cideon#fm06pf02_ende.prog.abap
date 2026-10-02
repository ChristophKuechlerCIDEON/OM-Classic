*eject
*----------------------------------------------------------------------*
* Beenden Formulardruck
*----------------------------------------------------------------------*
FORM ENDE.

* Unterschrift -------------------------------------------------------*
  CALL FUNCTION 'WRITE_FORM'
       EXPORTING
            ELEMENT = 'LAST'
       EXCEPTIONS
            OTHERS  = 01.
  CLEAR SY-SUBRC.

* Folgeseitenzaehler löschen -----------------------------------------*
  CALL FUNCTION 'WRITE_FORM'
       EXPORTING
            ELEMENT  = 'NEXTPAGE'
            WINDOW   = 'NEXTPAGE'
            FUNCTION = 'DELETE'
       EXCEPTIONS
            OTHERS   = 01.
  CLEAR SY-SUBRC.

* Ende Formulardruck --------------------------------------------------*
  CALL FUNCTION 'CLOSE_FORM'
       IMPORTING
            RESULT = RESULT.
  IF RESULT-TDSPOOLID NE SPACE.
    SPOOLID = RESULT-TDSPOOLID.
    PERFORM PROTOCOL_UPDATE USING '320' SPOOLID SPACE SPACE SPACE.

**   Übergabe der Spool ID
*    data: wa_psb type zcl_psb_tmp.
*    clear wa_psb.
*    wa_psb-tdspoolid = spoolid.
*    modify zcl_psb_tmp from wa_psb.

  ENDIF.

  if result-userexit eq 'C' or
      result-userexit eq 'E'.
    retco = '9'.
  endif.

ENDFORM.
