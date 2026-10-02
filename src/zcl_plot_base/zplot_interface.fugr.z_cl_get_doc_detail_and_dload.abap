FUNCTION z_cl_get_doc_detail_and_dload .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NEW_DIRECTORY_NAME) TYPE  STRING OPTIONAL
*"     VALUE(WA_TEST) TYPE  ZCL_S_PLOTLIST OPTIONAL
*"     VALUE(I_LAST_PATH) TYPE  FILEP OPTIONAL
*"     VALUE(I_DOWNLOADED_PATH) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(E_NEW_PATH) TYPE  STRING
*"     VALUE(E_LAST_PATH) TYPE  FILEP
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.
  DATA : itab_bapi_doc_files2 TYPE bapi_doc_files2 OCCURS 0,
         itab2_bapi_doc_files2 TYPE bapi_doc_files2 OCCURS 0,
         wa2_bapi_doc_files2 TYPE bapi_doc_files2 ,
         itab_bapi_doc_draw2 TYPE bapi_doc_draw2,
         itab_bapiret2 TYPE bapiret2,
         wa_bapi_doc_files2 TYPE bapi_doc_files2 ,
         lv_string(200) TYPE c,
         ao_naming(60) TYPE c,
         lv_last_path TYPE filep.

  DATA : lv_stripped_name LIKE rlgrap-filename,
         lv_file_path     LIKE rlgrap-filename,
         lv_full_name     LIKE rlgrap-filename.

  DATA : i_down_path    LIKE rlgrap-filename,
         lv_split_part1 LIKE rlgrap-filename.

  DATA : flag_checked_in TYPE c.

  DATA: return TYPE bapiret2.

  DATA : tmp_bapi_check_path TYPE bapi_doc_aux-filename.

  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ENDIF.

*  IF NOT ( lv_last_path IS space ).
*    GET PARAMETER ID 'LLP' FIELD lv_last_path.
*  ELSE.
*  ENDIF.

  IF wa_test-filep NE i_last_path.

*DATA REPID like sy-repid VALUE 'RSPFPAR'.
*SET PARAMETER ID 'RID' FIELD REPID.

    MOVE wa_test-filep TO lv_last_path.

*    TRANSLATE lv_last_path TO UPPER CASE.

    MOVE lv_last_path TO e_last_path.

*    SET PARAMETER ID 'LLP' FIELD lv_last_path.

*    IF NOT ( wa_test-checked IS INITIAL ).

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
      DATA: dis_keys(36).

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



*        LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2
*                                        WHERE docfile = wa_test-filep.

      LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2.
*        TRANSLATE wa_bapi_doc_files2 TO UPPER CASE.

        IF wa_bapi_doc_files2-docfile = wa_test-filep.

          MOVE wa_bapi_doc_files2-docfile TO lv_full_name.

