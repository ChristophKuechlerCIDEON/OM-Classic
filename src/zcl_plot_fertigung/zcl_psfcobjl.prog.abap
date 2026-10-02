report psfcobjl message-id co.
*---------------------------------------------------------------------*
*                                                                     *
* PPS-Print: Object list (Objektübersicht                             *
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
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------

* DATA-Statements general
include ppcoincl.
* DATA-Statements specific for production orders
include codrgt10.

* entry to print
perform print_sub.

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
                   or    object = obj-mat
                   or    object = obj-fhm
                   and   aufnr  = print_co-aufnr.  "New 3.0
    exit.
  endloop.

  check sy-subrc is initial.

* fill workarea of header (probably more than 1 order is to be printed)

  loop at itab_tdr where object = obj-alt
                   and   aufnr  = print_co-aufnr.     "New 3.0
* Save Indextable of header
    itab_ord = itab_tdr.

    loop at caufvd_tab where aufnr = itab_ord-aufnr.
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
        perform pppr_open_form using 'PAG_RES'.
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
  perform pppr_print_prodnet_info.          "New 3.0
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
    call function 'WRITE_FORM'
         exporting
              element = 'BARCODE_RSNUM'
              window  = 'MAIN'.
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

* reset work areas
  clear: affld, afvgd, resbd, affhd.

  loop at itab_tdr where object = obj-pos
                   or    object = obj-sop
                   or    object = obj-mat
                   or    object = obj-fhm
                   and   aufnr  = itab_ord-aufnr.

    if itab_tdr-object = obj-pos
    or itab_tdr-object = obj-sop.
      index_vrg = sy-tabix.
    else.
      check itab_tdr-aplzl <> afvgd-aplzl.
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
              command = 'ENDPROTECT'.
* print activities
    perform psfc_print_activities using afvgd.
* print components
    perform pppr_print_cmp_to_opr.
* print PRT
    perform pppr_print_prt_to_opr.
* finish operation with line
    call function 'WRITE_FORM'
         exporting
              element = 'LINE'
              window  = 'MAIN'.
  endloop.
endform.

include codrgett.                      "PSFC-form-routinen: get_tables
include codrif01.          "PSFC-Form-Routinen: Druck-Parts lesen
include codrif02.          "PSFC-Form-Routinen: Open/Close Form
include codrif03.          "PSFC-Form-Routinen: print_prodnet_info
include codrif04.          "PSFC-Form-Routinen: read_mat
include codrif05.          "PSFC-Form-Routinen: print_activities
include codrif06.          "PSFC-Form-Routinen: print_prod_note
include codrif07.          "PSFC-Form-Routinen: print_ord_text
include codrif08.          "PSFC-Form-Routinen: print_configuration
include codrif09.          "PSFC-Form-Routinen: print_prt_to_opr
*                          "                    (+ Include CODRIF12)
include codrif10.          "PSFC-Form-Routinen: print_opr_text
include codrif14.          "PSFC-Form-Routinen: print_cmp_to_opr
*                          "                    (+ Include CODRIF13)
include codrif15.          "PSFC-Form-Routinen: get_components
include codrif16.          "PSFC-Form-Routinen: print_seq_header
*                          "                    (+ Include CODRIF11)
include codrif17.          "PSFC-Form-Routinen: std_init_operation
include codrif18.          "PSFC-Form-Routinen: print_routing_text
