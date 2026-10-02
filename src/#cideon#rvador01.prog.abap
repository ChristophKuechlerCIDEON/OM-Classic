*----------------------------------------------------------------------*
*              Print of an order confirmation by SAPscript
*----------------------------------------------------------------------*
report rvador01 line-count 100 message-id vn.

*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:

*-----------------------------------------------------------------------
* Journal
* 25.04.2007 - Erstellung / Kopie
* 27.04 2007 -
* 05.05.2007 - Problem mit Druckausgabe beseitigt.....
*-----------------------------------------------------------------------
* Übergaben an S-PSO
* Anpassung des
*   - Forms "FORM_CLOSE", um die Spool ID zu bekommen
*   - Forms "ENTRY", um die allgemeine Verarbeitung zu ermöglichen
*----------------------------------------------------------------------*
* Datenteil
*----------------------------------------------------------------------*
*ITAB
*WA
data: result type itcpp.
*NORMAL

*----------------------------------------------------------------------*



tables: komk,                          "Communicationarea for conditions
        komp,                          "Communicationarea for conditions
        komvd,                         "Communicationarea for conditions
        vbco3,                         "Communicationarea for view
        vbdka,                         "Headerview
        vbdpa,                         "Itemview
        vbdpau,                        "Subitemnumbers
        conf_out,                      "Configuration data
        sadr,                          "Addresses
        tvag,                          "Reason for rejection
        vedka,                         "Servicecontract head data
        vedpa,                         "Servicecontract position data
        vedkn,                         "Servicecontract head notice data
        vedpn,                         "Servicecontract pos. notice data
        riserls,                       "Serialnumbers
        komser,                        "Serialnumbers for print
        tvbur,                         "Sales office
        tvko,                          "Sales organisation
        adrs,                          "Communicationarea for Address
        fpltdr,                        "billing schedules
        wtad_addis_in_so_print,        "additional
        wtad_buying_print_extra_text.  "texts belonging to additional
include rvadtabl.
include rvdirekt.
include vedadata.

* data for access to central address maintenance
include sdzavdat.

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type-pools: addi.

data price_print_mode(1) type c.       "Print-mode
data: retcode   like sy-subrc.         "Returncode
data: repeat(1) type c.
data: xscreen(1) type c.               "Output on printer or screen
data: begin of steu,                   "Controldata for output
        vdkex(1) type c,
        vdpex(1) type c,
        kbkex(1) type c,
        kbpex(1) type c,
      end of steu.


data: begin of tvbdpa occurs 0.        "Internal table for items
        include structure vbdpa.
data: end of tvbdpa.

data: begin of tkomv occurs 50.
        include structure komv.
data: end of tkomv.

data: begin of tkomvd occurs 50.
        include structure komvd.
data: end of tkomvd.

data: begin of tvbdpau occurs 5.
        include structure vbdpau.
data: end   of tvbdpau.

data: begin of tkomcon occurs 50.
        include structure conf_out.
data: end   of tkomcon.

data: begin of tkomservh occurs 1.
        include structure vedka.
data: end   of tkomservh.

data: begin of tkomservp occurs 5.
        include structure vedpa.
data: end   of tkomservp.

data: begin of tkomservhn occurs 5.
        include structure vedkn.
data: end   of tkomservhn.

data: begin of tkomservpn occurs 5.
        include structure vedpn.
data: end   of tkomservpn.

data: begin of tkomser occurs 5.
        include structure riserls.
data: end   of tkomser.

data: begin of tkomser_print occurs 5.
        include structure komser.
data: end   of tkomser_print.

data: begin of tfpltdr occurs 5.
        include structure fpltdr.
data: end   of tfpltdr.

data: taddi_print type addi_so_print_itab with header line.

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

data: pr_kappl(01)   type c value 'V'. "Application for pricing

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

form entry using return_code us_screen.

  clear retcode.
  xscreen = us_screen.
  perform processing.
  if retcode ne 0.
    return_code = 1.
  else.
    return_code = 0.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form processing.

  perform get_data.
  check retcode = 0.
  perform form_open using xscreen vbdka-land1.
  check retcode = 0.
  perform form_title_print.
  check retcode = 0.
  perform validity_print.
  check retcode = 0.
  perform header_data_print.
  check retcode = 0.
  perform header_serv_print.
  check retcode = 0.
  perform header_notice_print.
  check retcode = 0.
  perform header_inter_print.
  check retcode = 0.
  perform header_text_print.
  check retcode = 0.
  perform item_print.
  check retcode = 0.
  perform end_print.
  check retcode = 0.
  perform form_close.
  check retcode = 0.


* allgemeine Verarbeitung
* Übergabe von Dokumenten
*  - Spool
*  - Dokumente zu Position
*  - Dokumente zum Material
*  - Dokumente zu Positionen der Materialstückliste


* Rücksicht auf die Druckansicht nehmen,
* dann keine Verarbeitung
  if
* bitte keine Prüfung auf TCODE...
*    sy-tcode = 'VA22'
*    or
    result-tdspoolid is initial.
    exit.
  else.
  endif.

  call function '/CIDEON/PLOT_VA_RVADOR01'
       exporting
            i_result = result
            i_vbdka  = vbdka
       tables
            lt_vbdpa = tvbdpa
       exceptions
            error    = 1
            others   = 2.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.



endform.

***********************************************************************
*       S U B R O U T I N E S                                         *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM ALTERNATIVE_ITEM                                         *
*---------------------------------------------------------------------*
*       A text is printed, if the item is an alternative item.        *
*---------------------------------------------------------------------*

form alternative_item.

  check vbdpa-grpos cn '0'.
  call function 'WRITE_FORM'
       exporting
            element = 'ALTERNATIVE_ITEM'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM CHECK_REPEAT                                             *
*---------------------------------------------------------------------*
*       A text is printed, if it is a repeat print for the document.  *
*---------------------------------------------------------------------*

