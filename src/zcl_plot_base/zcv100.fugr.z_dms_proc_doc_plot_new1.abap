FUNCTION z_dms_proc_doc_plot_new1.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DEFAULT_USER) TYPE  XUBNAME DEFAULT 'SAP*'
*"     REFERENCE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     REFERENCE(I_CLF_DOWN_PATH) TYPE  STRING OPTIONAL
*"     REFERENCE(FILTER) TYPE  C OPTIONAL
*"     REFERENCE(I_OUT_PROC) TYPE  C OPTIONAL
*"     REFERENCE(I_DELETE_ITEM) TYPE  CHAR1 DEFAULT '0'
*"     REFERENCE(I_DELETE_STATUS) TYPE  CHAR1 DEFAULT '0'
*"     REFERENCE(I_FORMAT_CHECKING) TYPE  CHAR1 OPTIONAL
*"  TABLES
*"      ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*&--------------------------------------------------------------------&*
*& Function Group  : ZCV100                                           &*
*& Function Module : Z_DMS_PROC_DOC_PLOT_NEW1                         &*
*& Author          : Srinivas.Mamillapalli@CIDEON-Software.de         &*
*&--------------------------------------------------------------------&*
*& This Function Module contains the logic to create a new CLF file   &*
*& every time . The downloaded CLF File name combines with Username   &*
*& and Timestamp for the unique name.                                 &*
*& To Create a new PPL File use Function Module Z_DMS_NEW_PLOT_LIST   &*
*&--------------------------------------------------------------------&*

*&--------------------------------------------------------------------&*
*&NOTICE: THis Function Module will be executed only when the Import  &*
*&        Parameter ' I_OUT_PROC ' is not Initial.There by a CLF File &*
*&        will be created on the Server.If ' I_OUT_PROC ' initialised &*
*&        then other Function Module will be executed to create       &*
*&        a PPL File on the Server. This Import Parameter can be      &*
*&        Activated by the User Customizing Data of PlottingSolution  &*
*&--------------------------------------------------------------------&*

  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  DATA : flag_multi_page      TYPE c, "Boolean Variables..
         flag_dir_exist       TYPE c,
         flag_is_dir          TYPE c.

  DATA : lv_new_dirname       LIKE rlgrap-filename,
         lv_x_filename        LIKE rlgrap-filename,
         lv_temp_path         LIKE rlgrap-filename,
         lv_full_name         LIKE rlgrap-filename,
         lv_stripped_name     LIKE rlgrap-filename,
         lv_file_path         LIKE rlgrap-filename,
         lv_split_part1       LIKE rlgrap-filename,
         lv_split_part2       LIKE rlgrap-filename,
         lv_tabix             TYPE sy-tabix,
         lv_no_copies(2)      TYPE c.

  DATA : BEGIN OF repli_skeleton OCCURS 0,
          line(200),
         END OF repli_skeleton,

         BEGIN OF repli_lines OCCURS 0,
          line(1000),
         END OF repli_lines,

         BEGIN OF reproliste OCCURS 0,
          line(1000),
         END OF reproliste,

         BEGIN OF x_lines OCCURS 0,
          line(1000),
         END OF x_lines.

  DATA : itab1_bapi_doc_files2   TYPE bapi_doc_files2 OCCURS 0
                                                  WITH HEADER LINE,
         itab2_bapi_doc_files2   TYPE bapi_doc_files2 OCCURS 0
                                                  WITH HEADER LINE,
         itab_bapi_doc_draw2     TYPE bapi_doc_draw2 OCCURS 0
                                                  WITH HEADER LINE,
         itab_bapiret2           TYPE bapiret2       OCCURS 0
                                                  WITH HEADER LINE,
         itab_joblist_file       TYPE zcl_s_plotlist OCCURS 0
                                                  WITH HEADER LINE,
        itab_repli_skeleton_lines TYPE STANDARD TABLE OF zcl_s_line_256,
        itab_repli_skeleton       TYPE STANDARD TABLE OF zcl_s_line_256.

  DATA : wa_repli_skeleton_lines TYPE zcl_s_line_256,
         wa_repli_skeleton       TYPE zcl_s_line_256,
         wa1_bapi_doc_files2     TYPE bapi_doc_files2,
         wa_test                 TYPE zcl_s_plotlist,
         wa_stamps               TYPE zcl_s_stempel_value.

  DATA : ao_naming(60),
         ao_datum(10),
         ao_viewname(40),
         ao_save(40),
         ao_print                               VALUE '0',
         ao_appl(40)                            VALUE '-',
         ao_project(60)                         VALUE '-'.

