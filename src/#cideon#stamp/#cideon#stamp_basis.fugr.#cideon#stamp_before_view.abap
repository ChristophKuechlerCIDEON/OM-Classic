FUNCTION /cideon/stamp_before_view.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_APPL_TYPE) TYPE  TDWX-APPTP OPTIONAL
*"     VALUE(I_DRAW) TYPE  DRAW OPTIONAL
*"     VALUE(I_TARGET_FILE) TYPE  DMS_DOC_FILE OPTIONAL
*"     VALUE(I_DOCFILE) TYPE  DMS_REC_FILE OPTIONAL
*"     VALUE(I_DRAZ) TYPE  DMS_TBL_DRAZ OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      DO_NOT_STAMP
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 15.07.2002 creation
* 30.10.2003 Erweiterung: DIS mit bestimmten Merkmalen werden
*            nicht mehr gestempelt
* 13.11.2003 Erweiterung RFC / FTP
*
* 7.0.169.1  CKR
* 2014/08/04 Sulzer
  " EHP 7 - Ausbau FB DSVAS_DOC_WS_DOWNLOAD_50
  " FB /CIDEON/ANMELDUNG_AN_SERVER
  "
*-----------------------------------------------------------------------
* to do:    - Umstellung auf allgemeines Lesen der Einstellungen
*             Benutzung der Struktur für Einstellungen
*-----------------------------------------------------------------------
* TYPES
  TYPES: BEGIN OF t_stempel_wert,
      line TYPE char255,
    END OF t_stempel_wert.
* ITAB
  DATA: itab_stempel TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_class_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_stamp_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_plotjobs TYPE TABLE OF zcl_s_plotlist.
  DATA: itab_stempel_werte TYPE TABLE OF t_stempel_wert.
  DATA: itab_res_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: itab_class_data_no_use TYPE TABLE OF zcl_v_ug_cl_n_u.

* WA
  DATA: wa_plint_cfg_00 TYPE zcl_plint_cfg_00.
  DATA: wa_plint_config TYPE zcl_plint_config.
  DATA: wa_stempel TYPE zcl_s_stempel_value.
  DATA: wa_class_data TYPE zcl_s_stempel_value.
  DATA: wa_stamp_data TYPE zcl_s_stempel_value.
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: wa_stempel_werte TYPE t_stempel_wert.
  DATA: wa_res_data TYPE zcl_s_stempel_value.
  DATA: wa_draw_check TYPE draw.

  DATA: user_data TYPE /cideon/plot_userdata.
  DATA: default_data TYPE /cideon/plot_defaultdata.

* NORMAL
  DATA: pwert TYPE pwert.
  DATA: pname TYPE pname.
  DATA: tmp_str(255).
  DATA: frontend TYPE REF TO cl_gui_frontend_services.

  DATA: upload_path TYPE rlgrap-filename.
  DATA: download_path TYPE rlgrap-filename.

  DATA: docid TYPE dsvasdocid.
  DATA: verzeichnis TYPE dsvasdocid.
  DATA: dateiname TYPE dsvasdocid.
  DATA: extension TYPE dsvasdocid.
  DATA: arbeits_verzeichnis TYPE dsvasdocid.
  DATA: start_verzeichnis TYPE dsvasdocid.

  DATA: dateiname_stempel TYPE filep.
*  DATA: stamp_program TYPE filep.

*  DATA: default_nutzer TYPE xubname.
*  DATA: knz_use_stamp_before_view(1).
*  DATA: knz_anmeldung_am_server(1).
*  DATA: anmeldestring_server TYPE zcl_pwert.
*  DATA: stamp_parameter TYPE zcl_pwert.

*  DATA: anmeldestring_server_vorher TYPE zcl_pwert.
*  DATA: anmeldestring_server_nachher TYPE zcl_pwert.

  DATA: dappl TYPE dms_doc_file-dappl.

*  DATA: knz_check_dis(1).
*  DATA: knz_check_dis_class(1).

