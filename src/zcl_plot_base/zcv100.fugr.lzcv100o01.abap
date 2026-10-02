*----------------------------------------------------------------------*
***INCLUDE lzcv100O01 .
*----------------------------------------------------------------------*

* OUTPUT MODULE FOR TABLECONTROL 'Z602':
* COPY DDIC-TABLE TO ITAB
MODULE z602_init OUTPUT.

  IF g_z602_copied IS INITIAL.
* COPY DDIC-TABLE 'TDWP'
* INTO INTERNAL TABLE 'g_Z602_itab'
    SELECT * FROM tdwp
       INTO CORRESPONDING FIELDS
       OF TABLE g_z602_itab.
    g_z602_copied = 'X'.
    REFRESH CONTROL 'Z602' FROM SCREEN '0602'.
  ENDIF.

ENDMODULE.

* OUTPUT MODULE FOR TABLECONTROL 'Z602':
* MOVE ITAB TO DYNPRO
MODULE z602_move OUTPUT.
  MOVE-CORRESPONDING g_z602_wa TO tdwp.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  status_0602  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0602 OUTPUT.
  SET PF-STATUS 'ZZ602'.
  SET TITLEBAR 'BOX'.
ENDMODULE.                 " status_0602  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0902  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0702 OUTPUT.

*  SELECT * FROM TDWP INTO TABLE it_tdwp.
*
*  IF grid_suchen_z IS INITIAL.
*
*    CREATE OBJECT container_grid_suchen_z
*      EXPORTING container_name = 'CONTAINER_GRID_SUCHEN1'.
*
*    CREATE OBJECT   grid_suchen_z
*      EXPORTING i_parent = container_grid_suchen_z.
*
*    CALL METHOD grid_suchen_z->set_table_for_first_display
*      EXPORTING
**    I_BYPASSING_BUFFER            =
**    I_BUFFER_ACTIVE               =
**    I_CONSISTENCY_CHECK           =
*        i_structure_name              = 'TDWP'
**    IS_VARIANT                    =
**    I_SAVE                        =
**    I_DEFAULT                     = 'X'
**    IS_LAYOUT                     =
**    IS_PRINT                      =
**    IT_SPECIAL_GROUPS             =
**    IT_TOOLBAR_EXCLUDING          =
**    IT_HYPERLINK                  =
**    IT_ALV_GRAPHICS               =
*      CHANGING
*        it_outtab                     = itab_tdwp
**    IT_FIELDCATALOG               =
**    IT_SORT                       =
**    IT_FILTER                     =
*      EXCEPTIONS
*        invalid_parameter_combination = 1
*        program_error                 = 2
*        too_many_lines                = 3
*        OTHERS                        = 4
*            .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    CALL METHOD grid_suchen_z->get_frontend_layout
*      IMPORTING
*        es_layout = g_layo_grid_suchen_z.
*
*    g_layo_grid_suchen_z-sel_mode = 'A'.
*
*    CALL METHOD grid_suchen_z->set_frontend_layout
*      EXPORTING
*        is_layout = g_layo_grid_suchen_z
*        .
*    CALL METHOD grid_suchen_z->refresh_table_display
**        EXPORTING
**          IS_STABLE      =
**          I_SOFT_REFRESH =
*      EXCEPTIONS
*        finished       = 1
*        OTHERS         = 2
*            .
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*
*  ELSE.
*  ENDIF.
*
*  SET PF-STATUS 'S902'.
*  SET TITLEBAR 'SLI'.

ENDMODULE.                 " STATUS_0902  OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'Z100':
* COPY DDIC-TABLE TO ITAB
MODULE z100_init OUTPUT.
  IF g_z100_copied IS INITIAL.
* COPY DDIC-TABLE 'TDWP'
* INTO INTERNAL TABLE 'g_Z100_itab'
    SELECT * FROM tdwp
       INTO CORRESPONDING FIELDS
       OF TABLE g_z100_itab.
    g_z100_copied = 'X'.
    REFRESH CONTROL 'Z100' FROM SCREEN '0100'.
  ENDIF.
ENDMODULE.

* OUTPUT MODULE FOR TABLECONTROL 'Z100':
* MOVE ITAB TO DYNPRO
MODULE z100_move OUTPUT.
  MOVE-CORRESPONDING g_z100_wa TO tdwp.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'BOX'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0902  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0902 OUTPUT.

  SELECT * FROM tdwp INTO TABLE itab_tdwp.

  IF grid_suchen_z IS INITIAL.

    CREATE OBJECT container_grid_suchen_z
      EXPORTING container_name = 'CONTAINER_GRID_SUCHEN1'.

    CREATE OBJECT   grid_suchen_z
      EXPORTING i_parent = container_grid_suchen_z.

    CALL METHOD grid_suchen_z->set_table_for_first_display
      EXPORTING
*    I_BYPASSING_BUFFER            =
*    I_BUFFER_ACTIVE               =
*    I_CONSISTENCY_CHECK           =
        i_structure_name              = 'TDWP'
*    IS_VARIANT                    =
*    I_SAVE                        =
*    I_DEFAULT                     = 'X'
*    IS_LAYOUT                     =
*    IS_PRINT                      =
*    IT_SPECIAL_GROUPS             =
*    IT_TOOLBAR_EXCLUDING          =
*    IT_HYPERLINK                  =
*    IT_ALV_GRAPHICS               =
      CHANGING
        it_outtab                     = itab_tdwp
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

    CALL METHOD grid_suchen_z->get_frontend_layout
      IMPORTING
        es_layout = g_layo_grid_suchen_z.

    g_layo_grid_suchen_z-sel_mode = 'A'.

    CALL METHOD grid_suchen_z->set_frontend_layout
      EXPORTING
        is_layout = g_layo_grid_suchen_z
        .
    CALL METHOD grid_suchen_z->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
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

  SET PF-STATUS 'STATUS_902'.
  SET TITLEBAR 'BOX'.

ENDMODULE.                 " STATUS_0902  OUTPUT
