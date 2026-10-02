*&---------------------------------------------------------------------*
*& Report  ZCL_LISTING_OR_DLOAD_ORI_FILES                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author der Änderungen:  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 09.10.2003 - Änderung
* 06.07.2006 - Ändeurngen wegen UNICODE
*-----------------------------------------------------------------------

REPORT  zcl_listing_or_dload_ori_files NO STANDARD PAGE HEADING.

* General Variable(S)....
DATA : lv_return            TYPE i,
       lv_flag              TYPE c,
       lv_log_flag          TYPE c,
       lv_answer            TYPE c,
       lv_draw_string(36)   TYPE c,
       lv_counter(5)        TYPE c,
       lv_exist             TYPE c,
       lv_source            LIKE rlgrap-filename,
       lv_dokar_dir         LIKE rlgrap-filename,
       lv_doar_nr_vr_tl_dir LIKE rlgrap-filename,
       lv_bapi_nr_vr_tl_dir LIKE rlgrap-filename,
       lv_selected_folder   LIKE rlgrap-filename,
       lv_stripped_name     LIKE rlgrap-filename,
       lv_file_path         LIKE rlgrap-filename,
       lv_log_file          LIKE rlgrap-filename,
       lv_log_file_cid2     LIKE rlgrap-filename,
       lv_bapi_check_path   LIKE bapi_doc_aux-filename.

DATA : lv_initial_folder LIKE rlgrap-filename
                  VALUE 'C:\'.

* Internal Table(S)....
DATA : itab_draw            TYPE TABLE OF draw,
       itab_zori_doc_files  TYPE TABLE OF zori_doc_files,
       itab_bapi_doc_files2 TYPE TABLE OF bapi_doc_files2,
       itab_documentfiles   TYPE TABLE OF bapi_doc_files2,
       itab_fail_documents  TYPE TABLE OF zcl_s_fail_document.

DATA : itab_bapiret2 TYPE bapiret2.

* Working Area(S).........
DATA : wa_draw              TYPE draw,
       wa_zori_doc_files    TYPE zori_doc_files,
       wa_bapi_doc_files2   TYPE bapi_doc_files2,
       wa_documentfiles     TYPE bapi_doc_files2,
       wa_fail_documents    TYPE "bapi_doc_files2
       zcl_s_fail_document.

DATA : BEGIN OF tab_cid2 ,
           number LIKE bapi_doc_files2-originaltype,
           filename LIKE bapi_doc_files2-docfile,
        END OF tab_cid2.

DATA : itab_tab_cid2 LIKE TABLE OF tab_cid2,
       wa_tab_cid2   LIKE tab_cid2.



************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_check AS CHECKBOX.
PARAMETERS: p_list  RADIOBUTTON GROUP prog DEFAULT 'X' .
PARAMETERS: p_down  RADIOBUTTON GROUP prog  .
SELECTION-SCREEN END OF BLOCK bl1.



INITIALIZATION.

AT SELECTION-SCREEN.

START-OF-SELECTION.

  IF p_check = 'X'.
    IF p_list = 'X'.
      lv_answer = '1'.
    ELSE.
      lv_answer = '2'.
    ENDIF.

    CALL FUNCTION 'CV100_DOC_SEARCH'
     EXPORTING
       pf_cv04_list_type       = '2'
*  PF_WEB_LIST_TYPE        =
       api_flag                = 'X'
     TABLES
       ptx_draw                = itab_draw
              .

    IF itab_draw IS INITIAL.
    ELSE.

      CALL FUNCTION 'Z_DMS_PROC_DOC_FILES'
*    EXPORTING
*      CALLED_FROM              = ''
*      TESTMODE                 = ''
       TABLES
         it_zori_doc_files        = itab_zori_doc_files
         it_bapi_doc_files2       = itab_bapi_doc_files2
         tdraw                    = itab_draw
