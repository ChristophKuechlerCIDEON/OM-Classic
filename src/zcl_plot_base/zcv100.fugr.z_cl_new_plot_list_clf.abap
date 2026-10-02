FUNCTION z_cl_new_plot_list_clf.
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
*"  TABLES
*"      ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Srinivas Mamillapallli
*
*           Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 28.05.2004 - Umstellung WS_DOWNLOAD auf DSVAS_DOC_WS_DOWNLOAD_50
*              Umstellung auf GUI_DOWNLOAD
* 23.02.2005 - Änderungen für JavaGUI
*              Dateiablage / Verzeichnistests
*-----------------------------------------------------------------------


  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  DATA : lv_rc                TYPE i,
         lv_filelength        TYPE i,
         lv_starting_page(2)  TYPE c,
         lv_ending_page(2)    TYPE c,
         lv_i_last_path       TYPE filep,
         lv_e_last_path       TYPE filep,
         lv_new_dirname       TYPE string,
         lv_downloaded_path   TYPE string,
         lv_tabix             TYPE sy-tabix,
         lv_temp_path         LIKE rlgrap-filename,
         lv_x_filename        LIKE rlgrap-filename,
         lv_split_part1       LIKE rlgrap-filename,
         lv_split_part2       LIKE rlgrap-filename,
         lv_stripped_name     LIKE rlgrap-filename,
         lv_file_path         LIKE rlgrap-filename.
*         lv_clf_dowload_path  LIKE rlgrap-filename.


  DATA : itab_clf_final_data  TYPE STANDARD TABLE OF zcl_s_line_256,
         itab_repli_skeleton TYPE STANDARD TABLE OF zcl_s_line_256,
         itab_joblist_file   TYPE zcl_s_plotlist OCCURS 0
                                                  WITH HEADER LINE,
         itab_out_repli_skeleton_lines TYPE zcl_s_line_256
                                         OCCURS 0 WITH HEADER LINE,
         itab_reproliste TYPE STANDARD TABLE OF zcl_s_line_256
                                                  WITH HEADER LINE,
         itab_repli_skeleton_lines TYPE STANDARD
                                           TABLE OF zcl_s_line_256.

  DATA : flag_dir_exist TYPE c,
         flag_is_dir TYPE c.

  DATA : wa_test TYPE zcl_s_plotlist,
         itab1_test TYPE STANDARD TABLE OF zcl_s_line_256.

*NORMAL
  DATA: knz_w32_gui.
  DATA: dir_name TYPE rlgrap-filename.


* Feststellen, ob JavaGUI oder normaler GUI
  CLEAR knz_w32_gui.
  CALL FUNCTION 'GUI_HAS_ACTIVEX'
    IMPORTING
      return = knz_w32_gui.


  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ENDIF.

  CLEAR lv_i_last_path.

  LOOP AT itab_test.
    IF sy-tabix = 1.
      APPEND itab_test TO itab_joblist_file.
      MOVE itab_test-seite_von TO lv_starting_page.
    ELSE.
      CLEAR lv_ending_page.
      MOVE itab_test-seite_bis TO lv_ending_page.
    ENDIF.
  ENDLOOP.

******* Modif. on 13.12.2002..start..Mamillapalli
********* Not properly checking the
******* '\\Soft-gr-oratest\AutoORG\TEMP\CV04N' existance
******** by the object Method..so tried with FM.
*  CALL METHOD obj_frontend_services->file_exist
*    EXPORTING
*      file            = i_down_path
*    RECEIVING
*      result          = lv_rc
*    EXCEPTIONS
*      cntl_error      = 1
*      error_no_gui    = 2
*      wrong_parameter = 3
*      OTHERS          = 4
*          .

  DATA : tmp_fname(150) TYPE c,
         tmp_exist      TYPE c.

  MOVE i_down_path TO tmp_fname.

  CLEAR tmp_exist.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
       EXPORTING
            fname          = tmp_fname
       IMPORTING
            exist          = tmp_exist
*           isdir          =
*           filesize       =
       EXCEPTIONS
            fileinfo_error = 1
            OTHERS         = 2
                .

  IF sy-subrc NE 0.
    IF sy-subrc = 1.
      MESSAGE e009(zcvn) WITH
        'fileinfo_error' 'TMP_GUI_GET_FILE_EXIST'
        'Z_CL_NEW_PLOT_LIST_CLF' ''
        RAISING error.
    ELSE.
      MESSAGE e009(zcvn) WITH
        'OTHERS' 'TMP_GUI_GET_FILE_EXIST'
        'Z_CL_NEW_PLOT_LIST_CLF' ''
        RAISING error.
    ENDIF.
  ELSE.
  ENDIF.

  IF tmp_exist IS INITIAL.
