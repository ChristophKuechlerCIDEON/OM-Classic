*----------------------------------------------------------------------*
*   INCLUDE ZCL_MAINTAIN_PLINT_CFG_00O01                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_MAINTAIN_PLINT_CFG_00'.
  SET TITLEBAR 'TITLE_MAINTAIN_STAMP_VOREIN'.

  IF obj_docking_container IS INITIAL.
    CREATE OBJECT obj_docking_container
      EXPORTING
*        PARENT                      =
*        REPID                       =
*        DYNNR                       =
*        SIDE                        = DOCK_AT_TOP
        extension                   = 350
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        CAPTION                     =
        metric                      = 0
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
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL METHOD obj_docking_container->dock_at
      EXPORTING
        side              = cl_gui_docking_container=>dock_at_top
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT obj_alv_grid
      EXPORTING
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
         i_parent          = obj_docking_container
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

    g_layo_alv-sel_mode = 'B'.

    CALL METHOD obj_alv_grid->set_table_for_first_display
      EXPORTING
*    I_BYPASSING_BUFFER            =
*    I_BUFFER_ACTIVE               =
*    I_CONSISTENCY_CHECK           =
        i_structure_name              = 'ZCL_STAMP_VOREIN'
*    IS_VARIANT                    =
*    I_SAVE                        =
*    I_DEFAULT                     = 'X'
    is_layout                     = g_layo_alv
*    IS_PRINT                      =
*    IT_SPECIAL_GROUPS             =
*    IT_TOOLBAR_EXCLUDING          =
*    IT_HYPERLINK                  =
*    IT_ALV_GRAPHICS               =
      CHANGING
        it_outtab                     = itab_stamp_vorein
*    IT_FIELDCATALOG               =
*    IT_SORT                       =
*    IT_FILTER                     =
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

    SET HANDLER
      alv_event_handler->catch_dblclick FOR obj_alv_grid.
    SET HANDLER
      alv_event_handler->handle_user_command FOR obj_alv_grid.

  ELSE.
  ENDIF.


* checks, what the active Tab is then choose the Status
  CASE tabstripcontrol_001-activetab.
    WHEN 'TAB1'.
    WHEN 'TAB2'.
  ENDCASE.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.

*  Sri......Modifications on Sat.28thSept2002..Begin

*  To Toggle the Display & Change of the Screen Attributes.
  IF lv_flag_toggle_edit EQ '0'.
    LOOP AT SCREEN .
      IF screen-name CS 'WA_STAMP_VOREIN'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF lv_flag_toggle_edit EQ '1'.
    LOOP AT SCREEN.
      IF screen-name CS 'WA_STAMP_VOREIN'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*  Sri......Modifications on Sat.28thSept2002..Ende

ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0102 OUTPUT.

*  Sri......Modifications on Sat.28thSept2002..Begin

*  To Toggle the Display & Change of the Screen Attributes.
  IF lv_flag_toggle_edit EQ '0'.
    LOOP AT SCREEN .
      IF screen-name CS 'WA_STAMP_VOREIN'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.


  ELSEIF lv_flag_toggle_edit EQ '1'.
    LOOP AT SCREEN.
      IF screen-name CS 'WA_STAMP_VOREIN'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  Sri......Modifications on Sat.28thSept2002..ende

ENDMODULE.                 " STATUS_0102  OUTPUT
