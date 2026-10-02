FUNCTION z_cl_ppl_files_plot_list .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(FILTER) TYPE  C DEFAULT '*.*'
*"     VALUE(I_PPL_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(TEST) TYPE  C DEFAULT 'X'
*"     VALUE(DEFAULT_USER) TYPE  XUBNAME DEFAULT 'SAP*'
*"  TABLES
*"      ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*&--------------------------------------------------------------------&*
*&NOTICE: THis Function Module will be executed only when the Import  &*
*&        Parameter ' I_OUT_PROC ' is not Initial.There by a CLF File &*
*&        will be created on the Server.If ' I_OUT_PROC ' initialised &*
*&        then other Function Module will be executed to create       &*
*&        a PPL File on the Server. This Import Parameter can be      &*
*&        Activated by the User Customizing Data of PlottingSolution  &*
*&--------------------------------------------------------------------&*

*&--------------------------------------------------------------------&*
*& Function Group  : ZPLOT_INTERFACE                                  &*
*& Function Module : Z_CL_CLF_FILES_PLOT_LIST                         &*
*& Author          : Srinivas.Mamillapalli@CIDEON-Software.de         &*
*&--------------------------------------------------------------------&*
*& This Function Module contains the logic of creating a new PPL file &*
*& every time . The downloaded PPL File combines with Username and    &*
*& and Timestamp for the unique name.                                 &*
*&--------------------------------------------------------------------&*

  DATA : obj_frontend TYPE REF TO cl_gui_frontend_services.
  DATA : fehl_doc_detail(40) TYPE c.
  DATA : ppl_special_check TYPE c,
         ppl_deck_check  TYPE c,
         ppl_inhalts_check  TYPE c,
         ppl_ende_check  TYPE c,
         ppl_fehl_check  TYPE c.

  DATA : rtf_special_check TYPE c,
         rtf_deck_check  TYPE c,
         rtf_inhalts_check  TYPE c,
         rtf_ende_check  TYPE c,
         rtf_fehl_check  TYPE c,
         aofb_aofe_check TYPE c.

  DATA : no_lines_in_job_fehllist TYPE i,
         n TYPE i VALUE 1.

  DATA : no_lines_in_itab_exist_files TYPE i,
         m TYPE i VALUE 1.

  DATA : tmp_dirname       LIKE rlgrap-filename,
         stripped_name     LIKE rlgrap-filename,
         file_path         LIKE rlgrap-filename,
         split_full_path   LIKE rlgrap-filename,
         moved_directory   LIKE rlgrap-filename,
         h1                LIKE rlgrap-filename,
         h2                LIKE rlgrap-filename,
         p1                LIKE rlgrap-filename,
         p2                LIKE rlgrap-filename,
         deck_down         LIKE rlgrap-filename,
         ende_down         LIKE rlgrap-filename,
         inhalts_down      LIKE rlgrap-filename,
         fehl_down         LIKE rlgrap-filename.



  DATA : t_zcl_s_plotlist TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE,
         joblist_file     TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE,
         job_fehllist     TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE,
         itab_exist_files TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE.

  DATA : t_bapi_doc_files2    TYPE bapi_doc_files2 OCCURS 0
                                                WITH HEADER LINE,
         t1_bapi_doc_files2   TYPE bapi_doc_files2 OCCURS 0
                                                WITH HEADER LINE,
         t2_bapi_doc_files2   TYPE bapi_doc_files2 OCCURS 0
                                                WITH HEADER LINE,
         t3_bapi_doc_files2   TYPE bapi_doc_files2 OCCURS 0
                                                WITH HEADER LINE.

  DATA : ao_datum(10),
         tabix            TYPE sy-tabix,
         file             TYPE string,
         dir_exist        TYPE c,
         rc               TYPE i,
         count_files      TYPE i,
         tmp_copies       TYPE c,
         check            TYPE c,
         num_copy         TYPE c,
         dir_create       TYPE string,
         k                TYPE sy-tabix VALUE 1,
         filename_to_down TYPE string,
         temp_path        LIKE bapi_doc_aux-filename,
         x_filename       LIKE rlgrap-filename,
         d_drive_path LIKE rlgrap-filename.

*
  DATA : it_file_info TYPE TABLE OF file_info,
         wa_file_info TYPE file_info.

* An internal table to read number of files available in
* in a particular directory.
  DATA : it_file_table TYPE STANDARD TABLE OF file_table,
         wa_file_table TYPE file_table.

  DATA :  it_repli_skeleton TYPE STANDARD TABLE OF zcl_s_line_256,
          wa_repli_skeleton TYPE zcl_s_line_256.

  DATA : it_repli_lines TYPE STANDARD TABLE OF zcl_s_line_256,
         wa_repli_lines TYPE zcl_s_line_256.


* An internal table to modify or insert..from or to any internal tables.
  DATA : BEGIN OF reproliste OCCURS 50,
              line(1000),
          END OF reproliste.