***** Modif. on 13.12.2002..ende..Mamillapalli
    CLEAR lv_rc.

    CALL METHOD obj_frontend_services->directory_create
      EXPORTING
        directory                = i_down_path
      CHANGING
        rc                       = lv_rc
      EXCEPTIONS
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        OTHERS                   = 8.
    IF sy-subrc <> 0.
      MESSAGE e048(zcvn) WITH i_down_path RAISING error.
    ENDIF.

  ELSE.
  ENDIF.

  CALL FUNCTION 'Z_CL_UPLOAD_SKELETON_AND_LINES'
    EXPORTING
      default_user         = default_user  "'SAP*'
    TABLES
      o_rep_skeleton       = itab_repli_skeleton
      o_rep_skeleton_lines = itab_repli_skeleton_lines
    EXCEPTIONS
      error                = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      MESSAGE e049(zcvn) RAISING error.
  ENDIF.

  CLEAR lv_x_filename.

*********  Geändert am 18.08.2003 (Start)..MAMILLAPALLI


  DATA : lv_logic_file    LIKE rlgrap-filename,
         lv_timestamp     LIKE rlgrap-filename,
         lv_year          LIKE rlgrap-filename,
         lv_fname         TYPE char255.

  DATA : lv_exist    TYPE  c,
         lv_isdir    TYPE  c.

  DATA : lv_result TYPE abap_bool.

* Get the CLF File name that has to be created , with
* the use of LOGICAL_FILENAME & PARAMETER_1.
  CALL FUNCTION 'FILE_GET_NAME'
       EXPORTING
           client                  = sy-mandt
           logical_filename        = 'ZZ_REPRO_CLF_STANDARD_NEW'
           operating_system        = sy-opsys
*        parameter_1             = 'SAP_DMS_LIST'
           parameter_1             = text-100
*        PARAMETER_2             = ' '
*        PARAMETER_3             = ' '
           use_presentation_server = 'X'
*        WITH_FILE_EXTENSION     = ' '
*        USE_BUFFER              = ' '
       IMPORTING
*        EMERGENCY_FLAG          =
*        FILE_FORMAT             =
           file_name               = lv_x_filename
       EXCEPTIONS
           file_not_found          = 1
           OTHERS                  = 2
            .
  IF sy-subrc <> 0.
    MESSAGE e018(zcvn) RAISING error.
  ENDIF.

  CONCATENATE i_clf_down_path lv_x_filename INTO i_clf_down_path.

*  CONCATENATE i_clf_down_path lv_x_filename INTO lv_clf_dowload_path .
*  CONCATENATE i_down_path lv_x_filename INTO i_down_path .

* Problem mit "." innerhalb eines Nutzernamens
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
* Problem mit "." innerhalb eines Nutzernamens ENDE

*SPLIT lv_split_part1 AT 'SAP_DMS_LIST' INTO lv_logic_file lv_timestamp.
  SPLIT lv_split_part1 AT text-100 INTO lv_logic_file lv_timestamp.

  lv_year = lv_timestamp+0(4).

  CONCATENATE i_down_path lv_year INTO lv_fname.

  CLEAR lv_exist.
  CLEAR lv_isdir.

* Jahr
  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
      fname                = lv_fname
   IMPORTING
     exist                = lv_exist
     isdir                = lv_isdir
*   filesize             =
* EXCEPTIONS
*   FILEINFO_ERROR       = 1
*   OTHERS               = 2
            .

  IF knz_w32_gui = 'X'.
  ELSE.
*   Java
*   Verzeichnis einfach nochmal anlegen
    CLEAR lv_exist.
    CLEAR lv_isdir.
  ENDIF.

  IF ( lv_exist IS INITIAL AND lv_isdir IS INITIAL ).

    MOVE lv_fname TO lv_new_dirname.

    CALL METHOD obj_frontend_services->directory_create
      EXPORTING
        directory                = lv_new_dirname
      CHANGING
        rc                       = lv_rc
      EXCEPTIONS
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        OTHERS                   = 8.
    IF lv_rc GT 0.
      IF knz_w32_gui = 'X'.
        MESSAGE e010(zcvn) WITH lv_new_dirname '' '' ''
          RAISING error.
      ELSE.
      ENDIF.
    ENDIF.

  ENDIF.

  CONCATENATE lv_fname '\' sy-datum INTO lv_fname.

  CLEAR lv_exist.
  CLEAR lv_isdir.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
      fname                = lv_fname
   IMPORTING
     exist                = lv_exist
     isdir                = lv_isdir
