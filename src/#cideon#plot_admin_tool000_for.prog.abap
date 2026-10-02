*----------------------------------------------------------------------*
*   INCLUDE ZCK_MAINT_ZCL_USR_GRP_KL_FORM                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_sel_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sel_items.
* holt die selektierten Einträge

  CLEAR itab_et_index_rows_plotjobs .
  CLEAR wa_et_index_rows_plotjobs .

  CALL METHOD alv_plotjobs->get_selected_rows
     IMPORTING
       et_index_rows = itab_et_index_rows_plotjobs
*       ET_ROW_NO     =
      .

  CLEAR itab_plot_item.
  CLEAR wa_plot_item.

  LOOP AT itab_et_index_rows_plotjobs INTO
    wa_et_index_rows_plotjobs.
    index_itab_plotjobs = wa_et_index_rows_plotjobs-index.
    READ TABLE itab_v_adm_01 INTO wa_v_adm_01 INDEX index_itab_plotjobs.
    APPEND wa_v_adm_01 TO itab_plot_item.
  ENDLOOP.



ENDFORM.                    " get_sel_items
*&---------------------------------------------------------------------*
*&      Form  get_sel_jobs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sel_jobs.
* holt die Jobs für die selektierten Einträge
  DATA: itab_plot_item_tmp LIKE itab_plot_item.
  DATA: itab_plot_item_tmp_new LIKE itab_plot_item.

  CLEAR itab_plot_item_tmp.
  CLEAR itab_plot_item_tmp_new.
  itab_plot_item_tmp[] = itab_plot_item[].

  SORT itab_plot_item_tmp BY id_plotjob.
  DELETE ADJACENT DUPLICATES FROM itab_plot_item_tmp
    COMPARING id_plotjob.

*  LOOP AT itab_plot_item_tmp INTO wa_plot_item.
*    SELECT * FROM /cideon/v_adm_01
*      APPENDING TABLE itab_plot_item_tmp_new
*      WHERE id_plotjob = wa_plot_item-id_plotjob
*      .
*    IF sy-subrc NE 0.
*    ELSE.
*    ENDIF.
*  ENDLOOP.


  LOOP AT itab_plot_item_tmp INTO wa_plot_item.
    SELECT * FROM /cideon/v_adm_02
      APPENDING CORRESPONDING FIELDS OF TABLE itab_plot_item_tmp_new
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.
  ENDLOOP.


* Rest der Daten nachlesen
  DATA: wa_itab_plot_item_tmp_new TYPE /cideon/_s_adm_01.
  DATA: index TYPE i.
  CLEAR index.
  LOOP AT itab_plot_item_tmp_new INTO wa_itab_plot_item_tmp_new.
    index = sy-tabix.
    SELECT SINGLE * FROM /cideon/pl_jobs1
    INTO CORRESPONDING FIELDS
    OF wa_itab_plot_item_tmp_new
    WHERE id_plotjob = wa_itab_plot_item_tmp_new-id_plotjob
    AND cont = wa_itab_plot_item_tmp_new-cont
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM /cideon/pl_jobs2
    INTO CORRESPONDING FIELDS
    OF wa_itab_plot_item_tmp_new
    WHERE id_plotjob = wa_itab_plot_item_tmp_new-id_plotjob
    AND cont = wa_itab_plot_item_tmp_new-cont
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM /cideon/pl_jobs3
    INTO CORRESPONDING FIELDS
    OF wa_itab_plot_item_tmp_new
    WHERE id_plotjob = wa_itab_plot_item_tmp_new-id_plotjob
    AND cont = wa_itab_plot_item_tmp_new-cont
    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM /cideon/pl_jobsc
    INTO CORRESPONDING FIELDS
    OF wa_itab_plot_item_tmp_new
    WHERE id_plotjob = wa_itab_plot_item_tmp_new-id_plotjob

    .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    MODIFY itab_plot_item_tmp_new FROM wa_itab_plot_item_tmp_new
      INDEX index.
  ENDLOOP.


  itab_plot_item[] = itab_plot_item_tmp_new[].

