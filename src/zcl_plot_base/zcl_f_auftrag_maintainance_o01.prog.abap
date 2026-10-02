*----------------------------------------------------------------------*
*   INCLUDE Z_PP_CO_MAINTAINANCE_O01                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0999  OUTPUT
*&---------------------------------------------------------------------*
*        text                                                          *
*----------------------------------------------------------------------*
MODULE status_0999 OUTPUT.
  SET PF-STATUS 'STATUS_999'.
  SET TITLEBAR 'T_999'.

  IF aufk_sel_flag IS INITIAL.

    REFRESH itab_aufk.

    IF NOT ( pp_order IS INITIAL ).
      SELECT * FROM aufk INTO TABLE itab_aufk WHERE aufnr = pp_order.

    ELSEIF NOT ( pp_all IS INITIAL ).
      SELECT * FROM aufk INTO TABLE itab_aufk .

    ELSEIF NOT ( p_order IS INITIAL ).
      SELECT * FROM aufk INTO TABLE itab_aufk .

    ENDIF.
  ELSE.
  ENDIF.

  IF NOT ( itab_aufk IS INITIAL ).

    IF obj_alv_grid1 IS INITIAL .

      CREATE OBJECT obj_custom_container1
        EXPORTING
*         PARENT                      =
          container_name              = '999_CONTAINER'
*         STYLE                       =
*         LIFETIME                    = lifetime_default
*         REPID                       =
*         DYNNR                       =
*         NO_AUTODEF_PROGID_DYNNR     =
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          others                      = 6
               .

      IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CREATE OBJECT obj_alv_grid1
        EXPORTING
*        I_SHELLSTYLE        = 0
*        I_LIFETIME          =
         i_parent            = obj_custom_container1
*        I_APPL_EVENTS       = space
*        I_PARENTDBG         =
*        I_APPLOGPARENT      =
*        I_GRAPHICSPARENT    =
*        I_USE_VARIANT_CLASS = SPACE
*        I_NAME              =
        EXCEPTIONS
         error_cntl_create   = 1
         error_cntl_init     = 2
         error_cntl_link     = 3
         error_dp_create     = 4
         others              = 5
          .
      IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.

    CALL METHOD obj_alv_grid1->set_table_for_first_display
      EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
         i_structure_name              = 'AUFK'
*        IS_VARIANT                    =
*        I_SAVE                        =
         i_default                     = 'X'
*        is_layout                     = layo_alv_gridb
         is_layout                     = layo_alv_grida
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
      CHANGING
         it_outtab                     = itab_aufk
*        IT_FIELDCATALOG               =
*        IT_SORT                       =
*        IT_FILTER                     =
      EXCEPTIONS
         invalid_parameter_combination = 1
         program_error                 = 2
         too_many_lines                = 3
         OTHERS                        = 4
              .

    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    MESSAGE i075(zcvn).
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.                 " STATUS_0999  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0996  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0996 OUTPUT.
  SET PF-STATUS 'STATUS_996'.
  SET TITLEBAR 'T_996'.

  LOOP AT SCREEN .
    IF screen-name = 'MM_IM'.
      IF screen-group1 = 'SPE'.
        screen-input = '0'.
      ENDIF.
    ELSEIF screen-name = 'MM_SP'.
      screen-input = '1'.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " STATUS_0996  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0993  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0993 OUTPUT.

  SET PF-STATUS 'STATUS_993'.
  SET TITLEBAR 'T_993'.

  IF NOT ( itab_mara_materials IS INITIAL ).
    SORT itab_mara_materials.
    DELETE ADJACENT DUPLICATES FROM itab_mara_materials
                                      COMPARING ALL FIELDS.

    IF obj_alv_grid4 IS INITIAL .
      CREATE OBJECT obj_custom_container4
        EXPORTING
*         PARENT                      =
          container_name              = 'ALL_MATERIALS'
*         STYLE                       =
*         LIFETIME                    = lifetime_default
*         REPID                       =
*         DYNNR                       =
*         NO_AUTODEF_PROGID_DYNNR     =
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          others                      = 6
          .

      IF sy-subrc <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CREATE OBJECT obj_alv_grid4
        EXPORTING
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
         i_parent          = obj_custom_container4
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
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

    CALL METHOD obj_alv_grid4->set_table_for_first_display
      EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
         i_structure_name              = 'MARA'