************************************************************************

  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ELSE.
  ENDIF.

  SORT itab_test BY doknr.

  LOOP AT itab_test.
    IF sy-tabix = 1.
      APPEND itab_test TO itab_joblist_file.
      EXIT.
    ENDIF.
  ENDLOOP.

* Check for the directory existance in which all the files will
* be downloaded or copied.
  CLEAR lv_temp_path.

  MOVE i_down_path TO lv_temp_path.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
       fname                = lv_temp_path
    IMPORTING
       exist                = flag_dir_exist
       isdir                = flag_is_dir
*      FILESIZE             =
    EXCEPTIONS
       fileinfo_error       = 1
       OTHERS               = 2
            .
  IF sy-subrc <> 0.
* Create a directory at ,if it is not existing.
    CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
      EXPORTING
       dirname        = lv_temp_path
*      NO_FLUSH       = ' '
     EXCEPTIONS
        failed         = 1
        OTHERS         = 2
              .
    IF sy-subrc <> 0.
      MESSAGE e010(zcvn) WITH lv_temp_path '' '' ''
        RAISING error.
    ENDIF.
  ENDIF.

* Read the Skeleton Data to internal table.
  CALL FUNCTION 'Z_CL_READ_SKEL_CLF'
    EXPORTING
      i_uname     = sy-uname
    TABLES
      o_itab_data = itab_repli_skeleton
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.

  IF sy-subrc <> 0.
*   If the data not found with the User name ,
*   Process with the Default-User name 'SAP*'.
    CALL FUNCTION 'Z_CL_READ_SKEL_CLF'
      EXPORTING
        i_uname     = default_user
      TABLES
        o_itab_data = itab_repli_skeleton
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
      MESSAGE e012(zcvn) RAISING error.
    ENDIF.

  ENDIF.

* Read the Skeleton Lines Data to internal table.
  CALL FUNCTION 'Z_CL_READ_SKEL_CLF_LINES'
    EXPORTING
      i_uname     = sy-uname
    TABLES
      o_itab_data = itab_repli_skeleton_lines
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.

  IF sy-subrc <> 0.
*   If the data not found with the User name ,
*   Process with the Default-User name 'SAP*'.
    CALL FUNCTION 'Z_CL_READ_SKEL_CLF_LINES'
      EXPORTING
        i_uname     = default_user
      TABLES
        o_itab_data = itab_repli_skeleton_lines
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.

    IF sy-subrc <> 0.
      MESSAGE e014(zcvn) RAISING error.
    ENDIF.

  ENDIF.

  CLEAR lv_x_filename.
* Get the CLF File name that has to be created , with
* the use of LOGICAL_FILENAME & PARAMETER_1.
  CALL FUNCTION 'FILE_GET_NAME'
       EXPORTING
*          CLIENT                  = SY-MANDT
           logical_filename        = 'ZZ_REPRO_CLF_STANDARD_NEW'
*          OPERATING_SYSTEM        = SY-OPSYS
           parameter_1             = 'SAP_DMS_List_'
*          PARAMETER_2             = ' '
*          PARAMETER_3             = ' '
           use_presentation_server = 'X'
*          WITH_FILE_EXTENSION     = ' '
*          USE_BUFFER              = ' '
       IMPORTING
*          EMERGENCY_FLAG          =
*          FILE_FORMAT             =
           file_name               = lv_x_filename
       EXCEPTIONS
           file_not_found          = 1
           OTHERS                  = 2
            .
  IF sy-subrc <> 0.
    MESSAGE e018(zcvn) RAISING error.
  ENDIF.

  CONCATENATE i_clf_down_path lv_x_filename INTO lv_x_filename.


  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = lv_x_filename
    IMPORTING
      stripped_name = lv_stripped_name
      file_path     = lv_file_path
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e032(zcvn) WITH lv_x_filename RAISING error .
  ENDIF.

  SPLIT lv_stripped_name AT '.' INTO lv_split_part1 lv_split_part2.

  CONCATENATE i_down_path lv_split_part1 INTO lv_new_dirname.

* A directory new will created with the same name as the file name.
  CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
    EXPORTING
      dirname  = lv_new_dirname
      no_flush = ' '
    EXCEPTIONS
      failed   = 1
      OTHERS   = 2.
*    IF sy-subrc <> 0.
*    ENDIF.

