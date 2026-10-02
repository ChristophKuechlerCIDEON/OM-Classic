FUNCTION z_cl_plot_list.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(I_FILTER) TYPE  C DEFAULT '*.*'
*"     VALUE(I_PPL_DOWN_PATH) TYPE  STRING OPTIONAL
*"     VALUE(I_TEST_CHECK) TYPE  C DEFAULT 'X'
*"     VALUE(I_DEFAULT_USER) TYPE  XUBNAME OPTIONAL
*"  TABLES
*"      T_ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*&--------------------------------------------------------------------&*
*& Function Group : ZPLOT_INTERFACE                                   &*
*& Function Z_CL_PLOT_LIST                                            &*
*& Author : Srinivas.Mamillapalli@CIDEON-Software.de                  &*
*&--------------------------------------------------------------------&*
*& This Function Module contains the logic of creating a new PPL file &*
*& every time . The downloaded PPL File combines with Username and    &*
*& and Timestamp for the unique name.                                 &*
*&--------------------------------------------------------------------&*

  MOVE 'C:\TEMP\CV04N\' TO i_down_path.
  CREATE OBJECT obj_frontend .


  CLEAR :  rtf_special_check ,
           rtf_deck_check,
           rtf_inhalts_check,
           rtf_ende_check.

  MOVE i_ppl_down_path TO d_drive_path .
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF dir_exist EQ space.
    REPLACE 'C:\' WITH 'D:\' INTO d_drive_path.
  ENDIF.


  REFRESH t_zcl_s_plotlist.

  SORT t_itab_test BY doknr.

  LOOP AT t_itab_test.
    APPEND t_itab_test TO t_zcl_s_plotlist.

    IF sy-tabix = 1.
      MOVE t_itab_test TO joblist_file.
    ENDIF.

  ENDLOOP.

  APPEND joblist_file.

  DELETE ADJACENT DUPLICATES FROM t_itab_test COMPARING dokar
                                                      doknr
                                                      dokvr
                                                      doktl.

  LOOP AT t_itab_test.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 10
        text       = text-003.

*   Get the details for each of the dokument...
    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = t_itab_test-dokar
        documentnumber             = t_itab_test-doknr
        documentpart               = t_itab_test-doktl
        documentversion            = t_itab_test-dokvr
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
*       GETACTIVEFILES             = 'X'
*     IMPORTING
*       DOCUMENTDATA               =
*       RETURN                     =
     TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
       documentfiles              = t1_bapi_doc_files2
*       COMPONENTS                 =
              .


    LOOP AT t1_bapi_doc_files2.

      MOVE t1_bapi_doc_files2 TO t_bapi_doc_files2.

      MOVE t_itab_test-dokar TO t_bapi_doc_files2-documenttype.
      MOVE t_itab_test-doknr TO t_bapi_doc_files2-documentnumber.
      MOVE t_itab_test-dokvr TO t_bapi_doc_files2-documentversion.
      MOVE t_itab_test-doktl TO t_bapi_doc_files2-documentpart.

      APPEND t_bapi_doc_files2.
      CLEAR t1_bapi_doc_files2.

    ENDLOOP.

  ENDLOOP.

*************************
** Check for the directory existance in which all the files will
** be downloaded or copied.

  CALL METHOD obj_frontend->file_exist
    EXPORTING
      file            = i_down_path
    RECEIVING
      result          = dir_exist
    EXCEPTIONS
      cntl_error      = 1
      error_no_gui    = 2
      wrong_parameter = 3
      OTHERS          = 4.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF dir_exist EQ space. "If the directory is not exist

    CALL METHOD obj_frontend->directory_create
      EXPORTING
        directory                = i_down_path
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
    IF sy-subrc = 6.
    ELSEIF sy-subrc = 0.
      MESSAGE i002(zcvn) WITH 'A new' 'directory at' 'C:\Temp\CV04N\'
                                                            'created.'.
    ELSE.
      MESSAGE i002(zcvn) WITH 'There is' 'a Problem with the Method'
            'obj_frontend->directory_create'.
    ENDIF.

  ENDIF.
