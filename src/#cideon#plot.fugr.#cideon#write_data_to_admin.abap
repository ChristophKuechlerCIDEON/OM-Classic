FUNCTION /cideon/write_data_to_admin.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_USER_DATA) LIKE  /CIDEON/PLOT_USERDATA STRUCTURE
*"        /CIDEON/PLOT_USERDATA
*"     VALUE(I_WA_DEFAULT_DATA) LIKE  /CIDEON/PLOT_DEFAULTDATA
*"       STRUCTURE  /CIDEON/PLOT_DEFAULTDATA
*"     VALUE(I_PROGRAMM) TYPE  PROGRAMM
*"     VALUE(I_ID_PLOTJOB) TYPE  ZCL_S_PLOTLIST-ID_PLOTJOB
*"     VALUE(I_STR_DOWN_PATH) TYPE  STRING
*"     VALUE(I_STR_PPL_DOWN_PATH) TYPE  STRING
*"  TABLES
*"      ITAB_PLOTJOBS STRUCTURE  ZCL_S_PLOTLIST
*"      ITAB_STEMPEL_WERT STRUCTURE  ZCL_S_STEMPEL_VALUE
*"      IT_NOTIZ TYPE  /CIDEON/TTYPE_S_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 19.07.2004 - Erstellung
* 10.01.2006 - LOG ID / GUID
* 29.11.2006 - Übergabe der Notiztabelle
* 04.10.2010 - CKR
*            - /CIDEON/PL_JOBS4 eingeführt
*-----------------------------------------------------------------------
*WA
  DATA: wa_plotjobs LIKE zcl_s_plotlist.
  DATA: wa_pl_jobs1 TYPE /cideon/pl_jobs1.
  DATA: wa_pl_jobs2 TYPE /cideon/pl_jobs2.
  DATA: wa_pl_jobs3 TYPE /cideon/pl_jobs3.
  DATA: wa_pl_jobs4 TYPE /cideon/pl_jobs4.
  DATA: wa_pl_jobsc TYPE /cideon/pl_jobsc.
  DATA: wa_pl_jobss TYPE /cideon/pl_jobss.
  DATA: wa_stempel_wert TYPE zcl_s_stempel_value.

* Daten in Übergabetabelle schreiben
  CLEAR wa_pl_jobs1.
  CLEAR wa_pl_jobs2.
  CLEAR wa_pl_jobs3.
  CLEAR wa_pl_jobss.
  CLEAR wa_pl_jobsc.

* Verwaltungsdaten schreiben
  wa_pl_jobsc-id_plotjob = i_id_plotjob.
  wa_pl_jobsc-default_user = i_wa_default_data-default_nutzer.
  wa_pl_jobsc-down_path = i_str_down_path.
  wa_pl_jobsc-clf_down_path = i_str_ppl_down_path.
  wa_pl_jobsc-out_proc = i_wa_user_data-knz_auto_process.
  wa_pl_jobsc-delete_item = i_wa_user_data-delete_item.
  wa_pl_jobsc-delete_status = i_wa_user_data-delete_status.
  wa_pl_jobsc-format_checking = i_wa_user_data-knz_format_checking.
  wa_pl_jobsc-knz_use_converte = i_wa_user_data-knz_use_converte.
  wa_pl_jobsc-converter_name = i_wa_user_data-converter_name.
  wa_pl_jobsc-converter_number = i_wa_user_data-converter_number.
  wa_pl_jobsc-ftp_destination = i_wa_user_data-ftp_destination.
  wa_pl_jobsc-ftp_user = i_wa_user_data-ftp_user.
  wa_pl_jobsc-ftp_passwd  = i_wa_user_data-ftp_passwd.
  wa_pl_jobsc-ftp_down = i_wa_user_data-ftp_down.
  wa_pl_jobsc-knz_use_new_clf
    = i_wa_user_data-knz_use_new_clf_type.
  wa_pl_jobsc-knz_auto_process
    = i_wa_user_data-knz_auto_process.

  wa_pl_jobsc-zclinsname = sy-uname.
  wa_pl_jobsc-zclinsdate = sy-datum.
  wa_pl_jobsc-zclinstime = sy-uzeit.
  wa_pl_jobsc-zclinsprog = i_programm.
  wa_pl_jobsc-zclupdname = sy-uname.
  wa_pl_jobsc-zclupddate = sy-datum.
  wa_pl_jobsc-zclupdtime = sy-uzeit.
  wa_pl_jobsc-zclupdprog = i_programm.

  MODIFY /cideon/pl_jobsc FROM wa_pl_jobsc.
  IF sy-subrc NE 0.
    MESSAGE e001(/cideon/plot_admin)
      WITH '/CIDEON/PL_JOBSC' '' '' ''.
    ROLLBACK WORK.
    EXIT.
  ELSE.
  ENDIF.

