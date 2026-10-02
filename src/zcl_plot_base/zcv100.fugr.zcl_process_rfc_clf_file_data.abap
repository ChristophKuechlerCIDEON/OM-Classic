FUNCTION zcl_process_rfc_clf_file_data.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DIR_SEPARATER) TYPE  C
*"     REFERENCE(WA_CONVERTER_DESTS) TYPE  CONVERTER
*"     REFERENCE(CLF_FILE_NAME) TYPE  RLGRAP-FILENAME
*"     REFERENCE(I_CLF_DOWN_PATH) TYPE  STRING
*"  TABLES
*"      IT_CONVERT_SPEC STRUCTURE  CONVERT_SPEC OPTIONAL
*"      ITAB_CLF_FINAL_DATA STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  DATA : wa_cvapi_doc_file TYPE          cvapi_doc_file,
         it_cvapi_doc_file TYPE TABLE OF cvapi_doc_file.

  DATA : wa_draw TYPE          draw,
         it_draw TYPE TABLE OF draw.

  DATA : wa_doc_files TYPE          bapi_doc_files2,
         it_doc_files TYPE TABLE OF bapi_doc_files2.

  DATA : wa_doc_files1 TYPE          bapi_doc_files2,
         it_doc_files1 TYPE TABLE OF bapi_doc_files2.

  DATA : wa_convert_spec TYPE convert_spec,
         wa_bapi_doc_aux TYPE bapi_doc_aux,
         wa_document_key TYPE conv_s_document_key.

  DATA : data_table TYPE STANDARD TABLE OF zcl_s_line_256.

  DATA : lv_filelength   TYPE i,
         lv_kpro_use     TYPE c,
         lv_path_length  TYPE i,
         lv_path_closing TYPE c,
         lv_file_name    TYPE filep,
         lv_rfc_clfs_dir TYPE filep,
         download_path   TYPE string,
         return          TYPE bapiret2,
         error_message   TYPE messages,
         documentdata    TYPE bapi_doc_draw2.

  DATA : lv_doctype    LIKE bapi_doc_aux-doctype,
         lv_docnumber  LIKE bapi_doc_aux-docnumber,
         lv_docpart    LIKE bapi_doc_aux-docpart,
         lv_docversion LIKE bapi_doc_aux-docversion.

***********************************

  SELECT * FROM draw INTO TABLE it_draw
      WHERE  dokar = 'DWK'
      AND    doknr = 'RFC_FLAT_FILE'
      AND    doktl = '000'
      AND    dokvr = '00'.

  IF sy-subrc EQ 0.
    LOOP AT itab_clf_final_data .

      APPEND itab_clf_final_data TO data_table.

    ENDLOOP.
  ENDIF.

  LOOP AT it_draw INTO wa_draw.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
              percentage = 50
              text       = 'Sending CLF Data to RFC Destination'.

    MOVE wa_draw-dokar TO lv_doctype.
    MOVE wa_draw-doknr TO lv_docnumber.
    MOVE wa_draw-doktl TO lv_docpart.
    MOVE wa_draw-dokvr TO lv_docversion.

    CREATE OBJECT obj_frontend_services.

    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = lv_doctype
        documentnumber             = lv_docnumber
        documentpart               = lv_docpart
        documentversion            = lv_docversion
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
        getactivefiles             = 'X'
*       GETCLASSIFICATION          = ' '
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
      IMPORTING
        documentdata               = documentdata
        return                     = return
      TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
        documentfiles              = it_doc_files
*       COMPONENTS                 =
*       CHARACTERISTICVALUES       =
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
              .

    LOOP AT it_doc_files INTO wa_doc_files.

      CLEAR return.

      CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
        EXPORTING
        documenttype               = lv_doctype
        documentnumber             = lv_docnumber
        documentpart               = lv_docpart
        documentversion            = lv_docversion
        documentfile               = wa_doc_files
*         GETSTRUCTURE              = '1'
*         GETCOMPONENTS             = 'X'
*         originalpath              =
*         HOSTNAME                  = ' '
*         GETHEADER                 = 'X'
*         DOCBOMCHANGENUMBER        =
*         DOCBOMVALIDFROM           =
*         DOCBOMREVISIONLEVEL       =
        IMPORTING
          return                    = return
        TABLES
*         DOCUMENTSTRUCTURE         =
          documentfiles             = it_doc_files1
*         COMPONENTS                =
                .

      LOOP AT it_doc_files1 INTO wa_doc_files1.

        MOVE wa_doc_files1-docfile TO download_path.


        CALL METHOD obj_frontend_services->gui_download
          EXPORTING
*           BIN_FILESIZE            =
            filename                = download_path
            filetype                = 'ASC'
*           APPEND                  = SPACE
*           WRITE_FIELD_SEPARATOR   = SPACE
*           HEADER                  = '00'
*           TRUNC_TRAILING_BLANKS   = SPACE
*           WRITE_LF                = 'X'
*           COL_SELECT              = SPACE
*           COL_SELECT_MASK         = SPACE
         IMPORTING
           filelength              = lv_filelength
          CHANGING
            data_tab                = data_table
