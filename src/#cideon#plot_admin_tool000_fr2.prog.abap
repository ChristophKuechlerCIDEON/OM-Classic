*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_ADMIN_TOOL000_FR2 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  create_dis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_dis.
* neuen DIS erstellen
  data: anzahl_items type i.
  data: wa_plot_item_tmp like wa_plot_item.

  clear anzahl_items.
  describe table itab_plot_item lines anzahl_items.
  if anzahl_items = 1.
  else.
    message w005(/cideon/plot_admin) with '' '' '' ''.
    exit.
  endif.

  read table itab_plot_item into wa_plot_item index 1.

  if wa_plot_item-knz_spez_dok = 'X'
    and wa_v_adm_01-object_type ne 'SPOOL'.
  else.
    message w009(/cideon/plot_admin) with '' '' '' ''.
    exit.
  endif.

  if user_data-trans_cv01n is initial.
    user_data-trans_cv01n = 'CV01n'.
  else.
  endif.

  set parameter id 'CV1' field wa_plot_item-doknr.
  set parameter id 'CV2' field wa_plot_item-dokar.
  set parameter id 'CV3' field wa_plot_item-dokvr.
  set parameter id 'CV4' field wa_plot_item-doktl.

  if user_data-trans_cv01n_skip_first_screen = 'X'.
    call transaction user_data-trans_cv01n and skip first screen.
  else.
    call transaction user_data-trans_cv01n.
  endif.


endform.                    " create_dis
*&---------------------------------------------------------------------*
*&      Form  relate_dis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form relate_dis.
* DIS einem Item zuordnen
  data: anzahl_items type i.
  data: wa_draw_check type draw.

  clear anzahl_items.
  describe table itab_plot_item lines anzahl_items.
  if anzahl_items = 1.
  else.
    message w005(/cideon/plot_admin) with '' '' '' ''.
    exit.
  endif.

  read table itab_plot_item into wa_plot_item index 1.

  if wa_plot_item-knz_spez_dok = 'X'
    and wa_v_adm_01-object_type ne 'SPOOL'.
  else.
    message w009(/cideon/plot_admin) with '' '' '' ''.
    exit.
  endif.

* DIS abfragen
  data: document type csap_dbom-doknr.
  data: doc_type type csap_dbom-dokar.
  data: doc_vers type csap_dbom-dokvr.
  data: doc_part type csap_dbom-doktl.

  clear document.
  clear doc_type.
  clear doc_vers.
  clear doc_part.

  doc_type = wa_plot_item-dokar.
  document = wa_plot_item-doknr.
  doc_part = wa_plot_item-doktl.
  doc_vers = wa_plot_item-dokvr.

  set parameter id 'CV1' field wa_plot_item-doknr.
  set parameter id 'CV2' field wa_plot_item-dokar.
  set parameter id 'CV3' field wa_plot_item-dokvr.
  set parameter id 'CV4' field wa_plot_item-doktl.

  call function 'Z_CL_PLINT_ASK_DOCUMENT_NR'
       importing
            o_doknr = document
            o_dokar = doc_type
            o_dokvr = doc_vers
            o_doktl = doc_part
       exceptions
            error   = 1
            others  = 2.
  if sy-subrc <> 0.
    exit.
  endif.

* Testen, ob DIS vorhanden...
  clear wa_draw_check.
  select single * from draw into wa_draw_check
    where dokar = doc_type
    and doknr = document
    and doktl = doc_part
    and dokvr = doc_vers
    .
  if sy-subrc ne 0.
    message w010(/cideon/plot_admin)
      with doc_type document doc_part doc_vers.
    exit.
  else.
  endif.

* DIS zuordnen in den Tabellen updaten
* /CIDEON/PL_jobs1, /CIDEON/PL_jobs2, /CIDEON/PL_jobss, /CIDEON/PL_jobsc
* /CIDEON/PL_jobs3
  update /cideon/pl_jobs1
    set:  dokar = doc_type
          doknr = document
          doktl = doc_part
          dokvr = doc_vers
    where id_plotjob = wa_plot_item-id_plotjob
    and cont = wa_plot_item-cont
    .
  if sy-subrc ne 0.
    rollback work.
    message w011(/cideon/plot_admin)
      with '/CIDEON/PL_JOBS1' doc_type document doc_part .
    exit.
  else.
  endif.