*      ITAB_FILETYPE            =
         it_fail_document           = itab_fail_documents
       EXCEPTIONS
         error                    = 1
         abort                    = 2
         OTHERS                   = 3
         .

      IF sy-subrc <> 0.
        MESSAGE e006(zcvn) .
      ENDIF.
    ENDIF.

    IF  lv_answer = '2'.
      IF lv_flag IS INITIAL.

        CLEAR lv_exist.

        CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
          EXPORTING
            fname                = lv_initial_folder
         IMPORTING
           exist                = lv_exist
*          ISDIR                =
*          FILESIZE             =
*       EXCEPTIONS
*          FILEINFO_ERROR       = 1
*          OTHERS               = 2
                  .

        IF lv_exist IS INITIAL.
          CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
            EXPORTING
              dirname  = lv_initial_folder
              no_flush = 'X'
            EXCEPTIONS
              failed   = 1
              OTHERS   = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER
            sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.



        CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
          EXPORTING
            window_title    = text-010
            initial_folder  = lv_initial_folder
          IMPORTING
            selected_folder = lv_selected_folder
          EXCEPTIONS
            cntl_error      = 1
            OTHERS          = 2.
        IF sy-subrc <> 0.
          MESSAGE e007(zcvn) .
        ENDIF.
        lv_flag = 'X'.

        IF lv_selected_folder IS INITIAL.
          EXIT.
        ELSE.
        ENDIF.

      ENDIF.
    ENDIF.

    DATA: max_lines TYPE i.
    DATA: akt_line TYPE i.
    DATA: f TYPE f.
    DATA: proz(5).
    DATA: proz_i TYPE i.
    DESCRIBE TABLE itab_draw LINES max_lines.

    IF max_lines = 0.
      f = 0.
    ELSE.
      f = 100 / max_lines .
    ENDIF.
    CLEAR akt_line.

*****
    WRITE : / 'The documents available for the selection criteria'.
    ULINE.
*****
    LOOP AT itab_draw INTO wa_draw.

      akt_line = akt_line + 1.
      proz_i = TRUNC( f * akt_line ).
      proz = proz_i.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = proz  " Balkenanzeige
          text       = wa_draw-doknr.


      CLEAR lv_draw_string.
      CLEAR lv_log_flag.
      CLEAR itab_tab_cid2.


      lv_counter = lv_counter + 1 .

      CONCATENATE wa_draw-dokar '_'
                  wa_draw-doknr '_'
                  wa_draw-dokvr '_'
                  wa_draw-doktl INTO lv_draw_string.

      SKIP.

*      WRITE :/ lv_counter,')', lv_draw_string.
      WRITE:  lv_counter, wa_draw-dokar, wa_draw-doknr,
        wa_draw-doktl, wa_draw-dokvr.

      LOOP AT itab_fail_documents INTO wa_fail_documents
            WHERE dokar = wa_draw-dokar
            AND doknr = wa_draw-doknr
            AND dokvr = wa_draw-dokvr
            AND doktl = wa_draw-doktl.

        WRITE : /
          '      ****** No Original documents are available*****'
                               INPUT ON.

      ENDLOOP.

      IF  lv_answer = '2'.

        CLEAR lv_log_file.

        LOOP AT itab_bapi_doc_files2 INTO wa_bapi_doc_files2 WHERE
                                     documenttype    = wa_draw-dokar
                                 AND documentnumber  = wa_draw-doknr
                                 AND documentversion = wa_draw-dokvr
                                 AND documentpart    = wa_draw-doktl .

          CONCATENATE lv_selected_folder '\' wa_draw-dokar
          INTO lv_dokar_dir.

*  Directory with the DOKAR name...............
          CLEAR lv_exist.
          CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
               EXPORTING
                    fname          = lv_dokar_dir
               IMPORTING
                    exist          = lv_exist
