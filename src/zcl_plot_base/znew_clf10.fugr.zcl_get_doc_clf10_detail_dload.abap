FUNCTION zcl_get_doc_clf10_detail_dload.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NEW_DIRECTORY_NAME) TYPE  STRING OPTIONAL
*"     VALUE(WA_TEST) TYPE  ZCL_S_PLOTLIST OPTIONAL
*"     VALUE(I_LAST_PATH) TYPE  STRING OPTIONAL
*"     VALUE(I_DOWNLOADED_PATH) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(E_NEW_PATH) TYPE  STRING
*"     VALUE(E_LAST_PATH) TYPE  FILEP
*"  TABLES
*"      IT_AOFILE STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      IT_AOFILE_CLF STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      NO_CHECKOUT
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Srinivas Mamillapalli
*
*           Christoph Küchler
*
* Kontakt:
*           helpdesk@cideon-software.com
*
*-----------------------------------------------------------------------
* Journal
* 24.03.2004 - Änderungen, Fehlermeldung, falls Datei nicht am
*              DIS vorhanden ist
* 25.03.2004 - Integration SPOOL Dateien / Fertifungsauftrag
* 17.06.2005 - Loggen von Informationen im Appl. LOG
* 12.08.2005 - COMMIT WORK AND WAIT / WAIT vor der Ausgabe
*              Downloadproblem bei Diehl Avionik
* 28.09.2005 - Loggen bei Kopierproblem
* 17.02.2006 - Anpassung SPOOL Dateien
* 21.07.2006 - Berücksichtigung von Komponenten / Redlining
* 12.02.2007 - Integration der Möglichkeit ganze Strukturen
*              auf dem Plotserver auszugeben (Checkout mit Struktur)
*              Hintergrund: Borealis - native Konvertierung vor dem
*              Plotten mit AutoCAD Dateien + X-Refs
* 28.02.2007 - Erweiterung der Implementierung für Borealis, so daß
*              auch alle anderes WSA und nicht nur die Obere
*              beachtet werden
* 22.07.2008 -
*              Längenproblem beim SPLIT
*              Manz
*
* SP 115
* 08.01.2010 - SR 7904
*              (HDF MSH090685)
*              Meldung (zcvn) =16 vermeiden, bei mehrfachem Kopieren,
*              falls das Dokument schon vorhanden ist
*
* SP 117
* 25.01.2010 - SR
*              Borg Warner
*              Problem, daß hier das Auschecken mit Struktur, wegen
*              einer nicht vorhandenen Berechtigung auf die Stückliste
*              fehlschlägt.
*              Für diesen Kunden ist die Stücklliste nicht notwendig.
*              Änderung der Checkoutparameter
*              0 = nur angegebene Datei
*              1 = angegebene Datei + erste Ebene unter Datei
*              2 = angegebene Datei + alle Ebenen darunter
*
* SP119
* 7.0.1.19
* 16.02.2010 - CONCAST
*              Reaktion auf nicht zugreifbare Dateien aus dem CS
*              -> Fehlblattgenerierung
*
* 14.01.2011 - CKR
* 7.0.144.1    URL Integration in ZCL_GET_DOC_CLF10_DETAIL_DLOAD
*              Reaktion auf URL wo keine Datei angegeben ist1
*              ... dds.getPDF?IdentNr=12423
*              BADI Integration
*              Umstieg auf GUID
*
* 7.0.167.1
* 2013/05/27 SM 8000014441 - Rofin
* Dateipfad länger als 128 Zeichen
* FB ZCL_GET_DOC_CLF10_DETAIL_DLOAD
*
* 7.0.170.1
* 2014/10/02 - APEX
* Anpassung der Sourcen auf Ersetzung von FB GUID_CREATE

*-----------------------------------------------------------------------


*  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  DATA : itab_bapi_doc_files2 TYPE TABLE OF bapi_doc_files2,
         wa_bapi_doc_files2   TYPE bapi_doc_files2 .

  DATA : itab2_bapi_doc_files2 TYPE TABLE OF bapi_doc_files2 ,
         wa2_bapi_doc_files2 TYPE bapi_doc_files2.

  DATA:  it_components TYPE TABLE OF bapi_doc_comp.
  DATA:  wa_components TYPE bapi_doc_comp.

* Strucctures for the return objects...
  DATA : itab_bapi_doc_draw2 TYPE bapi_doc_draw2,
         itab_bapiret2 TYPE bapiret2.

  DATA : ao_naming(60)  TYPE c,
         lv_string(200) TYPE c,
         lv_last_path   TYPE filep.

  DATA : ws_return.

*  DATA :
*         lv_stripped_name LIKE rlgrap-filename,
*         lv_file_path     LIKE rlgrap-filename,
*         lv_full_name     LIKE rlgrap-filename,
*         i_down_path      LIKE rlgrap-filename,
*         lv_split_part1   LIKE rlgrap-filename.
*


*  DATA :
*         lv_stripped_name TYPE filep,
*         lv_file_path     TYPE filep,
*         lv_full_name     TYPE filep,
*         i_down_path      TYPE filep,
*         lv_split_part1   TYPE filep.

  DATA :
          lv_stripped_name TYPE string,
          lv_file_path     TYPE string,
          lv_full_name     TYPE string,
          i_down_path      TYPE string,
          lv_split_part1   TYPE string.

  DATA : flag_checked_in TYPE c.

  DATA : return TYPE bapiret2.

  DATA : tmp_bapi_check_path TYPE bapi_doc_aux-filename.

  DATA : tmp_fname(255)     TYPE c,
         tmp_flag_file_exit TYPE c,
         tmp_flag_isdir     TYPE c.

  DATA: dis_keys(36).

  DATA: knz_plot_log.
  DATA: return_log TYPE bapiret2.
  DATA: wa_log_bapi_doc_files2 TYPE bapi_doc_files2.