* Stempeltabelle löschen
  delete  from /cideon/pl_jobss
    where id_plotjob = wa_plot_item-id_plotjob
    and zeile_plotjob = wa_plot_item-cont
    .
  if sy-subrc ne 0.
*    ROLLBACK WORK.
*    MESSAGE w012(/cideon/plot_admin)
*      WITH '/CIDEON/PL_JOBSS' wa_plot_item-id_plotjob wa_plot_item-cont
    .
*    EXIT.
  else.
  endif.

* Tabellen füllen und mappen
  refresh itab_tmp_plotjobs_2.
  clear wa_tmp_plotjobs.
  move-corresponding wa_plot_item to wa_tmp_plotjobs.
  append wa_tmp_plotjobs to itab_tmp_plotjobs_2.

  perform get_stamp_values.

  perform get_class_data.

  perform get_result_stamp_values.

*  Stempeldaten schreiben
  loop at itab_stempel_wert into wa_stempel_wert.
    clear wa_pl_jobss.
    move-corresponding wa_stempel_wert to wa_pl_jobss.
    wa_pl_jobss-id_plotjob = wa_plot_item-id_plotjob.
    wa_pl_jobss-pos = sy-tabix.

    wa_pl_jobss-zclinsname = sy-uname.
    wa_pl_jobss-zclinsdate = sy-datum.
    wa_pl_jobss-zclinstime = sy-uzeit.
    wa_pl_jobss-zclinsprog = 'ZCL_PLINT_DESIGN_007F03'.
    wa_pl_jobss-zclupdname = sy-uname.
    wa_pl_jobss-zclupddate = sy-datum.
    wa_pl_jobss-zclupdtime = sy-uzeit.
    wa_pl_jobss-zclupdprog = 'ZCL_PLINT_DESIGN_007F03'.

    modify /cideon/pl_jobss from wa_pl_jobss.
    if sy-subrc ne 0.
      message e001(/cideon/plot_admin)
        with '/CIDEON/PL_JOBSS' '' '' ''.
      rollback work.
      exit.
    else.
    endif.
  endloop.

  message s013(/cideon/plot_admin)
    with '' '' '' ''.


endform.                    " relate_dis
*&---------------------------------------------------------------------*
*&      Form  relate_original_pl_ohne_dis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form relate_original_pl_ohne_dis.
* Ordnet einem Item ein Original des DIS zu ...
* Item war vorher eine Plotanforderung ohne DIS
  data: anzahl_items type i.
  data: wa_plot_item_tmp like wa_plot_item.
  data: itab_plot_item_tmp type table of /cideon/_s_adm_01.
  data: pos type /cideon/pl_jobss-zeile_plotjob.
  data: cont_i type i.
  data: max_item type i.
  data: anzahl_stempel_werte type i.
  data: index_pl_jobss type i.

  clear anzahl_items.
  describe table itab_plot_item lines anzahl_items.
  if anzahl_items = 1.
  else.
    message w005(/cideon/plot_admin) with '' '' '' ''.
    exit.
  endif.

  read table itab_plot_item into wa_plot_item index 1.

  if wa_plot_item-knz_spez_dok = 'X'
    and wa_v_adm_01-object_type ne 'SPOOL'.
  else.
    message w009(/cideon/plot_admin) with '' '' '' ''.
    exit.
  endif.

