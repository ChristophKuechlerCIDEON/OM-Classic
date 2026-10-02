FUNCTION /cideon/otf_2_pdf.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PFAD) TYPE  STRING
*"     VALUE(I_TDSPOOLID) TYPE  RSPOID
*"     VALUE(I_TDOTFTYPE) TYPE  TDOTFTYPE
*"  EXPORTING
*"     VALUE(O_FILEP) TYPE  FILEP
*"  EXCEPTIONS
*"      ERROR
*"      NO_SPOOL
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  C. Küchler
*
* Anpassungen:

*
* Kontakt über:   https://service.cideon.com
*                 HELPDESK@CIDEON-SOFTWARE.DE
*
*-----------------------------------------------------------------------
* Journal
* 25.03.2004 - Erstellung
* 28.05.2004 - Änderung auf GUI_DOWNLOAD
*
* SP 114
* 16.12.2009 - PDF Spool berücksichtigen
*
* 7.0.152.2 - CKR
*             FB /CIDEON/OTF_2_PDF
*             Setzen des Status eines Spoolsjobs auf Verarbeitet
*
* 7.0.156.1
* 08.07.2011 - CKR
*              SM 8000002953
*              Manz
*              FB /CIDEON/OTF_2_PDF Vermeidung der Abfrage, bei einer
*              Ausgabe von mehr als 99 Seiten im PDF
*
** 7.0.157.1
*              FB /CIDEON/OTF_2_PDF

*-----------------------------------------------------------------------

*TYPES
*ITAB
  DATA: itab_pdf TYPE TABLE OF tline.
*WA
  DATA: wa_tsp01 TYPE tsp01.
*NORMAL
  DATA: objtype LIKE rststype-type.
  DATA: type LIKE rststype-type.
  DATA: f_is_otf VALUE ''.
  DATA: str_spoolid(10).

  DATA: numbytes TYPE i,
        arc_idx LIKE toa_dara,
        pdfspoolid LIKE tsp01-rqident,
        jobname LIKE tbtcjob-jobname,
        jobcount LIKE tbtcjob-jobcount.

* Check, ob Spoolauftrag existiert
  SELECT SINGLE * FROM tsp01 INTO wa_tsp01
    WHERE rqident = i_tdspoolid.
  IF sy-subrc <> 0.
    RAISE no_spool.
  ELSE.
  ENDIF.

* hole Attribute
  CALL FUNCTION 'RSTS_GET_ATTRIBUTES'
         EXPORTING
              authority     = 'SP01'
              client        = wa_tsp01-rqclient
              name          = wa_tsp01-rqo1name
              part          = 1
         IMPORTING
*           CHARCO        =
*           CREATER       =
*           CREDATE       =
*           DELDATE       =
*           MAX_CREDATE   =
*           MAX_DELDATE   =
*           NON_UNIQ      =
*           NOOF_PARTS    =
*           RECTYP        =
*           SIZE          =
*           STOTYP        =
              type          = type
              objtype       = objtype
         EXCEPTIONS
              fb_error      = 1
              fb_rsts_other = 2
              no_object     = 3
              no_permission = 4.
  IF objtype(3) = 'OTF'.
    f_is_otf = 'X'.
  ELSE.
    f_is_otf = space.
  ENDIF.

  IF f_is_otf = 'X'.
    "Umbau auf verschiedene SAP System Releases

    IF sy-saprl = '46C'.
      CALL FUNCTION 'CONVERT_OTFSPOOLJOB_2_PDF'
      EXPORTING
        src_spoolid                    = i_tdspoolid
        no_dialog                      = ' '
*       DST_DEVICE                     =
*       PDF_DESTINATION                =
        "no_background                =  'X'
      IMPORTING
        pdf_bytecount                  = numbytes
        pdf_spoolid                    = pdfspoolid
*       OTF_PAGECOUNT                  =
        btc_jobname                    = jobname
        btc_jobcount                   = jobcount
      TABLES
        pdf                            = itab_pdf
      EXCEPTIONS
        err_no_otf_spooljob            = 1
        err_no_spooljob                = 2
        err_no_permission              = 3
        err_conv_not_possible          = 4
        err_bad_dstdevice              = 5
        user_cancelled                 = 6
        err_spoolerror                 = 7
        err_temseerror                 = 8
        err_btcjob_open_failed         = 9
        err_btcjob_submit_failed       = 10
        err_btcjob_close_failed        = 11.

    ELSE.
      CALL FUNCTION 'CONVERT_OTFSPOOLJOB_2_PDF'
      EXPORTING
        src_spoolid                    = i_tdspoolid
        no_dialog                      = 'X'
*       DST_DEVICE                     =
*       PDF_DESTINATION                =
        no_background                =  'X'
      IMPORTING
        pdf_bytecount                  = numbytes
        pdf_spoolid                    = pdfspoolid
*       OTF_PAGECOUNT                  =
        btc_jobname                    = jobname
        btc_jobcount                   = jobcount
      TABLES
        pdf                            = itab_pdf
      EXCEPTIONS
        err_no_otf_spooljob            = 1
        err_no_spooljob                = 2
        err_no_permission              = 3
        err_conv_not_possible          = 4
        err_bad_dstdevice              = 5
        user_cancelled                 = 6
        err_spoolerror                 = 7
        err_temseerror                 = 8
        err_btcjob_open_failed         = 9
        err_btcjob_submit_failed       = 10
        err_btcjob_close_failed        = 11.

    ENDIF.

    CASE sy-subrc.
      WHEN 0.