form check_repeat.

  clear repeat.
  select * into *nast from nast where kappl = nast-kappl
                                and   objky = nast-objky
                                and   kschl = nast-kschl
                                and   spras = nast-spras
                                and   parnr = nast-parnr
                                and   parvw = nast-parvw
                                and   nacha between '1' and '4'.
    check *nast-vstat = '1'.
    repeat = 'X'.
    exit.
  endselect.

endform.

*---------------------------------------------------------------------*
*       FORM DELIVERY_DATE                                            *
*---------------------------------------------------------------------*
*       If the delivery date in the item is different to the header   *
*       date and there are no scheduled quantities, the delivery date *
*       is printed in the item block.                                 *
*---------------------------------------------------------------------*

form delivery_date.

  if vbdka-lfdat =  space and
     vbdpa-lfdat ne space and
     vbdpa-etenr_da = space.
    call function 'WRITE_FORM'
         exporting
              element = 'ITEM_DELIVERY_DATE'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM DIFFERENT_CONSIGNEE                                      *
*---------------------------------------------------------------------*
*       If the consignee in the item is different to the header con-  *
*       signee, it is printed by this routine.                        *
*---------------------------------------------------------------------*

form different_consignee.

  check vbdka-name1_we ne vbdpa-name1_we
    or  vbdka-name2_we ne vbdpa-name2_we
    or  vbdka-name3_we ne vbdpa-name3_we
    or  vbdka-name4_we ne vbdpa-name4_we
    or  vbdka-stras_we ne vbdpa-stras_we
    or  vbdka-pfach_we ne vbdpa-pfach_we
    or  vbdka-pstlz_we ne vbdpa-pstlz_we
    or  vbdka-pstl2_we ne vbdpa-pstl2_we
    or  vbdka-ort01_we ne vbdpa-ort01_we
    or  vbdka-pfort_we ne vbdpa-pfort_we
    or  vbdka-land1_we ne vbdpa-land1_we.
  check vbdpa-name1_we ne space
    or  vbdpa-name2_we ne space
    or  vbdpa-name3_we ne space
    or  vbdpa-name4_we ne space
    or  vbdpa-stras_we ne space
    or  vbdpa-pfach_we ne space
    or  vbdpa-pstlz_we ne space
    or  vbdpa-pstl2_we ne space
    or  vbdpa-ort01_we ne space
    or  vbdpa-pfort_we ne space
    or  vbdpa-land1_we ne space.
  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_CONSIGNEE'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM DIFFERENT_REFERENCE_NO                                   *
*---------------------------------------------------------------------*
*       If the reference number in the item is different to the header*
*       reference number, it is printed by this routine.              *
*---------------------------------------------------------------------*

form different_reference_no.

  check vbdpa-vbeln_vang ne vbdka-vbeln_vang
    or  vbdpa-vbtyp_vang ne vbdka-vbtyp_vang.
  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_REFERENCE_NO'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM DIFFERENT_TERMS                                          *
*---------------------------------------------------------------------*
*       If the terms in the item are different to the header terms,   *
*       they are printed by this routine.                             *
*---------------------------------------------------------------------*
form different_terms.

  data: us_vposn   like vedpa-vposn.
  data: us_text(1) type c.             "Flag for Noticetext was printed

  if vbdpa-zterm ne vbdka-zterm and
     vbdpa-zterm ne space.
    call function 'WRITE_FORM'
         exporting
              element = 'ITEM_TERMS_OF_PAYMENT'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.
  if vbdpa-inco1 ne space.
    if vbdpa-inco1 ne vbdka-inco1 or
       vbdpa-inco2 ne vbdka-inco2.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_TERMS_OF_DELIVERY'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    endif.
  endif.

* Print different validity-data for the position
  read table tkomservp with key vbdpa-posnr.
  if sy-subrc eq 0.
    vedpa = tkomservp.
    if vedpa-vbegdat ne space       and
       vedpa-venddat ne space       and
       not vedpa-vbegdat is initial and
       not vedpa-venddat is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_TERMS_OF_SERV1'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    elseif vedpa-vbegdat ne space and
           not vedpa-vbegdat is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_TERMS_OF_SERV2'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    else.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_TERMS_OF_SERV3'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    endif.
  endif.

* Notice-rules for the positions.
  move vbdpa-posnr to us_vposn.
  clear us_text.
  loop at tkomservpn where vposn = us_vposn.
    vedpn = tkomservpn.
    if us_text is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_TERMS_OF_NOTTXT'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
      us_text = charx.
    endif.
    call function 'WRITE_FORM'
         exporting
              element = 'ITEM_TERMS_OF_NOTICE'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endloop.
  if not us_text is initial.
    call function 'WRITE_FORM'
         exporting
              element = 'EMPTY_LINE'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM END_PRINT                                                *
*---------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*

form end_print.

  perform get_header_prices.

  call function 'CONTROL_FORM'
       exporting
            command = 'PROTECT'.

  perform header_price_print.

  if not price_print_mode eq chara.
* Pricing data init
    call function 'RV_PRICE_PRINT_GET_BUFFER'
         exporting
              i_init   = charx
         tables
              t_tkomv  = tkomv
              t_tkomvd = tkomvd.

  endif.

  call function 'WRITE_FORM'
       exporting
            element = 'END_VALUES'.
  call function 'CONTROL_FORM'
       exporting
            command = 'ENDPROTECT'.
  call function 'WRITE_FORM'
       exporting
            element = 'SUPPLEMENT_TEXT'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM FORM_CLOSE                                               *
*---------------------------------------------------------------------*
*       End of printing the form                                      *
*---------------------------------------------------------------------*

form form_close.

  data da_clear_vbeln(1) type c.

* bei Druckansicht im Anlegen gibt es noch keine Belegnummer - für die
* Anzeige temporäre Belegnummer übergeben und danach zurücknehmen, damit
* Folgeverarbeitung noch funktioniert
  if vbdka-vbeln is initial.
    da_clear_vbeln = charx.
    vbdka-vbeln = '$000000001'.
  endif.

  clear result.

  call function 'CLOSE_FORM'
       importing
            result = result
       exceptions
            others = 1.
  if sy-subrc ne 0.
    perform protocol_update.
    retcode = 1.
  endif.
  set country space.

  if da_clear_vbeln eq charx.
    clear vbdka-vbeln.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM FORM_OPEN                                                *