*   filesize             =
* EXCEPTIONS
*   FILEINFO_ERROR       = 1
*   OTHERS               = 2
            .

  IF knz_w32_gui = 'X'.
  ELSE.
*   Java
*   Verzeichnis einfach nochmal anlegen
    CLEAR lv_exist.
    CLEAR lv_isdir.
  ENDIF.

  IF ( lv_exist IS INITIAL AND lv_isdir IS INITIAL ).

    MOVE lv_fname TO lv_new_dirname.

    CALL METHOD obj_frontend_services->directory_create
      EXPORTING
        directory                = lv_new_dirname
      CHANGING
        rc                       = lv_rc
      EXCEPTIONS
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        OTHERS                   = 8.
    IF lv_rc GT 0.
      IF knz_w32_gui = 'X'.
        MESSAGE e010(zcvn) WITH lv_new_dirname '' '' ''
          RAISING error.
      ELSE.
      ENDIF.
    ENDIF.
  ENDIF.

  CONCATENATE lv_fname '\' lv_split_part1 INTO lv_fname.

  CLEAR lv_exist.
  CLEAR lv_isdir.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
      fname                = lv_fname
   IMPORTING
     exist                = lv_exist
     isdir                = lv_isdir
*   filesize             =
* EXCEPTIONS
*   FILEINFO_ERROR       = 1
*   OTHERS               = 2
            .
  IF knz_w32_gui = 'X'.
  ELSE.
*   Java
*   Verzeichnis einfach nochmal anlegen
    CLEAR lv_exist.
    CLEAR lv_isdir.
  ENDIF.

  IF ( lv_exist IS INITIAL AND lv_isdir IS INITIAL ).

    MOVE lv_fname TO lv_new_dirname.

    CALL METHOD obj_frontend_services->directory_create
      EXPORTING
        directory                = lv_new_dirname
      CHANGING
        rc                       = lv_rc
      EXCEPTIONS
        directory_create_failed  = 1
        cntl_error               = 2
        error_no_gui             = 3
        path_not_found           = 4
        directory_access_denied  = 5
        directory_already_exists = 6
        unknown_error            = 7
        OTHERS                   = 8.
    IF lv_rc GT 0.
      IF knz_w32_gui = 'X'.
        MESSAGE e010(zcvn) WITH lv_new_dirname '' '' ''
          RAISING error.
      ELSE.
      ENDIF.
    ENDIF.
  ENDIF.

*********  Geändert am 18.08.2003 (Ende) MAMILLAPALLI


********** Kommentiert ( MAMILLAPALLI)  ..18.08.2003..Start
** Get the CLF File name that has to be created , with
** the use of LOGICAL_FILENAME & PARAMETER_1.
*  CALL FUNCTION 'FILE_GET_NAME'
*       EXPORTING
*           client                  = sy-mandt
*           logical_filename        = 'ZZ_REPRO_CLF_STANDARD_NEW'
*           operating_system        = sy-opsys
*           parameter_1             = 'SAP_DMS_LIST'
**          PARAMETER_2             = ' '
**          PARAMETER_3             = ' '
*           use_presentation_server = 'X'
**          WITH_FILE_EXTENSION     = ' '
**          USE_BUFFER              = ' '
*       IMPORTING
**          EMERGENCY_FLAG          =
**          FILE_FORMAT             =
*           file_name               = lv_x_filename
*       EXCEPTIONS
*           file_not_found          = 1
*           OTHERS                  = 2
*            .
*  IF sy-subrc <> 0.
*    MESSAGE e018(zcvn) RAISING error.
*  ENDIF.
*
*  CONCATENATE i_clf_down_path lv_x_filename INTO lv_x_filename.
*
*  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*       EXPORTING
*            full_name     = lv_x_filename
*       IMPORTING
*            stripped_name = lv_stripped_name
*            file_path     = lv_file_path
*       EXCEPTIONS
*            x_error       = 1
*            OTHERS        = 2.
*
*  IF sy-subrc <> 0.
*    MESSAGE e032(zcvn) WITH lv_x_filename RAISING error .
*  ENDIF.
*
*  SPLIT lv_stripped_name AT '.' INTO lv_split_part1 lv_split_part2.
*
*  CONCATENATE i_down_path lv_split_part1 INTO lv_new_dirname.
*
*  CALL METHOD obj_frontend_services->directory_create
*    EXPORTING
*      directory                = lv_new_dirname
*    CHANGING
*      rc                       = lv_rc
*    EXCEPTIONS
*      directory_create_failed  = 1
*      cntl_error               = 2
*      error_no_gui             = 3
*      path_not_found           = 4
*      directory_access_denied  = 5
*      directory_already_exists = 6
*      unknown_error            = 7
*      OTHERS                   = 8
*          .
*
******  Geändert am 01.04.2003 bei SRI
*  IF sy-subrc NE 0.
*    CLEAR tmp_exist.
*    MOVE lv_new_dirname TO tmp_fname.
*
*    CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
*      EXPORTING
*        fname                = tmp_fname
*     IMPORTING
*       exist                = tmp_exist
**   ISDIR                =
**   FILESIZE             =
*     EXCEPTIONS
*       fileinfo_error       = 1
*       OTHERS               = 2
*              .
*    IF sy-subrc <> 0.
*      MESSAGE e050(zcvn) RAISING error.
*    ENDIF.
*  ENDIF.
******* Geändert ende.
**  IF sy-subrc <> 0.
**    MESSAGE e050(zcvn) RAISING error.
**  ENDIF.
********** Kommentiert ( MAMILLAPALLI)  ..18.08.2003..Ende

  CALL FUNCTION 'Z_CL_CLF_PROCESS_SKELETON'
    EXPORTING
      i_out_proc     = i_out_proc
    TABLES
      i_rep_skeleton = itab_repli_skeleton
      o_reproliste   = itab_reproliste
      i_joblist_file = itab_joblist_file
    EXCEPTIONS
      error          = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE e051(zcvn) RAISING error.
  ENDIF.

  LOOP AT itab_test INTO wa_test .