*        IS_VARIANT                    =
*        I_SAVE                        =
         i_default                     = 'X'
*        is_layout                     = layo_alv_gridb
         is_layout                     = layo_alv_grida
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
      CHANGING
*        it_outtab                     = itab_mara
         it_outtab                     = itab_mara_materials
*        IT_FIELDCATALOG               =
*        IT_SORT                       =
*        IT_FILTER                     =
      EXCEPTIONS
         invalid_parameter_combination = 1
         program_error                 = 2
         too_many_lines                = 3
         OTHERS                        = 4
              .

    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    MESSAGE i078(zcvn).
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.                 " STATUS_0993  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0992  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0992 OUTPUT.

  SET PF-STATUS 'STATUS_992'.
  SET TITLEBAR 'T_992'.

ENDMODULE.                 " STATUS_0992  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0991  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0991 OUTPUT.

  SET PF-STATUS 'STATUS_991'.
  SET TITLEBAR 'T_991'.

ENDMODULE.                 " STATUS_0991  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0899  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0899 OUTPUT.

  SET PF-STATUS 'STATUS_899'.
  SET TITLEBAR 'T_899'.
  PERFORM clear_subscreen_fields.

ENDMODULE.                 " STATUS_0899  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0888  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0888 OUTPUT.

  SET PF-STATUS 'STATUS_888'.
  SET TITLEBAR 'T_888'.

  IF NOT ( itab_draw IS INITIAL ).

    IF obj_alv_grid5 IS INITIAL .

      CREATE OBJECT obj_custom_container5
        EXPORTING
*         PARENT                      =
          container_name              = 'DIS'
*         STYLE                       =
*         LIFETIME                    = lifetime_default
*         REPID                       =
*         DYNNR                       =
*         NO_AUTODEF_PROGID_DYNNR     =
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          others                      = 6
          .

      IF sy-subrc <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CREATE OBJECT obj_alv_grid5
        EXPORTING
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
         i_parent          = obj_custom_container5
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
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

    CALL METHOD obj_alv_grid5->set_table_for_first_display
      EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
         i_structure_name              = 'DRAW'
*        IS_VARIANT                    =
*        I_SAVE                        =
         i_default                     = 'X'
         is_layout                     = layo_alv_gridb
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
      CHANGING
         it_outtab                     = itab_draw
*        IT_FIELDCATALOG               =
*        IT_SORT                       =
*        IT_FILTER                     =
      EXCEPTIONS
         invalid_parameter_combination = 1
         program_error                 = 2
         too_many_lines                = 3
         OTHERS                        = 4
              .

    IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.
    MESSAGE i075(zcvn).
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.                 " STATUS_0888  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0887  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0887 OUTPUT.

  SET PF-STATUS 'STATUS_887'.

  IF bom_flag = 'D'.
    SET TITLEBAR 'T_887D'.
  ELSEIF bom_flag = 'M'.
    SET TITLEBAR 'T_887M'.
  ENDIF.


  IF NOT ( itab_stpo_positions IS INITIAL ).

    SORT itab_stpo_positions BY stlty stlnr stlkn.

    DELETE ADJACENT DUPLICATES FROM itab_stpo_positions
                                  COMPARING ALL FIELDS.

* The filed 'POSTP' defines whether it is a
* Document or material or some thing else..
    IF obj_alv_grid6 IS INITIAL.
      IF obj_custom_container6 IS INITIAL.

        CREATE OBJECT obj_custom_container6
          EXPORTING
*           PARENT                      =
            container_name              = 'CONTAINER_STPO'
*           STYLE                       =
*           LIFETIME                    = lifetime_default
*           REPID                       =
*           DYNNR                       =
*           NO_AUTODEF_PROGID_DYNNR     =
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

      ENDIF.

      CREATE OBJECT obj_alv_grid6
        EXPORTING
*        I_SHELLSTYLE        = 0
*        I_LIFETIME          =
         i_parent            = obj_custom_container6