*        MESSAGE e150(/cideon/plot_basis) WITH
*        'Funktion CONVERT_OTFSPOOLJOB_2_PDF erfolgreich'(001)
*        '' '' '' RAISING error.
      WHEN 1.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Kein OTF- und kein ABAP-Spoolauftrag'(002)
        '' '' '' RAISING error.
      WHEN 2.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Spoolauftrag existiert nicht'(003)
        '' '' '' RAISING error.
      WHEN 3.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Keine Berechtigung zum Lesen Spoolauftrag'(004)
        '' '' '' RAISING error.
      WHEN OTHERS.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Fehler bei Funktion CONVERT_OTFSPOOLJOB_2_PDF'(005)
        '' '' '' RAISING error.
    ENDCASE.
  ELSE.
    "BADI Integration
    DATA: badi_main_pre_001 TYPE REF TO /cideon/if_ex_pre_main_001.
    DATA: return TYPE bapiret2.

    CALL METHOD cl_exithandler=>get_instance
      CHANGING
        instance = badi_main_pre_001.
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    DATA: f_processed.
    CLEAR f_processed.

    IF badi_main_pre_001 IS INITIAL.
    ELSE.
      CALL METHOD badi_main_pre_001->chg_spool_processing
         EXPORTING
           i_pfad      = i_pfad
           i_tdspoolid = i_tdspoolid
           i_tdotftype =            i_tdotftype
        CHANGING
          o_filep     = o_filep
          f_processed = f_processed
         EXCEPTIONS
           error       = 1
           no_spool    = 2
           OTHERS      = 3
              .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.

    IF f_processed = 'X'.
      " Verarbeitung erfolgreich im BADI vorgenommen
      EXIT.
    ELSE.
    ENDIF.

    CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
        EXPORTING
          src_spoolid                    = i_tdspoolid
          no_dialog                      = ' '
*       DST_DEVICE                     =
*       PDF_DESTINATION                =
        IMPORTING
          pdf_bytecount                  = numbytes
          pdf_spoolid                    = pdfspoolid
*       LIST_PAGECOUNT                 =
          btc_jobname                    = jobname
          btc_jobcount                   = jobcount
        TABLES
          pdf                            = itab_pdf
        EXCEPTIONS
          err_no_abap_spooljob           = 1
          err_no_spooljob                = 2
          err_no_permission              = 3
          err_conv_not_possible          = 4
          err_bad_destdevice             = 5
          user_cancelled                 = 6
          err_spoolerror                 = 7
          err_temseerror                 = 8
          err_btcjob_open_failed         = 9
          err_btcjob_submit_failed       = 10
          err_btcjob_close_failed        = 11.
    CASE sy-subrc.
      WHEN 0.
*        MESSAGE e150(/cideon/plot_basis) WITH
*        'Funktion CONVERT_ABAPSPOOLJOB_2_PDF erfolgreich'(006)
*        '' '' '' RAISING error.
      WHEN 1.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Kein OTF- und kein ABAP-Spoolauftrag'(002)
        '' '' '' RAISING error.
      WHEN 2.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Spoolauftrag existiert nicht'(003)
        '' '' '' RAISING error.
      WHEN 3.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Keine Berechtigung zum Lesen Spoolauftrag'(004)
        '' '' '' RAISING error.
      WHEN OTHERS.
        MESSAGE e150(/cideon/plot_basis) WITH
        'Fehler bei Funktion CONVERT_ABAPSPOOLJOB_2_PDF'(007)
        '' '' '' RAISING error.
    ENDCASE.
  ENDIF.

  str_spoolid = i_tdspoolid.
  CONDENSE str_spoolid NO-GAPS.
  CONCATENATE i_pfad '\' str_spoolid '.pdf'
    INTO o_filep.

  DATA: str_o_filep TYPE string.
  str_o_filep = o_filep.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize                  = numbytes
      filename                      = str_o_filep
      filetype                      = 'BIN'
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
      data_tab                      = itab_pdf
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
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*  CALL FUNCTION 'DSVAS_DOC_WS_DOWNLOAD_50'
*    EXPORTING
*      bin_filesize                  = numbytes
*      filename                      = o_filep
*      filetype                      = 'BIN'
**     MODE                          = ' '
**   IMPORTING
**     FILELENGTH                    =
*    TABLES
*      data_tab                      = itab_pdf
*    EXCEPTIONS
*      file_open_error               = 1
*      file_write_error              = 2
*      invalid_filesize              = 3
*      invalid_type                  = 4
*      no_batch                      = 5
*      unknown_error                 = 6
*      invalid_table_width           = 7
*      gui_refuse_filetransfer       = 8
*      customer_error                = 9
*      no_authority                  = 10
*      OTHERS                        = 11
*            .
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.


* 7.0.152.2 - CKR
*             FB /CIDEON/OTF_2_PDF
*             Setzen des Status eines Spoolsjobs auf Verarbeitet


  TABLES tsp01.

  UPDATE tsp01 SET   rqpjreq = '1' rqpjdone = '1'
                 WHERE rqident = i_tdspoolid.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.



ENDFUNCTION.
