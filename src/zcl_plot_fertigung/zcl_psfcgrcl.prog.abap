report psfcgrcl message-id co.
*---------------------------------------------------------------------*
*                                                                     *
* PPS-Print: Good-Receipt-List (Zugangsliste)
*                                                                     *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Journal
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------

data: kzkup_m like resbd-kzkup.
data: kzkup_o like resbd-kzkup value 'X'.

data: begin of zug_tab occurs 0,
        r like resbd,
        a like afpod,
      end of zug_tab.

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

* fill workarea of header (probably more than 1 order is to be printed)

  loop at itab_tdr where object = obj-alt
                   and   aufnr  = print_co-aufnr.

* Save Indextable of header
    itab_ord = itab_tdr.

    loop at caufvd_tab where aufnr = itab_ord-aufnr.
      perform pppr_std_init_order using caufvd_tab.
      do print_co-copys times.
        if sy-index gt 1.
          move text-dup to print_co-drtxt.
        endif.
* call OPEN_FORM to open formular
        perform pppr_open_form using 'PAG_STD'.
* print info's of order-header
        perform zug_header.
* print receiped goods
        perform zug_list.
* call CLOSE_FORM to finish formular
        perform pppr_close_form.
      enddo.
    endloop.
  endloop.
endform.
*---------------------------------------------------------------------*
*       FORM ZUG_HEADER                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form zug_header.
  perform pppr_print_prodnet_info.     "New 3.0
* if BARCODE forced the print
  if not print_co-barco is initial.
* standard: materialnumber and order-number as Barcode:
    call function 'WRITE_FORM'
         exporting
              element = 'BARCODE_AUFNR_MATNR'
              window  = 'MAIN'.
  endif.
* print order text
  perform pppr_print_ord_text.
endform.
*---------------------------------------------------------------------*
*       FORM ZUG_LIST                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form zug_list.
* Informations to main-position
  perform get_first_pos_info.
  perform print_first_pos_info.

*  get informations of by-products
  perform build_zug_tab.

* Print list
  if not kzkup_m is initial.
    perform print_from_zug_tab using kzkup_m.
  endif.
  if kzkup_o is initial.
    perform print_from_zug_tab using kzkup_o.
  endif.

endform.

*&---------------------------------------------------------------------*
*&      Form  GET_FIRST_POS_INFO
*&---------------------------------------------------------------------*
*       Zugang (Auftragsposition 1) nach AFPOD
*----------------------------------------------------------------------*
form get_first_pos_info.

* build short table for sort of components
  loop at afpod_tab where aufnr = caufvd-aufnr
                    and   posnr  = 1.
    afpod = afpod_tab.
    exit.
  endloop.
endform.                               " GET_FIRST_POS_INFO

*&---------------------------------------------------------------------*
*&      Form  BUILD_ZUG_TAB
*&---------------------------------------------------------------------*
*   Kuppelprodukte mit/ohne Abrechnung nach ZUG_TAB                    *
*----------------------------------------------------------------------*
form build_zug_tab.

* build short table for sort of components
  loop at resbd_tab where aufnr = caufvd-aufnr
                   and  flg_loe eq space
* SHKZG = 'S' <=> amount of component less than 0
                   and shkzg    eq 'S'
* not printed will be: Dummy's
                   and  dumps   eq space
* first position is already printed
                   and  afpos   ne 1.

    clear afpod_tab.

* byproduct without settlement ?
    if resbd_tab-kzkup eq space.
      clear kzkup_o.

* byproduct with settlement ?
    else.
* read corresponding position
      loop at afpod_tab where aufnr = caufvd-aufnr
                        and   posnr = resbd_tab-afpos.
        move-corresponding afpod_tab to zug_tab-a.
        kzkup_m = resbd_tab-kzkup.
        exit.
      endloop.
    endif.

* in any case: Reservierungsbedarf -> ZUG_TAB
    move-corresponding resbd_tab to zug_tab-r.
    append zug_tab.
  endloop.
  sort zug_tab by a-posnr ascending.
endform.                               " BUILD_ZUG_TAB