*    IF wa_test-knz_fehl_blatt IS INITIAL. " § Modif..am 21.10.2002

    CALL FUNCTION 'Z_CL_GET_DOC_DETAIL_AND_DLOAD'
      EXPORTING
        i_new_directory_name = lv_new_dirname
        wa_test              = wa_test
        i_last_path          = lv_i_last_path
        i_downloaded_path    = lv_downloaded_path
      IMPORTING
        e_new_path           = lv_downloaded_path
        e_last_path          = lv_e_last_path
      EXCEPTIONS
        error                = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      IF sy-msgid IS INITIAL.
        MESSAGE e051(zcvn) RAISING error.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

*    ELSE.                                 " § Modif..am 21.10.2002
*    ENDIF.                                " § Modif..am 21.10.2002

*  Kennzeichen für Multipage setzen, falls eine bestimmte Seite
*  angefordert wird
*    IF ( ( NOT ( wa_test-seite IS INITIAL ) )
*         OR
*         ( NOT ( wa_test-seite_von IS INITIAL ) )
*         OR
*         ( NOT ( wa_test-seite_bis IS INITIAL ) )
*       )
*    AND ( wa_test-knz_multi_page IS INITIAL ).
*      wa_test-knz_multi_page = 'X'.
*    ELSE.
*    ENDIF.


    CALL FUNCTION 'Z_CL_CLF_PROC_SKELETON_LINES'
      EXPORTING
        i_multi_page      = wa_test-knz_multi_page
        i_start_page_no   = wa_test-seite_von
        i_end_page_no     = wa_test-seite_bis
        i_downloaded_path = lv_downloaded_path
        wa_test           = wa_test
        i_last_path       = lv_e_last_path
        i_delete_status   = i_delete_status
      IMPORTING
        e_last_path       = lv_i_last_path
      TABLES
        it_rep_skel_lines = itab_repli_skeleton_lines
        ot_rep_skel_lines = itab_out_repli_skeleton_lines
        itab_stamps       = itab_stamps
      EXCEPTIONS
        error             = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
      MESSAGE e052(zcvn) RAISING error.
    ENDIF.



  ENDLOOP.

  LOOP AT itab_reproliste.
    IF itab_reproliste-line CS '%LINES.CLF%'.
      LOOP AT itab_out_repli_skeleton_lines.
        APPEND itab_out_repli_skeleton_lines TO itab_clf_final_data.
      ENDLOOP.
    ELSE.
      APPEND itab_reproliste TO itab_clf_final_data.
    ENDIF.
  ENDLOOP.


* Download Reprolistdatei to the required destination.
  SEARCH itab_clf_final_data FOR 'AOFB'.

  IF sy-subrc = 0.
    CONCATENATE text-086  ' ' lv_x_filename INTO tmp_str.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 50
        text       = tmp_str.

* Geändert am 18.08.2003 mit 'lv_clf_dowload_path'. "MAMILLAPALLI
* The path of the destinatination to where the
* CLF Data has to be downloaded.

    DATA : tmp_clf_down_path LIKE rlgrap-filename.
    MOVE i_clf_down_path TO tmp_clf_down_path.

    DATA: str_file_name TYPE string.
    CLEAR str_file_name.
    str_file_name = tmp_clf_down_path.

    IF knz_w32_gui = 'X'.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
