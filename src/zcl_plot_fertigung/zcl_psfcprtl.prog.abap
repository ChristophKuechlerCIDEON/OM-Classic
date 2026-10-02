report psfcprtl message-id co.
*---------------------------------------------------------------------*
*                                                                     *
* PPC-Print: PRT list                                                 *
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
* constants for PRT-handling
include cf00cons.

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

* print-type
  case prlst_tmp-drart.
    when reprint.
      move text-dup to prlst_tmp-drtxt.
    when others.
      clear prlst_tmp-drtxt.
  endcase.

  loop at itab_tdr
       where object = obj-fhm
       and   aufnr  = prlst_tmp-aufnr. "New 3.0

*   Read PRT-allocation data
    read table affhd_tab index itab_tdr-index_plfh.
    affhd = affhd_tab.
*   PRT deleted?
    if affhd-loekz is initial.
      exit.
    endif.
  endloop.

  check sy-subrc is initial.

* fill workarea of header (probably more than 1 order is to be printed)

  loop at itab_tdr where object = obj-alt
                   and   aufnr  = prlst_tmp-aufnr. "New 3.0
* Save Indextable of header
    itab_ord = itab_tdr.

    loop at caufvd_tab where aufnr = itab_tdr-aufnr.
      perform pppr_std_init_order using caufvd_tab.
* Get position
      read table afpod_tab with key aufnr = caufvd-aufnr
                                    posnr = '0001'.
      afpod = afpod_tab.
      do prlst_tmp-copys times.
        if sy-index gt 1.
          move text-dup to prlst_tmp-drtxt.
        endif.
* call OPEN_FORM to open formular
        perform pppr_open_form using 'PAG_STD'.
* print info's of order-header
        perform lg01_header.
* print info's of PRTs
        perform lg01_prt.
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
  perform pppr_print_prodnet_info.     "New 3.0
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
* new with 3.0: print production note
  perform pppr_print_prod_note.
* print routing text
  perform pppr_print_routing_text.

endform.
*---------------------------------------------------------------------*
*       FORM LG01_PRT                                                 *
*---------------------------------------------------------------------*
*       Production resources and tools                                *
*---------------------------------------------------------------------*
form lg01_prt.

  data: flg_seq_new_page.
  data: flg_new_seq.
* Postscript text key
  data: begin of ltsch_ps_text,
          mandt like draw-mandt,
          dokar like draw-dokar,
          doknr like draw-doknr,
          dokvr like draw-dokvr,
          doktl like draw-doktl,
        end   of ltsch_ps_text.
  data: thead_tab    like thead occurs 0,
        thead_tab_wa like thead.
  data: tab_size_tmp like sy-tabix.
  data: objky_tmp like  drad-objky.

  clear flg_seq_new_page.
  clear flg_new_seq.
  clear stxh_tab.
  refresh stxh_tab.

* PRT-allocations of an order
  loop at itab_tdr
       where object = obj-fhm
       and   aufnr  = itab_ord-aufnr.

* initialize PRT
    perform pppr_std_init_prt using x_field.
    check not x_field is initial.
* new-sequence ?
    if affld-plnfl ne itab_tdr-aplfl.
* print sequence header
      perform pppr_print_seq_header using
                                    flg_seq_new_page 'PAGE_NEW' x_field.
      check not x_field is initial.
      flg_new_seq = const-flg_yes.
    endif.
    if    itab_tdr-uvorn <> afvgd-uvorn
       or itab_tdr-vornr <> afvgd-vornr
       or itab_tdr-aplfl <> afvgd-plnfl.
* initialize operation
      perform pppr_std_init_operation
              using x_field const-flg_yes space space.
      check not x_field is initial.

      if flg_new_seq is initial.
        call function 'WRITE_FORM'
             exporting
                  element = 'LINE'
                  window  = 'MAIN'.
      else.
        clear flg_new_seq.
      endif.
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
    endif.
