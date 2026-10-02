FUNCTION z_cl_clf_files_plot_list.
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
*& Function Group  : ZPLOT_INTERFACE                                  &*
*& Function Module : Z_CL_CLF_FILES_PLOT_LIST                         &*
*& Author          : Srinivas.Mamillapalli@CIDEON-Software.de         &*
*&--------------------------------------------------------------------&*
*& This Function Module contains the logic of creating a new CLF file &*
*& every time . The downloaded CLF File combines with Username and    &*
*& and Timestamp for the unique name.                                 &*
*&--------------------------------------------------------------------&*

*&--------------------------------------------------------------------&*
*&NOTICE:THis Function Module will be executed only when the Import  &*
*&        Parameter ' I_OUT_PROC ' is not Initial.There by a CLF File &*
*&        will be created on the Server.If ' I_OUT_PROC ' initialised &*
*&        then other Function Module will be executed to create       &*
*&        a PPL File on the Server. This Import Parameter can be      &*
*&        Activated by the User Customizing Data of PlottingSolution  &*
*&--------------------------------------------------------------------&*



  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.
  DATA:  k TYPE sy-tabix VALUE 1.

  DATA : complete_path LIKE rlgrap-filename,
         complete_dest  LIKE  rlgrap-filename.

  DATA : z_full_name LIKE rlgrap-filename ,
         z_stripped_name LIKE rlgrap-filename ,
         z_file_path LIKE rlgrap-filename .

  DATA : wa_stamps TYPE  zcl_s_stempel_value.
  DATA : stamp_desc(30) TYPE c.

  DATA : index_num(2) TYPE c.

  DATA : tmp_new_dirname LIKE  rlgrap-filename.

  DATA : x_filename LIKE rlgrap-filename.

  DATA: BEGIN OF repli_skeleton OCCURS 30,
          line(200),
        END OF repli_skeleton,

        BEGIN OF repli_stamps OCCURS 5,
          line(200),
        END OF repli_stamps,

        BEGIN OF repli_lines OCCURS 200,
          line(1000),
        END OF repli_lines.

  DATA : wa_test TYPE zcl_s_plotlist,
         temp_path   LIKE rlgrap-filename,
         dir_exist        TYPE c,
         is_dir           TYPE c,
         rc               TYPE i,
         tabix            LIKE sy-tabix,
         destination      LIKE  rlgrap-filename.

  DATA : BEGIN OF reproliste OCCURS 500,
          line(1000),
        END OF reproliste,

        BEGIN OF x_lines OCCURS 20,
          line(1000),
        END OF x_lines.

  DATA : obj_source TYPE string.
  DATA : no_copies(2) TYPE c.
  DATA : file_type_filter TYPE string.
  DATA : return TYPE c,
         joblist_file TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE.

  DATA : it_repli_skeleton_lines TYPE STANDARD TABLE OF zcl_s_line_256,
         wa_repli_skeleton_lines TYPE zcl_s_line_256.

  DATA :  it_repli_skeleton TYPE STANDARD TABLE OF zcl_s_line_256,
          wa_repli_skeleton TYPE zcl_s_line_256.

  DATA : file_table TYPE sdokpath OCCURS 0 WITH HEADER LINE,
         dir_table TYPE sdokpath OCCURS 0 WITH HEADER LINE.

  DATA: t1_bapi_doc_files2    TYPE bapi_doc_files2 OCCURS 0
                                              WITH HEADER LINE,
        wa1_bapi_doc_files2    TYPE bapi_doc_files2 ,

        t2_bapi_doc_files2    TYPE bapi_doc_files2 OCCURS 0
                                              WITH HEADER LINE,
        wa2_bapi_doc_files2    TYPE bapi_doc_files2 ,
        bapi_doc_draw2  TYPE bapi_doc_draw2 OCCURS 0 WITH HEADER LINE,
        bapiret2        TYPE bapiret2       OCCURS 0 WITH HEADER LINE.


  DATA : h1 LIKE rlgrap-filename ,
         h2 LIKE rlgrap-filename .

  DATA : p1 LIKE rlgrap-filename ,
         p2 LIKE rlgrap-filename .

  DATA: ao_naming(60),
        ao_datum(10),
        ao_viewname(40),
        ao_save(40),
        ao_print                               VALUE '0',
        ao_appl(40)                            VALUE '-',
        ao_project(60)                         VALUE '-'.

