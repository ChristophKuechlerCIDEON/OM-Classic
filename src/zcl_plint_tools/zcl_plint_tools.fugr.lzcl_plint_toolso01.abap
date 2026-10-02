*----------------------------------------------------------------------*
***INCLUDE LZCL_PLINT_TOOLSO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZCL_TOOLS001_STATUS_01'.
  SET TITLEBAR 'ZCL_TOOLS001_TITLEBAR_01'.

  IF view_container IS INITIAL.
    CREATE OBJECT view_container
      EXPORTING
        container_name              = 'VIEW'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
  ENDIF.
  IF viewer IS INITIAL.
    CALL METHOD c_oi_container_control_creator=>get_document_viewer
      IMPORTING viewer = viewer
      EXCEPTIONS
        unsupported_platform = 1.
    IF sy-subrc NE 0.
      MESSAGE w300(zcl_plint_message_01) WITH
       'unsupported_platform' 'Z_CL_PLINT_TOOLS_VIEW_DOC_001'
       '' ''.
      EXIT.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL METHOD viewer->init_viewer
       EXPORTING parent = view_container
       EXCEPTIONS cntl_error = 1
                  cntl_install_error = 2
                  dp_install_error = 3
                  dp_error = 4.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
  ENDIF.


* Display the document
  CALL METHOD viewer->view_document_from_url
   EXPORTING document_url = url
               show_inplace = 'X'
   EXCEPTIONS  cntl_error = 1
               not_initialized = 2
               dp_error_general = 3
               invalid_parameter = 4.
  IF sy-subrc NE 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    CASE sy-subrc.
      WHEN 3.
        MESSAGE s061(zcl_plint_message_01)
          WITH filename_tmp '' '' ''.
        PERFORM exit_office.
        ok_code = 'EXIT'.
      WHEN OTHERS.
        MESSAGE s062(zcl_plint_message_01)
         WITH filename_tmp '' '' ''.
        PERFORM exit_office.
        ok_code = 'EXIT'.
    ENDCASE.
  ENDIF.






ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'ZCL_TOOLS001_STATUS_01'.
  SET TITLEBAR 'ZCL_TOOLS001_TITLEBAR_01'.

  IF gf_view_cont IS INITIAL.
*   get the mimetype for the file
    PERFORM get_mimetype.

    CREATE OBJECT gf_view_cont
    EXPORTING
        container_name              = 'GF_VIEW_CONT'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
  ENDIF.
  IF gf_view_2d IS INITIAL.

    DATA: f_with_layer(1).
    f_with_layer = 'X'.
    IF f_with_layer = 'X'.
*     Redlining Layer
      DATA: pf_file TYPE filep.
      DATA: ps_draw TYPE draw.
      pf_file = filename_tmp.

      DATA: lf_appl_name TYPE tdwx-appfd.
      DATA: lf_appl_type TYPE tdwx-apptp.


      SELECT SINGLE * FROM draw INTO ps_draw
        WHERE dokar = wa_plotjobs-dokar
        AND doknr = wa_plotjobs-doknr
        AND dokvr = wa_plotjobs-dokvr
        AND doktl = wa_plotjobs-doktl
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

*        break kuechler.

      CALL FUNCTION 'CV120_GET_APPL_TYPE'
        EXPORTING
          pf_dappl              = wa_plotjobs-wsapplication
          pf_apptp              = '1'
*           PF_TYPDT              =
        IMPORTING
          pfx_appl_name         = lf_appl_name
          pfx_appl_type         = lf_appl_type
*            PFX_NO_CHECKOUT       = lf_no_checkout
*           PFX_MAX_SIZE          =
*           PFX_OUTPLACE          =
*           PFX_NO_LEAVE          =
*           PSX_TDWX              =
       EXCEPTIONS
         error                 = 1
         OTHERS                = 2
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF lf_appl_name IS INITIAL.
        lf_appl_name = 'EAIWeb.webviewer2D.1'.
      ELSE.
      ENDIF.

      CALL FUNCTION 'CV121_ECL_OPEN_DOCUMENT'
        EXPORTING
          pf_parent            = gf_view_cont
          pf_ctrl_name         = 'EAIWeb.webviewer2D.1' "lf_appl_name "
          ps_draw              = ps_draw
          pf_master_loio       = wa_plotjobs-application_id
          pf_master_phio       = wa_plotjobs-file_id
         pf_file              = pf_file
