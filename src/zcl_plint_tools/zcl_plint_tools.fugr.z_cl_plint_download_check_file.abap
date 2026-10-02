FUNCTION z_cl_plint_download_check_file.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"     VALUE(I_TEMP_PATH) TYPE  BAPI_DOC_AUX-FILENAME
*"  EXPORTING
*"     VALUE(O_FILENAME) TYPE  BAPI_DOC_AUX-FILENAME
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
  DATA:  itab_bapi    TYPE bapi_doc_files2 OCCURS 0 WITH HEADER LINE.
  DATA:  itab2_bapi    TYPE bapi_doc_files2 OCCURS 0
                                          WITH HEADER LINE.
  DATA: wa_itab_bapi  TYPE bapi_doc_files2 .
  DATA: stripped_name     LIKE rlgrap-filename.
  DATA: file_path         LIKE rlgrap-filename.
  DATA: dir_exist         TYPE c.
  DATA: is_dir            TYPE c.



  REFRESH itab_bapi.
  REFRESH itab2_bapi.
  CLEAR wa_itab_bapi.


  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = i_wa_plotjobs-dokar
      documentnumber             = i_wa_plotjobs-doknr
      documentpart               = i_wa_plotjobs-doktl
      documentversion            = i_wa_plotjobs-dokvr
*      GETOBJECTLINKS             = ' '
*      GETCOMPONENTS              = ' '
*      GETSTATUSLOG               = ' '
*      GETLONGTEXTS               = ' '
*      GETACTIVEFILES             = 'X'
*   IMPORTING
*     DOCUMENTDATA               =
*     RETURN                     =
    TABLES
*     OBJECTLINKS                =
*     DOCUMENTDESCRIPTIONS       =
*     LONGTEXTS                  =
*     STATUSLOG                  =
     documentfiles              = itab_bapi
*     COMPONENTS                 =
            .
*  IF sy-subrc NE 0.
*  ELSE.
*  ENDIF.

  LOOP AT itab_bapi INTO wa_itab_bapi.
    wa_itab_bapi-documenttype = i_wa_plotjobs-dokar.
    wa_itab_bapi-documentnumber = i_wa_plotjobs-doknr.
    wa_itab_bapi-documentpart = i_wa_plotjobs-doktl.
    wa_itab_bapi-documentversion = i_wa_plotjobs-dokvr.
    MODIFY itab_bapi FROM wa_itab_bapi INDEX sy-tabix.
  ENDLOOP.
  LOOP AT itab_bapi INTO wa_itab_bapi.
    IF wa_itab_bapi-docfile = i_wa_plotjobs-filep.
      IF wa_itab_bapi-checkedin = 'X'.
      ELSE.
        DELETE itab_bapi INDEX sy-tabix.
        CONTINUE.
      ENDIF.
      IF wa_itab_bapi-file_id = i_wa_plotjobs-file_id.
      ELSE.
        DELETE itab_bapi INDEX sy-tabix.
        CONTINUE.
      ENDIF.
      IF wa_itab_bapi-application_id = i_wa_plotjobs-application_id.
      ELSE.
        DELETE itab_bapi INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ELSE.
      DELETE itab_bapi INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  LOOP AT itab_bapi INTO wa_itab_bapi.
  ENDLOOP.

  IF itab_bapi[] IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
*      fname                = d_name
       fname                = i_temp_path
    IMPORTING
       exist                = dir_exist
       isdir                = is_dir
*      FILESIZE             =
    EXCEPTIONS
       fileinfo_error       = 1
       OTHERS               = 2
            .
  IF sy-subrc <> 0.
    RAISE error.
  ENDIF.

  IF dir_exist EQ space. "If the directory is not exist

* Create a a directory for the above purpose.
    DATA: tmp_dirname TYPE rlgrap-filename.
    tmp_dirname = i_temp_path.
    CALL FUNCTION 'TMP_GUI_CREATE_DIRECTORY'
      EXPORTING
        dirname       = tmp_dirname "i_temp_path
*       NO_FLUSH       = ' '
     EXCEPTIONS
        failed         = 1
        OTHERS         = 2
              .
    IF sy-subrc <> 0.
      RAISE error.
    ENDIF.

  ENDIF.



  CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
*  CALL FUNCTION 'Z_CL_BAPI_DOC_CHECKOUTVIEW2'
       EXPORTING
            documenttype        = i_wa_plotjobs-dokar
            documentnumber      = i_wa_plotjobs-doknr
            documentpart        = i_wa_plotjobs-doktl
            documentversion     = i_wa_plotjobs-dokvr
            documentfile        = wa_itab_bapi
            getstructure        = '1'
            getcomponents       = 'X'
            originalpath        = i_temp_path
*                     hostname            = ' '
            getheader           = 'X'
*                     docbomchangenumber  =
*                     docbomvalidfrom     =
*                     docbomrevisionlevel =
*                 IMPORTING
*                      return              = bapiret2
       TABLES
*                     documentstructure   =
            documentfiles       = itab_bapi
            .
*  IF sy-subrc NE 0.
*  ELSE.
*  ENDIF.


  DATA: tmp_filename TYPE rlgrap-filename.
  tmp_filename = i_wa_plotjobs-filep.

  READ TABLE itab_bapi INDEX 1.
  IF sy-subrc NE 0.
  ELSE.
    tmp_filename = itab_bapi-docfile.
  ENDIF.


  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
       EXPORTING
            full_name     = tmp_filename
       IMPORTING
            stripped_name = stripped_name
            file_path     = file_path
       EXCEPTIONS
            x_error       = 1
            OTHERS        = 2.

  IF sy-subrc NE 0.
    CLEAR o_filename.
    RAISE error.
  ELSE.
    CONCATENATE i_temp_path stripped_name INTO o_filename.
  ENDIF.




ENDFUNCTION.