*********************
  CREATE OBJECT obj_frontend_services.

** Check for the directory existance in which all the files will
** be downloaded or copied.

  SORT itab_test BY doknr.

  LOOP AT itab_test.
    IF sy-tabix = 1.
      APPEND itab_test TO joblist_file.
      EXIT.
    ENDIF.
  ENDLOOP.

* Check for the directory existance in which all the files will
* be downloaded or copied.
  CLEAR temp_path.

  MOVE i_down_path TO temp_path.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
       fname                = temp_path
    IMPORTING
       exist                = dir_exist
       isdir                = is_dir
*      FILESIZE             =
    EXCEPTIONS
       fileinfo_error       = 1
       OTHERS               = 2
            .
  IF sy-subrc <> 0.
* Create a directory at ,if it is not existing.
    CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
      EXPORTING
       dirname        = temp_path
*       NO_FLUSH       = ' '
     EXCEPTIONS
        failed         = 1
        OTHERS         = 2
              .
    IF sy-subrc <> 0.
      MESSAGE e010(zcvn) WITH temp_path '' '' ''
        RAISING error.
    ENDIF.
  ENDIF.
  CLEAR rc.

* Read the Skeleton Data to internal table.
  CALL FUNCTION 'Z_CL_READ_SKEL_CLF'
    EXPORTING
      i_uname     = sy-uname
    TABLES
      o_itab_data = it_repli_skeleton
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.

  IF sy-subrc <> 0.
*   If the data not found with the User name ,
*   Process with the Default-User name.
    CALL FUNCTION 'Z_CL_READ_SKEL_CLF'
      EXPORTING
        i_uname     = default_user
      TABLES
        o_itab_data = it_repli_skeleton
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
      o_itab_data = it_repli_skeleton_lines
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.

  IF sy-subrc <> 0.
*   If the data not found with the User name ,
*   Process with the Default-User name.
    CALL FUNCTION 'Z_CL_READ_SKEL_CLF_LINES'
      EXPORTING
        i_uname     = default_user
      TABLES
        o_itab_data = it_repli_skeleton_lines
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.

    IF sy-subrc <> 0.
      MESSAGE e014(zcvn) RAISING error.
    ENDIF.

  ENDIF.

  CLEAR x_filename.
* Get the CLF File name that has to be created , with
* the use of LOGICAL_FILENAME & PARAMETER_1.
  CALL FUNCTION 'FILE_GET_NAME'
       EXPORTING
*              CLIENT                  = SY-MANDT
           logical_filename        = 'ZZ_REPRO_CLF_STANDARD_NEW'
*              OPERATING_SYSTEM        = SY-OPSYS
           parameter_1             = 'SAP_DMS_List_'
*              PARAMETER_2             = ' '
*              PARAMETER_3             = ' '
           use_presentation_server = 'X'
*              WITH_FILE_EXTENSION     = ' '
*              USE_BUFFER              = ' '
       IMPORTING
*              EMERGENCY_FLAG          =
*              FILE_FORMAT             =
           file_name               = x_filename
       EXCEPTIONS
           file_not_found          = 1
           OTHERS                  = 2
            .
  IF sy-subrc <> 0.
    MESSAGE e018(zcvn) RAISING error.
  ENDIF.

  CONCATENATE i_clf_down_path x_filename INTO x_filename.


  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = x_filename
    IMPORTING
      stripped_name = z_stripped_name
      file_path     = z_file_path
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e032(zcvn) WITH x_filename RAISING error .
  ENDIF.

  SPLIT z_stripped_name AT '.' INTO h1 h2.

  CONCATENATE i_down_path h1 INTO tmp_new_dirname.

* A directory new will created with the same name as the file name.
  CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
    EXPORTING
      dirname  = tmp_new_dirname
      no_flush = ' '
    EXCEPTIONS
      failed   = 1
      OTHERS   = 2.
*    IF sy-subrc <> 0.
*      MESSAGE e020(zcvn) WITH tmp_new_dirname '' '' '' RAISIING error.
*    ENDIF.

