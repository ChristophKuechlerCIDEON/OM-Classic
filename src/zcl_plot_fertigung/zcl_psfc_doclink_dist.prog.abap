report psfc_doclink_dist.
* This report starts distribution orders for the documents that are
* linked to printable operations.
* The target plot system is hard coded at the moment.
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

* general declarations
include ppcoincl.

* internal tables holding objects
data caufvd_p_tab like sorted table of caufvd_p with unique key
                  aufnr                         with header line.
data afpod_p_tab  like sorted table of afpod_p with unique key
                  aufnr posnr                  with header line.
data affld_p_tab  like sorted table of affld_p with unique key
                  aufnr plnfl                  with header line.
data afvgd_p_tab  like sorted table of afvgd_p with unique key
                  aufnrd aplfl vornr           with header line.
data afdld_p_tab  like sorted table of afdld_p with unique key
                  aufnr folnr vornr dokar doknr dokvr doktl zaehl
                  with header line.
data rserob_tab like rserob occurs 0 with header line.

* information related to layout of form
* linesize of long texts
constants:  linesize_ord   type i value '70',
            linesize_item  type i value '50',
            linesize_rout  type i value '70',
            linesize_seq   type i value '70',
            linesize_opr   type i value '40',
            linesize_sopr  type i value '40',
            linesize_pnote type i value '70',
            linesize_prt   type i value '40',
            linesize_cmp   type i value '54'.
* Heigt of window main (number of lines)
data  lines_main(5) type n value 60.
* Space to be reserved for horizontal lines
data  n_space type p decimals 2 value '0.5'.
* first operation number used for header doc link assignment
data g_first_opr like afvgd-vornr.

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

wa_item-aufnr_pp = print_co-aufnr.

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


*----------------------------------------------------------------------
form print_sub.

  data: subrc like sy-subrc.
  data: l_aufpl_switch type c.
  data: l_ddi_id           like drzoi-ddi_id.
  data: ls_drzoi           like drzoi.
  data: l_draw_key         like cvdidrawkey.
  data: ls_document        like cviobjdata,
        lt_documents       like cviobjdata occurs 10 with header line,
        lt_characteristics like cls_charac occurs 10 with header line.
  data: l_amount(10) type c,
        l_startdate(12) type c,
        l_enddate(12) type c.

* fill data buffer in COPRINT
  perform import_data changing subrc.
  check subrc is initial.
* read list/printing info
  perform get_info_list.
* read order headers
  perform get_orders changing subrc.
  check subrc is initial.

*-process orders----------
  loop at caufvd_p_tab.
*   fill DDIC structure
    caufvd_p = caufvd_p_tab.
*   read order item
    perform get_item.
    read table afpod_p_tab index 1.
    afpod_p = afpod_p_tab.
*---loop over number of copies----------
    do print_co-copys times.
      if sy-index gt 1.
        move text-dup to print_co-drtxt.
      endif.
*   don't open and start form because we will start a distribution order
*   PERFORM open_form USING 'DOCLLST'.
*     read sequences
      perform get_seq.

*-----process sequences----------
      loop at affld_p_tab.
        affld_p = affld_p_tab.
*       read operation info
        perform get_opr.

* flag that new order is processed
        l_aufpl_switch = 'X'.
*-------process operations---------
        loop at afvgd_p_tab.
          afvgd_p = afvgd_p_tab.

*         read document link info
* Two strategies ares supported at the moment to handle document links
* that are not assigned to any operation but to the header. The strategy
* is controlled by the call to GET_DOCLINKS below.
* 1. The default: they are ignored, this is the following call
*          PERFORM get_doclinks USING space space.
* 2. Header doc links will be plotted together with the first operation
          perform get_doclinks using 'X' l_aufpl_switch.
          clear l_aufpl_switch.
*-----process document links----------
          loop at afdld_p_tab.
            afdld_p = afdld_p_tab.
* document to plot
            clear l_draw_key.
            clear ls_document.
            l_draw_key-doknr = afdld_p_tab-doknr.
            l_draw_key-dokar = afdld_p_tab-dokar.
            l_draw_key-doktl = afdld_p_tab-doktl.
            l_draw_key-dokvr = afdld_p_tab-dokvr.
            ls_document-objkey = l_draw_key.

* optional -> application
*            ls_document-application = 'TIF'.
            ls_document-num_copies  = 1.
            append ls_document to lt_documents.
          endloop.                     " afdld_p_tab
        endloop.
      endloop.

      if not lt_documents[] is initial.
* The usage of classifications requires that classes and
* characteristics are created. If this is done, the classification
* can be used according to the coding shown below.
* E.g. class ORDER with class type 170 has to be created before with
* charateristic ORDERNUMBER.
*         lt_characteristics-atnam = 'ORDERNUMBER'.
*         lt_characteristics-atwrt = '12345'.
*         APPEND lt_characteristics.
* The content of the following four fields will be printed on the
* header page of the distribution order
        write caufvd_p-gamng to l_amount.
        write caufvd_p-gstrp to l_startdate.
        write caufvd_p-gltrp to l_enddate.
        concatenate text-ord caufvd_p-aufnr
                    into ls_drzoi-descript1 separated by space.
        concatenate text-mat caufvd_p-matnr
                    text-qua l_amount
                    caufvd_p-gmein
                    into ls_drzoi-descript2 separated by space.
        concatenate text-osd l_startdate
                    text-oed l_enddate
                    into ls_drzoi-descript3 separated by space.

* start distribution order for plotting
        call function 'CVV1_PLOT_DOCUMENTS'
             exporting
* pass the next two parameters to use classification
*                 i_class                     = 'ORDER'
*                 i_classtype                 = '170'
                  i_printer                   = print_co-desti
