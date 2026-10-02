*----------------------------------------------------------------------*
*      Print of a delivery note by SAPscript SMART FORMS               *
*----------------------------------------------------------------------*
REPORT rle_delnote.
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:

*-----------------------------------------------------------------------
* Journal
* 15.10.2008 - Erstellung / Kopie
*-----------------------------------------------------------------------
* Übergaben an S-PSO
* Anpassung des
*   - Forms "FORM_CLOSE", um die Spool ID zu bekommen
*   - Forms "ENTRY", um die allgemeine Verarbeitung zu ermöglichen
*----------------------------------------------------------------------*
* Datenteil
*----------------------------------------------------------------------*
*ITAB
*WA
DATA: result TYPE itcpp.
DATA: job_output_info TYPE  ssfcrescl.
DATA: job_output_options TYPE  ssfcresop.
*NORMAL
"CKR 2008/10/15
DATA: g_ls_dlv_delnote        TYPE ledlv_delnote.
*----------------------------------------------------------------------*




* declaration of data
INCLUDE rle_delnote_data_declare.
* definition of forms
INCLUDE rle_delnote_forms.
INCLUDE rle_print_forms.

*---------------------------------------------------------------------*
*       FORM ENTRY
*---------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  "CKR 2008/10/15
  CLEAR g_ls_dlv_delnote.

  DATA: lf_retcode TYPE sy-subrc.
  xscreen = us_screen.
  PERFORM processing USING    us_screen
                     CHANGING lf_retcode.
  IF lf_retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

  "Anbindung der Dokumentenausgabe
  IF
* bitte keine Prüfung auf TCODE...
    job_output_info-spoolids IS INITIAL.
    EXIT.
  ELSE.

    CALL FUNCTION '/CIDEON/PLOT_VA_RLE_DELNOTE'
      EXPORTING
        i_ls_dlv_delnote           = g_ls_dlv_delnote
        i_ls_job_output_info       = job_output_info
*     EXCEPTIONS
*       ERROR                      = 1
*       OTHERS                     = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
FORM processing USING    proc_screen
                CHANGING cf_retcode.

  DATA: ls_print_data_to_read TYPE ledlv_print_data_to_read.
  DATA: ls_dlv_delnote        TYPE ledlv_delnote.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.

* SmartForm from customizing table TNAPR
  lf_formname = tnapr-sform.

* determine print data
  PERFORM set_print_data_to_read USING    lf_formname
                                 CHANGING ls_print_data_to_read
                                 cf_retcode.

  IF cf_retcode = 0.
* select print data
    PERFORM get_data USING    ls_print_data_to_read
                     CHANGING ls_addr_key
                              ls_dlv_delnote
                              cf_retcode.
  ENDIF.

  IF cf_retcode = 0.
    PERFORM set_print_param USING    ls_addr_key
                            CHANGING ls_control_param
                                     ls_composer_param
                                     ls_recipient
                                     ls_sender
                                     cf_retcode.
  ENDIF.

  IF cf_retcode = 0.
* determine smartform function module for delivery note
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
         EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
         IMPORTING  fm_name            = lf_fm_name
         EXCEPTIONS no_form            = 1
                    no_function_module = 2
                    OTHERS             = 3.
    IF sy-subrc <> 0.
*   error handling
      cf_retcode = sy-subrc.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

  IF cf_retcode = 0.
*   call smartform delivery note

    "CKR 2008/10/15
    CLEAR job_output_info.
    CLEAR job_output_options.

    CLEAR g_ls_dlv_delnote.
    g_ls_dlv_delnote = ls_dlv_delnote.

    CALL FUNCTION lf_fm_name
         EXPORTING
                  archive_index        = toa_dara
                  archive_parameters   = arc_params
                  control_parameters   = ls_control_param
*                 mail_appl_obj        =
                  mail_recipient       = ls_recipient
                  mail_sender          = ls_sender
                  output_options       = ls_composer_param
                  user_settings        = ' '
                  is_dlv_delnote       = ls_dlv_delnote
                  is_nast              = nast               "n_489639
       IMPORTING
*                  document_output_info =
                   job_output_info      = job_output_info
                 job_output_options   =   job_output_options
       EXCEPTIONS formatting_error     = 1
                  internal_error       = 2
                  send_error           = 3
                  user_canceled        = 4
                  OTHERS               = 5.
    IF sy-subrc <> 0.
*   error handling
      cf_retcode = sy-subrc.
      PERFORM protocol_update.
*     get SmartForm protocoll and store it in the NAST protocoll
      PERFORM add_smfrm_prot.                  "INS_HP_335958
    ENDIF.
  ENDIF.

* get SmartForm protocoll and store it in the NAST protocoll
* PERFORM ADD_SMFRM_PROT.                       DEL_HP_335958

ENDFORM.