* init PRT
    perform pppr_std_init_prt using x_field.
* print PRT
    call function 'WRITE_FORM'
         exporting
              element = 'LINE_DOTTED'
              window  = 'MAIN'.
    call function 'CONTROL_FORM'
         exporting
              command = 'PROTECT'.
    call function 'WRITE_FORM'
         exporting
              element = 'PRT_OPR_HDR'
              window  = 'MAIN'.
    call function 'WRITE_FORM'
         exporting
              element = 'PRT_DATA_HDR'
              window  = 'MAIN'.
    call function 'WRITE_FORM'
         exporting
              element = 'PRT_DATA'
              window  = 'MAIN'.
* print prt text
    perform pppr_print_prt_text.
    call function 'CONTROL_FORM'
         exporting
              command = 'ENDPROTECT'.

* Print PRT text information
    if not tcf10-xexpand is initial.
      case affhd-fhmar.
        when material.
          objky_tmp = affhd-matnr.
          perform get_act_documents_for_object tables stxh_tab
                                             using  objky_tmp
                                                    dokob-mara.
        when dokument.
* Fill text file key
* Document EPS Text file
          ltsch_ps_text-mandt = '000'.
          ltsch_ps_text-dokar = affhd-dokar.
          ltsch_ps_text-doknr = affhd-doknr.
          ltsch_ps_text-dokvr = affhd-dokvr.
          ltsch_ps_text-doktl = affhd-doktl.
          stxh_tab-tdname   = ltsch_ps_text.
          stxh_tab-tdobject = 'TEXT'.
          stxh_tab-tdid     = 'ST  '.
          stxh_tab-tdspras  = sy-langu.
          append stxh_tab.
        when sonstige.
          objky_tmp = affhd-sfhnr.
          perform get_act_documents_for_object tables stxh_tab
                                             using  objky_tmp
                                                    dokob-fhms.
        when equipment.
          objky_tmp = affhd-equnr.
          perform get_act_documents_for_object tables stxh_tab
                                             using  objky_tmp
                                                    dokob-equi.
      endcase.
      loop at stxh_tab.
*...... check text file
        refresh thead_tab.
        call function 'SELECT_TEXT'
             exporting
                  client                  = sy-mandt
                  name                    = stxh_tab-tdname
                  object                  = stxh_tab-tdobject
                  id                      = stxh_tab-tdid
                  language                = stxh_tab-tdspras
             tables
                  selections              = thead_tab
             exceptions
                  wrong_access_to_archive = 01.
        read table thead_tab index 1 into thead_tab_wa.
        if sy-subrc is initial.
*........ print text file
          move-corresponding stxh_tab to stxh.               "for layout
          call function 'WRITE_FORM'
               exporting
                    element = 'PRT_EPS_TEXT'
                    window  = 'MAIN'.
        endif.
      endloop.
      refresh stxh_tab.
      clear   stxh_tab.
    endif.
  endloop.                             "ITAB_TDR OBJ-FHM
endform.

include codrgett.     "PPPR-Form-Routinen: pppr_get_tables
include codrif01.     "PPPR-Form-Routinen: Druck-Parts lesen
include codrif02.     "PPPR-Form-Routinen: Open/Close Form
include codrif03.     "PPPR-Form-Routinen: print_prodnet_info
include codrif04.                      "PPPR-Form-Routinen: read_mat
include codrif06.     "PSFC-Form-Routinen: print_prod_note
include codrif07.     "PPPR-Form-Routinen: print_ord_text
include codrif12.     "PPPR-Form-Routinen: print_fhm_text
include codrif16.     "PSFC-Form-Routinen: print_seq_header
include codrif17.     "PSFC-Form-Routinen: std_init_operation
include codrif18.     "PSFC-Form-Routinen: print_routing_text
include codrif19.                      "PSFC-Form-Routinen: std_init_prt