*---------------------------------------------------------------------*
*       FORM PRINT_FIRST_POS_INFO                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form print_first_pos_info.

  call function 'CONTROL_FORM'
       exporting
            command = 'PROTECT'.
* Call SAPSCRIPT-element for AFPOD
* first print title
  call function 'WRITE_FORM'
       exporting
            element = 'CMP_GRL_HDR1'
            window  = 'MAIN'.
* and header
  call function 'WRITE_FORM'
       exporting
            element = 'CMP_GRL_HDR'
            window  = 'MAIN'.

* print data of components
  call function 'WRITE_FORM'
       exporting
            element = 'CMP_GRL_AFPOD'
            window  = 'MAIN'.
  call function 'CONTROL_FORM'
       exporting
            command = 'ENDPROTECT'.
endform.

*&---------------------------------------------------------------------*
*&      Form  PRINT_FROM_ZUG_TAB
*&---------------------------------------------------------------------*
*       Print loop über ZUG_TAB
*----------------------------------------------------------------------*
form print_from_zug_tab
     using kzkup_x.

  data: flg_head.
  data: flg_protect.
  data: flg_opr_info.
  data: aplzl_sav like afvgd-aplzl.
  data: element_hdr like itcce-tdevent.

  describe table zug_tab lines sy-dbcnt.

  check sy-dbcnt gt 0.                 " ZUG_TAB empty

* Kuppelprodukt mit/ohne Abrechnung existiert?
  loop at zug_tab where r-kzkup eq kzkup_x.
    exit.
  endloop.
  check sy-subrc eq 0.

  clear flg_head.
  clear flg_protect.
  clear afpod.

  if kzkup_x is initial.
    element_hdr = 'CMP_GRL_HDR2'.
  else.
    element_hdr = 'CMP_GRL_HDR3'.
  endif.

* Print all materials for the current order (now in sorted order)
  loop at zug_tab where r-kzkup eq kzkup_x.
* Fill DDIC-Strutcures of components
    if kzkup_x ne space.
      move-corresponding zug_tab-a to afpod.
    endif.
    move-corresponding zug_tab-r to resbd.
* at first entry print print description
    if flg_head is initial.
      call function 'CONTROL_FORM'
           exporting
                command = 'PROTECT'.
      flg_protect = 'X'.
      call function 'WRITE_FORM'
           exporting
                element = element_hdr
                window  = 'MAIN'.
      call function 'WRITE_FORM'
           exporting
                element  = element_hdr
                function = 'SET'
                type     = 'TOP'
                window   = 'MAIN'.
* and header
      call function 'WRITE_FORM'
           exporting
                element = 'CMP_GRL_HDR'
                window  = 'MAIN'.
      call function 'WRITE_FORM'
           exporting
                element  = 'CMP_GRL_HDR'
                function = 'APPEND'
                type     = 'TOP'
                window   = 'MAIN'.
      flg_head = const-flg_yes.
    endif.

* print data of components
    if kzkup_x is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'CMP_GRL_RESBD'
                window  = 'MAIN'.
    else.
      call function 'WRITE_FORM'
           exporting
                element = 'CMP_GRL_AFPOD'
                window  = 'MAIN'.
    endif.
    if not flg_protect is initial.
      call function 'CONTROL_FORM'
           exporting
                command = 'ENDPROTECT'.
      clear flg_protect.
    endif.

  endloop.

  call function 'WRITE_FORM'
       exporting
            element  = element_hdr
            function = 'DELETE'
            type     = 'TOP'
            window   = 'MAIN'.
  call function 'WRITE_FORM'
       exporting
            element  = 'CMP_GRL_HDR'
            function = 'DELETE'
            type     = 'TOP'
            window   = 'MAIN'.

endform.                               " PRINT_FROM_ZUG_TAB

include codrgett.                      "PPPR-Form-Routinen: get_tables
include codrif01.         "PPPR-Form-Routinen: Druck-Parts lesen
include codrif02.         "PPPR-Form-Routinen: Open/Close Form
include codrif03.         "PPPR-Form-Routinen: print_prodnet_info
include codrif04.                      "PPPR-Form-Routinen: read_mat
include codrif07.         "PPPR-Form-Routinen: print_ord_text
