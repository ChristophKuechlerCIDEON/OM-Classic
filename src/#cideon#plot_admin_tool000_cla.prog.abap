INCLUDE <icon>.


*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_alv DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_alv_plot DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      catch_dblclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column,

    handle_toolbar:
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive,

    handle_menu_button
        FOR EVENT menu_button OF cl_gui_alv_grid
            IMPORTING e_object e_ucomm,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

    handle_hotspot_click FOR EVENT hotspot_click
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id.

    METHODS:  handle_data_changed
                  FOR EVENT data_changed OF cl_gui_alv_grid
                     IMPORTING er_data_changed,

              handle_close
                  FOR EVENT close OF cl_gui_dialogbox_container
                  IMPORTING sender.

  PRIVATE SECTION.

    DATA: error_in_data TYPE c.
* Methods to modularize event handler method HANDLE_DATA_CHANGED:
    METHODS: check_copy
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_satz
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_para
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_para2
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.


    METHODS: check_para3
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_para4
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_para5
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_para6
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_para7
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_para8
     IMPORTING
        ps_good_copy TYPE lvc_s_modi
        pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.


ENDCLASS.



*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_alv IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_alv_plot IMPLEMENTATION.

  METHOD catch_dblclick.
  ENDMETHOD.

  METHOD handle_toolbar.

    DATA: lc_menu    TYPE REF TO cl_ctmenu.
    DATA: ls_menu    TYPE stb_btnmnu.

    DATA: lc_menu_search TYPE REF TO cl_ctmenu.

*   add toolbar-button 'Änderung Kopienanzahl'
    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CLEAR ls_sl_button.
    MOVE 'CH_COPY' TO ls_sl_button-function.
    MOVE icon_toggle_display_change TO ls_sl_button-icon.
    MOVE text-051 TO ls_sl_button-quickinfo.
    MOVE text-052 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*   add toolbar-button 'Änderung PreProzessor/Verteiler'
    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CLEAR ls_sl_button.
    MOVE 'CH_PREPR' TO ls_sl_button-function.
    MOVE icon_rename  TO ls_sl_button-icon.
    MOVE text-056 TO ls_sl_button-quickinfo.
    MOVE text-055 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*   add toolbar-button 'Optionen / automatischer Durchlauf'
    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CLEAR ls_sl_button.
    MOVE 'OPTIONS' TO ls_sl_button-function.
    MOVE icon_read_file TO ls_sl_button-icon.
    MOVE text-026 TO ls_sl_button-quickinfo.
    MOVE text-027 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    MOVE 1 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_search.
    CALL METHOD lc_menu_search->add_function
                EXPORTING fcode   = 'KNZ_AUTO_PROC_ON'
                          text    = text-028.

    CALL METHOD lc_menu_search->add_function
                EXPORTING fcode   = 'KNZ_AUTO_PROC_OFF'
                text    = text-029.
    ls_menu-ctmenu = lc_menu_search.
    ls_menu-function = 'OPTIONS'.
    APPEND ls_menu TO e_object->mt_btnmnu.

*   add toolbar-button 'Spezial'
    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

*   Eintrag Spezial
    CLEAR ls_sl_button.
    MOVE 'SPECIAL' TO ls_sl_button-function.
    MOVE icon_sap TO ls_sl_button-icon.
    MOVE text-047 TO ls_sl_button-quickinfo.
    MOVE text-048 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    MOVE 1 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu.
    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'DWNL_LOCAL'
                text    = text-049.

    CALL METHOD lc_menu->add_separator.

    CALL METHOD lc_menu->add_function
                EXPORTING fcode   = 'STR_KONV'
                          text    = text-050.

    ls_menu-ctmenu = lc_menu.
    ls_menu-function = 'SPECIAL'.
    APPEND ls_menu TO e_object->mt_btnmnu.