*  DATA: knz_use_stamp_call_rfc(1).
*  DATA: stamp_rfc_destination TYPE rfcdes-rfcdest.
*  DATA: stamp_ftp_destination TYPE rfcdes-rfcdest.
*  DATA: stamp_ftp_user TYPE /cideon/ftp_user.
*  DATA: stamp_ftp_passwd TYPE /cideon/ftp_passwd.
*  DATA: stamp_ftp_verzeichnis TYPE filep.
*  DATA: stamp_delay TYPE i.
  DATA: stamp_delay_numc(2) TYPE n.

* Einbau der Defaultbausteine für das Lesen der Einstellungen
* mglw. zuerst noch die Abfrage, ob überhaupt gestempelt werden
* soll, bevor die gesamte Einstellung gelesen wird
  DATA: itab_roles TYPE TABLE OF bapiagr.
  DATA: wa_roles TYPE bapiagr.

  DATA: wa TYPE zcl_plint_cfg_00.
  DATA: f_role_used VALUE 'X'.


  CLEAR default_data.
  CLEAR user_data.


* KNZ_USE_STAMP_BEFORE_VIEW
  CLEAR tmp_str.
  pname = 'KNZ_USE_STAMP_BEFORE_VIEW'.
  SELECT SINGLE pwert FROM zcl_plint_cfg_00
    INTO tmp_str
    WHERE pname = pname
    .
  IF sy-subrc NE 0.
    default_data-knz_use_stamp_before_view = ''.
    wa-pwert = ''.
    wa-pname = pname.
    MODIFY zcl_plint_cfg_00 FROM wa.
  ELSE.
    default_data-knz_use_stamp_before_view = tmp_str.
  ENDIF.

* KNZ_USE_STAMP_BEFORE_VIEW
  CLEAR tmp_str.
  pname = 'KNZ_USE_STAMP_BEFORE_VIEW'.
  SELECT SINGLE pwert FROM zcl_plint_config
    INTO tmp_str
    WHERE uname = sy-uname
    AND pname = pname
    .
  IF sy-subrc NE 0.
    user_data-knz_use_stamp_before_view =
      default_data-knz_use_stamp_before_view.
    IF f_role_used = 'X'.
      LOOP AT itab_roles INTO wa_roles.
        SELECT SINGLE pwert FROM zcl_plint_config
          INTO tmp_str
          WHERE rolle = wa_roles-agr_name
          AND pname = pname
          .
        IF sy-subrc NE 0.
        ELSE.
*         gefunden
          user_data-knz_use_stamp_before_view = tmp_str.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
    ENDIF.
  ELSE.
    user_data-knz_use_stamp_before_view = tmp_str.
  ENDIF.

  IF user_data-knz_use_stamp_before_view = 'X'.
  ELSE.
*   kein Stempeln
    RAISE do_not_stamp.
    EXIT.
  ENDIF.

* Einstellungen lesen
  CALL FUNCTION '/CIDEON/READ_DEFAULTDATA'
    EXPORTING
      i_batch        = ''
    IMPORTING
      o_default_data = default_data.


  CALL FUNCTION '/CIDEON/READ_USERDATA'
    EXPORTING
      i_default_data = default_data
    IMPORTING
      o_user_data    = user_data.


***********************************************************************

  stamp_delay_numc = user_data-stamp_delay.
  user_data-stamp_delay = stamp_delay_numc.

  IF stamp_delay_numc CO ' 0123456789'.
  ELSE.
    user_data-stamp_delay = 1.
  ENDIF.

* allgemeine Checks
* Nachsehen, ob für die Dokumentenart gestempelt werden soll
  CALL FUNCTION '/CIDEON/CHECK_STAMP_DOKAR'
    EXPORTING
      i_nutzer         = sy-uname
      i_default_nutzer = default_data-default_nutzer
      i_dokar          = i_draw-dokar
    EXCEPTIONS
      error            = 1
      do_not_stamp     = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    IF sy-subrc = 2.
      RAISE do_not_stamp.
    ELSE.
    ENDIF.
  ENDIF.

* Nachsehen, ob für die WSAPPLICATION gestempelt werden soll
  IF i_docfile-dappl IS INITIAL.
    dappl = i_target_file-dappl.
  ELSE.
    dappl = i_docfile-dappl.
  ENDIF.
  CALL FUNCTION '/CIDEON/CHECK_STAMP_WSAPP'
    EXPORTING
      i_nutzer         = sy-uname
      i_default_nutzer = default_data-default_nutzer
      i_wsapp          = dappl  "i_docfile-dappl
    EXCEPTIONS
      error            = 1
      do_not_stamp     = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    IF sy-subrc = 2.
      RAISE do_not_stamp.
    ELSE.
    ENDIF.
  ENDIF.