*  DATA: log_stripped_name LIKE rlgrap-filename.
*  DATA: log_file_path     LIKE rlgrap-filename.
*  DATA: log_full_name     LIKE rlgrap-filename.

  DATA: log_stripped_name LIKE draw-filep.
  DATA: log_file_path     LIKE draw-filep.
  DATA: log_full_name     LIKE draw-filep.

  DATA: knz_clf_commit.
  DATA: clf_wait_time(10).
  DATA: knz_copy_original.

  DATA: itab_file TYPE TABLE OF filep.
  DATA: lines TYPE i.
  DATA: wa_file TYPE filep.
  DATA: index TYPE i.

  DATA: file_source TYPE string.
  DATA: file_dest TYPE string.

  DATA: wa_wsa_down TYPE /cideon/wsa_down.

* Log Parameter
  CLEAR knz_plot_log.
  GET PARAMETER ID 'Z_KNZ_PLOT_LOG' FIELD knz_plot_log.

  CLEAR knz_clf_commit.
  GET PARAMETER ID 'Z_KNZ_CLF_COMMIT' FIELD knz_clf_commit.

  CLEAR clf_wait_time.
  GET PARAMETER ID 'Z_CLF_WAIT_TIME' FIELD clf_wait_time.

* spezial Parameter
  CLEAR knz_copy_original.
  GET PARAMETER ID 'Z_COPY_ORIGINAL' FIELD knz_copy_original.


  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ENDIF.

  "BADI
  DATA: badi_main_pre_001
    TYPE REF TO /cideon/if_ex_pre_main_001.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = badi_main_pre_001.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


  IF wa_test-filep NE i_last_path.
    MOVE wa_test-filep TO lv_last_path.
    MOVE lv_last_path TO e_last_path.

*   Dokument ist abgelegt
*   abgelegtes Dokument soll benutzt werden
    IF ( wa_test-storagecategory NE space )
          AND ( wa_test-knz_use_checked_in NE space ).
      CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
        EXPORTING
          documenttype               = wa_test-dokar
          documentnumber             = wa_test-doknr
          documentpart               = wa_test-doktl
          documentversion            = wa_test-dokvr
*         GETOBJECTLINKS             = ' '
*         GETCOMPONENTS              = ' '
*         GETSTATUSLOG               = ' '
*         GETLONGTEXTS               = ' '
*         GETACTIVEFILES             = 'X'
*         GETCLASSIFICATION          = ' '
*         GETSTRUCTURE               = ' '
*         GETWHEREUSED               = ' '
*         HOSTNAME                   = ' '
        IMPORTING
          documentdata               = itab_bapi_doc_draw2
          return                     = itab_bapiret2
        TABLES
*         OBJECTLINKS                =
*         DOCUMENTDESCRIPTIONS       =
*         LONGTEXTS                  =
*         STATUSLOG                  =
          documentfiles              = itab_bapi_doc_files2
*         COMPONENTS                 =
*         CHARACTERISTICVALUES       =
*         CLASSALLOCATIONS           =
*         DOCUMENTSTRUCTURE          =
*         WHEREUSEDLIST              =
      .

      IF itab_bapi_doc_files2 IS INITIAL.
        MESSAGE e028(zcvn) WITH wa_test-dokar wa_test-doknr
                                wa_test-doktl wa_test-dokvr.
      ENDIF.

*     Test, ob Dateiname in den am DIS enthalten Dateien
*     vorhanden ist
      LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2
        WHERE docfile = wa_test-filep.
      ENDLOOP.

      IF sy-subrc NE 0.
        CLEAR dis_keys.
        CONCATENATE wa_test-dokar '/' wa_test-doknr '/'
          wa_test-doktl '/' wa_test-dokvr
          INTO dis_keys.
        MESSAGE e029(zcvn) WITH wa_test-filep
          dis_keys '' '' RAISING error.
      ELSE.
      ENDIF.

      CLEAR index.
      LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2.
        IF wa_bapi_doc_files2-docfile = wa_test-filep
          "CKR 2012/03/01
          AND wa_bapi_doc_files2-originaltype =
            wa_test-originaltype.
          MOVE wa_bapi_doc_files2-docfile TO lv_full_name.

          IF lv_full_name CS '\'.
            CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
              EXPORTING
                full_name     = lv_full_name
              IMPORTING
                stripped_name = lv_stripped_name
                file_path     = lv_file_path
              EXCEPTIONS
                x_error       = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ENDIF.
          ENDIF.

*         Temporary Variable to accept filepath.
          CLEAR tmp_bapi_check_path .

          CONCATENATE i_new_directory_name '\'
            INTO tmp_bapi_check_path .

          CLEAR itab2_bapi_doc_files2.
          "REFRESH itab2_bapi_doc_files2. " ck 31.03.2003
          CLEAR it_components.

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 50
              text       = lv_string.

          CLEAR return.

*          TRANSLATE tmp_bapi_check_path TO UPPER CASE.


          DATA : it_doc_structure TYPE TABLE OF bapi_doc_structure.

*       If the Original File is Checkedin Download by using
*       below BAPI_* Function Module.
*
          IF knz_clf_commit = 'X'.
            COMMIT WORK AND WAIT.
          ELSE.
          ENDIF.

          IF NOT clf_wait_time IS INITIAL.
            IF NOT clf_wait_time CO '0123456789 '.
              clf_wait_time = '0'.
            ELSE.
            ENDIF.
            WAIT UP TO clf_wait_time SECONDS.
          ELSE.
          ENDIF.

*        Checkoutintegration - Strukturen
          CLEAR wa_wsa_down.
          SELECT SINGLE * FROM /cideon/wsa_down
            INTO wa_wsa_down
            WHERE
            dokar = wa_test-dokar
            AND dappl = wa_bapi_doc_files2-wsapplication
            AND status = '10'
           .
          IF sy-subrc NE 0.
