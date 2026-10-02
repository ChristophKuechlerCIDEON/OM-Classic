FUNCTION zcl_rfc_dload_clf_files_2_conv.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DEFAULT_USER) TYPE  XUBNAME OPTIONAL
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(I_CLF_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(FILTER) TYPE  C OPTIONAL
*"     VALUE(I_OUT_PROC) TYPE  C OPTIONAL
*"     VALUE(I_DELETE_ITEM) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_DELETE_STATUS) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_FORMAT_CHECKING) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_KNZ_USE_CONVERTE) TYPE  /CIDEON/KNZ_USE_CONVERTER
*"       DEFAULT ''
*"     VALUE(I_CONVERTER_NAME) TYPE  CONVERTER_NAME OPTIONAL
*"     VALUE(I_CONVERTER_NUMBER) TYPE  CONVERTER_NUMBER OPTIONAL
*"     VALUE(I_FTP_DESTINATION) TYPE  FTP_DESTINATION OPTIONAL
*"     VALUE(I_FTP_USER) TYPE  /CIDEON/FTP_USER OPTIONAL
*"     VALUE(I_FTP_PASSWD) TYPE  /CIDEON/FTP_PASSWD OPTIONAL
*"     VALUE(I_FTP_DOWN) TYPE  ZCL_KLIENT_DOWN_PFAD OPTIONAL
*"  EXPORTING
*"     VALUE(ERROR_MESSAGE) TYPE  MESSAGES
*"  TABLES
*"      ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"      ITAB_CLFLIST STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
* 30.01.2006 - Test auf leere CLF Datei
* 21.07.2006 - Änderung wegen Komponenten / noch nicht realisiert
*"----------------------------------------------------------------------

  DATA : wa_test             TYPE zcl_s_plotlist,
         wa_clflist          TYPE zcl_s_line_256,
         wa_converter_dests  TYPE converter,
         wa_document_key     TYPE conv_s_document_key.

  DATA : itab_group_clf10    TYPE TABLE OF zcl_s_line_256,
         itab_aofile_clf10   TYPE TABLE OF zcl_s_line_256,
         itab_clf_final_data TYPE TABLE OF zcl_s_line_256.

  DATA : wa_aofile_clf       TYPE zcl_s_line_256,
         it_aofile_clf       TYPE TABLE OF zcl_s_line_256.

  DATA : wa_converter        TYPE converter,
         it_converter        TYPE TABLE OF converter.

  DATA : wa_convert_spec     TYPE convert_spec,
         it_convert_spec     TYPE TABLE OF convert_spec.

  DATA : wa_cvapi_doc_file   TYPE cvapi_doc_file,
         it_cvapi_doc_file   TYPE TABLE OF cvapi_doc_file.

  DATA : wa_cvapi_doc_files2 TYPE cvapi_doc_file,
         it_cvapi_doc_files2 TYPE TABLE OF cvapi_doc_file.

  DATA : wa_bapi_doc_files   TYPE bapi_doc_files2,
         it_bapi_doc_files   TYPE TABLE OF bapi_doc_files2.

  DATA:  it_components TYPE TABLE OF bapi_doc_comp.
  DATA:  wa_components TYPE bapi_doc_comp.


  DATA : lv_exist            TYPE c,
         lv_isdir            TYPE c,
         lv_text_ele(12)     TYPE c,
         lv_path_length      TYPE i,
         lv_path_closing     TYPE c,
         lv_directory_sep    TYPE c,
         lv_file_name        TYPE filep,
         lv_rfc_clf_dir      TYPE filep,
         lv_rfc_files_dir    TYPE filep,
         lv_fname            TYPE char255,
         lv_result           TYPE abap_bool.

  DATA : lv_error_string(45) TYPE c,
         lv_return           TYPE bapiret2,
         lv_documentdata     TYPE bapi_doc_draw2.

  DATA : lv_year             LIKE rlgrap-filename,
         lv_today            LIKE rlgrap-filename,
         lv_timestamp        LIKE rlgrap-filename,
         lv_logic_file       LIKE rlgrap-filename.

  DATA : lv_file_path        LIKE rlgrap-filename,
         lv_full_name        LIKE rlgrap-filename,
         lv_x_filename       LIKE rlgrap-filename,
         lv_split_part1      LIKE rlgrap-filename,
         lv_split_part2      LIKE rlgrap-filename,
         lv_stripped_name    LIKE rlgrap-filename.

  DATA : lv_kpro_use         TYPE tdwa-kpro_use,
         lv_progid           TYPE rfcopt-rfcexec,
         lv_destination      TYPE rfcdes-rfcdest,
         lv_progname         TYPE rfcopt-rfcexec,
         lv_gwhost           TYPE rfcopt-rfcgwhost,
         lv_gwserv           TYPE rfcopt-rfcgwserv,
         lv_start_on         TYPE converter_destination.

  DATA : lv_sap_prog_text(100) TYPE c.
**********************************************************
*  SELECT SINGLE * FROM converter INTO wa_converter
*                              WHERE name        EQ i_converter_name
*                                AND conv_number EQ i_converter_number.

  SELECT * FROM converter INTO wa_converter
                              WHERE name        EQ i_converter_name
                                AND conv_number EQ i_converter_number.
  ENDSELECT.

  IF sy-subrc EQ 0.

*    MOVE wa_converter-name TO lv_progname.
    MOVE i_converter_name TO lv_progname.
    MOVE wa_converter-conv_util_dest TO lv_start_on.

    CONCATENATE text-090 i_converter_name
    INTO lv_sap_prog_text.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
              percentage = 50
              text       = lv_sap_prog_text.

    CLEAR error_message.
    CLEAR lv_destination.

    CALL FUNCTION 'CONV_UTIL_START_REG_SERVER'
         EXPORTING
              progname      = lv_progname
              startmode     = 'X'
              exclusiv      = 'Y'
              waittime      = 60
              startpara     = ' '
              start_on      = lv_start_on
         IMPORTING
              error_message = error_message
              destination   = lv_destination
         CHANGING
              gwhost        = lv_gwhost
              gwserv        = lv_gwserv
              progid        = lv_progid.

*    IF error_message-msg_type CA 'E'.
*      MESSAGE e060(zcvn) WITH lv_progname RAISING error.
*    ELSE.
*    ENDIF.

    CLEAR lv_sap_prog_text.

    CONCATENATE 'RFC Destination' i_converter_name 'Registiert..!'
       INTO lv_sap_prog_text.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
              percentage = 50
              text       = lv_sap_prog_text.
    CLEAR error_message.

    CALL FUNCTION 'CONV_UTIL_GET_DIR_SEP'
         EXPORTING
*             wa_converter  = wa_converter_dests
              wa_converter  = wa_converter
         IMPORTING
              directory_sep = lv_directory_sep
              error_message = error_message.

    CALL FUNCTION 'ZCL_UPLOAD_JOB_DATA_CLF10'
         EXPORTING
              user           = default_user
         TABLES
              o_jobdat_clf10 = itab_group_clf10
         EXCEPTIONS
              error          = 1
              OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE e099(zcvn) WITH 'ZCL_JOBDAT_CLF10' RAISING error.
    ENDIF.


    CALL FUNCTION 'ZCL_ULOAD_AOFILE_CLF10'
         EXPORTING
              user             = default_user
         TABLES
              o_aofile_clf_tab = itab_aofile_clf10
         EXCEPTIONS
              error            = 1
              OTHERS           = 2.

    IF sy-subrc <> 0.
      MESSAGE e099(zcvn) WITH 'ZCL_AOFILE_CLF10' RAISING error.
    ENDIF.

    CLEAR lv_x_filename.

* Get the CLF File name that has to be created , with
* the use of LOGICAL_FILENAME & PARAMETER_1.
    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        client                  = sy-mandt
        logical_filename        = 'ZZ_REPRO_CLF_STANDARD_NEW'
        operating_system        = sy-opsys
        parameter_1             = text-100
*       PARAMETER_2             = ' '
*       PARAMETER_3             = ' '
        use_presentation_server = 'X'
*       WITH_FILE_EXTENSION     = ' '
*       USE_BUFFER              = ' '
      IMPORTING
*       EMERGENCY_FLAG          =
*       FILE_FORMAT             =
        file_name               = lv_x_filename
      EXCEPTIONS
        file_not_found          = 1
        OTHERS                  = 2
              .
    IF sy-subrc <> 0.
      MESSAGE e018(zcvn) RAISING error.
    ENDIF.

    CLEAR lv_file_name.

*   Problem mit "." innerhalb eines Nutzernamens
    DATA: itab_split TYPE TABLE OF char255.
    DATA: wa_split TYPE char255.
    DATA: lines TYPE i.
    CLEAR itab_split.
    CLEAR wa_split.
    CLEAR lines.

    SPLIT lv_x_filename AT '.' INTO TABLE itab_split.
    DESCRIBE TABLE itab_split LINES lines.
    CLEAR lv_split_part1.
    CLEAR lv_split_part2.
    IF lines = 2.
      SPLIT lv_x_filename AT '.' INTO lv_split_part1 lv_split_part2.
    ELSE.
      LOOP AT itab_split INTO wa_split.
        IF sy-tabix = lines.
          lv_split_part2 = wa_split.
        ELSE.
          IF lv_split_part1 IS INITIAL.
            lv_split_part1 = wa_split.
          ELSE.
            CONCATENATE lv_split_part1 wa_split
              INTO lv_split_part1 SEPARATED BY '.'.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

*CKR  SPLIT lv_x_filename AT '.' INTO lv_split_part1 lv_split_part2.
*   Problem mit "." innerhalb eines Nutzernamens ENDE

    MOVE text-100 TO lv_text_ele.
    SPLIT lv_split_part1 AT lv_text_ele INTO lv_logic_file lv_timestamp.

    lv_today = lv_timestamp+0(8).
    lv_year  = lv_timestamp+0(4).

    lv_path_length  = strlen( i_down_path ).
    lv_path_length  = lv_path_length - 1.
    lv_path_closing = i_down_path+lv_path_length(1).

    IF lv_directory_sep EQ lv_path_closing.
      CONCATENATE i_down_path lv_year INTO lv_rfc_files_dir.
    ELSE.
      CONCATENATE i_down_path lv_directory_sep lv_year
                                      INTO lv_rfc_files_dir.
    ENDIF.

    CALL FUNCTION 'CONV_UTIL_CREATE_DIRECTORY'
         EXPORTING
              directory     = lv_rfc_files_dir
              wa_converter  = wa_converter
         IMPORTING
              error_message = error_message.

    IF error_message-msg_type CA 'E'.
      MESSAGE e010(zcvn) WITH lv_rfc_files_dir RAISING error.
    ELSE.
      CLEAR error_message.
    ENDIF.


    CONCATENATE lv_rfc_files_dir lv_directory_sep lv_today
                                        INTO lv_rfc_files_dir.

    CALL FUNCTION 'CONV_UTIL_CREATE_DIRECTORY'
         EXPORTING
              directory     = lv_rfc_files_dir
              wa_converter  = wa_converter
         IMPORTING
              error_message = error_message.

    IF error_message-msg_type CA 'E'.
      MESSAGE e010(zcvn) WITH lv_rfc_files_dir RAISING error.
    ELSE.
      CLEAR error_message.
    ENDIF.

    CONCATENATE lv_rfc_files_dir lv_directory_sep lv_split_part1
                                                  INTO lv_rfc_files_dir.

    CALL FUNCTION 'CONV_UTIL_CREATE_DIRECTORY'
         EXPORTING
              directory     = lv_rfc_files_dir
              wa_converter  = wa_converter
         IMPORTING
              error_message = error_message.

    IF error_message-msg_type CA 'E'.
      MESSAGE e010(zcvn) WITH lv_rfc_files_dir RAISING error.
    ELSE.
      CLEAR error_message.
    ENDIF.


    CALL FUNCTION 'ZCL_PROC_SKEL_GROUP_CLF10'
*     EXPORTING
*       wa_draw      = wa_test
      TABLES
        it_group     = itab_group_clf10
        it_group_clf = itab_clflist
      EXCEPTIONS
        error        = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE e098(zcvn) WITH 'ZCL_GROUP_CLF10' RAISING error.
    ENDIF.


*    LOOP AT itab_test INTO wa_test WHERE knz_use_checked_in NE space.
*    Commented by 'Mamillapalli' am 10.11.2003.

    LOOP AT itab_test INTO wa_test. "Modified on 10.11.2003..Sri
      CALL FUNCTION 'CVAPI_DOC_GETDETAIL'
        EXPORTING
*         PF_BATCHMODE          = ' '
*         PF_HOSTNAME           = ' '
          pf_dokar              = wa_test-dokar
          pf_doknr              = wa_test-doknr
          pf_dokvr              = wa_test-dokvr
          pf_doktl              = wa_test-doktl
*         PF_READ_DRAD          = ' '
*         PF_READ_DRAP          = ' '
*         PF_ACTIVE_FILES       = ' '
*         PF_READ_COMP          = ' '
*       IMPORTING
*         PSX_DRAW              =
*         PFX_DESCRIPTION       =
        TABLES
          pt_files              = it_cvapi_doc_file
*         PT_COMP               =
*         PT_DRAP               =
*         PT_DRAD               =
*         PT_DRAT               =
        EXCEPTIONS
          not_found             = 1
          no_auth               = 2
          error                 = 3
          OTHERS                = 4
                .

      IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      DATA : file_number TYPE dms_appnr.

*     Test, ob Dateiname in den am DIS enthalten Dateien
*     vorhanden ist
      DATA: dis_keys(36).

      LOOP AT it_cvapi_doc_file INTO wa_cvapi_doc_file
        WHERE filename = wa_test-filep.
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


      LOOP AT it_cvapi_doc_file INTO wa_cvapi_doc_file
        WHERE filename EQ wa_test-filep.

        CLEAR wa_document_key.
        MOVE wa_test-dokar TO wa_document_key-documenttype.
        MOVE wa_test-doknr TO wa_document_key-documentnumber.
        MOVE wa_test-doktl TO wa_document_key-documentpart.
        MOVE wa_test-dokvr TO wa_document_key-documentversion.

        MOVE wa_cvapi_doc_file-appnr TO file_number.


        CLEAR error_message.

        CALL FUNCTION 'CONV_UTIL_CHECK_KPRO_USE'
             EXPORTING
                  documenttype  = wa_test-dokar
             IMPORTING
                  error_message = error_message
                  kpro_use      = lv_kpro_use.

        IF NOT ( lv_kpro_use IS INITIAL ).

          IF wa_cvapi_doc_file-filename CS lv_directory_sep.


            CLEAR lv_full_name.
            CLEAR lv_stripped_name.
            CLEAR lv_file_path.

            MOVE wa_cvapi_doc_file-filename TO lv_full_name.

            CLEAR wa_cvapi_doc_file-filename.

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
*               MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ENDIF.

            CLEAR lv_file_path.

            CONCATENATE
                lv_rfc_files_dir lv_directory_sep lv_stripped_name
                                    INTO wa_cvapi_doc_file-filename.

            DATA : lv_doc_info(46) TYPE c.
            CLEAR lv_sap_prog_text.

            CONCATENATE wa_test-dokar '/' wa_test-doknr '/'
            INTO lv_doc_info.
            CONCATENATE  lv_doc_info wa_test-doktl '/' wa_test-dokvr
            INTO lv_doc_info.
           CONCATENATE 'Checkingout-' lv_doc_info '-to RFC Destination'
                                 INTO lv_sap_prog_text.
            CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                 EXPORTING
                      percentage = 50
                      text       = lv_sap_prog_text.

            CLEAR lv_file_path.
            CLEAR error_message.
            CLEAR lv_error_string.

            CALL FUNCTION 'CONV_CHECKOUT_TO_DESTINATION'
                 EXPORTING
                      document_key   = wa_document_key
                      original       = wa_cvapi_doc_file
                      kpro_use       = lv_kpro_use
                      ftp_dest       = wa_converter-ftp_dest
                      http_dest      = wa_converter-http_dest
                      conv_util_dest = wa_converter-conv_util_dest
                 IMPORTING
                      error_message  = error_message
                      file_name      = lv_file_name.



            IF wa_test-filep EQ lv_file_name.
*              MESSAGE e101(zcvn) . "Commented on 03.11.2003

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*                                        Modified on 10.11.2003 ..beginn
              DATA : tmp_lcl_path       LIKE rlgrap-filename,
                     tmp_downloadedpath TYPE filep.
*                     tmp_downloadedpath LIKE rlgrap-filename.

              MOVE wa_test-filep TO tmp_lcl_path.

              CALL FUNCTION 'ZCL_DLOAD_LOCAL_FILES_VIA_FTP'
                   EXPORTING
                        i_down_path          = i_down_path
                        local_file_path      = tmp_lcl_path
                        clf_file_name        = lv_x_filename
                        i_ftp_destination    = i_ftp_destination
                        i_ftp_user           = i_ftp_user
                        i_ftp_passwd         = i_ftp_passwd
                        i_ftp_down           = i_ftp_down
                   IMPORTING
                        downloaded_path      = tmp_downloadedpath
                   EXCEPTIONS
                        ftp_connection_error = 1
                        error                = 2
                        OTHERS               = 3.

              IF sy-subrc <> 0.
*                MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              ENDIF.

              MOVE tmp_downloadedpath TO lv_file_name.
*                                          Modified on 10.11.2003 ..ende
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

            ELSEIF error_message-msg_type CA 'E'.
              CONCATENATE wa_document_key-documenttype '\'
                          wa_document_key-documentnumber '\'
                          wa_document_key-documentpart   '\'
                          wa_document_key-documentversion '\'
                          wa_cvapi_doc_file-appnr INTO lv_error_string.

              MESSAGE e100(zcvn) WITH lv_error_string
                        wa_converter_dests-conv_util_dest
                                                  RAISING error.
            ELSE.
              CLEAR error_message.
            ENDIF.


            CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
              EXPORTING
                documenttype      = wa_document_key-documenttype
                documentnumber    = wa_document_key-documentnumber
                documentpart      = wa_document_key-documentpart
                documentversion   = wa_document_key-documentversion
*               GETOBJECTLINKS        = ' '
*               GETCOMPONENTS         = ' '
*               GETSTATUSLOG          = ' '
*               GETLONGTEXTS          = ' '
                getactivefiles        = 'X'
*               GETCLASSIFICATION     = ' '
*               GETSTRUCTURE          = ' '
*               GETWHEREUSED          = ' '
*               HOSTNAME              = ' '
              IMPORTING
                documentdata          = lv_documentdata
                return                = lv_return
              TABLES
*               OBJECTLINKS           =
*               DOCUMENTDESCRIPTIONS  =
*               LONGTEXTS     =
*               STATUSLOG     =
                documentfiles        = it_bapi_doc_files
*               COMPONENTS           =
*               CHARACTERISTICVALUES =
*               CLASSALLOCATIONS     =
*               DOCUMENTSTRUCTURE    =
*               WHEREUSEDLIST        =
                      .

            LOOP AT it_bapi_doc_files INTO wa_bapi_doc_files
                WHERE docfile EQ wa_test-filep.


              CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                   EXPORTING
                        percentage = 50
                        text       = text-120.

              CALL FUNCTION 'ZCL_PROC_SKEL_AOFILE_CLF10'
                   EXPORTING
                        wa_doc_files2    = wa_bapi_doc_files
                        lv_stripped_name = lv_stripped_name
                        wa_test          = wa_test
                        rfc_dest_path    = lv_file_name
                   TABLES
                        it_aofile        = itab_aofile_clf10
                        it_aofile_clf    = it_aofile_clf
                        itab_stamps      = itab_stamps
                   EXCEPTIONS
                        error            = 1
                        OTHERS           = 2.

              IF sy-subrc <> 0.
                MESSAGE e098(zcvn) WITH 'ZCL_AOFILE_CLF10'
                                                  RAISING error.
              ENDIF.
            ENDLOOP.


          ELSE.
            CLEAR lv_kpro_use.
            CLEAR error_message.

            CALL FUNCTION 'CONV_UTIL_LIST_ORIGINALS'
                 EXPORTING
                      document_key  = wa_document_key
                      active_files  = 'X'
                 IMPORTING
                      kpro_use      = lv_kpro_use
                      error_message = error_message
                 TABLES
                      lt_originals  = it_cvapi_doc_files2.

            LOOP AT it_cvapi_doc_files2 INTO wa_cvapi_doc_files2
             WHERE  appnr EQ file_number.

              MOVE wa_cvapi_doc_files2-filename TO lv_full_name.

              CLEAR wa_cvapi_doc_files2-filename.

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
                MESSAGE e094(zcvn) WITH lv_full_name RAISING error.
              ENDIF.

              CLEAR lv_file_path.

              CONCATENATE
                 lv_rfc_files_dir lv_directory_sep lv_stripped_name
                                  INTO wa_cvapi_doc_files2-filename.


              CLEAR lv_file_path.
              CLEAR error_message.

              CALL FUNCTION 'CONV_CHECKOUT_TO_DESTINATION'
                   EXPORTING
                        document_key   = wa_document_key
                        original       = wa_cvapi_doc_files2
                        kpro_use       = lv_kpro_use
                        ftp_dest       = wa_converter-ftp_dest
                        http_dest      = wa_converter-http_dest
                        conv_util_dest = wa_converter-conv_util_dest
                   IMPORTING
                        error_message  = error_message
                        file_name      = lv_file_name.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT itab_clflist INTO wa_clflist.
      IF wa_clflist CS '<%AOFILE_CLF10%>'.
        LOOP AT it_aofile_clf INTO wa_aofile_clf.
          APPEND wa_aofile_clf TO itab_clf_final_data.
        ENDLOOP.
      ELSE.
        APPEND wa_clflist TO itab_clf_final_data.
      ENDIF.
    ENDLOOP.

* Test auf leere oder unvollständige CLF Datei
* kein Eintrag für Dateinnamen als Testkriterium
* AO$_PATH
    DATA: f_found.
    CLEAR f_found.
    LOOP AT itab_clf_final_data INTO wa_clflist.
      IF wa_clflist CS 'AO$_PATH'.
        f_found = 'X'.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.
    IF f_found = 'X'.
    ELSE.
      MESSAGE e034(zcvn) RAISING error.
    ENDIF.


    IF NOT ( itab_clf_final_data IS INITIAL ).

*      CALL FUNCTION 'ZCL_PROCESS_RFC_CLF_FILE_DATA'
*           EXPORTING
*                wa_converter_dests  = wa_converter
*                dir_separater       = lv_directory_sep
*                clf_file_name       = lv_x_filename
*                i_clf_down_path     = i_clf_down_path
*           TABLES
*                itab_clf_final_data = itab_clf_final_data
*                it_convert_spec     = it_convert_spec
*           EXCEPTIONS
*                error               = 1
*                OTHERS              = 2.
*
*      IF sy-subrc <> 0.
*        MESSAGE e062(zcvn) .
*      ENDIF.

      DATA : errmsg(120)       TYPE c,
             rfc_clf_down_path TYPE rlgrap-filename.

      CONCATENATE i_clf_down_path lv_x_filename INTO rfc_clf_down_path.

      CALL FUNCTION 'RFC_REMOTE_FILE'
        DESTINATION
          wa_converter-conv_dest
        EXPORTING
          file = rfc_clf_down_path
          write = 'X' "X=write <space>=read
        TABLES
          filedata = itab_clf_final_data
        EXCEPTIONS
          system_failure        = 1 MESSAGE errmsg
          communication_failure = 2 MESSAGE errmsg.

      IF sy-subrc NE 0.
        MESSAGE e102(zcvn) WITH errmsg RAISING error.
      ENDIF.

    ELSE.
      MESSAGE e097(zcvn) WITH 'ZCL_PROCESS_RFC_CLF_FILE_DATA'
                                                    RAISING error.

    ENDIF.


*   Stop Regestration of the RFC Server.
    DATA : err_code LIKE  sy-index,
           err_mess LIKE  sy-lisel.
    CALL FUNCTION 'SYSTEM_STOP_REG_SERVER'
         EXPORTING
              destination = lv_destination
         IMPORTING
              err_code    = err_code
              err_mess    = err_mess.

  ELSE.
    MESSAGE e096(zcvn) WITH lv_destination RAISING error.
  ENDIF.

ENDFUNCTION.
