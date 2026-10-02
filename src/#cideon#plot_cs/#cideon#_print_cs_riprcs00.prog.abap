report riprcs00.
************************************************************************
* Print Drive ABAP for Confirmation Sheet                              *
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
*...     !                                                             *
*...     !-- AFVGD       (AFVC AFVV plus dialog fields) Order operatns *
*...     !   !                                                         *
*...     !   !-- The sub operations also stored AFVGD and are pre      *
*...     !       sorted. The SUMNR fields distinguishes Main operaitons*
*...     !       and sub operations                                    *
*...     !                                                             *
*...     !-- RESBD                 Materials                           *
*...     !-- RIPW0                 Object list dialog area             *
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

***** CIDEON integration ************************************
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
  perform read_order_text_tables.      " Read tables for CAUFVD
  perform confirmation_slips.          " print the tickets
endform.
*$*$   F O R M    R O U T I N E S -------------------------------------*
*...   Includes for General and Sepcific form routines
include riprif01.                      " General PRINT routines
include riprif02.                      " General PRINT routines ORDERS
*.......................................................................
*$*$ G E N E R A L     F O R M     R O U T I N E S ....................*
*----------------------------------------------------------------------*
*       FORM CONFIRMATION_SLIPS                                        *
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
form confirmation_slips.
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
*... individual opeation print check
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
*... control key.  IE Confirmation SLIP  should be printed or not
    check t430-rudr = yes.             " Print conf Slip flag on ???
    perform new_paper_test.
    perform lock_and_set               " Enque and determine copy number
            using c_operation.         " open for Operation level
*::::::CONFIRMATION SLIP IS ONLY PRINTED ONCE , :::::::::::::::::::::::*
*::::::FOR MULTIPLE COPIES USE CODE BELOW::::::::::::::::::::::::::::::*
*::::   IF AFVGD-LOANZ IS INITIAL.     " how many time
*:::       AFVGD-LOANZ = 1.            " tickets are requested
*:::    ENDIF.                         " By default always 1
*:::    DO AFVGD-LOANZ TIMES.          " CONFIRMATION SLIP ONLY ONCE
    perform sapscript_command using 'PROTECT'.
    perform title_block.
    call function 'WRITE_FORM'
         exporting
              element = 'ORDER_HEADER_SHORT'
              window  = 'MAIN'.
    call function 'WRITE_FORM'
         exporting
              element = 'OPERATION_SHORT'
              window  = 'MAIN'.
    call function 'WRITE_FORM'         " single text element
         exporting                     " form with title
              element   = 'CONFIRM_END'" built in.
              window    = 'MAIN'.
    perform sapscript_command using 'ENDPROTECT'.
*:::    ENDDO.
    perform unlock_and_log.            " Dequeue and Log write (OPER)
  endloop.                             " loop on operations
  perform close_form.                  " Close the last open form.
endform.