ENDFORM.                    " get_sel_jobs
*&---------------------------------------------------------------------*
*&      Form  set_sel_job_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_sel_job_items.
* selektiert an Hand der Jobs die Items nach, falls notwendig
  DATA: index_in TYPE i.
  CLEAR itab_et_index_rows_plotjobs.

  CLEAR wa_et_index_rows_plotjobs.

  LOOP AT itab_plot_item INTO wa_plot_item.
    LOOP AT itab_v_adm_01 INTO wa_v_adm_01
      WHERE id_plotjob = wa_plot_item-id_plotjob
      AND cont = wa_plot_item-cont.
      index_in = sy-tabix.
      wa_et_index_rows_plotjobs-index = index_in.
      APPEND wa_et_index_rows_plotjobs TO itab_et_index_rows_plotjobs.
    ENDLOOP.
  ENDLOOP.

  CALL METHOD alv_plotjobs->set_selected_rows
    EXPORTING
      it_index_rows = itab_et_index_rows_plotjobs
*          IT_ROW_NO     =
      .



ENDFORM.                    " set_sel_job_items
*&---------------------------------------------------------------------*
*&      Form  send_plot_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_plot_items.
* list aus den Tabellen die Einträge und sendet die entsprechenden
* Dateien
  DATA: itab_plot_item_tmp LIKE itab_plot_item.
  DATA: itab_pl_jobs1 TYPE TABLE OF /cideon/pl_jobs1.
  DATA: itab_pl_jobs2 TYPE TABLE OF /cideon/pl_jobs2.
  DATA: itab_pl_jobs3 TYPE TABLE OF /cideon/pl_jobs3.
  DATA: itab_pl_jobsc TYPE TABLE OF /cideon/pl_jobsc.
  DATA: itab_pl_jobss TYPE TABLE OF /cideon/pl_jobss.

  DATA: wa_pl_jobs1 TYPE /cideon/pl_jobs1.
  DATA: wa_pl_jobs2 TYPE /cideon/pl_jobs2.
  DATA: wa_pl_jobs3 TYPE /cideon/pl_jobs3.
  DATA: wa_pl_jobsc TYPE /cideon/pl_jobsc.
  DATA: wa_pl_jobss TYPE /cideon/pl_jobss.

  IF itab_plot_item[] IS INITIAL.
    MESSAGE w008(/cideon/plot_admin) WITH '' '' '' ''.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR itab_plot_item_tmp.
  itab_plot_item_tmp[] = itab_plot_item[].

  SORT itab_plot_item_tmp BY id_plotjob.
  DELETE ADJACENT DUPLICATES FROM itab_plot_item_tmp
    COMPARING id_plotjob.

  LOOP AT itab_plot_item_tmp INTO wa_plot_item.
*   entsprechende Daten aus der Liste lesen
*   COntrol
*   Job 1 Job 2
*   Stempel
    CLEAR itab_pl_jobs1.
    CLEAR itab_pl_jobs2.
    CLEAR itab_pl_jobs3.
    CLEAR itab_pl_jobsc.
    CLEAR itab_pl_jobss.

    SELECT * FROM /cideon/pl_jobs1 INTO TABLE itab_pl_jobs1
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
      MESSAGE s003(/cideon/plot_admin) WITH
      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
      CONTINUE.
    ELSE.
    ENDIF.

    SELECT * FROM /cideon/pl_jobs2 INTO TABLE itab_pl_jobs2
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
      MESSAGE s003(/cideon/plot_admin) WITH
      '/cideon/pl_jobs2' wa_plot_item-id_plotjob '' ''.
      CONTINUE.
    ELSE.
    ENDIF.

    SELECT * FROM /cideon/pl_jobs3 INTO TABLE itab_pl_jobs3
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
      MESSAGE s003(/cideon/plot_admin) WITH
      '/cideon/pl_jobs3' wa_plot_item-id_plotjob '' ''.
      CONTINUE.
    ELSE.
    ENDIF.

    SELECT * FROM /cideon/pl_jobsc INTO TABLE itab_pl_jobsc
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
      MESSAGE s003(/cideon/plot_admin) WITH
      '/cideon/pl_jobsc' wa_plot_item-id_plotjob '' ''.
      CONTINUE.
    ELSE.
    ENDIF.

    SELECT * FROM /cideon/pl_jobss INTO TABLE itab_pl_jobss
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
* CKR 2006/08/10 möglicherweise keine Stempel vorhanden.....
*      MESSAGE s003(/cideon/plot_admin) WITH
*      '/cideon/pl_jobss' wa_plot_item-id_plotjob '' ''.
      CONTINUE.
    ELSE.
    ENDIF.

