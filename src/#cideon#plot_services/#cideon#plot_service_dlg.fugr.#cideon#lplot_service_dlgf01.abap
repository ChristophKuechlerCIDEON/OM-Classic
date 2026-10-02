*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LPLOT_SERVICE_DLGF01 .
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Beschreibung: Erzeugt den Feldkatalog aus dem DDIC und passt ihn an.
*&               - Benutzername wird ausgeblendet.
*&               - Spaltenüberschrift für VALUE --> "Vorgabe"
*&
*& Autor:        HAENSEL
*& Angelegt am:  07.09.2006 10:25:32
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
FORM prepare_field_catalog.
  DATA: lc_vorgabe TYPE string.
  FIELD-SYMBOLS: <ls_fcat> TYPE lvc_s_fcat.

  lc_vorgabe = text-000.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
*         I_BUFFER_ACTIVE              =
          i_structure_name             = '/CIDEON/PLSRVSET'
*         I_CLIENT_NEVER_DISPLAY       = 'X'
*         I_BYPASSING_BUFFER           =
*         I_INTERNAL_TABNAME           =
        CHANGING
          ct_fieldcat                  = gt_objlist_fcat
*       EXCEPTIONS
*         INCONSISTENT_INTERFACE       = 1
*         PROGRAM_ERROR                = 2
*         OTHERS                       = 3
                .
  LOOP AT gt_objlist_fcat ASSIGNING <ls_fcat>.
    IF <ls_fcat>-fieldname = 'UNAME'.
      <ls_fcat>-no_out = abap_true.
    ELSEIF <ls_fcat>-fieldname = 'VALUE'.
      <ls_fcat>-coltext = lc_vorgabe.
      <ls_fcat>-checkbox = abap_true.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " prepare_field_catalog

*&---------------------------------------------------------------------*
*& Beschreibung: Ausblenden der nicht benötigten Toolbar Buttons
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 11:57:47
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
FORM prepare_toolbar .
  DATA: ls_func TYPE ui_func.

  ls_func = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_func TO gt_toolbar_excluding.
  ls_func = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_func TO gt_toolbar_excluding.
  ls_func = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_func TO gt_toolbar_excluding.
  ls_func = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_func TO gt_toolbar_excluding.
  ls_func = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_func TO gt_toolbar_excluding.
  ls_func = cl_gui_alv_grid=>mc_fc_average.
  APPEND ls_func TO gt_toolbar_excluding.
ENDFORM.                    " prepare_toolbar


*&---------------------------------------------------------------------*
*& Beschreibung: Verabreitung des OK Codes
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 12:18:38
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
FORM user_command_0100 .
  DATA: lb_valid TYPE abap_bool.

* Einstellungen speichern, wenn OK CODE = SAVE
  IF sy-ucomm = 'SAVE'.
*   Eingaben im ALV Grid verproben
    CALL METHOD go_objlist_control->check_changed_data
      IMPORTING
        e_valid = lb_valid.

    CHECK NOT lb_valid IS INITIAL.
    CALL FUNCTION '/CIDEON/PLOT_SRV_SET_SETTINGS'
      EXPORTING
        ib_expand_all = gb_expand_all
        it_obj_settings = gt_objtype_settings.

  ENDIF.

  LEAVE TO SCREEN 0.
ENDFORM.                    " user_command_0100