************************************
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
      percentage = 10
      text       = text-006.


  CALL FUNCTION 'Z_CL_READ_SKELETON'
    EXPORTING
      i_uname     = sy-uname
    TABLES
      o_itab_data = it_repli_skeleton
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  IF sy-dbcnt = 0.
  IF sy-subrc NE 0.
    CALL FUNCTION 'Z_CL_READ_SKELETON'
      EXPORTING
        i_uname     = i_default_user
      TABLES
        o_itab_data = it_repli_skeleton
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 10
      text       = text-007.

  CALL FUNCTION 'Z_CL_READ_SKELETON_LINES'
    EXPORTING
      i_uname     = sy-uname
    TABLES
      o_itab_data = it_repli_lines
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  IF sy-dbcnt = 0.
  IF sy-subrc NE 0.
    CALL FUNCTION 'Z_CL_READ_SKELETON_LINES'
      EXPORTING
        i_uname     = i_default_user
      TABLES
        o_itab_data = it_repli_lines
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

**********************************************
* Montieren der Repro-Listdatei Kopfdaten ...
  LOOP AT it_repli_skeleton INTO wa_repli_skeleton.

    LOOP AT joblist_file.

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

        DATA : proirity(2) TYPE c.
        MOVE joblist_file-prio TO proirity.
        SHIFT proirity LEFT  DELETING LEADING  '0'.
*        SHIFT proirity RIGHT DELETING TRAILING '0'.
      ELSEIF reproliste-line CS '%PRIORITY%'.
        REPLACE '%PRIORITY%' WITH proirity INTO reproliste-line.
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


  CLEAR percentage .
  CLEAR next_level.
  CLEAR no_lines.

  DESCRIBE TABLE t_zcl_s_plotlist LINES no_lines.

***********************
  LOOP AT t_zcl_s_plotlist .

    next_level = 100 DIV no_lines.

    percentage = percentage + next_level.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = percentage
        text       = text-002.


    IF t_zcl_s_plotlist-knz_fehl_blatt EQ space.

      IF t_zcl_s_plotlist-checked = 'X'.

        CLEAR t2_bapi_doc_files2.

        LOOP AT t_bapi_doc_files2
                     WHERE docfile = t_zcl_s_plotlist-filep.

          MOVE t_bapi_doc_files2 TO t2_bapi_doc_files2.

        ENDLOOP.

        APPEND t2_bapi_doc_files2.

        CLEAR t1_bapi_doc_files2.

        MOVE i_down_path TO temp_path.

* Download the file(s) if they R 'CHEKEDIN'
        CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
             EXPORTING
                  documenttype        = t_zcl_s_plotlist-dokar
                  documentnumber      = t_zcl_s_plotlist-doknr
                  documentpart        = t_zcl_s_plotlist-doktl
                  documentversion     = t_zcl_s_plotlist-dokvr
                  documentfile        = t2_bapi_doc_files2
                  getstructure        = '1'
                  getcomponents       = 'X'
                  originalpath        = temp_path
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

        IF sy-subrc = 0.

        ENDIF.

      ELSEIF t_zcl_s_plotlist-filep CS ':'.

        CLEAR tmp_dirname.

        MOVE i_down_path TO tmp_dirname.

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
*                   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.


        CALL FUNCTION 'STRING_CONCATENATE'
          EXPORTING
            string1   = tmp_dirname
            string2   = stripped_name
          IMPORTING
            string    = tmp_dirname
          EXCEPTIONS
            too_small = 1
            OTHERS    = 2.
        IF sy-subrc <> 0.
*                   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        CLEAR destination.
        CLEAR source.

        MOVE split_full_path TO source.
        MOVE tmp_dirname TO destination.


        CALL METHOD obj_frontend->file_copy
          EXPORTING
            SOURCE             = SOURCE
            destination        = destination
*        OVERWRITE          = SPACE
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
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.

******************************************
      CLEAR x_filename.
      CLEAR gv_stru-y_filename.

* Modification on 30.08.2002............( Begin )
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
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*      SET LOCALE LANGUAGE stru-langu.

      MOVE x_filename TO gv_stru-y_filename.
      MOVE 'D' TO gv_stru-langu.

      IF gv_stru-langu = sy-langu.
        TRANSLATE gv_stru-y_filename TO LOWER CASE.
      ELSE.
      ENDIF.

      MOVE gv_stru-y_filename TO x_filename .