*     BIN_FILESIZE                  =
          filename                      = str_file_name
          filetype                      = 'ASC'
*     APPEND                        = ' '
*     WRITE_FIELD_SEPARATOR         = ' '
*     HEADER                        = '00'
*     TRUNC_TRAILING_BLANKS         = ' '
*     WRITE_LF                      = 'X'
*     COL_SELECT                    = ' '
*     COL_SELECT_MASK               = ' '
*     DAT_MODE                      = ' '
*   IMPORTING
*     FILELENGTH                    =
        TABLES
          data_tab                      = itab_clf_final_data
       EXCEPTIONS
         file_write_error              = 1
         no_batch                      = 2
         gui_refuse_filetransfer       = 3
         invalid_type                  = 4
         no_authority                  = 5
         unknown_error                 = 6
         header_not_allowed            = 7
         separator_not_allowed         = 8
         filesize_not_allowed          = 9
         header_too_long               = 10
         dp_error_create               = 11
         dp_error_send                 = 12
         dp_error_write                = 13
         unknown_dp_error              = 14
         access_denied                 = 15
         dp_out_of_memory              = 16
         disk_full                     = 17
         dp_timeout                    = 18
         file_not_found                = 19
         dataprovider_exception        = 20
         control_flush_error           = 21
         OTHERS                        = 22
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ELSE.
      DATA lc_fname TYPE rs38l_fnam.
      CLEAR lc_fname.
      lc_fname = 'WS_DOWNLOAD'.

      CALL FUNCTION lc_fname
       EXPORTING
*      BIN_FILESIZE                  = ' '
*      CODEPAGE                      = ' '
*      filename                      = lv_x_filename
         filename                      = tmp_clf_down_path
         filetype                      = 'ASC'
*      MODE                          = ' '
*      WK1_N_FORMAT                  = ' '
*      WK1_N_SIZE                    = ' '
*      WK1_T_FORMAT                  = ' '
*      WK1_T_SIZE                    = ' '
*      COL_SELECT                    = ' '
*      COL_SELECTMASK                = ' '
*      NO_AUTH_CHECK                 = ' '
       IMPORTING
         filelength                    = lv_filelength
       TABLES
         data_tab                      = itab_clf_final_data
*      FIELDNAMES                    =
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.


*    CALL FUNCTION 'DSVAS_DOC_WS_DOWNLOAD_50'
*      EXPORTING
**       BIN_FILESIZE                  = ' '
*        filename                      = tmp_clf_down_path
*        filetype                      = 'ASC'
**       MODE                          = ' '
*      IMPORTING
*        filelength                    = lv_filelength
*      TABLES
*        data_tab                      = itab_clf_final_data
*      EXCEPTIONS
*        file_open_error               = 1
*        file_write_error              = 2
*        invalid_filesize              = 3
*        invalid_type                  = 4
*        no_batch                      = 5
*        unknown_error                 = 6
*        invalid_table_width           = 7
*        gui_refuse_filetransfer       = 8
*        customer_error                = 9
*        no_authority                  = 10
*        OTHERS                        = 11
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.


*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**   BIN_FILESIZE                  = ' '
**   CODEPAGE                      = ' '
**   filename                 = lv_x_filename "Mamillapalli(18.08.2003)
*       filename                      = tmp_clf_down_path
*       filetype                      = 'ASC'
**   MODE                          = ' '
**   WK1_N_FORMAT                  = ' '
**   WK1_N_SIZE                    = ' '
**   WK1_T_FORMAT                  = ' '
**   WK1_T_SIZE                    = ' '
**   COL_SELECT                    = ' '
**   COL_SELECTMASK                = ' '
**   NO_AUTH_CHECK                 = ' '
*     IMPORTING
*       filelength                    = lv_filelength
*      TABLES
*        data_tab                      = itab_clf_final_data
**   FIELDNAMES                    =
* EXCEPTIONS
*   file_open_error               = 1
*   file_write_error              = 2
*   invalid_filesize              = 3
*   invalid_type                  = 4
*   no_batch                      = 5
*   unknown_error                 = 6
*   invalid_table_width           = 7
*   gui_refuse_filetransfer       = 8
*   customer_error                = 9
*   OTHERS                        = 10
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
  ELSE.
    MESSAGE e034(zcvn) RAISING error.
  ENDIF.

  REFRESH itab_test.
  CLEAR itab_test.
  CLEAR wa_test.
  REFRESH itab_clf_final_data.

ENDFUNCTION.
