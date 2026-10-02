*----------------------------------------------------------------------*
***INCLUDE /CIDEON/PLOT_ADMIN_TOOL000_FR7 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_data_count
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_count.
* Anzahl der Treffer holen

  CLEAR count_lines.

  CLEAR itab_v_adm_01.

*  SELECT * FROM /cideon/v_adm_01
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


  DESCRIBE TABLE itab_v_adm_01 LINES count_lines.

ENDFORM.                    " get_data_count
*&---------------------------------------------------------------------*
*&      Form  download_to_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_to_local.
* Ablegen auf lokalen Verzeichnis
* es werden nur im Contentserver abgelegt Dateien benutzt
*ITAB
*WA
  DATA: return TYPE bapiret2.
  DATA: wa_documentfiles TYPE bapi_doc_files2.
*NORMAL
  DATA: checkout_path TYPE bapi_doc_aux-filename.
  DATA: ausgabe_progress TYPE char100.
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.

* neues Rollenkonzept eingeschaltet?
  IF user_data-knz_use_new_roles = 'X'.
*   Berechtigung testen
*   Ändern des Feldes
    AUTHORITY-CHECK OBJECT 'ZCL_PLOTDN'
             ID 'ZCL_TA' FIELD sy-tcode
             ID 'ACTVT' FIELD '02'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
    .
    IF sy-subrc NE 0.
*     keine Berechtigung
      MESSAGE i030(zcl_plint_message_01) WITH '' '' '' ''.
*     Sie haben keine Berechtigung für diese Funktion! & & & &
      EXIT.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


  DESCRIBE TABLE itab_plot_item LINES count_lines.
  IF count_lines < 1.
    MESSAGE e040(/cideon/plot_admin) WITH
      text-060 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.


  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
    EXPORTING
      window_title          = text-061
*      INITIAL_FOLDER        =
    IMPORTING
      selected_folder       = checkout_path
    EXCEPTIONS
      cntl_error            = 1
      OTHERS                = 2
            .
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  IF checkout_path IS INITIAL.
    EXIT.
  ELSE.
    CONCATENATE checkout_path '\' INTO checkout_path.
  ENDIF.

  MESSAGE s041(/cideon/plot_admin)
    WITH '' '' '' ''.


  LOOP AT itab_plot_item INTO wa_plot_item.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

*   Test auf Spezialdokumente
    IF wa_plot_item-knz_spez_dok = 'X'.
      CONTINUE.
    ELSE.
    ENDIF.

    IF wa_plot_item-knz_fehl_blatt = 'X'.
      CONTINUE.
    ELSE.
    ENDIF.


    CLEAR ausgabe_progress.
    CONCATENATE text-071 wa_plot_item-filep
      INTO ausgabe_progress.
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*      EXPORTING
**        PERCENTAGE       = 0
*        text             = ausgabe_progress
*              .
*

*   Ablegen
    CLEAR wa_documentfiles.

    wa_documentfiles-documenttype = wa_plot_item-dokar.
    wa_documentfiles-documentnumber = wa_plot_item-doknr.
    wa_documentfiles-documentversion = wa_plot_item-dokvr.
    wa_documentfiles-documentpart = wa_plot_item-doktl.

    wa_documentfiles-wsapplication = wa_plot_item-wsapplication.
    wa_documentfiles-docfile = wa_plot_item-filep.

    CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
      EXPORTING
        documenttype              = wa_plot_item-dokar
        documentnumber            = wa_plot_item-doknr
        documentpart              = wa_plot_item-doktl
        documentversion           = wa_plot_item-dokvr
        documentfile              = wa_documentfiles
        getstructure              = '1'
        getcomponents             = 'X'
        originalpath              = checkout_path
*     HOSTNAME                  = ' '
        getheader                 = 'X'
*     DOCBOMCHANGENUMBER        =
*     DOCBOMVALIDFROM           =
*     DOCBOMREVISIONLEVEL       =
      IMPORTING
        return                    = return
*   TABLES
*     DOCUMENTSTRUCTURE         =
*     DOCUMENTFILES             =
*     COMPONENTS                =
              .

    IF return IS INITIAL.
    ELSE.
    ENDIF.

    IF akt_dec <> last_dec.
      prozent = akt_dec * 100.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = prozent
                text       = ausgabe_progress.
    ELSE.
    ENDIF.
    last = akt.
    last_dec = akt_dec.

  ENDLOOP.



ENDFORM.                    " download_to_local
*&---------------------------------------------------------------------*
*&      Form  start_converting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_converting.
* Anstarten des Konvertierungsvorganges für einen DIS
*ITAB
*WA
*NORMAL
  DATA: ausgabe_progress TYPE char100.
  DATA: akt_index TYPE i.
  DATA: last TYPE f.
  DATA: akt TYPE f.
  DATA: akt_dec TYPE p DECIMALS 1.
  DATA: last_dec TYPE p DECIMALS 1.
  DATA: prozent TYPE i.


  DESCRIBE TABLE itab_plot_item LINES count_lines.
  IF count_lines < 1.
    MESSAGE e040(/cideon/plot_admin) WITH
      text-060 count_lines '' ''.
    EXIT.
  ELSE.
  ENDIF.


  LOOP AT itab_plot_item INTO wa_plot_item.

    akt_index = sy-tabix.
    akt = akt_index / count_lines.
    akt_dec = akt.

    SUBMIT conv_convert_document
      WITH dokar EQ wa_plot_item-dokar
      WITH doknr EQ wa_plot_item-doknr
      WITH doktl EQ wa_plot_item-doktl
      WITH dokvr EQ wa_plot_item-dokvr
      WITH dokst EQ wa_plot_item-dokst
      AND RETURN.

    IF akt_dec <> last_dec.
      prozent = akt_dec * 100.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = prozent
                text       = ausgabe_progress.
    ELSE.
    ENDIF.
    last = akt.
    last_dec = akt_dec.

  ENDLOOP.


ENDFORM.                    " start_converting