* Nachsehen, ob für den DIS ein Merkmal vohanden ist
* für welches gilt, daß nicht gestempelt werden soll
  IF user_data-knz_check_dis = 'X'.
    IF user_data-knz_check_dis_class = 'X'.
*     kein Stempeln
      CLEAR itab_class_data_no_use.
      CALL FUNCTION '/CIDEON/GET_CLASS_NO_USE_STAMP'
        EXPORTING
          i_nutzer                 = sy-uname
          i_default_nutzer         = default_data-default_nutzer
        TABLES
          o_itab_class_data_no_use = itab_class_data_no_use
        EXCEPTIONS
          error                    = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CLEAR wa_draw_check.
      wa_draw_check = i_draw.

      CALL FUNCTION '/CIDEON/CHECK_DIS_FOR_CLASS'
        EXPORTING
          i_wa_draw                = wa_draw_check
        TABLES
          i_itab_class_data_no_use = itab_class_data_no_use
        EXCEPTIONS
          error                    = 1
          do_not_use_dis           = 2
          OTHERS                   = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        IF sy-subrc = 2.
          RAISE do_not_stamp.
        ELSE.
        ENDIF.
      ENDIF.
    ELSE.
    ENDIF.
  ELSE.
  ENDIF.


  IF user_data-knz_check_dis = 'X'.
    IF user_data-knz_check_dis_class = 'X'.
*     kein Plotten und auch kein Stempeln
      CLEAR itab_class_data_no_use.
      CALL FUNCTION '/CIDEON/GET_CLASS_NO_USE'
        EXPORTING
          i_nutzer                 = sy-uname
          i_default_nutzer         = default_data-default_nutzer
        TABLES
          o_itab_class_data_no_use = itab_class_data_no_use
        EXCEPTIONS
          error                    = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CLEAR wa_draw_check.
      wa_draw_check = i_draw.

      CALL FUNCTION '/CIDEON/CHECK_DIS_FOR_CLASS'
        EXPORTING
          i_wa_draw                = wa_draw_check
        TABLES
          i_itab_class_data_no_use = itab_class_data_no_use
        EXCEPTIONS
          error                    = 1
          do_not_use_dis           = 2
          OTHERS                   = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        IF sy-subrc = 2.
          RAISE do_not_stamp.
        ELSE.
        ENDIF.
      ENDIF.

    ELSE.
    ENDIF.
  ELSE.
  ENDIF.




* Anmeldung an einem SMB Share
  IF user_data-knz_anmeldung_am_server = 'X'.
    CALL FUNCTION '/CIDEON/ANMELDUNG_AN_SERVER'
      EXPORTING
        i_anmeldestring_server         = user_data-anmeldestring_server
        i_anmeldestring_server_voher   = user_data-anmeldestring_server_vorher
        i_anmeldestring_server_nachher = user_data-anmeldestring_server_nachher
      EXCEPTIONS
        error                          = 1
        OTHERS                         = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.

* Stempeltabelle füllen
  CLEAR itab_stempel.
  CLEAR wa_stempel.
  CALL FUNCTION '/CIDEON/STAMP_STEMPEL_WERTE'
    EXPORTING
      i_appl_type     = i_appl_type
      i_draw          = i_draw
      i_target_file   = i_target_file
      i_docfile       = i_docfile
      i_draz          = i_draz
    TABLES
      o_stempel_werte = itab_stempel
    EXCEPTIONS
      error           = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Klassifikationen holen
  CLEAR itab_class_data.
  CLEAR itab_plotjobs.
  CLEAR wa_plotjob.
  MOVE-CORRESPONDING i_draw TO wa_plotjob.
  "Objekt-ID erzeugen
  CALL FUNCTION 'Z_CL_MAKE_OBJECT_KEY'
    EXPORTING
      i_dokar = wa_plotjob-dokar
      i_doknr = wa_plotjob-doknr
      i_dokvr = wa_plotjob-dokvr
      i_doktl = wa_plotjob-doktl
    IMPORTING
      o_objky = wa_plotjob-objky
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  APPEND wa_plotjob TO itab_plotjobs.

  CALL FUNCTION '/CIDEON/GET_CLASS_DATA'
    EXPORTING
      i_nutzer          = sy-uname
      i_default_nutzer  = default_data-default_nutzer
    TABLES
      i_itab_plotjobs   = itab_plotjobs
      o_itab_class_data = itab_class_data
    EXCEPTIONS
      error             = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION '/CIDEON/GET_STAMP_DATA'
    EXPORTING
      i_nutzer          = sy-uname
      i_default_nutzer  = default_data-default_nutzer
    TABLES
      i_itab_plotjobs   = itab_plotjobs
      o_itab_stamp_data = itab_stamp_data
    EXCEPTIONS
      error             = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Tabelle für Verarbeitung zusammenführen
