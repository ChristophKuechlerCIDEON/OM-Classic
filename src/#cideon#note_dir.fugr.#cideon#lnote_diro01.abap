*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LNOTE_DIRO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  DATA: lf_title LIKE draw-filep,
        lf_apptp LIKE tdwx-apptp.
*----------------------------------------------------------------------*

  CLEAR: lf_title,
         ok_code.

  CALL FUNCTION 'CV120_SPLIT_PATH'
       EXPORTING: pf_path  = gc_docfile
       IMPORTING: pfx_file = lf_title.

** set display/change-mode
  IF gs_data-display = 'X'.
    SET PF-STATUS '0200DISPLAY'.
    SET TITLEBAR  '0200DISPLAY' WITH lf_title.
  ELSE.
    SET PF-STATUS '0200CHANGE'.
    SET TITLEBAR  '0200CHANGE' WITH lf_title.
  ENDIF.

  CALL METHOD cl_gui_custom_container=>set_focus
    EXPORTING
      control           = gf_oi_cont
    EXCEPTIONS
      cntl_error        = 1
      cntl_system_error = 2
      OTHERS            = 3
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD cl_gui_cfw=>flush
       EXCEPTIONS: OTHERS = 1.


ENDMODULE.                 " STATUS_0200  OUTPUT