*   Tabellen
    CLEAR itab_tmp_plotjobs_2.
    CLEAR itab_stempel_wert.
    CLEAR wa_plotjobs.

    READ TABLE itab_pl_jobsc INTO wa_pl_jobsc INDEX 1.

    LOOP AT itab_pl_jobs1 INTO wa_pl_jobs1.
      CLEAR wa_plotjobs.
      MOVE-CORRESPONDING wa_pl_jobs1 TO wa_plotjobs.
      LOOP AT itab_pl_jobs2 INTO wa_pl_jobs2
        WHERE id_plotjob = wa_pl_jobs1-id_plotjob
        AND cont = wa_pl_jobs1-cont.
        MOVE-CORRESPONDING wa_pl_jobs2 TO wa_plotjobs.
        wa_plotjobs-knz_use_checked_in =
          wa_pl_jobs2-knz_use_checked_ .
      ENDLOOP.

      LOOP AT itab_pl_jobs3 INTO wa_pl_jobs3
        WHERE id_plotjob = wa_pl_jobs1-id_plotjob
        AND cont = wa_pl_jobs1-cont.
        MOVE-CORRESPONDING wa_pl_jobs3 TO wa_plotjobs.

      ENDLOOP.

      APPEND wa_plotjobs TO itab_tmp_plotjobs_2.
    ENDLOOP.

    LOOP AT itab_pl_jobss INTO wa_pl_jobss.
      CLEAR wa_stempel_wert.
      MOVE-CORRESPONDING wa_pl_jobss TO wa_stempel_wert.
      APPEND wa_stempel_wert TO itab_stempel_wert.
    ENDLOOP.

    CLEAR str_down_path.
    CLEAR str_ppl_down_path.

    str_down_path = wa_pl_jobsc-down_path.
    str_ppl_down_path = wa_pl_jobsc-clf_down_path.

*    wa_pl_jobsc-knz_use_new_clf = 'X'.

    IF wa_pl_jobsc-knz_use_new_clf = 'X'.
      CALL FUNCTION 'ZCL_CLF10_PROCESS_PLOT_LIST'
           EXPORTING
                default_user       = default_data-default_nutzer
                i_down_path        = str_down_path
                i_clf_down_path    = str_ppl_down_path
                filter             = '*.*'
                i_out_proc         = wa_pl_jobsc-knz_auto_process
                i_delete_item      = wa_pl_jobsc-delete_item
                i_delete_status    = wa_pl_jobsc-delete_status
                i_format_checking  = wa_pl_jobsc-format_checking
                i_knz_use_converte = wa_pl_jobsc-knz_use_converte
                i_converter_name   = wa_pl_jobsc-converter_name
                i_converter_number = wa_pl_jobsc-converter_number
                i_ftp_destination  = wa_pl_jobsc-ftp_destination
                i_ftp_user         = wa_pl_jobsc-ftp_user
                i_ftp_passwd       = wa_pl_jobsc-ftp_passwd
                i_ftp_down         = wa_pl_jobsc-ftp_down
                i_user_data        = user_data
                f_dyn_toc          = ''
                f_dyn_cov          = ''
           TABLES
                itab_test          = itab_tmp_plotjobs_2
                itab_stamps        = itab_stempel_wert
                it_notiz           = it_notiz
           EXCEPTIONS
                error              = 1
                OTHERS             = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        COMMIT WORK AND WAIT.
        MESSAGE s015(/cideon/plot_admin) WITH '' '' '' ''.
      ENDIF.
    ELSE.
      CALL FUNCTION 'Z_CL_NEW_PLOT_LIST_CLF'
           EXPORTING
                default_user       = default_data-default_nutzer
                i_down_path        = str_down_path
                i_clf_down_path    = str_ppl_down_path
                filter             = '*.*'
                i_out_proc         = wa_pl_jobsc-knz_auto_process
                i_delete_item      = wa_pl_jobsc-delete_item
                i_delete_status    = wa_pl_jobsc-delete_status
                i_format_checking  = wa_pl_jobsc-format_checking
                i_knz_use_converte = wa_pl_jobsc-knz_use_converte
                i_converter_name   = wa_pl_jobsc-converter_name
                i_converter_number = wa_pl_jobsc-converter_number
                i_ftp_destination  = wa_pl_jobsc-ftp_destination
                i_ftp_user         = wa_pl_jobsc-ftp_user
                i_ftp_passwd       = wa_pl_jobsc-ftp_passwd
                i_ftp_down         = wa_pl_jobsc-ftp_down
           TABLES
                itab_test          = itab_tmp_plotjobs_2
                itab_stamps        = itab_stempel_wert
           EXCEPTIONS
                error              = 1
                OTHERS             = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        COMMIT WORK AND WAIT.
        MESSAGE s015(/cideon/plot_admin) WITH '' '' '' ''.
      ENDIF.
    ENDIF.

    UPDATE /cideon/pl_jobs2
      SET:  status = c_status_processed_plot
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.


  ENDLOOP.