*---------------------------------------------------------------------*
*       Start of printing the form                                    *
*---------------------------------------------------------------------*
*  -->  US_SCREEN  Output on screen                                   *
*                  ' ' = printer                                      *
*                  'X' = screen                                       *
*  -->  US_COUNTRY County for telecommunication and SET COUNTRY       *
*---------------------------------------------------------------------*

form form_open using us_screen us_country.

* Send confirmation to user who send the document.
  if  nast-nacha eq '2'.
    nast-usnam = vbdka-ernam.
*  get fax country key
    if nast-teltx is initial and  nast-manue ne 'X'.
      perform get_fax_land using nast-tland.
    endif.
  endif.

  include rvadopfo.

endform.

*---------------------------------------------------------------------*
*       FORM FORM_TITLE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printing of the form title depending of the field VBTYP       *
*---------------------------------------------------------------------*

form form_title_print.

  case vbdka-vbtyp.
    when 'A'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_A'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
*      IF sy-subrc NE 0.
*        PERFORM protocol_update.
*      ENDIF.
    when 'B'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_B'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
*      IF sy-subrc NE 0.
*        PERFORM protocol_update.
*      ENDIF.
    when 'C'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_C'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    when 'E'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_E'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    when 'F'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_F'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    when 'G'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_F'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    when 'H'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_H'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    when 'K'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_K'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    when 'L'.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_L'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    when others.
      call function 'WRITE_FORM'
           exporting
                element = 'TITLE_OTHERS'
                window  = 'TITLE'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
  endcase.
  if repeat ne space.
    call function 'WRITE_FORM'
         exporting
              element = 'REPEAT'
              window  = 'REPEAT'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       General provision of data for the form                        *
*---------------------------------------------------------------------*

form get_data.

  data: us_veda_vbeln     like veda-vbeln.
  data: us_veda_posnr_low like veda-vposn.

  data: da_mess like vbfs occurs 0 with header line.

  call function 'RV_PRICE_PRINT_GET_MODE'
       importing
            e_print_mode = price_print_mode.

  if price_print_mode eq chara.
    call function 'RV_PRICE_PRINT_REFRESH'
         tables
              tkomv = tkomv.
  endif.

  clear komk.
  clear komp.

  vbco3-mandt = sy-mandt.
  vbco3-spras = nast-spras.
  vbco3-vbeln = nast-objky.
  vbco3-kunde = nast-parnr.
  vbco3-parvw = nast-parvw.

  call function 'RV_DOCUMENT_PRINT_VIEW'
       exporting
            comwa                       = vbco3
       importing
            kopf                        = vbdka
       tables
            pos                         = tvbdpa
            mess                        = da_mess
       exceptions
            fehler_bei_datenbeschaffung = 1.
  if sy-subrc ne 0.
    perform protocol_update.
    retcode = 1.
    exit.
  else.
    loop at da_mess.
      sy-msgid = da_mess-msgid.
      sy-msgno = da_mess-msgno.
      sy-msgty = da_mess-msgty.
      sy-msgv1 = da_mess-msgv1.
      sy-msgv2 = da_mess-msgv2.
      sy-msgv3 = da_mess-msgv3.
      sy-msgv4 = da_mess-msgv4.
      perform protocol_update.
    endloop.
  endif.

* fill address key --> necessary for emails
  addr_key-addrnumber = vbdka-adrnr.
  addr_key-persnumber = vbdka-adrnp.
  addr_key-addr_type  = vbdka-address_type.

* Fetch servicecontract-data and notice-data for head and position.
  us_veda_vbeln     = vbdka-vbeln.
  us_veda_posnr_low = posnr_low.
  call function 'SD_VEDA_GET_PRINT_DATA'
       exporting
            i_document_number = us_veda_vbeln
            i_language        = sy-langu
            i_posnr_low       = us_veda_posnr_low
       tables
            print_data_pos    = tkomservp
            print_data_head   = tkomservh
            print_notice_pos  = tkomservpn
            print_notice_head = tkomservhn.

  perform get_controll_data.

  perform sender.
  perform check_repeat.
  perform tvbdpau_create.

endform.

*---------------------------------------------------------------------*
*       FORM GET_ITEM_BILLING_SCHEDULES                               *
*---------------------------------------------------------------------*
*       In this routine the billing schedules are fetched from the    *
*       database.                                                     *
*---------------------------------------------------------------------*

form get_item_billing_schedules.

  refresh tfpltdr.
  check not vbdpa-fplnr is initial.

  call function 'BILLING_SCHED_PRINTVIEW_READ'
       exporting
            i_fplnr    = vbdpa-fplnr
            i_language = nast-spras
            i_vbeln    = vbdka-vbeln
       tables
            zfpltdr    = tfpltdr.

endform.

*&---------------------------------------------------------------------*
*&      Form  ITEM_BILLING_SCHEDULES_PRINT
*&---------------------------------------------------------------------*
*       This routine prints the billing shedules of a salesdocument    *
*       position.                                                      *
*----------------------------------------------------------------------*
form  item_billing_schedules_print.

  data: first_line(1) type c.

  first_line = charx.
  loop at tfpltdr.
    fpltdr = tfpltdr.
*   Output of the following printlines
    if not fpltdr-perio is initial.
*     periodische Fakturen
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_BILLING_SCHEDULE_PERIODIC'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
*     bei periodischen nur eine Zeile
      exit.
    elseif fpltdr-fareg ca '14'.
*     prozentuale Teilfakturierung
      if not first_line is initial.
        clear first_line.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_BILLING_SCHEDULE_PERCENT_HEADER'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      else.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_BILLING_SCHEDULE_PERCENT'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    elseif fpltdr-fareg ca '235'.
*     wertmäßige  Teilfakturierung
      if not first_line is initial.
        clear first_line.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_BILLING_SCHEDULE_VALUE_HEADER'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      else.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_BILLING_SCHEDULE_VALUE'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    elseif fpltdr-fareg ca '3'.
