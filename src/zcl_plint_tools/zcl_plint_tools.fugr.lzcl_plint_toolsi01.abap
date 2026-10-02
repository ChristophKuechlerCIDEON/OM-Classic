*----------------------------------------------------------------------*
***INCLUDE LZCL_PLINT_TOOLSI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'OK'.
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
*      exit.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      PERFORM exit_2d.
      LEAVE SCREEN.
*      exit.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      PERFORM exit_3d.
      LEAVE SCREEN.
*      exit.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      IF ( prio => prio_von ) AND ( prio <= prio_bis ).
        g_prio = prio.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE i063(zcl_plint_message_01)
          WITH prio_von prio_bis '' ''.
      ENDIF.
    WHEN 'CANC'.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.
  CASE ok_code.
    WHEN 'CV04N'.
      "PERFORM suche_via_cv04n.
      CALL TRANSACTION 'CV04N'.
      GET PARAMETER ID 'CV1' FIELD doknr.
      GET PARAMETER ID 'CV2' FIELD dokar.
      GET PARAMETER ID 'CV3' FIELD dokvr.
      GET PARAMETER ID 'CV4' FIELD doktl.

      g_draw_doknr = doknr.
      g_draw_dokar = dokar.
      g_draw_dokvr = dokvr.
      g_draw_doktl = doktl.

      zcl_s_draw01-dokar = dokar.
      zcl_s_draw01-doknr = doknr.
      zcl_s_draw01-doktl = doktl.
      zcl_s_draw01-dokvr = dokvr.

*      SET PARAMETER ID 'CV1' FIELD doknr.
*      SET PARAMETER ID 'CV2' FIELD dokar.
*      SET PARAMETER ID 'CV3' FIELD dokvr.
*      SET PARAMETER ID 'CV4' FIELD doktl.

*      wa_zcl_s_draw01-dokar = dokar.
*      wa_zcl_s_draw01-doknr = doknr.
*      wa_zcl_s_draw01-doktl = doktl.
*      wa_zcl_s_draw01-dokvr = dokvr.

      CLEAR ok_code.
      LEAVE TO SCREEN 600.
    WHEN 'OK'.
*      GET PARAMETER ID 'CV1' FIELD doknr.
*      GET PARAMETER ID 'CV2' FIELD dokar.
*      GET PARAMETER ID 'CV3' FIELD dokvr.
*      GET PARAMETER ID 'CV4' FIELD doktl.

      g_draw_doknr = zcl_s_draw01-doknr.
      g_draw_dokar = zcl_s_draw01-dokar.
      g_draw_dokvr = zcl_s_draw01-dokvr.
      g_draw_doktl = zcl_s_draw01-doktl.

      doknr = zcl_s_draw01-doknr.
      dokar = zcl_s_draw01-dokar.
      dokvr = zcl_s_draw01-dokvr.
      doktl = zcl_s_draw01-doktl.

      IF doknr IS INITIAL
       OR dokvr IS INITIAL
       OR dokar IS INITIAL
       OR doktl IS INITIAL
      .
        MESSAGE i070(zcl_plint_message_01)
          WITH '' '' '' ''.
        CLEAR ok_code.
        LEAVE TO SCREEN 600.
        EXIT.
      ELSE.
        IF dokar IS INITIAL.
          MESSAGE i070(zcl_plint_message_01)
            WITH '' '' '' ''.
          LEAVE TO SCREEN 600.
        ELSE.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR g_draw_doknr.
      CLEAR g_draw_dokar.
      CLEAR g_draw_dokvr.
      CLEAR g_draw_doktl.
      LEAVE TO SCREEN 0.

    WHEN 'STACK'.
      DATA: wa_stack TYPE object_keyfields.

      CLEAR wa_stack.
      CALL FUNCTION 'C_PDM_SHOW_OBJECTS_FROM_STACK'
           EXPORTING
                objtyp              = 'DOCUMENT'
           IMPORTING
                new_object_fields   = wa_stack
           EXCEPTIONS
                fehlender_objekttyp = 1
                OTHERS              = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        CLEAR ok_code.
        EXIT.
      ENDIF.

      IF wa_stack IS INITIAL.
        CLEAR ok_code.
        EXIT.
      ELSE.
      ENDIF.

      CLEAR zcl_s_draw01.

      zcl_s_draw01-doknr = wa_stack-doknr.
      zcl_s_draw01-dokar = wa_stack-dokar.
      zcl_s_draw01-dokvr = wa_stack-dokvr.
      zcl_s_draw01-doktl = wa_stack-doktl.


      SET PARAMETER ID 'CV1' FIELD wa_stack-doknr.
      SET PARAMETER ID 'CV2' FIELD wa_stack-dokar.
      SET PARAMETER ID 'CV3' FIELD wa_stack-dokvr.
      SET PARAMETER ID 'CV4' FIELD wa_stack-doktl.