* An internal table to modify or insert..from or to any internal tables.
  DATA : BEGIN OF x_lines OCCURS 20,
          line(1000),
         END OF x_lines.

  DATA : destination TYPE string,
         source TYPE string.

  DATA : itab_paper_format TYPE STANDARD TABLE OF zcl_paper_format,
         wa_paper_format   TYPE zcl_paper_format.

  DATA : lv_ppl_filename LIKE rlgrap-filename.

  DATA : it_bapi_doc_draw2 TYPE bapi_doc_draw2 OCCURS 0
                                          WITH HEADER LINE,
         it_bapiret2 TYPE bapiret2 OCCURS 0
                                          WITH HEADER LINE.

************************************************************************

  CREATE OBJECT obj_frontend .

  SELECT * FROM zcl_paper_format INTO TABLE itab_paper_format.

  CLEAR :  rtf_special_check ,
           rtf_deck_check,
           rtf_inhalts_check,
           rtf_ende_check,
           d_drive_path.

  CLEAR t_zcl_s_plotlist.

  SORT itab_test BY doknr.

  LOOP AT itab_test.
    IF sy-tabix = 1.
*Take a line from 'ITAB_TEST'for the sake of the Job Data
*in the PPL file.
      APPEND itab_test TO joblist_file.
    ELSE.
    ENDIF.
    IF itab_test-knz_fehl_blatt EQ space.
      APPEND itab_test TO itab_exist_files.
    ELSE.
      APPEND itab_test TO job_fehllist.
    ENDIF.
    APPEND itab_test TO t_zcl_s_plotlist.
  ENDLOOP.


  DELETE ADJACENT DUPLICATES FROM itab_test COMPARING dokar
                                                      doknr
                                                      dokvr
                                                      doktl.

  MOVE i_down_path TO d_drive_path .

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 45
      text       = text-100.


  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
     fname                = d_drive_path
   IMPORTING
     exist                = dir_exist
*   ISDIR                =
*   FILESIZE             =
 EXCEPTIONS
   fileinfo_error       = 1
   OTHERS               = 2
            .
  IF sy-subrc <> 0.
* Create a directory at ,if it is not existing.
    CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
      EXPORTING
       dirname        = d_drive_path
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

*****************
* These 2 Function Modules will down load the data from the data base
* dependding upon the USER who is executing this function Module.
* The data is already existing in the data base which is to be UPLOADED
* or MODIFIED by the USER with Function Module'Z_CL_UPDATE_SKELETON'
* and 'Z_CL_UPDATE_SKELETON_LINES'. These Functin Modules are existing
* in the function Group 'ZCL_PLINT_TOOLS'.


* If SKELETON and SKELETON_LINES data is not available with with the
* USER name then a DEFAULT_USER data will be dowloaded. The data with
* the DEFAULT_USER always available in the data base table. So this data
* will be available for the processing.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 15
      text       = text-101.


  CALL FUNCTION 'Z_CL_READ_SKELETON'
    EXPORTING
      i_uname     = sy-uname
    TABLES
      o_itab_data = it_repli_skeleton
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    CALL FUNCTION 'Z_CL_READ_SKELETON'
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

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 15
      text       = text-102.


  CALL FUNCTION 'Z_CL_READ_SKELETON_LINES'
    EXPORTING
      i_uname     = sy-uname
    TABLES
      o_itab_data = it_repli_lines
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    CALL FUNCTION 'Z_CL_READ_SKELETON_LINES'
      EXPORTING
        i_uname     = default_user
      TABLES
        o_itab_data = it_repli_lines
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
      MESSAGE e014(zcvn) RAISING error.
    ENDIF.

  ENDIF.

  CALL FUNCTION 'FILE_GET_NAME'
           EXPORTING
