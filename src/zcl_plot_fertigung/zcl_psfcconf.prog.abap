report psfcconf message-id co.
*---------------------------------------------------------------------*
*                                                                     *
* PPS-Print: Confirmation-Tickets (Rückmeldescheine)                  *
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
* 08.02.2007 - Integration Werksabhängigkeit der Verteiler
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
                   and   aufnr  = print_co-aufnr.           "New 3.0
    exit.
  endloop.

  check sy-subrc is initial.

* fill workarea of header (probably more than 1 order is to be printed)

  read table itab_tdr with key object = obj-alt
                               aufnr  = print_co-aufnr.     "New 3.0
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
    use_default = 'X'.            " default destination in 1st run
    loop at destination_tab.
      pr_options-tddest = destination_tab-dest.
* call OPEN_FORM to open formular
      perform pppr_open_form using 'MAIN'.
* Print confirmation tickets
      perform confirmation_ticket using print_co-use_wcp
                                        destination_tab-dest
                                        use_default.
* call CLOSE_FORM to finish formular
      perform pppr_close_form.
      clear use_default.          " default destination only in 1st run
    endloop.
  enddo.
endform.
*---------------------------------------------------------------------*
*       FORM CONFIRMATION_TICKET                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form confirmation_ticket using use_wcp     like t496p-use_wcp
                               destination like t496p-drdest
                               use_default.
  data: counter_abs(4) type n.
  data: number_of_tickets(4) type n.
  data flg_act_read.

  clear counter_abs.
  loop at itab_tdr where object = obj-pos
                   or    object = obj-sop
                   and   aufnr  = itab_ord-aufnr.
* Save ITAB of operation
    itab_vrg = itab_tdr.
* Get sequenze (only if changed)
    if itab_vrg-aplfl ne affld-plnfl or itab_vrg-aufnr ne affld-aufnr.
      read table affld_tab index itab_tdr-index_plfl.
      affld = affld_tab.
      perform pppr_get_tables using drpart-seq.
    endif.
* initialize operation
    perform pppr_std_init_operation
            using x_field space space const-flg_yes.
    check not x_field is initial.
* output only for work center printer
    check    use_wcp is initial         "no use of work center printer
          or destination = afvgd-pdest  "wcp requested
          or (    afvgd-pdest is initial"if wcp not given ...
              and not use_default is initial ). "... use default printer
* if number of tickets 'RSANZ' not given no print
    if not rcr01-rsanz_ref is initial.
      check not rcr01-rsanz is initial.
      number_of_tickets = rcr01-rsanz.
    else.
      check not afvgd-rsanz is initial.
      number_of_tickets = afvgd-rsanz.
    endif.

    clear flg_act_read.
* Print each ticket for number of ticket times
    do number_of_tickets times.
* increment counter of tickets on page by 1
      add 1 to counter_abs.
* check wether number of tickets on page greater than possible
      if not print_co-azabs is initial.
        if counter_abs > print_co-azabs.
* if greater create a new page
          call function 'CONTROL_FORM'
               exporting
                    command = 'NEW-PAGE'.
* reset the counter and add 1 for new page
          clear counter_abs.
          add 1 to counter_abs.
        endif.
      endif.
* preserve form of skip
      call function 'CONTROL_FORM'
           exporting
                command = 'PROTECT'.
* print header
      call function 'WRITE_FORM'
           exporting
                element = 'HDR_STD'
                window  = 'MAIN'.
* print operation header
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
      perform psfc_print_activities using afvgd.
*      PERFORM PPPR_PRINT_ACTIVITIES USING
*                                    AFVGD RCR01 TTL_ACTIV FLG_ACT_READ.
* print mask for manual entries
      call function 'WRITE_FORM'
           exporting
                element = 'OPR_MASK'
                window  = 'MAIN'.
* end preservation of form
      call function 'CONTROL_FORM'
           exporting
                command = 'ENDPROTECT'.
    enddo.
  endloop.
endform.

include codrgett.   "PPPR-Form-Routinen: pppr_get_tables
include codrif01.   "PPPR-Form-Routinen: Druck-Parts lesen
include codrif02.   "PPPR-Form-Routinen: Open/Close Form
include codrif04.                      "PPPR-Form-Routinen: read_mat
include codrif05.   "PPPR-Form-Routinen: print_activities
include codrif17.          "PSFC-Form-Routinen: std_init_operation
include codrif20.   "PSFC-Form-Routinen: pppr_collect_destinations