*   add toolbar-button 'Löschen ganzer Plotjob/einzelner Eintrag'
    CLEAR ls_sl_button.
    MOVE 3 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CLEAR ls_sl_button.
    MOVE 'SEARCH' TO ls_sl_button-function.
    MOVE icon_delete TO ls_sl_button-icon.
    MOVE text-022 TO ls_sl_button-quickinfo.
    MOVE text-023 TO ls_sl_button-text.
    MOVE ' ' TO ls_sl_button-disabled.
    MOVE 1 TO ls_sl_button-butn_type.
    APPEND ls_sl_button TO e_object->mt_toolbar.

    CREATE OBJECT lc_menu_search.
    CALL METHOD lc_menu_search->add_function
                EXPORTING fcode   = 'DEL_ITEM'
                          text    = text-025.

    CALL METHOD lc_menu_search->add_function
                EXPORTING fcode   = 'DEL_JOB'
                text    = text-024.
    ls_menu-ctmenu = lc_menu_search.
    ls_menu-function = 'SEARCH'.
    APPEND ls_menu TO e_object->mt_btnmnu.


  ENDMETHOD.

  METHOD handle_menu_button.
  ENDMETHOD.


  METHOD handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'DEL_ITEM'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DEL_ITEM'
*      IMPORTING
*        RC       =
            .
      WHEN 'DEL_JOB'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DEL_JOB'
*      IMPORTING
*        RC       =
            .

      WHEN 'CH_COPY'.
        IF alv_plotjobs->is_ready_for_input( ) EQ 0.
          CALL METHOD alv_plotjobs->set_ready_for_input
                   EXPORTING i_ready_for_input = 1.
        ELSE.
          CALL METHOD alv_plotjobs->set_ready_for_input
                   EXPORTING i_ready_for_input = 0.
        ENDIF.

      WHEN 'CH_PREPR'.
        CALL METHOD alv_plotjobs->get_selected_rows
          IMPORTING
            et_index_rows = lt_rows.

        IF lt_rows IS INITIAL.
          MESSAGE i022(/cideon/plot_admin).
        ELSE.
          PERFORM change_preprocessor TABLES lt_rows.
        ENDIF.


      WHEN 'KNZ_AUTO_PROC_ON'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'KNZ_AUTO_PROC_ON'
*      IMPORTING
*        RC       =
            .
      WHEN 'KNZ_AUTO_PROC_OFF'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'KNZ_AUTO_PROC_OFF'
*      IMPORTING
*        RC       =
            .
      WHEN 'DWNL_LOCAL'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DWNL_LOCAL'
*      IMPORTING
*        RC       =
            .
      WHEN 'STR_KONV'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'STR_KONV'
*      IMPORTING
*        RC       =
            .

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD handle_hotspot_click.
    index_itab_searchlist = e_row_id.
    READ TABLE itab_v_adm_01 INDEX index_itab_searchlist INTO
      wa_v_adm_01.

    CASE e_column_id-fieldname.
      WHEN 'ICON_DISPLAY_DIS'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'HOT_SPOT_CLICK_DISPLAY_DIS'
*      IMPORTING
*        RC       =
            .

      WHEN 'ICON_DISPLAY'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'HOT_SPOT_CLICK_DISPLAY'
*      IMPORTING
*        RC       =
            .

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD handle_data_changed.

    DATA: ls_good TYPE lvc_s_modi.
    error_in_data = space.

    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
      CASE ls_good-fieldname.
*       check if column 'KOPIEN' of this row was changed
        WHEN 'KOPIEN'.
          CALL METHOD check_copy
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.

        WHEN 'SATZANZAHL'.
          CALL METHOD check_satz
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.

        WHEN 'PARA1'.
          CALL METHOD check_para
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
        WHEN 'PARA2'.
          CALL METHOD check_para2
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
        WHEN 'PARA3'.
          CALL METHOD check_para3
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
        WHEN 'PARA4'.
          CALL METHOD check_para4
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
        WHEN 'PARA5'.
          CALL METHOD check_para5
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
        WHEN 'PARA6'.
          CALL METHOD check_para6
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
        WHEN 'PARA7'.
          CALL METHOD check_para7
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
        WHEN 'PARA8'.
          CALL METHOD check_para8
                 EXPORTING
                    ps_good_copy = ls_good
                    pr_data_changed   = er_data_changed.
      ENDCASE.
    ENDLOOP.