*     Schlußrechnung
    endif.
  endloop.
endform.
*eject

*&---------------------------------------------------------------------*
*&      FORM  GET_ITEM_ADDIS
*&---------------------------------------------------------------------*
*       Additionals data are fetched from database
*----------------------------------------------------------------------*
form get_item_addis.

  clear: taddi_print.

  call function 'WTAD_ADDIS_IN_SO_PRINT'
       exporting
            fi_vbeln              = vbdka-vbeln
            fi_posnr              = vbdpa-posnr
*           FI_LANGUAGE           = SY-LANGU
       tables
            fet_addis_in_so_print = taddi_print
       exceptions
            addis_not_active      = 1
            no_addis_for_so_item  = 2
            others                = 3.

endform.                               " GET_ITEM_ADDIS

*---------------------------------------------------------------------*
*       FORM GET_ITEM_CHARACTERISTICS                                 *
*---------------------------------------------------------------------*
*       In this routine the configuration data item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

form get_item_characteristics.

  data da_t_cabn like cabn occurs 10 with header line.
  data: begin of da_key,
          mandt like cabn-mandt,
          atinn like cabn-atinn,
        end   of da_key.

  refresh tkomcon.
  check not vbdpa-cuobj is initial and
            vbdpa-attyp ne var_typ.

  call function 'VC_I_GET_CONFIGURATION'
       exporting
            instance      = vbdpa-cuobj
            language      = nast-spras
            print_sales   = charx
       tables
            configuration = tkomcon
       exceptions
            others        = 4.

  ranges : da_in_cabn for da_t_cabn-atinn.
* Beschreibung der Merkmale wegen Objektmerkmalen auf sdcom-vkond holen
  clear da_in_cabn. refresh da_in_cabn.
  loop at tkomcon.
    da_in_cabn-option = 'EQ'.
    da_in_cabn-sign   = 'I'.
    da_in_cabn-low    = tkomcon-atinn.
    append da_in_cabn.
  endloop.

  clear da_t_cabn. refresh da_t_cabn.
  call function 'CLSE_SELECT_CABN'
*    EXPORTING
*         KEY_DATE                     = SY-DATUM
*         BYPASSING_BUFFER             = ' '
*         WITH_PREPARED_PATTERN        = ' '
*         I_AENNR                      = ' '
*    IMPORTING
*         AMBIGUOUS_OBJ_CHARACTERISTIC =
     tables
          in_cabn                      = da_in_cabn
          t_cabn                       = da_t_cabn
     exceptions
          no_entry_found               = 1
          others                       = 2.

* Preisfindungsmerkmale / Merkmale auf VCSD_UPDATE herausnehmen
  sort da_t_cabn.
  loop at tkomcon.
    da_key-mandt = sy-mandt.
    da_key-atinn = tkomcon-atinn.
    read table da_t_cabn with key da_key binary search.
    if sy-subrc <> 0 or
       ( ( da_t_cabn-attab = 'SDCOM' and
          da_t_cabn-atfel = 'VKOND'       ) or
        ( da_t_cabn-attab = 'VCSD_UPDATE' ) ) .
      delete tkomcon.
    endif.
  endloop.

endform.

*---------------------------------------------------------------------*
*       FORM GET_ITEM_PRICES                                          *
*---------------------------------------------------------------------*
*       In this routine the price data for the item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

form get_item_prices.

  clear: komp,
         tkomv.

  if komk-knumv ne vbdka-knumv or
     komk-knumv is initial.
    clear komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdka-kalsm.
    komk-kappl = pr_kappl.
    komk-waerk = vbdka-waerk.
    komk-knumv = vbdka-knumv.
    komk-knuma = vbdka-knuma.
    komk-vbtyp = vbdka-vbtyp.
    komk-land1 = vbdka-land1.
    komk-vkorg = vbdka-vkorg.
    komk-vtweg = vbdka-vtweg.
    komk-spart = vbdka-spart.
    komk-bukrs = vbdka-bukrs_vf.
    komk-hwaer = vbdka-waers.
    komk-prsdt = vbdka-erdat.
    komk-kurst = vbdka-kurst.
    komk-kurrf = vbdka-kurrf.
    komk-kurrf_dat = vbdka-kurrf_dat.
  endif.
  komp-kposn = vbdpa-posnr.
  komp-kursk = vbdpa-kursk.
  komp-kursk_dat = vbdpa-kursk_dat.
  if vbdka-vbtyp ca 'HKNOT6'.
    if vbdpa-shkzg ca ' A'.
      komp-shkzg = 'X'.
    endif.
  else.
    if vbdpa-shkzg ca 'BX'.
      komp-shkzg = 'X'.
    endif.
  endif.

  if price_print_mode eq chara.
    call function 'RV_PRICE_PRINT_ITEM'
         exporting
              comm_head_i = komk
              comm_item_i = komp
              language    = nast-spras
         importing
              comm_head_e = komk
              comm_item_e = komp
         tables
              tkomv       = tkomv
              tkomvd      = tkomvd.
  else.
    call function 'RV_PRICE_PRINT_ITEM_BUFFER'
         exporting
              comm_head_i = komk
              comm_item_i = komp
              language    = nast-spras
         importing
              comm_head_e = komk
              comm_item_e = komp
         tables
              tkomv       = tkomv
              tkomvd      = tkomvd.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM GET_HEADER_PRICES                                        *
*---------------------------------------------------------------------*
*       In this routine the price data for the header is fetched from *
*       the database.                                                 *
*---------------------------------------------------------------------*