*           einzelnes File laden
            wa_wsa_down-getstructure = '1'.
            " SP 117 2010/01/25
            wa_wsa_down-getstructure = '0'.
          ELSE.
          ENDIF.

          IF wa_wsa_down-getstructure = '2'.
            CLEAR wa_bapi_doc_files2-file_id.
            CLEAR wa_bapi_doc_files2-application_id.
            CLEAR wa_bapi_doc_files2-originaltype.
            CLEAR wa_bapi_doc_files2-checkedin.
            CLEAR wa_bapi_doc_files2-active_version.
            CLEAR wa_bapi_doc_files2-storagecategory.

*           Download aller Dateien der Struktur
            IF wa_wsa_down-alle_dappl = 'X'.
              wa_bapi_doc_files2-wsapplication = '*'.
            ELSE.
            ENDIF.

          ELSE.
          ENDIF.

          CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
            EXPORTING
              documenttype        = wa_test-dokar
              documentnumber      = wa_test-doknr
              documentpart        = wa_test-doktl
              documentversion     = wa_test-dokvr
              documentfile        = wa_bapi_doc_files2
              getstructure        = wa_wsa_down-getstructure "'1'
              getcomponents       = 'X'
              originalpath        = tmp_bapi_check_path
              hostname            = ' '
              getheader           = 'X'
*             docbomchangenumber  =
*             docbomvalidfrom     =
*             docbomrevisionlevel =
            IMPORTING
              return              = return
            TABLES
              documentstructure   = it_doc_structure
              documentfiles       = itab2_bapi_doc_files2
              components          = it_components
                    .

* SP119
          IF return-type CA 'EA'.
            "RAISE no_checkout.
          ELSE.
          ENDIF.
*/SP119

*         Checkoutintegration - Strukturen
*         Falls mehr als eine Datei abgelegt, dann die anderen
*         aus der Tabelle löschen
          CLEAR wa_log_bapi_doc_files2.
          LOOP AT itab2_bapi_doc_files2
            INTO wa_log_bapi_doc_files2.
            index = sy-tabix.
            IF index = '2'.
              DELETE itab2_bapi_doc_files2 INDEX index.
            ELSE.
            ENDIF.
          ENDLOOP.

          IF knz_copy_original = 'X'.
*           Umbenennen der abgelegten Dateien auf FILE_ID
*           2009/10/01 Anpassung auf GUID

            CLEAR wa_log_bapi_doc_files2.
            LOOP AT itab2_bapi_doc_files2
              INTO wa_log_bapi_doc_files2.
*             Umbenennen (Copy, delete)
              index = sy-tabix.

              CLEAR file_source.
              CLEAR file_dest.
              file_source = wa_log_bapi_doc_files2-docfile.

              CLEAR log_stripped_name.
              CLEAR log_file_path.
              CLEAR log_full_name.

              log_full_name = file_source.
*              CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*                   EXPORTING
*                        full_name     = log_full_name
*                   IMPORTING
*                        stripped_name = log_stripped_name
*                        file_path     = log_file_path
*                   EXCEPTIONS
*                        x_error       = 1
*                        OTHERS        = 2.

              CALL FUNCTION 'CV120_SPLIT_PATH'
                EXPORTING
                  pf_path  = log_full_name
                IMPORTING
                  pfx_path = log_file_path
                  pfx_file = log_stripped_name.


              IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                CONTINUE.
              ENDIF.

              " GUID holen
              DATA: lc_guid TYPE guid_32.
              CLEAR lc_guid.
              "CALL FUNCTION 'GUID_CREATE'
              CALL FUNCTION '/CIDEON/OM_CLASSIC_GUID_CREATE'
                IMPORTING
                  ev_guid_32 = lc_guid.


*             Extension holen / Dateinamen ändern
              CLEAR itab_file.
              SPLIT log_stripped_name AT '.'
                INTO TABLE itab_file.
              CLEAR lines.
              DESCRIBE TABLE itab_file LINES lines.
              IF lines => 2.
                CLEAR wa_file.
                READ TABLE itab_file INTO wa_file INDEX lines.
                CONCATENATE log_file_path wa_log_bapi_doc_files2-file_id
                                                             '.' wa_file
                                                          INTO file_dest.
                CONCATENATE log_file_path
                   lc_guid '.' wa_file INTO file_dest.
              ELSE.
                CONCATENATE log_file_path wa_log_bapi_doc_files2-file_id
                                                          INTO file_dest.
                CONCATENATE log_file_path
                  lc_guid '.' wa_file INTO file_dest.
              ENDIF.

              CALL METHOD cl_gui_frontend_services=>file_copy
                EXPORTING
                  SOURCE             = file_source
                  DESTINATION        = file_dest
*                OVERWRITE          = SPACE
                 EXCEPTIONS
                   cntl_error         = 1
                   error_no_gui       = 2
                   wrong_parameter    = 3
                   disk_full          = 4
                   access_denied      = 5
                   file_not_found     = 6
                   destination_exists = 7
                   unknown_error      = 8
                   path_not_found     = 9
                   disk_write_protect = 10
                   drive_not_ready    = 11
                   OTHERS             = 12
                      .
              IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                IF sy-subrc = 7.
                ELSE.
                  CONTINUE.
                ENDIF.
              ELSE.
                "falls erfolgreich, dann Datei löschen
                DATA: lc_rc TYPE i.
                CLEAR lc_rc.
                CALL METHOD cl_gui_frontend_services=>file_delete
                  EXPORTING
                    filename           = file_source
                  CHANGING
                    rc                 = lc_rc
*                  EXCEPTIONS
*                    FILE_DELETE_FAILED = 1
*                    CNTL_ERROR         = 2
*                    ERROR_NO_GUI       = 3
*                    FILE_NOT_FOUND     = 4
*                    ACCESS_DENIED      = 5
*                    UNKNOWN_ERROR      = 6
*                    others             = 7
                        .
                IF sy-subrc <> 0.
*                 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                ENDIF.

              ENDIF.