* Process the Job Parameter in CLF File using skeleton Data.
  LOOP AT itab_joblist_file.

    LOOP AT itab_repli_skeleton INTO wa_repli_skeleton.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 30
          text       = text-083.

      MOVE wa_repli_skeleton-line TO reproliste-line.

      IF reproliste-line CS '%SY-UNAME%'.
        REPLACE '%SY-UNAME%' WITH sy-uname INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%VERTEILER%'.
        REPLACE '%VERTEILER%' WITH itab_joblist_file-verteiler
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%SY-DATUM%'.
        WRITE sy-datum TO ao_datum DD/MM/YYYY.
        REPLACE '%SY-DATUM%' WITH ao_datum INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%KOSTENSTELLE%'.
        REPLACE '%KOSTENSTELLE%' WITH itab_joblist_file-kostl
                                            INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%PROJECT%'.
        IF ao_project = '-'.
          REPLACE '%PROJECT%' WITH text-078 INTO reproliste-line.
        ELSE.
          REPLACE '%PROJECT%' WITH ao_project INTO reproliste-line.
        ENDIF.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%PRINTMODE%'.
        IF i_out_proc = 'X'.
          ao_print = '1'.
        ELSE.
          ao_print = '0'.
        ENDIF.
        REPLACE '%PRINTMODE%' WITH ao_print INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%NAME1%'.
        REPLACE '%NAME1%' WITH itab_joblist_file-name1
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%FIRMA%'.
        REPLACE '%FIRMA%' WITH itab_joblist_file-name1
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%KUNDENNAME%'.
        REPLACE '%KUNDENNAME%' WITH itab_joblist_file-name1
                                              INTO reproliste-line.
        APPEND reproliste.


      ELSEIF reproliste-line CS '%STREET%'.
        REPLACE '%STREET%' WITH itab_joblist_file-stras
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%CITY%'.
        REPLACE '%CITY%' WITH itab_joblist_file-ort1
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%PLZ%'.
        REPLACE '%PLZ%' WITH itab_joblist_file-pstlz
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%PHONE%'.
        REPLACE '%PHONE%' WITH itab_joblist_file-telf1
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%FAX%'.
        REPLACE '%FAX%' WITH itab_joblist_file-telfx
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%MAILID%'.
        REPLACE '%MAILID%' WITH itab_joblist_file-smtp_addr
                                              INTO reproliste-line.
        APPEND reproliste.


      ELSEIF reproliste-line CS '%LINES.CLF%'.
        lv_tabix = sy-tabix + 1.
        EXIT.

      ELSE.
        APPEND reproliste.
      ENDIF.

    ENDLOOP.
  ENDLOOP.


  LOOP AT itab_test INTO wa_test.

    CLEAR itab2_bapi_doc_files2.

    IF wa_test-checked = 'X' .

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 30
          text       = text-084.

*   If the Original File is try to get the details of the document
*   by using below BAPI_* Function Module.
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
        IMPORTING
          documentdata               = itab_bapi_doc_draw2
          return                     = itab_bapiret2
        TABLES
*         OBJECTLINKS                =
*         DOCUMENTDESCRIPTIONS       =
*         LONGTEXTS                  =
*         STATUSLOG                  =
          documentfiles              = itab1_bapi_doc_files2
*         COMPONENTS                 =
                .

      IF itab1_bapi_doc_files2 IS INITIAL.
        MESSAGE e028(zcvn) WITH wa_test-dokar wa_test-doknr
                                wa_test-doktl wa_test-dokvr.
      ENDIF.

      LOOP AT itab1_bapi_doc_files2 INTO wa1_bapi_doc_files2
                                      WHERE docfile = wa_test-filep.

*       Temporary Variable to accept filepath.
        DATA : tmp_bapi_check_path TYPE bapi_doc_aux-filename.

        MOVE lv_new_dirname TO tmp_bapi_check_path .

        CONCATENATE tmp_bapi_check_path '\' INTO tmp_bapi_check_path.

        CLEAR itab2_bapi_doc_files2.

        CONCATENATE text-079 ' ' tmp_bapi_check_path INTO tmp_str.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 30
            text       = tmp_str.

*       If the Original File is Checkedin Download by using
*       below BAPI_* Function Module.
        CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
             EXPORTING
                  documenttype        = wa_test-dokar
                  documentnumber      = wa_test-doknr
                  documentpart        = wa_test-doktl
                  documentversion     = wa_test-dokvr
                  documentfile        = wa1_bapi_doc_files2
                  getstructure        = '1'
