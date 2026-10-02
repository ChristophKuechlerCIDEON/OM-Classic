*----------------------------------------------------------------------*
***INCLUDE /CIDEON/_OM_007F17 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  switch_operator_mode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM switch_operator_mode.
* Schaltet zwischen den Operatoren Modi um
  " Plotoperator <-> normale Ausgabe

  PERFORM get_default_values.
  PERFORM get_user_values.

  "KNZ_USE_ADMIN_MODULE
  IF user_data-knz_use_admin_module = 'X'.
    CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
      EXPORTING
        i_pname       = 'KNZ_USE_ADMIN_MODULE'
        i_pwert       = ' '
*     EXCEPTIONS
*       ERROR         = 1
*       OTHERS        = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
    EXPORTING
      i_pname       = 'KNZ_USE_ADMIN_MODULE'
      i_pwert       = 'X'
*     EXCEPTIONS
*       ERROR         = 1
*       OTHERS        = 2
            .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  PERFORM get_default_values.
  PERFORM get_user_values.

  MESSAGE i004(/cideon/plot_basis)
    WITH 'KNZ_USE_ADMIN_MODULE' user_data-knz_use_admin_module
    '' ''.
*   Wert & geändert nach & & &


ENDFORM.                    " switch_operator_mode
*&---------------------------------------------------------------------*
*&      Form  chang_link_to_om
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chang_link_to_om.
* Änderung der OM Zuordnung

  CALL FUNCTION '/CIDEON/CHG_LINK_PREPRO_USER'
* EXPORTING
*   USER          =
            .

  PERFORM reload_properties.

ENDFORM.                    " chang_link_to_om
*&---------------------------------------------------------------------*
*&      Form  pl_set_file_size
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pl_set_file_size.

  CALL FUNCTION '/CIDEON/PL_SET_FILE_SIZE'
    EXPORTING
      i_wa_user_data       = user_data
    TABLES
      itab_plotjobs        = itab_plotjobs
* EXCEPTIONS
*   ERROR                = 1
*   OTHERS               = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " pl_set_file_size