*      COMMIT WORK AND WAIT.

*      GET PARAMETER ID 'CV1' FIELD doknr.
*      GET PARAMETER ID 'CV2' FIELD dokar.
*      GET PARAMETER ID 'CV3' FIELD dokvr.
*      GET PARAMETER ID 'CV4' FIELD doktl.

      g_draw_doknr = wa_stack-doknr.
      g_draw_dokar = wa_stack-dokar.
      g_draw_dokvr = wa_stack-dokvr.
      g_draw_doktl = wa_stack-doktl.



*      wa_zcl_s_draw01-dokar = dokar.
*      wa_zcl_s_draw01-doknr = doknr.
*      wa_zcl_s_draw01-doktl = doktl.
*      wa_zcl_s_draw01-dokvr = dokvr.

      CLEAR ok_code.
*      LEAVE TO SCREEN 600.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.
  CASE ok_code.
    WHEN 'OK'.
*     fill table with sel. Items
      REFRESH itab_tmp_fail_document.
      PERFORM get_selectet_rows.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      REFRESH itab_tmp_fail_document.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'DBLCLICK_LIST'.
      PERFORM view_doc.
    WHEN 'DOK_VIEW  '.
      PERFORM view_sel_doc.
    WHEN 'SAVE_FB_LI'.
      PERFORM save_to_fb_list.
    WHEN OTHERS.
      REFRESH itab_tmp_fail_document.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0800 INPUT.
  CASE ok_code.
    WHEN 'OK'.
*     fill table with sel. Items
      REFRESH itab_tmp_zori_doc_files.
      REFRESH itab_tmp_zori_doc_files_detail.
      PERFORM get_selectet_rows_zori.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      REFRESH itab_tmp_zori_doc_files.
      REFRESH itab_tmp_zori_doc_files_detail.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN OTHERS.
      REFRESH itab_tmp_zori_doc_files.
      REFRESH itab_tmp_zori_doc_files_detail.
  ENDCASE.

  CLEAR ok_code.


ENDMODULE.                 " USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0550  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0550 INPUT.
  CASE ok_code.
    WHEN 'PROG_INFO'.
      tabcontrol_info-activetab = 'PROG_INFO'.
    WHEN 'PATCH_INFO'.
      tabcontrol_info-activetab = 'PATCH_INFO'.
    WHEN 'VERSIONS_INFO'.
      tabcontrol_info-activetab = 'VERSIONS_INFO'.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
      EXIT.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0550  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0560  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0560 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR wa_plotjobs.
      LEAVE TO SCREEN 0.
      EXIT.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0560  INPUT

*---------------------------------------------------------------------*
*       MODULE USER_COMMAND_0570 INPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE user_command_0570 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_vbeln.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0580  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0580 INPUT.

  CASE fcode.
    WHEN 'BACK'.
      IF NOT html_control IS INITIAL.
        CALL METHOD html_control->free.
        FREE html_control.
      ENDIF.
      IF NOT my_container IS INITIAL.
        CALL METHOD my_container->free
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
*         MESSAGE E002 WITH F_RETURN.
        ENDIF.
        FREE my_container.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'HHOM'.                       " show the home page
      CALL METHOD html_control->go_home.

      CALL METHOD html_control->get_current_url
           IMPORTING
                url  = edurl.

    WHEN 'HBAK'.
      CALL METHOD html_control->go_back.

      CALL METHOD html_control->get_current_url
           IMPORTING
                url  = edurl.

    WHEN 'HFWD'.
      CALL METHOD html_control->go_forward.

      CALL METHOD html_control->get_current_url
           IMPORTING
                url  = edurl.

    WHEN 'HRFR'.
      CALL METHOD html_control->do_refresh.

      CALL METHOD html_control->get_current_url
           IMPORTING
                url  = edurl.

    WHEN 'HNAV'.
      IF NOT edurl IS INITIAL.
        CALL METHOD html_control->show_url
             EXPORTING
                  url = edurl
             EXCEPTIONS
                  cnht_error_parameter = 1
                  OTHERS = 2.
        IF sy-subrc GE 2.
          RAISE cntl_error.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.

  ENDCASE.
  CLEAR fcode.

ENDMODULE.                 " USER_COMMAND_0580  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0590  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0590 INPUT.
  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_vbeln.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0590  INPUT