*             Update der Tabelle
              wa_log_bapi_doc_files2-docfile = file_dest.
              MODIFY itab2_bapi_doc_files2
                FROM wa_log_bapi_doc_files2 INDEX index.
              wa_test-filep = file_dest.
            ENDLOOP.
          ELSE.
          ENDIF.

*         Loggen der Informationen
          IF knz_plot_log = 'X'.
            CLEAR wa_log_bapi_doc_files2.
            READ TABLE itab2_bapi_doc_files2
              INTO wa_log_bapi_doc_files2 INDEX 1.

            CLEAR return_log.
            return_log-type = 'W'.
            return_log-number = '000'.
            return_log-id = 'ZCL_PLINT_TOOLS'.
            return_log-message_v1 = 'ZCL_GET_DOC_CLF10_DETAIL_DLOAD'.
            return_log-message_v2 = wa_log_bapi_doc_files2-docfile.
            return_log-message_v3 = sy-datum.
            return_log-message_v4 = sy-uzeit.

            CLEAR log_stripped_name.
            CLEAR log_file_path.
            CLEAR log_full_name.

            log_full_name = wa_log_bapi_doc_files2-docfile.
*            CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*                 EXPORTING
*                      full_name     = log_full_name
*                 IMPORTING
*                      stripped_name = log_stripped_name
*                      file_path     = log_file_path
*                 EXCEPTIONS
*                      x_error       = 1
*                      OTHERS        = 2.
            CALL FUNCTION 'CV120_SPLIT_PATH'
              EXPORTING
                pf_path  = log_full_name
              IMPORTING
                pfx_path = log_file_path
                pfx_file = log_stripped_name.

            IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ENDIF.
            return_log-message_v2 = log_stripped_name.

            CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
              EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = return_log-number
                i_msgtyp   = return_log-type
                i_msgid    = return_log-id
                i_msgno    = return_log-number
                i_msgv1    = return_log-message_v1
                i_msgv2    = return_log-message_v2
                i_msgv3    = return_log-message_v3
                i_msgv4    = return_log-message_v4
                i_class    = ' '
                i_newhead  = 'X'
                i_messhead = 'X'
              EXCEPTIONS
                error      = 1
                OTHERS     = 2.
            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            COMMIT WORK.
          ELSE.
          ENDIF.

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 50
              text       = lv_string.

          IF return IS INITIAL.
            LOOP AT itab2_bapi_doc_files2 INTO wa_bapi_doc_files2.

              MOVE wa_bapi_doc_files2-docfile TO lv_full_name.

              CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
                EXPORTING
                  full_name     = lv_full_name
                IMPORTING
                  stripped_name = lv_stripped_name
                  file_path     = lv_file_path
                EXCEPTIONS
                  x_error       = 1
                  OTHERS        = 2.
              IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              ENDIF.

*             mögliche Komponenten holen und mitgeben
              CLEAR wa_components.
              IF it_components[] IS INITIAL.
              ELSE.
                LOOP AT it_components INTO wa_components
                 WHERE originaltype = wa_bapi_doc_files2-originaltype.
                ENDLOOP.
                IF sy-subrc NE 0.
                  CLEAR wa_components.
                ELSE.
                ENDIF.
              ENDIF.

              CALL FUNCTION 'ZCL_PROC_SKEL_AOFILE_CLF10'
                EXPORTING
                  wa_doc_files2    = wa_bapi_doc_files2
                  lv_stripped_name = lv_stripped_name
                  wa_test          = wa_test
                  wa_components    = wa_components
                TABLES
                  it_aofile        = it_aofile
                  it_aofile_clf    = it_aofile_clf
                  itab_stamps      = itab_stamps
                EXCEPTIONS
                  error            = 1
                  OTHERS           = 2.

              IF sy-subrc <> 0.
                MESSAGE e028(zcvn) WITH ao_naming.
              ENDIF.
            ENDLOOP.
          ELSE.
*           Make an Entry in the APPL-LOG
            CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
              EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = return-number
                i_msgtyp   = return-type
                i_msgid    = return-id
                i_msgno    = return-number
                i_msgv1    = return-message_v1
                i_msgv2    = return-message_v2
                i_msgv3    = return-message_v3
                i_msgv4    = return-message_v4
                i_class    = ' '
                i_newhead  = 'X'
                i_messhead = 'X'
              EXCEPTIONS
                error      = 1
                OTHERS     = 2.
            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            COMMIT WORK.
*           Send a Message
            "MESSAGE i002(zcvn) WITH return-message '' '' '' .
            MESSAGE ID return-id TYPE return-type NUMBER return-number
                       WITH return-message_v1 return-message_v2
                       return-message_v3 return-message_v4
                       .
          ENDIF.

        ELSE.
        ENDIF.
      ENDLOOP.

      LOOP AT itab2_bapi_doc_files2 INTO wa2_bapi_doc_files2.
        MOVE wa2_bapi_doc_files2-docfile TO e_new_path.
      ENDLOOP.

      CLEAR lv_full_name.
      CLEAR lv_stripped_name.
      CLEAR lv_file_path.

    ELSEIF wa_test-checked NE space.
*   Dokument ist  abgelegt
      CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
              EXPORTING
                documenttype               = wa_test-dokar
                documentnumber             = wa_test-doknr
                documentpart               = wa_test-doktl
                documentversion            = wa_test-dokvr
*         GETOBJECTLINKS             = ' '
*         GETCOMPONENTS              = ' '
*         GETSTATUSLOG               = ' '
*         GETLONGTEXTS               = ' '
*         GETACTIVEFILES             = 'X'
*         GETCLASSIFICATION          = ' '
*         GETSTRUCTURE               = ' '
*         GETWHEREUSED               = ' '
*         HOSTNAME                   = ' '
              IMPORTING
                documentdata               = itab_bapi_doc_draw2
                return                     = itab_bapiret2
              TABLES
*         OBJECTLINKS                =
*         DOCUMENTDESCRIPTIONS       =
*         LONGTEXTS                  =
*         STATUSLOG                  =
                documentfiles              = itab_bapi_doc_files2