*        I_APPL_EVENTS       = space
*        I_PARENTDBG         =
*        I_APPLOGPARENT      =
*        I_GRAPHICSPARENT    =
*        I_USE_VARIANT_CLASS = SPACE
*        I_NAME              =
        EXCEPTIONS
         error_cntl_create   = 1
         error_cntl_init     = 2
         error_cntl_link     = 3
         error_dp_create     = 4
         others              = 5
          .

      IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.


    CALL METHOD obj_alv_grid6->set_table_for_first_display
      EXPORTING
*         I_BYPASSING_BUFFER            =
*         I_BUFFER_ACTIVE               =
*         I_CONSISTENCY_CHECK           =
        i_structure_name              = 'STPO'
*         IS_VARIANT                    =
*         I_SAVE                        =
        i_default                     = 'X'
        is_layout                     = layo_alv_grida
*         IS_PRINT                      =
*         IT_SPECIAL_GROUPS             =
*         IT_TOOLBAR_EXCLUDING          =
*         IT_HYPERLINK                  =
*         IT_ALV_GRAPHICS               =
      CHANGING
*         it_outtab                     = itab_stpo
        it_outtab                  = itab_stpo_positions
*         IT_FIELDCATALOG               =
*         IT_SORT                       =
*         IT_FILTER                     =
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4
            .

    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " STATUS_0887  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0886  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0886 OUTPUT.

  SET PF-STATUS 'STATUS_886'.
  SET TITLEBAR 'T_886'.

  IF obj_alv_grid7 IS INITIAL.
    IF obj_custom_container7 IS INITIAL.

      CREATE OBJECT obj_custom_container7
        EXPORTING
*        PARENT                      =
         container_name              = 'MAST_STLAN'
*        STYLE                       =
*        LIFETIME                    = lifetime_default
*        REPID                       =
*        DYNNR                       =
*        NO_AUTODEF_PROGID_DYNNR     =
*      EXCEPTIONS
*        CNTL_ERROR                  = 1
*        CNTL_SYSTEM_ERROR           = 2
*        CREATE_ERROR                = 3
*        LIFETIME_ERROR              = 4
*        LIFETIME_DYNPRO_DYNPRO_LINK = 5
*        others                      = 6
          .
      IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

    CREATE OBJECT obj_alv_grid7
      EXPORTING
*       I_SHELLSTYLE      = 0
*       I_LIFETIME        =
        i_parent          = obj_custom_container7
*       I_APPL_EVENTS     = space
*       I_PARENTDBG       =
*       I_APPLOGPARENT    =
*       I_GRAPHICSPARENT  =
*       I_USE_VARIANT_CLASS = SPACE
*       I_NAME            =
*     EXCEPTIONS
*       ERROR_CNTL_CREATE = 1
*       ERROR_CNTL_INIT   = 2
*       ERROR_CNTL_LINK   = 3
*       ERROR_DP_CREATE   = 4
*       others            = 5
        .
    IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

  IF NOT ( itab_mast IS INITIAL ).
    CALL METHOD obj_alv_grid7->set_table_for_first_display
      EXPORTING
*      I_BYPASSING_BUFFER            =
*      I_BUFFER_ACTIVE               =
*      I_CONSISTENCY_CHECK           =
        i_structure_name              = 'MAST'
*      IS_VARIANT                    =
*      I_SAVE                        =
        i_default                     = 'X'
        is_layout                     =  layo_alv_gridb
*      IS_PRINT                      =
*      IT_SPECIAL_GROUPS             =
*      IT_TOOLBAR_EXCLUDING          =
*      IT_HYPERLINK                  =
*      IT_ALV_GRAPHICS               =
      CHANGING
        it_outtab                     = itab_mast
*      IT_FIELDCATALOG               =
*      IT_SORT                       =
*      IT_FILTER                     =
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1
*      PROGRAM_ERROR                 = 2
*      TOO_MANY_LINES                = 3
*      others                        = 4
            .
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.
ENDMODULE.                 " STATUS_0886  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0884  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0884 OUTPUT.

  SET PF-STATUS 'STATUS_884'.
  SET TITLEBAR 'T_884'.

ENDMODULE.                 " STATUS_0884  OUTPUT