*&---------------------------------------------------------------------*
*&      Module  VERTEILER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verteiler INPUT.
  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
  DATA: uname_prepro TYPE xubname.
  DATA: wa_tmp_preproz_user TYPE zcl_preproz_user.
* F4 Help.


  SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_preproz_user
    WHERE uname = uname
    AND status = c_status_aktiv
    .
  IF sy-subrc NE 0.
*     Testen, ob eine Zuordnung über eine Rolle vorliegt
    CLEAR uname_prepro.
    CALL FUNCTION '/CIDEON/CHECK_ROLES_FOR_USER'
         EXPORTING
              i_uname        = uname
         IMPORTING
              o_uname_prepro = uname_prepro
         EXCEPTIONS
              no_role        = 1
              error          = 2
              OTHERS         = 3.
    IF sy-subrc <> 0.
      SET PARAMETER ID 'ZCL_UNAME_GET'
        FIELD default_nutzer.
    ELSE.
      SET PARAMETER ID 'ZCL_UNAME_GET'
        FIELD uname.
    ENDIF.
  ELSE.
    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD uname.
  ENDIF.


  tmp_sy_repid = sy-repid.


* ZCL_V_PRE_US_VER
  DATA: itab_data TYPE TABLE OF zcl_v_pre_us_ver.
  DATA: itab_ret TYPE TABLE OF ddshretval.
  DATA: wa_ret TYPE ddshretval.
  DATA: tmp_get_uname TYPE xubname.

  CLEAR tmp_get_uname.
  GET PARAMETER ID 'ZCL_UNAME_GET' FIELD tmp_get_uname.

  SELECT * FROM zcl_v_pre_us_ver INTO TABLE itab_data
    WHERE uname = tmp_get_uname
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      ddic_structure         = 'ZCL_V_PRE_US_VER'
      retfield               = 'VERTEILER'
*           PVALKEY                = ' '
*           DYNPPROG               = ' '
*           DYNPNR                 = ' '
*           DYNPROFIELD            = ' '
*           STEPL                  = 0
*           WINDOW_TITLE           =
*           VALUE                  = ' '
      value_org              = 'S'
*           MULTIPLE_CHOICE        = ' '
*           DISPLAY                = ' '
*           CALLBACK_PROGRAM       = ' '
*           CALLBACK_FORM          = ' '
    TABLES
      value_tab              = itab_data
*           FIELD_TAB              =
      return_tab             = itab_ret
*           DYNPFLD_MAPPING        =
    EXCEPTIONS
      parameter_error        = 1
      no_values_found        = 2
      OTHERS                 = 3
            .

  IF itab_ret[] IS INITIAL.
  ELSE.
    LOOP AT itab_ret INTO wa_ret.
    ENDLOOP.
    ask_verteiler = wa_ret-fieldval.
  ENDIF.

*  PERFORM save_wa_akt_plotjobs.
*  CLEAR ok_code.





**************************************************

*  DATA: wa_tmp_verteiler TYPE zcl_verteiler.
** F4 Help.
*
*  SELECT SINGLE * FROM zcl_preproz_user INTO wa_tmp_verteiler
*    WHERE uname = sy-uname
*    AND status = c_status_aktiv
*    .
*  IF sy-subrc NE 0.
*    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_nutzer.
*  ELSE.
*    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD sy-uname.
*  ENDIF.
*
*
**  SELECT SINGLE * FROM zcl_verteiler INTO wa_tmp_verteiler
**    WHERE uname = uname
**    .
**  IF sy-subrc NE 0.
**    SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_nutzer.
**  ELSE.
**    IF uname IS INITIAL.
**     SET PARAMETER ID 'ZCL_UNAME_GET' FIELD default_nutzer.
**    ELSE.
**      SET PARAMETER ID 'ZCL_UNAME_GET' FIELD uname.
**    ENDIF.
**  ENDIF.
*
*  tmp_sy_repid = sy-repid.
*
*  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
*       EXPORTING
*            tabname     = 'ZCL_S_PLOTLIST'
*            fieldname   = 'VERTEILER'
*            dynpprog    = tmp_sy_repid
*            dynpnr      = sy-dynnr
*            dynprofield = 'ASK_VERTEILER'.
*
**  f_f4_voreinstellung = 'X'.


ENDMODULE.                 " VERTEILER  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0575  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0575 INPUT.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_aufnr.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0575  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0510 INPUT.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_kopien.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0510  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0520 INPUT.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
      EXIT.
    WHEN 'CANC'.
      CLEAR ask_notiz.
      RAISE forget.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0520  INPUT
