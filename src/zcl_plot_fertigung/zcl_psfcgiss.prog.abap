report psfcgiss message-id co.
*---------------------------------------------------------------------*
*
* PPS-Print: Goods-Issue-Slip (Warenentnahmeschin)
*
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
* 09.02.2007 - Integration Werksabhängigkeit der Verteiler
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

  read table itab_tdr with key object = obj-mat
                               aufnr  = print_co-aufnr.    "New 3.0

  check sy-subrc is initial.

* fill workarea of header (probably more than 1 order is to be printed)

  loop at itab_tdr where object = obj-alt
                   and   aufnr  = print_co-aufnr.   "New 3.0
* Save Indextable of header
    itab_ord = itab_tdr.

    loop at caufvd_tab where aufnr = itab_ord-aufnr.
      perform pppr_std_init_order using caufvd_tab.
      do print_co-copys times.
        if sy-index gt 1.
          move text-dup to print_co-drtxt.
        endif.
* call OPEN_FORM to open formular
        perform pppr_open_form using 'MAIN'.
        perform goods_issue_slip.
* call CLOSE_FORM to finish formular
        perform pppr_close_form.
      enddo.
    endloop.
    exit.
  endloop.
endform.
*---------------------------------------------------------------------*
*       FORM GOODS_ISSUE_SLIP                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form goods_issue_slip.
  data: counter_abs(2) type n.
  data: number_of_tickets(2) type n.
  data: begin of index_tab occurs 0,
          index_cmp like sy-tabix,
          index_seq like sy-tabix,
          index_opr like sy-tabix,
          plnfl     like resbd-plnfl,
          vornr     like resbd-vornr,
          lgort     like resbd-lgort,
          posnr     like resbd-posnr,
        end of index_tab.

* build short table for sort of components
  loop at itab_tdr where object = obj-mat
                     and aufnr eq itab_ord-aufnr.
* Fill DDIC-Strutcure of component
    read table resbd_tab index itab_tdr-index_plmz.
* found ?
    check sy-subrc is initial.
    resbd = resbd_tab.
* no slip for
    check resbd-dumps is initial and   "keine Dummys
          resbd-rgekz is initial and   "keine mit retrograder Ent
      not resbd-matnr is initial and   "keine ohne Materialnummer
          resbd-dbskz is initial and   "keine direktbeschaftten
          resbd-bdmng gt 0       and   "keine Zugänge
          resbd-kzkup eq space   and   "keine Zugänge   New 3.0
          resbd-shkzg ne 'S'     and   "keine Zugänge
          resbd-schgt is initial.      "kein Schüttgut
    index_tab-index_cmp = itab_tdr-index_plmz.
    index_tab-index_seq = itab_tdr-index_plfl.
    index_tab-index_opr = itab_tdr-index_plpo.
    move-corresponding resbd_tab to index_tab.
    append index_tab.
  endloop.

  describe table index_tab lines sy-dbcnt.
  check sy-dbcnt gt 0.

* sort index table
  sort index_tab by plnfl vornr lgort posnr.

  clear counter_abs.
  loop at index_tab.
* Read component from internal table
    read table resbd_tab index index_tab-index_cmp.
    check sy-subrc is initial.
    resbd = resbd_tab.
* number of records on page specified ?
    if not print_co-azabs is initial.
      add 1 to counter_abs.
      if counter_abs > print_co-azabs.
        call function 'CONTROL_FORM'
             exporting
                  command = 'NEW-PAGE'.
        clear counter_abs.
        add 1 to counter_abs.
      endif.
    endif.

* Read sequence
    if    index_tab-index_seq ne affld-plnfl
       or affld-aufnr ne caufvd-aufnr.
      read table affld_tab index index_tab-index_seq.
      affld = affld_tab.
      perform pppr_get_tables using drpart-seq.
    endif.
* Read operation
    if    index_tab-index_opr ne afvgd-aplzl
       or afvgd-aufnrd ne caufvd-aufnr.
      read table afvgd_tab index index_tab-index_opr.
      afvgd = afvgd_tab.
      perform pppr_get_tables using drpart-opr.
    endif.
* Get ATAB's for component
    perform pppr_get_tables using drpart-cmp.
* Get MSFCV for component
    clear msfcv.
    if not resbd-matnr is initial.
      perform pppr_read_mat using resbd-werks resbd-matnr msfcv.
    endif.

    call function 'CONTROL_FORM'
         exporting
              command = 'PROTECT'.

* print data of components
    call function 'WRITE_FORM'
         exporting
              element = 'HDR_RES'
              window  = 'MAIN'.
    if not print_co-barco is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'BARCODE_RSNUM_RSPOS'
                window  = 'MAIN'.
    endif.
* print without barcodes
    call function 'WRITE_FORM'
         exporting
              element = 'CMP_DATA_HDR'
              window  = 'MAIN'.
    call function 'WRITE_FORM'
         exporting
              element = 'CMP_DATA'
              window  = 'MAIN'.
    call function 'WRITE_FORM'
         exporting
              element = 'CMP_INST'
              window  = 'MAIN'.
* print data if variable sized items are given
    if not resbd-roms1 is initial
    or not resbd-roms2 is initial
    or not resbd-roms3 is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'CMP_VAR_SIZED'
                window  = 'MAIN'.
    endif.

    call function 'WRITE_FORM'
         exporting
              element = 'LINE_EMPTY'
              window  = 'MAIN'.
    call function 'WRITE_FORM'
         exporting
              element = 'LINE_EMPTY'
              window  = 'MAIN'.
    call function 'CONTROL_FORM'
         exporting
              command = 'ENDPROTECT'.
  endloop.
endform.

* INCLUDE for ATAB-Table-Read
include codrgett.     "PPPR-Form-Routinen: pppr_get_tables
include codrif01.     "PPPR-Form-Routinen: Druck-Parts lesen
include codrif02.     "PPPR-Form-Routinen: Open/Close Form
include codrif04.                      "PPPR-Form-Routinen: read_mat