* If the AutoORG software not installed in the directory
* 'C:\' then it processes with the directory 'D:\'.
      IF  x_filename CS 'C:\'.
      ELSEIF x_filename NS 'C:\'.
        CONCATENATE d_drive_path x_filename INTO x_filename.
      ENDIF.

      CLEAR stripped_name.
      CLEAR file_path.

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

*  Create an unique file name to process the data with
*  the DECK/ENDE/INHALTSBLATT.

      IF t_zcl_s_plotlist-deckblatt NE space.

        IF rtf_special_check EQ space.

          CALL FUNCTION 'Z_CL_DECKBLATT'
            EXPORTING
              i_down_deckblatt = x_filename
              i_strip_name     = stripped_name
            IMPORTING
              e_deck_down_path = deck_down
            TABLES
              t_deck_list      = joblist_file
            EXCEPTIONS
              error            = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

        ENDIF.
      ELSE.
      ENDIF.


      IF t_zcl_s_plotlist-endeblatt NE space.

        IF rtf_special_check EQ space.

          CALL FUNCTION 'Z_CL_ENDEBLATT'
            EXPORTING
              i_down_endeblatt = x_filename
              i_strip_name     = stripped_name
            IMPORTING
              e_ende_down_path = ende_down
            TABLES
              t_ende_list      = joblist_file
            EXCEPTIONS
              error            = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

        ENDIF.
      ELSE.


      ENDIF.

* Checking with the length of 'Ja' or 'Nein'. When len_knz_inhalt_vz
* length is 2 means 'Ja'. Then try to make an INHALTSBLATT.
      DATA : len_knz_inhalt_vz TYPE i.
      CLEAR len_knz_inhalt_vz.

      len_knz_inhalt_vz = STRLEN( t_zcl_s_plotlist-knz_inhalt_vz ).

      IF rtf_special_check EQ space.

        IF len_knz_inhalt_vz EQ 2.

          CALL FUNCTION 'Z_CL_INHALTSBLATT'
            EXPORTING
              i_down_inhaltsblatt = x_filename
              i_strip_name        = stripped_name
            IMPORTING
              e_inhalts_down_path = inhalts_down
            TABLES
              t_inhalts_list      = joblist_file
            EXCEPTIONS
              error               = 1
              OTHERS              = 2.
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          rtf_special_check = 'X'.
*      ELSE.
        ENDIF.
      ENDIF.
* Modification on 30.08.2002............( Ende )
******************************************
      REFRESH x_lines.

      LOOP AT it_repli_lines INTO wa_repli_lines.

        MOVE wa_repli_lines-line TO x_lines-line.

        IF x_lines-line CS '%ERASE%'.
          REPLACE '%ERASE%' WITH t_zcl_s_plotlist-lochen
                                          INTO x_lines-line.
          APPEND x_lines.

*    ELSEIF x_lines-line CS '%PROJECT%'.
*      REPLACE '%PROJECT%' WITH t_zcl_s_plotlist-lochen
*                                      INTO x_lines-line.
*      APPEND x_lines.

        ELSEIF x_lines-line CS '%PATH%'.
          CONCATENATE 'AO$_PATH=' t_zcl_s_plotlist-filep
                  INTO x_lines-line+1 .
          APPEND x_lines.

        ELSEIF x_lines-line CS '%BEARB1%'.
          REPLACE '%BEARB1%' WITH sy-uname INTO x_lines-line.
          APPEND x_lines.

*    ELSEIF x_lines-line CS '%KONSTRUK%'.
*      REPLACE '%KONSTRUK%' WITH
*           wa_draw_last_change-created_by INTO x_lines-line.
*      APPEND x_lines.
*
*    ELSEIF x_lines-line CS '%BEARB2%'.
*
*      REPLACE '%BEARB2%' WITH
*           wa_draw_last_change-changed_by INTO x_lines-line.
*      APPEND x_lines.

        ELSEIF x_lines-line CS '%FORMAT%'.
          REPLACE '%FORMAT%' WITH t_zcl_s_plotlist-wsapplication
                   INTO x_lines-line.
          APPEND x_lines.

        ELSEIF x_lines-line CS '%COPIES%'.
          MOVE t_zcl_s_plotlist-kopien TO tmp_copies.

          REPLACE '%COPIES%' WITH tmp_copies
                                  INTO x_lines-line.
          APPEND x_lines.
        ELSEIF x_lines-line CS '%DELETE%'.
          REPLACE '%DELETE%' WITH t_zcl_s_plotlist-lochen INTO
                                            x_lines-line.
          APPEND x_lines.
