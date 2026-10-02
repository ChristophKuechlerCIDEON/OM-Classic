*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_MDR_TR_PAI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'INFO'.
      PERFORM show_info.
    WHEN 'DBLCLICK_PRST'.
      CLEAR wa_rc29l.
      MOVE-CORRESPONDING wa_prst TO wa_rc29l.

    WHEN 'MDF'.
*     PSP Stückliste lesen
      PERFORM get_prst_bom.
*     Dokumente recherchieren
      PERFORM get_doc_for_bom.
*     Ausgabe als XLS
      PERFORM fill_xls.

    WHEN 'PLOT_MDR'.
*     MDR erstellen
      PERFORM check_psp_element.
      IF wa_mdr_tr IS INITIAL.
      ELSE.
        IF wa_mdr_tr-f_wbs_bom = 'X'.
          CLEAR it_objects.
          PERFORM get_psp_elements.
*         PSP Stückliste lesen
          PERFORM get_prst_bom.
*         Dokumente recherchieren
          PERFORM get_doc_for_bom.

          PERFORM make_doctab_from_bom.

          PERFORM send_objects_to_om.
        ELSE.
          CLEAR it_objects.
          PERFORM get_psp_elements.
          PERFORM get_doc_for_psp.
*        PERFORM get_doc_easydms.
*        PERFORM clean_out_with_class_mdr.
*        PERFORM make_toc_tr_mdr.
*        PERFORM drawings_to_plot.
          PERFORM send_objects_to_om.
        ENDIF.
      ENDIF.
    WHEN 'PLOT_TR'.
*     TR erstellen
*      PERFORM check_psp_element.
*      IF wa_mdr_tr IS INITIAL.
*      ELSE.
*        PERFORM get_psp_elements.
*        PERFORM get_doc_for_psp.
*        PERFORM create_tr_table.
*        PERFORM create_tr.
*        "PERFORM make_tr_pdf.
*      ENDIF.
    WHEN 'VIEW_DIS'.
*      SET PARAMETER ID 'CV1' FIELD wa_mdr_tr-doknr.
*      SET PARAMETER ID 'CV2' FIELD wa_mdr_tr-dokar.
*      SET PARAMETER ID 'CV3' FIELD wa_mdr_tr-dokvr.
*      SET PARAMETER ID 'CV4' FIELD wa_mdr_tr-doktl.
*
*      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
    WHEN OTHERS.
*     Lesen der Projektdaten
*      IF wa_mdr_tr-pspid IS INITIAL.
*        IF wa_mdr_tr-posid IS INITIAL.
*        ELSE.
*          PERFORM read_pspid.
*          "SET PARAMETER ID 'PRO' FIELD wa_mdr_tr-posid.
*        ENDIF.
*      ELSE.
*      ENDIF.
      PERFORM read_pspid.
      SET PARAMETER ID 'PRO' FIELD wa_mdr_tr-posid.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  mdf_template  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mdf_template INPUT.
* Auswahl des MDF Templates (FILENAME)
  DATA: lt_filetable TYPE filetable.
  DATA: lc_filetable TYPE file_table.
  DATA: rc TYPE i.
  DATA: window_title TYPE string.
  DATA: initial_directory TYPE string.
  DATA: default_filename TYPE string.

  CLEAR lt_filetable.
  CLEAR rc.

  window_title = text-003.
  initial_directory = mdf_filename.
  default_filename = mdf_filename.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
   EXPORTING
     window_title            = window_title
     default_extension       = 'XLS'
     default_filename        = '*.xls'
     file_filter             = 'XLS'
     initial_directory       = initial_directory
*    MULTISELECTION          =
    CHANGING
      file_table              = lt_filetable
      rc                      = rc
*    USER_ACTION             =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      OTHERS                  = 4
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  IF rc = 1.
    READ TABLE lt_filetable INTO lc_filetable INDEX 1.
    wa_mdr_tr-mdf_template = lc_filetable-filename.
  ELSE.
  ENDIF.




ENDMODULE.                 " mdf_template  INPUT
