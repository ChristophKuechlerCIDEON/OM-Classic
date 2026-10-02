*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOTINFOO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.



ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '300'.

  IF editor IS INITIAL.
    CREATE OBJECT cc_editor
    EXPORTING container_name = 'CC_EDITOR'.
    IF sy-subrc <> 0.
    ENDIF.

    CREATE OBJECT editor
      EXPORTING
*         MAX_NUMBER_CHARS       = '80'
*        STYLE                  = 0
*        WORDWRAP_MODE          = WORDWRAP_AT_WINDOWBORDER
*        WORDWRAP_POSITION      = -1
*        WORDWRAP_TO_LINEBREAK_MODE = FALSE
*        FILEDROP_MODE          = DROPFILE_EVENT_OFF
        parent                 = cc_editor
*        LIFETIME               =
*        NAME                   =
       EXCEPTIONS
         error_cntl_create      = 1
         error_cntl_init        = 2
         error_cntl_link        = 3
         error_dp_create        = 4
         gui_type_not_supported = 5
         others                 = 6
        .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL METHOD cl_gui_textedit=>set_focus
      EXPORTING
        control           = editor
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


* Daten setzen
  CALL METHOD editor->set_text_as_r3table
     EXPORTING
       table           = it_text
     EXCEPTIONS
       error_dp        = 1
       error_dp_create = 2
       OTHERS          = 3
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDMODULE.                 " status_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0301  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0301 OUTPUT.

  DATA: ls_text TYPE zcl_stempel_wert,
        ls_outtab TYPE /cideon/s_verteiler,
        ls_styl TYPE lvc_s_styl.

  DATA: lt_ct TYPE lvc_t_styl.

  DATA: ls_preprozessor TYPE zcl_preprozessor.

  FIELD-SYMBOLS: <fieldcat> TYPE lvc_s_fcat.

  SET PF-STATUS '0300'.
  SET TITLEBAR '300'.

*  MESSAGE W009(/cideon/plot_basis).
*   Eingaben müssen mit ENTER bestätigt werden!

*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      TITLEBAR                    = text-002
**     DIAGNOSE_OBJECT             = ' '
*      text_question               = text-001
**     TEXT_BUTTON_1               = 'Ja'(001)
**     ICON_BUTTON_1               = ' '
**     TEXT_BUTTON_2               = 'Nein'(002)
**     ICON_BUTTON_2               = ' '
**     DEFAULT_BUTTON              = '1'
*      DISPLAY_CANCEL_BUTTON       = ''
**     USERDEFINED_F1_HELP         = ' '
**     START_COLUMN                = 25
**     START_ROW                   = 6
**     POPUP_TYPE                  =
**   IMPORTING
**     ANSWER                      =
**   TABLES
**     PARAMETER                   =
**   EXCEPTIONS
**     TEXT_NOT_FOUND              = 1
**     OTHERS                      = 2
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.



  IF editor IS INITIAL.
    CREATE OBJECT cc_editor
      EXPORTING
        container_name              =  'CC_EDITOR'
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


    g_variant-report = sy-repid.

    g_layout-zebra = 'X'.
    g_layout-sel_mode = 'X'.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
         EXPORTING
              i_structure_name       = '/CIDEON/S_VERTEILER'
         CHANGING
              ct_fieldcat            = gt_fieldcat
         EXCEPTIONS
              inconsistent_interface = 1
              program_error          = 2
              OTHERS                 = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT gt_fieldcat ASSIGNING <fieldcat>.
      <fieldcat>-edit = 'X'.
    ENDLOOP.


** Outtab refreshen
    REFRESH gt_outtab.


** Verteiler Beschreibung holen
    LOOP AT it_text INTO ls_text.
      SELECT SINGLE *
        INTO ls_preprozessor
        FROM zcl_preprozessor
        WHERE preprozessor = g_preprocessor AND
              verteiler = ls_text.

      IF sy-subrc = 0.
        ls_outtab-verteiler = ls_preprozessor-verteiler.
        ls_outtab-beschreibung = ls_preprozessor-beschreibung.

        ls_styl-fieldname = 'BESCHREIBUNG'.
        ls_styl-style = cl_gui_alv_grid=>mc_style_enabled.
        APPEND ls_styl TO lt_ct.

        ls_styl-fieldname = 'VERTEILER'.
        ls_styl-style = cl_gui_alv_grid=>mc_style_enabled.
        APPEND ls_styl TO lt_ct.


        ls_outtab-ct[] = lt_ct[].
        APPEND ls_outtab TO gt_outtab.

        REFRESH lt_ct.
        CLEAR ls_outtab.
      ENDIF.

    ENDLOOP.



    IF g_alv_grid IS INITIAL.
      CREATE OBJECT g_alv_grid
        EXPORTING
          i_parent          =  cc_editor
        EXCEPTIONS
          error_cntl_create = 1
          error_cntl_init   = 2
          error_cntl_link   = 3
          error_dp_create   = 4
          others            = 5
          .
      IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


      CALL METHOD g_alv_grid->set_table_for_first_display
        EXPORTING
          i_bypassing_buffer            = 'X'
          i_structure_name              = '/CIDEON/S_VERTEILER'
          is_variant                    =  g_variant
          i_save                        = 'A'
          i_default                     = 'X'
          is_layout                     =  g_layout
*          IS_PRINT                      =
*          IT_SPECIAL_GROUPS             =
*          IT_TOOLBAR_EXCLUDING          =
*          IT_HYPERLINK                  =
*          IT_ALV_GRAPHICS               =
*          IT_EXCEPT_QINFO               =
        CHANGING
          it_outtab                     =  gt_outtab
          it_fieldcatalog               = gt_fieldcat
*          IT_SORT                       =
*          IT_FILTER                     =
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

* Register events
      CALL METHOD g_alv_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified.

      CALL METHOD g_alv_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 1.
    ELSE.

      CALL METHOD g_alv_grid->refresh_table_display.

    ENDIF.
  ENDIF.

ENDMODULE.                 " status_0301  OUTPUT
