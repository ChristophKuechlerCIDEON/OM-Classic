*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOT_BASISO02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0800 OUTPUT.
  SET PF-STATUS '0800'.
  SET TITLEBAR '0800'.

ENDMODULE.                 " STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_alv OUTPUT.

  IF go_custom_container IS INITIAL.
    CREATE OBJECT go_custom_container
      EXPORTING
*        PARENT                      =
        container_name              = 'GC_CUSTOM_CONTROL'
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
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.

  IF go_alv IS INITIAL.
    create object go_alv
      exporting
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
        i_parent          = go_custom_container
*        I_APPL_EVENTS     = space
*        I_PARENTDBG       =
*        I_APPLOGPARENT    =
*        I_GRAPHICSPARENT  =
*        I_USE_VARIANT_CLASS = SPACE
*        I_NAME            =
*      EXCEPTIONS
*        ERROR_CNTL_CREATE = 1
*        ERROR_CNTL_INIT   = 2
*        ERROR_CNTL_LINK   = 3
*        ERROR_DP_CREATE   = 4
*        others            = 5
        .
    IF sy-subrc <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     EXIT.
    ENDIF.

    CREATE OBJECT go_handler_alv.

    SET HANDLER go_handler_alv->handle_toolbar FOR go_alv.
    SET HANDLER go_handler_alv->handle_usercommand FOR go_alv.
    SET HANDLER go_handler_alv->handle_doubleclick FOR go_alv.



    gs_layout-cwidth_opt = 'X'.
    gs_layout-zebra      = 'X'.
    gs_layout-sel_mode   = 'A'.




    CALL METHOD go_alv->set_table_for_first_display
     EXPORTING
*      I_BYPASSING_BUFFER            =
*      I_BUFFER_ACTIVE               =
*      I_CONSISTENCY_CHECK           =
       I_STRUCTURE_NAME              = gc_sname_stored_search
*      IS_VARIANT                    =
*      I_SAVE                        =
*      I_DEFAULT                     = 'X'
       IS_LAYOUT                     = gs_layout
*      IS_PRINT                      =
*      IT_SPECIAL_GROUPS             =
*      IT_TOOLBAR_EXCLUDING          =
*      IT_HYPERLINK                  =
*      IT_ALV_GRAPHICS               =
*      IT_EXCEPT_QINFO               =
    CHANGING
      it_outtab                     =  gt_stored_search
*      IT_FIELDCATALOG               =  gt_fields_stored_search
*      IT_SORT                       =
*      IT_FILTER                     =
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1
*      PROGRAM_ERROR                 = 2
*      TOO_MANY_LINES                = 3
*      others                        = 4
          .
  IF sy-subrc <> 0.
   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.




  ELSE.

  DATA: is_stable TYPE LVC_S_STBL.

    is_stable-row = 'X'.
    is_stable-col = 'X'.

    CALL METHOD go_alv->refresh_table_display
      EXPORTING
          IS_STABLE      = is_stable
*        I_SOFT_REFRESH =
*      EXCEPTIONS
*        FINISHED       = 1
*        others         = 2
            .
    IF sy-subrc <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


  ENDIF.



ENDMODULE.                 " CREATE_ALV  OUTPUT