ENDFORM.                    " send_plot_items

*&---------------------------------------------------------------------*
*&      Form  DELETE_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_item.
  DATA: wa_plojobs1_tmp TYPE /cideon/pl_jobs1.

  IF itab_plot_item[] IS INITIAL.
    MESSAGE w008(/cideon/plot_admin) WITH '' '' '' ''.
    EXIT.
  ELSE.
  ENDIF.

* Löscht einzelnes markiertes Item
  LOOP AT itab_plot_item INTO wa_plot_item.
    DELETE FROM /cideon/pl_jobs1
      WHERE id_plotjob = wa_plot_item-id_plotjob
      AND cont = wa_plot_item-cont
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

    DELETE FROM /cideon/pl_jobs2
      WHERE id_plotjob = wa_plot_item-id_plotjob
      AND cont = wa_plot_item-cont
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

    DELETE FROM /cideon/pl_jobs3
      WHERE id_plotjob = wa_plot_item-id_plotjob
      AND cont = wa_plot_item-cont
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

    DELETE FROM /cideon/pl_jobss
      WHERE id_plotjob = wa_plot_item-id_plotjob
      AND zeile_plotjob = wa_plot_item-cont
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

*   testen, ob noch ein Datensatz mit den Verwaltungsdatensatz
*   verknüpft ist
    SELECT SINGLE * FROM /cideon/pl_jobs1 INTO wa_plojobs1_tmp
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
*     kein weiterer Datensatz verknüpft, dann löschen....
      DELETE FROM /cideon/pl_jobsc
        WHERE id_plotjob = wa_plot_item-id_plotjob
        .
      IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " DELETE_ITEM
*&---------------------------------------------------------------------*
*&      Form  DELETE_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_job.
* löscht alle Jobs, die zu den markierten Items gehören ..

  SORT itab_plot_item BY id_plotjob.
  DELETE ADJACENT DUPLICATES FROM itab_plot_item
    COMPARING id_plotjob.

  IF itab_plot_item[] IS INITIAL.
    MESSAGE w008(/cideon/plot_admin) WITH '' '' '' ''.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_plot_item INTO wa_plot_item.
    DELETE FROM /cideon/pl_jobs1
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

    DELETE FROM /cideon/pl_jobs2
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

    DELETE FROM /cideon/pl_jobs3
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

    DELETE FROM /cideon/pl_jobss
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

    DELETE FROM /cideon/pl_jobsc
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
*      MESSAGE s004(/cideon/plot_admin) WITH
*      '/cideon/pl_jobs1' wa_plot_item-id_plotjob '' ''.
    ELSE.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " DELETE_JOB
*&---------------------------------------------------------------------*
*&      Form  RELOAD_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reload_alv.
* Lädt die interne Tabelle für den ALV
  CLEAR itab_v_adm_01.

*  SELECT * FROM /cideon/v_adm_01
*    UP TO max_sel ROWS BYPASSING BUFFER
*    INTO CORRESPONDING FIELDS OF TABLE itab_v_adm_01
*    WHERE id_plotjob IN p_id
*    AND uname IN p_un
*    AND notiz IN p_note
*    AND preprocessor IN p_prepro
*    AND status IN p_status
*
*    AND zclinsname IN p_insn
*    AND zclinsdate IN p_insd
*    AND zclinstime IN p_inst
*    AND zclinsprog IN p_insp
*    AND zclupdname IN p_updn
*    AND zclupddate IN p_updd
*    AND zclupdtime IN p_updt
*    AND zclupdprog IN p_updp
*    .
*  IF sy-subrc NE 0.
*  ELSE.
*  ENDIF.

