FUNCTION z_cl_upload_back_to_sap_repos.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_DIR) TYPE  SDOKPATH
*"     VALUE(I_TRESOR) TYPE  DTTRG
*"  EXCEPTIONS
*"      ERROR
*"      NO_FILES
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------

* TYPE
  TYPES: BEGIN OF t_cid2,
           originaltype LIKE bapi_doc_files2-originaltype,
           docfile LIKE bapi_doc_files2-docfile,
         END OF t_cid2.

* ITAB
  DATA: itab_file TYPE TABLE OF sdokpath.
  DATA: itab_dir           TYPE TABLE OF sdokpath.
  DATA : tmp_itab_local_data TYPE TABLE OF bapi_doc_files2,
         tmp_wa_local_data TYPE bapi_doc_files2.
  DATA: itab_cid1 TYPE TABLE OF bapi_doc_files2.
  DATA: itab_cid2 TYPE TABLE OF t_cid2.

* WA
  DATA: wa_file          TYPE sdokpath.
  DATA: wa_cid1 TYPE bapi_doc_files2.
  DATA: wa_cid2 TYPE t_cid2.
  DATA: wa_tmp_local_data TYPE bapi_doc_files2.

* NORMAL
  DATA : lv_file_count      TYPE i,
         lv_dir_count       TYPE i,
         lv_selected_folder LIKE rlgrap-filename,
         tmp_chosen_folder  LIKE rlgrap-filename,
         dir_string         LIKE rlgrap-filename.

  DATA : lv_return TYPE bapiret2.

  DATA : wa_dir           TYPE rlgrap-filename.

  DATA: tresor TYPE dttrg.

  DATA : lv_cid1_file_path LIKE rlgrap-filename,
         lv_cid2_file_path LIKE rlgrap-filename.

  DATA : lv_stripped_name LIKE rlgrap-filename,
         lv_file_path     LIKE rlgrap-filename.


  DATA : itab_documentfiles TYPE bapi_doc_files2
                                          OCCURS 0 WITH HEADER LINE,
         wa_documentfiles   TYPE bapi_doc_files2.

  wa_dir = i_wa_dir.
  tresor = i_tresor.

* clear content
  REFRESH itab_file.
  REFRESH itab_dir.

* get the file list
  MOVE wa_dir TO dir_string.


  CLEAR lv_stripped_name.
  CLEAR lv_file_path.

  CHECK NOT dir_string IS INITIAL.
  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = dir_string
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


  CONCATENATE  wa_dir '\' INTO wa_dir.

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
    EXPORTING
      directory  = wa_dir
      filter     = '*.*'
    IMPORTING
      file_count = lv_file_count
      dir_count  = lv_dir_count
    TABLES
      file_table = itab_file
      dir_table  = itab_dir
    EXCEPTIONS
      cntl_error = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
    MESSAGE s002(zcl_konv)
      WITH wa_dir '' '' ''
      RAISING error.
    EXIT.
  ENDIF.

  IF itab_file[] IS INITIAL.
    MESSAGE s004(zcl_konv)
      WITH wa_dir '' '' ''
      RAISING no_files.
    EXIT.
  ELSE.
  ENDIF.

  CONCATENATE wa_dir lv_stripped_name '.CID1'
                                      INTO lv_cid1_file_path .

  CONCATENATE wa_dir lv_stripped_name '.CID2'
                                      INTO lv_cid2_file_path .


* DELETE CIDEON  1 and CIDEON 2 from itab_file
  LOOP AT itab_file INTO wa_file.

    DATA : tmp_doc_file LIKE rlgrap-filename.

    CLEAR tmp_doc_file.

    IF lv_cid1_file_path CS wa_file .
      DELETE TABLE itab_file FROM wa_file.
    ELSEIF lv_cid2_file_path CS wa_file .
      DELETE TABLE itab_file FROM wa_file.
    ELSE.
    ENDIF.

  ENDLOOP.


* read CIDEON 1

  REFRESH itab_cid1.


  DATA lc_fname TYPE rs38l_fnam.
  CLEAR lc_fname.
  lc_fname = 'WS_UPLOAD'.

  CALL FUNCTION lc_fname
   EXPORTING
*     CODEPAGE                      = ' '
     filename                      = lv_cid1_file_path
     filetype                      = 'DAT'
*     HEADLEN                       = ' '
*     LINE_EXIT                     = ' '
*     TRUNCLEN                      = ' '
*     USER_FORM                     = ' '
*     USER_PROG                     = ' '
*     DAT_D_FORMAT                  = ' '
*   IMPORTING
*     FILELENGTH                    =
    TABLES
      data_tab                      = itab_cid1
   EXCEPTIONS
     conversion_error              = 1
     file_open_error               = 2
     file_read_error               = 3
     invalid_type                  = 4
     no_batch                      = 5
     unknown_error                 = 6
     invalid_table_width           = 7
     gui_refuse_filetransfer       = 8
     customer_error                = 9
     OTHERS                        = 10
            .
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    MESSAGE s005(zcl_konv)
      WITH lv_cid1_file_path '' '' ''
      RAISING error.
    EXIT.
  ENDIF.