* Stempel, normale Stempel, Klassifizierung
* normale Stempel bleiben als Grundlage
* Stempel
  LOOP AT itab_stempel INTO wa_stempel.
    APPEND wa_stempel TO itab_stamp_data.
  ENDLOOP.
* Klassifikation
  LOOP AT itab_class_data INTO wa_class_data.
    APPEND wa_class_data TO itab_stamp_data.
  ENDLOOP.


* resultierende Stempel holen
  CLEAR itab_res_data.
  CALL FUNCTION '/CIDEON/GET_RESULT_STAMP_DATA'
    EXPORTING
      i_nutzer          = sy-uname
      i_default_nutzer  = default_data-default_nutzer
    TABLES
      i_itab_plotjobs   = itab_plotjobs
      i_itab_stamp_data = itab_stamp_data
      o_itab_stamp_data = itab_res_data
    EXCEPTIONS
      error             = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Anhängen, dann Sortieren / resultierende Stempel
  LOOP AT itab_res_data INTO wa_res_data.
    APPEND wa_res_data TO itab_stamp_data.
  ENDLOOP.

  SORT itab_stamp_data BY zeile_plotjob stempel_name ASCENDING.


* Tabellen zusammenführen
* in andere Tabellendarstellung mappen
  CLEAR itab_stempel_werte.
  CLEAR wa_stempel_werte.
  wa_stempel_werte-line = '[STAMPSFIELDS]'.
  APPEND wa_stempel_werte TO itab_stempel_werte.
  LOOP AT itab_stamp_data INTO wa_stamp_data.
    CLEAR wa_stempel_werte.
    CONCATENATE wa_stamp_data-stempel_name '='
      wa_stamp_data-stempel_wert
      INTO wa_stempel_werte-line.
    APPEND wa_stempel_werte TO itab_stempel_werte.
  ENDLOOP.



*   wo liegt die Grafikdatei ?!?
*   Dateinamen zerlegen
  docid = i_target_file-filename.
*  CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
*    EXPORTING
*      pf_docid     = docid
*    IMPORTING
*      pf_directory = verzeichnis
*      pf_filename  = dateiname
*      pf_extension = extension.


  DATA pfx_path TYPE draw-filep.
  DATA pfx_file TYPE draw-filep.
  CLEAR pfx_path.
  CLEAR pfx_file.

  CALL FUNCTION 'CV120_SPLIT_PATH'
    EXPORTING
      pf_path  = i_target_file-filename
    IMPORTING
      pfx_path = pfx_path
      pfx_file = pfx_file.


*  CONCATENATE verzeichnis 'stamps.txt'
*    INTO dateiname_stempel.
  CONCATENATE pfx_path pfx_file '_stamps.txt'
    INTO dateiname_stempel.


  start_verzeichnis = pfx_path .

* Arbeitsverzeichnis
*  docid = user_data-stamp_program.
*  CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
*    EXPORTING
*      pf_docid     = docid
*    IMPORTING
*      pf_directory = verzeichnis
*      pf_filename  = dateiname
*      pf_extension = extension.
*

  DATA lc_pf_path TYPE filep.
  CLEAR lc_pf_path.

  lc_pf_path = user_data-stamp_program.

  CLEAR pfx_path.
  CLEAR pfx_file.

  CALL FUNCTION 'CV120_SPLIT_PATH'
    EXPORTING
      pf_path  = lc_pf_path
    IMPORTING
      pfx_path = pfx_path
      pfx_file = pfx_file.


  arbeits_verzeichnis = pfx_path.