* neues Original auswählen lassen
  clear wa_plot_item_tmp.
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
*        EXIT.
*      WHEN '2'.
*        EXIT.
*      WHEN '3'.
*        EXIT.
*      WHEN OTHERS.
*        EXIT.
*    ENDCASE.
*  ELSE.
*  ENDIF.
*
** Tabellen aktualisieren
*  CLEAR wa_pl_jobs1.
*  SELECT SINGLE * FROM /cideon/pl_jobs1 INTO wa_pl_jobs1
*    WHERE id_plotjob = wa_plot_item-id_plotjob
*    AND cont = wa_plot_item-cont
*    .
*  IF sy-subrc NE 0.
*    EXIT.
*  ELSE.
*  ENDIF.
*
*  CLEAR wa_pl_jobs2.
*  SELECT SINGLE * FROM /cideon/pl_jobs2 INTO wa_pl_jobs2
*    WHERE id_plotjob = wa_plot_item-id_plotjob
*    AND cont = wa_plot_item-cont
*    .
*  IF sy-subrc NE 0.
*    EXIT.
*  ELSE.
*  ENDIF.
*
*  CLEAR wa_pl_jobs1-icon_fehlblatt.
*  wa_pl_jobs1-checked = wa_plot_item_tmp-checked.
*  wa_pl_jobs1-filep = wa_plot_item_tmp-filep.
*  wa_pl_jobs1-filename = wa_plot_item_tmp-filename.
*  wa_pl_jobs1-wsapplication = wa_plot_item_tmp-wsapplication.
*
*  wa_pl_jobs2-application_id = wa_plot_item_tmp-application_id.
*  wa_pl_jobs2-file_id = wa_plot_item_tmp-file_id.
*  wa_pl_jobs2-description = wa_plot_item_tmp-description.
*  CLEAR wa_pl_jobs2-knz_spez_dok.
*  CLEAR wa_pl_jobs2-icon_spez_dok.
*
*
*  MODIFY /cideon/pl_jobs1 FROM wa_pl_jobs1.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.
*    EXIT.
*  ELSE.
*  ENDIF.
*
*  MODIFY /cideon/pl_jobs2 FROM wa_pl_jobs2.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.
*    EXIT.
*  ELSE.
*  ENDIF.
*
*  MESSAGE s014(/cideon/plot_admin)
*    WITH '' '' '' ''.

  call function '/CIDEON/MAKE_SEL_FOR_ORIGINAL2'
       exporting
            i_wa_plot_item   = wa_plot_item
       importing
            o_wa_plot_item   = wa_plot_item_tmp
       tables
            o_itab_plot_item = itab_plot_item_tmp
       exceptions
            error            = 1
            no_selection     = 2
            others           = 3.

  if sy-subrc <> 0.
    case sy-subrc.
      when '1'.
        message w007(/cideon/plot_admin) with '' '' '' ''.
      when '2'.
        exit.
      when '3'.
        exit.
      when others.
        exit.
    endcase.
  endif.


  read table itab_plot_item_tmp into wa_plot_item_tmp index 1.
*   Tabellen aktualisieren
  clear wa_pl_jobs1.
  select single * from /cideon/pl_jobs1 into wa_pl_jobs1
    where id_plotjob = wa_plot_item-id_plotjob
    and cont = wa_plot_item-cont
    .
  if sy-subrc ne 0.
    exit.
  else.
  endif.

  clear wa_pl_jobs2.
  select single * from /cideon/pl_jobs2 into wa_pl_jobs2
    where id_plotjob = wa_plot_item-id_plotjob
    and cont = wa_plot_item-cont
    .
  if sy-subrc ne 0.
    exit.
  else.
  endif.

  clear wa_pl_jobs1-icon_fehlblatt.
  wa_pl_jobs1-checked = wa_plot_item_tmp-checked.
  wa_pl_jobs1-filep = wa_plot_item_tmp-filep.
  wa_pl_jobs1-filename = wa_plot_item_tmp-filename.
  wa_pl_jobs1-wsapplication = wa_plot_item_tmp-wsapplication.

