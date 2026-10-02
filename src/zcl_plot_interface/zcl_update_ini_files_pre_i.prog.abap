*----------------------------------------------------------------------*
***INCLUDE ZCL_UPDAE_INI_FILES_I .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.

  case ok_code.
    when 'BACK'.
      leave to screen 0.
    when 'EXIT'.
      leave to screen 0.
    when 'CANC'.
      leave to screen 0.
*   manuelle Eingabe der Verteiler
    when 'MAN_EINGABE'.
      preprozessor = wa_work_normal-preprozessor.
      "Lesen der Verteiler, falls vorhanden
      data: it_preprocessor type table of zcl_preprozessor.
      data: wa_preprocessor type zcl_preprozessor.
      data: it_verteiler type table of /cideon/string.
      data: wa_verteiler type /cideon/string.

      clear it_preprocessor.
      select * from zcl_preprozessor
        into table it_preprocessor
        where preprozessor = preprozessor
        .
      if sy-subrc ne 0.
      else.
      endif.

      clear it_verteiler.
      loop at it_preprocessor into wa_preprocessor.
        clear wa_verteiler.
        wa_verteiler-line = wa_preprocessor-verteiler.
        append wa_verteiler to it_verteiler.
      endloop.

      call function '/CIDEON/UPDATE_PSO_EMERGENCY'
           exporting
                i_preprocessor = preprozessor
           tables
                itab_verteiler = it_verteiler
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      endif.

    when 'INI_EINLESEN_PSO6'.
      preprozessor = wa_work_normal-preprozessor.
      call function '/CIDEON/UPDATE_PRE6_INI'
           exporting
                i_preprocessor = preprozessor
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        clear ok_code.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    when 'INI_EINLESEN'.
      preprozessor = wa_work_normal-preprozessor.
      call function 'Z_CL_READ_INI_PREPROZESSOR_PRE'
           exporting
                i_preprozessor = preprozessor
                i_filename     = filename
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    when 'VERTEILER'.
      preprozessor = wa_work_normal-preprozessor.
      call function 'Z_CL_UPD_PREPROZESSOR_VERTEILE'
           exporting
                i_preprozessor = preprozessor
           exceptions
                error          = 1
                others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        rollback work.
      endif.
    when 'VERT_DEL'.
*     Löschen von Verteilern
      data: answer.
      clear answer.
      call function 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
           exporting
                textline1 = 'Wollen Sie wirklich löschen?'(001)
                titel     = 'Löschanfrage'(002)
           importing
                answer    = answer
           exceptions
                others    = 1.
      if answer = 'J'.
        preprozessor = wa_work_normal-preprozessor.
        scan_pfad_pre = wa_work_normal-scan_pfad_pre.
        down_pfad_pre = wa_work_normal-down_pfad_pre.

        delete from zcl_preprozessor
          where preprozessor = preprozessor
          .
        if sy-subrc ne 0.
          rollback work.
        else.
          delete from zcl_repcl_ini_pr
            where preprozessor = preprozessor
            .
          if sy-subrc ne 0.
            "rollback work.
          else.
            "message i049(zcl_plint_tools) with '' '' '' ''.
          endif.
          message i049(zcl_plint_tools) with '' '' '' ''.
        endif.
      else.
      endif.
    when 'SCAN_PF'.


      preprozessor = wa_work_normal-preprozessor.
      scan_pfad_pre = wa_work_normal-scan_pfad_pre.
      down_pfad_pre = wa_work_normal-down_pfad_pre.

      if scan_pfad_pre is initial or down_pfad_pre is initial.
        message e006(zcl_plint_tools).
*   Bitte Werte für Pfade setzen!


      else.