*    ELSEIF x_lines-line CS '%PRINTMODE%'.
*      REPLACE '%PRINTMODE%' WITH ao_print INTO x_lines-line.
*      APPEND x_lines.
        ELSEIF x_lines-line CS '%NUMBER%'.
          REPLACE '%NUMBER%' WITH t_zcl_s_plotlist-doknr
                  INTO x_lines-line.
          APPEND x_lines.
*    ELSEIF x_lines-line CS '%APPLICATION%'.
*      REPLACE '%APPLICATION%' WITH ao_appl INTO
*              x_lines-line.
*      APPEND x_lines.
*    ELSEIF x_lines-line CS '%VIEWNAME%'.
*      REPLACE '%VIEWNAME%' WITH ao_viewname INTO
*                                x_lines-line.
*      APPEND x_lines.
*    ELSEIF x_lines-line CS '%SAVECONVERTAS%'.
*      REPLACE '%SAVECONVERTAS%' WITH ao_save INTO
*                               x_lines-line.
*      APPEND x_lines.
*
        ELSEIF x_lines-line CS 'SAP$=%DVS%'.  "User-Felder
          CLEAR x_lines-line.


***********************************************************************
          IF ppl_special_check EQ space.

            LOOP AT joblist_file.
* Process of DECKBLATT für Plotjob.................RTF
              IF ( ppl_deck_check EQ space AND
                                joblist_file-deckblatt NE space ) .

*                CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*                     EXPORTING
*                          percentage = 25
*                          text       = text-009.

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

                CONCATENATE 'APPL$_PATH = ' deck_down
                                                    INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_RESOLUTION = '
                        t_zcl_s_plotlist-aufloesung INTO x_lines-line+1.
                APPEND x_lines.

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

                CONCATENATE 'APPL$_FOLD = '
                            t_zcl_s_plotlist-falten INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_PUNCH = '
                            t_zcl_s_plotlist-lochen INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_TYPE = '
                         t_zcl_s_plotlist-appl_type INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_COMPRESSION = '
                         t_zcl_s_plotlist-appl_comp INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_FORMAT = ' 'A4' INTO x_lines-line+1.
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

*                CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*                     EXPORTING
*                          percentage = 25
*                          text       = text-010.


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

                CONCATENATE 'APPL$_PATH = ' inhalts_down
                                                    INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_RESOLUTION = '
                        t_zcl_s_plotlist-aufloesung INTO x_lines-line+1.
                APPEND x_lines.

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

                CONCATENATE 'APPL$_FOLD = '
                            t_zcl_s_plotlist-falten INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_PUNCH = '
                            t_zcl_s_plotlist-lochen INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_TYPE = '
                         t_zcl_s_plotlist-appl_type INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_COMPRESSION = '
                         t_zcl_s_plotlist-appl_comp INTO x_lines-line+1.
                APPEND x_lines.

                CONCATENATE 'APPL$_FORMAT = ' 'A4' INTO x_lines-line+1.
                APPEND x_lines.


                MOVE 'AOFE' TO x_lines.
                APPEND x_lines.

                MOVE 'AOFB' TO x_lines.
                APPEND x_lines.

                CLEAR x_lines.
                ppl_inhalts_check = 'X'.
              ENDIF.
            ENDLOOP.
*        ELSE.
          ENDIF.

***********************************************************************
          CONCATENATE 'APPL$_KIND = ' '1'
                                    INTO x_lines-line+1.
          APPEND x_lines.


          CONCATENATE 'APPL$_ERASE = ' '0' INTO x_lines-line+1.
          APPEND x_lines.


          CLEAR stripped_name.
          CLEAR file_path.

*        IF t_zcl_s_plotlist-knz_fehl_blatt EQ space.
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          CONCATENATE 'APPL$_PATH = ' moved_directory
                                                INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_RESOLUTION = '
                       t_zcl_s_plotlist-aufloesung INTO x_lines-line+1.
          APPEND x_lines.