*         PF_URL               =
*          PF_MIMETYPE          = ' '
*         PF_USE_DYNP          = ' '
*         PS_FRONTEND          =
*       IMPORTING
*         PFX_NEW_INST         =
*         PFX_FIRST_INST       =
*         PFX_CONTROL          =
       EXCEPTIONS
         cntl_error           = 1
         error                = 2
         OTHERS               = 3
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      EXIT.
    ELSE.
    ENDIF.

    CREATE OBJECT gf_view_2d
           EXPORTING: parent = gf_view_cont
           EXCEPTIONS: others            = 01
                       cntl_system_error = 02
                       cntl_error        = 03.
    IF sy-subrc <> 0.
      IF sy-msgid IS INITIAL .
        MESSAGE s059(zcl_plint_message_01)
          WITH '' '' '' ''.
        PERFORM exit_2d.
        ok_code = 'EXIT'.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    pf_tools = 'X'.

    CALL METHOD gf_view_2d->create_toolbar
         EXPORTING tools           = pf_tools
                   viewer_openfile = space
                   viewer_savefile = space
         EXCEPTIONS OTHERS = 01.
    IF sy-subrc <> 0.
      IF sy-msgid IS INITIAL .
        MESSAGE s059(zcl_plint_message_01)
          WITH '' '' '' ''.
        PERFORM exit_2d.
        ok_code = 'EXIT'.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    IF pf_tools = 'X'.
      gf_view_2d->for_dvs = 'X'.
      gf_view_2d->ask_for_layer_name = 'X'.
    ENDIF.
    CALL METHOD gf_view_2d->set_visible
         EXPORTING visible = 'X'
         EXCEPTIONS OTHERS = 01.

    CALL METHOD gf_view_2d->my_toolbar->set_focus
         EXPORTING control = gf_view_2d->my_toolbar
         EXCEPTIONS OTHERS = 01.

    CALL METHOD gf_view_2d->my_toolbar->set_visible
         EXPORTING visible = 'X'
         EXCEPTIONS OTHERS = 01.

    gf_view = gf_view_2d.

*    concatenate g_mimetype_1 '/' g_mimetype_2 into g_mimetype.
    g_mimetype = 'application/octet-stream'.
    CLEAR g_mimetype.
    CALL METHOD gf_view->open_document
       EXPORTING: markup_forbidden = ''
                file             = filename_tmp
*                file_type        = g_mimetype
       IMPORTING: error_code       = lf_result
       EXCEPTIONS: invalid_file_format = 1
                 permission_denied   = 2
                 file_not_found      = 3
                 bad_file_name       = 4
                 invalid_data        = 5
                 OTHERS              = 10.
    IF sy-subrc NE 0.
      CASE sy-subrc.
        WHEN 3.
          MESSAGE s061(zcl_plint_message_01)
            WITH filename_tmp '' '' ''.
          PERFORM exit_2d.
          ok_code = 'EXIT'.
        WHEN OTHERS.
          MESSAGE s062(zcl_plint_message_01)
           WITH filename_tmp '' '' ''.
          PERFORM exit_2d.
          ok_code = 'EXIT'.
      ENDCASE.
    ELSE.
    ENDIF.


  ELSE.
  ENDIF.


ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'ZCL_TOOLS001_STATUS_01'.
  SET TITLEBAR 'ZCL_TOOLS001_TITLEBAR_01'.

  IF gf_view_cont IS INITIAL.
*   get the mimetype for the file
    PERFORM get_mimetype.

    CREATE OBJECT gf_view_cont
    EXPORTING
        container_name              = 'GF_VIEW_CONT'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
      IF sy-msgid IS INITIAL .
        MESSAGE s059(zcl_plint_message_01)
          WITH '' '' '' ''.
        PERFORM exit_2d.
        ok_code = 'EXIT'.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
  ENDIF.
  IF gf_view_3d IS INITIAL.


*    DATA: f_with_layer(1).
    f_with_layer = 'X'.
    IF f_with_layer = 'X'.
*     Redlining Layer
*      DATA: pf_file TYPE filep.
*      DATA: ps_draw TYPE draw.
      pf_file = filename_tmp.

*      DATA: lf_appl_name TYPE tdwx-appfd.
*      DATA: lf_appl_type TYPE tdwx-apptp.


      SELECT SINGLE * FROM draw INTO ps_draw
        WHERE dokar = wa_plotjobs-dokar
        AND doknr = wa_plotjobs-doknr
        AND dokvr = wa_plotjobs-dokvr
        AND doktl = wa_plotjobs-doktl
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