* kleinen View lesen und großen View daraum machen
* /CIDEON/V_ADM_02

  DATA: it_v_adm_02 TYPE TABLE OF /cideon/v_adm_02.
  DATA: wa_v_adm_02 TYPE /cideon/v_adm_02.
  CLEAR it_v_adm_02.

  SELECT * FROM /cideon/v_adm_02
    UP TO max_sel ROWS BYPASSING BUFFER
    INTO CORRESPONDING FIELDS OF TABLE it_v_adm_02
    WHERE id_plotjob IN p_id
    AND uname IN p_un
    AND notiz IN p_note
    AND preprocessor IN p_prepro
    AND status IN p_status

    AND para1 IN p_para1
    AND para2 IN p_para2
    AND para3 IN p_para3
    AND para4 IN p_para4

    AND zclinsname IN p_insn
    AND zclinsdate IN p_insd
    AND zclinstime IN p_inst
    AND zclinsprog IN p_insp
    AND zclupdname IN p_updn
    AND zclupddate IN p_updd
    AND zclupdtime IN p_updt
    AND zclupdprog IN p_updp
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Nachlesen der Informationen für die Anzeige des Views
*/cideon/pl_jobs1
*/cideon/pl_jobs2,
*/cideon/pl_jobs3,
*/cideon/pl_jobss,
*/cideon/pl_jobsc

  LOOP AT it_v_adm_02 INTO wa_v_adm_02.
    CLEAR wa_v_adm_01.

    SELECT SINGLE * FROM /cideon/pl_jobs1
      INTO CORRESPONDING FIELDS
      OF wa_v_adm_01
      WHERE id_plotjob = wa_v_adm_02-id_plotjob
      AND cont = wa_v_adm_02-cont
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM /cideon/pl_jobs2
      INTO CORRESPONDING FIELDS
      OF wa_v_adm_01
      WHERE id_plotjob = wa_v_adm_02-id_plotjob
      AND cont = wa_v_adm_02-cont
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM /cideon/pl_jobs3
      INTO CORRESPONDING FIELDS
      OF wa_v_adm_01
      WHERE id_plotjob = wa_v_adm_02-id_plotjob
      AND cont = wa_v_adm_02-cont
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM /cideon/pl_jobs4
      INTO CORRESPONDING FIELDS
      OF wa_v_adm_01
      WHERE id_plotjob = wa_v_adm_02-id_plotjob
      AND cont = wa_v_adm_02-cont
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    SELECT SINGLE * FROM /cideon/pl_jobsc
      INTO CORRESPONDING FIELDS
      OF wa_v_adm_01
      WHERE id_plotjob = wa_v_adm_02-id_plotjob
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.



    APPEND wa_v_adm_01 TO itab_v_adm_01.
  ENDLOOP.






* Exception setzen
  LOOP AT itab_v_adm_01 INTO wa_v_adm_01.
    index = sy-tabix.
    wa_v_adm_01-light = '3'.
    MODIFY itab_v_adm_01 FROM wa_v_adm_01 INDEX index.
  ENDLOOP.

* Fehlblätter / Spezialdokumente
  LOOP AT itab_v_adm_01 INTO wa_v_adm_01.
    index = sy-tabix.

    IF wa_v_adm_01-knz_fehl_blatt = 'X'
      OR ( wa_v_adm_01-knz_spez_dok = 'X'
          AND wa_v_adm_01-object_type NE 'SPOOL'
          ).
      wa_v_adm_01-light = '1'.
      LOOP AT itab_v_adm_01 INTO wa_tmp_v_adm_01
        WHERE
        id_plotjob = wa_v_adm_01-id_plotjob.
        index2 = sy-tabix.
        wa_tmp_v_adm_01-light = '1'.
        MODIFY itab_v_adm_01 FROM wa_tmp_v_adm_01 INDEX index2.
      ENDLOOP.
      CONTINUE.
    ELSE.
*      wa_v_adm_01-light = '3'.
    ENDIF.

    MODIFY itab_v_adm_01 FROM wa_v_adm_01 INDEX index.
  ENDLOOP.

  LOOP AT itab_v_adm_01 INTO wa_v_adm_01.
    index = sy-tabix.

    CASE wa_v_adm_01-status.
      WHEN '00'.
        "angelegt
        wa_v_adm_01-icon_status = icon_create.
      WHEN '10'.
        "in Bearbeitung
        wa_v_adm_01-icon_status = icon_activity.
      WHEN '20'.
        "Verarbeitet
        wa_v_adm_01-icon_status = icon_checked.
      WHEN '30'.
        "Fehler
        wa_v_adm_01-icon_status = icon_cancel.
      WHEN '40'.
        "gesperrt
        wa_v_adm_01-icon_status = icon_system_cancel.
      WHEN OTHERS.
        wa_v_adm_01-icon_status = ''.
    ENDCASE.

    MODIFY itab_v_adm_01 FROM wa_v_adm_01 INDEX index.
  ENDLOOP.


  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = '30'  " Balkenanzeige
            text       = text-040.

  CLEAR anzahl_items.
  CLEAR anzahl_jobs.
  IF itab_v_adm_01[] IS INITIAL.
    MESSAGE s002(/cideon/plot_admin) WITH '' '' '' ''.
