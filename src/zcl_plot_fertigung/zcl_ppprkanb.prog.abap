report ppprkanb message-id co.
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

* fill workarea of header (probably more than 1 order is to be printed)

  loop at itab_tdr where object = obj-alt.

* Save Indextable of header
    itab_ord = itab_tdr.

    loop at caufvd_tab where aufnr = itab_tdr-aufnr.
* fill DDIC-Structure of header from internal table
      caufvd = caufvd_tab.
* Get position
      loop at afpod_tab where aufnr eq caufvd-aufnr and
                              posnr eq '0001'.
        afpod = afpod_tab.
        exit.
      endloop.

* KANBAN-order ?
      check afpod-kbnkz eq 'X'.

* fill DDIC-Structur from internal table
      print_co = prlst_tmp.

* fill table PRINT-Options
      call function 'CO_DR_PR_OPT_FILL'
           exporting
                prt_co = prlst_tmp
           importing
                pr_opt = pr_options.

      call function 'PK_PRINT_KANBAN_SFC'
           exporting
                iaufnr             = caufvd-aufnr
                iposnr             = afpod-posnr
                iitcpo             = pr_options
                itdform            = prlst_tmp-forml
           exceptions
                insufficient_input = 01
                header_not_found   = 02
                pvb_not_found      = 03
                no_printer         = 04.

    endloop.
*
  endloop.
endform.

include codrgett.
