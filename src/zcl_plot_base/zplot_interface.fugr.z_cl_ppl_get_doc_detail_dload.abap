FUNCTION z_cl_ppl_get_doc_detail_dload.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NEW_DIRECTORY_NAME) TYPE  STRING OPTIONAL
*"     VALUE(WA_ZCL_S_PLOTLIST) LIKE  ZCL_S_PLOTLIST STRUCTURE
*"        ZCL_S_PLOTLIST OPTIONAL
*"     VALUE(I_DOWNLOADED_PATH) TYPE  STRING OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : obj_frontend_services TYPE REF TO cl_gui_frontend_services.

  DATA : itab_bapi_doc_draw2  TYPE bapi_doc_draw2
                                      OCCURS 0 WITH HEADER LINE,
         itab1_bapi_doc_files2 TYPE bapi_doc_files2
                                      OCCURS 0 WITH HEADER LINE,
         itab2_bapi_doc_files2 TYPE bapi_doc_files2
                                      OCCURS 0 WITH HEADER LINE,
         itab3_bapi_doc_files2 TYPE bapi_doc_files2
                                      OCCURS 0 WITH HEADER LINE,
         itab_bapiret2        TYPE bapiret2
                                      OCCURS 0 WITH HEADER LINE.

  DATA : wa1_bapi_doc_files2 TYPE bapi_doc_files2,
         wa3_bapi_doc_files2 TYPE bapi_doc_files2.


  DATA : lv_bapi_check_path TYPE bapi_doc_aux-filename,
         lv_str(200)        TYPE c,
         lv_full_path       LIKE rlgrap-filename,
         lv_stripped_name   LIKE rlgrap-filename,
         lv_file_path       LIKE rlgrap-filename,
         lv_source          TYPE string,
         lv_destination     TYPE string.

  IF obj_frontend_services IS INITIAL.
    CREATE OBJECT obj_frontend_services.
  ELSE.
  ENDIF.

  IF t_zcl_s_plotlist-knz_fehl_blatt EQ space.

    IF wa_zcl_s_plotlist-checked = 'X'.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = 30
                text       = text-084.

      CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
        EXPORTING
          documenttype               = wa_zcl_s_plotlist-dokar
          documentnumber             = wa_zcl_s_plotlist-doknr
          documentpart               = wa_zcl_s_plotlist-doktl
          documentversion            = wa_zcl_s_plotlist-dokvr
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
         documentdata               = itab_bapi_doc_draw2
         return                     = itab_bapiret2
       TABLES
*          OBJECTLINKS                =
*          DOCUMENTDESCRIPTIONS       =
*          LONGTEXTS                  =
*          STATUSLOG                  =
         documentfiles              = itab1_bapi_doc_files2
*          COMPONENTS                 =
*          CHARACTERISTICVALUES       =
*          CLASSALLOCATIONS           =
*          DOCUMENTSTRUCTURE          =
*          WHEREUSEDLIST              =
                .

************
      LOOP AT itab1_bapi_doc_files2 INTO wa3_bapi_doc_files2.

        TRANSLATE wa3_bapi_doc_files2 TO UPPER CASE.

        APPEND wa3_bapi_doc_files2 TO itab3_bapi_doc_files2.

      ENDLOOP.
************
      LOOP AT itab3_bapi_doc_files2 INTO wa1_bapi_doc_files2
                          WHERE docfile = wa_zcl_s_plotlist-filep.


        CONCATENATE i_new_directory_name '\' INTO lv_bapi_check_path.

        MOVE i_downloaded_path TO temp_path.

        CONCATENATE text-079 ' ' lv_bapi_check_path INTO lv_str.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
             EXPORTING
                  percentage = 30
                  text       = lv_str.


* Download the file(s) if they R 'CHEKEDIN'
        CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
             EXPORTING
                  documenttype        = wa_zcl_s_plotlist-dokar
                  documentnumber      = wa_zcl_s_plotlist-doknr
                  documentpart        = wa_zcl_s_plotlist-doktl
                  documentversion     = wa_zcl_s_plotlist-dokvr
                  documentfile        = wa1_bapi_doc_files2
                  getstructure        = '1'
*                  getcomponents       = 'X'
                  originalpath        = lv_bapi_check_path
*                     hostname            = ' '
                  getheader           = 'X'
*                     docbomchangenumber  =
*                     docbomvalidfrom     =
*                     docbomrevisionlevel =
*                   IMPORTING
*                        return              = bapiret2
             TABLES
*                     documentstructure   =
                  documentfiles       = itab2_bapi_doc_files2
                  .

        CLEAR itab2_bapi_doc_files2.

      ENDLOOP.


    ELSE.

*      MOVE i_downloaded_path TO lv_destination.
      MOVE i_new_directory_name TO lv_destination.

      MOVE wa_zcl_s_plotlist-filep TO lv_full_path.

      IF NOT ( lv_full_path IS INITIAL ).
        CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
             EXPORTING
                  full_name     = lv_full_path
             IMPORTING
                  stripped_name = lv_stripped_name
                  file_path     = lv_file_path
             EXCEPTIONS
                  x_error       = 1
                  OTHERS        = 2.
        IF sy-subrc <> 0.
          MESSAGE e036(zcvn) WITH '' RAISING error.
        ENDIF.
      ELSE.
      ENDIF.

      CONCATENATE lv_destination '\' lv_stripped_name
                                      INTO lv_destination.

*      CONCATENATE lv_destination lv_stripped_name
*                                      INTO lv_destination.

      MOVE lv_full_path TO lv_source.

      CONCATENATE text-081 ' ' lv_destination INTO lv_str.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = 50
                text       = lv_str.

      CALL METHOD obj_frontend_services->file_copy
        EXPORTING
          source             = lv_source
          destination        = lv_destination
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
        MESSAGE e016(zcvn) WITH lv_source lv_destination '' ''
                                                    RAISING error.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