*  wa_pl_jobs2-knz_fehl_blatt = wa_plot_item_tmp-knz_fehl_blatt.
  wa_pl_jobs2-application_id = wa_plot_item_tmp-application_id.
  wa_pl_jobs2-file_id = wa_plot_item_tmp-file_id.
  wa_pl_jobs2-description = wa_plot_item_tmp-description.
  wa_pl_jobs2-originaltype = wa_plot_item_tmp-originaltype.
  clear wa_pl_jobs2-knz_spez_dok.
  clear wa_pl_jobs2-icon_spez_dok.

  modify /cideon/pl_jobs1 from wa_pl_jobs1.
  if sy-subrc ne 0.
    rollback work.
  else.
  endif.

  modify /cideon/pl_jobs2 from wa_pl_jobs2.
  if sy-subrc ne 0.
    rollback work.
  else.
  endif.


* Anzahl checken
  clear anzahl_items.
  describe table itab_plot_item_tmp lines anzahl_items.
  if anzahl_items = '1'.
    exit.
  else.
*   Tabellen aktualisieren
*   Einträge lesen und duplizieren
*   aktuell höchsten Eintrag lesen, um die Nummer der Duplikate
*   zu bestimmen
*   ersten Eintrag normal verarbeiten (siehe oben)
    delete itab_plot_item_tmp index 1.
*   Stempeleinträge nachlesen
    clear cont_i.
    cont_i = wa_plot_item-cont.
    select * from /cideon/pl_jobss
      into table itab_pl_jobss
      where id_plotjob = wa_plot_item-id_plotjob
      and zeile_plotjob = cont_i
       .
    if sy-subrc ne 0.
      message s003(/cideon/plot_admin) with
      '/cideon/pl_jobss' wa_plot_item-id_plotjob '' ''.
      rollback work.
    else.
    endif.

*   Anzahl abfragen
    clear max_item.
    select count( * ) from /cideon/pl_jobs1
      into max_item
      where id_plotjob = wa_plot_item-id_plotjob
      .
    if sy-subrc ne 0.
    else.
    endif.

    clear anzahl_stempel_werte.
    describe table itab_pl_jobss lines anzahl_stempel_werte.

    loop at itab_plot_item_tmp into wa_plot_item_tmp.
*     Counter updaten
*     Felder übergeben
*     Speichern
      max_item = max_item + 1.

      wa_pl_jobs1-cont = max_item.
      wa_pl_jobs2-cont = max_item.

      clear cont_i.
      cont_i = max_item.
      loop at itab_pl_jobss into wa_pl_jobss.
        wa_pl_jobss-zeile_plotjob = cont_i.
        modify itab_pl_jobss from wa_pl_jobss.
      endloop.


      clear wa_pl_jobs1-icon_fehlblatt.
      wa_pl_jobs1-checked = wa_plot_item_tmp-checked.
      wa_pl_jobs1-filep = wa_plot_item_tmp-filep.
      wa_pl_jobs1-filename = wa_plot_item_tmp-filename.
      wa_pl_jobs1-wsapplication = wa_plot_item_tmp-wsapplication.

      wa_pl_jobs2-knz_fehl_blatt = wa_plot_item_tmp-knz_fehl_blatt.
      wa_pl_jobs2-application_id = wa_plot_item_tmp-application_id.
      wa_pl_jobs2-file_id = wa_plot_item_tmp-file_id.
      wa_pl_jobs2-description = wa_plot_item_tmp-description.
      wa_pl_jobs2-originaltype = wa_plot_item_tmp-originaltype.

      loop at itab_pl_jobss into wa_pl_jobss.
        index_pl_jobss = sy-tabix.
        wa_pl_jobss-pos = wa_pl_jobss-pos + anzahl_stempel_werte.
        modify itab_pl_jobss from wa_pl_jobss
          index index_pl_jobss.
      endloop.

      modify /cideon/pl_jobs1 from wa_pl_jobs1.
      if sy-subrc ne 0.
        rollback work.
      else.
      endif.

      modify /cideon/pl_jobs2 from wa_pl_jobs2.
      if sy-subrc ne 0.
        rollback work.
      else.
      endif.

      modify /cideon/pl_jobss from table itab_pl_jobss.
      if sy-subrc ne 0.
        rollback work.
      else.
      endif.

    endloop.
  endif.

  message s014(/cideon/plot_admin)
    with '' '' '' ''.

endform.                    " relate_original_pl_ohne_dis