*        break kuechler.

      CALL FUNCTION 'CV120_GET_APPL_TYPE'
        EXPORTING
          pf_dappl              = wa_plotjobs-wsapplication
          pf_apptp              = '1'
*           PF_TYPDT              =
        IMPORTING
          pfx_appl_name         = lf_appl_name
          pfx_appl_type         = lf_appl_type
*            PFX_NO_CHECKOUT       = lf_no_checkout
*           PFX_MAX_SIZE          =
*           PFX_OUTPLACE          =
*           PFX_NO_LEAVE          =
*           PSX_TDWX              =
       EXCEPTIONS
         error                 = 1
         OTHERS                = 2
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF lf_appl_name IS INITIAL.
        lf_appl_name = 'EAIWeb.webviewer3D.1'.
      ELSE.
      ENDIF.

      CALL FUNCTION 'CV121_ECL_OPEN_DOCUMENT'
        EXPORTING
          pf_parent            = gf_view_cont
          pf_ctrl_name         = 'EAIWeb.webviewer3D.1' "lf_appl_name "
          ps_draw              = ps_draw
          pf_master_loio       = wa_plotjobs-application_id
          pf_master_phio       = wa_plotjobs-file_id
         pf_file              = pf_file
*         PF_URL               =
*          PF_MIMETYPE          = ' '
*         PF_USE_DYNP          = ' '
*         PS_FRONTEND          =
*       IMPORTING
*         PFX_NEW_INST         =
*         PFX_FIRST_INST       =
*         PFX_CONTROL          =
       EXCEPTIONS
         cntl_error           = 1
         error                = 2
         OTHERS               = 3
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      EXIT.
    ELSE.
    ENDIF.




    CREATE OBJECT gf_view_3d
           EXPORTING: parent = gf_view_cont
           EXCEPTIONS: others            = 01
                       cntl_system_error = 02
                       cntl_error        = 03.
    IF sy-subrc <> 0.
      IF sy-msgid IS INITIAL .
        MESSAGE s059(zcl_plint_message_01)
          WITH '' '' '' ''.
        PERFORM exit_2d.
        ok_code = 'EXIT'.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    pf_tools = 'X'.

    CALL METHOD gf_view_3d->create_toolbar
         EXPORTING tools           = pf_tools
                   viewer_openfile = space
                   viewer_savefile = space
         EXCEPTIONS OTHERS = 01.

    IF pf_tools = 'X'.
      gf_view_3d->for_dvs = 'X'.
*      gf_view_3d->ask_for_layer_name = 'X'.
    ENDIF.
    CALL METHOD gf_view_3d->set_visible
         EXPORTING visible = 'X'
         EXCEPTIONS OTHERS = 01.

    CALL METHOD gf_view_3d->my_toolbar->set_focus
         EXPORTING control = gf_view_3d->my_toolbar
         EXCEPTIONS OTHERS = 01.

    CALL METHOD gf_view_3d->my_toolbar->set_visible
         EXPORTING visible = 'X'
         EXCEPTIONS OTHERS = 01.

    gf_view = gf_view_3d.

*    concatenate g_mimetype_1 '/' g_mimetype_2 into g_mimetype.
    g_mimetype = 'application/octet-stream'.
    CLEAR g_mimetype.
    CALL METHOD gf_view->open_document
       EXPORTING: markup_forbidden = ''
                file             = filename_tmp
*                file_type        = g_mimetype
       IMPORTING: error_code       = lf_result
       EXCEPTIONS: invalid_file_format = 1
                 permission_denied   = 2
                 file_not_found      = 3
                 bad_file_name       = 4
                 invalid_data        = 5
                 OTHERS              = 10.
    IF sy-subrc NE 0.
      CASE sy-subrc.
        WHEN 3.
          MESSAGE s061(zcl_plint_message_01)
            WITH filename_tmp '' '' ''.
          PERFORM exit_3d.
          ok_code = 'EXIT'.
        WHEN OTHERS.
          MESSAGE s062(zcl_plint_message_01)
           WITH filename_tmp '' '' ''.
          PERFORM exit_3d.
          ok_code = 'EXIT'.
      ENDCASE.
    ELSE.
    ENDIF.


  ELSE.
  ENDIF.


ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS 'ZCL_PF_ASK_FOR_PRIO'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0600 OUTPUT.
  SET PF-STATUS 'ZCL_PF_ASK_DOK_NR'.
  SET TITLEBAR '0600'.

  IF zcl_s_draw01 IS INITIAL.
    GET PARAMETER ID 'CV1' FIELD zcl_s_draw01-doknr.
    GET PARAMETER ID 'CV2' FIELD zcl_s_draw01-dokar.
    GET PARAMETER ID 'CV3' FIELD zcl_s_draw01-dokvr.
    GET PARAMETER ID 'CV4' FIELD zcl_s_draw01-doktl.
  ELSE.
  ENDIF.

