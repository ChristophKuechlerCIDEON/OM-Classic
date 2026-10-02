*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LCSS_CCMSF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  sperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sperren.
* Sperren setzen
  CALL FUNCTION 'ENQUEUE_/CIDEON/CSS_SPO'
       EXPORTING
            MODE_/CIDEON/SP_CSS01 = 'E'
            mandt                 = sy-mandt
            fname                 = '/CIDEON/SET_WORK_ENTRY_CSS'
            x_fname               = ' '
            _scope                = '3'
            _wait                 = ' '
            _collect              = ' '
       EXCEPTIONS
            foreign_lock          = 1
            system_failure        = 2
            OTHERS                = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RAISE gesperrt.
  ENDIF.

ENDFORM.                    " sperren
*&---------------------------------------------------------------------*
*&      Form  entsperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM entsperren.
* Sperren freigeben
  CALL FUNCTION 'DEQUEUE_/CIDEON/CSS_SPO'
       EXPORTING
            MODE_/CIDEON/SP_CSS01 = 'E'
            mandt                 = sy-mandt
            fname                 = '/CIDEON/SET_WORK_ENTRY_CSS'
            x_fname               = ' '
            _scope                = '3'
            _synchron             = ' '
            _collect              = ' '.

  COMMIT WORK AND WAIT.

ENDFORM.                    " entsperren
