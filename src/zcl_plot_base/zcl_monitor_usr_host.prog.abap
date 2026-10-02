*&---------------------------------------------------------------------*
*& Report  ZCL_MONITOR_USR_HOST                                        *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zcl_monitor_usr_host          .

TABLES : zcl_usr_host_cfg.

CONTROLS tabstripcontrols_900 TYPE TABSTRIP.

CLASS lcl_application DEFINITION DEFERRED.

DATA : search_handler TYPE REF TO lcl_application.

DATA   : index_itab_searchlist TYPE i,
         ok_code(20)           TYPE c.

DATA   : itab_search TYPE TABLE OF  zcl_usr_host_cfg,
         wa_search   TYPE           zcl_usr_host_cfg.

DATA   : itab_display TYPE TABLE OF  zcl_usr_host_cfg,
         wa_display   TYPE           zcl_usr_host_cfg.


DATA : alv_grid           TYPE REF TO cl_gui_alv_grid,
       docking_container  TYPE REF TO cl_gui_docking_container.

* Layout
DATA : layo_alv_grid TYPE lvc_s_layo.

* Field catlogs
DATA : fc_alv_grid TYPE lvc_t_fcat.

* ALV-Grid Control row.
DATA : itab_index_rows_alv_grid TYPE lvc_t_row.

* Description of ALV-Grid row.
DATA : wa_index_rows_alv_grid   TYPE lvc_s_row.

* Events
DATA : itab_events TYPE cntl_simple_events,
       wa_events TYPE LINE OF  cntl_simple_events.



*---------------------------------------------------------------------*
*       CLASS lcl_application DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_application DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS:

      catch_double_click FOR EVENT double_click
                        OF  cl_gui_alv_grid IMPORTING
                                            e_row e_column.

ENDCLASS.         "End of CLASS lcl_application DEFINITION.

*---------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.

  METHOD catch_double_click.

    index_itab_searchlist = e_row.

    READ TABLE itab_search INDEX index_itab_searchlist INTO wa_search.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DOUBLE_CLICK_SEARCH'
*      IMPORTING
*        RC       =
        .

  ENDMETHOD.

ENDCLASS.       "End of CLASS lcl_application IMPLEMENTATION.


SELECTION-SCREEN BEGIN OF BLOCK backdrop WITH FRAME TITLE text-001.

SELECT-OPTIONS : p_uname  FOR zcl_usr_host_cfg-uname DEFAULT sy-uname,
                 p_cfhost FOR zcl_usr_host_cfg-host ,
                 p_cdpath FOR zcl_usr_host_cfg-ppl_down_path,
                 p_fdpath FOR zcl_usr_host_cfg-down_path,
                 p_cuname FOR zcl_usr_host_cfg-zclinsname,
                 p_cdatum FOR zcl_usr_host_cfg-zclinsdate,
                 p_progid FOR zcl_usr_host_cfg-zclinsprog,
                 p_uuname FOR zcl_usr_host_cfg-zclupdname,
                 p_udatum FOR zcl_usr_host_cfg-zclupddate,
                 p_uuzeit FOR zcl_usr_host_cfg-zclupdtime
                                       DEFAULT '000000' TO '240000',
                 p_uproid FOR zcl_usr_host_cfg-zclupdprog.


SELECTION-SCREEN END OF BLOCK backdrop.


INITIALIZATION.

AT SELECTION-SCREEN.

START-OF-SELECTION.

  SELECT * FROM zcl_usr_host_cfg
    INTO TABLE itab_search
        WHERE uname         IN p_uname
          AND host          IN p_cfhost
          AND ppl_down_path IN p_cdpath
          AND down_path     IN p_fdpath
          AND zclinsname    IN p_cuname
          AND zclinsdate    IN p_cdatum
          AND zclinsprog    IN p_progid
          AND zclupdname    IN p_uuname
          AND zclupddate    IN p_udatum
          AND zclupdtime    IN p_uuzeit
          AND zclupdprog    IN p_uproid
          .

  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CALL SCREEN 900.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0900 OUTPUT.
  SET PF-STATUS 'Z900'.
  SET TITLEBAR 'HOST'.

  IF docking_container IS INITIAL.
    CREATE OBJECT docking_container
      EXPORTING