*  GET PARAMETER ID 'CV1' FIELD doknr.
*  GET PARAMETER ID 'CV2' FIELD dokar.
*  GET PARAMETER ID 'CV3' FIELD dokvr.
*  GET PARAMETER ID 'CV4' FIELD doktl.
*
*  zcl_s_draw01-dokar = dokar.
*  zcl_s_draw01-doknr = doknr.
*  zcl_s_draw01-doktl = doktl.
*  zcl_s_draw01-dokvr = dokvr.

*  zcl_s_draw01-dokvr = '1'.

*  EXIT.
*
*
*  LOOP AT SCREEN.
*    IF screen-group1 = 'NOT'.
*      screen-invisible = '0'.
*      screen-input = '0'.
*      screen-output = '1'.
*      screen-active = '1'.
*      MODIFY SCREEN.
*    ELSE.
*    ENDIF.
*  ENDLOOP.
ENDMODULE.                 " STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS 'ZCL_PF_VIEW_INFO'.
*  SET TITLEBAR 'xxx'.
  IF picture IS INITIAL.

    CREATE OBJECT cc_picture
      EXPORTING
        container_name              = 'CC_PICTURE'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    CREATE OBJECT picture
      EXPORTING
        parent = cc_picture
      EXCEPTIONS
        error  = 1
        others = 2
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD picture->load_picture_from_url
      EXPORTING
        url    = l_url
*      IMPORTING
*        RESULT =
      EXCEPTIONS
        error  = 1
        OTHERS = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD picture->set_3d_border
      EXPORTING
        border =  '1'
      EXCEPTIONS
        error  = 1
        OTHERS = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*    CALL METHOD picture->set_height
*      EXPORTING
*        height     = 50
*      EXCEPTIONS
*        cntl_error = 1
*        OTHERS     = 2
*            .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.

    CALL METHOD picture->get_height
      IMPORTING
        height     = picture_height
      EXCEPTIONS
        cntl_error = 1
        OTHERS     = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD picture->get_width
      IMPORTING
        width      = picture_width
      EXCEPTIONS
        cntl_error = 1
        OTHERS     = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
  ENDIF.

ENDMODULE.                 " STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.
  SET PF-STATUS 'ZCL_PF_SHOW_DOKS'.
  SET TITLEBAR 'ZCL_TB_SHOW_DOKS'.

  IF fail_document_container IS INITIAL.
    CREATE OBJECT fail_document_container
      EXPORTING
*        PARENT                      =
        container_name              = 'CUST_CONTRL_FAIL_DOCUMENTS'
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        REPID                       =
*        DYNNR                       =
*        NO_AUTODEF_PROGID_DYNNR     =
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT fail_document_alv
      EXPORTING
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
        i_parent          = fail_document_container
*        I_APPL_EVENTS     = space
*        I_PARENTDBG       =
*        I_APPLOGPARENT    =
*        I_GRAPHICSPARENT  =
*        I_USE_VARIANT_CLASS = SPACE
*        I_NAME            =
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        others            = 5
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
     EXPORTING
*       I_BUFFER_ACTIVE              =
       i_structure_name             = 'ZCL_S_FAIL_DOCUMENT_ALV'