*         COMPONENTS                 =
*         CHARACTERISTICVALUES       =
*         CLASSALLOCATIONS           =
*         DOCUMENTSTRUCTURE          =
*         WHEREUSEDLIST              =
            .

      IF itab_bapi_doc_files2 IS INITIAL.
        MESSAGE e028(zcvn) WITH wa_test-dokar wa_test-doknr
                                wa_test-doktl wa_test-dokvr.
      ENDIF.

      LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2.

        IF wa_bapi_doc_files2-docfile = wa_test-filep.

          MOVE wa_bapi_doc_files2-docfile TO lv_full_name.

          CLEAR tmp_bapi_check_path.

          CONCATENATE i_new_directory_name '\' INTO tmp_bapi_check_path .

          CLEAR itab2_bapi_doc_files2.
          CLEAR it_components.

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 70
              text       = lv_string.

          CLEAR return.

*       If the Original File is Checkedin Download by using
*       below BAPI_* Function Module.

*        Checkoutintegration - Strukturen
          CLEAR wa_wsa_down.
          SELECT SINGLE * FROM /cideon/wsa_down
            INTO wa_wsa_down
            WHERE
            dokar = wa_test-dokar
            AND dappl = wa_bapi_doc_files2-wsapplication
            AND status = '10'
           .
          IF sy-subrc NE 0.
*           einzelnes File laden
            wa_wsa_down-getstructure = '1'.
            " SP 117 2010/01/25
            wa_wsa_down-getstructure = '0'.
          ELSE.
          ENDIF.

          IF wa_wsa_down-getstructure = '2'.
            CLEAR wa_bapi_doc_files2-file_id.
            CLEAR wa_bapi_doc_files2-application_id.
            CLEAR wa_bapi_doc_files2-originaltype.
            CLEAR wa_bapi_doc_files2-checkedin.
            CLEAR wa_bapi_doc_files2-active_version.
            CLEAR wa_bapi_doc_files2-storagecategory.

*           Download aller Dateien der Struktur
            IF wa_wsa_down-alle_dappl = 'X'.
              wa_bapi_doc_files2-wsapplication = '*'.
            ELSE.
            ENDIF.

          ELSE.
          ENDIF.

          CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
               EXPORTING
                    documenttype        = wa_test-dokar
                    documentnumber      = wa_test-doknr
                    documentpart        = wa_test-doktl
                    documentversion     = wa_test-dokvr
                    documentfile        = wa_bapi_doc_files2
                   getstructure        = wa_wsa_down-getstructure "'1'
                    getcomponents       = 'X'
                    originalpath        = tmp_bapi_check_path
*                 hostname            = ' '
                    getheader           = 'X'
*                 docbomchangenumber  =
*                 docbomvalidfrom     =
*                 docbomrevisionlevel =
            IMPORTING
                 return              = return
               TABLES
*                 documentstructure   =
                    documentfiles       = itab2_bapi_doc_files2
                    components          = it_components
                    .
*         Checkoutintegration - Strukturen
*         Falls mehr als eine Datei abgelegt, dann die anderen
*         aus der Tabelle löschen
          CLEAR wa_log_bapi_doc_files2.
          LOOP AT itab2_bapi_doc_files2
            INTO wa_log_bapi_doc_files2.
            index = sy-tabix.
            IF index = '2'.
              DELETE itab2_bapi_doc_files2 INDEX index.
            ELSE.
            ENDIF.
          ENDLOOP.
          IF knz_copy_original = 'X'.
*           Umbenennen der abgelegten Dateien auf FILE_ID
            CLEAR wa_log_bapi_doc_files2.
            LOOP AT itab2_bapi_doc_files2
              INTO wa_log_bapi_doc_files2.
*             Umbenennen (Copy, delete)
              index = sy-tabix.

              CLEAR file_source.
              CLEAR file_dest.
              file_source = wa_log_bapi_doc_files2-docfile.

              CLEAR log_stripped_name.
              CLEAR log_file_path.
              CLEAR log_full_name.

              log_full_name = file_source.
*              CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*                   EXPORTING
*                        full_name     = log_full_name
*                   IMPORTING
*                        stripped_name = log_stripped_name
*                        file_path     = log_file_path
*                   EXCEPTIONS
*                        x_error       = 1
*                        OTHERS        = 2.
              CALL FUNCTION 'CV120_SPLIT_PATH'
                EXPORTING
                  pf_path  = log_full_name
                IMPORTING
                  pfx_path = log_file_path
                  pfx_file = log_stripped_name.

              IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                CONTINUE.
              ENDIF.

              " GUID holen
              "DATA: lc_guid TYPE guid_32.
              CLEAR lc_guid.
              CALL FUNCTION 'GUID_CREATE'
                IMPORTING
                  ev_guid_32 = lc_guid.


*             Extension holen / Dateinamen ändern
              CLEAR itab_file.
              SPLIT log_stripped_name AT '.'
                INTO TABLE itab_file.
              CLEAR lines.
              DESCRIBE TABLE itab_file LINES lines.
              IF lines => 2.
                CLEAR wa_file.
                READ TABLE itab_file INTO wa_file INDEX lines.
                CONCATENATE log_file_path wa_log_bapi_doc_files2-file_id
                                                             '.' wa_file
                                                          INTO file_dest.

                CONCATENATE log_file_path lc_guid '.' wa_file
                  INTO file_dest.
              ELSE.
                CONCATENATE log_file_path wa_log_bapi_doc_files2-file_id
                                                          INTO file_dest.

                CONCATENATE log_file_path lc_guid '.' wa_file
                  INTO file_dest.
              ENDIF.

              CALL METHOD cl_gui_frontend_services=>file_copy
                EXPORTING
                  SOURCE             = file_source
                  DESTINATION        = file_dest
