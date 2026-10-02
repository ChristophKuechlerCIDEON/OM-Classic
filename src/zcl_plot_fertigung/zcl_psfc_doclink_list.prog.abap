report psfc_doclink_list.
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


*----------------------------------------------------------------------
form print_sub.

  data: subrc like sy-subrc.

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
*   read serial number
    perform get_info_serob.

*---loop over number of copies----------
    do print_co-copys times.
      if sy-index gt 1.
        move text-dup to print_co-drtxt.
      endif.
*     open and start form
      perform open_form using 'DOCLLST'.
*     print info of order header
*      PERFORM PRINT_ORDER.
*     read document links
      perform get_doclinks.

*-----process document links----------
      loop at afdld_p_tab.
        afdld_p = afdld_p_tab.
*       print sequence header
        perform print_doclink.

*-------process operations---------

      endloop.   " afdld_p_tab

*     close and end form
      perform close_form.

    enddo.   "print_co-copys

  endloop.   " caufvd_p_tab

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


endform.                    " IMPORT_DATA

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

endform.                    " GET_ORDERS
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

endform.                    " GET_INFO_LIST
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

endform.                    " GET_item
*&---------------------------------------------------------------------*
*&      Form  GET_DOCLINKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_doclinks.

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
            others           = 3
            .
  call function 'CO_PRINT_GET_DOCL_OPR'
       exporting
            caufvd_p_imp     = caufvd_p
*           AFVGD_P_IMP      =
            flg_no_refresh   = 'X'
*           FLG_CHK_CNTRLKEY = 'X'
       changing
            afdld_p_tab_exp  = afdld_p_tab[]
       exceptions
            entry_not_found  = 1
            too_many_params  = 2
            others           = 3
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " GET_DOCLINKS

*&---------------------------------------------------------------------*
*&      Form  PRINT_DOCLINK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form print_doclink.

  data  ltxt_lines like tline occurs 0 with header line.

* check if there is enough space
  lines_left = lines_main - last_line.
  if last_line > 1.                   " not at top of the page!
    call function 'WRITE_FORM'
         exporting
              element = 'EMPTY_LINE'
              window  = 'MAIN'.
    add 1 to last_line.
  endif.
  perform position_frame changing psfc_frame.
  call function 'WRITE_FORM'
       exporting
            element = 'DATA_DOCL'
            window  = 'MAIN'.
  call function 'WRITE_FORM'
       exporting
            element = 'FRAME_SPACE'
            window  = 'MAIN'.
  add lines_printed to last_line.

endform.                    " PRINT_SEQUENCE
*&---------------------------------------------------------------------*
*&      Form  OPEN_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0175   text                                                *
*----------------------------------------------------------------------*
form open_form using startpage.

  call function 'OPEN_FORM'
       exporting
            device   = 'PRINTER'
            dialog   = space
            form     = print_co-forml
            language = print_co-spras
            options  = print_opts
       exceptions
            canceled = 01
            device   = 02
            form     = 03
            options  = 04
            unclosed = 05.
  call function 'START_FORM'
       exporting
            startpage = startpage.

* reset counter for page numbers
  print_co-actpage = 1.

endform.                    " OPEN_FORM
*&---------------------------------------------------------------------*
*&      Form  CLOSE_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form close_form.

* close actual page with a horizontal line
  perform position_frame changing psfc_frame.
  call function 'WRITE_FORM'
       exporting
            element = 'HORIZ_LINE'
            window  = 'MAIN'.
* close form
  call function 'END_FORM'.
  call function 'CLOSE_FORM'
       importing
            result = pr_result
       exceptions
            others = 01.

endform.                    " CLOSE_FORM
*&---------------------------------------------------------------------*
*&      Form  GET_INFO_SEROB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_info_serob.

  call function 'CO_PRINT_GET_INFO_SEROB'
       exporting