*              CLIENT                  = SY-MANDT
               logical_filename        = 'ZZ_REPRO_LNA_STANDARD'
                operating_system        = sy-opsys
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
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  MOVE x_filename TO lv_ppl_filename.

  CLEAR stripped_name.
  CLEAR file_path.

  CONCATENATE i_ppl_down_path x_filename INTO x_filename.

  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = x_filename
    IMPORTING
      stripped_name = stripped_name
      file_path     = file_path
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SPLIT stripped_name AT '.' INTO h1 h2.

  CONCATENATE i_down_path h1 INTO dir_create.

  CLEAR rc.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 15
      text       = text-103.


  CALL METHOD obj_frontend->directory_create
    EXPORTING
      directory                = dir_create
    CHANGING
      rc                       = rc
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT joblist_file.

    LOOP AT it_repli_skeleton INTO wa_repli_skeleton.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 30
          text       = text-083.

      MOVE wa_repli_skeleton-line TO reproliste-line.

      IF reproliste-line CS 'AOPPL-LIST_1.0'.
        APPEND reproliste.

      ELSEIF reproliste-line CS 'AOJOB-BEGIN'.
        APPEND reproliste.

      ELSEIF reproliste-line CS 'AOFILES-BEGIN'.
        APPEND reproliste.

      ELSEIF reproliste-line CS 'AOJOB-END'.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%SY-UNAME%'.
        REPLACE '%SY-UNAME%' WITH sy-uname INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%SENDER%'.
        REPLACE '%SENDER%' WITH sy-uname INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%OUTPUTDEVICE%'.
        REPLACE '%OUTPUTDEVICE%' WITH joblist_file-ausgabegeraet
                                          INTO reproliste-line.
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

      ELSEIF reproliste-line CS '%ACCOUNT%'.
        REPLACE '%ACCOUNT%' WITH sy-uname INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%JOBCOUNT%'.
        REPLACE '%JOBCOUNT%' WITH '1' INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%DISTRIBUTOR%'.
        REPLACE '%DISTRIBUTOR%' WITH joblist_file-ausgabegeraet
                                                 INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%TARGET%'.
        REPLACE '%TARGET%' WITH '1' INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%SEPARATOR%'.
        REPLACE '%SEPARATOR%' WITH '-' INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%PRIORITY%'.
        REPLACE '%PRIORITY%' WITH joblist_file-prio
                                            INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%NAME1%'.
        REPLACE '%NAME1%' WITH joblist_file-name1 INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%FIRMA%'.
        REPLACE '%FIRMA%' WITH  joblist_file-firma INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%STREET%'.
        REPLACE '%STREET%' WITH joblist_file-stras INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%CITY%'.
        REPLACE '%CITY%' WITH joblist_file-ort1 INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%PLZ%'.
        REPLACE '%PLZ%' WITH joblist_file-pstlz INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%PHONE%'.
        REPLACE '%PHONE%' WITH joblist_file-telf1 INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%FAX%'.
        REPLACE '%FAX%' WITH joblist_file-telfx INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS '%MAILID%'.
        REPLACE '%MAILID%' WITH joblist_file-smtp_addr
                                         INTO reproliste-line.
        APPEND reproliste.

      ELSEIF reproliste-line CS 'AOFILES-END'.
        CLEAR reproliste.
        EXIT.

      ELSEIF reproliste-line CS '%LINES.CLF%'.
        tabix = sy-tabix + 1.

        LOOP AT it_repli_lines INTO wa_repli_lines.

          APPEND wa_repli_lines  TO reproliste.

        ENDLOOP.
        EXIT.

      ENDIF.
    ENDLOOP.
  ENDLOOP.


  LOOP AT t_zcl_s_plotlist.

    IF t_zcl_s_plotlist-knz_fehl_blatt EQ space.

      IF t_zcl_s_plotlist-checked = 'X'.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 30
            text       = text-084.

        CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
          EXPORTING
            documenttype               = t_zcl_s_plotlist-dokar
            documentnumber             = t_zcl_s_plotlist-doknr
            documentpart               = t_zcl_s_plotlist-doktl
            documentversion            = t_zcl_s_plotlist-dokvr
*           GETOBJECTLINKS             = ' '
*           GETCOMPONENTS              = ' '
*           GETSTATUSLOG               = ' '
*           GETLONGTEXTS               = ' '
*           GETACTIVEFILES             = 'X'
*           GETCLASSIFICATION          = ' '
*           GETSTRUCTURE               = ' '
*           GETWHEREUSED               = ' '
*           HOSTNAME                   = ' '
         IMPORTING
           documentdata               = it_bapi_doc_draw2
           return                     = it_bapiret2
         TABLES
*          OBJECTLINKS                =
*          DOCUMENTDESCRIPTIONS       =
*          LONGTEXTS                  =
*          STATUSLOG                  =
           documentfiles              = t1_bapi_doc_files2
*          COMPONENTS                 =
*          CHARACTERISTICVALUES       =
*          CLASSALLOCATIONS           =
*          DOCUMENTSTRUCTURE          =
*          WHEREUSEDLIST              =
                  .


        LOOP AT t1_bapi_doc_files2 INTO t2_bapi_doc_files2
                            WHERE docfile = t_zcl_s_plotlist-filep.
          APPEND t2_bapi_doc_files2.
        ENDLOOP.


**       Temporary Variable to accept BAPI filepath for download.
        DATA : tmp_bapi_check_path TYPE bapi_doc_aux-filename.
        CLEAR tmp_bapi_check_path.
        CLEAR t3_bapi_doc_files2.

        MOVE dir_create TO tmp_bapi_check_path .
        CONCATENATE tmp_bapi_check_path '\' INTO tmp_bapi_check_path.

        MOVE i_down_path TO temp_path.


        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 30
            text       = text-079.


* Download the file(s) if they R 'CHEKEDIN'
        CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
             EXPORTING
                  documenttype        = t_zcl_s_plotlist-dokar
                  documentnumber      = t_zcl_s_plotlist-doknr
                  documentpart        = t_zcl_s_plotlist-doktl
                  documentversion     = t_zcl_s_plotlist-dokvr
                  documentfile        = t2_bapi_doc_files2
                  getstructure        = '1'