*                OVERWRITE          = SPACE
                 EXCEPTIONS
                   cntl_error         = 1
                   error_no_gui       = 2
                   wrong_parameter    = 3
                   disk_full          = 4
                   access_denied      = 5
                   file_not_found     = 6
                   destination_exists = 7
                   unknown_error      = 8
                   path_not_found     = 9
                   disk_write_protect = 10
                   drive_not_ready    = 11
                   OTHERS             = 12
                      .
              IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                IF sy-subrc = 7.
                ELSE.
                  CONTINUE.
                ENDIF.
              ELSE.
                "falls erfolgreich, dann Datei löschen
                "DATA: lc_rc TYPE i.
                CLEAR lc_rc.
                CALL METHOD cl_gui_frontend_services=>file_delete
                  EXPORTING
                    filename           = file_source
                  CHANGING
                    rc                 = lc_rc
*                  EXCEPTIONS
*                    FILE_DELETE_FAILED = 1
*                    CNTL_ERROR         = 2
*                    ERROR_NO_GUI       = 3
*                    FILE_NOT_FOUND     = 4
*                    ACCESS_DENIED      = 5
*                    UNKNOWN_ERROR      = 6
*                    others             = 7
                        .
                IF sy-subrc <> 0.
*                 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                ENDIF.

              ENDIF.

*             Update der Tabelle
              wa_log_bapi_doc_files2-docfile = file_dest.
              MODIFY itab2_bapi_doc_files2
                FROM wa_log_bapi_doc_files2 INDEX index.
              wa_test-filep = file_dest.
            ENDLOOP.
          ELSE.
          ENDIF.

*         Loggen der Informationen
          IF knz_plot_log = 'X'.
            CLEAR wa_log_bapi_doc_files2.
            READ TABLE itab2_bapi_doc_files2
              INTO wa_log_bapi_doc_files2 INDEX 1.

            CLEAR return_log.
            return_log-type = 'W'.
            return_log-number = '000'.
            return_log-id = 'ZCL_PLINT_TOOLS'.
            return_log-message_v1 = 'ZCL_GET_DOC_CLF10_DETAIL_DLOAD'.
            return_log-message_v2 = wa_log_bapi_doc_files2-docfile.
            return_log-message_v3 = sy-datum.
            return_log-message_v4 = sy-uzeit.

            CLEAR log_stripped_name.
            CLEAR log_file_path.
            CLEAR log_full_name.

            log_full_name = wa_log_bapi_doc_files2-docfile.
*            CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*                 EXPORTING
*                      full_name     = log_full_name
*                 IMPORTING
*                      stripped_name = log_stripped_name
*                      file_path     = log_file_path
*                 EXCEPTIONS
*                      x_error       = 1
*                      OTHERS        = 2.
            CALL FUNCTION 'CV120_SPLIT_PATH'
              EXPORTING
                pf_path  = log_full_name
              IMPORTING
                pfx_path = log_file_path
                pfx_file = log_stripped_name.
            IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ENDIF.
            return_log-message_v2 = log_stripped_name.

            CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
              EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = return_log-number
                i_msgtyp   = return_log-type
                i_msgid    = return_log-id
                i_msgno    = return_log-number
                i_msgv1    = return_log-message_v1
                i_msgv2    = return_log-message_v2
                i_msgv3    = return_log-message_v3
                i_msgv4    = return_log-message_v4
                i_class    = ' '
                i_newhead  = 'X'
                i_messhead = 'X'
              EXCEPTIONS
                error      = 1
                OTHERS     = 2.
            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            COMMIT WORK.
          ELSE.
          ENDIF.

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 70
              text       = lv_string.

          IF return IS INITIAL.

*           mögliche Komponenten holen und mitgeben
            CLEAR wa_components.
            IF it_components[] IS INITIAL.
            ELSE.
              LOOP AT it_components INTO wa_components
                WHERE originaltype = wa_bapi_doc_files2-originaltype.
              ENDLOOP.
              IF sy-subrc NE 0.
                CLEAR wa_components.
              ELSE.
              ENDIF.
            ENDIF.

            CALL FUNCTION 'ZCL_PROC_SKEL_AOFILE_CLF10'
              EXPORTING
                wa_doc_files2    = wa_bapi_doc_files2
                lv_stripped_name = lv_stripped_name
                wa_test          = wa_test
                wa_components    = wa_components
              TABLES
                it_aofile        = it_aofile
                it_aofile_clf    = it_aofile_clf
                itab_stamps      = itab_stamps
              EXCEPTIONS
                error            = 1
                OTHERS           = 2.

            IF sy-subrc <> 0.
              MESSAGE e028(zcvn) WITH ao_naming.
            ENDIF.

          ELSE.
*           Make an Entry in the APPL-LOG
            CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
              EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = return-number
                i_msgtyp   = return-type
                i_msgid    = return-id
                i_msgno    = return-number
                i_msgv1    = return-message_v1
                i_msgv2    = return-message_v2
                i_msgv3    = return-message_v3
                i_msgv4    = return-message_v4
                i_class    = ' '
                i_newhead  = 'X'
                i_messhead = 'X'
              EXCEPTIONS
                error      = 1
                OTHERS     = 2.
            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            COMMIT WORK.
*           Send a Message
            "MESSAGE i002(zcvn) WITH return-message '' '' '' .
            MESSAGE ID return-id TYPE return-type NUMBER return-number
                       WITH return-message_v1 return-message_v2
                       return-message_v3 return-message_v4
                       .
          ENDIF.

        ELSE.
        ENDIF.
      ENDLOOP.

      LOOP AT itab2_bapi_doc_files2 INTO wa2_bapi_doc_files2.
        MOVE wa2_bapi_doc_files2-docfile TO e_new_path.
      ENDLOOP.

      CLEAR lv_full_name.
      CLEAR lv_stripped_name.
      CLEAR lv_file_path.

    ELSE.