* read CIDEON 2

  REFRESH itab_cid2.


  CLEAR lc_fname.
  lc_fname = 'WS_UPLOAD'.

  CALL FUNCTION lc_fname
   EXPORTING
*     CODEPAGE                      = ' '
     filename                      = lv_cid2_file_path
     filetype                      = 'DAT'
*     HEADLEN                       = ' '
*     LINE_EXIT                     = ' '
*     TRUNCLEN                      = ' '
*     USER_FORM                     = ' '
*     USER_PROG                     = ' '
*     DAT_D_FORMAT                  = ' '
*   IMPORTING
*     FILELENGTH                    =
    TABLES
      data_tab                      = itab_cid2
   EXCEPTIONS
     conversion_error              = 1
     file_open_error               = 2
     file_read_error               = 3
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
    MESSAGE s005(zcl_konv)
      WITH lv_cid2_file_path '' '' ''
      RAISING error.
    EXIT.

  ENDIF.

* make tmp_itab_local_data

  REFRESH tmp_itab_local_data.
  REFRESH itab_documentfiles.

*  break kuechler.

  LOOP AT itab_cid1 INTO wa_cid1.
    LOOP AT itab_cid2 INTO wa_cid2
      WHERE originaltype = wa_cid1-originaltype.
      CLEAR wa_tmp_local_data.
*      wa_tmp_local_data = wa_cid1.
      wa_tmp_local_data-docfile =  wa_cid2-docfile.

      TRANSLATE wa_tmp_local_data-docfile TO UPPER CASE.

      wa_tmp_local_data-wsapplication =  wa_cid1-wsapplication.
      wa_tmp_local_data-storagecategory =  wa_cid1-storagecategory.
      wa_tmp_local_data-application_id = wa_cid1-application_id.
      wa_tmp_local_data-file_id = wa_cid1-file_id.

*     tresor
      IF wa_tmp_local_data-file_id IS INITIAL.
        wa_tmp_local_data-originaltype = wa_cid1-originaltype.
      ELSE.
      ENDIF.

*      wa_tmp_local_data-originaltype = wa_cid1-originaltype.

      APPEND wa_tmp_local_data TO itab_documentfiles.
    ENDLOOP.
  ENDLOOP.

  IF itab_documentfiles[] IS INITIAL.
    EXIT.
  ELSE.
    READ TABLE itab_cid1 INTO wa_cid1 INDEX 1.
  ENDIF.

  CLEAR lv_return.

*  LOOP AT itab_documentfiles.
*    CLEAR itab_documentfiles-documenttype.
*    CLEAR itab_documentfiles-documentnumber.
*    CLEAR itab_documentfiles-documentpart.
*    CLEAR itab_documentfiles-documentversion.
*    MODIFY itab_documentfiles INDEX sy-tabix.
*  ENDLOOP.

*  CALL FUNCTION 'BAPI_DOCUMENT_CHECKIN2'
*    EXPORTING
*      documenttype            = wa_cid1-documenttype
*      documentnumber          = wa_cid1-documentnumber
*      documentpart            = wa_cid1-documentpart
*      documentversion         = wa_cid1-documentversion
**     HOSTNAME                = ' '
**     STATUSINTERN            = ' '
**     STATUSEXTERN            = ' '
**     STATUSLOG               = ' '
**     REVLEVEL                = ' '
**     AENNR                   = ' '
*   IMPORTING
*     return                  = lv_return
*    TABLES
*      documentfiles           = itab_documentfiles
**     COMPONENTS              =
**     DOCUMENTSTRUCTURE       =
*            .
*
*    IF NOT ( lv_return IS INITIAL ).
**      break steurich.
**      MESSAGE i056(zcvn) WITH lv_return-message.
*      WRITE lv_return INPUT ON.
*    ENDIF.
*
*
*  IF lv_return-type CA 'EA'.
*    ROLLBACK WORK.
*    MESSAGE ID '26' TYPE 'I' NUMBER '000'
*    WITH lv_return-message.
*  ELSE.
*    COMMIT WORK.
*  ENDIF.


  CALL FUNCTION 'BAPI_DOCUMENT_CHECKIN_REPLACE2'
    EXPORTING
      documenttype            = wa_cid1-documenttype
      documentnumber          = wa_cid1-documentnumber
      documentpart            = wa_cid1-documentpart
      documentversion         = wa_cid1-documentversion
*       HOSTNAME                = ' '
*       STATUSINTERN            = ' '
*       STATUSEXTERN            = ' '
*       STATUSLOG               = ' '
*       REVLEVEL                = ' '
*       AENNR                   = ' '
   IMPORTING
     return                   = lv_return
   TABLES
     documentfiles            = itab_documentfiles
*      COMPONENTS               =
*      DOCUMENTSTRUCTURE        =
            .

  IF NOT ( lv_return IS INITIAL ).