*                  getcomponents       = 'X'
                  originalpath        = tmp_bapi_check_path
*                     hostname            = ' '
                  getheader           = 'X'
*                     docbomchangenumber  =
*                     docbomvalidfrom     =
*                     docbomrevisionlevel =
*                 IMPORTING
*                      return              = bapiret2
             TABLES
*                     documentstructure   =
                  documentfiles       = t3_bapi_doc_files2
                  .

        IF t3_bapi_doc_files2 IS INITIAL.
          MESSAGE e030(zcvn) WITH temp_path RAISING error.
        ENDIF.

        CLEAR t3_bapi_doc_files2.

      ELSE.      "PPL Files................

        MOVE i_down_path TO destination.
        MOVE t_zcl_s_plotlist-filep TO split_full_path.

        CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
          EXPORTING
            full_name     = split_full_path
          IMPORTING
            stripped_name = stripped_name
            file_path     = file_path
          EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          MESSAGE e036(zcvn) WITH '' RAISING error.
        ENDIF.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 50
            text       = text-081.


        CONCATENATE destination h1 '\' stripped_name INTO destination.

        MOVE split_full_path TO source.

        CALL METHOD obj_frontend->file_copy
          EXPORTING
            SOURCE             = SOURCE
            destination        = destination
*           OVERWRITE          = SPACE
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
          MESSAGE e016(zcvn) WITH source destination '' ''
                                                      RAISING error.
        ENDIF.
      ENDIF.
    ENDIF.

*  Create an unique file name to process the data with
*  the DECK/ENDE/INHALTSBLATT.

    IF t_zcl_s_plotlist-deckblatt NE space.

      IF rtf_special_check EQ space.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 45
            text       = text-104.

        CALL FUNCTION 'Z_CL_DECKBLATT'
          EXPORTING
            i_down_deckblatt = x_filename
            i_strip_name     = lv_ppl_filename
          IMPORTING
            e_deck_down_path = deck_down
          TABLES
            t_deck_list      = joblist_file
          EXCEPTIONS
            error            = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

      ELSE.
      ENDIF.

    ENDIF.

    IF t_zcl_s_plotlist-endeblatt NE space.

      IF rtf_special_check EQ space.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 45
            text       = text-105.

        CALL FUNCTION 'Z_CL_ENDEBLATT'
          EXPORTING
            i_down_endeblatt = x_filename
            i_strip_name     = lv_ppl_filename
          IMPORTING
            e_ende_down_path = ende_down
          TABLES
            t_ende_list      = joblist_file
          EXCEPTIONS
            error            = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

      ELSE.
      ENDIF.

    ENDIF.

*** Checking with the length of 'Ja' or 'Nein'. When len_knz_inhalt_vz
*** length is 2 means 'Ja'. Then try to make an INHALTSBLATT.

    DATA : len_knz_inhalt_vz TYPE i.
    CLEAR len_knz_inhalt_vz.

    len_knz_inhalt_vz = STRLEN( t_zcl_s_plotlist-knz_inhalt_vz ).

    IF rtf_special_check EQ space.

      IF len_knz_inhalt_vz EQ 2.

        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = 45
            text       = text-106.

        CALL FUNCTION 'Z_CL_INHALTSBLATT'
          EXPORTING
            i_down_inhaltsblatt = x_filename
            i_strip_name        = lv_ppl_filename
          IMPORTING
            e_inhalts_down_path = inhalts_down
          TABLES
            t_inhalts_list      = joblist_file
          EXCEPTIONS
            error               = 1
            OTHERS              = 2.
        IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        rtf_special_check = 'X'.
      ELSE.
      ENDIF.
    ENDIF.

    REFRESH x_lines.

    LOOP AT it_repli_lines INTO wa_repli_lines.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 30
          text       = text-082.

      MOVE wa_repli_lines-line TO x_lines-line.

      IF x_lines-line CS '%DELETE%'.
        REPLACE '%DELETE%' WITH t_zcl_s_plotlist-lochen INTO
                                          x_lines-line.
        APPEND x_lines.

      ELSEIF x_lines-line CS 'AO$_PATH='.
        CONCATENATE 'AO$_PATH=' t_zcl_s_plotlist-filep
                INTO x_lines-line+1 .
        APPEND x_lines.

      ELSEIF x_lines-line CS 'SAP$=%DVS%'.  "User-Felder
        CLEAR x_lines-line.

        IF ppl_special_check EQ space.

          LOOP AT joblist_file.