** Existiert erst ab 4.6c ......
*  CALL FUNCTION 'DSVAS_DOC_WS_DOWNLOAD_50'
*   EXPORTING
**     BIN_FILESIZE                  = ' '
*     filename                      = dateiname_stempel
*     filetype                      = 'ASC'
**     MODE                          = ' '
**   IMPORTING
**     FILELENGTH                    =
*    TABLES
*      data_tab                      = itab_stempel_werte
*   EXCEPTIONS
*     file_open_error               = 1
*     file_write_error              = 2
*     invalid_filesize              = 3
*     invalid_type                  = 4
*     no_batch                      = 5
*     unknown_error                 = 6
*     invalid_table_width           = 7
*     gui_refuse_filetransfer       = 8
*     customer_error                = 9
*     no_authority                  = 10
*     OTHERS                        = 11
*            .
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

  DATA lc_filename_str TYPE string.
  CLEAR lc_filename_str.
  lc_filename_str = dateiname_stempel.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
*      bin_filesize              =
      filename                  = lc_filename_str
       filetype                  = 'ASC'
*      append                    = SPACE
*      write_field_separator     = SPACE
*      header                    = '00'
*      trunc_trailing_blanks     = SPACE
*      write_lf                  = 'X'
*      col_select                = SPACE
*      col_select_mask           = SPACE
*      dat_mode                  = SPACE
*      confirm_overwrite         = SPACE
*      no_auth_check             = SPACE
*      codepage                  = SPACE
*      ignore_cerr               = ABAP_TRUE
*      replacement               = '#'
*      write_bom                 = SPACE
*      trunc_trailing_blanks_eol = 'X'
*      wk1_n_format              = SPACE
*      wk1_n_size                = SPACE
*      wk1_t_format              = SPACE
*      wk1_t_size                = SPACE
*      show_transfer_status      = 'X'
*      fieldnames                =
*      write_lf_after_last_line  = 'X'
*    IMPORTING
*      filelength                =
    CHANGING
      data_tab                  = itab_stempel_werte
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      OTHERS                    = 24
          .

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Auseinandersteuern, ob TIF oder PDF
* PDF -> PDF mit Stempeln bedeutet PDF->TIF->PDF
* TIF -> TIF mit Stempeln bedeutet TIF->TIF


* Ändern der Auseinandersteuerung !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* möglicherweise ist eine andere Benenung der WSAPPLICATIONS
* vorhanden, deshalb Mapping Tabelle dazu schreiben ...
* Ändern der Auseinandersteuerung !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  IF user_data-knz_use_stamp_call_rfc = 'X'.
*   Aufruf über RFC
    CASE i_target_file-dappl.
      WHEN 'TIF'.
        CALL FUNCTION '/CIDEON/STAMP_CALL_STMP_TOOL_R'
          EXPORTING
            i_filename              = i_target_file-filename
            i_filename_ziel         = i_target_file-filename
            i_filename_stempel      = dateiname_stempel
            i_stamp_program         = user_data-stamp_program
            i_start_verzeichnis     = start_verzeichnis
            i_arbeits_verzeichnis   = arbeits_verzeichnis
            i_konverter             = 'TOTIF'
            i_stamp_parameter       = user_data-stamp_parameter
            i_stamp_rfc_destination = user_data-stamp_rfc_destination
            i_stamp_ftp_destination = user_data-stamp_ftp_destination
            i_stamp_ftp_user        = user_data-stamp_ftp_user
            i_stamp_ftp_passwd      = user_data-stamp_ftp_passwd
            i_stamp_ftp_verzeichnis = user_data-stamp_ftp_verzeichnis
            i_stamp_delay           = user_data-stamp_delay
          EXCEPTIONS
            error                   = 1
            OTHERS                  = 2.
        IF sy-subrc <> 0.
