*----------------------------------------------------------------------*
*   INCLUDE ZCK_CFG_00_ALV_EDIT_PBO                                    *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  REFRESH it_excl.
  IF max_lines = 0.
    wa_excl-fcode = 'SAVE'.
    APPEND wa_excl TO it_excl.
    wa_excl-fcode = 'DEL'.
    APPEND wa_excl TO it_excl.
    wa_excl-fcode = 'START'.
    APPEND wa_excl TO it_excl.
    wa_excl-fcode = 'PREV'.
    APPEND wa_excl TO it_excl.
    wa_excl-fcode = 'NEXT'.
    APPEND wa_excl TO it_excl.
    wa_excl-fcode = 'END'.
    APPEND wa_excl TO it_excl.
    wa_excl-fcode = 'USER'.
    APPEND wa_excl TO it_excl.
  ELSE.
    IF wa_edit_mode = co_show_mode.
      wa_excl-fcode = 'SAVE'.
      APPEND wa_excl TO it_excl.
      wa_excl-fcode = 'DEL'.
      APPEND wa_excl TO it_excl.
    ENDIF.
    IF max_lines = 1.
      wa_excl-fcode = 'START'.
      APPEND wa_excl TO it_excl.
      wa_excl-fcode = 'PREV'.
      APPEND wa_excl TO it_excl.
      wa_excl-fcode = 'NEXT'.
      APPEND wa_excl TO it_excl.
      wa_excl-fcode = 'END'.
      APPEND wa_excl TO it_excl.
    ENDIF.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-group1 = 'KEY'.
      IF wa_edit_mode = '2'.
        screen-input    = '1'.
*        screen-required = '1'.
      ELSE.
        screen-input = '0'.
      ENDIF.
    ELSEIF screen-group1 = 'DAT'.
      IF wa_edit_mode = '0'.
        screen-input = '0'.
      ELSE.
        screen-input = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  SET PF-STATUS '100' EXCLUDING it_excl.
  SET TITLEBAR '100'.

  IF dynp IS INITIAL.
    dynp = '101'.
  ENDIF.

  tabstr-activetab = dynp.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_CONTROLS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_controls_0100 OUTPUT.

* wenn objekt noch nicht angelegt, dann kreieren.
  IF ref_container IS INITIAL.
    CLEAR g_repid.
    g_repid = sy-repid.

    CREATE OBJECT ref_container
      EXPORTING
*        PARENT                      =
        repid                       = g_repid
        dynnr                       = sy-dynnr
        side                        =
                    cl_gui_docking_container=>dock_at_top
        extension                   = 150
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        CAPTION                     =
*        METRIC                      = 0
*        RATIO                       =
*        NO_AUTODEF_PROGID_DYNNR     =
*        NAME                        =
*      EXCEPTIONS
*        CNTL_ERROR                  = 1
*        CNTL_SYSTEM_ERROR           = 2
*        CREATE_ERROR                = 3
*        LIFETIME_ERROR              = 4
*        LIFETIME_DYNPRO_DYNPRO_LINK = 5
*        others                      = 6
        .

    CALL METHOD ref_container->dock_at
      EXPORTING
        side              = cl_gui_docking_container=>dock_at_top
*      EXCEPTIONS
*        CNTL_ERROR        = 1
*        CNTL_SYSTEM_ERROR = 2
*        others            = 3
            .


*    CREATE OBJECT ref_container
*      EXPORTING
*        container_name              = 'MY_CONTAINER'.

    CREATE OBJECT ref_alv
      EXPORTING
        i_parent          = ref_container.


*CALL METHOD ref_alv->set_table_for_first_display
*  EXPORTING
*    I_BUFFER_ACTIVE               =
*    I_STRUCTURE_NAME              =
*    IS_VARIANT                    =
*    I_SAVE                        =
*    I_DEFAULT                     = 'X'
*    IS_PRINT                      =
*    IT_SPECIAL_GROUPS             =
*    IT_TOOLBAR_EXCLUDING          =
*  CHANGING
*    it_outtab                     =
*    IT_FIELDCATALOG               =
*    IT_SORT                       =
*    IT_FILTER                     =
*  EXCEPTIONS
*    INVALID_PARAMETER_COMBINATION = 1
*    PROGRAM_ERROR                 = 2
*    others                        = 3


* set layout
* mark column
    wa_s_layo-sel_mode   = 'A'.
    wa_s_layo-zebra      = 'X'.
*    wa_s_layo-no_hgridln = 'X'.
*    wa_s_layo-no_vgridln = 'X'.

* variant
    wa_s_variant-report = sy-repid.

* field catalog
    PERFORM set_field_catalog.

    CALL METHOD ref_alv->set_table_for_first_display
       EXPORTING
         i_structure_name     =  tabname
         is_layout            =  wa_s_layo
         is_variant           =  wa_s_variant
         i_save               =  co_variant_both
         i_default            = 'X'
      CHANGING
        it_outtab             = it
        it_fieldcatalog       = it_field_cat
        .

    SET HANDLER lcl_event_handler=>on_double_click FOR ref_alv.
  ENDIF.
ENDMODULE.                             " INIT_CONTROLS_0100  OUTPUT



*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'KEY'.
      IF wa_edit_mode = '2'.
        screen-input    = '1'.
*        screen-required = '1'.
      ELSE.
        screen-input = '0'.
      ENDIF.
    ELSEIF screen-group1 = 'DAT'.
      IF wa_edit_mode = '0'.
        screen-input = '0'.
      ELSE.
        screen-input = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0111 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  LOOP AT SCREEN.
    IF screen-group1 = 'KEY'.
      IF wa_edit_mode = '2'.
        screen-input    = '1'.
*        screen-required = '1'.
      ELSE.
        screen-input = '0'.
      ENDIF.
    ELSEIF screen-group1 = 'DAT'.
      IF wa_edit_mode = '0'.
        screen-input = '0'.
      ELSE.
        screen-input = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " STATUS_0111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_content  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_content OUTPUT.

  CLEAR zcl_plint_config.
  zcl_plint_config = wa.

ENDMODULE.                 " set_content  OUTPUT