*   Display application log if an error has occured.
    IF error_in_data EQ 'X'.
      CALL METHOD er_data_changed->display_protocol.
    ENDIF.


  ENDMETHOD.


  METHOD handle_close.
* handle method close dialogbox for changing preprocessor/verteiler
    CALL METHOD sender->set_visible
          EXPORTING visible = space.
    FREE dialogbox_container.
    CLEAR dialogbox_container.
    FREE alv_preprocessor.
    CLEAR alv_preprocessor.

  ENDMETHOD.



  METHOD check_copy.


    DATA: l_copy TYPE /cideon/_s_adm_01-kopien.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_copy.
*   check number
    IF l_copy BETWEEN 0 AND 99.
      CALL METHOD pr_data_changed->modify_cell
                 EXPORTING i_row_id    = ps_good_copy-row_id
                           i_fieldname = 'KOPIEN'
                           i_value     = l_copy.
      CLEAR wa_v_adm_01.
      wa_v_adm_01-kopien = l_copy.
*     modify itab
      MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
            TRANSPORTING kopien.
*     update DB
      CLEAR wa_v_adm_01.
      READ TABLE itab_v_adm_01 INTO wa_v_adm_01
            INDEX ps_good_copy-row_id.

      SELECT SINGLE * FROM /cideon/pl_jobs1 INTO wa_pl_jobs1
        WHERE id_plotjob = wa_v_adm_01-id_plotjob
        AND   cont = wa_v_adm_01-cont.

      wa_pl_jobs1-kopien     = wa_v_adm_01-kopien.
      wa_pl_jobs1-zclupdname = sy-uname.
      wa_pl_jobs1-zclupddate = sy-datum.
      wa_pl_jobs1-zclupdtime = sy-uzeit.
      wa_pl_jobs1-zclupdprog = sy-repid.


      UPDATE /cideon/pl_jobs1 FROM wa_pl_jobs1.
*check update DB
      IF sy-subrc NE 0.
        MESSAGE e001(/cideon/plot_admin)
          WITH '/CIDEON/PL_JOBSS' '' '' ''.
        ROLLBACK WORK.
        EXIT.
      ELSE.
      ENDIF.


    ELSE.

* In case of error, create a protocol entry in the application log.
* Possible values for message type ('i_msgty'):
*
*    'A': Abort (Stop sign)
*    'E': Error (red LED)
*    'W': Warning (yellow LED)
*    'I': Information (green LED)
*
      CALL METHOD pr_data_changed->add_protocol_entry
       EXPORTING
          i_msgid = '0K' i_msgno = '000'  i_msgty = 'E'
          i_msgv1 = text-053           "Kopienzahl
          i_msgv2 = l_copy
          i_msgv3 = text-054           "ungültig
          i_fieldname = ps_good_copy-fieldname
          i_row_id = ps_good_copy-row_id.

      error_in_data = 'X'.
      EXIT. "ungültige Koipienzahl, so we're finished here!
    ENDIF.

*    CALL METHOD alv_plotjobs->refresh_table_display.


  ENDMETHOD.                           " CHECK_COPY
*---------------------------------------------------------------------*

  METHOD check_satz.


    DATA: l_copy TYPE /cideon/_s_adm_01-satzanzahl.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_copy.
*   check number
    IF l_copy BETWEEN 0 AND 99.
      CALL METHOD pr_data_changed->modify_cell
                 EXPORTING i_row_id    = ps_good_copy-row_id
                           i_fieldname = 'SATZANZAHL'
                           i_value     = l_copy.
      CLEAR wa_v_adm_01.
      wa_v_adm_01-satzanzahl = l_copy.
*     modify itab
      MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
            TRANSPORTING satzanzahl.
*     update DB
      CLEAR wa_v_adm_01.
      READ TABLE itab_v_adm_01 INTO wa_v_adm_01
            INDEX ps_good_copy-row_id.

      SELECT SINGLE * FROM /cideon/pl_jobs1 INTO wa_pl_jobs1
        WHERE id_plotjob = wa_v_adm_01-id_plotjob
        AND   cont = wa_v_adm_01-cont.

      wa_pl_jobs1-satzanzahl     = wa_v_adm_01-satzanzahl.
      wa_pl_jobs1-zclupdname = sy-uname.
      wa_pl_jobs1-zclupddate = sy-datum.
      wa_pl_jobs1-zclupdtime = sy-uzeit.
      wa_pl_jobs1-zclupdprog = sy-repid.


      UPDATE /cideon/pl_jobs1 FROM wa_pl_jobs1.