*          CONCATENATE 'APPL$_COMPRESSION = '
*                     t_zcl_s_plotlist-kompression INTO x_lines-line+1.
*          APPEND x_lines.

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

          CONCATENATE 'APPL$_FOLD = '
                      t_zcl_s_plotlist-falten INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_PUNCH = '
                       t_zcl_s_plotlist-lochen INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_BINDINGEDGE = '
                    t_zcl_s_plotlist-heftrand INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_STAMP = '
                        t_zcl_s_plotlist-stempel INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_FORMAT = '
                  t_zcl_s_plotlist-format_ausgabe INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_FORMATTYPE = '
                  t_zcl_s_plotlist-format_ausgabe INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_TARGETFORMAT = '
                  t_zcl_s_plotlist-format_ausgabe INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_OFFSETXY = '
                      t_zcl_s_plotlist-verschiebung INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_TYPE = '
                      t_zcl_s_plotlist-appl_type INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_COMPRESSION = '
                      t_zcl_s_plotlist-appl_comp INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_PENTABLE = '
                      t_zcl_s_plotlist-stifttabelle INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_ORIENTATION = ' 'Auto' INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_COVERTED = ' '0' INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_CORRECTIONX = ' '1'
                                        INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_CORRECTIONY = ' '1'
                                        INTO x_lines-line+1.
          APPEND x_lines.

          CONCATENATE 'APPL$_DAPPL1 = '
                     t_zcl_s_plotlist-wsapplication INTO x_lines-line+1.
          APPEND x_lines.

          IF t_zcl_s_plotlist-seite NE space.
            CONCATENATE 'APPL$_PAGES = '
                        t_zcl_s_plotlist-seite INTO x_lines-line+1.
            APPEND x_lines.
          ELSE.
          ENDIF.

        ELSE.
          APPEND x_lines.
        ENDIF.
      ENDLOOP.

      LOOP AT x_lines .
        MOVE x_lines TO reproliste-line.
        APPEND reproliste.
      ENDLOOP.

    ELSE.
      MOVE t_zcl_s_plotlist TO job_fehllist.
      APPEND job_fehllist.
    ENDIF.
  ENDLOOP. "End of Loop t_zcl_s_plotlist.


**********************************&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&6


**  CLEAR reproliste.
  IF NOT ( job_fehllist IS INITIAL ).
    APPEND reproliste.

    LOOP AT job_fehllist.

*      IF  reproliste CS 'AOFB'.
*      ELSE.
      MOVE 'AOFB' TO reproliste.
      APPEND reproliste.
*      ENDIF.


      CONCATENATE 'APPL$_KIND = ' '1' INTO reproliste-line.
      SHIFT reproliste-line RIGHT BY 1 PLACES.
      APPEND reproliste.

      CONCATENATE 'APPL$_ERASE = ' '0' INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE job_fehllist-dokar '_'
                  job_fehllist-doknr '_'
                  job_fehllist-dokvr '_'
                  job_fehllist-doktl
                  INTO fehl_doc_detail.

      CONCATENATE 'APPL$_ORIGINALNAME = ' fehl_doc_detail
                                    INTO reproliste-line+1.
      APPEND reproliste.


      CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO reproliste-line+1.
      APPEND reproliste.


      CONCATENATE 'APPL$_PATH = ' 'C:\' fehl_doc_detail
                                        INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_RESOLUTION = ' job_fehllist-aufloesung
                                            INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_TARGETFORMAT = ' job_fehllist-format_ausgabe
                                               INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_COMPRESSION = '
               job_fehllist-kompression INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_TYPE = '
                       job_fehllist-typ INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_SCALINGX = '
               job_fehllist-skalieren_x INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_SCALINGY = '
               job_fehllist-skalieren_y INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_MEDIUM = '
                    job_fehllist-medium INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_ROTATE ='
                    job_fehllist-drehen INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_MIRROR = '
                  job_fehllist-spiegeln INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_TYPE = '
                         job_fehllist-typ INTO reproliste-line+1.
      APPEND reproliste.

      CLEAR num_copy.
      MOVE job_fehllist-kopien TO num_copy.
      CONCATENATE 'APPL$_COPY = '  num_copy INTO reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_FOLD = '
                  job_fehllist-falten INTO  reproliste-line+1.
      APPEND reproliste.

      CONCATENATE 'APPL$_PUNCH = '
                   job_fehllist-lochen INTO reproliste-line+1.
      APPEND reproliste.

      MOVE 'AOFE' TO reproliste.
      APPEND reproliste.

    ENDLOOP.
  ENDIF.