*                   isdir          =
*                   filesize       =
*               EXCEPTIONS
*                    fileinfo_error = 1
*                    OTHERS         = 2
                    .
          IF lv_exist IS INITIAL.
            CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
              EXPORTING
                dirname  = lv_dokar_dir
                no_flush = 'X'
              EXCEPTIONS
                failed   = 1
                OTHERS   = 2.
            IF sy-subrc <> 0.
              MESSAGE e008(zcvn) WITH lv_dokar_dir.
            ENDIF.
          ENDIF.

          CONCATENATE lv_dokar_dir '\' lv_draw_string
                                INTO lv_doar_nr_vr_tl_dir.
          CLEAR lv_exist.


*   Directory with naming as DOKAR_DOKNR_DOKVR_DOKTL.
          CLEAR  lv_exist.
          CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
               EXPORTING
                    fname          = lv_doar_nr_vr_tl_dir
               IMPORTING
                    exist          = lv_exist
*                    isdir          =
*                    filesize       =
*               EXCEPTIONS
*                    fileinfo_error = 1
*                    OTHERS         = 2
                     .
          IF lv_exist IS INITIAL.
            CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
              EXPORTING
                dirname  = lv_doar_nr_vr_tl_dir
                no_flush = 'X'
              EXCEPTIONS
                failed   = 1
                OTHERS   = 2.
            IF sy-subrc <> 0.
              MESSAGE e008(zcvn) WITH lv_dokar_dir.
            ENDIF.
          ENDIF.

          CONCATENATE lv_doar_nr_vr_tl_dir '\' INTO lv_bapi_check_path.

          MOVE wa_bapi_doc_files2-docfile TO lv_bapi_nr_vr_tl_dir.

          IF NOT ( lv_bapi_nr_vr_tl_dir IS INITIAL )
                 AND ( lv_bapi_nr_vr_tl_dir CS '\' )
                 AND ( lv_bapi_nr_vr_tl_dir CS '.' ).

            CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
              EXPORTING
                full_name     = lv_bapi_nr_vr_tl_dir
              IMPORTING
                stripped_name = lv_stripped_name
                file_path     = lv_file_path
              EXCEPTIONS
                x_error       = 1
                OTHERS        = 2.
            IF sy-subrc EQ 0.
              CONCATENATE lv_bapi_nr_vr_tl_dir '\' lv_stripped_name
                            INTO lv_bapi_nr_vr_tl_dir.
            ENDIF.
          ENDIF.

          CLEAR lv_exist.

          CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
            EXPORTING
              fname                = lv_bapi_nr_vr_tl_dir
           IMPORTING
              exist                = lv_exist
*             ISDIR                =
*             FILESIZE             =
*           EXCEPTIONS
*             FILEINFO_ERROR       = 1
*             OTHERS               = 2
                    .
          IF ( lv_exist IS INITIAL ) AND
                  NOT ( wa_bapi_doc_files2-checkedin IS INITIAL ).

            CLEAR itab_bapiret2.

            CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
              EXPORTING
                documenttype              = wa_draw-dokar
                documentnumber            = wa_draw-doknr
                documentpart              = wa_draw-doktl
                documentversion           = wa_draw-dokvr
                documentfile              = wa_bapi_doc_files2
*               GETSTRUCTURE              = '1'
*               GETCOMPONENTS             = 'X'
                originalpath              = lv_bapi_check_path
*               HOSTNAME                  = ' '
                getheader                 = 'X'
*               DOCBOMCHANGENUMBER        =
*               DOCBOMVALIDFROM           =
*               DOCBOMREVISIONLEVEL       =
              IMPORTING
                return                    = itab_bapiret2
              TABLES
*               DOCUMENTSTRUCTURE         =
                documentfiles             = itab_documentfiles
*               COMPONENTS                =
                      .

            IF itab_bapiret2 IS INITIAL.
            ELSE.
              WRITE: / itab_bapiret2-message.
            ENDIF.

            IF NOT ( itab_documentfiles IS INITIAL ).
              SHIFT wa_bapi_doc_files2-docfile RIGHT BY 20 PLACES.
              WRITE :  wa_bapi_doc_files2-docfile.

              LOOP AT itab_documentfiles INTO wa_documentfiles.
                MOVE wa_documentfiles-originaltype TO wa_tab_cid2-number.
                MOVE wa_documentfiles-docfile TO wa_tab_cid2-filename.
                APPEND wa_tab_cid2 TO itab_tab_cid2.
              ENDLOOP.

            ELSE.
            ENDIF.

          ELSEIF ( wa_bapi_doc_files2-checkedin IS INITIAL )
          AND NOT ( wa_bapi_doc_files2-docfile IS INITIAL ).

            MOVE wa_bapi_doc_files2-docfile TO lv_source.

            IF ( lv_source CS '\' ) AND ( lv_source CS '.' ).
              CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
                EXPORTING
                  full_name     = lv_source
                IMPORTING
                  stripped_name = lv_stripped_name
                  file_path     = lv_file_path
                EXCEPTIONS
                  x_error       = 1
                  OTHERS        = 2.
              IF sy-subrc <> 0.
                MESSAGE e049(zcvn) WITH lv_source .
              ENDIF.

              MOVE lv_doar_nr_vr_tl_dir TO lv_log_file.

              CONCATENATE lv_doar_nr_vr_tl_dir '\'
                            lv_stripped_name INTO lv_doar_nr_vr_tl_dir.
            ELSE.
              CONCATENATE lv_doar_nr_vr_tl_dir '\'
                           lv_source INTO lv_doar_nr_vr_tl_dir.

            ENDIF.

            CLEAR lv_exist.

            CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
                 EXPORTING
                      fname          = lv_doar_nr_vr_tl_dir
                      IMPORTING
                      exist          = lv_exist
*                      isdir          =
*                      filesize       =
*                      EXCEPTIONS
*                      fileinfo_error = 1
*                      OTHERS         = 2
                      .

            IF lv_exist IS INITIAL.
              CLEAR lv_return.

              CALL FUNCTION 'WS_FILE_COPY'
                EXPORTING
                  destination = lv_doar_nr_vr_tl_dir
                  SOURCE      = lv_source
                IMPORTING
                  return      = lv_return.


              IF ( lv_return EQ 0 ) OR ( lv_return EQ 8 ) .
                IF NOT ( itab_tab_cid2 IS INITIAL ).
                  DATA : tmp_counter(2) TYPE c.
                  tmp_counter = sy-dbcnt + 1.
                  MOVE tmp_counter TO wa_tab_cid2-number.
                  MOVE lv_doar_nr_vr_tl_dir TO wa_tab_cid2-filename.
                  APPEND wa_tab_cid2 TO itab_tab_cid2.
                ELSE.
                  MOVE '1' TO wa_tab_cid2-number.
                  MOVE lv_doar_nr_vr_tl_dir TO wa_tab_cid2-filename.
                  APPEND wa_tab_cid2 TO itab_tab_cid2.
                ENDIF.

                IF wa_bapi_doc_files2-checkedin IS INITIAL.
                  WRITE : text-012 INPUT ON.
                  WRITE : text-013.
                ELSE.
                ENDIF.

                SHIFT lv_source RIGHT BY 20 PLACES.
                WRITE :  lv_source.
              ELSE.
                WRITE :  text-011.
                IF wa_bapi_doc_files2-checkedin IS INITIAL.
                  WRITE :  text-012.
                ELSE.
                ENDIF.
                SHIFT lv_source RIGHT BY 20 PLACES.
                WRITE:  lv_source INPUT ON.                 "COLOR 3 .
              ENDIF.

            ENDIF.
          ENDIF.

********************************
          IF lv_log_flag IS INITIAL.

            DATA : tmp_itab_bapi_doc_files2  TYPE TABLE OF bapi_doc_files2,
                   tmp_itab2_bapi_doc_files2 TYPE TABLE OF bapi_doc_files2,
                            tmp_wa_bapi_doc_files2    TYPE bapi_doc_files2,
                            tmp_filename              TYPE rlgrap-filename.

            REFRESH tmp_itab_bapi_doc_files2.

            CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
              EXPORTING
                documenttype               = wa_draw-dokar
                documentnumber             = wa_draw-doknr
                documentpart               = wa_draw-doktl
                documentversion            = wa_draw-dokvr
*             GETOBJECTLINKS             = ' '
*             GETCOMPONENTS              = ' '
*             GETSTATUSLOG               = ' '
*             GETLONGTEXTS               = ' '
*             GETACTIVEFILES             = 'X'
*             GETCLASSIFICATION          = ' '
*             GETSTRUCTURE               = ' '
*             GETWHEREUSED               = ' '
*             HOSTNAME                   = ' '
*           IMPORTING
*             DOCUMENTDATA               =
*             RETURN                     =
            TABLES
*             OBJECTLINKS                =
*             DOCUMENTDESCRIPTIONS       =
*             LONGTEXTS                  =
*             STATUSLOG                  =
                documentfiles              = tmp_itab_bapi_doc_files2
*             COMPONENTS                 =
*             CHARACTERISTICVALUES       =
*             CLASSALLOCATIONS           =
*             DOCUMENTSTRUCTURE          =
*             WHEREUSEDLIST              =
                      .
            CLEAR tmp_filename.

            DATA: tmp_storage_flag TYPE c.

            CLEAR tmp_storage_flag.

            LOOP AT tmp_itab_bapi_doc_files2 INTO
              tmp_wa_bapi_doc_files2.

              IF ( tmp_wa_bapi_doc_files2-docfile CS '\' ) AND
                 ( tmp_wa_bapi_doc_files2-docfile CS '.' ) AND
                   tmp_storage_flag IS INITIAL .

                CONCATENATE lv_bapi_check_path
                lv_draw_string '.CID1' INTO tmp_filename.

                tmp_storage_flag = 'X'.

              ELSEIF ( tmp_wa_bapi_doc_files2-docfile CS '\' ) AND
                       tmp_storage_flag IS INITIAL .

                CONCATENATE lv_log_file '\' lv_draw_string '.CID1'
                INTO tmp_filename.

                tmp_storage_flag = 'X'.

              ELSEIF ( tmp_wa_bapi_doc_files2-docpath CS '\' ) AND
                       tmp_storage_flag IS INITIAL .

                CONCATENATE lv_log_file '\' lv_draw_string '.CID1'
                INTO tmp_filename.

                tmp_storage_flag = 'X'.

              ELSEIF ( tmp_wa_bapi_doc_files2-docfile NS '\' ) AND
                        tmp_storage_flag IS INITIAL .

                CONCATENATE lv_bapi_check_path lv_log_file
                    lv_draw_string '.CID1' INTO tmp_filename.

                tmp_storage_flag = 'X'.

              ELSE.
                EXIT.
              ENDIF.

              MOVE tmp_filename TO lv_log_file_cid2.

            ENDLOOP.

            CLEAR lv_exist.

            CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
              EXPORTING
                fname                = tmp_filename
             IMPORTING
               exist                = lv_exist
*               ISDIR                =
*               FILESIZE             =
*             EXCEPTIONS
*               fileinfo_error       = 1
*               OTHERS               = 2
                      .

            IF lv_exist IS INITIAL .

              REFRESH tmp_itab2_bapi_doc_files2.

              LOOP AT tmp_itab_bapi_doc_files2
                 INTO tmp_wa_bapi_doc_files2.

                MOVE wa_draw-dokar TO
                  tmp_wa_bapi_doc_files2-documenttype.
                MOVE wa_draw-doknr TO
                  tmp_wa_bapi_doc_files2-documentnumber.
                MOVE wa_draw-doktl TO
                  tmp_wa_bapi_doc_files2-documentpart.
                MOVE wa_draw-dokvr TO
                  tmp_wa_bapi_doc_files2-documentversion.

                CLEAR tmp_wa_bapi_doc_files2-created_at.
                CLEAR tmp_wa_bapi_doc_files2-changed_at.

                APPEND tmp_wa_bapi_doc_files2 TO
                  tmp_itab2_bapi_doc_files2.

              ENDLOOP.

              DATA lc_fname TYPE rs38l_fnam.
              CLEAR lc_fname.
              lc_fname = 'WS_DOWNLOAD'.

              "CALL FUNCTION 'WS_DOWNLOAD'
              CALL FUNCTION lc_fname
              EXPORTING
*                BIN_FILESIZE                  = ' '
*                CODEPAGE                      = ' '
                 filename                      = tmp_filename
                 filetype                      = 'DAT'
*                MODE                          = ' '
*                WK1_N_FORMAT                  = ' '
*                WK1_N_SIZE                    = ' '
*                WK1_T_FORMAT                  = ' '
*                WK1_T_SIZE                    = ' '
*                COL_SELECT                    = ' '
*                COL_SELECTMASK                = ' '
*                NO_AUTH_CHECK                 = ' '
*              IMPORTING
*                FILELENGTH                    =
              TABLES
                 data_tab                    = tmp_itab2_bapi_doc_files2
*                FIELDNAMES                    =
              EXCEPTIONS
                 file_open_error               = 1
                 file_write_error              = 2
                 invalid_filesize              = 3
                 invalid_type                  = 4
                 no_batch                      = 5
                 unknown_error                 = 6
                 invalid_table_width           = 7
                 gui_refuse_filetransfer       = 8
                 customer_error                = 9
                 OTHERS                        = 10
                                      .
              IF sy-subrc <> 0.
*                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.

              lv_log_flag = 'X'.

            ENDIF.
          ENDIF.
********************************
        ENDLOOP.

        SEARCH lv_log_file_cid2 FOR '.CID1'.
        IF sy-subrc EQ 0.
          REPLACE '.CID1' WITH '.CID2' INTO lv_log_file_cid2.
        ENDIF.


        SORT itab_tab_cid2 BY number.


        CLEAR lc_fname.
        lc_fname = 'WS_DOWNLOAD'.

        "CALL FUNCTION 'WS_DOWNLOAD'
        CALL FUNCTION lc_fname
         EXPORTING
*           BIN_FILESIZE                  = ' '
*           CODEPAGE                      = ' '
           filename                      = lv_log_file_cid2
           filetype                      = 'DAT'
*           MODE                          = ' '
*           WK1_N_FORMAT                  = ' '
*           WK1_N_SIZE                    = ' '
*           WK1_T_FORMAT                  = ' '
*           WK1_T_SIZE                    = ' '
*           COL_SELECT                    = ' '
*           COL_SELECTMASK                = ' '
*           NO_AUTH_CHECK                 = ' '
*         IMPORTING
*           FILELENGTH                    =
          TABLES
            data_tab                      = itab_tab_cid2
*           FIELDNAMES                    =
         EXCEPTIONS
           file_open_error               = 1
           file_write_error              = 2
           invalid_filesize              = 3
           invalid_type                  = 4
           no_batch                      = 5
           unknown_error                 = 6
           invalid_table_width           = 7
           gui_refuse_filetransfer       = 8
           customer_error                = 9
           OTHERS                        = 10
                  .
        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.


      ENDIF.

      IF lv_answer = '1'.
        LOOP AT itab_zori_doc_files INTO wa_zori_doc_files
                  WHERE dokar = wa_draw-dokar
                  AND doknr = wa_draw-doknr
                  AND dokvr = wa_draw-dokvr
                  AND doktl = wa_draw-doktl.

          SHIFT wa_zori_doc_files-filep RIGHT BY 20 PLACES.
          WRITE : / wa_zori_doc_files-filep.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.