*     If the Original File is not Checkedin try to copy
*     the file from the Original Source to Destination.



      DATA : tmp_obj_source TYPE string,
             tmp_destiny    TYPE string.

      CLEAR tmp_obj_source.
      CLEAR tmp_destiny.
      CLEAR lv_stripped_name.
      CLEAR lv_file_path.
      CLEAR lv_full_name.

      MOVE wa_test-filep TO lv_full_name.
      MOVE i_new_directory_name TO tmp_destiny.

**     Besondere Berücksichtigung für Einträge, welche
*fertigungsrelevant
**     sind
**     Erstellen von PDFs aus Spoolaufträgen
*      IF wa_test-object_type = 'SPOOL'.
**       PDF erstellen
*        CALL FUNCTION '/CIDEON/OTF_2_PDF'
*             EXPORTING
*                  i_pfad      = tmp_destiny
*                  i_tdspoolid = wa_test-tdspoolid
*                  i_tdotftype = wa_test-tdotftype
*             IMPORTING
*                  o_filep     = wa_test-filep
*             EXCEPTIONS
*                  error       = 1
*                  no_spool    = 2
*                  OTHERS      = 3.
*        IF sy-subrc <> 0.
*          IF sy-msgid IS INITIAL.
*            MESSAGE e150(zcvn) WITH
*              wa_test-tdspoolid wa_test-tdotftype tmp_destiny
*              '' RAISING error.
*          ELSE.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                    RAISING error.
*          ENDIF.
*        ENDIF.
*
**       Datensatz updaten
**       bei Erfolg Spooleintrag löschen (mglw. an anderer Stelle)
*        DATA: rc TYPE rspotype-rc.
*        DATA: status LIKE sy-subrc.
*        DATA: spool_id TYPE tsp01_sp0r-rqid_char.
*        CLEAR status.
*        CLEAR rc.
*        CLEAR spool_id.
*        spool_id = wa_test-tdspoolid.
**        CALL FUNCTION 'RSPO_R_RDELETE_SPOOLREQ'
**             EXPORTING
**                  spoolid = spool_id
**             IMPORTING
**                  rc      = rc
**                  status  = status.
*        IF status NE 0.
*        ELSE.
*        ENDIF.
*      ELSE.
*      ENDIF.

      CASE wa_test-object_type.
        WHEN 'SPOOL'.
          "besondere Berücksichtigung für Einträge,
          "welche fertigungsrelevant sind
          "Erstellen von PDFs aus Spoolaufträgen
          "PDF erstellen
          CALL FUNCTION '/CIDEON/OTF_2_PDF'
            EXPORTING
              i_pfad      = tmp_destiny
              i_tdspoolid = wa_test-tdspoolid
              i_tdotftype = wa_test-tdotftype
            IMPORTING
              o_filep     = wa_test-filep
            EXCEPTIONS
              error       = 1
              no_spool    = 2
              OTHERS      = 3.
          IF sy-subrc <> 0.
            IF sy-msgid IS INITIAL.
              MESSAGE e150(zcvn) WITH
                wa_test-tdspoolid wa_test-tdotftype tmp_destiny
                '' RAISING error.
            ELSE.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      RAISING error.
            ENDIF.
          ENDIF.

*       Datensatz updaten
*       bei Erfolg Spooleintrag löschen (mglw. an anderer Stelle)
          DATA: rc TYPE rspotype-rc.
          DATA: status LIKE sy-subrc.
          DATA: spool_id TYPE tsp01_sp0r-rqid_char.
          CLEAR status.
          CLEAR rc.
          CLEAR spool_id.
          spool_id = wa_test-tdspoolid.
*        CALL FUNCTION 'RSPO_R_RDELETE_SPOOLREQ'
*             EXPORTING
*                  spoolid = spool_id
*             IMPORTING
*                  rc      = rc
*                  status  = status.
          IF status NE 0.
          ELSE.
          ENDIF.

        WHEN 'URL'.
          "URL benutzen zum Download

          DATA: lc_skip TYPE char1.
          CLEAR lc_skip.

          IF badi_main_pre_001 IS INITIAL.
          ELSE.
            CALL METHOD badi_main_pre_001->chg_clf_download_url
              CHANGING
                ls_job       = wa_test
                lc_down_path = tmp_destiny
                lc_skip      = lc_skip.

          ENDIF.

          IF lc_skip = 'X'.
          ELSE.

            DATA: lc_url_pf_path TYPE filep.
            DATA: lc_url_pfx_path TYPE filep.
            DATA: lc_url_pfx_file TYPE filep.

            CLEAR lc_url_pf_path.
            CLEAR lc_url_pfx_path.
            CLEAR lc_url_pfx_file.

            lc_url_pf_path = wa_test-url.

*          CALL FUNCTION 'CV120_SPLIT_PATH'
*               EXPORTING
*                    pf_path  = lc_url_pf_path
*               IMPORTING
*                    pfx_path = lc_url_pfx_path
*                    pfx_file = lc_url_pfx_file.
*
*          "tmp_destiny

            " CKR 2011/01/14
            " GUID holen
            "DATA: lc_guid TYPE guid_32.
            CLEAR lc_guid.
            CALL FUNCTION 'GUID_CREATE'
              IMPORTING
                ev_guid_32 = lc_guid.

            CONCATENATE lc_guid '.PDF'
              INTO lc_url_pfx_file.
            " CKR 2011/01/14 - Ende

            DATA: lc_absolute_uri TYPE filep.
            DATA: lc_document_path TYPE filep.

            CLEAR lc_absolute_uri.
            CLEAR lc_document_path.

            lc_absolute_uri = wa_test-url.
            lc_document_path = tmp_destiny.

            CONCATENATE lc_document_path lc_url_pfx_file
              INTO lc_document_path SEPARATED BY '\'.

            CALL FUNCTION 'HTTP_GET_FILE'
              EXPORTING
                absolute_uri                = lc_absolute_uri
*             RFC_DESTINATION             = 'SAPHTTP'
*             PROXY                       =
*             PROXY_USER                  =
*             PROXY_PASSWORD              =
*             USER                        =
*             PASSWORD                    =
                document_path               = lc_document_path