*       I_CLIENT_NEVER_DISPLAY       = 'X'
*       I_BYPASSING_BUFFER           =
      CHANGING
        ct_fieldcat                  = itab_fc_fail_document
     EXCEPTIONS
       inconsistent_interface       = 1
       program_error                = 2
       OTHERS                       = 3
              .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    LOOP AT itab_fc_fail_document INTO wa_fc_fail_document.
      IF wa_fc_fail_document-fieldname = 'STATUS'.
        wa_fc_fail_document-icon = 'X'.
        wa_fc_fail_document-outputlen = 5.
        wa_fc_fail_document-no_out = 'X'.
        MODIFY itab_fc_fail_document FROM wa_fc_fail_document
          INDEX sy-tabix.
      ELSE.
      ENDIF.
    ENDLOOP.

    CLEAR g_layo_fail_document_alv.

    g_layo_fail_document_alv-sel_mode = 'A'.
    g_layo_fail_document_alv-excp_fname = 'LIGHT'.
    g_layo_fail_document_alv-excp_led = g_led_style.



    CALL METHOD fail_document_alv->set_table_for_first_display
      EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
        i_structure_name              = 'ZCL_S_FAIL_DOCUMENT_ALV'
*        IS_VARIANT                    =
*        I_SAVE                        =
*        I_DEFAULT                     = 'X'
        is_layout                     = g_layo_fail_document_alv
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
      CHANGING
        it_outtab                     = itab_fail_document_alv
        it_fieldcatalog               = itab_fc_fail_document
*        IT_SORT                       =
*        IT_FILTER                     =
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD fail_document_alv->refresh_table_display
*      EXPORTING
*        IS_STABLE      =
*        I_SOFT_REFRESH =
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    SET HANDLER
      list_handler->catch_dblclick FOR fail_document_alv.

  ELSE.
  ENDIF.

  IF g_first = 'X'.
    CALL METHOD fail_document_alv->refresh_table_display
*      EXPORTING
*        IS_STABLE      =
*        I_SOFT_REFRESH =
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    g_first = ''.
  ELSE.
  ENDIF.

ENDMODULE.                 " STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0800 OUTPUT.
  SET PF-STATUS 'ZCL_PF_SHOW_ZORI'.
  SET TITLEBAR 'ZCL_TB_SHOW_ZORI'.

  IF zori_document_container IS INITIAL.

    CREATE OBJECT zori_document_container
      EXPORTING
*        PARENT                      =
        container_name              = 'CUST_CONTRL_ZORI_DOC_FILES'
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        REPID                       =
*        DYNNR                       =
*        NO_AUTODEF_PROGID_DYNNR     =
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT zori_document_alv
      EXPORTING
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
        i_parent          = zori_document_container
*        I_APPL_EVENTS     = space
*        I_PARENTDBG       =
*        I_APPLOGPARENT    =
*        I_GRAPHICSPARENT  =
*        I_USE_VARIANT_CLASS = SPACE
*        I_NAME            =
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        others            = 5
        .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    CLEAR g_layo_zori_alv.
    g_layo_zori_alv-sel_mode = 'A'.

    CALL METHOD zori_document_alv->set_table_for_first_display
      EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
        i_structure_name              = 'ZORI_DOC_FILES'
*        IS_VARIANT                    =
*        I_SAVE                        =
*        I_DEFAULT                     = 'X'
        is_layout                     = g_layo_zori_alv
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
      CHANGING
        it_outtab                     = itab_zori_doc_files_alv
*        it_fieldcatalog               =
*        IT_SORT                       =
*        IT_FILTER                     =
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD zori_document_alv->refresh_table_display
*      EXPORTING
*        IS_STABLE      =
*        I_SOFT_REFRESH =
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.
  ENDIF.

  IF g_first = 'X'.
    CALL METHOD zori_document_alv->refresh_table_display
*      EXPORTING
*        IS_STABLE      =
*        I_SOFT_REFRESH =
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    g_first = ''.
  ELSE.
  ENDIF.

ENDMODULE.                 " STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0550  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0550 OUTPUT.
  SET PF-STATUS 'ZCL_INFO_DIALOG_2'.
*  SET TITLEBAR 'xxx'.