*                 getcomponents       = 'X'
                  originalpath        = tmp_bapi_check_path
*                 hostname            = ' '
                  getheader           = 'X'
*                 docbomchangenumber  =
*                 docbomvalidfrom     =
*                 docbomrevisionlevel =
*            IMPORTING
*                 return              = itab_bapiret2
             TABLES
*                 documentstructure   =
                  documentfiles       = itab2_bapi_doc_files2
                  .

        CONCATENATE text-079 ' ' tmp_bapi_check_path INTO tmp_str.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 30
            text       = tmp_str.
      ENDLOOP.

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
      MOVE i_down_path TO tmp_destiny.

      IF NOT ( lv_full_name IS INITIAL ). " Modified on 27thSept.2002

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

        CONCATENATE tmp_destiny lv_split_part1 '\'
                         lv_stripped_name INTO tmp_destiny.

        MOVE lv_full_name TO tmp_obj_source.

        CONCATENATE text-081 ' ' tmp_destiny INTO tmp_str.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 50
            text       = tmp_str.

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
        IF sy-subrc <> 0.
*          MESSAGE e016(zcvn) WITH tmp_obj_source tmp_destiny '' ''
*                                                        RAISING error.
        ENDIF.

      ELSE.
        CONCATENATE wa_test-dokar '_'
                    wa_test-doknr '_'
                    wa_test-dokvr '_'
                    wa_test-doktl '.txt' INTO ao_naming.

        CONCATENATE tmp_destiny lv_split_part1 '\'
                                        ao_naming INTO tmp_destiny.
      ENDIF.

      CONCATENATE text-081 ' ' tmp_destiny INTO tmp_str.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 50
          text       = tmp_str.
    ENDIF.

*   Process the Job-Data Parameter in CLF File using skeleton line Data.
    REFRESH x_lines.


    LOOP AT itab_repli_skeleton_lines INTO wa_repli_skeleton_lines.

*      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*           EXPORTING
*                percentage = 30
*                text       = text-082.

      MOVE wa_repli_skeleton_lines-line TO x_lines-line.

      IF x_lines-line CS '%NAMING%'.
        CLEAR ao_naming.
        CONCATENATE wa_test-dokar '/'
                    wa_test-doknr '/'
                    wa_test-dokvr '/'
                    wa_test-doktl  INTO ao_naming.
        REPLACE '%NAMING%' WITH ao_naming INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%PROJECT%'.
        IF ao_project = '-'.
          REPLACE '%PROJECT%' WITH text-058 INTO reproliste-line.
        ELSE.
          REPLACE '%PROJECT%' WITH ao_project INTO reproliste-line.
        ENDIF.

      ELSEIF x_lines-line CS 'AOFB'.
        APPEND x_lines.

      ELSEIF x_lines-line CS 'AOFE'.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%ERASE%'.
        REPLACE '%ERASE%' WITH i_delete_item INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%PATH%'.
        IF NOT ( itab2_bapi_doc_files2[] IS INITIAL ).

          CLEAR lv_stripped_name.
          CLEAR lv_file_path.
          CLEAR lv_full_name.

          IF wa_test-filep IS INITIAL.
            CONCATENATE 'AO$_PATH=' wa_test-dokar '_'
                                    wa_test-doknr '_'
                                    wa_test-doktl '_'
                                    wa_test-dokvr  INTO x_lines-line+1.
          ELSE.
            MOVE wa_test-filep TO lv_full_name.

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

            CONCATENATE 'AO$_PATH=' tmp_bapi_check_path
                              lv_stripped_name INTO x_lines-line+1.
          ENDIF.

        ELSE.

          CONCATENATE 'AO$_PATH=' tmp_destiny INTO x_lines-line+1.
        ENDIF.

        CLEAR tmp_destiny.
        CLEAR itab2_bapi_doc_files2.

        APPEND x_lines.

      ELSEIF x_lines-line CS '%FORMAT%'.

        IF i_format_checking EQ space.
          REPLACE '%FORMAT%' WITH wa_test-format_ausgabe
                                            INTO x_lines-line.
          APPEND x_lines.
        ELSE.
        ENDIF.

      ELSEIF x_lines-line CS '%COPIES%'.
        CLEAR lv_no_copies.
        MOVE wa_test-kopien TO lv_no_copies.
        REPLACE '%COPIES%' WITH lv_no_copies INTO x_lines-line.
        APPEND x_lines.
        CLEAR lv_no_copies.

      ELSEIF x_lines-line CS '%PRINTMODE%'.

        IF i_out_proc EQ 'X'.
          REPLACE '%PRINTMODE%' WITH ao_print INTO x_lines-line.
        ELSE.
          REPLACE '%PRINTMODE%' WITH '1' INTO x_lines-line.
        ENDIF.

        APPEND x_lines.

      ELSEIF x_lines-line CS '%NUMBER%'.
        REPLACE '%NUMBER%' WITH wa_test-doknr INTO x_lines-line.
        APPEND x_lines.
      ELSEIF x_lines-line CS '%APPLICATION%'.
        REPLACE '%APPLICATION%' WITH ao_appl INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%DELETE%'.
        REPLACE '%DELETE%' WITH i_delete_status INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%VIEWNAME%'.
        REPLACE '%VIEWNAME%' WITH ao_viewname INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%SAVECONVERTAS%'.
        REPLACE '%SAVECONVERTAS%' WITH ao_save INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%MULTIPAGE%'.
        IF wa_test-knz_multi_page EQ 'X'.
          REPLACE '%MULTIPAGE%' WITH '1' INTO x_lines-line.
          APPEND x_lines.
        ELSE.
          REPLACE '%MULTIPAGE%' WITH '0' INTO x_lines-line.
          APPEND x_lines.
        ENDIF.

      ELSEIF x_lines-line CS '%PAGE%'.
        REPLACE '%PAGE%' WITH wa_test-seite_von INTO x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '"%STEMPEL1%"'.