*   Keine Daten für Selektion verfügbar. & & & &
  ELSE.
    DESCRIBE TABLE itab_v_adm_01 LINES anzahl_items.

    CLEAR itab_count.
    CLEAR wa_count.
    LOOP AT itab_v_adm_01 INTO wa_v_adm_01.
      CLEAR wa_count.
      wa_count-id_plotjob = wa_v_adm_01-id_plotjob.
      APPEND wa_count TO itab_count.
    ENDLOOP.
    SORT itab_count BY id_plotjob.
    DELETE ADJACENT DUPLICATES FROM itab_count.
    DESCRIBE TABLE itab_count LINES anzahl_jobs.
  ENDIF.

ENDFORM.                    " RELOAD_ALV
*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_alv.
* aktualisiert die Anzeige des ALV

  CALL METHOD alv_plotjobs->refresh_table_display
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


ENDFORM.                    " REFRESH_ALV
*&---------------------------------------------------------------------*
*&      Form  VIEW_DIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* Änderungen:
*  28.06.2004   HAENSELH  ALV Grid f. Plot Jobs vor der Anzeige des
*                         Spools verstecken und nachher wieder sichtbar
*                         machen.
************************************************************************
FORM view_dis.
* Anzeige des DIS

* Spoolbehandlung
  IF wa_v_adm_01-object_type = 'SPOOL'.
    CALL METHOD alv_plotjobs->set_visible( ' ' ).
*    call method cl_gui_cfw=>flush.
    CALL FUNCTION '/CIDEON/DISPLAY_SPOOL_ID'
         EXPORTING
              i_spoolid = wa_v_adm_01-tdspoolid
         EXCEPTIONS
              error     = 1
              OTHERS    = 2.
    IF sy-subrc <> 0.
*      EXIT.
    ENDIF.
    CALL METHOD alv_plotjobs->set_visible( 'X' ).
*    EXIT.
  ELSE.
    SET PARAMETER ID 'CV1' FIELD wa_v_adm_01-doknr.
    SET PARAMETER ID 'CV2' FIELD wa_v_adm_01-dokar.
    SET PARAMETER ID 'CV3' FIELD wa_v_adm_01-dokvr.
    SET PARAMETER ID 'CV4' FIELD wa_v_adm_01-doktl.

    CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
  ENDIF.


ENDFORM.                    " VIEW_DIS
*&---------------------------------------------------------------------*
*&      Form  change_fehl_blatt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_fehl_blatt.
* Fehlblattbehandlung
* testen, ob nur ein Eintrag ausgewählt wurde....
  DATA: anzahl_items TYPE i.
  DATA: itab_plot_item_tmp TYPE TABLE OF /cideon/_s_adm_01.
  DATA: wa_plot_item_tmp LIKE wa_plot_item.
  DATA: pos TYPE /cideon/pl_jobss-zeile_plotjob.
  DATA: cont_i TYPE i.
  DATA: max_item TYPE i.
  DATA: anzahl_stempel_werte TYPE i.
  DATA: index_pl_jobss TYPE i.

  CLEAR anzahl_items.
  DESCRIBE TABLE itab_plot_item LINES anzahl_items.
  IF anzahl_items = 1.
  ELSE.
    MESSAGE w005(/cideon/plot_admin) WITH '' '' '' ''.
    EXIT.
  ENDIF.

  READ TABLE itab_plot_item INTO wa_plot_item INDEX 1.

  IF wa_plot_item-knz_fehl_blatt = 'X'.
  ELSE.
    MESSAGE w006(/cideon/plot_admin) WITH '' '' '' ''.
    EXIT.
  ENDIF.

* neues Original auswählen lassen
  CLEAR wa_plot_item_tmp.