*    PARENT                      = custom_container
*    REPID                       =
        dynnr                       = '0900'
        side                        = 2
* 2 means 'cl_gui_docking_container=>dock_at_top'
    extension                   = 200
*    STYLE                       =
*    LIFETIME                    = lifetime_default
*    CAPTION                     =
*    METRIC                      = 40
*    RATIO                       =
*    NO_AUTODEF_PROGID_DYNNR     =
*    NAME                        =
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6
        .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.

  layo_alv_grid-sel_mode = 'A'.
  layo_alv_grid-excp_led = 'X'.

  IF alv_grid IS INITIAL.

    CREATE OBJECT alv_grid
      EXPORTING
*    I_SHELLSTYLE      = 0
*    I_LIFETIME        =
        i_parent          = docking_container
*    I_APPL_EVENTS     = space
*    I_PARENTDBG       =
*    I_APPLOGPARENT    =
*    I_GRAPHICSPARENT  =
*    I_USE_VARIANT_CLASS = SPACE
*    I_NAME            =
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        others            = 5
        .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL METHOD alv_grid->set_table_for_first_display
      EXPORTING
*    I_BYPASSING_BUFFER            =
*    I_BUFFER_ACTIVE               =
*    I_CONSISTENCY_CHECK           =
        i_structure_name              = 'ZCL_USR_HOST_CFG'
*    IS_VARIANT                    =
*    I_SAVE                        =
    i_default                     = 'X'
    is_layout                     = layo_alv_grid
*    IS_PRINT                      =
*    IT_SPECIAL_GROUPS             =
*    IT_TOOLBAR_EXCLUDING          =
*    IT_HYPERLINK                  =
*    IT_ALV_GRAPHICS               =
      CHANGING
        it_outtab                     = itab_search
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    SET HANDLER lcl_application=>catch_double_click FOR alv_grid.

  ELSE.
    CALL METHOD alv_grid->set_table_for_first_display
      EXPORTING
*    I_BYPASSING_BUFFER            =
*    I_BUFFER_ACTIVE               =
*    I_CONSISTENCY_CHECK           =
        i_structure_name              = 'ZCL_USR_HOST_CFG'
*    IS_VARIANT                    =
*    I_SAVE                        =
    i_default                     = 'X'
    is_layout                     = layo_alv_grid
*    IS_PRINT                      =
*    IT_SPECIAL_GROUPS             =
*    IT_TOOLBAR_EXCLUDING          =
*    IT_HYPERLINK                  =
*    IT_ALV_GRAPHICS               =
      CHANGING
        it_outtab                     = itab_search
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    SET HANDLER lcl_application=>catch_double_click FOR alv_grid.

  ENDIF.

ENDMODULE.                 " STATUS_0900  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0900 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'TAB1'.
      tabstripcontrols_900-activetab = 'TAB1'.
    WHEN 'TAB2'.
      tabstripcontrols_900-activetab = 'TAB2'.
    WHEN 'DOUBLE_CLICK_SEARCH'.
      PERFORM read_akt_line_search.
    WHEN 'ENTER'.
      PERFORM check_modified_fiields.
    WHEN 'SAVE'.
      PERFORM save_usr_host_details.
      PERFORM dispaly_whole_table.
    WHEN 'CREATE'.
      PERFORM clear_user_data_line.
      PERFORM refresh_alv_grid.
    WHEN 'UPDATE'.
      PERFORM check_modified_fiields.
      PERFORM update_table_with_new_values.
    WHEN 'DELETE'.
      PERFORM delete_row_from_table.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0900  INPUT


*&---------------------------------------------------------------------*
*&      Form  refresh_alv_grid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_alv_grid.

  CALL METHOD alv_grid->refresh_table_display
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