* Process of DECKBLATT für Plotjob.................RTF
            IF ( ppl_deck_check EQ space AND
                              joblist_file-deckblatt NE space ) .

              CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                EXPORTING
                  percentage = 45
                  text       = text-107.


              CONCATENATE 'APPL$_KIND = ' '2'
                                        INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_KIND = ' '2'
                                        INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_ERASE = ' '0' INTO x_lines-line+1.
              APPEND x_lines.

              CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
                EXPORTING
                  full_name     = deck_down
                IMPORTING
                  stripped_name = stripped_name
                  file_path     = file_path
                EXCEPTIONS
                  x_error       = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.

              CONCATENATE 'APPL$_ORIGINALNAME = ' stripped_name
                                            INTO x_lines-line+1.
              APPEND x_lines.


              CONCATENATE 'APPL$_ONLY_PATH = ' '0' INTO x_lines-line+1.
              APPEND x_lines.

              CLEAR stripped_name.
              CLEAR file_path.

              SPLIT deck_down AT 'scan' INTO stripped_name file_path.
              CONCATENATE 'APPL$_PATH = ' file_path
                                                  INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_RESOLUTION = '
                      t_zcl_s_plotlist-aufloesung INTO x_lines-line+1.
              APPEND x_lines.

              LOOP AT itab_paper_format INTO
                          wa_paper_format WHERE paper_format = 'A4'.

                CONCATENATE 'APPL$_TARGETFORMAT = '
                      wa_paper_format-paper_index INTO x_lines-line+1.
                APPEND x_lines.
              ENDLOOP.

              CONCATENATE 'APPL$_SCALINGX = '
                     t_zcl_s_plotlist-skalieren_x INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_SCALINGY = '
                     t_zcl_s_plotlist-skalieren_y INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_MEDIUM = '
                          t_zcl_s_plotlist-medium INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_ROTATE ='
                          t_zcl_s_plotlist-drehen INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_MIRROR = '
                        t_zcl_s_plotlist-spiegeln INTO x_lines-line+1.
              APPEND x_lines.

              MOVE t_zcl_s_plotlist-kopien TO num_copy.
              CONCATENATE 'APPL$_COPY = '  num_copy INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_FOLD = ' 'nein' INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_PUNCH = '
                          t_zcl_s_plotlist-lochen INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_FORMAT = ' 'A4' INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_TYPE = '
                       t_zcl_s_plotlist-appl_type INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_COMPRESSION = '
                       t_zcl_s_plotlist-appl_comp INTO x_lines-line+1.
              APPEND x_lines.

              MOVE 'AOFE' TO x_lines.
              APPEND x_lines.

              MOVE 'AOFB' TO x_lines.
              APPEND x_lines.

              CLEAR  x_lines.
              ppl_deck_check = 'X'.
            ENDIF.

* Process of INHALTSVERZEICHNIS........RTF
            IF ( ppl_inhalts_check EQ space AND
                              joblist_file-knz_inhalt_vz EQ 'JA' ) .

*            'APPL$_KIND = 4' means it is an Inhaltsblatt.rtf.
              CONCATENATE 'APPL$_KIND = ' '4' INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_ERASE = ' '0' INTO x_lines-line+1.
              APPEND x_lines.

              CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
                EXPORTING
                  full_name     = inhalts_down
                IMPORTING
                  stripped_name = stripped_name
                  file_path     = file_path
                EXCEPTIONS
                  x_error       = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.

              CONCATENATE 'APPL$_ORIGINALNAME = ' stripped_name
                                            INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_ONLY_PATH = ' '0' INTO x_lines-line+1.
              APPEND x_lines.


              CLEAR stripped_name.
              CLEAR file_path.

              SPLIT inhalts_down AT 'scan' INTO stripped_name file_path.
              CONCATENATE 'APPL$_PATH = ' file_path
                                                  INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_RESOLUTION = '
                      t_zcl_s_plotlist-aufloesung INTO x_lines-line+1.
              APPEND x_lines.

************************************
              LOOP AT itab_paper_format INTO
                          wa_paper_format WHERE paper_format = 'A4'.

                CONCATENATE 'APPL$_TARGETFORMAT = '
                      wa_paper_format-paper_index INTO x_lines-line+1.
                APPEND x_lines.
              ENDLOOP.

************************************
              CONCATENATE 'APPL$_SCALINGX = '
                     t_zcl_s_plotlist-skalieren_x INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_SCALINGY = '
                     t_zcl_s_plotlist-skalieren_y INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_MEDIUM = '
                          t_zcl_s_plotlist-medium INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_ROTATE ='
                          t_zcl_s_plotlist-drehen INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_MIRROR = '
                        t_zcl_s_plotlist-spiegeln INTO x_lines-line+1.
              APPEND x_lines.

              MOVE t_zcl_s_plotlist-kopien TO num_copy.
              CONCATENATE 'APPL$_COPY = '  num_copy INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_FOLD = ' 'nein' INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_PUNCH = '
                          t_zcl_s_plotlist-lochen INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_FORMAT = ' 'A4' INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_TYPE = '
                       t_zcl_s_plotlist-appl_type INTO x_lines-line+1.
              APPEND x_lines.

              CONCATENATE 'APPL$_COMPRESSION = '
                       t_zcl_s_plotlist-appl_comp INTO x_lines-line+1.
              APPEND x_lines.

              MOVE 'AOFE' TO x_lines.
              APPEND x_lines.

              MOVE 'AOFB' TO x_lines.
              APPEND x_lines.

              CLEAR x_lines.
              ppl_inhalts_check = 'X'.
            ENDIF.
            ppl_special_check = 'X'.

          ENDLOOP.
        ELSE.
        ENDIF.