form get_header_prices.

  loop at tvbdpa.

    call function 'SD_TAX_CODE_MAINTAIN'
         exporting
              key_knumv           = vbdka-knumv
              key_kposn           = tvbdpa-posnr
              i_application       = ' '
              i_pricing_procedure = vbdka-kalsm
         tables
              xkomv               = tkomv.


  endloop.

  if price_print_mode eq chara.
    call function 'RV_PRICE_PRINT_HEAD'
         exporting
              comm_head_i = komk
              language    = nast-spras
         importing
              comm_head_e = komk
         tables
              tkomv       = tkomv
              tkomvd      = tkomvd.
  else.
    call function 'RV_PRICE_PRINT_HEAD_BUFFER'
         exporting
              comm_head_i = komk
              language    = nast-spras
         importing
              comm_head_e = komk
         tables
              tkomv       = tkomv
              tkomvd      = tkomvd.
  endif.

endform.

*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA_PRINT
*&---------------------------------------------------------------------*
*       Printing of header data like terms, weights ....               *
*----------------------------------------------------------------------*

form header_data_print.

  call function 'WRITE_FORM'
       exporting
            element = 'HEADER_DATA'
       exceptions
            element = 1
            window  = 2.
*  IF sy-subrc NE 0.
*    PERFORM protocol_update.
*  ENDIF.

endform.                               " HEADER_DATA_PRINT

*---------------------------------------------------------------------*
*       FORM HEADER_PRICE_PRINT                                       *
*---------------------------------------------------------------------*
*       Printout of the header prices                                 *
*---------------------------------------------------------------------*

form header_price_print.

  loop at tkomvd.

    at first.
      if komk-supos ne 0.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_SUM'.
      else.
        call function 'WRITE_FORM'
             exporting
                  element = 'UNDER_LINE'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    endat.

    komvd = tkomvd.
    if komvd-koaid = 'D'.
      call function 'WRITE_FORM'
           exporting
                element = 'TAX_LINE'.
    else.
      if not komvd-kntyp eq 'f'.
        call function 'WRITE_FORM'
             exporting
                  element = 'SUM_LINE'.
      endif.
    endif.
  endloop.
  describe table tkomvd lines sy-tfill.
  if sy-tfill = 0.
    call function 'WRITE_FORM'
         exporting
              element = 'UNDER_LINE'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM HEADER_TEXT_PRINT                                        *
*---------------------------------------------------------------------*
*       Printout of the headertexts                                   *
*---------------------------------------------------------------------*

form header_text_print.

  call function 'WRITE_FORM'
       exporting
            element = 'HEADER_TEXT'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM ITEM_BILLING_CORRECTION_HEADER                          *
*---------------------------------------------------------------------*
*       In the case of a billing correction, the header of the item   *
*       debit memo / credit memo position, is printed by this routine *
*---------------------------------------------------------------------*

form item_billing_correction_header using us_ganf us_lanf.


  check vbdka-vbklt eq vbklt_rech_korr.

  if vbdka-vbtyp = vbtyp_ganf.
*   Gutschriftsanforderung
    if vbdpa-shkzg = charx.
      if us_ganf is initial.
        move charx to us_ganf.
        move space to us_lanf.

        call function 'WRITE_FORM'
             exporting
                  element = 'CORRECTION_TEXT_K'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    else.
      if us_lanf is initial.
        move charx to us_lanf.
        move space to us_ganf.

        call function 'WRITE_FORM'
             exporting
                  element = 'CORRECTION_TEXT_L'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    endif.
  endif.

  if vbdka-vbtyp = vbtyp_lanf.
*   Lastschriftssanforderung
    if vbdpa-shkzg = space.
      if us_lanf is initial.
        move charx to us_lanf.
        move space to us_ganf.

        call function 'WRITE_FORM'
             exporting
                  element = 'CORRECTION_TEXT_L'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    else.
      if us_ganf is initial.
        move charx to us_ganf.
        move space to us_lanf.

        call function 'WRITE_FORM'
             exporting
                  element = 'CORRECTION_TEXT_K'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*&      Form  ITEM_ADDIS_PRINT
*&---------------------------------------------------------------------*
*       Printout of item additionals
*----------------------------------------------------------------------*
form item_addis_print.

  loop at taddi_print.
    move-corresponding taddi_print to wtad_addis_in_so_print.
    call function 'WRITE_FORM'
         exporting
              element = 'ITEM_ADDI_SO_INFO'
         exceptions
              others  = 1.
    loop at taddi_print-addi_so_extra_text_info
            into wtad_buying_print_extra_text.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_ADDI_EXTRA_TEXT'
           exceptions
                others  = 1.
    endloop.
  endloop.

endform.                               " ITEM_ADDIS_PRINT
*---------------------------------------------------------------------*
*       FORM ITEM_CHARACERISTICS_PRINT                                *
*---------------------------------------------------------------------*
*       Printout of the item characteristics -> configuration         *
*---------------------------------------------------------------------*

form item_characteristics_print.

  loop at tkomcon.
    conf_out = tkomcon.
    if sy-tabix = 1.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_LINE_CONFIGURATION_HEADER'
           exceptions
                others  = 1.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    else.
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_LINE_CONFIGURATION'
           exceptions
                others  = 1.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    endif.
  endloop.

endform.

*---------------------------------------------------------------------*
*       FORM ITEM_DELIVERY_CONFIRMATION                               *
*---------------------------------------------------------------------*
*       If the delivery date is not confirmed, a text is printed      *
*---------------------------------------------------------------------*

form item_delivery_confirmation.

  check vbdka-vbtyp ne vbtyp_ganf and vbdka-vbtyp ne vbtyp_lanf.
  check vbdpa-lfdat = space.
  check vbdpa-kwmeng ne 0.
  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_DELIVERY_CONFIRMATION'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.
*---------------------------------------------------------------------*
*       FORM ITEM_AGREED_DELIVERY_TIME                                *
*---------------------------------------------------------------------*
*       If an agreed delivery time and the corresponding text is      *
*       available on item level, the text is printed                  *
*---------------------------------------------------------------------*

form item_agreed_delivery_time.

  check vbdka-vbtyp eq 'B' or vbdka-vbtyp eq 'G'.
  check vbdpa-delco ne space and vbdpa-delco_bez ne space.

  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_AGREED_DELIVERY_TIME'
       exceptions
            element = 1
            window  = 2.

  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM ITEM_PRICE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printout of the item prices                                   *