* Process the Job Parameter in CLF File using skeleton Data.
  LOOP AT joblist_file.

    LOOP AT it_repli_skeleton INTO wa_repli_skeleton.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 30
          text       = text-083.

      MOVE wa_repli_skeleton-line TO reproliste-line.

      IF reproliste-line CS '%SY-UNAME%'.
        REPLACE '%SY-UNAME%' WITH sy-uname INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%VERTEILER%'.
        REPLACE '%VERTEILER%' WITH joblist_file-verteiler
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%SY-DATUM%'.
        WRITE sy-datum TO ao_datum DD/MM/YYYY.
        REPLACE '%SY-DATUM%' WITH ao_datum INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%KOSTENSTELLE%'.
        REPLACE '%KOSTENSTELLE%' WITH joblist_file-kostl
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

      ELSEIF reproliste-line CS '%KUNDENNAME%'.
        REPLACE '%KUNDENNAME%' WITH joblist_file-name1
                                              INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%LINES.CLF%'.
        tabix = sy-tabix + 1.
        EXIT.

      ELSE.
        APPEND reproliste.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

  LOOP AT itab_test INTO wa_test.

    CLEAR t2_bapi_doc_files2.

    IF wa_test-checked = 'X'.

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
          documentdata               = bapi_doc_draw2
          return                     = bapiret2
        TABLES
*         OBJECTLINKS                =
*         DOCUMENTDESCRIPTIONS       =
*         LONGTEXTS                  =
*         STATUSLOG                  =
          documentfiles              = t1_bapi_doc_files2
*         COMPONENTS                 =
                .

      IF t1_bapi_doc_files2 IS INITIAL.
        MESSAGE e028(zcvn) WITH wa_test-dokar wa_test-doknr
                                wa_test-doktl wa_test-dokvr.
      ENDIF.

      LOOP AT t1_bapi_doc_files2 INTO wa1_bapi_doc_files2
                                        WHERE docfile = wa_test-filep.

*       Temporary Variable to accept filepath.
        DATA : tmp_bapi_check_path TYPE bapi_doc_aux-filename.

        MOVE tmp_new_dirname TO tmp_bapi_check_path .

        CONCATENATE tmp_bapi_check_path '\' INTO tmp_bapi_check_path.

        CLEAR t2_bapi_doc_files2.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 30
            text       = text-079.

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
*                     getcomponents       = 'X'
                  originalpath        = tmp_bapi_check_path
*                  originalpath        = temp_path
*                     hostname            = ' '
                  getheader           = 'X'
*                     docbomchangenumber  =
*                     docbomvalidfrom     =
*                     docbomrevisionlevel =
*                 IMPORTING
*                      return              = bapiret2
             TABLES
*                     documentstructure   =
                  documentfiles       = t2_bapi_doc_files2
                  .
        IF t2_bapi_doc_files2 IS INITIAL.
          MESSAGE e030(zcvn) WITH tmp_bapi_check_path RAISING error.
        ENDIF.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 30
            text       = text-079.

      ENDLOOP.

    ELSE.     "CLF Files................

*     If the Original File is not Checkedin try to copy
*     the file from the source to the destination.

      DATA : tmp_obj_source TYPE string,
             tmp_destiny    TYPE string.

      CLEAR tmp_obj_source.
      CLEAR tmp_destiny.
      CLEAR z_stripped_name.
      CLEAR z_file_path.
      CLEAR z_full_name.

      MOVE wa_test-filep TO z_full_name.
      MOVE i_down_path TO tmp_destiny.

      IF NOT ( z_full_name IS INITIAL ). " Modified on 27thSept.2002

        CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
          EXPORTING
            full_name     = z_full_name
          IMPORTING
            stripped_name = z_stripped_name
            file_path     = z_file_path
          EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          MESSAGE e036(zcvn) WITH '' RAISING error.
        ENDIF.

        CONCATENATE tmp_destiny h1 '\' z_stripped_name INTO tmp_destiny.
        MOVE z_full_name TO tmp_obj_source.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 50
            text       = text-081.

        CALL METHOD obj_frontend_services->file_copy
          EXPORTING
            SOURCE             = tmp_obj_source
            DESTINATION        = tmp_destiny
*         overwrite          = space
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
          MESSAGE e016(zcvn) WITH tmp_obj_source tmp_destiny '' ''
                                                          RAISING error.
        ENDIF.
      ELSE.  " Modified on 27thSept.2002
      ENDIF. " Modified on 27thSept.2002


      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 50
          text       = text-081.
    ENDIF.