*           CAUFVD_P_IMP      =
            afpod_p_imp       = afpod_p
       changing
            rserob_tab_exp    = rserob_tab[]
       exceptions
            entry_not_found   = 1
            imp_param_missing = 2
            too_many_params   = 3
            others            = 4.

endform.                    " GET_INFO_SEROB

*&---------------------------------------------------------------------*
*&      Form  POSITION_FRAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PSFC_FRAME  text                                           *
*----------------------------------------------------------------------*
form position_frame changing p_psfc_frame like psfc_frame.

  data line like last_line.

* frame position
  clear psfc_frame-pos.
  line = last_line.       " - n_space * '0.25' .
  if line < 0.
    p_psfc_frame-pos(1) = '-'.
  else.
    p_psfc_frame-pos(1) = '+'.
  endif.
  line = abs( line ).
  write line to p_psfc_frame-pos+1(8).
  translate p_psfc_frame-pos using ' 0'.
  translate p_psfc_frame-pos using ',.'.
* frame height
  write lines_printed to p_psfc_frame-height+1(6).
  translate p_psfc_frame-height using ',.'.

endform.                    " POSITION_FRAME
*&---------------------------------------------------------------------*
*&      Form  NEW_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form new_page.

* extend vertical lines of last frame if necessary.
  perform extend_vert_lines.

* close actual page with a horizontal line
  perform position_frame changing psfc_frame.
  call function 'WRITE_FORM'
       exporting
            element = 'HORIZ_LINE'
            window  = 'MAIN'.
* new page
  clear last_line.
  call function 'CONTROL_FORM'
       exporting
            command = 'NEW-PAGE'.
* increase counter for page numbers
  add 1 to print_co-actpage.
* space
  call function 'WRITE_FORM'
       exporting
            element = 'EMPTY_LINE'
            window  = 'MAIN'.
  add 1 to last_line.

endform.                    " NEW_PAGE
*&---------------------------------------------------------------------*
*&      Form  HORIZ_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form horiz_line.

  perform position_frame changing psfc_frame.
  call function 'WRITE_FORM'
       exporting
            element = 'HORIZ_LINE'
            window  = 'MAIN'.

endform.                    " HORIZ_LINE
*&---------------------------------------------------------------------*
*&      Form  PRINT_BARCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form print_barcode.

  move 6 to lines_printed. add n_space to lines_printed.
  perform position_frame changing psfc_frame.
  call function 'WRITE_FORM'
       exporting
            element = 'TITLE_BC'
            window  = 'MAIN'.
  call function 'WRITE_FORM'
       exporting
            element = 'DATA_BC'
            window  = 'MAIN'.
  call function 'WRITE_FORM'
       exporting
            element = 'FRAME_SPACE'
            window  = 'MAIN'.
  add lines_printed to last_line.

endform.                    " PRINT_BARCODE
*&---------------------------------------------------------------------*
*&      Form  EXTEND_VERT_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form extend_vert_lines.

* Sorry, this is not nice and not easy to understand but
* necessary to avoid that the closing horizontal line
* cuts through the last text line when the new-page occurs
* in the middle of a list of components, production resources
* or sub-operations.

  case last_object_printed.
    when obj-sop.                       "sub-operation
      move n_space to lines_printed.
      perform position_frame changing psfc_frame.
      call function 'WRITE_FORM'
           exporting
                element = 'FRAME_SOP'
                window  = 'MAIN'.
      add lines_printed to last_line.
    when obj-mat.                       "material component
      move n_space to lines_printed.
      perform position_frame changing psfc_frame.
      call function 'WRITE_FORM'
           exporting
                element = 'FRAME_CMP'
                window  = 'MAIN'.
      add lines_printed to last_line.
    when obj-fhm.                       "production resource
      move n_space to lines_printed.
      perform position_frame changing psfc_frame.
      call function 'WRITE_FORM'
           exporting
                element = 'FRAME_PRT'
                window  = 'MAIN'.
      add lines_printed to last_line.
    when others.
  endcase.

  clear last_object_printed.

endform.                    " EXTEND_VERT_LINES