*---------------------------------------------------------------------*

form item_price_print.

  loop at tkomvd.
    komvd = tkomvd.
    if sy-tabix = 1 and
     ( komvd-koaid = charb or
       komvd-kschl = space ).
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_LINE_PRICE_QUANTITY'.
    else.
      if komvd-kntyp ne 'f'.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_LINE_PRICE_TEXT'.
      else.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_LINE_REBATE_IN_KIND'.
      endif.
    endif.
  endloop.

endform.

*---------------------------------------------------------------------*
*       FORM ITEM_PRINT                                               *
*---------------------------------------------------------------------*
*       Printout of the items                                         *
*---------------------------------------------------------------------*

form item_print.

  data: da_subrc like sy-subrc,
        da_dragr like tvag-dragr.
  data: da_ganf(1) type c,      "Print flag for billing correction
        da_lanf(1) type c.      "Print flag for billing correction

  call function 'WRITE_FORM'           "First header
       exporting  element = 'ITEM_HEADER'
       exceptions others  = 1.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.
  call function 'WRITE_FORM'           "Activate header
       exporting  element = 'ITEM_HEADER'
                  type    = 'TOP'
       exceptions others  = 1.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

  loop at tvbdpa.
    vbdpa = tvbdpa.

    if vbdpa-dragr eq space.           "Print rejected item?
      if vbdpa-posnr_neu ne space.     "Item
        perform item_billing_correction_header using da_ganf da_lanf.
        perform get_item_serials.
        perform get_item_characteristics.
        perform get_item_billing_schedules.
        perform get_item_prices.
        perform get_item_addis.
        call function 'CONTROL_FORM'
             exporting
                  command = 'ENDPROTECT'.
        call function 'CONTROL_FORM'
             exporting
                  command = 'PROTECT'.
        call function 'WRITE_FORM'
             exporting
                  element = 'ITEM_LINE'.
        perform item_rejected.
        perform item_price_print.
        call function 'CONTROL_FORM'
             exporting
                  command = 'ENDPROTECT'.
        perform item_text_print.
        perform item_serials_print.
        perform item_characteristics_print.
        perform item_addis_print.
        perform item_reference_billing.
        perform alternative_item.
        perform delivery_date.
        perform item_delivery_confirmation.
        perform item_agreed_delivery_time.
        perform item_billing_schedules_print.
        perform different_reference_no.
        perform different_terms.
        perform different_consignee.
        perform schedule_header.
        perform main_item.
      else.
        perform schedule_print.
      endif.
    endif.
  endloop.

  call function 'WRITE_FORM'           "Deactivate Header
       exporting  element  = 'ITEM_HEADER'
                  function = 'DELETE'
                  type     = 'TOP'
       exceptions others   = 1.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.
*---------------------------------------------------------------------*
*       FORM ITEM_REFERENCE_BILLING                                  *
*---------------------------------------------------------------------*
*       If the reference number of the billing is printed by this     *
*       routine. In case (debit memo / credit memo)                   *
*---------------------------------------------------------------------*

form item_reference_billing.

  check vbdka-vbklt eq vbklt_rech_korr.
  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_REFERENCE_BILLING'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.


*---------------------------------------------------------------------*
*       FORM ITEM_REJECTED                                            *
*---------------------------------------------------------------------*
*       A text is printed, if the item is rejected                    *
*---------------------------------------------------------------------*

form item_rejected.

  check not vbdpa-abgru is initial.
  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_REJECTED'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM MAIN_ITEM                                                *
*---------------------------------------------------------------------*
*       A text is printed, if the item is a main item                 *
*---------------------------------------------------------------------*

form main_item.

  loop at tvbdpau into vbdpau
                  where posnr eq vbdpa-posnr.
    if vbdpau-uposb is initial.
      call function 'WRITE_FORM'
           exporting
                element = 'ONE_SUBITEM'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    else.
      call function 'WRITE_FORM'
           exporting
                element = 'SEVERAL_SUBITEMS'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    endif.
  endloop.

endform.

*---------------------------------------------------------------------*
*       FORM ITEM_TEXT_PRINT                                          *
*---------------------------------------------------------------------*
*       Printout of the item texts                                    *
*---------------------------------------------------------------------*

form item_text_print.

  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_TEXT'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

form protocol_update.

  check xscreen = space.
  call function 'NAST_PROTOCOL_UPDATE'
       exporting
            msg_arbgb = syst-msgid
            msg_nr    = syst-msgno
            msg_ty    = syst-msgty
            msg_v1    = syst-msgv1
            msg_v2    = syst-msgv2
            msg_v3    = syst-msgv3
            msg_v4    = syst-msgv4
       exceptions
            others    = 1.

endform.

*---------------------------------------------------------------------*
*       FORM SCHEDULE_HEADER                                          *
*---------------------------------------------------------------------*
*       If there are schedules in the item, then here is printed the  *
*       header for the schedules.                                     *
*---------------------------------------------------------------------*

form schedule_header.

  check vbdpa-etenr_da ne space.
  call function 'CONTROL_FORM'
       exporting
            command = 'PROTECT'.
  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_SCHEDULE_HEADER'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM SCHEDULE_PRINT                                           *
*---------------------------------------------------------------------*
*       This routine prints the schedules for an item.                *
*---------------------------------------------------------------------*

form schedule_print.

  check vbdpa-lfrel eq 'X'.
  call function 'WRITE_FORM'
       exporting
            element = 'ITEM_SCHEDULE_PRINT'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM SENDER                                                   *
*---------------------------------------------------------------------*
*       This routine determines the address of the sender (Table VKO) *
*---------------------------------------------------------------------*