*        SHIFT wa_test-cont LEFT DELETING LEADING 0.
        SHIFT wa_test-cont LEFT DELETING LEADING '0'.

        LOOP AT itab_stamps INTO wa_stamps
                      WHERE zeile_plotjob = wa_test-cont.
          IF sy-subrc = 0.
            CONCATENATE wa_stamps-stempel_name ' = '
                wa_stamps-stempel_wert INTO x_lines-line+1.
            APPEND x_lines.
          ENDIF.

        ENDLOOP.

*        MOVE wa_stamps-stempel_name TO index_num.
*        REPLACE '"%STEMPEL1%"' WITH index_num INTO x_lines-line.
*        APPEND x_lines.
*
*      ELSEIF x_lines-line CS '"%STEMPEL2%"'.
*        REPLACE '"%STEMPEL2%"' WITH wa_stamps-stempel_name
*                                                INTO x_lines-line.
*        APPEND x_lines.
*
*      ELSEIF x_lines-line CS '"%STEMPEL3%"'.
*        REPLACE '"%STEMPEL3%"' WITH wa_stamps-stempel_wert
*                                                INTO x_lines-line.
*        APPEND x_lines.

      ELSEIF x_lines-line CS 'SAP$=%DVS%'.  "User-Felder
        CLEAR x_lines-line.

      ENDIF.

    ENDLOOP.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 30
        text       = text-083.

    LOOP AT x_lines.
      MOVE x_lines TO reproliste-line.
      APPEND reproliste.
    ENDLOOP.

    CLEAR itab2_bapi_doc_files2.

  ENDLOOP.

  LOOP AT repli_skeleton FROM lv_tabix.
    MOVE repli_skeleton-line TO reproliste-line.
    APPEND reproliste.
  ENDLOOP.


* Download Reprolistdatei to the required destination.
  SEARCH reproliste FOR 'AOFB'.

  IF sy-subrc = 0.

    APPEND 'AO2LE' TO reproliste.

    CONCATENATE text-086  ' ' lv_x_filename INTO tmp_str.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 50
        text       = tmp_str.

    DATA lc_fname TYPE rs38l_fnam.
    CLEAR lc_fname.
    lc_fname = 'WS_DOWNLOAD'.

    CALL FUNCTION lc_fname
      EXPORTING
        filename                = lv_x_filename
        filetype                = 'ASC'
        mode                    = 'O'
      TABLES
        data_tab                = reproliste
      EXCEPTIONS
        file_open_error         = 1
        file_write_error        = 2
        invalid_filesize        = 3
        invalid_type            = 4
        no_batch                = 5
        unknown_error           = 6
        invalid_table_width     = 7
        gui_refuse_filetransfer = 8
        customer_error          = 9
        OTHERS                  = 10.
    IF sy-subrc <> 0.
      MESSAGE e037(zcvn) WITH lv_x_filename.
    ENDIF.

  ELSE.
    MESSAGE e034(zcvn) RAISING error.
  ENDIF.

ENDFUNCTION.