*         Fehlermeldung
*         Löschen der Dateien ....
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.
      WHEN 'PDF'.
        CALL FUNCTION '/CIDEON/STAMP_CALL_STMP_TOOL_R'
          EXPORTING
            i_filename              = i_target_file-filename
            i_filename_ziel         = i_target_file-filename
            i_filename_stempel      = dateiname_stempel
            i_stamp_program         = user_data-stamp_program
            i_start_verzeichnis     = start_verzeichnis
            i_arbeits_verzeichnis   = arbeits_verzeichnis
            i_konverter             = 'TOPDF'
            i_stamp_parameter       = user_data-stamp_parameter
            i_stamp_rfc_destination = user_data-stamp_rfc_destination
            i_stamp_ftp_destination = user_data-stamp_ftp_destination
            i_stamp_ftp_user        = user_data-stamp_ftp_user
            i_stamp_ftp_passwd      = user_data-stamp_ftp_passwd
            i_stamp_ftp_verzeichnis = user_data-stamp_ftp_verzeichnis
            i_stamp_delay           = user_data-stamp_delay
          EXCEPTIONS
            error                   = 1
            OTHERS                  = 2.
        IF sy-subrc <> 0.
*         Fehlermeldung
*         Löschen der Dateien ....
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.

      WHEN OTHERS.
        EXIT.
    ENDCASE.

  ELSE.
*   Aufruf über BATCHe
    CASE i_target_file-dappl.
      WHEN 'TIF'.
*       Konvertierungstool aufrufen
        CALL FUNCTION '/CIDEON/STAMP_CALL_STAMP_TOOL'
          EXPORTING
            i_filename            = i_target_file-filename
            i_filename_ziel       = i_target_file-filename
            i_filename_stempel    = dateiname_stempel
            i_stamp_program       = user_data-stamp_program
            i_start_verzeichnis   = start_verzeichnis
            i_arbeits_verzeichnis = arbeits_verzeichnis
            i_konverter           = ''
            i_stamp_parameter     = user_data-stamp_parameter
          EXCEPTIONS
            error                 = 1
            OTHERS                = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      WHEN 'PDF'.
*       Konvertierungstool aufrufen
        CALL FUNCTION '/CIDEON/STAMP_CALL_STAMP_TOOL'
          EXPORTING
            i_filename            = i_target_file-filename
            i_filename_ziel       = i_target_file-filename
            i_filename_stempel    = dateiname_stempel
            i_stamp_program       = user_data-stamp_program
            i_start_verzeichnis   = start_verzeichnis
            i_arbeits_verzeichnis = arbeits_verzeichnis
            i_konverter           = ''
            i_stamp_parameter     = user_data-stamp_parameter
          EXCEPTIONS
            error                 = 1
            OTHERS                = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

*       Mapping ?!?


*       Konvertierungstool aufrufen
        CALL FUNCTION '/CIDEON/STAMP_CALL_STAMP_TOOL'
          EXPORTING
            i_filename            = i_target_file-filename
            i_filename_ziel       = i_target_file-filename
            i_filename_stempel    = ''  "dateiname_stempel
            i_stamp_program       = user_data-stamp_program
            i_start_verzeichnis   = start_verzeichnis
            i_arbeits_verzeichnis = arbeits_verzeichnis
            i_konverter           = 'TOPDF'
            i_stamp_parameter     = user_data-stamp_parameter
          EXCEPTIONS
            error                 = 1
            OTHERS                = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

      WHEN OTHERS.
        EXIT.
    ENDCASE.

  ENDIF.




* Unterscheidungen in verschiedene Versionen
  IF sy-saprl = '610'
    OR sy-saprl = '620'.
*   FrontEntServices benutzen
*    CREATE OBJECT frontend
*    EXPORTING
*      TITLE  =
*      INIT_DIRECTORY =
    .
  ELSE.
*   alte Bausteine benutzen
*    CALL FUNCTION 'WS_ULDL_PATH'
*         IMPORTING
*              download_path = download_path
*              upload_path   = upload_path.

  ENDIF.

* temporäre Dateien löschen
* Stempeldateien
* Startdateien
  DATA: file_to_delete TYPE rlgrap-filename.

  file_to_delete = dateiname_stempel.
  CALL FUNCTION 'GUI_DELETE_FILE'
    EXPORTING
      file_name = file_to_delete
    EXCEPTIONS
      failed    = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.




ENDFUNCTION.
