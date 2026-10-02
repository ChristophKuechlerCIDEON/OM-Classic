report zcl_psfcopct_werks message-id co.
*---------------------------------------------------------------------*
*                                                                     *
* PPS-Print: Control-Ticket (Steuerkarte)                             *
*                                                                     *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Integration des Werks
*-----------------------------------------------------------------------
* Journal
* 07.02.2007 - Kopie / Erstellung
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------


* DATA-Statements general
include ppcoincl.
* DATA-Statements specific for production orders
include codrgt10.

* entry to print
perform print_sub.

* Schreiben der Spool ID in ZCL_PSB_TMP oder ins Memory
* OBJECT_TYPE : SPOOL
* Counter normal gefüllt
*WA
data: wa_default_data type /cideon/plot_defaultdata.
data: wa_user_data type /cideon/plot_userdata.

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


data: wa_item type zcl_pdm_objects_fa_int.
data: itab_item type table of zcl_pdm_objects_fa_int.

* Daten übergeben
clear wa_item.
clear itab_item.

wa_item-drtxt = print_co-drtxt.
wa_item-tdotftype = pr_result-tdotftype.
wa_item-tdspoolid = pr_result-tdspoolid.

wa_item-aufnr_pp = print_co-aufnr.

*   Druckinformationen
wa_item-drtxt = print_co-drtxt.

wa_item-psteu = print_co-psteu.
wa_item-samlt = print_co-samlt.
wa_item-pmode = print_co-pmode.
wa_item-drart = print_co-drart.
wa_item-ktext = print_co-ktext.
wa_item-selpr = print_co-selpr.
wa_item-tcode = print_co-tcode.

* Projektsystem Informationen
wa_item-projn = caufvd_tab-projn.


* Testen, ob für Fertigungswerk ein Verteiler vorliegt
* sonst Verteiler des Nutzers benutzen
data: wa_fauf_werk_ve type zcl_fauf_werk_ve.

clear wa_fauf_werk_ve.
select single * from zcl_fauf_werk_ve
  into wa_fauf_werk_ve
  where werks = print_co-werks
  .
if sy-subrc ne 0.
  wa_item-verteiler = wa_user_data-default_verteiler_fauf.
else.
  wa_item-verteiler = wa_fauf_werk_ve-verteiler.
endif.

"wa_item-verteiler = wa_user_data-default_verteiler_fauf.

append wa_item to itab_item.

call function 'Z_CL_INT_WRITE_PLOT_PSB_SPOOL'
* EXPORTING
*   F_AUT_PROCESS       = 'X'
  tables
    i_itab_items        = itab_item
  exceptions
    error               = 1
    others              = 2
          .
if sy-subrc <> 0.
  message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.




*---------------------------------------------------------------------*
*       FORM PRINT_SUB                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form print_sub.

* Document-tables
  include lcodrinc.

  loop at itab_tdr where object = obj-pos
                   or    object = obj-sop
                   or    object = obj-fhm
                   and   aufnr  = print_co-aufnr.           "New 3.0
    exit.
  endloop.

  check sy-subrc is initial.

* fill workarea of header (probably more than 1 order is to be printed)

  loop at itab_tdr where object = obj-alt
                   and   aufnr  = print_co-aufnr.           "New 3.0
* Save Indextable of header
    itab_ord = itab_tdr.

    loop at caufvd_tab where aufnr = itab_tdr-aufnr.
      perform pppr_std_init_order using caufvd_tab.
* Get position
      read table afpod_tab with key aufnr = caufvd-aufnr
                                    posnr = '0001'.
      afpod = afpod_tab.
      do print_co-copys times.
        if sy-index gt 1.
          move text-dup to print_co-drtxt.
        endif.
* call OPEN_FORM to open formular
        perform pppr_open_form using 'PAG_STD'.
* print info's of order-header
        perform lg01_header.
* print info's of operations
        perform lg01_vorgang.
* call CLOSE_FORM to finish formular
        perform pppr_close_form.
      enddo.
    endloop.
  endloop.
