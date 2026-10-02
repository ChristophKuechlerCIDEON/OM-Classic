*&---------------------------------------------------------------------*
*& Report  ZCL_PRINT_FAUF_02                                           *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 29.09.2003 - Erstellung
* 01.10.2003 - Einstellungen lesen
* 26.02.2004 - Kopie
* 08.02.2007 - Integration Werksabhängigkeit der Verteiler
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------

report  zcl_print_fauf_01 .

include ppcoincl.

* Schauen, ob das das richtige Include ist .....
include codrgt10.

*TYPES
*ITAB
data: itab_items_fauf type table of zcl_pdm_objects_fa_int.
*WA
data: wa_default_data type /cideon/plot_defaultdata.
data: wa_user_data type /cideon/plot_userdata.
data: wa_item_fauf type zcl_pdm_objects_fa_int.
*NORMAL



* Einstellungen lesen
clear wa_user_data.
clear wa_default_data.

call function '/CIDEON/READ_DEFAULTDATA'
     exporting
          i_batch        = ''
     importing
          o_default_data = wa_default_data.


call function '/CIDEON/READ_USERDATA'
     exporting
          i_default_data = wa_default_data
     importing
          o_user_data    = wa_user_data.




perform print_sub.


*---------------------------------------------------------------------*
*       FORM PRINT_SUB                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form print_sub.

* Document-tables
  include lcodrinc.

* eigene Druckroutinen hinhängen....
* Lesen in welchen Verteiler gedruckt werden soll ?
* Defaultkopien
* etc. am besten alles Lesen lassen.


* Spoolauftragerstellen und ID Lesen....

*  Die Druckoptionen sollten hier liegen
*  PRINT_CO

*****************************************
* Optionen befüllen, damit
* SCRIPT PP01 000001000120 gleichartig rüberkommt...
* damit es alles im gleichen Spool landet ....
*****************************************


  call function 'OPEN_FORM'
   exporting
     device                            = 'PRINTER'
     dialog                            = space
     form                              = 'ZFAUF_STD_LAYOUT'
     language                          = sy-langu
     options                           = pr_options
*     MAIL_SENDER                       =
*     MAIL_RECIPIENT                    =
*     MAIL_APPL_OBJECT                  =
*     RAW_DATA_INTERFACE                = '*'
*   IMPORTING
*     LANGUAGE                          =
*     NEW_ARCHIVE_PARAMS                =
*     RESULT                            =
   exceptions
     canceled                          = 1
     device                            = 2
     form                              = 3
     options                           = 4
     unclosed                          = 5
     mail_options                      = 6
     archive_error                     = 7
     invalid_fax_number                = 8
     more_params_needed_in_batch       = 9
     spool_error                       = 10
     others                            = 11
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

*  PERFORM pppr_collect_destinations USING  print_co.

  call function 'START_FORM'
       exporting
            startpage = 'S1'.

  call function 'WRITE_FORM'
       exporting
*            element = 'MAIN_FINISH'
            window  = 'MAIN'.
  call function 'END_FORM'.
  call function 'CLOSE_FORM'
       importing
            result = pr_result
       exceptions
            others = 01.

  break kuechler.                                          "#EC NOBREAK

  loop at afdld_tab.
    clear wa_item_fauf.

    move-corresponding afdld_tab to wa_item_fauf.


* Testen, ob für Fertigungswerk ein Verteiler vorliegt
* sonst Verteiler des Nutzers benutzen
    data: wa_fauf_werk_ve type zcl_fauf_werk_ve.

    clear wa_fauf_werk_ve.
    select single * from zcl_fauf_werk_ve
      into wa_fauf_werk_ve
      where werks = print_co-werks
      .
    if sy-subrc ne 0.
      wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.
    else.
      wa_item_fauf-verteiler = wa_fauf_werk_ve-verteiler.
    endif.
    "wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.

    wa_item_fauf-folnr = afdld_tab-folnr.
    wa_item_fauf-vornr = afdld_tab-vornr.
    wa_item_fauf-aufnr_pp = afdld_tab-aufnr.

    append wa_item_fauf to itab_items_fauf.

  endloop.


* Aufruf des FBs
  if itab_items_fauf[] is initial.
  else.
    call function 'Z_CL_INT_WRITE_PLOT_PSB'
         exporting
              f_aut_process = wa_user_data-knz_auto_fauf
         tables
              i_itab_items  = itab_items_fauf
         exceptions
              error         = 1
              others        = 2.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
  endif.
endform.


*INCLUDE codrif01.          "PSFC-Form-Routinen: Druck-Parts lesen
*INCLUDE codrif02.          "PSFC-Form-Routinen: Open/Close Form
*INCLUDE codrif03.          "PSFC-Form-Routinen: print_prodnet_info
*INCLUDE codrif04.          "PSFC-Form-Routinen: read_mat
*INCLUDE codrif05.          "PSFC-Form-Routinen: print_activities
*INCLUDE codrif06.          "PSFC-Form-Routinen: print_prod_note
*INCLUDE codrif07.          "PSFC-Form-Routinen: print_ord_text
*INCLUDE codrif08.          "PSFC-Form-Routinen: print_configuration
*INCLUDE codrif09.          "PSFC-Form-Routinen: print_prt_to_opr
**                          "                    (+ Include CODRIF12)
*INCLUDE codrif10.          "PSFC-Form-Routinen: print_opr_text
*INCLUDE codrif14.          "PSFC-Form-Routinen: print_cmp_to_opr
**                          "                    (+ Include CODRIF13)
*INCLUDE codrif15.          "PSFC-Form-Routinen: get_components
*INCLUDE codrif16.          "PSFC-Form-Routinen: print_seq_header
**                          "                    (+ Include CODRIF11)
*INCLUDE codrif17.          "PSFC-Form-Routinen: std_init_operation
*INCLUDE codrif18.          "PSFC-Form-Routinen: print_routing_text




include codrgett.