**********************************************************************
* Precess the Failed Documents which a PPL file can not found/Process.
        DESCRIBE TABLE job_fehllist LINES no_lines_in_job_fehllist.

        LOOP AT job_fehllist.

          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 45
              text       = text-108.

          CONCATENATE 'APPL$_KIND = ' '1' INTO x_lines-line.
          SHIFT x_lines-line RIGHT BY 1 PLACES.
          APPEND x_lines.

          CONCATENATE 'APPL$_ERASE = ' '0' INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE job_fehllist-dokar '_'
                      job_fehllist-doknr '_'
                      job_fehllist-dokvr '_'
                      job_fehllist-doktl
                      INTO fehl_doc_detail.

          CONCATENATE 'APPL$_ORIGINALNAME = ' fehl_doc_detail
                                        INTO x_lines-line+1.
          APPEND x_lines.


          CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO x_lines-line+1.
          APPEND x_lines.


          CONCATENATE 'APPL$_PATH = ' 'C:\' fehl_doc_detail
                                            INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_RESOLUTION = ' job_fehllist-aufloesung
                                                INTO x_lines-line+1.
          APPEND x_lines.

          LOOP AT itab_paper_format INTO
                wa_paper_format WHERE paper_format =
                                   job_fehllist-format_ausgabe.
            CONCATENATE 'APPL$_TARGETFORMAT = '
                wa_paper_format-paper_index INTO x_lines-line+1.
            APPEND x_lines.
          ENDLOOP.


          CONCATENATE 'APPL$_SCALINGX = '
                   job_fehllist-skalieren_x INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_SCALINGY = '
                   job_fehllist-skalieren_y INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_MEDIUM = '
                        job_fehllist-medium INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_ROTATE ='
                        job_fehllist-drehen INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_MIRROR = '
                      job_fehllist-spiegeln INTO x_lines-line+1.
          APPEND x_lines.

          CLEAR num_copy.
          MOVE job_fehllist-kopien TO num_copy.
          CONCATENATE 'APPL$_COPY = '  num_copy INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_FOLD = '
                      job_fehllist-falten INTO  x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_PUNCH = '
                       job_fehllist-lochen INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_BINDINGEDGE = '
                    job_fehllist-heftrand INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_STAMP = '
                        job_fehllist-stempel INTO x_lines-line+1.
          APPEND x_lines.


          CONCATENATE 'APPL$_FORMAT = '
                  job_fehllist-format_ausgabe INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_PENTABLE = '
                    job_fehllist-stifttabelle INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_ORIENTATION = '
                      job_fehllist-ausrichtung INTO x_lines-line+1.
          APPEND x_lines.

*         If the document is converted by Client '1' else '0'.
*         For more details refer Doc-Manager.
*         But at this moment itz '0' as hard coded one.
          CONCATENATE 'APPL$_CONVERTED = ' '0' INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_CORRECTIONX = ' '1'
                                        INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_CORRECTIONY = ' '1'
                                        INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_DAPPL1 = '
                   job_fehllist-wsapplication INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_TYPE = '
                     job_fehllist-appl_type INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_COMPRESSION = '
                     job_fehllist-appl_comp INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_OFFSETXY = '
                     job_fehllist-verschiebung INTO x_lines-line+1.
          APPEND x_lines.

          IF job_fehllist-seite NE space.
            CONCATENATE 'APPL$_PAGES = '
                        job_fehllist-seite INTO x_lines-line+1.
            APPEND x_lines.
          ELSE.
          ENDIF.


          IF ( n EQ 1 AND no_lines_in_job_fehllist EQ 1 ).
            MOVE 'AOFE' TO x_lines.
            APPEND x_lines.

            MOVE 'AOFB' TO x_lines.
            APPEND x_lines.

          ELSEIF n NE no_lines_in_job_fehllist.
            MOVE 'AOFE' TO x_lines.
            APPEND x_lines.

            MOVE 'AOFB' TO x_lines.
            APPEND x_lines.
          ENDIF.

          n = n + 1.

        ENDLOOP.

        IF NOT ( job_fehllist IS INITIAL ) .
          IF aofb_aofe_check EQ space.
            IF ( x_lines-line NS 'AOFB' AND x_lines-line NS 'AOFE' ).
              APPEND 'AOFE' TO x_lines.
              APPEND 'AOFB' TO x_lines.
            ELSEIF x_lines-line CS 'AOFE'.
              APPEND 'AOFB' TO x_lines.
            ELSEIF x_lines-line CS 'AOFB'.
            ENDIF.
            aofb_aofe_check = 'X'.
          ENDIF.
        ENDIF.

        REFRESH job_fehllist.