* Plotjobsdaten schreiben
  LOOP AT itab_plotjobs INTO wa_plotjobs.
    CLEAR wa_pl_jobs1.
    MOVE-CORRESPONDING wa_plotjobs TO wa_pl_jobs1.
    wa_pl_jobs1-id_plotjob = i_id_plotjob.

    wa_pl_jobs1-zclinsname = sy-uname.
    wa_pl_jobs1-zclinsdate = sy-datum.
    wa_pl_jobs1-zclinstime = sy-uzeit.
    wa_pl_jobs1-zclinsprog = i_programm.
    wa_pl_jobs1-zclupdname = sy-uname.
    wa_pl_jobs1-zclupddate = sy-datum.
    wa_pl_jobs1-zclupdtime = sy-uzeit.
    wa_pl_jobs1-zclupdprog = i_programm.

    CLEAR wa_pl_jobs2.
    MOVE-CORRESPONDING wa_plotjobs TO wa_pl_jobs2.
    wa_pl_jobs2-knz_use_checked_ =
      wa_plotjobs-knz_use_checked_in.
    wa_pl_jobs2-id_plotjob = i_id_plotjob.

    wa_pl_jobs2-zclinsname = sy-uname.
    wa_pl_jobs2-zclinsdate = sy-datum.
    wa_pl_jobs2-zclinstime = sy-uzeit.
    wa_pl_jobs2-zclinsprog = i_programm.
    wa_pl_jobs2-zclupdname = sy-uname.
    wa_pl_jobs2-zclupddate = sy-datum.
    wa_pl_jobs2-zclupdtime = sy-uzeit.
    wa_pl_jobs2-zclupdprog = i_programm.

    CLEAR wa_pl_jobs3.
    MOVE-CORRESPONDING wa_plotjobs TO wa_pl_jobs3.

    wa_pl_jobs3-zclinsname = sy-uname.
    wa_pl_jobs3-zclinsdate = sy-datum.
    wa_pl_jobs3-zclinstime = sy-uzeit.
    wa_pl_jobs3-zclinsprog = i_programm.
    wa_pl_jobs3-zclupdname = sy-uname.
    wa_pl_jobs3-zclupddate = sy-datum.
    wa_pl_jobs3-zclupdtime = sy-uzeit.
    wa_pl_jobs3-zclupdprog = i_programm.


    CLEAR wa_pl_jobs4.
    MOVE-CORRESPONDING wa_plotjobs TO wa_pl_jobs4.

    wa_pl_jobs4-zclinsname = sy-uname.
    wa_pl_jobs4-zclinsdate = sy-datum.
    wa_pl_jobs4-zclinstime = sy-uzeit.
    wa_pl_jobs4-zclinsprog = i_programm.
    wa_pl_jobs4-zclupdname = sy-uname.
    wa_pl_jobs4-zclupddate = sy-datum.
    wa_pl_jobs4-zclupdtime = sy-uzeit.
    wa_pl_jobs4-zclupdprog = i_programm.


    MODIFY /cideon/pl_jobs1 FROM wa_pl_jobs1.
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBS1' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.

    MODIFY /cideon/pl_jobs2 FROM wa_pl_jobs2.
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBS2' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.

    MODIFY /cideon/pl_jobs3 FROM wa_pl_jobs3.
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBS3' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.

    MODIFY /cideon/pl_jobs4 FROM wa_pl_jobs4.
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBS4' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.

* Stempeldaten schreiben
  LOOP AT itab_stempel_wert INTO wa_stempel_wert.
    CLEAR wa_pl_jobss.
    MOVE-CORRESPONDING wa_stempel_wert TO wa_pl_jobss.
    wa_pl_jobss-id_plotjob = i_id_plotjob.
    wa_pl_jobss-pos = sy-tabix.

    wa_pl_jobss-zclinsname = sy-uname.
    wa_pl_jobss-zclinsdate = sy-datum.
    wa_pl_jobss-zclinstime = sy-uzeit.
    wa_pl_jobss-zclinsprog = i_programm.
    wa_pl_jobss-zclupdname = sy-uname.
    wa_pl_jobss-zclupddate = sy-datum.
    wa_pl_jobss-zclupdtime = sy-uzeit.
    wa_pl_jobss-zclupdprog = i_programm.

    MODIFY /cideon/pl_jobss FROM wa_pl_jobss.
    IF sy-subrc NE 0.
      MESSAGE e001(/cideon/plot_admin)
        WITH '/CIDEON/PL_JOBSS' '' '' ''.
      ROLLBACK WORK.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
