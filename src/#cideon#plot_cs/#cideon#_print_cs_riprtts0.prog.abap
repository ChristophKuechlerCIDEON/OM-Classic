report riprtts0.
************************************************************************
* Print Drive ABAP for Time Ticket                                     *
*                                                                      *
* Standard FORM is  PM_COMMON                                          *
*----------------------------------------------------------------------*
* ABAP STEPS:                                                          *
*    1: IMPORT data to print.                                          *
*                                                                      *
*    2: Parse of Data to print FORM.                                   *
*       The external text tables will be read as necessary.            *
*                                                                      *
*    3: Save Print-Protocol records in PMPL                            *
************************************************************************
*$*$  D A T A    S E C T I O N    I N C L U D E S ---------------------*
include riprid01.                      " General DATA and TABLE struct.
************************************
start-of-selection.
***********************************
 perform print_paper.  "can be started via SUBMIT or PERFORM PRINT_PAPER

*$*$ ................ M A I N     F O R M .............................*
*... DATA STRUCTURE: ..................................................*
*...                                                                   *
*...    CAUFVD (AFIH AUFK AFKO plus other dialog fields: ORDER HEADER) *
*...     |                                                             *
*...     |-- AFVGD       (AFVC AFVV plus dialog fields) Order operatns *
*...     |   |                                                         *
*...     |   |-- The sub operations also stored AFVGD and are pre      *
*...     |   |   sorted. The SUMNR fields distinguishes Main operaitons*
*...     |   |   and sub operations                                    *
*...     |   |
*        |   |-- KBEDP             Capacities per operation
*        |                                                             *
*...     |-- RESBD                 Materials                           *
*...     |-- RIPW0                 Object list dialog area             *
*......................................................................*

*----------------------------------------------------------------------*
*       FORM PRINT_PAPER                                               *
*----------------------------------------------------------------------*
*       Main driving Form behind the Printing of Papers                *
*       All information is imported from MEMORY                        *
*----------------------------------------------------------------------*
*  -->  FORM        Name of SAPSCRIPT form to use.                     *
*  -->  WWORKPAPER  Print options for SAPSCRIPT.                       *
*                   Structure command to define wworkpaper so the      *
*                   individual fields can be addressed.                *
*  -->  DATA STRUCTURES    See form DATA_IMPORT INCLUDE RIPRID01       *
*----------------------------------------------------------------------*
*$*$ -   P  R  I  N   T       P  A  P  E  R
form print_paper.                      " This form name must be used !!!
*$*$ -  STARTED BY EXTERNAL PERFORM
  perform order_data_import.           " See INCLUDE RIPRIf02
  perform main_print.                  " Print the PAPER now

***** cideon integration ************************************
* Schreiben der Spool ID in ZCL_PSB_TMP oder ins Memory
* OBJECT_TYPE : SPOOL
* Counter normal gefüllt
*WA
  data: wa_default_data type /cideon/plot_defaultdata.
  data: wa_user_data type /cideon/plot_userdata.

* Verarbeitung erfolgt?
*  IF entries = 0.
*    EXIT.
*  ELSE.
*  ENDIF.

  if itcpp-tdspoolid is initial.
    exit.
  else.
  endif.

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

  wa_item-tdotftype = itcpp-tdotftype.
  wa_item-tdspoolid = itcpp-tdspoolid.

*   Druckinformationen
*  wa_item-drtxt = print_co-drtxt.
*
*  wa_item-psteu = print_co-psteu.
*  wa_item-samlt = print_co-samlt.
*  wa_item-pmode = print_co-pmode.
*  wa_item-drart = print_co-drart.
*  wa_item-ktext = print_co-ktext.
*  wa_item-selpr = print_co-selpr.
*  wa_item-tcode = print_co-tcode.

* Projektsystem Informationen
  wa_item-projn = caufvd-projn.

  wa_item-aufnr_cs = caufvd-aufnr.

  wa_item-verteiler = wa_user_data-default_verteiler_cs.

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

***** /CIDEON Integration ************************************

endform.

*$*$ MAIN PRINT SECTION CONTROLLED HERE................................
*... If you are making changes to Print ABAPS, (Naturally a copied
*... version) here is the place you can alter the logic and
*... and data supplied to the form.   You should not alter logic
*... before this point if you wish it to operate successfully
*... with the standard transactions. Form PRINT_PAPER must exist!!
*... However if you wish the PRINT LOG to work you must take
*... care to make sure the LOG records are written to PMPL.
*......................................................................
form main_print.
*... Print Time Ticket:Controlled at Operation level.
*... A seperate ticket is printed for each Operation.
*... The time ticket relvant flag in control Key from table T430
*... will be checked before print the paper.
*... The number of copies is control as follows.
*...
*... COPIES = No. of time tickets requested in order operation
*...        * NO. OF TIME_TICKET PAPERS from Paper selection screen
*...
  perform read_order_text_tables.      " Read tables for CAUFVD
  perform time_ticket.                 " print the tickets