*  IF info_edit_container IS INITIAL.
*    CREATE OBJECT info_edit_container
*      EXPORTING
**        PARENT                      =
*        container_name              = 'CC_INFO'
**        STYLE                       =
**        LIFETIME                    = lifetime_default
**        REPID                       =
**        DYNNR                       =
**        NO_AUTODEF_PROGID_DYNNR     =
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        lifetime_dynpro_dynpro_link = 5
*        others                      = 6
*        .
*    IF sy-subrc <> 0.
**     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ELSE.
*    ENDIF.
*    IF info_edit IS INITIAL.
*      CREATE OBJECT info_edit
*        EXPORTING
**          MAX_NUMBER_CHARS       =
*           style                  = 0
**          WORDWRAP_MODE          = WORDWRAP_AT_WINDOWBORDER
**          WORDWRAP_POSITION      = -1
**          WORDWRAP_TO_LINEBREAK_MODE = FALSE
**          FILEDROP_MODE          = DROPFILE_EVENT_OFF
*          parent                 = info_edit_container
**          LIFETIME               =
**          NAME                   =
*        EXCEPTIONS
*          error_cntl_create      = 1
*          error_cntl_init        = 2
*          error_cntl_link        = 3
*          error_dp_create        = 4
*          gui_type_not_supported = 5
*          others                 = 6
*          .
*      IF sy-subrc <> 0.
**       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*      CALL METHOD info_edit->set_statusbar_mode
*        EXPORTING
*          statusbar_mode         = 0
*        EXCEPTIONS
*          error_cntl_call_method = 1
*          invalid_parameter      = 2
*          OTHERS                 = 3
*              .
*      IF sy-subrc <> 0.
**       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*      CALL METHOD info_edit->set_toolbar_mode
*        EXPORTING
*          toolbar_mode           = 0
*        EXCEPTIONS
*          error_cntl_call_method = 1
*          invalid_parameter      = 2
*          OTHERS                 = 3
*              .
*      IF sy-subrc <> 0.
**       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*      CALL METHOD info_edit->set_text_as_r3table
*        EXPORTING
*          table           = itab_info
*        EXCEPTIONS
*          error_dp        = 1
*          error_dp_create = 2
*          OTHERS          = 3
*              .
*      IF sy-subrc <> 0.
**       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*      CALL METHOD info_edit->set_readonly_mode
*        EXPORTING
*          readonly_mode          = 1
*        EXCEPTIONS
*          error_cntl_call_method = 1
*          invalid_parameter      = 2
*          OTHERS                 = 3
*              .
*      IF sy-subrc <> 0.
**       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*
*
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.
*



ENDMODULE.                 " STATUS_0550  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0560  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0560 OUTPUT.
  SET PF-STATUS 'ZCL_PF_ASK_FOR_SELECT'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0560  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0580  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0580 OUTPUT.
  SET PF-STATUS 'TESTHTM1'.
  SET TITLEBAR '001'.

  IF html_dock_container IS INITIAL.
    CREATE OBJECT html_dock_container
      EXPORTING
*        PARENT                      =
*        REPID                       =
*        DYNNR                       =
*        SIDE                        = DOCK_AT_LEFT
        extension                   = 800
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        CAPTION                     =
*        METRIC                      = 0
*        RATIO                       =
*        NO_AUTODEF_PROGID_DYNNR     =
*        NAME                        =
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    CALL METHOD html_dock_container->dock_at
      EXPORTING
        side              = cl_gui_docking_container=>dock_at_top
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.


*  IF my_container IS INITIAL.
*
*    CREATE OBJECT my_container
*        EXPORTING
*            container_name = 'HTML'
*        EXCEPTIONS
*            others = 1.
*    CASE sy-subrc.
*      WHEN 0.
**
*      WHEN OTHERS.
*        RAISE cntl_error.
*    ENDCASE.
*  ENDIF.

  IF html_control IS INITIAL.
    CREATE OBJECT html_control
         EXPORTING
              parent    = html_dock_container "my_container
          .
    IF sy-subrc NE 0.
      RAISE cntl_error.
    ENDIF.

    alignment = html_control->align_at_left +
                html_control->align_at_right +
                html_control->align_at_top +
                html_control->align_at_bottom.

    CALL METHOD html_control->set_alignment
       EXPORTING
         alignment = alignment.

* register event
    myevent-eventid = html_control->m_id_navigate_complete.
    myevent-appl_event = 'X'.
    APPEND myevent TO myevent_tab.
    CALL METHOD html_control->set_registered_events
        EXPORTING
           events = myevent_tab.

    CREATE OBJECT evt_receiver.

    SET HANDLER evt_receiver->on_navigate_complete
                FOR html_control.

    PERFORM load_home_page.
    CALL METHOD html_control->show_url
     EXPORTING
          url       = edurl.

  ENDIF.

ENDMODULE.                 " STATUS_0580  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0551  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0551 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  IF info_edit_container IS INITIAL.
    CREATE OBJECT info_edit_container
      EXPORTING