***********************************************************************
        DESCRIBE TABLE itab_exist_files LINES no_lines_in_job_fehllist.

        LOOP AT itab_exist_files.

          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = 45
              text       = text-109.

          CONCATENATE 'APPL$_KIND = ' '1'
                                    INTO x_lines-line.
          SHIFT x_lines-line RIGHT BY 1 PLACES.

          APPEND x_lines.


          CONCATENATE 'APPL$_ERASE = ' '0' INTO x_lines-line+1.
          APPEND x_lines.


          CLEAR stripped_name.
          CLEAR file_path.

          MOVE itab_exist_files-filep TO split_full_path.

          CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
            EXPORTING
              full_name     = split_full_path
            IMPORTING
              stripped_name = stripped_name
              file_path     = file_path
            EXCEPTIONS
              x_error       = 1
              OTHERS        = 2.

          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          CONCATENATE 'APPL$_ORIGINALNAME = ' stripped_name
                                        INTO x_lines-line+1.
          APPEND x_lines.

          CALL FUNCTION 'STRING_CONCATENATE'
            EXPORTING
              string1   = i_down_path
              string2   = stripped_name
            IMPORTING
              string    = moved_directory
            EXCEPTIONS
              too_small = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_PATH = ' moved_directory
                                                INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_RESOLUTION = '
                      itab_exist_files-aufloesung INTO x_lines-line+1.
          APPEND x_lines.

************************************
          LOOP AT itab_paper_format INTO
            wa_paper_format WHERE
                  paper_format = itab_exist_files-format_ausgabe.

            CONCATENATE 'APPL$_TARGETFORMAT = '
                    wa_paper_format-paper_index INTO x_lines-line+1.
            APPEND x_lines.
          ENDLOOP.

************************************

          CONCATENATE 'APPL$_SCALINGX = '
                     itab_exist_files-skalieren_x INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_SCALINGY = '
                     itab_exist_files-skalieren_y INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_MEDIUM = '
                          itab_exist_files-medium INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_ROTATE ='
                          itab_exist_files-drehen INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_MIRROR = '
                        itab_exist_files-spiegeln INTO x_lines-line+1.
          APPEND x_lines.


          MOVE itab_exist_files-kopien TO num_copy.
          CONCATENATE 'APPL$_COPY = '  num_copy INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_FOLD = '
                      itab_exist_files-falten INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_PUNCH = '
                       itab_exist_files-lochen INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_BINDINGEDGE = '
                    itab_exist_files-heftrand INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_STAMP = '
                        itab_exist_files-stempel INTO x_lines-line+1.
          APPEND x_lines.


          CONCATENATE 'APPL$_FORMAT = '
                  itab_exist_files-format_ausgabe INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_PENTABLE = '
                    itab_exist_files-stifttabelle INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_ORIENTATION = '
                  itab_exist_files-ausrichtung
                                INTO x_lines-line+1.
          APPEND x_lines.

*         If the document is converted by Client '1' else '0'.
*         For more details refer Doc-Manager.
*         But at this moment itz '0' as hard coded one.
          CONCATENATE 'APPL$_CONVERTED = ' '0' INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_CORRECTIONX = ' '1'
                                        INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_CORRECTIONY = ' '1'
                                        INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_DAPPL1 = '
                   itab_exist_files-wsapplication INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_TYPE = '
                       itab_exist_files-appl_type INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_COMPRESSION = '
                       itab_exist_files-appl_comp INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_OFFSETXY = '
                    itab_exist_files-verschiebung INTO x_lines-line+1.
          APPEND x_lines.

*         Process only when this ITAB_EXIST_FILES-SEITE is filled with
*         some data.
          IF itab_exist_files-seite NE space.
            CONCATENATE 'APPL$_PAGES = '
                        itab_exist_files-seite INTO x_lines-line+1.
            APPEND x_lines.
          ELSE.
          ENDIF.


          IF ( m EQ 1 AND no_lines_in_itab_exist_files EQ 1 ).
            MOVE 'AOFE' TO x_lines.
            APPEND x_lines.

            MOVE 'AOFB' TO x_lines.
            APPEND x_lines.

          ELSEIF m NE no_lines_in_itab_exist_files.
            MOVE 'AOFE' TO x_lines.
            APPEND x_lines.

            MOVE 'AOFB' TO x_lines.
            APPEND x_lines.
          ENDIF.
          m = m + 1.
        ENDLOOP.

        REFRESH itab_exist_files. "Mittwoch,25.September2002...

      ELSE.
      ENDIF.

    ENDLOOP.

    LOOP AT x_lines .
      MOVE x_lines TO reproliste-line.
      APPEND reproliste.
    ENDLOOP.

    REFRESH x_lines.

  ENDLOOP. "End of Loop t_zcl_s_plotlist.

  DATA: tmp_i TYPE i, " Temporariy Variable
        tmp_j TYPE i. " Temporariy Variable

  CLEAR tmp_i.
  CLEAR tmp_j.

  LOOP AT reproliste.
    tmp_i = sy-tabix.
    IF reproliste-line = 'AOFB'.
      tmp_i = tmp_i + 1.
      READ TABLE reproliste INDEX tmp_i.
      IF reproliste-line = ' SAP$=%DVS%'.
        tmp_j = tmp_i + 1.
        READ TABLE reproliste INDEX tmp_j.
        IF reproliste-line = 'AOFE'.
          DELETE reproliste INDEX sy-tabix.
          DELETE reproliste INDEX tmp_j.
          DELETE reproliste INDEX tmp_i.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


  CLEAR tmp_i.
  CLEAR tmp_j.