*           I_CONTEXT                   =
*           I_STATUS                    = 'SY'
                  i_com_type                  = 'PLO'
                  i_drzoi                     = ls_drzoi
             importing
                  e_ddi_id                    = l_ddi_id
             tables
                  documents                   = lt_documents
                  characteristics             = lt_characteristics
             exceptions
                  printer_does_not_exist      = 1
                  error                       = 2
                  classification_update_error = 3
                  parameter_error             = 4
                  others                      = 5.

        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        else.
          message s055(25) with l_ddi_id.
        endif.
      endif.
*     don't close and end form because it wasn't opened
*     PERFORM close_form.
    enddo.                             "print_co-copys
  endloop.                             " caufvd_p_tab

endform.


*&---------------------------------------------------------------------*
*&      Form  IMPORT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form import_data changing subrc like sy-subrc.

  call function 'CO_PRINT_IMPORT_DATA'
       exceptions
            memory_id_ppt_not_exist = 1
            memory_id_ppi_not_exist = 2
            memory_id_pps_not_exist = 3
            others                  = 4.
  subrc = sy-subrc.


endform.                               " IMPORT_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_ORDERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_orders
     changing subrc   type sy-subrc.

  clear subrc.
  call function 'CO_PRINT_GET_ORD'
       exporting
            aufnr_imp        = print_co-aufnr
            flg_prtbl_opr    = on
            flg_prtbl_sop    = on
            flg_prtbl_cmp    = on
            flg_prtbl_prt    = on
       changing
            caufvd_p_tab_exp = caufvd_p_tab[]
       exceptions
            entry_not_found  = 1
            others           = 2.
  subrc = sy-subrc.

endform.                               " GET_ORDERS
*&---------------------------------------------------------------------*
*&      Form  GET_INFO_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_info_list.

  call function 'CO_PRINT_GET_INFO_LIST'
       importing
            print_co_exp   = print_co
            print_opts_exp = print_opts
       exceptions
            others         = 0.

* print-type
  case print_co-drart.
    when reprint.
      move text-dup to print_co-drtxt.
    when others.
      move text-org to print_co-drtxt.
  endcase.

endform.                               " GET_INFO_LIST
*&---------------------------------------------------------------------*
*&      Form  GET_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_item.

  call function 'CO_PRINT_GET_ITEM'
       exporting
            caufvd_p_imp    = caufvd_p
            posnr_imp       = '0001'
       changing
            afpod_p_tab_exp = afpod_p_tab[]
       exceptions
            entry_not_found = 1
            others          = 2.

endform.                               " GET_item
*&---------------------------------------------------------------------*
*&      Form  GET_DOCLINKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_doclinks using i_hdr_include
                        i_aufpl_switch.

  data: l_no_refresh type c value space.
* check whether header doc links should be assigned to first operation
  if not i_hdr_include is initial.
    if not i_aufpl_switch is initial.
      call function 'CO_PRINT_GET_FIRST_OPR'
           exporting
                i_aufpl   = afvgd_p-aufpl
           importing
                e_vornr   = g_first_opr
           exceptions
                not_found = 1.
    endif.
    if afvgd_p-vornr = g_first_opr.
      l_no_refresh = 'X'.
      call function 'CO_PRINT_GET_DOCL_ORD'
           exporting
                caufvd_p_imp     = caufvd_p
*           AFFLD_P_IMP      =
*           AFVGD_P_IMP      =
*           FLG_NO_REFRESH   =
*           FLG_CHK_CNTRLKEY = 'X'
           changing
                afdld_p_tab_exp  = afdld_p_tab[]
           exceptions
                entry_not_found  = 1
                too_many_params  = 2
                .
    endif.
  endif.
  call function 'CO_PRINT_GET_DOCL_OPR'
       exporting
*            caufvd_p_imp     = caufvd_p
            afvgd_p_imp      = afvgd_p
            flg_no_refresh   = l_no_refresh
*           FLG_CHK_CNTRLKEY = 'X'
       changing
            afdld_p_tab_exp  = afdld_p_tab[]
       exceptions
            entry_not_found  = 1
            too_many_params  = 2
            others           = 3
            .

endform.                               " GET_DOCLINKS

*&---------------------------------------------------------------------*
*&      Form  GET_SEQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_seq.

  call function 'CO_PRINT_GET_SEQ'
       exporting
            caufvd_p_imp    =  caufvd_p
*           AFVGD_P_IMP     =
*           RESBD_P_IMP     =
*           AFFHD_P_IMP     =
*           FLG_NO_REFRESH  =
            flg_prtbl_opr   = on
            flg_prtbl_sop   = on
            flg_prtbl_cmp   = on
            flg_prtbl_prt   = on
       changing
            affld_p_tab_exp =  affld_p_tab[]
       exceptions
            entry_not_found = 1
            too_many_params = 2
            others          = 3.

endform.                               " GET_SEQ

*&---------------------------------------------------------------------*
*&      Form  GET_OPR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_opr.

  call function 'CO_PRINT_GET_OPR'
        exporting
*            CAUFVD_P_IMP    =
             affld_p_imp     = affld_p
*            SAFVGD_P_IMP    =
*            RESBD_P_IMP     =
*            AFFHD_P_IMP     =
*            FLG_NO_REFRESH  =
             flg_chk_ctrlkey = print_co-psteu
*            FLG_PRTBL_SOP   =
*            FLG_PRTBL_CMP   =
*            FLG_PRTBL_PRT   =
        changing
             afvgd_p_tab_exp = afvgd_p_tab[]
        exceptions
             entry_not_found = 1
             too_many_params = 2
             others          = 3.

endform.                               " GET_OPR
