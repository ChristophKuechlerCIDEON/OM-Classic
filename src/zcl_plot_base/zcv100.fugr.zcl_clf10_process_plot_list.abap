FUNCTION zcl_clf10_process_plot_list.
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
*"     VALUE(I_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA OPTIONAL
*"     VALUE(F_DYN_TOC) TYPE  CHAR1 OPTIONAL
*"     VALUE(F_DYN_COV) TYPE  CHAR1 OPTIONAL
*"     VALUE(LI_COUNTER_CLF) TYPE  I OPTIONAL
*"  TABLES
*"      ITAB_TEST STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"      ITAB_STAMPS STRUCTURE  ZCL_S_STEMPEL_VALUE OPTIONAL
*"      IT_NOTIZ TYPE  /CIDEON/TTYPE_S_STEMPEL_WERT OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Srinivas Mamillapalli
*
*           Christoph Küchler
*
* Kontakt:
*           helpdesk@cideon-software.com
*
*-----------------------------------------------------------------------
* Journal
* 24.03.2004 - Änderungen Exceptionmanagment
* 25.03.2004 - Multipageänderungen
* 23.02.2005 - Änderungen für JavaGUI
*              Dateiablage / Verzeichnistests
* 18.04.2005 - AO$_MERGE = =0 / 1 / 2
*              kein / 1.Wert / letzter Wert
*              nur innerhalb der neuen CLF
* 29.11.2006 - Übergabe der Notiztabelle

*-----------------------------------------------------------------------
* toDo
*
*-----------------------------------------------------------------------


  DATA : lv_flag_test                 TYPE c,
         lv_flag_clf_send_out_process TYPE c,
         lv_error_message             TYPE messages.

  DATA : wa_test           TYPE          zcl_s_plotlist,
         itab_ghead_clf10  TYPE TABLE OF zcl_s_line_256,
         itab_clflist      TYPE TABLE OF zcl_s_line_256.

  DATA : wa_plint_config   TYPE          zcl_plint_config,
         itab_plint_config TYPE TABLE OF zcl_plint_config.

*************************************

  LOOP AT itab_test INTO wa_test.
    IF lv_flag_test IS INITIAL.
      lv_flag_test = 'X'.
      CONTINUE.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'ZCL_ULOAD_GHEAD_CLF10'
       EXPORTING
            user          = default_user
       TABLES
            o_ghead_clf10 = itab_ghead_clf10
       EXCEPTIONS
            error         = 1
            OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e099(zcvn) WITH 'ZCL_GHEAD_CLF10' RAISING error.
  ENDIF.

  CALL FUNCTION 'ZCL_PROC_SKEL_GHEAD_CLF10'
       EXPORTING
            i_process_clf   = i_out_proc
            wa_draw         = wa_test
            i_delete_item   = i_delete_item
            i_delete_status = i_delete_status
       TABLES
            it_ghead        = itab_ghead_clf10
            ot_clflist      = itab_clflist
            it_notiz        = it_notiz
            it_stamps       = itab_stamps
       EXCEPTIONS
            error           = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE e098(zcvn) WITH 'ZCL_GHEAD_CLF10' RAISING error.
  ENDIF.

  IF ( i_knz_use_converte EQ space ).
    CALL FUNCTION 'ZCL_PROCESS_CLF_DLOAD'
      EXPORTING
        default_user            = default_user
        i_down_path             = i_down_path
        i_clf_down_path         = i_clf_down_path
        filter                  = '*.*'
        i_out_proc              = lv_flag_clf_send_out_process
*       I_DELETE_ITEM           =
*       I_DELETE_STATUS         =
*       I_FORMAT_CHECKING       =
        i_user_data             = i_user_data
        f_dyn_toc               = f_dyn_toc
        f_dyn_cov               = f_dyn_cov
        li_counter_clf          = li_counter_clf
      TABLES
        itab_test               = itab_test
        itab_stamps             = itab_stamps
        itab_clflist            = itab_clflist
      EXCEPTIONS
        error                   = 1
        OTHERS                  = 2.

    IF sy-subrc <> 0.
      IF sy-msgid IS INITIAL.
        MESSAGE e062(zcvn) . "RAISING error.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

  ELSE.
    IF NOT ( i_converter_name IS INITIAL ).

      CALL FUNCTION 'ZCL_RFC_DLOAD_CLF_FILES_2_CONV'
        EXPORTING
          default_user       = default_user
          i_down_path        = i_down_path
          i_clf_down_path    = i_clf_down_path
          filter             = '*.*'
          i_out_proc         = lv_flag_clf_send_out_process
*         I_DELETE_ITEM      =
*         I_DELETE_STATUS    =
*         I_FORMAT_CHECKING  =
          i_knz_use_converte = ''
          i_converter_name   = i_converter_name
          i_converter_number = i_converter_number
          i_ftp_destination  = i_ftp_destination
          i_ftp_user         = i_ftp_user
          i_ftp_passwd       = i_ftp_passwd
          i_ftp_down         = i_ftp_down
        IMPORTING
          error_message      = lv_error_message
        TABLES
          itab_test          = itab_test
          itab_stamps        = itab_stamps
          itab_clflist       = itab_clflist
        EXCEPTIONS
          error              = 1
          OTHERS             = 2.

*      IF lv_error_message-msg_type CA 'CE' .
*        MESSAGE e096(zcvn) WITH i_converter_name RAISING error.
*      ENDIF.    " Kommentiert am 13.10.2003 -- Sri

      IF ( ( lv_error_message-msg_type CA 'CE' )
              OR ( sy-subrc <> 0 ) ).
        MESSAGE e096(zcvn) WITH i_converter_name RAISING error.
      ELSE.
        IF sy-msgid IS INITIAL.
        ELSE.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

    ELSE.
      MESSAGE e095(zcvn) .
    ENDIF.

  ENDIF.

ENDFUNCTION.
