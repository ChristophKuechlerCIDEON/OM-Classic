*----------------------------------------------------------------------*
***INCLUDE LZCL_PLINT_TOOLSF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_mimetype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_mimetype.
* try to get the mimetype

  SELECT SINGLE * FROM tdwp INTO wa_tdwp
    WHERE dappl = wa_plotjobs-wsapplication.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF wa_tdwp-mimetype IS INITIAL.
    g_mimetype_1 = 'application'.
    g_mimetype_1 = 'unknown'.
  ELSE.
    SPLIT wa_tdwp-mimetype AT '/' INTO g_mimetype_1 g_mimetype_2.
  ENDIF.


ENDFORM.                    " get_mimetype
*&---------------------------------------------------------------------*
*&      Form  exit_2d
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_2d.
  IF NOT gf_view IS INITIAL.
    CALL METHOD gf_view->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    FREE gf_view.
  ENDIF.
  IF NOT gf_view_3d IS INITIAL.
    CALL METHOD gf_view_3d->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    FREE gf_view_3d .
  ENDIF.
  IF NOT gf_view_2d IS INITIAL.
    CALL METHOD gf_view_2d->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    FREE gf_view_2d .
  ENDIF.

  IF NOT gf_view_cont IS INITIAL.
    CALL METHOD gf_view_cont->free
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
    ENDIF.
    FREE gf_view_cont.
  ENDIF.

  LEAVE SCREEN.
*      exit.

ENDFORM.                                                    " exit_2d
*&---------------------------------------------------------------------*
*&      Form  exit_3d
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_3d.
  IF NOT gf_view IS INITIAL.
    CALL METHOD gf_view->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    FREE gf_view.
  ENDIF.
  IF NOT gf_view_3d IS INITIAL.
    CALL METHOD gf_view_3d->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    FREE gf_view_3d .
  ENDIF.
  IF NOT gf_view_2d IS INITIAL.
    CALL METHOD gf_view_2d->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    FREE gf_view_2d .
  ENDIF.

  IF NOT gf_view_cont IS INITIAL.
    CALL METHOD gf_view_cont->free
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
    ENDIF.
    FREE gf_view_cont.
  ENDIF.


ENDFORM.                                                    " exit_3d
*&---------------------------------------------------------------------*
*&      Form  exit_office
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_office.
  IF NOT viewer IS INITIAL.
    CALL METHOD viewer->destroy_viewer
        EXCEPTIONS not_initialized = 1
                    free_failed = 2.
    IF sy-subrc NE 0.
    ENDIF.
    FREE viewer.
  ENDIF.
  IF NOT view_container IS INITIAL.
    CALL METHOD view_container->free
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
    ENDIF.
    FREE view_container.
  ENDIF.

  LEAVE SCREEN.

ENDFORM.                    " exit_office



***
*&---------------------------------------------------------------------*
*&      Module  STATUS_0570  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_0570 output.
  SET PF-STATUS 'ZCL_PF_ASK_FOR_VBELN'.
*  SET TITLEBAR 'xxx'.

endmodule.                 " STATUS_0570  OUTPUT