*******&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&6


*  The name of the unique directory to which all the files concerned
*  to this plotlist.
  CONCATENATE i_down_path h1 INTO dir_create.

  CLEAR rc.

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

  CALL METHOD obj_frontend->directory_list_files
  EXPORTING
  directory                   = i_down_path
  filter                      = '*.*'
  files_only                  = 'X'
*       DIRECTORIES_ONLY            =
  CHANGING
  file_table                  = it_file_info
  count                       = count_files
  EXCEPTIONS
  cntl_error                  = 1
  directory_list_files_failed = 2
  wrong_parameter             = 3
  error_no_gui                = 4
  OTHERS                      = 5
    .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



  CLEAR no_lines.
  CLEAR next_level.
  CLEAR percentage.

  DESCRIBE TABLE it_file_info LINES no_lines.


  LOOP AT it_file_info INTO wa_file_info.


    next_level = 100 DIV no_lines.

    percentage = percentage + next_level.

*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              percentage = percentage
*              text       = text-008.

    CLEAR rc.
    CLEAR destination.
    CLEAR source.


    CONCATENATE dir_create '\' wa_file_info-filename INTO destination.
    CONCATENATE i_down_path  wa_file_info-filename INTO source.

    CALL METHOD obj_frontend->file_copy
      EXPORTING
        SOURCE             = SOURCE
        destination        = destination
        overwrite          = 'X'
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
        OTHERS             = 12.
    IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDLOOP.


  DATA: i TYPE i,
  j TYPE i.

  CLEAR i.
  CLEAR j.

  LOOP AT reproliste.

*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              percentage = 20
*              text       = text-004.


    SEARCH reproliste FOR 'APPL$_KIND =' STARTING AT k.

    IF sy-tabix LT 1.
      CLEAR reproliste-line.
      EXIT.
    ENDIF.

    MOVE tabix TO j.
    IF sy-tabix LT 1.
      EXIT.

    ELSE.
      SEARCH reproliste FOR 'APPL$_PATH =C:\TEMP\CV04N\' STARTING AT k.
      IF sy-tabix LT 1.
        CLEAR reproliste-line.
        EXIT.
      ENDIF.

      READ TABLE reproliste INDEX sy-tabix.
      SPLIT reproliste-line AT 'N' INTO p1 p2.
      CONCATENATE p1 'N\' h1 p2 INTO reproliste-line+1.
      SHIFT reproliste-line BY 1 PLACES LEFT.
      MODIFY reproliste INDEX sy-tabix.

      CLEAR: p1, p2.
      CLEAR k.

      MOVE sy-tabix TO k.
      k = k + 1.

    ENDIF.
  ENDLOOP.

  CLEAR i.
  CLEAR j.


  LOOP AT reproliste.

*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              percentage = 20
*              text       = text-004.

    i = sy-tabix.
    IF reproliste-line = 'AOFB'.
      i = i + 1.
      READ TABLE reproliste INDEX i.
      IF reproliste-line = ' SAP$=%DVS%'.
        j = i + 1.
        READ TABLE reproliste INDEX j.
        IF reproliste-line = 'AOFE'.
          DELETE reproliste INDEX sy-tabix.
          DELETE reproliste INDEX j.
          DELETE reproliste INDEX i.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
  ENDLOOP.


  CLEAR i.
  CLEAR j.

*  SET LOCALE LANGUAGE stru-langu.
*
*  MOVE x_filename TO stru-y_filename.
*  stru-langu = 'D'.
*
*  IF stru-langu = sy-langu.
*    TRANSLATE stru-y_filename TO LOWER CASE.
*  ELSE.
*  ENDIF.
*
*  MOVE stru-y_filename TO x_filename .