endform.
*---------------------------------------------------------------------*
*       FORM LG01_HEADER                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form lg01_header.
  perform pppr_print_prodnet_info.                          "New 3.0
* if BARCODE forced the print
  if not print_co-barco is initial.
* standard: materialnumber and order-number as Barcode:
    call function 'WRITE_FORM'
         exporting
              element = 'BARCODE_AUFNR_MATNR'
              window  = 'MAIN'.
* for modification: if customer-order-number as barcode
*   call function 'WRITE_FORM'
*        exporting
*             element = 'BARCODE_KDAUF_KDPOS'
*             window  = 'MAIN'.
  endif.
* print header text
  perform pppr_print_ord_text.
* print configuration
  perform pppr_print_configuration.
* new with 3.0: print production note
  perform pppr_print_prod_note.
* print routing text
  perform pppr_print_routing_text.

endform.
*---------------------------------------------------------------------*
*       FORM LG01_VORGANG                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form lg01_vorgang.

  data: flg_seq_new_page.
  data: flg_act_read.
  clear flg_seq_new_page.

  loop at itab_tdr where object = obj-pos
                   or    object = obj-sop
                   or    object = obj-fhm
                   and   aufnr  = itab_ord-aufnr.

    if itab_tdr-object = obj-pos
    or itab_tdr-object = obj-sop.
      index_vrg = sy-tabix.
    else.
      check itab_tdr-aplzl ne afvgd-aplzl.
      index_vrg = sy-tabix - 1.
    endif.

    clear flg_act_read.

* save entry
    itab_vrg = itab_tdr.
* new-sequence ?
    if affld-plnfl ne itab_tdr-aplfl.
* print sequence header
      perform pppr_print_seq_header using
                                    flg_seq_new_page 'PAGE_NEW' x_field.
      check not x_field is initial.
    endif.
* initialize operation
    perform pppr_std_init_operation
            using x_field const-flg_yes space space.
    check not x_field is initial.

* print Main-Data of operation
    call function 'CONTROL_FORM'
         exporting
              command = 'PROTECT'.
    call function 'WRITE_FORM'
         exporting
              element = 'OPR_DATA_HDR'
              window  = 'MAIN'.
    if print_co-barco is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'OPR_DATA'
                window  = 'MAIN'.
    else.
      call function 'WRITE_FORM'
           exporting
                element = 'OPR_DATA_BC'
                window  = 'MAIN'.
    endif.
* print operation text
    perform pppr_print_opr_text.
    call function 'CONTROL_FORM'
         exporting
              command = 'PROTECT'.
* print activities
    perform psfc_print_activities using afvgd.
* print PRT
    perform pppr_print_prt_to_opr.
* finish operation with line
    call function 'WRITE_FORM'
         exporting
              element = 'LINE'
              window  = 'MAIN'.
  endloop.
endform.
include codrgett.         "PPPR-Form-Routinen: pppr_get_tables
include codrif01.         "PPPR-Form-Routinen: Druck-Parts lesen
include codrif02.         "PPPR-Form-Routinen: Open/Close Form
include codrif03.         "PPPR-Form-Routinen: print_prodnet_info
include codrif04.         "PPPR-Form-Routinen: read_mat
include codrif05.         "PPPR-Form-Routinen: print_activities
include codrif06.         "PPPR-Form-Routinen: print_prod_note
include codrif07.         "PPPR-Form-Routinen: print_ord_text
include codrif08.         "PPPR-Form-Routinen: print_configuration
include codrif09.         "PPPR-Form-Routinen: print_prt_to_opr
*                         "                    (+ Include CODRIF12)
include codrif10.         "PPPR-Form-Routinen: print_opr_text
include codrif16.         "PSFC-Form-Routinen: print_seq_header
*                         "                    (+ Include CODRIF11)
include codrif17.         "PSFC-Form-Routinen: std_init_operation
include codrif18.         "PSFC-Form-Routinen: print_routing_text
