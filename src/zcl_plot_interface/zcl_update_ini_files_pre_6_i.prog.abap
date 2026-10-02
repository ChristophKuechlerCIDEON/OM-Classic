*----------------------------------------------------------------------*
***INCLUDE ZCL_UPDAE_INI_FILES_I .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'INI_EINLESEN'.
      preprozessor = wa_work_normal-preprozessor.
*      CALL FUNCTION 'Z_CL_READ_INI_PREPROZESSOR_PRE'
*           EXPORTING
*                i_preprozessor = preprozessor
*                i_filename     = filename
*           EXCEPTIONS
*                error          = 1
*                OTHERS         = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
    WHEN 'VERTEILER'.
*      preprozessor = wa_work_normal-preprozessor.
*      CALL FUNCTION 'Z_CL_UPD_PREPROZESSOR_VERTEILE'
*           EXPORTING
*                i_preprozessor = preprozessor
*           EXCEPTIONS
*                error          = 1
*                OTHERS         = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ROLLBACK WORK.
*      ENDIF.
    WHEN 'VERT_DEL'.
*     Löschen von Verteilern
*      preprozessor = wa_work_normal-preprozessor.
*      scan_pfad_pre = wa_work_normal-scan_pfad_pre.
*      down_pfad_pre = wa_work_normal-down_pfad_pre.
*
*      DELETE FROM zcl_preprozessor
*        WHERE preprozessor = preprozessor
*        .
*      IF sy-subrc NE 0.
*        ROLLBACK WORK.
*      ELSE.
*        DELETE FROM zcl_repcl_ini_pr
*          WHERE preprozessor = preprozessor
*          .
*        IF sy-subrc NE 0.
*          ROLLBACK WORK.
*        ELSE.
*          MESSAGE i049(zcl_plint_tools) WITH '' '' '' ''.
*        ENDIF.
*      ENDIF.

    WHEN 'SCAN_PF'.
      preprozessor = wa_work_normal-preprozessor.
      scan_pfad_pre = wa_work_normal-scan_pfad_pre.
      down_pfad_pre = wa_work_normal-down_pfad_pre.

*     Check auf abschließende '\' '/'
      DATA: laenge TYPE i.
      DATA: last_char(1).
      laenge = strlen( wa_work_normal-scan_pfad_pre ).
      IF laenge > 0.
        laenge = laenge - 1.
        last_char = wa_work_normal-scan_pfad_pre+laenge.
        IF last_char <> '/'
          AND last_char <> '\'.
          MESSAGE i072(zcl_plint_tools) WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.

      laenge = strlen( wa_work_normal-down_pfad_pre ).
      IF laenge > 0.
        laenge = laenge - 1.
        last_char = wa_work_normal-down_pfad_pre+laenge.
        IF last_char <> '/'
          AND last_char <> '\'.
          MESSAGE i072(zcl_plint_tools) WITH '' '' '' ''.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.


      CALL FUNCTION 'Z_CL_UPD_PREPROZESSOR_SCAN'
           EXPORTING
                i_preprozessor      = preprozessor
                i_scan_pfad_pre     = scan_pfad_pre
                i_down_pfad_pre     = down_pfad_pre
                i_pre_processor_rfc = wa_pre_processor_rfc
           EXCEPTIONS
                error               = 1
                OTHERS              = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ROLLBACK WORK.
      ENDIF.
    WHEN 'READ_PF'.
      CLEAR wa_pre_processor_rfc.

      preprozessor = wa_work_normal-preprozessor.
      SELECT SINGLE klient_scan_pfad FROM zcl_preprozessor
        INTO wa_work_normal-scan_pfad_pre
        WHERE preprozessor = preprozessor
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
      SELECT SINGLE klient_down_pfad FROM zcl_preprozessor
        INTO wa_work_normal-down_pfad_pre
        WHERE preprozessor = preprozessor
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
      SELECT SINGLE knz_use_converte converter_name converter_number
        ftp_destination ftp_user ftp_passwd ftp_down
        FROM zcl_preprozessor
        INTO (wa_pre_processor_rfc-knz_use_converter,
          wa_pre_processor_rfc-converter_name,
          wa_pre_processor_rfc-converter_number,
          wa_pre_processor_rfc-ftp_destination,
          wa_pre_processor_rfc-ftp_user,
          wa_pre_processor_rfc-ftp_passwd,
          wa_pre_processor_rfc-ftp_down)
        WHERE preprozessor = preprozessor
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    WHEN 'TRANS'.
      PERFORM transportieren.
    WHEN OTHERS.
*     Falls Verzeichnisangaben leer, dann versuch sie zu lesen
      IF ( wa_work_normal-scan_pfad_pre IS INITIAL )
      AND ( wa_work_normal-down_pfad_pre IS INITIAL ).
        preprozessor = wa_work_normal-preprozessor.
        SELECT SINGLE klient_scan_pfad FROM zcl_preprozessor
          INTO wa_work_normal-scan_pfad_pre
          WHERE preprozessor = preprozessor
          .
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
        SELECT SINGLE klient_down_pfad FROM zcl_preprozessor
          INTO wa_work_normal-down_pfad_pre
          WHERE preprozessor = preprozessor
          .
        IF sy-subrc NE 0.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_checkboxen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_checkboxen INPUT.

  wa_pre_processor_rfc-knz_use_converter = cb_knz_use_converter.

ENDMODULE.                 " get_checkboxen  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data INPUT.

  wa_pre_processor_rfc = /cideon/_s_pre_preocessor.

ENDMODULE.                 " get_data  INPUT