********* kommentiert. am 4.11.2002.....Begin
*          IF ( lv_full_name CS '\' AND lv_full_name CS '.' ).
*            CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*                 EXPORTING
*                      full_name     = lv_full_name
*                 IMPORTING
*                      stripped_name = lv_stripped_name
*                      file_path     = lv_file_path
*                 EXCEPTIONS
*                      x_error       = 1
*                      OTHERS        = 2.
*            IF sy-subrc <> 0.
**             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*            ENDIF.
*          ELSE.
*          ENDIF.
********* kommentiert. am 4.11.2002.....Beendet

*       Temporary Variable to accept filepath.
          CLEAR tmp_bapi_check_path .

         CONCATENATE i_new_directory_name '\' INTO tmp_bapi_check_path .

          CLEAR itab2_bapi_doc_files2.
          "REFRESH itab2_bapi_doc_files2. " ck 31.03.2003

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
               EXPORTING
                    percentage = 30
                    text       = lv_string.

          CLEAR return.

*       If the Original File is Checkedin Download by using
*       below BAPI_* Function Module.
          CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
               EXPORTING
                    documenttype        = wa_test-dokar
                    documentnumber      = wa_test-doknr
                    documentpart        = wa_test-doktl
                    documentversion     = wa_test-dokvr
                    documentfile        = wa_bapi_doc_files2
                    getstructure        = '1'
*                 getcomponents       = 'X'
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
                    .

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
               EXPORTING
                    percentage = 30
                    text       = lv_string.

          IF return IS INITIAL.
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

*  Modification on 24.10.2002 begin..

      LOOP AT itab2_bapi_doc_files2 INTO wa2_bapi_doc_files2.
        MOVE wa2_bapi_doc_files2-docfile TO e_new_path.
      ENDLOOP.
*     CONCATENATE tmp_bapi_check_path lv_stripped_name INTO e_new_path.

*  Modification on 24.10.2002 ende..


*      MOVE tmp_bapi_check_path TO e_new_path.               "10.10.2002
      CLEAR lv_full_name.
      CLEAR lv_stripped_name.
      CLEAR lv_file_path.

******************** Modified on 05.05.2003 Beginen
*    ELSEIF wa_test-checked NE space. " Geändert am 16.09.2003
    ELSEIF wa_test-knz_use_checked_in NE space.


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


*        LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2
*                                        WHERE docfile = wa_test-filep.

      LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2.
*        TRANSLATE wa_bapi_doc_files2 TO UPPER CASE.

        IF wa_bapi_doc_files2-docfile = wa_test-filep.

          MOVE wa_bapi_doc_files2-docfile TO lv_full_name.

*       Temporary Variable to accept filepath.
          CLEAR tmp_bapi_check_path.

         CONCATENATE i_new_directory_name '\' INTO tmp_bapi_check_path .

          CLEAR itab2_bapi_doc_files2.
          "REFRESH itab2_bapi_doc_files2. " ck 31.03.2003

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
               EXPORTING
                    percentage = 30
                    text       = lv_string.

          CLEAR return.

*       If the Original File is Checkedin Download by using
*       below BAPI_* Function Module.
          CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
               EXPORTING
                    documenttype        = wa_test-dokar
                    documentnumber      = wa_test-doknr
                    documentpart        = wa_test-doktl
                    documentversion     = wa_test-dokvr
                    documentfile        = wa_bapi_doc_files2
                    getstructure        = '1'
*                 getcomponents       = 'X'
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
                    .

          CONCATENATE text-079 ' ' tmp_bapi_check_path INTO lv_string.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
               EXPORTING
                    percentage = 30
                    text       = lv_string.

          IF return IS INITIAL.
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

*  Modification on 24.10.2002 begin..

      LOOP AT itab2_bapi_doc_files2 INTO wa2_bapi_doc_files2.
        MOVE wa2_bapi_doc_files2-docfile TO e_new_path.
      ENDLOOP.
*     CONCATENATE tmp_bapi_check_path lv_stripped_name INTO e_new_path.

*  Modification on 24.10.2002 ende..


*      MOVE tmp_bapi_check_path TO e_new_path.               "10.10.2002
      CLEAR lv_full_name.
      CLEAR lv_stripped_name.
      CLEAR lv_file_path.

******************** Modified on 05.05.2003 ende
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
*        MOVE i_down_path TO tmp_destiny.
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
            source             = tmp_obj_source
            destination        = tmp_destiny
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
*        IF sy-subrc EQ 6.
*          MESSAGE i016(zcvn) WITH tmp_obj_source
*          '->file not available in local' '' '' . "RAISING error.
*        ELSE.
        IF sy-subrc <> 0.
          MESSAGE s016(zcvn) WITH tmp_obj_source 'File not copied to'
          tmp_destiny '' . "RAISING error.
        ENDIF.

        MOVE tmp_destiny TO e_new_path.                     "10.10.2002


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
*    MOVE wa_test-filep TO i_last_path.
  ENDIF.

*  ENDLOOP.
ENDFUNCTION.