*         EXCEPTIONS
*           FILE_WRITE_ERROR        = 1
*           NO_BATCH                = 2
*           GUI_REFUSE_FILETRANSFER = 3
*           INVALID_TYPE            = 4
*           NO_AUTHORITY            = 5
*           UNKNOWN_ERROR           = 6
*           HEADER_NOT_ALLOWED      = 7
*           SEPARATOR_NOT_ALLOWED   = 8
*           FILESIZE_NOT_ALLOWED    = 9
*           HEADER_TOO_LONG         = 10
*           DP_ERROR_CREATE         = 11
*           DP_ERROR_SEND           = 12
*           DP_ERROR_WRITE          = 13
*           UNKNOWN_DP_ERROR        = 14
*           ACCESS_DENIED           = 15
*           DP_OUT_OF_MEMORY        = 16
*           DISK_FULL               = 17
*           DP_TIMEOUT              = 18
*           FILE_NOT_FOUND          = 19
*           DATAPROVIDER_EXCEPTION  = 20
*           CONTROL_FLUSH_ERROR     = 21
*           others                  = 22
                .

        IF NOT ( lv_filelength IS INITIAL ).

          CLEAR return.

          CALL FUNCTION 'BAPI_DOCUMENT_CHECKIN_REPLACE2'
            EXPORTING
              documenttype               = lv_doctype
              documentnumber             = lv_docnumber
              documentpart               = lv_docpart
              documentversion            = lv_docversion
*             HOSTNAME                = ' '
*             STATUSINTERN            = ' '
*             STATUSEXTERN            = ' '
*             STATUSLOG               = ' '
*             REVLEVEL                = ' '
*             AENNR                   = ' '
            IMPORTING
              return                  = return
            TABLES
              documentfiles           = it_doc_files1
*             COMPONENTS              =
*             DOCUMENTSTRUCTURE       =
                    .

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait   = 'X'
            IMPORTING
              return = return.

          IF NOT ( return IS INITIAL ).
            MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ELSE.
            CLEAR wa_document_key.
            MOVE wa_draw-dokar TO wa_document_key-documenttype.
            MOVE wa_draw-doknr TO wa_document_key-documentnumber.
            MOVE wa_draw-doktl TO wa_document_key-documentpart.
            MOVE wa_draw-dokvr TO wa_document_key-documentversion.

            MOVE i_clf_down_path TO lv_rfc_clfs_dir.

            CLEAR error_message.
            CALL FUNCTION 'CONV_UTIL_CHECK_KPRO_USE'
                 EXPORTING
                      documenttype  = wa_draw-dokar
                 IMPORTING
                      error_message = error_message
                      kpro_use      = lv_kpro_use.

            IF NOT ( lv_kpro_use IS INITIAL ).

              CALL FUNCTION 'CVAPI_DOC_GETDETAIL'
                EXPORTING
*               PF_BATCHMODE          = ' '
*               PF_HOSTNAME           = ' '
                  pf_dokar              = wa_draw-dokar
                  pf_doknr              = wa_draw-doknr
                  pf_dokvr              = wa_draw-dokvr
                  pf_doktl              = wa_draw-doktl
*               PF_READ_DRAD          = ' '
*               PF_READ_DRAP          = ' '
*               PF_ACTIVE_FILES       = ' '
*               PF_READ_COMP          = ' '
*             IMPORTING
*               PSX_DRAW              =
*               PFX_DESCRIPTION       =
               TABLES
                 pt_files              = it_cvapi_doc_file
*               PT_COMP               =
*               PT_DRAP               =
*               PT_DRAD               =
*               PT_DRAT               =
*             EXCEPTIONS
*               not_found             = 1
*               no_auth               = 2
*               error                 = 3
*               OTHERS                = 4
                        .
              IF sy-subrc <> 0.
*               MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
              ENDIF.


              LOOP AT it_cvapi_doc_file INTO wa_cvapi_doc_file.

                lv_path_length  = strlen( i_clf_down_path ).
                lv_path_length  = lv_path_length - 1.
                lv_path_closing = i_clf_down_path+lv_path_length(1).

                IF dir_separater EQ lv_path_closing.
                  CONCATENATE lv_rfc_clfs_dir clf_file_name
                                        INTO wa_cvapi_doc_file-filename.
                ELSE.
                CONCATENATE lv_rfc_clfs_dir dir_separater clf_file_name
                                        INTO wa_cvapi_doc_file-filename.
                ENDIF.

                CONCATENATE lv_rfc_clfs_dir clf_file_name
                                       INTO wa_cvapi_doc_file-filename.

                CLEAR lv_file_name.
                CLEAR error_message.

                CALL FUNCTION 'CONV_CHECKOUT_TO_DESTINATION'
                  EXPORTING
                    document_key   = wa_document_key
                    original       = wa_cvapi_doc_file
                    kpro_use       = lv_kpro_use
                    ftp_dest       = wa_converter_dests-ftp_dest
                    http_dest      = wa_converter_dests-http_dest
                    conv_util_dest = wa_converter_dests-conv_util_dest
                  IMPORTING
                    error_message  = error_message
                    file_name      = lv_file_name.

                IF error_message-msg_type NA 'E'.
                  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                     EXPORTING
                        percentage = 50
                       text = 'Sending CLF Data to RFC Destination..OK'.

                ENDIF.


              ENDLOOP.

            ENDIF.
          ENDIF.
        ELSE.
        ENDIF.


      ENDLOOP.

    ENDLOOP.

  ENDLOOP.

ENDFUNCTION.
