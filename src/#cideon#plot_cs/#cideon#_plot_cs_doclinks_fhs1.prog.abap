*&---------------------------------------------------------------------*
*& Report  /CIDEON/_PRINT_CS_DOC_LINKS                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*  Serviceauftragsdruck Plot Dokumente zum FHM Stammsatz
*-----------------------------------------------------------------------
* Author :  Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*           25.08.2004
*-----------------------------------------------------------------------
* Journal
*
*-----------------------------------------------------------------------

report  /cideon/_print_cs_doc_links .

************************************************************************
* Print Drive ABAP for CONTROL TICKET                                  *
*                                                                      *
* Standard FORM is  PM_COMMOM                                          *
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
data:  lt_drad type table of drad with header line,
       gf_nodrad.

*------------------*
start-of-selection.
*------------------*
 perform print_paper.  "can be started via SUBMIT or PERFORM PRINT_PAPER

*$*$ ................ M A I N     F O R M .............................*
*... DATA STRUCTURE: ..................................................*
*...                                                                   *
*...    CAUFVD (AFIH AUFK AFKO plus other dialog fields: ORDER HEADER) *
*...     |                                                             *
*...     |-- AFVGD       (AFVC AFVV plus dialog fields) Order operatns *
*...     |   |                                                         *
*...     |   |-- The sub operations also stored AFVGD and are pre      *
*...     |       sorted. The SUMNR fields distinguishes Main operaitons*
*...     |       and sub operations                                    *
*...     |                                                             *
*...     |-- RESBD                 Materials                           *
*...     |-- RIPW0                 Object list dialog area
*             ------VIQMEL         First Notification from Object list
*...     |-- IHPAD                 Partners to Orders                  *
*...
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
form print_paper.                      " This form name must be used !!
*$*$ -  STARTED BY EXTERNAL PERFORM

*  break schulte.
  perform order_data_import.           " See INCLUDE RIPRIf02
  perform read_fh_doc_links.              " Read document links

  if gf_nodrad is initial.

***** CIDEON Integration ************************************
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

    loop at lt_drad.

      move-corresponding lt_drad to wa_item.
      wa_item-tdotftype = itcpp-tdotftype.
      wa_item-tdspoolid = itcpp-tdspoolid.


* Projektsystem Informationen
      wa_item-projn = caufvd-projn.
*   mglw. Nachlesen der ID
      if wa_item-projn is initial.
        data: wa_afpo type afpo.
        select single projn
          into wa_item-projn
          from afpo
          where aufnr = caufvd-aufnr
          .
        if sy-subrc ne 0.
        else.
        endif.
      else.
      endif.

      wa_item-aufnr_cs = caufvd-aufnr.
      wa_item-verteiler = wa_user_data-default_verteiler_cs.

      append wa_item to itab_item.
    endloop.

* Aufruf des FBs
    if itab_item is initial.
    else.
      call function 'Z_CL_INT_WRITE_PLOT_PSB_NO_STR'
           exporting
                f_aut_process = wa_user_data-knz_auto_cs
           tables
                i_itab_items  = itab_item
           exceptions
                error         = 1
                others        = 2.
      if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      else.
      endif.
    endif.

  else.
    export gf_nodrad to memory id 'NODRAD'.
  endif.

***** /CIDEON Integration ************************************

endform.
*$*$   F O R M    R O U T I N E S -------------------------------------*
*...   Includes for General and Sepcific form routines
include riprif01.                      " General PRINT routines
include riprif02.                      " General PRINT routines ORDERS
*.......................................................................
*$*$ G E N E R A L     F O R M     R O U T I N E S ....................
*ENDFORM.                    " EXTEND_VERT_LINES

*&---------------------------------------------------------------------*
*&      Form  read_fh_doc_links
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_fh_doc_links.

  data:  lf_key type drad-objky,
         lf_objekt type drad-dokob,
         lt_drad_temp type table of drad,
         ls_drad_temp type drad.

  if not iaffhd[] is initial.
      clear lt_drad.
      loop at iaffhd.
        check iaffhd-fhmar = 'S'.  " Fertigungshilfsmittelverknüpfung !
        lf_key = iaffhd-fhmnr.
        lf_objekt = 'CRVS_B'.

        clear gf_nodrad.
        call function 'DOKUMENTE_ZU_OBJEKT'
          exporting
            key                       = lf_key
            objekt                    = lf_objekt
*   MANDT                     = SY-MANDT
*   CHECK_BUFFER_AND_DB       = ' '
         tables
           doktab                    = lt_drad_temp
         exceptions
           kein_dokument             = 1
           others                    = 2
                  .

        if sy-subrc = 0.
          loop at lt_drad_temp into ls_drad_temp.
            append ls_drad_temp to lt_drad.
          endloop.
        endif.
      endloop.
    endif.

  if lt_drad[] is initial.
    gf_nodrad = 'X'.
  else.
    clear gf_nodrad .
  endif.

endform.                    " read_doc_links