*  CALL FUNCTION '/CIDEON/MAKE_SEL_FOR_ORIGINAL'
*       EXPORTING
*            i_wa_plot_item = wa_plot_item
*       IMPORTING
*            o_wa_plot_item = wa_plot_item_tmp
*       EXCEPTIONS
*            error          = 1
*            no_selection   = 2
*            OTHERS         = 3.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    CASE sy-subrc.
*      WHEN '1'.
*        MESSAGE w007(/cideon/plot_admin) WITH '' '' '' ''.
*      WHEN '2'.
*        EXIT.
*      WHEN '3'.
*        EXIT.
*      WHEN OTHERS.
*        EXIT.
*    ENDCASE.
*  ELSE.
*  ENDIF.

  CALL FUNCTION '/CIDEON/MAKE_SEL_FOR_ORIGINAL2'
       EXPORTING
            i_wa_plot_item   = wa_plot_item
       IMPORTING
            o_wa_plot_item   = wa_plot_item_tmp
       TABLES
            o_itab_plot_item = itab_plot_item_tmp
       EXCEPTIONS
            error            = 1
            no_selection     = 2
            OTHERS           = 3.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN '1'.
        MESSAGE w007(/cideon/plot_admin) WITH '' '' '' ''.
      WHEN '2'.
        EXIT.
      WHEN '3'.
        EXIT.
      WHEN OTHERS.
        EXIT.
    ENDCASE.
  ENDIF.


  READ TABLE itab_plot_item_tmp INTO wa_plot_item_tmp INDEX 1.
*   Tabellen aktualisieren
  CLEAR wa_pl_jobs1.
  SELECT SINGLE * FROM /cideon/pl_jobs1 INTO wa_pl_jobs1
    WHERE id_plotjob = wa_plot_item-id_plotjob
    AND cont = wa_plot_item-cont
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_pl_jobs2.
  SELECT SINGLE * FROM /cideon/pl_jobs2 INTO wa_pl_jobs2
    WHERE id_plotjob = wa_plot_item-id_plotjob
    AND cont = wa_plot_item-cont
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_pl_jobs3.
  SELECT SINGLE * FROM /cideon/pl_jobs3 INTO wa_pl_jobs3
    WHERE id_plotjob = wa_plot_item-id_plotjob
    AND cont = wa_plot_item-cont
    .
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_pl_jobs1-icon_fehlblatt.
  wa_pl_jobs1-checked = wa_plot_item_tmp-checked.
  wa_pl_jobs1-filep = wa_plot_item_tmp-filep.
  wa_pl_jobs1-filename = wa_plot_item_tmp-filename.
  wa_pl_jobs1-wsapplication = wa_plot_item_tmp-wsapplication.

  wa_pl_jobs2-knz_fehl_blatt = wa_plot_item_tmp-knz_fehl_blatt.
  wa_pl_jobs2-application_id = wa_plot_item_tmp-application_id.
  wa_pl_jobs2-file_id = wa_plot_item_tmp-file_id.
  wa_pl_jobs2-description = wa_plot_item_tmp-description.
  wa_pl_jobs2-originaltype = wa_plot_item_tmp-originaltype.

  wa_pl_jobs2-knz_use_checked_ = wa_plot_item_tmp-knz_use_checked_.
  wa_pl_jobs2-storagecategory = wa_plot_item_tmp-storagecategory.

  MODIFY /cideon/pl_jobs1 FROM wa_pl_jobs1.
  IF sy-subrc NE 0.
    ROLLBACK WORK.
  ELSE.
  ENDIF.

  MODIFY /cideon/pl_jobs2 FROM wa_pl_jobs2.
  IF sy-subrc NE 0.
    ROLLBACK WORK.
  ELSE.
  ENDIF.

  MODIFY /cideon/pl_jobs3 FROM wa_pl_jobs3.
  IF sy-subrc NE 0.
    ROLLBACK WORK.
  ELSE.
  ENDIF.

* Anzahl checken
  CLEAR anzahl_items.
  DESCRIBE TABLE itab_plot_item_tmp LINES anzahl_items.
  IF anzahl_items = '1'.
    EXIT.
  ELSE.
*   Tabellen aktualisieren
*   Einträge lesen und duplizieren
*   aktuell höchsten Eintrag lesen, um die Nummer der Duplikate
*   zu bestimmen
*   ersten Eintrag normal verarbeiten (siehe oben)
    DELETE itab_plot_item_tmp INDEX 1.
*   Stempeleinträge nachlesen
    CLEAR cont_i.
    cont_i = wa_plot_item-cont.
    SELECT * FROM /cideon/pl_jobss
      INTO TABLE itab_pl_jobss
      WHERE id_plotjob = wa_plot_item-id_plotjob
      AND zeile_plotjob = cont_i
       .
    IF sy-subrc NE 0.
      MESSAGE s003(/cideon/plot_admin) WITH
      '/cideon/pl_jobss' wa_plot_item-id_plotjob '' ''.
      ROLLBACK WORK.
    ELSE.
    ENDIF.