*  IF NOT ( job_fehllist IS INITIAL ).
*    CALL FUNCTION 'Z_CL_FEHLBLATT'
*         EXPORTING
*              i_file         = x_filename
*              i_strip_name   = stripped_name
*         IMPORTING
*              e_fehl_down    = fehl_down
*         TABLES
*              t_fehl_list    = job_fehllist
*              t_job_fehllist = joblist_file
*         EXCEPTIONS
*              error          = 1
*              OTHERS         = 2.
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*  ENDIF.


  CLEAR ppl_ende_check .

  CLEAR reproliste.

  IF NOT ( reproliste[] IS INITIAL ).

    LOOP AT joblist_file.

*      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*           EXPORTING
*                percentage = 25
*                text       = text-005.

      IF ( ppl_ende_check EQ space AND joblist_file-endeblatt NE space ).

        MOVE 'AOFB' TO reproliste.
        APPEND reproliste.

        CONCATENATE 'APPL$_KIND = ' '3' INTO reproliste-line.
        SHIFT reproliste-line RIGHT BY 1 PLACES.
        APPEND reproliste.

        CONCATENATE 'APPL$_ERASE = ' '0' INTO reproliste-line+1.
        APPEND reproliste.

        CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
             EXPORTING
*                  full_name     = endeblatt
                   full_name = ende_down
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

        CONCATENATE 'APPL$_PATH = ' ende_down INTO reproliste-line+1.
        APPEND reproliste.

        CONCATENATE 'APPL$_ONLY_PATH = ' '1' INTO reproliste-line+1.
        APPEND reproliste.


        CONCATENATE 'APPL$_RESOLUTION = ' joblist_file-aufloesung
                                              INTO reproliste-line+1.
        APPEND reproliste.

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

        CONCATENATE 'APPL$_FOLD = '
                    joblist_file-falten INTO  reproliste-line+1.
        APPEND reproliste.

        CONCATENATE 'APPL$_PUNCH = '
                     joblist_file-lochen INTO reproliste-line+1.
        APPEND reproliste.

        CONCATENATE 'APPL$_TYPE = '
                      joblist_file-appl_type INTO reproliste-line+1.
        APPEND reproliste.

        CONCATENATE 'APPL$_COMPRESSION = '
                      joblist_file-appl_comp INTO reproliste-line+1.
        APPEND reproliste.

        CONCATENATE 'APPL$_FORMAT = ' 'A4' INTO reproliste-line+1.
        APPEND reproliste.

        MOVE 'AOFE' TO reproliste.
        APPEND reproliste.

        ppl_deck_check = 'X'.

      ENDIF.

    ENDLOOP.

  ELSE.
*    MESSAGE e002(zcvn) WITH 'There are' 'no proper'
*                  'Documents to' 'Process further :-( '.
  ENDIF.
*******************************
  CLEAR filename .
  IF NOT ( reproliste IS INITIAL ).
    IF x_filename NE space .

      MOVE 'AOFILES-END' TO reproliste.
      APPEND reproliste.

      DATA lc_fname TYPE rs38l_fnam.
      CLEAR lc_fname.
      lc_fname = 'WS_DOWNLOAD'.

      "CALL FUNCTION 'WS_DOWNLOAD'
      CALL FUNCTION lc_fname
       EXPORTING
*   BIN_FILESIZE                  = ' '
*   CODEPAGE                      = ' '
         filename                      = x_filename
*   FILETYPE                      = 'ASC'
*   MODE                          = ' '
*   WK1_N_FORMAT                  = ' '
*   WK1_N_SIZE                    = ' '
*   WK1_T_FORMAT                  = ' '
*   WK1_T_SIZE                    = ' '
*   COL_SELECT                    = ' '
*   COL_SELECTMASK                = ' '
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
        TABLES
          data_tab                      = reproliste
*   FIELDNAMES                    =
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
  ENDIF.

  MOVE i_down_path TO delete_source.


  CALL FUNCTION 'Z_CL_DELETE_FILES_IN_TMP'
    EXPORTING
      path                   = delete_source
      file_type              = i_filter
    TABLES
      table_of_files_deleted = table_of_files1
      table_of_dir_occured   = table_of_direcs1
    EXCEPTIONS
      error                  = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFUNCTION.