form sender.

  select single * from tvko  where vkorg = vbdka-vkorg.
  if sy-subrc ne 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'TVKO'.
    syst-msgv2 = syst-subrc.
    perform protocol_update.
    exit.
  endif.

  clear gv_fb_addr_get_selection.
  gv_fb_addr_get_selection-addrnumber = tvko-adrnr.         "SADR40A
  call function 'ADDR_GET'
       exporting
            address_selection = gv_fb_addr_get_selection
            address_group     = 'CA01'
       importing
            sadr              = sadr
       exceptions
            others            = 01.
  if sy-subrc ne 0.
    clear sadr.
  endif.                                                    "SADR40A
  vbdka-sland = sadr-land1.
  if sy-subrc ne 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'SADR'.
    syst-msgv2 = syst-subrc.
    perform protocol_update.
  endif.
*  SELECT SINGLE * FROM TVBUR  WHERE VKBUR = VBDKA-VKBUR.
*  IF SY-SUBRC NE 0.
*    SYST-MSGID = 'VN'.
*    SYST-MSGNO = '203'.
*    SYST-MSGTY = 'E'.
*    SYST-MSGV1 = 'TVBUR'.
*    SYST-MSGV2 = SYST-SUBRC.
*    PERFORM PROTOCOL_UPDATE.
*  ENDIF.

endform.

*---------------------------------------------------------------------*
*       FORM TVBDPAU_CREATE                                           *
*---------------------------------------------------------------------*
*       This routine is creating a table which includes the subitem-  *
*       numbers                                                       *
*---------------------------------------------------------------------*

form tvbdpau_create.

  clear tvbdpau.
  refresh tvbdpau.
  loop at tvbdpa.
    if tvbdpa-uepos is initial or
       tvbdpa-uepos ne tvbdpau-posnr.
* Append work area to internal table TVBDPAU
      if tvbdpau-uposv > 0.
        append tvbdpau.
        clear tvbdpau.
      endif.
* Start filling new work area
      tvbdpau-posnr = tvbdpa-posnr.

      if not tvbdpa-uepos is initial and
         tvbdpa-uepos ne tvbdpau-posnr.
        tvbdpau-posnr = tvbdpa-uepos.
        tvbdpau-uepvw = tvbdpa-uepvw.
        tvbdpau-uposv = tvbdpa-posnr.
      endif.

    else.
      if tvbdpau-uposv is initial or
         tvbdpau-uposv > tvbdpa-posnr.
        tvbdpau-uposv = tvbdpa-posnr.
      endif.
      if tvbdpau-uposb < tvbdpa-posnr and
         tvbdpau-uposv < tvbdpa-posnr.
        tvbdpau-uposb = tvbdpa-posnr.
      endif.
      tvbdpau-uepvw = tvbdpa-uepvw.    "UPOS-Verwendung
    endif.
  endloop.
  if tvbdpau-uposv > 0.
    append tvbdpau.
  endif.
  sort tvbdpau.

endform.

*---------------------------------------------------------------------*
*       FORM VALIDITY_PRINT                                           *
*---------------------------------------------------------------------*
*       This routine is printing the period of validity for offers    *
*       and contracts                                                 *
*---------------------------------------------------------------------*

form validity_print.

  check steu-vdkex eq space.
  case vbdka-vbtyp.
    when 'B'.
      if vbdka-angdt cn '0' or
         vbdka-bnddt cn '0'.
        call function 'WRITE_FORM'
             exporting
                  element = 'VALIDITY_OFFER'
                  window  = 'VALIDITY'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    when 'E'.
      if vbdka-guebg cn '0' or
         vbdka-gueen cn '0'.
        call function 'WRITE_FORM'
             exporting
                  element = 'VALIDITY_CONTRACT'
                  window  = 'VALIDITY'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    when 'F'.
      if vbdka-guebg cn '0' or
         vbdka-gueen cn '0'.
        call function 'WRITE_FORM'
             exporting
                  element = 'VALIDITY_CONTRACT'
                  window  = 'VALIDITY'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
    when 'G'.
      if vbdka-guebg cn '0' or
         vbdka-gueen cn '0'.
        call function 'WRITE_FORM'
             exporting
                  element = 'VALIDITY_CONTRACT'
                  window  = 'VALIDITY'
             exceptions
                  element = 1
                  window  = 2.
        if sy-subrc ne 0.
          perform protocol_update.
        endif.
      endif.
  endcase.

endform.

*&---------------------------------------------------------------------*
*&      Form  HEADER_NOTICE_PRINT
*&---------------------------------------------------------------------*
*       This routine prints the notice-rules of the contract-header.   *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form header_notice_print.

 data: us_text(1) type c.             "Kz. falls Text für Kündigungsbed.

* Kündigungsbedingungen auf Kopfebene.
  clear us_text.
  loop at tkomservhn.
    vedkn = tkomservhn.
    if us_text is initial.
*     For the first time a headertext is printed.
      call function 'WRITE_FORM'
           exporting
                element = 'HEADER_TERMS_OF_NOTTXT'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
      us_text = charx.
    endif.
    call function 'WRITE_FORM'
         exporting
              element = 'HEADER_TERMS_OF_NOTICE'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endloop.
* If notice-rules exists a empty line is printed.
  if not us_text is initial.
    call function 'WRITE_FORM'
         exporting
              element = 'EMPTY_LINE'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.

endform.                               " HEADER_NOTICE_PRINT
*eject

*&---------------------------------------------------------------------*
*&      Form  GET_ITEM_SERIALS
*&---------------------------------------------------------------------*
*       This routine give back the serialnumbers of salesdocument      *
*       position. The numbers are processed as print-lines in the      *
*       table KOMSER_PRINT.                                            *
*----------------------------------------------------------------------*
*  -->  US_VBELN  Salesdocument
*  -->  US_POSNR  Position of the salesdocument
*----------------------------------------------------------------------*
form get_item_serials.

  data: key_data like rserob,
        sernos like rserob occurs 0 with header line.

  key_data-taser = 'SER02'.
  key_data-sdaufnr = vbdka-vbeln.
  key_data-posnr = vbdpa-posnr.
  if key_data-sdaufnr is initial and not
     key_data-posnr is initial.
* beim Anlegen ist Belegnummer leer - deshalb Dummy-Belegnummer
    key_data-sdaufnr = char$.
  endif.