ENDFORM.                    " refresh_alv_grid
*&---------------------------------------------------------------------*
*&      Form  read_akt_line_search
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_akt_line_search.

  IF search_handler IS INITIAL.
    CREATE OBJECT search_handler.
  ELSE.
  ENDIF.

  CLEAR wa_search.
  CALL METHOD alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = itab_index_rows_alv_grid.

  READ TABLE itab_search INDEX index_itab_searchlist INTO wa_search.
  APPEND wa_search TO itab_display.

ENDFORM.                    " read_akt_line_search

*&---------------------------------------------------------------------*
*&      Form  check_modified_fiields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_modified_fiields.

  DATA : flag TYPE c.

  LOOP AT itab_display INTO wa_display.

    IF wa_search-uname NE wa_display-uname.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-uname         NE wa_display-uname.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-host          NE wa_display-host.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-ppl_down_path NE wa_display-ppl_down_path.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-down_path     NE wa_display-down_path.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-zclinsname    NE wa_display-zclinsname.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-zclinsdate    NE wa_display-zclinsdate.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-zclinsprog    NE wa_display-zclinsprog.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-zclinsprog    NE wa_display-zclinsprog.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-zclupddate    NE wa_display-zclupddate.
      flag = 'X'.
      EXIT.
    ELSEIF wa_search-zclupdprog    NE wa_display-zclupdprog.
      flag = 'X'.
      EXIT.
    ELSE.
      flag = ''.
    ENDIF.

  ENDLOOP.


  IF flag = 'X'.

    MODIFY itab_search FROM wa_search INDEX index_itab_searchlist.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'SAVE'
*     IMPORTING
*       rc       =
        .
  ENDIF.

ENDFORM.                    " check_modified_fiields

*&---------------------------------------------------------------------*
*&      Form  update_table_with_new_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_table_with_new_values.

  CLEAR wa_display.

  LOOP AT itab_display INTO wa_display.
    MODIFY zcl_usr_host_cfg FROM wa_display.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
    ELSE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " update_table_with_new_values

*&---------------------------------------------------------------------*
*&      Form  clear_user_data_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_user_data_line.
  CLEAR wa_search.
ENDFORM.                    " create_new_usr_host

*&---------------------------------------------------------------------*
*&      Form  save_usr_host_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_usr_host_details.
  IF NOT ( wa_search IS INITIAL ).
    INSERT INTO zcl_usr_host_cfg VALUES wa_search.
  ENDIF.
*  APPEND wa_search TO itab_search.
  UPDATE zcl_usr_host_cfg FROM TABLE itab_search.

  CLEAR wa_search.
ENDFORM.                    " save_usr_host_details
*&---------------------------------------------------------------------*
*&      Form  dispaly_whole_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dispaly_whole_table.
  CLEAR itab_search.

  SELECT * FROM zcl_usr_host_cfg INTO TABLE itab_search.

  CALL METHOD alv_grid->set_table_for_first_display
    EXPORTING
*    I_BYPASSING_BUFFER            =
*    I_BUFFER_ACTIVE               =
*    I_CONSISTENCY_CHECK           =
     i_structure_name              = 'ZCL_USR_HOST_CFG'
*    IS_VARIANT                    =
*    I_SAVE                        =
     i_default                     = 'X'
     is_layout                     = layo_alv_grid
*    IS_PRINT                      =
*    IT_SPECIAL_GROUPS             =
*    IT_TOOLBAR_EXCLUDING          =
*    IT_HYPERLINK                  =
*    IT_ALV_GRAPHICS               =
    CHANGING
     it_outtab                     = itab_search
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SET HANDLER lcl_application=>catch_double_click FOR alv_grid.

ENDFORM.                    " dispaly_whole_table
*&---------------------------------------------------------------------*
*&      Form  delete_row_from_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_row_from_table.

  IF search_handler IS INITIAL.
    CREATE OBJECT search_handler.
  ELSE.
  ENDIF.

  DELETE FROM zcl_usr_host_cfg
                  WHERE uname         = wa_search-uname
                    AND host          = wa_search-host
                    AND ppl_down_path = wa_search-ppl_down_path
                    AND down_path     = wa_search-down_path.

  CLEAR wa_search.

  SELECT * FROM zcl_usr_host_cfg INTO TABLE itab_search.

ENDFORM.                    " delete_row_from_table