******************************
  CLEAR ppl_ende_check .

  LOOP AT joblist_file.

    CLEAR reproliste.

    IF ( ppl_ende_check EQ space AND joblist_file-endeblatt NE space ).

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 45
          text       = text-110.

      IF reproliste-line CS 'AOFE'.
        APPEND 'AOFB' TO reproliste.
      ELSEIF reproliste-line CS 'AOFB'.
      ENDIF.

*     'APPL$_KIND = 3' means it is an Endblatt.rtf.
      CONCATENATE 'APPL$_KIND = ' '3' INTO reproliste-line.
      SHIFT reproliste-line RIGHT BY 1 PLACES.
      APPEND reproliste.

      CONCATENATE 'APPL$_ERASE = ' '0' INTO reproliste-line+1.
      APPEND reproliste.

      CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
        EXPORTING
          full_name     = ende_down
        IMPORTING
          stripped_name = stripped_name
          file_path     = file_path
        EXCEPTIONS
          x_error       = 1
          OTHERS        = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CONCATENATE 'APPL$_ORIGINALNAME = ' stripped_name
                                    INTO reproliste-line+1.
      APPEND reproliste.


      CONCATENATE 'APPL$_ONLY_PATH = ' '0' INTO reproliste-line+1.
      APPEND reproliste.

      CLEAR stripped_name.
      CLEAR file_path.

      SPLIT ende_down AT 'scan' INTO stripped_name file_path.


      CONCATENATE 'APPL$_PATH = ' file_path INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_RESOLUTION = ' joblist_file-aufloesung
                                            INTO reproliste-line+1.
      APPEND reproliste.

      LOOP AT itab_paper_format INTO
          wa_paper_format WHERE paper_format = 'A4'.

        CONCATENATE 'APPL$_TARGETFORMAT = '
                wa_paper_format-paper_index INTO reproliste-line+1.
        APPEND reproliste.
      ENDLOOP.

      CONCATENATE 'APPL$_SCALINGX = '
               joblist_file-skalieren_x INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_SCALINGY = '
               joblist_file-skalieren_y INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_MEDIUM = '
                    joblist_file-medium INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_ROTATE ='
                    joblist_file-drehen INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_MIRROR = '
                  joblist_file-spiegeln INTO reproliste-line+1.
      APPEND reproliste.

      CLEAR num_copy.
      MOVE joblist_file-kopien TO num_copy.
      CONCATENATE 'APPL$_COPY = '  num_copy INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_FOLD = ' 'nein' INTO  reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_PUNCH = '
                   joblist_file-lochen INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_FORMAT = ' 'A4' INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_TYPE = '
                     joblist_file-appl_type INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_COMPRESSION = '
                     joblist_file-appl_comp INTO reproliste-line+1.
      APPEND reproliste.

      MOVE 'AOFE' TO reproliste.
      APPEND reproliste.

      ppl_ende_check = 'X'.

    ENDIF.

  ENDLOOP.

  MOVE 'AOFILES-END' TO reproliste.
  APPEND reproliste.

  CLEAR filename .
  IF x_filename NE space.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 45
        text       = text-111.

    DATA lc_fname TYPE rs38l_fnam.
    CLEAR lc_fname.
    lc_fname = 'WS_DOWNLOAD'.

    "CALL FUNCTION 'WS_DOWNLOAD'
    CALL FUNCTION lc_fname
     EXPORTING
*      BIN_FILESIZE                  = ' '
*      CODEPAGE                      = ' '
        filename                      = x_filename
*      FILETYPE                      = 'ASC'
*      MODE                          = ' '
*      WK1_N_FORMAT                  = ' '
*      WK1_N_SIZE                    = ' '
*      WK1_T_FORMAT                  = ' '
*      WK1_T_SIZE                    = ' '
*      COL_SELECT                    = ' '
*      COL_SELECTMASK                = ' '
*      NO_AUTH_CHECK                 = ' '
*   IMPORTING
*      FILELENGTH                    =
     TABLES
        data_tab                      = reproliste
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
  ENDIF.

ENDFUNCTION.