*   Process the Job-Data Parameter in CLF File using skeleton line Data.
    REFRESH x_lines.


    LOOP AT it_repli_skeleton_lines INTO wa_repli_skeleton_lines.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 30
          text       = text-082.

      MOVE wa_repli_skeleton_lines-line TO x_lines-line.

      IF x_lines-line CS '%NAMING%'.
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
        IF NOT ( t2_bapi_doc_files2[] IS INITIAL ).

          CLEAR z_stripped_name.
          CLEAR z_file_path.
          CLEAR z_full_name.

          IF wa_test-filep IS INITIAL.
*            CONCATENATE 'AO$_PATH=' ao_naming INTO x_lines-line+1.
            CONCATENATE 'AO$_PATH=' wa_test-dokar '_'
                         wa_test-doknr '_' wa_test-doktl '_'
                         wa_test-dokvr  INTO x_lines-line+1.
          ELSE.
            MOVE wa_test-filep TO z_full_name.

            CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
              EXPORTING
                full_name     = z_full_name
              IMPORTING
                stripped_name = z_stripped_name
                file_path     = z_file_path
              EXCEPTIONS
                x_error       = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
              MESSAGE e036(zcvn) WITH '' RAISING error.
            ENDIF.

            CONCATENATE 'AO$_PATH=' tmp_bapi_check_path
                              z_stripped_name INTO x_lines-line+1.
          ENDIF.

        ELSE.

          CONCATENATE 'AO$_PATH=' tmp_destiny INTO x_lines-line+1.
        ENDIF.

        CLEAR tmp_destiny.
        CLEAR t2_bapi_doc_files2.

        APPEND x_lines.

      ELSEIF x_lines-line CS '%FORMAT%'.

        IF i_format_checking EQ space.
          REPLACE '%FORMAT%' WITH wa_test-format_ausgabe
                                            INTO x_lines-line.
          APPEND x_lines.
        ELSE.
        ENDIF.

      ELSEIF x_lines-line CS '%COPIES%'.
        CLEAR no_copies.
        MOVE wa_test-kopien TO no_copies.
        REPLACE '%COPIES%' WITH no_copies INTO x_lines-line.
        APPEND x_lines.
        CLEAR no_copies.

      ELSEIF x_lines-line CS '%PRINTMODE%'.

        IF i_out_proc EQ 'X'.
          REPLACE '%PRINTMODE%' WITH ao_print INTO x_lines-line.
        ELSE.
          REPLACE '%PRINTMODE%' WITH '1' INTO x_lines-line.
        ENDIF.

        APPEND x_lines.

      ELSEIF x_lines-line CS '%NUMBER%'.
        REPLACE '%NUMBER%' WITH wa_test-doknr
                INTO x_lines-line.
        APPEND x_lines.
      ELSEIF x_lines-line CS '%APPLICATION%'.
        REPLACE '%APPLICATION%' WITH ao_appl INTO
                x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%DELETE%'.
        REPLACE '%DELETE%' WITH i_delete_status INTO
                x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS '%VIEWNAME%'.
        REPLACE '%VIEWNAME%' WITH ao_viewname INTO
                                  x_lines-line.
        APPEND x_lines.
      ELSEIF x_lines-line CS '%SAVECONVERTAS%'.
        REPLACE '%SAVECONVERTAS%' WITH ao_save INTO
                                 x_lines-line.
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

    CLEAR t2_bapi_doc_files2.

  ENDLOOP.

  LOOP AT repli_skeleton FROM tabix.
    MOVE repli_skeleton-line TO reproliste-line.
    APPEND reproliste.
  ENDLOOP.


* Download Reprolistdatei to the required destination.
  SEARCH reproliste FOR 'AOFB'.

  IF sy-subrc = 0.

    APPEND 'AO2LE' TO reproliste.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 50
        text       = text-085.

    DATA lc_fname TYPE rs38l_fnam.
    CLEAR lc_fname.
    lc_fname = 'WS_DOWNLOAD'.

    "CALL FUNCTION 'WS_DOWNLOAD'
    CALL FUNCTION lc_fname
      EXPORTING
        filename                = x_filename
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
      MESSAGE e037(zcvn) WITH x_filename.
    ENDIF.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 50
        text       = text-086.


  ELSE.
    MESSAGE e034(zcvn) RAISING error.
  ENDIF.


ENDFUNCTION.
