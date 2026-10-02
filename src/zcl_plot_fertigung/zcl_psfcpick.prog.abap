report psfcpick message-id co.
*---------------------------------------------------------------------*
*                                                                     *
* PPS-Print: Material-Provision-List (Materialbereitstelliste)        *
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

data: read_stpu value ' '.             "Standard: no read of subitems

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

  read table itab_tdr with key object  = obj-mat
                               aufnr   = print_co-aufnr. "New 3.0

  check sy-subrc is initial.

* first check wether something is to be printed
  perform check_print.
* if Sy-subrc=12: components given to print
  check sy-subrc = 12.

* fill workarea of header (probably more than 1 order is to be printed)

  loop at itab_tdr where object = obj-alt
                   and   aufnr  = print_co-aufnr.    "New 3.0
* Save Indextable of header
    itab_ord = itab_tdr.

    loop at caufvd_tab where aufnr = itab_ord-aufnr.
      perform pppr_std_init_order using caufvd_tab.
      do print_co-copys times.
        if sy-index gt 1.
          move text-dup to print_co-drtxt.
        endif.
* OPEN_FORM to open form
        perform pppr_open_form using 'PAG_RES'.
* header-informations
        perform mbr_header.
* list of components
        perform mbr_list.
* CLOSE_FORM to close form
        perform pppr_close_form.
      enddo.
    endloop.
  endloop.
endform.
*---------------------------------------------------------------------*
*       FORM MBR_HEADER                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form mbr_header.
  perform pppr_print_prodnet_info.     "New 3.0
* if BARCODE forced the print
  if not print_co-barco is initial.
* standard: materialnumber and order-number as Barcode:
    call function 'WRITE_FORM'
         exporting
              element = 'BARCODE_AUFNR_MATNR'
              window  = 'MAIN'.
    call function 'WRITE_FORM'
         exporting
              element = 'BARCODE_RSNUM'
              window  = 'MAIN'.

  endif.
* print order-text
  perform pppr_print_ord_text.
endform.
*---------------------------------------------------------------------*
*       FORM MBR_LIST                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form mbr_list.
  data: flg_head.
  data: flg_opr_info.
  data: aplzl_sav like afvgd-aplzl.
  data: begin of index_tab occurs 0,
          index_cmp like sy-tabix,
          index_seq like sy-tabix,
          index_opr like sy-tabix,
          plnfl     like resbd-plnfl,
          vornr     like resbd-vornr,
          lgort     like resbd-lgort,
          aobar     like resbd-aobar,
          aufst     like resbd-aufst,
          aufwg     like resbd-aufwg,
          baust     like resbd-baust,
          posnr     like resbd-posnr,
          matnr     like resbd-matnr,
          rspos     like resbd-rspos,
        end of index_tab.

* build short table for sort of components
  loop at itab_tdr where object = obj-mat
                         and aufnr eq itab_ord-aufnr.
* Fill DDIC-Strutcure of component
    read table resbd_tab index itab_tdr-index_plmz.
* found ?
    check sy-subrc is initial
* only print if amount of component greater than 0
    and   resbd_tab-bdmng gt 0
* not printed will be: Dummy's
    and   resbd_tab-dumps is initial
* not printed will be by-products:
    and   resbd_tab-shkzg ne 'S'.
    index_tab-index_cmp = itab_tdr-index_plmz.
    index_tab-index_seq = itab_tdr-index_plfl.
    index_tab-index_opr = itab_tdr-index_plpo.
    move-corresponding resbd_tab to index_tab.
    append index_tab.
  endloop.

  describe table index_tab lines sy-dbcnt.

  check sy-dbcnt gt 0.

* sort index_tab by ...
  sort index_tab by plnfl vornr lgort  " order of ITAB
                    aobar aufst aufwg baust
                    posnr matnr rspos.
* Print all materials for the current order (now in sorted order)
  loop at index_tab.
* Fill DDIC-Strutcure of component
    read table resbd_tab index index_tab-index_cmp.
    resbd = resbd_tab.
* at first entry print print description
    if flg_head is initial.
      if print_co-barco is initial.
        call function 'WRITE_FORM'
             exporting
                  element = 'CMP_DATA_HDR'
                  window  = 'MAIN'.
      else.
