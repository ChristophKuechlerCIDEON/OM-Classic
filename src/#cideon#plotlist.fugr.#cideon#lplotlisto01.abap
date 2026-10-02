*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOTLISTO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.

  IF f_init = 'X'.
    CREATE OBJECT custom_control_files
      EXPORTING container_name = 'COSTUM_CONTROL_FILES'.
    IF sy-subrc <> 0.
    ENDIF.

    IF alv_files IS INITIAL.

      CLEAR dv_files.
      dv_files-report = sy-repid.
      dv_files-username = sy-uname.

      CREATE OBJECT alv_files
        EXPORTING
*          I_SHELLSTYLE      = 0
*          I_LIFETIME        =
          i_parent          = custom_control_files
*          I_APPL_EVENTS     = space
*          I_PARENTDBG       =
*          I_APPLOGPARENT    =
*          I_GRAPHICSPARENT  =
*          I_USE_VARIANT_CLASS = SPACE
*          I_NAME            =
        EXCEPTIONS
          error_cntl_create = 1
          error_cntl_init   = 2
          error_cntl_link   = 3
          error_dp_create   = 4
          others            = 5
          .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CALL METHOD alv_files->set_table_for_first_display
         EXPORTING
*          I_BYPASSING_BUFFER            =
*          I_BUFFER_ACTIVE               =
*          I_CONSISTENCY_CHECK           =
           i_structure_name              = 'ZORI_DOC_FILES'
           is_variant                    = dv_files
           i_save                        = x_save_files
*          I_DEFAULT                     = 'X'
*          IS_LAYOUT                     =
*          IS_PRINT                      =
*          IT_SPECIAL_GROUPS             =
*          IT_TOOLBAR_EXCLUDING          =
*          IT_HYPERLINK                  =
*          IT_ALV_GRAPHICS               =
*          IT_EXCEPT_QINFO               =
        CHANGING
          it_outtab                     = lt_files_internal
*          IT_FIELDCATALOG               =
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

      CLEAR layo_files.
      CALL METHOD alv_files->get_frontend_layout
        IMPORTING
          es_layout = layo_files
          .
      layo_files-sel_mode = 'A'.

      CALL METHOD alv_files->set_frontend_layout
        EXPORTING
          is_layout = layo_files
          .


      CALL METHOD alv_files->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
        EXCEPTIONS
          finished       = 1
          OTHERS         = 2
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


    ELSE.
    ENDIF.


    CLEAR f_init.
  ELSE.
  ENDIF.

  CALL METHOD alv_files->set_table_for_first_display
   EXPORTING
*          I_BYPASSING_BUFFER            =
*          I_BUFFER_ACTIVE               =
*          I_CONSISTENCY_CHECK           =
     i_structure_name              = 'ZORI_DOC_FILES'
     is_variant                    = dv_files
     i_save                        = x_save_files
*          I_DEFAULT                     = 'X'
*          IS_LAYOUT                     =
*          IS_PRINT                      =
*          IT_SPECIAL_GROUPS             =
*          IT_TOOLBAR_EXCLUDING          =
*          IT_HYPERLINK                  =
*          IT_ALV_GRAPHICS               =
*          IT_EXCEPT_QINFO               =
  CHANGING
    it_outtab                     = lt_files_internal
*          IT_FIELDCATALOG               =
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


  CALL METHOD alv_files->refresh_table_display
*        EXPORTING
*          IS_STABLE      =
*          I_SOFT_REFRESH =
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2
          .
  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


*   Alles Selektieren
  PERFORM sel_all.



ENDMODULE.                 " STATUS_0100  OUTPUT