*     Check auf abschließende '\' '/'
        data: laenge type i.
        data: last_char(1).
        laenge = strlen( wa_work_normal-scan_pfad_pre ).
        if laenge > 0.
          laenge = laenge - 1.
          last_char = wa_work_normal-scan_pfad_pre+laenge.
          if last_char <> '/'
            and last_char <> '\'.
            message i072(zcl_plint_tools) with '' '' '' ''.
          else.
          endif.
        else.
        endif.

        laenge = strlen( wa_work_normal-down_pfad_pre ).
        if laenge > 0.
          laenge = laenge - 1.
          last_char = wa_work_normal-down_pfad_pre+laenge.
          if last_char <> '/'
            and last_char <> '\'.
            message i072(zcl_plint_tools) with '' '' '' ''.
          else.
          endif.
        else.
        endif.


        call function 'Z_CL_UPD_PREPROZESSOR_SCAN'
             exporting
                  i_preprozessor      = preprozessor
                  i_scan_pfad_pre     = scan_pfad_pre
                  i_down_pfad_pre     = down_pfad_pre
                  i_pre_processor_rfc = wa_pre_processor_rfc
             exceptions
                  error               = 1
                  others              = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          rollback work.
        endif.
      endif.
    when 'READ_PF'.
      perform read_dirs.
*      CLEAR wa_pre_processor_rfc.
*
*      preprozessor = wa_work_normal-preprozessor.
*      SELECT SINGLE klient_scan_pfad FROM zcl_preprozessor
*        INTO wa_work_normal-scan_pfad_pre
*        WHERE preprozessor = preprozessor
*        .
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
*      SELECT SINGLE klient_down_pfad FROM zcl_preprozessor
*        INTO wa_work_normal-down_pfad_pre
*        WHERE preprozessor = preprozessor
*        .
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
*      SELECT SINGLE knz_use_converte converter_name converter_number
*        ftp_destination ftp_user ftp_passwd ftp_down
*        FROM zcl_preprozessor
*        INTO (wa_pre_processor_rfc-knz_use_converter,
*          wa_pre_processor_rfc-converter_name,
*          wa_pre_processor_rfc-converter_number,
*          wa_pre_processor_rfc-ftp_destination,
*          wa_pre_processor_rfc-ftp_user,
*          wa_pre_processor_rfc-ftp_passwd,
*          wa_pre_processor_rfc-ftp_down)
*        WHERE preprozessor = preprozessor
*        .
*      IF sy-subrc NE 0.
*      ELSE.
*      ENDIF.
    when 'TRANS'.
      perform transportieren.
    when others.
*     Falls Verzeichnisangaben leer, dann versuch sie zu lesen
      if ( wa_work_normal-scan_pfad_pre is initial )
      and ( wa_work_normal-down_pfad_pre is initial ).
        preprozessor = wa_work_normal-preprozessor.
        select single klient_scan_pfad from zcl_preprozessor
          into wa_work_normal-scan_pfad_pre
          where preprozessor = preprozessor
          .
        if sy-subrc ne 0.
        else.
        endif.
        select single klient_down_pfad from zcl_preprozessor
          into wa_work_normal-down_pfad_pre
          where preprozessor = preprozessor
          .
        if sy-subrc ne 0.
        else.
        endif.
      else.
      endif.
  endcase.

  clear ok_code.

endmodule.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_checkboxen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_checkboxen input.

  wa_pre_processor_rfc-knz_use_converter = cb_knz_use_converter.

endmodule.                 " get_checkboxen  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_data input.

  wa_pre_processor_rfc = /cideon/_s_pre_preocessor.

endmodule.                 " get_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  preprocessor  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module preprocessor input.

** CHG MBH - 2010/10/20
**  New Search Dialog
  data: begin of ls_value_tab,
          preprozessor type zcl_name_preprozessor,
          verteiler type zcl_name_verteiler,
          beschreibung type beschreibg,
        end of ls_value_tab.

  data: lt_return_tab type table of  ddshretval,
        lt_value_tab like table of ls_value_tab.

  select *
    into corresponding fields of table lt_value_tab
    from zcl_preprozessor.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
       exporting
            retfield        = 'PREPROZESSOR'
            dynpprog        = 'ZCL_UPDATE_INI_FILES_PRE_I'  "sy-repid
            dynpnr          = sy-dynnr
            dynprofield     = 'WA_WORK_NORMAL-PREPROZESSOR'
            value_org       = 'S'
       tables
            value_tab       = lt_value_tab
            return_tab      = lt_return_tab
       exceptions
            parameter_error = 1
            no_values_found = 2
            others          = 3.

  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.




endmodule.                 " preprocessor  INPUT