* reservation BC on each page
        call function 'WRITE_FORM'
             exporting
                  element  = 'BARCODE_RSNUM'
                  function = 'SET'
                  type     = 'TOP'
                  window   = 'MAIN'.
        call function 'WRITE_FORM'
             exporting
                  element = 'CMP_DATA_BC_HDR'
                  window  = 'MAIN'.
      endif.
      flg_head = const-flg_yes.
    endif.
    if print_co-barco is initial.
      call function 'WRITE_FORM'
           exporting
                element  = 'CMP_DATA_HDR'
                function = 'APPEND'
                type     = 'TOP'
                window   = 'MAIN'.
    else.
      call function 'WRITE_FORM'
           exporting
                element  = 'CMP_DATA_BC_HDR'
                function = 'APPEND'
                type     = 'TOP'
                window   = 'MAIN'.
    endif.

* Get sequence
    if resbd-plnfl ne affld-plnfl or resbd-aufnr ne caufvd-aufnr.
      read table affld_tab index index_tab-index_seq.
      affld = affld_tab.
* Read ATAB-Tables for sequence
      perform pppr_get_tables using drpart-seq.
    endif.

* Get operation
    if resbd-aplzl ne afvgd-aplzl or resbd-aufnr ne afvgd-aufnrd.
      read table afvgd_tab index index_tab-index_opr.
      afvgd = afvgd_tab.
* Read ATAB-Tables for sequence
      perform pppr_get_tables using drpart-opr.
* set flag 'write info of operation'
      clear flg_opr_info.
      aplzl_sav = afvgd-aplzl.
    endif.

* Get ATAB-tables of component
    perform pppr_get_components.

* print data of components
    call function 'CONTROL_FORM'
         exporting
              command = 'PROTECT'.

    if print_co-barco is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'CMP_DATA'
                window  = 'MAIN'.
    else.
      call function 'WRITE_FORM'
           exporting
                element = 'CMP_DATA_BC'
                window  = 'MAIN'.
    endif.
    call function 'CONTROL_FORM'
         exporting
              command = 'ENDPROTECT'.
    if print_co-barco is initial.
      call function 'WRITE_FORM'
           exporting
                element  = 'CMP_DATA_HDR'
                function = 'DELETE'
                type     = 'TOP'
                window   = 'MAIN'.
    else.
      call function 'WRITE_FORM'
           exporting
                element  = 'CMP_DATA_BC_HDR'
                function = 'DELETE'
                type     = 'TOP'
                window   = 'MAIN'.
    endif.
* print material text
    perform pppr_print_cmp_text.
  endloop.

* Get subpositions if forced.
* check read_stpu eq 'X'
*   and not resbd-stlnr is initial
*   and not resbd-stlkn is initial
*   and not resbd-stlty is initial.
* clear: stpub.
* stpub-stlty = resbd-stlty.
* stpub-stlnr = resbd-stlnr.
* stpub-stlkn = resbd-stlkn.
* stpub-stpoz = resbd-stpoz.
*
* perform stpu_lesen.
*
* After This a loop at STPUB has to be programmed. For each entry a
* element of the sapscript has to be called
endform.

*---------------------------------------------------------------------*
*       FORM CHECK_PRINT                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form check_print.
  data: flg_print.

  loop at itab_tdr where object = obj-mat
                   and   aufnr  = print_co-aufnr.   "New 3.0
    read table resbd_tab index itab_tdr-index_plmz.
    check sy-subrc is initial
    and   resbd_tab-kzkup eq space     "New 3.0
    and   resbd_tab-dumps eq space
    and   resbd_tab-bdmng gt 0.
    flg_print = const-flg_yes.
    exit.
  endloop.
  if flg_print eq const-flg_yes.
    sy-subrc = 12.
  endif.
endform.
*---------------------------------------------------------------------*
*        STPU_LESEN                                                   *
*---------------------------------------------------------------------*
*        Input :                                                      *
*                                                                     *
*        Output:                                                      *
*                                                                     *
*---------------------------------------------------------------------*
form stpu_lesen.
  call function 'GET_STPU'
       exporting
            set             = 'X'
            all             = 'X'
       tables
            wa              = stpub
       exceptions
            no_record_found = 4
            key_incomplete  = 16
            call_invalid    = 24.
endform.

include codrgett.
include codrif01.    "PPPR-Form-Routinen: Druck-Parts lesen
include codrif02.    "PPPR-Form-Routinen: Open/Close Form
include codrif03.    "PPPR-Form-Routinen: print_prodnet_info
include codrif04.                      "PPPR-Form-Routinen: read_mat
include codrif07.    "PPPR-Form-Routinen: print_ord_text
include codrif13.    "PPPR-Form-Routinen: print_cmp_text
include codrif15.    "PSFC-Form-Routinen: get_components