* Read the Serialnumbers of a Position.
  refresh: tkomser,
           tkomser_print.
  call function 'GET_SERNOS_OF_DOCUMENT'
       exporting
            key_data            = key_data
       tables
            sernos              = sernos
       exceptions
            key_parameter_error = 1
            no_supported_access = 2
            no_data_found       = 3
            others              = 4.
  if sy-subrc ne 0 and
     sy-subrc ne 3.
    perform protocol_update.
  endif.

  check sy-subrc eq 0.
* Serialnummern übergeben
  tkomser-vbeln = sernos-sdaufnr.
  tkomser-posnr = sernos-posnr.
  loop at sernos.
    tkomser-sernr = sernos-sernr.
    append tkomser.
  endloop.

* Process the stringtable for Printing.
  call function 'PROCESS_SERIALS_FOR_PRINT'
       exporting
            i_boundary_left             = '(_'
            i_boundary_right            = '_)'
            i_sep_char_strings          = ',_'
            i_sep_char_interval         = '_-_'
            i_use_interval              = 'X'
            i_boundary_method           = 'C'
            i_line_length               = 50
            i_no_zero                   = 'X'
            i_alphabet                  = sy-abcde
            i_digits                    = '0123456789'
            i_special_chars             = '-'
            i_with_second_digit         = ' '
       tables
            serials                     = tkomser
            serials_print               = tkomser_print
       exceptions
            boundary_missing            = 01
            interval_separation_missing = 02
            length_to_small             = 03
            internal_error              = 04
            wrong_method                = 05
            wrong_serial                = 06
            two_equal_serials           = 07
            serial_with_wrong_char      = 08
            serial_separation_missing   = 09.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.


endform.                               " GET_ITEM_SERIALS
*eject


*&---------------------------------------------------------------------*
*&      Form  ITEM_SERIALS_PRINT
*&---------------------------------------------------------------------*
*       This routine prints the serialnumbers of a salesdocument       *
*       position.                                                      *
*----------------------------------------------------------------------*
form item_serials_print.

  data: first_line(1) type c.

  first_line = charx.
  loop at tkomser_print.
    komser = tkomser_print.
    if not first_line is initial.
*     Output of the Headerline
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_LINE_SERIAL_HEADER'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
      clear first_line.
    else.
*     Output of the following printlines
      call function 'WRITE_FORM'
           exporting
                element = 'ITEM_LINE_SERIAL'
           exceptions
                element = 1
                window  = 2.
      if sy-subrc ne 0.
        perform protocol_update.
      endif.
    endif.
  endloop.
* If serialnumbers exists a empty line is printed.
  if first_line is initial.
    call function 'WRITE_FORM'
         exporting
              element = 'EMPTY_LINE'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.

endform.                               " ITEM_SERIALS_PRINT
*eject


*&---------------------------------------------------------------------*
*&      Form  HEADER_INTER_PRINT
*&---------------------------------------------------------------------*
*       Prints the message that if other condition for the positions   *
*       exists they are printed there.                                 *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form header_inter_print.

  check not steu-vdkex is initial.
  call function 'WRITE_FORM'
       exporting
            element = 'HEADER_TERMS_OF_TXTEND'
       exceptions
            element = 1
            window  = 2.
  if sy-subrc ne 0.
    perform protocol_update.
  endif.

endform.                               " HEADER_INTER_PRINT

*&---------------------------------------------------------------------*
*&      Form  GET_CONTROLL_DATA
*&---------------------------------------------------------------------*
*       Checks if servicedata for the header exists.                   *
*       Checks if servicedata for the position exists.                 *
*       Checks if noticedata for the header exists.                    *
*       Checks if noticedata for the position exists.                  *
*----------------------------------------------------------------------*
form get_controll_data.

  data: lines type i.

* Exists servicedata for the header?
  describe table tkomservh lines lines.
  if lines gt 0.
    steu-vdkex = 'X'.
  endif.

* Exists servicedata for the position?
  describe table tkomservp lines lines.
  if lines gt 0.
    steu-vdpex = 'X'.
  endif.

* Exists noticedata for the header?
  describe table tkomservhn lines lines.
  if lines gt 0.
    steu-kbkex = 'X'.
  endif.

* Exists noticedata for the position?
  describe table tkomservpn lines lines.
  if lines gt 0.
    steu-kbpex = 'X'.
  endif.

endform.                               " GET_CONTROLL_DATA
*eject


*&---------------------------------------------------------------------*
*&      Form  HEADER_SERV_PRINT
*&---------------------------------------------------------------------*
*       Output of the validity of a service-contract.                  *
*----------------------------------------------------------------------*
form header_serv_print.

  check not steu-vdkex is initial.
  read table tkomservh index 1.
  move tkomservh to vedka.

* Output of the validity.
  if not vedka-venddat is initial or
     vedka-venddat eq space.
    call function 'WRITE_FORM'
         exporting
              element = 'HEADER_TERMS_OF_SERV1'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  elseif vedka-vbegdat ne space and
         not vedka-vbegdat is initial.
    call function 'WRITE_FORM'
         exporting
              element = 'HEADER_TERMS_OF_SERV2'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  else.
    call function 'WRITE_FORM'
         exporting
              element = 'HEADER_TERMS_OF_SERV3'
         exceptions
              element = 1
              window  = 2.
    if sy-subrc ne 0.
      perform protocol_update.
    endif.
  endif.

endform.                               " HEADER_SERV_PRINT

*&---------------------------------------------------------------------*
*&      Form  get_fax_land
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAST_TLAND  text
*----------------------------------------------------------------------*
form get_fax_land using   p_nast_land like nast-tland.

  data  l_land    like nast-tland .
  clear l_land.


  if not addr_key-addrnumber is initial.
    call function 'WFMC_FAXNUMBER_FOR_ADDRESS'
         exporting
              adrnr          = addr_key-addrnumber
         importing
              tland          = l_land
         exceptions
              addr_not_exist = 1
              others         = 2.
    if sy-subrc = 0 and not l_land is initial.
      p_nast_land = l_land.
    endif.

  endif.
endform.                    " get_fax_land