endform.
*$*$   F O R M    R O U T I N E S -------------------------------------*
*...   Includes for General and Sepcific form routines
include riprif01.                      " General PRINT routines
include riprif02.                      " General PRINT routines ORDERS
*.......................................................................
*$*$ G E N E R A L     F O R M     R O U T I N E S ....................*
*----------------------------------------------------------------------*
*       FORM TIME_TICKET.                                              *
*----------------------------------------------------------------------*
*... Print tickets     Controlled at Operation level.
*... A seperate ticket is printed for each  AVO  but for only
*... OPERATIONS WITH A VALID CONTROL KEY.
*... The print log is controlled per operation
*... tickets are printed on the same form, except if a specific
*... new printer is found in the operation. Specific printer
*... destinations in operations come from the workcenter
*----------------------------------------------------------------------*
*  -->  Global imported tables.  See IMPORT in RIPRIF02                *
*----------------------------------------------------------------------*
form time_ticket.
  last_printer = '????'.          " Invalid start priner, force open
  form_open_flag = space.              " no form opened as yet
  perform set_title.                   " build title
*... loop on the operations
  iafvgd = space.
  loop at iafvgd where aufpl = caufvd-aufpl. "loop on operations
    afvgd = iafvgd.                    " Set workarea for SAPSCRIPT
    perform check_print_status using afvgd-objnr
                                     wworkpaper-pm_delta_p
                                     rc.
    check rc = 0.
*... individual Capacity split print
    if op_entries > 0.                 " single operation print active
      loop at op_print_tab where
              flg_sel = 'X'
         and  vornr   = afvgd-vornr    " was the operation selected
         and  uvorn   = afvgd-uvorn.   " for print ???
      endloop.
      check syst-subrc = 0.            " should this op be printed
    endif.
    perform read_op_text_tables.       "operation text tables
*... check that the operation should be printed based on the
*... control key.  IE timeticket valid operation
    check t430-lodr = yes.             " jump to next operation
    perform new_paper_test.            "open/close forms performed here
    perform lock_and_set               " Enque and determine copy number
            using c_operation.         " open for Operation level
    perform time_ticket_control.
    perform unlock_and_log.            " Dequeue and Log write (OPER)
  endloop.                             " loop on operations
  perform close_form.                  " Close the last opened form.
endform.
*
*... print a ticket for all capacity splits
*
form time_ticket_control.
  data: split_cnt type p.

  perform split_count using afvgd-bedid afvgd-bedzl split_cnt.
  loop at kbedp_tab where bedid = afvgd-bedid
                    and   bedzl = afvgd-bedzl.
    kbedp = kbedp_tab.
*... if the capacity load was split, then check that the main capacity
*... is not printed.
    if split_cnt > 0.
      check not kbedp-canumf is initial.
    endif.
    call function 'STATUS_TEXT_EDIT'
         exporting
              objnr            = kbedp-kbsta
              only_active      = 'X'
              spras            = print_language
         importing
              line             = bsvz-stext
         exceptions
              object_not_found = 01.
*... for each operation
    perform read_op_text_tables.       "operation text tables
*... test copies
    if afvgd-loanz is initial.         " how many time
      afvgd-loanz = 1.                 " tickets are requested
    endif.                             " By default always 1
    do afvgd-loanz times.
      perform sapscript_command using 'PROTECT'.
      perform title_block.
      call function 'WRITE_FORM'
           exporting
                element = 'SPLIT_NAME'
                window  = 'MAIN'.
      call function 'WRITE_FORM'
           exporting
                element = 'ORDER_HEADER_SHORT'
                window  = 'MAIN'.
      call function 'WRITE_FORM'
           exporting
                element = 'OPERATION_SHORT'
                window  = 'MAIN'.
      call function 'WRITE_FORM'       " single text element
           exporting                   " form with title
                element   = 'TIME_TICKET_END_SPLIT' " built in.
                window    = 'MAIN'.
      perform sapscript_command using 'ENDPROTECT'.
    enddo.
  endloop.                             "end of loop on capacities
endform.
