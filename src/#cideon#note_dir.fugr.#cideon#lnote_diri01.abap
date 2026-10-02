*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LNOTE_DIRI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA: lf_error(1) TYPE c,
        lf_has_changed TYPE i,
        lf_is_saved TYPE i,
        ls_documentdata TYPE bapi_doc_draw2,
        ls_documentdatax TYPE bapi_doc_drawx2,
        ls_return TYPE bapiret2.

** Back
  CASE ok_code.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CALL METHOD cl_gui_cfw=>flush
           EXCEPTIONS: OTHERS = 1.

      SET SCREEN 0. LEAVE SCREEN.

** Save file
    WHEN 'OI_SAVE1' OR 'OI_SAVE2'.

      CALL FUNCTION 'CV150_HAS_CHANGED_DOC'
           EXPORTING
                im_url         = gc_url
           IMPORTING
                ex_has_changed = lf_has_changed
                ex_is_saved    = lf_is_saved
           EXCEPTIONS
                error          = 1
                not_found      = 2
                OTHERS         = 3.
      IF sy-subrc <> 0.
        MESSAGE s019(/cideon/cdesk_doc).
      ENDIF.

      CALL FUNCTION 'CV150_SAVE_DOC_TO_URL'
                  EXPORTING: im_url  = gc_url
                  EXCEPTIONS: error  = 1
                              OTHERS = 2.
      IF sy-subrc <> 0.
        MESSAGE s019(/cideon/cdesk_doc).
        EXIT.
      ENDIF.

** -> Save & EXIT
      IF ok_code = 'OI_SAVE2'.
        SET SCREEN 0. LEAVE SCREEN.
      ENDIF.

** do nothing
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