*             TIMEOUT                     =
*           IMPORTING
*             STATUS_CODE                 =
*             STATUS_TEXT                 =
*           TABLES
*             RESPONSE_HEADERS            =
              EXCEPTIONS
                connect_failed              = 1
                timeout                     = 2
                internal_error              = 3
                document_error              = 4
                tcpip_error                 = 5
                system_failure              = 6
                communication_failure       = 7
                OTHERS                      = 8
                      .
            IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ELSE.
              wa_test-filep = lc_document_path.
            ENDIF.

            wa_test-filep = lc_document_path.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.


      MOVE wa_test-filep TO lv_full_name.
      MOVE i_new_directory_name TO tmp_destiny.

      IF NOT ( lv_full_name IS INITIAL ).

        CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
          EXPORTING
            full_name     = lv_full_name
          IMPORTING
            stripped_name = lv_stripped_name
            file_path     = lv_file_path
          EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.

        IF sy-subrc <> 0.
          MESSAGE e036(zcvn) WITH '' RAISING error.
        ENDIF.

        CONCATENATE tmp_destiny '\' lv_stripped_name INTO tmp_destiny.

        MOVE lv_full_name TO tmp_obj_source.

        CONCATENATE text-081 ' ' tmp_destiny INTO lv_string.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 50
            text       = lv_string.

        CALL METHOD obj_frontend_services->file_copy
          EXPORTING
            SOURCE             = tmp_obj_source
            DESTINATION        = tmp_destiny
*           overwrite          = space
          EXCEPTIONS
            cntl_error         = 1
            error_no_gui       = 2
            wrong_parameter    = 3
            disk_full          = 4
            access_denied      = 5
            file_not_found     = 6
            destination_exists = 7
            unknown_error      = 8
            path_not_found     = 9
            disk_write_protect = 10
            drive_not_ready    = 11
            OTHERS             = 12
                .

        IF sy-subrc NE 0.
          IF wa_test-object_type = 'SPOOL'.
*           kein Kopieren notwendig -> Fehler vermeiden
          ELSE.
            " CKR 2010/01/08 Testen, ob Fehler deshalb kommt, weil
            " Dokument schon vorhanden ist

            IF sy-subrc = '8'.

              DATA: result TYPE abap_bool.

              CALL METHOD cl_gui_frontend_services=>file_exist
                EXPORTING
                  file            = tmp_destiny
                RECEIVING
                  result          = result
                EXCEPTIONS
                  cntl_error      = 1
                  error_no_gui    = 2
                  wrong_parameter = 3
                  OTHERS          = 4.
              IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              ENDIF.

              IF result = 'X'.
                "Datei vorhanden -> keine Fehler
              ELSE.
                MESSAGE s016(zcvn) WITH tmp_obj_source
                  " 'File not copied to'
                tmp_destiny '' ''. "RAISING error.

                SET PARAMETER ID 'Z_PL_VIEW_APPL_LOG' FIELD 'X'.
              ENDIF.

            ELSE.
              MESSAGE s016(zcvn) WITH tmp_obj_source
               " 'File not copied to'
                tmp_destiny '' ''. "RAISING error.

              SET PARAMETER ID 'Z_PL_VIEW_APPL_LOG' FIELD 'X'.

            ENDIF.




*         Loggen des Fehlers
            CLEAR return_log.
            return_log-type = 'A'.
            return_log-number = '002'.
            return_log-id = 'ZCL_PLOT_BASE'.
            return_log-message_v1 = tmp_obj_source.
            CONCATENATE wa_test-dokar wa_test-doknr wa_test-doktl
              wa_test-dokvr
              INTO return_log-message_v2
              SEPARATED BY '/'.
            "return_log-message_v2 = ''.
            return_log-message_v3 = tmp_destiny.
            return_log-message_v4 = 'ZCL_GET_DOC_CLF10_DETAIL_DLOAD'.

            CALL FUNCTION '/CIDEON/APPL_LOG_WRITE_2'
              EXPORTING
                i_object   = 'Z_CIDEON'
                i_subobj   = 'Z_PLOT'
                i_number   = return_log-number
                i_msgtyp   = return_log-type
                i_msgid    = return_log-id
                i_msgno    = return_log-number
                i_msgv1    = return_log-message_v1
                i_msgv2    = return_log-message_v2
                i_msgv3    = return_log-message_v3
                i_msgv4    = return_log-message_v4
                i_class    = ' '
                i_newhead  = 'X'
                i_messhead = 'X'
              EXCEPTIONS
                error      = 1
                OTHERS     = 2.
            IF sy-subrc <> 0.
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            COMMIT WORK.


          ENDIF.

        ENDIF.

        MOVE tmp_destiny TO e_new_path.

        MOVE tmp_destiny TO wa_bapi_doc_files2-docfile.
        CALL FUNCTION 'ZCL_PROC_SKEL_AOFILE_CLF10'
          EXPORTING
            wa_doc_files2    = wa_bapi_doc_files2
            lv_stripped_name = lv_stripped_name
            wa_test          = wa_test
          TABLES
            it_aofile        = it_aofile
            it_aofile_clf    = it_aofile_clf
            itab_stamps      = itab_stamps
          EXCEPTIONS
            error            = 1
            OTHERS           = 2.

        IF sy-subrc <> 0.
          MESSAGE e028(zcvn) WITH ao_naming.
        ENDIF.

      ELSE.

        CONCATENATE wa_test-dokar '_'
                    wa_test-doknr '_'
                    wa_test-dokvr '_'
                    wa_test-doktl '.txt' INTO ao_naming.

        CONCATENATE tmp_destiny lv_split_part1 '\'
                                        ao_naming INTO tmp_destiny.
      ENDIF.
    ENDIF.
  ELSE.
    e_new_path = i_downloaded_path.
    MOVE wa_test-filep TO e_last_path.
  ENDIF.
ENDFUNCTION.