*        PARENT                      =
        container_name              = 'CC_INFO'
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        REPID                       =
*        DYNNR                       =
*        NO_AUTODEF_PROGID_DYNNR     =
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
    ENDIF.
    IF info_edit IS INITIAL.
      CREATE OBJECT info_edit
        EXPORTING
*          MAX_NUMBER_CHARS       =
           style                  = 0
*          WORDWRAP_MODE          = WORDWRAP_AT_WINDOWBORDER
*          WORDWRAP_POSITION      = -1
*          WORDWRAP_TO_LINEBREAK_MODE = FALSE
*          FILEDROP_MODE          = DROPFILE_EVENT_OFF
          parent                 = info_edit_container
*          LIFETIME               =
*          NAME                   =
        EXCEPTIONS
          error_cntl_create      = 1
          error_cntl_init        = 2
          error_cntl_link        = 3
          error_dp_create        = 4
          gui_type_not_supported = 5
          others                 = 6
          .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit->set_statusbar_mode
        EXPORTING
          statusbar_mode         = 0
        EXCEPTIONS
          error_cntl_call_method = 1
          invalid_parameter      = 2
          OTHERS                 = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit->set_toolbar_mode
        EXPORTING
          toolbar_mode           = 0
        EXCEPTIONS
          error_cntl_call_method = 1
          invalid_parameter      = 2
          OTHERS                 = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit->set_text_as_r3table
        EXPORTING
          table           = itab_info
        EXCEPTIONS
          error_dp        = 1
          error_dp_create = 2
          OTHERS          = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit->set_readonly_mode
        EXPORTING
          readonly_mode          = 1
        EXCEPTIONS
          error_cntl_call_method = 1
          invalid_parameter      = 2
          OTHERS                 = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


ENDMODULE.                 " STATUS_0551  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0552  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0552 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  IF info_edit_container_pa IS INITIAL.
    CREATE OBJECT info_edit_container_pa
      EXPORTING
*        PARENT                      =
        container_name              = 'CC_PATCH'
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        REPID                       =
*        DYNNR                       =
*        NO_AUTODEF_PROGID_DYNNR     =
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
    ENDIF.
    IF info_edit_pa IS INITIAL.
      CREATE OBJECT info_edit_pa
        EXPORTING
*          MAX_NUMBER_CHARS       =
           style                  = 0
*          WORDWRAP_MODE          = WORDWRAP_AT_WINDOWBORDER
*          WORDWRAP_POSITION      = -1
*          WORDWRAP_TO_LINEBREAK_MODE = FALSE
*          FILEDROP_MODE          = DROPFILE_EVENT_OFF
          parent                 = info_edit_container_pa
*          LIFETIME               =
*          NAME                   =
        EXCEPTIONS
          error_cntl_create      = 1
          error_cntl_init        = 2
          error_cntl_link        = 3
          error_dp_create        = 4
          gui_type_not_supported = 5
          others                 = 6
          .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit_pa->set_statusbar_mode
        EXPORTING
          statusbar_mode         = 0
        EXCEPTIONS
          error_cntl_call_method = 1
          invalid_parameter      = 2
          OTHERS                 = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit_pa->set_toolbar_mode
        EXPORTING
          toolbar_mode           = 0
        EXCEPTIONS
          error_cntl_call_method = 1
          invalid_parameter      = 2
          OTHERS                 = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit_pa->set_text_as_r3table
        EXPORTING
          table           = itab_info_pa
        EXCEPTIONS
          error_dp        = 1
          error_dp_create = 2
          OTHERS          = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CALL METHOD info_edit_pa->set_readonly_mode
        EXPORTING
          readonly_mode          = 1
        EXCEPTIONS
          error_cntl_call_method = 1
          invalid_parameter      = 2
          OTHERS                 = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


    ELSE.
    ENDIF.
  ELSE.
  ENDIF.

ENDMODULE.                 " STATUS_0552  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0590  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0590 OUTPUT.
  SET PF-STATUS 'ZCL_PF_ASK_FOR_VERT'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0590  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0575  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0575 OUTPUT.
  SET PF-STATUS 'ZCL_PF_ASK_FOR_AUFNR'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0575  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0510 OUTPUT.
  SET PF-STATUS 'ZCL_PF_ASK_FOR_KOPIEN'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0510  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0520  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0520 OUTPUT.
  SET PF-STATUS 'ZCL_PF_ASK_FOR_NOTIZ'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0520  OUTPUT
