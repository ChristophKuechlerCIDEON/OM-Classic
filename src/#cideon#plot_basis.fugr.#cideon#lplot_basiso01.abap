*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOT_BASISO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.

  IF alv_originals IS INITIAL.
    CREATE OBJECT container_originals
    EXPORTING container_name = 'CS_CONTROL_ORIGINALS'.
    IF sy-subrc <> 0.
    ENDIF.

    CREATE OBJECT   alv_originals
      EXPORTING i_parent =
*      docking_searchlist
      container_originals
      .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR gs_layout_alv_originals.
    gs_layout_alv_originals-report = sy-repid.
    gs_layout_alv_originals-username = sy-uname.


    CALL METHOD alv_originals->set_table_for_first_display
       EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
         i_structure_name              = 'BAPI_DOC_FILES2'
         is_variant                    = gs_layout_alv_originals
         i_save                        = 'A'
         i_default                     = 'X'
*        IS_LAYOUT                     =
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
*        IT_EXCEPT_QINFO               =
      CHANGING
        it_outtab                     = itab_documentfiles
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
    CALL METHOD alv_originals->refresh_table_display
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
  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '200'.
  SET TITLEBAR '200'.

  IF alv_originals_2 IS INITIAL.
    CREATE OBJECT container_originals_2
    EXPORTING container_name = 'CS_CONTROL_ORIGINALS'.
    IF sy-subrc <> 0.
    ENDIF.

    CREATE OBJECT   alv_originals_2
      EXPORTING i_parent =  container_originals_2
      .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR gs_layout_alv_originals_2.
    gs_layout_alv_originals_2-report = sy-repid.
    gs_layout_alv_originals_2-username = sy-uname.

    CLEAR g_layo_alv_originals_2.
    g_layo_alv_originals_2-sel_mode = 'A'.


    CALL METHOD alv_originals_2->set_table_for_first_display
       EXPORTING
*        I_BYPASSING_BUFFER            =
*        I_BUFFER_ACTIVE               =
*        I_CONSISTENCY_CHECK           =
         i_structure_name              = 'BAPI_DOC_FILES2'
         is_variant                    = gs_layout_alv_originals_2
         i_save                        = 'A'
         i_default                     = 'X'
         is_layout                     = g_layo_alv_originals_2
*        IS_PRINT                      =
*        IT_SPECIAL_GROUPS             =
*        IT_TOOLBAR_EXCLUDING          =
*        IT_HYPERLINK                  =
*        IT_ALV_GRAPHICS               =
*        IT_EXCEPT_QINFO               =
      CHANGING
        it_outtab                     = itab_documentfiles
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
    CALL METHOD alv_originals_2->refresh_table_display
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
  ENDIF.


ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0600 OUTPUT.
  SET PF-STATUS '600'.
  SET TITLEBAR '600'.

ENDMODULE.                 " STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0650  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0650 OUTPUT.
  SET PF-STATUS '650'.
  SET TITLEBAR '650'.

* break kuechler.

*  LOOP AT SCREEN.
*    IF screen-name = 'SO_DOKAR'.
*    ELSE.
*    ENDIF.
*    IF screen-name = 'SO_DOKNR'.
*    ELSE.
*    ENDIF.
*    IF screen-name = 'SO_DOKTL'.
*    ELSE.
*    ENDIF.
*    IF screen-name = 'SO_DOKVR'.
*    ELSE.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

* Icon austauschen, falls Range gefüllt
  IF so_dokar[] IS INITIAL.
  ELSE.
  ENDIF.

  IF so_doknr[] IS INITIAL.
  ELSE.
  ENDIF.

  IF so_doktl[] IS INITIAL.
  ELSE.
  ENDIF.

  IF so_dokvr[] IS INITIAL.
  ELSE.
  ENDIF.


ENDMODULE.                 " STATUS_0650  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.
  SET PF-STATUS '0700'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0710  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0710 OUTPUT.
  SET PF-STATUS '710'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0710  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0720  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0720 OUTPUT.
  SET PF-STATUS '720'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0720  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0675  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0675 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  SET PF-STATUS '675'.
  SET TITLEBAR '675'.

*  LOOP AT SCREEN.
*    IF screen-name = 'SO_DOKAR'.
*    ELSE.
*    ENDIF.
*    IF screen-name = 'SO_DOKNR'.
*    ELSE.
*    ENDIF.
*    IF screen-name = 'SO_DOKTL'.
*    ELSE.
*    ENDIF.
*    IF screen-name = 'SO_DOKVR'.
*    ELSE.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

* Icon austauschen, falls Range gefüllt
  IF so_dokar[] IS INITIAL.
  ELSE.
  ENDIF.

  IF so_doknr[] IS INITIAL.
  ELSE.
  ENDIF.

  IF so_doktl[] IS INITIAL.
  ELSE.
  ENDIF.

  IF so_dokvr[] IS INITIAL.
  ELSE.
  ENDIF.



ENDMODULE.                 " STATUS_0675  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0680  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0680 OUTPUT.
  SET PF-STATUS '0680'.
  SET TITLEBAR '0680'.

* ALV erstellen
  IF alv_mast IS INITIAL.
    CREATE OBJECT cc_mast
    EXPORTING container_name = 'CC_MAST'.
    IF sy-subrc <> 0.
    ENDIF.

    CREATE OBJECT alv_mast
      EXPORTING
*        I_SHELLSTYLE      = 0
*        I_LIFETIME        =
        i_parent          = cc_mast
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

  ELSE.
  ENDIF.

  CLEAR g_layout_alv_mast.
  g_layout_alv_mast-sel_mode = 'B'.

  CALL METHOD alv_mast->set_table_for_first_display
    EXPORTING
      i_structure_name              = 'MAST'
*        is_variant                    = gs_layout_searchlist
      is_layout                     = g_layout_alv_mast
      i_save                        = 'A'
      i_default                     = 'X'
*        it_toolbar_excluding          = itab_tb_ex_searchlist
    CHANGING
      it_outtab                     = itab_mast
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



ENDMODULE.                 " STATUS_0680  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0730  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0730 OUTPUT.
  SET PF-STATUS '0730'.
  SET TITLEBAR '730'.


ENDMODULE.                 " STATUS_0730  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
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



ENDMODULE.                 " STATUS_0300  OUTPUT