*      break steurich.
*      MESSAGE i056(zcvn) WITH lv_return-message.
    WRITE lv_return-message INPUT ON.
  ENDIF.



*  SORT itab_file.
*
** read CIDEON 1
*  PERFORM f_upload_cid1_dat_file USING lv_cid1_file_path.
*
** read CIDEON 2
*  PERFORM f_upload_cid2_dat_file USING lv_cid2_file_path.


*  IF itab_cid1[] IS INITIAL.
*    MESSAGE s005(zcl_konv)
*      WITH lv_cid1_file_path '' '' ''
*      RAISING error.
*    EXIT.
*  ELSE.
*  ENDIF.
*
*  IF itab_tab_cid2[] IS INITIAL.
*    MESSAGE s005(zcl_konv)
*      WITH lv_cid2_file_path '' '' ''
*      RAISING error.
*    EXIT.
*  ELSE.
*  ENDIF.


* Process files
*  LOOP AT itab_file INTO wa_file.
*
*  ENDLOOP.

*  LOOP AT itab_cid1 INTO wa_cid1.
*
*    LOOP AT itab_file INTO wa_file.
*
*      LOOP AT itab_tab_cid2 INTO wa_tab_cid2 WHERE
*                              number = wa_cid1-originaltype.
*
*
*
**      DATA : tmp_doc_file LIKE rlgrap-filename.
*        DATA : tmp_dokvr_i     TYPE i,
*               tmp_doktl_i     TYPE i,
*               tmp_dokvr_n(2)  TYPE n,
*               tmp_doktl_n(3)  TYPE n,
*               tmp_doknr_n(25)  TYPE n,
*               tmp_strlen      TYPE i,
*               tmp_only_flag   TYPE c,
*               tmp_char25(25)  TYPE c,
*               tmp_no_of_chars TYPE i.
*
*
*        CLEAR tmp_doc_file.
*
*        CONCATENATE wa_dir wa_file INTO tmp_doc_file.
*        wa_cid1-docfile = tmp_doc_file.
*
*        tmp_dokvr_i = wa_cid1-documentversion.
*        tmp_dokvr_n = tmp_dokvr_i.
*        wa_cid1-documentversion = tmp_dokvr_n.
*
*        tmp_doktl_i = wa_cid1-documentversion.
*        tmp_doktl_n = tmp_doktl_i.
*        wa_cid1-documentpart = tmp_doktl_n.
*
*
*        IF wa_cid1-documentnumber NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_'.
*          tmp_strlen = strlen( wa_cid1-documentnumber ).
*          IF tmp_strlen < 25.
*
*            tmp_char25 = '0000000000000000000000000'.
*            tmp_no_of_chars = tmp_strlen.
*
*            SHIFT tmp_char25 BY tmp_no_of_chars PLACES RIGHT.
*            CONDENSE tmp_char25 NO-GAPS.
*            CONCATENATE tmp_char25 wa_cid1-documentnumber
*                                              INTO tmp_doknr_n.
*            wa_cid1-documentnumber = tmp_doknr_n.
*          ENDIF.
*        ELSE.
*        ENDIF.
*
*        IF tmp_only_flag IS INITIAL.
*          APPEND wa_cid1 TO tmp_itab_local_data.
*          tmp_only_flag = 'X'.
*        ENDIF.
*
*        CLEAR wa_cid1-documenttype.
*        CLEAR wa_cid1-documentnumber.
*        CLEAR wa_cid1-documentversion.
*        CLEAR wa_cid1-documentpart.
*
*        APPEND wa_cid1 TO itab_documentfiles.
*        DELETE TABLE itab_tab_cid2 FROM wa_tab_cid2.
*        DELETE TABLE itab_file FROM wa_file.
*
*      ENDLOOP.
*    ENDLOOP.
*  ENDLOOP.



*  LOOP AT tmp_itab_local_data INTO tmp_wa_local_data.
*
*    CALL FUNCTION 'BAPI_DOCUMENT_CHECKIN_REPLACE2'
*      EXPORTING
*        documenttype            = tmp_wa_local_data-documenttype
*        documentnumber          = tmp_wa_local_data-documentnumber
*        documentpart            = tmp_wa_local_data-documentpart
*        documentversion         = tmp_wa_local_data-documentversion
**       HOSTNAME                = ' '
**       STATUSINTERN            = ' '
**       STATUSEXTERN            = ' '
**       STATUSLOG               = ' '
**       REVLEVEL                = ' '
**       AENNR                   = ' '
*     IMPORTING
*       return                   = lv_return
*     TABLES
*       documentfiles            = itab_documentfiles
**      COMPONENTS               =
**      DOCUMENTSTRUCTURE        =
*              .
*
*    IF NOT ( lv_return IS INITIAL ).
**      break steurich.
**      MESSAGE i056(zcvn) WITH lv_return-message.
*      WRITE lv_return INPUT ON.
*    ENDIF.
*
*  ENDLOOP.

ENDFUNCTION.