*check update DB
      IF sy-subrc NE 0.
        MESSAGE e001(/cideon/plot_admin)
          WITH '/CIDEON/PL_JOBSS' '' '' ''.
        ROLLBACK WORK.
        EXIT.
      ELSE.
      ENDIF.


    ELSE.

* In case of error, create a protocol entry in the application log.
* Possible values for message type ('i_msgty'):
*
*    'A': Abort (Stop sign)
*    'E': Error (red LED)
*    'W': Warning (yellow LED)
*    'I': Information (green LED)
*
      CALL METHOD pr_data_changed->add_protocol_entry
       EXPORTING
          i_msgid = '0K' i_msgno = '000'  i_msgty = 'E'
          i_msgv1 = text-053           "Kopienzahl
          i_msgv2 = l_copy
          i_msgv3 = text-054           "ungültig
          i_fieldname = ps_good_copy-fieldname
          i_row_id = ps_good_copy-row_id.

      error_in_data = 'X'.
      EXIT. "ungültige Koipienzahl, so we're finished here!
    ENDIF.

*    CALL METHOD alv_plotjobs->refresh_table_display.


  ENDMETHOD.                           " CHECK_COPY


  METHOD check_para.
    DATA: l_para TYPE /cideon/_s_adm_01-para1.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para1 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para1.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para1     = wa_v_adm_01-para1.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.



  METHOD check_para2.
    DATA: l_para TYPE /cideon/_s_adm_01-para2.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para2 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para2.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para2     = wa_v_adm_01-para2.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.

  METHOD check_para3.
    DATA: l_para TYPE /cideon/_s_adm_01-para3.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para3 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para3.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para3     = wa_v_adm_01-para3.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.

  METHOD check_para4.
    DATA: l_para TYPE /cideon/_s_adm_01-para1.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para4 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para4.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para4     = wa_v_adm_01-para4.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.

  METHOD check_para5.
    DATA: l_para TYPE /cideon/_s_adm_01-para1.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para5 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para5.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para5     = wa_v_adm_01-para5.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.

  METHOD check_para6.
    DATA: l_para TYPE /cideon/_s_adm_01-para6.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para6 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para6.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para6     = wa_v_adm_01-para6.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.

  METHOD check_para7.
    DATA: l_para TYPE /cideon/_s_adm_01-para7.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para7 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para7.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para7     = wa_v_adm_01-para7.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.

  METHOD check_para8.
    DATA: l_para TYPE /cideon/_s_adm_01-para8.

    CALL METHOD pr_data_changed->get_cell_value
              EXPORTING i_row_id =    ps_good_copy-row_id
                        i_fieldname = ps_good_copy-fieldname
              IMPORTING e_value     = l_para.

    CALL METHOD pr_data_changed->modify_cell
               EXPORTING i_row_id    = ps_good_copy-row_id
                         i_fieldname = ps_good_copy-fieldname
                         i_value     = l_para.
    CLEAR wa_v_adm_01.
    wa_v_adm_01-para8 = l_para.
*     modify itab
    MODIFY itab_v_adm_01 FROM  wa_v_adm_01 INDEX ps_good_copy-row_id
          TRANSPORTING para8.
*     update DB
    CLEAR wa_v_adm_01.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01
          INDEX ps_good_copy-row_id.

    CLEAR wa_pl_jobs4.
    SELECT SINGLE * FROM /cideon/pl_jobs4 INTO wa_pl_jobs4
      WHERE id_plotjob = wa_v_adm_01-id_plotjob
      AND   cont = wa_v_adm_01-cont.

    wa_pl_jobs4-para8     = wa_v_adm_01-para8.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = sy-repid.


    UPDATE /cideon/pl_jobs4 FROM wa_pl_jobs4.
*check update DB
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
*    CALL METHOD alv_plotjobs->refresh_table_display.
  ENDMETHOD.

ENDCLASS.
