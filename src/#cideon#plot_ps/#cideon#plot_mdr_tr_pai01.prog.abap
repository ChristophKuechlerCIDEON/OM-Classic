*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_MDR_TR_PAI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  save_ok_code = ok_code.
  CLEAR ok_code.

  CASE save_ok_code.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'INFO'.
      PERFORM show_info.
    WHEN 'PLOT_MDR'.
*     MDR erstellen
      PERFORM check_psp_element.
      IF wa_mdr_tr IS INITIAL.
      ELSE.
        CLEAR it_objects.
        PERFORM get_psp_elements.
        PERFORM get_easy_doc_root.
        PERFORM get_doc_for_psp.
        PERFORM get_doc_easydms.
        PERFORM clean_out_with_class_mdr.
        PERFORM create_tr_table.
        PERFORM make_toc_tr_mdr.
        PERFORM add_drawings_to_mdr.
        PERFORM send_objects_to_om.
      ENDIF.
    WHEN 'PLOT_TR'.
*     TR erstellen
      PERFORM check_psp_element.
      IF wa_mdr_tr IS INITIAL.
      ELSE.
        PERFORM get_psp_elements.
        PERFORM get_easy_doc_root.
        PERFORM get_doc_for_psp.
        PERFORM create_tr_table.
        PERFORM create_tr.
        "PERFORM make_tr_pdf.
      ENDIF.
    WHEN 'VIEW_DIS'.
*      SET PARAMETER ID 'CV1' FIELD wa_mdr_tr-doknr.
*      SET PARAMETER ID 'CV2' FIELD wa_mdr_tr-dokar.
*      SET PARAMETER ID 'CV3' FIELD wa_mdr_tr-dokvr.
*      SET PARAMETER ID 'CV4' FIELD wa_mdr_tr-doktl.

      SET PARAMETER ID 'CV1' FIELD wa_mdr_tr-doknr_last_tr.
      SET PARAMETER ID 'CV2' FIELD wa_mdr_tr-dokar_last_tr.
      SET PARAMETER ID 'CV3' FIELD wa_mdr_tr-dokvr_last_tr.
      SET PARAMETER ID 'CV4' FIELD wa_mdr_tr-doktl_last_tr.

      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

    WHEN 'CDESK'.
      CLEAR it_objects.
      PERFORM get_psp_elements.
      PERFORM get_easy_doc_root.

      PERFORM anzeige_struktur_docu.

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
  CLEAR save_ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