*   Anzahl abfragen
    CLEAR max_item.
    SELECT COUNT( * ) FROM /cideon/pl_jobs1
      INTO max_item
      WHERE id_plotjob = wa_plot_item-id_plotjob
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    CLEAR anzahl_stempel_werte.
    DESCRIBE TABLE itab_pl_jobss LINES anzahl_stempel_werte.

    LOOP AT itab_plot_item_tmp INTO wa_plot_item_tmp.
*     Counter updaten
*     Felder übergeben
*     Speichern
      max_item = max_item + 1.

      wa_pl_jobs1-cont = max_item.
      wa_pl_jobs2-cont = max_item.

      CLEAR cont_i.
      cont_i = max_item.
      LOOP AT itab_pl_jobss INTO wa_pl_jobss.
        wa_pl_jobss-zeile_plotjob = cont_i.
        MODIFY itab_pl_jobss FROM wa_pl_jobss.
      ENDLOOP.


      CLEAR wa_pl_jobs1-icon_fehlblatt.
      wa_pl_jobs1-checked = wa_plot_item_tmp-checked.
      wa_pl_jobs1-filep = wa_plot_item_tmp-filep.
      wa_pl_jobs1-filename = wa_plot_item_tmp-filename.
      wa_pl_jobs1-wsapplication = wa_plot_item_tmp-wsapplication.

      wa_pl_jobs2-knz_fehl_blatt = wa_plot_item_tmp-knz_fehl_blatt.
      wa_pl_jobs2-application_id = wa_plot_item_tmp-application_id.
      wa_pl_jobs2-file_id = wa_plot_item_tmp-file_id.
      wa_pl_jobs2-description = wa_plot_item_tmp-description.
      wa_pl_jobs2-originaltype = wa_plot_item_tmp-originaltype.

      LOOP AT itab_pl_jobss INTO wa_pl_jobss.
        index_pl_jobss = sy-tabix.
        wa_pl_jobss-pos = wa_pl_jobss-pos + anzahl_stempel_werte.
        MODIFY itab_pl_jobss FROM wa_pl_jobss
          INDEX index_pl_jobss.
      ENDLOOP.

      MODIFY /cideon/pl_jobs1 FROM wa_pl_jobs1.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
      ELSE.
      ENDIF.

      MODIFY /cideon/pl_jobs2 FROM wa_pl_jobs2.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
      ELSE.
      ENDIF.

      MODIFY /cideon/pl_jobs3 FROM wa_pl_jobs3.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
      ELSE.
      ENDIF.

      MODIFY /cideon/pl_jobss FROM TABLE itab_pl_jobss.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
      ELSE.
      ENDIF.

    ENDLOOP.
  ENDIF.


* Reload / Refresh




ENDFORM.                    " change_fehl_blatt
*&---------------------------------------------------------------------*
*&      Form  set_knz_auto_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0115   text
*----------------------------------------------------------------------*
FORM set_knz_auto_process USING    value(p).
* setzen des Kennzeichen KNZ_AUTO_PROCESS in Verwaltungsdaten

  SORT itab_plot_item BY id_plotjob.
  DELETE ADJACENT DUPLICATES FROM itab_plot_item
    COMPARING id_plotjob.

  IF itab_plot_item[] IS INITIAL.
    MESSAGE w008(/cideon/plot_admin) WITH '' '' '' ''.
    EXIT.
  ELSE.
  ENDIF.

  LOOP AT itab_plot_item INTO wa_plot_item.
    IF p = 'X'.
      UPDATE /cideon/pl_jobsc
        SET knz_auto_process = 'X'
        WHERE id_plotjob = wa_plot_item-id_plotjob
      .
      IF sy-subrc NE 0.
      ELSE.
        MESSAGE s016(/cideon/plot_admin) WITH '' '' '' ''.
      ENDIF.
    ELSE.
      UPDATE /cideon/pl_jobsc
        SET knz_auto_process = ' '
        WHERE id_plotjob = wa_plot_item-id_plotjob
      .
      IF sy-subrc NE 0.
      ELSE.
        MESSAGE s016(/cideon/plot_admin) WITH '' '' '' ''.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " set_knz_auto_process
