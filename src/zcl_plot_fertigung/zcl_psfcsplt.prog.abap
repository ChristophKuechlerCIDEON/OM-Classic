report psfcsplt message-id co.
*---------------------------------------------------------------------*
*                                                                     *
* PPS-Print: Operation-split                                          *
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

* schreiben der spool id in zcl_psb_tmp oder ins memory
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

wa_item-aufnr_pp = print_co-aufnr.


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
  data use_default.

* Document-tables
  include lcodrinc.

  loop at itab_tdr where object = obj-pos
                   or    object = obj-sop
                   and   aufnr  = print_co-aufnr.
    exit.
  endloop.

  check sy-subrc is initial.

* fill workarea of header (probably more than 1 order is to be printed)

  read table itab_tdr with key object = obj-alt
                               aufnr  = print_co-aufnr.
  check sy-subrc is initial.
* Save Indextable of header
  itab_ord = itab_tdr.

  read table caufvd_tab with key aufnr = itab_ord-aufnr.
  check sy-subrc is initial.

  perform pppr_std_init_order using caufvd_tab.

  perform pppr_collect_destinations using  print_co.

  do print_co-copys times.
    if sy-index gt 1.
      move text-dup to print_co-drtxt.
    endif.
* get destination
    use_default = 'X'.                 " default destination in 1st run
    loop at destination_tab.
      pr_options-tddest = destination_tab-dest.
* call OPEN_FORM to open formular
      perform pppr_open_form using 'MAIN'.
* Print split tickets
      perform split_ticket using print_co-use_wcp
                                 destination_tab-dest
                                 use_default.
* call CLOSE_FORM to finish formular
      perform pppr_close_form.
      clear use_default.          " default destination only in 1st run
    endloop.
  enddo.
endform.
*---------------------------------------------------------------------*
*       FORM SPLIT_TICKET                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form split_ticket using use_wcp     like t496p-use_wcp
                        destination like t496p-drdest
                        use_default.
  data: counter_abs(4) type n.
  data: number_of_tickets(4) type n.
  data: begin of b occurs 0.
          include structure kbedp.
  data: end of b.
  data: begin of a.
          include structure afvgd.
  data: end of a.
  data flg_act_read.

  clear counter_abs.
  loop at itab_tdr where object = obj-pos
                   or    object = obj-sop
                   and   aufnr  = itab_ord-aufnr.
* Save ITAB of operation
    itab_vrg = itab_tdr.
* Get sequence (only if changed)
    if itab_vrg-aplfl ne affld-plnfl or itab_vrg-aufnr ne affld-aufnr.
      read table affld_tab index itab_tdr-index_plfl.
      affld = affld_tab.
      perform pppr_get_tables using drpart-seq.
    endif.
* initialize operation
    perform pppr_std_init_operation
            using x_field space const-flg_yes space.
    check not x_field is initial.
* output only for work center printer
    check use_wcp is initial                  "no use of wcp
    or    destination = afvgd-pdest           "wcp requested
    or    ( afvgd-pdest is initial            "if wcp not given ...
            and not use_default is initial ). "... use default printer

    clear flg_act_read.
    read table kbedp_tab
         with key bedid = afvgd-bedid
                  bedzl = afvgd-bedzl
         binary search transporting no fields.
    if sy-subrc = 0.
      loop at kbedp_tab from sy-tabix.
        if kbedp_tab-bedid <> afvgd-bedid
        or kbedp_tab-bedzl <> afvgd-bedzl.
          exit.
        endif.
        kbedp = kbedp_tab.
        move-corresponding kbedp to a.
* calculation of the activities using the operation-formalism
        perform get_activity(saplcodr)
                using a
                      rcr01
                      ttl_activ
                      afvgd-mgvrg
                      caufvd.
        add 1 to counter_abs.
* check wether number of tickets on page greater than possible
        if not print_co-azabs is initial.
          if counter_abs > print_co-azabs.
            call function 'CONTROL_FORM'
                 exporting
                      command = 'NEW-PAGE'.
            clear counter_abs.
            add 1 to counter_abs.
          endif.
        endif.

* preserve form of skip
        call function 'CONTROL_FORM'
             exporting
                  command = 'PROTECT'.
* print infos of header
        call function 'WRITE_FORM'
             exporting
                  element = 'HDR_STD'
                  window  = 'MAIN'.
* print infos of operation
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_SPLT_HDR'
                  window  = 'MAIN'.
* print operation info (optional with barcode)
        if print_co-barco is initial.
          call function 'WRITE_FORM'
               exporting
                    element = 'OPR_SPLT'
                    window  = 'MAIN'.
        else.
          call function 'WRITE_FORM'
               exporting
                    element = 'OPR_SPLT_BC'
                    window  = 'MAIN'.
        endif.
* print operation text
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_TEXT_SHORT'
                  window  = 'MAIN'.
* print activities
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_ACT_TYP'
                  window  = 'MAIN'.
* print infos depending on the type of split
        if kbedp-ename is initial.
* print infos of machine-split
          call function 'WRITE_FORM'
               exporting
                    element = 'OPR_TYP_MACH'
                    window  = 'MAIN'.
        else.
* print infos of pers-split
          call function 'WRITE_FORM'
               exporting
                    element = 'OPR_TYP_PERS'
                    window  = 'MAIN'.
        endif.
* print mask for manual entries
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_MASK'
                  window  = 'MAIN'.
* end preservation of slip
        call function 'CONTROL_FORM'
             exporting
                  command = 'ENDPROTECT'.
      endloop.
* no kbeds found
    else.
* calculation of the activities using the operation-formalism
      perform get_activity(saplcodr)
              using afvgd
                    rcr01
                    ttl_activ
                    afvgd-mgvrg
                    caufvd.
      if afvgd-spanz = 0.
        afvgd-spanz = 1.
      endif.
      do afvgd-spanz times.
        kbedp-split = sy-index.
        add 1 to counter_abs.
* check wether number of tickets on page greater than possible
        if not print_co-azabs is initial.
          if counter_abs > print_co-azabs.
            call function 'CONTROL_FORM'
                 exporting
                      command = 'NEW-PAGE'.
            clear counter_abs.
            add 1 to counter_abs.
          endif.
        endif.

* preserve form of skip
        call function 'CONTROL_FORM'
             exporting
                  command = 'PROTECT'.
* print infos of header
        call function 'WRITE_FORM'
             exporting
                  element = 'HDR_STD'
                  window  = 'MAIN'.
* print infos of operation
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_DATA_HDR'
                  window  = 'MAIN'.
* print operation info (optional with barcode)
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
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_TEXT_SHORT'
                  window  = 'MAIN'.
* print activities
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_ACT_TYP'
                  window  = 'MAIN'.
* print mask for manual entries
        call function 'WRITE_FORM'
             exporting
                  element = 'OPR_MASK'
                  window  = 'MAIN'.
* end preservation of slip
        call function 'CONTROL_FORM'
             exporting
                  command = 'ENDPROTECT'.
      enddo.
    endif.
  endloop.
endform.

* INCLUDE for ATAB-Table-Read
include codrgett.     "PPPR-Form-Routinen: pppr_get_tables
include codrif01.     "PPPR-Form-Routinen: Druck-Parts lesen
include codrif02.     "PPPR-Form-Routinen: Open/Close Form
include codrif04.                      "PPPR-Form-Routinen: read_mat
include codrif17.          "PSFC-Form-Routinen: std_init_operation
include codrif20.   "PSFC-Form-Routinen: pppr_collect_destinations
