report riprgi00 .
************************************************************************
* Print Drive ABAP for Goods Issue                                     *
*                                                                      *
* Standard FORM is  PM_COMMON                                          *
*                                                                      *
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

***** CIDEON Integration ************************************
* Schreiben der Spool ID in ZCL_PSB_TMP oder ins Memory
* OBJECT_TYPE : SPOOL
* Counter normal gefüllt
*WA
  data: wa_default_data type /cideon/plot_defaultdata.
  data: wa_user_data type /cideon/plot_userdata.

* Verarbeitung erfolgt?
  if entries = 0.
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
*-> Workpaper is controlled at a MATERIAL LEVEL
*   For each material will one PMPL record saved!!!
*   This could need a lot of space if usally a lot of materials
*   related to the order. If you want to avoid saving of PRINT LOG
*   remove PERFORMs: lock_and_set and unlock_and_log
*<-
*... Only those Operations with valid print will have the materials
*... listed.
*... the whole idea is list materials here !! If we have none then
*... lets get out of here
  describe table iresbd lines entries.
  if entries > 0.                      " something to print ????
    perform set_title.
    perform read_order_text_tables.    " Read tables for CAUFVD
    perform material_list.             " list reserverd materials
  endif.
endform.
*$*$   F O R M    R O U T I N E S -------------------------------------*
*...   Includes for General and Sepcific form routines
include riprif01.                      " General PRINT routines
include riprif02.                      " General PRINT routines ORDERS
*.......................................................................
*$*$ G E N E R A L     F O R M     R O U T I N E S ....................*
*----------------------------------------------------------------------*
*       FORM MATERIAL_LIST.                                            *
*----------------------------------------------------------------------*
*... list materials.   CFontrolled at Operation level.
*... A seperate ticket is printed for each  material but for only
*... OPERATIONS WITH A VALID CONTROL KEY.
*... The print log is controlled per operation
*----------------------------------------------------------------------*
*  -->  Global imported tables.  See IMPORT in RIPRIF02                *
*----------------------------------------------------------------------*
form material_list.
  data: order_printed like sy-datar,
        oper_printed like sy-datar.

  clear order_printed.
*... loop on the operations
  loop at iafvgd where aufpl = caufvd-aufpl  "loop on operations
         and sumnr is initial.         " must be main OPeration
    afvgd = iafvgd.                    " Set workarea for SAPSCRIPT
    clear oper_printed.
*... individual opeation print check
    if op_entries > 0.                 " single operation print active
      loop at op_print_tab where
              flg_sel = 'X'
         and  vornr   = afvgd-vornr    " was the operation selected
         and  uvorn   = afvgd-uvorn.   " for print ???
      endloop.
      check syst-subrc = 0.            " should this op be printed
    endif.
*... check operation has materials
    read table iresbd with key aufpl = afvgd-aufpl.
    if syst-subrc = 0.                 " we have materials for operation
*... for each operation
      perform read_op_text_tables.     "operation text tables
*... check that the operation should be printed based on the
*... control key.
      check t430-vrgd = yes.           " jump to next operation
      loop at iresbd where vornr = afvgd-vornr.
*printed deleted materials with status DEL so user can see its deleted
        resbd = iresbd.
        perform check_print_status using resbd-objnr
                                         wworkpaper-pm_delta_p
                                         rc.
        check rc = 0.
*-> check not relevant to materials planning
*       check resbd-no_disp <> '1'.
*<- (activate for skipping)
        if order_printed is initial.
*-> first material, print paper header for order
* start of node 766146:
* PERFORM OPEN_FORM  USING C_ARC_TYPE_AUFK "Archive link for order
  perform open_form  using gv_arc_type_aufk  "Archive link for order
* end of node 766146
                                  caufvd-aufnr" order obj number as key
                                  ' '.      " New form for each Order
          perform lock_and_set          " Enque and determine copy n
                  using c_header_order. " open for Header level
          perform title_page.
          perform order_header_short.        " Brief order details
          order_printed = yes. " don't print it any more
        endif.
        if oper_printed is initial.
*-> first material for this operation, print operation header
          call function 'WRITE_FORM'       " Brief details
               exporting                   " about operation
                  element   = 'OPERATION_SHORT'
                  window    = 'MAIN'.
          oper_printed = yes. " don't print it any more for this oper.
        endif.
        call function 'WRITE_FORM'
             exporting
                  element = 'MATERIAL'
                  window  = 'MAIN'.
        perform print_mat_longtext.
      endloop.
    endif.                             " material found for operation
  endloop.                             " loop on operations
  if not order_printed is initial.
    perform end_of_report.
    perform close_form.                " Close the form.
    perform unlock_and_log.            " Dequeue and Log write (MAT)
  endif.
endform.
