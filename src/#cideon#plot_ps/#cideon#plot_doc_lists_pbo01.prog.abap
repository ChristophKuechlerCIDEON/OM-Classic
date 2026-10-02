*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_MDR_TR_PBO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.


  IF f_to_init IS INITIAL.
  ELSE.
*   BADI initialisieren
    IF badi_om_ps_01 IS INITIAL.
      CALL METHOD cl_exithandler=>get_instance
        CHANGING
          instance = badi_om_ps_01.
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.

*   Einstellungen lesen.
    PERFORM read_defaults.
    PERFORM map_default_data.



*  Letztes PSP Element lesen
    GET PARAMETER ID 'PRO' FIELD wa_mdr_tr-posid.
*     Lesen der Projektdaten
    IF wa_mdr_tr-pspid IS INITIAL.
      IF wa_mdr_tr-posid IS INITIAL.
      ELSE.
        PERFORM read_pspid.
        SET PARAMETER ID 'PRO' FIELD wa_mdr_tr-posid.
      ENDIF.
    ELSE.
    ENDIF.

    CLEAR f_to_init.
  ENDIF.

* Projektstücklisten holen
  PERFORM get_prst.
  PERFORM set_alv_prst.


  SET PF-STATUS '0100'.
  SET TITLEBAR '100'.

  mdf_filename = wa_mdr_tr-mdf_template.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  set_alv_prst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_alv_prst.
* Setzen des ALV für PRST

  IF alv_prst IS INITIAL.
    CLEAR gs_variant_prst.
    gs_variant_prst-report = sy-repid.
    gs_variant_prst-username = sy-uname.

    CREATE OBJECT container_grid_prst
      EXPORTING container_name = 'CS_PRST'.
    IF sy-subrc <> 0.
    ENDIF.

    CREATE OBJECT alv_prst
      EXPORTING
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
        i_parent          = container_grid_prst
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
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL METHOD alv_prst->set_table_for_first_display
       EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
         i_structure_name              = 'PRST'
         is_variant                    = gs_variant_prst
         i_save                        = 'X'
         i_default                     = 'X'
*        IS_LAYOUT                     =
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
*        IT_EXCEPT_QINFO               =
      CHANGING
        it_outtab                     = it_prst
*        IT_FIELDCATALOG               =
*        IT_SORT                       =
*        IT_FILTER                     =
*      EXCEPTIONS
*        INVALID_PARAMETER_COMBINATION = 1
*        PROGRAM_ERROR                 = 2
*        TOO_MANY_LINES                = 3
*        others                        = 4
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    set handler
      prst_handler->catch_dblclick for alv_prst.

  ELSE.
    CALL METHOD alv_prst->set_table_for_first_display
       EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
         i_structure_name              = 'PRST'
         is_variant                    = gs_variant_prst
         i_save                        = 'X'
         i_default                     = 'X'
*        IS_LAYOUT                     =
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
*        IT_EXCEPT_QINFO               =
      CHANGING
        it_outtab                     = it_prst
*        IT_FIELDCATALOG               =
*        IT_SORT                       =
*        IT_FILTER                     =
*      EXCEPTIONS
*        INVALID_PARAMETER_COMBINATION = 1
*        PROGRAM_ERROR                 = 2
*        TOO_MANY_LINES                = 3
*        others                        = 4
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

  CALL METHOD alv_prst->refresh_table_display
*  EXPORTING
*    IS_STABLE      =
*    I_SOFT_REFRESH =
     EXCEPTIONS
       finished       = 1
       OTHERS         = 2
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " set_alv_prst
