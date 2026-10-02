*&---------------------------------------------------------------------*
*& Report  ZCL_PRINT_FAUF_01_KEIN_START*
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 29.09.2003 - Erstellung
* 01.10.2003 - Einstellungen lesen
* 11.05.2004 - Druckinformationen
* 09.02.2007 - Integration Werksabhängigkeit der Verteiler
* 20.11.2008 - SP 86
*              lesen der Tabelle der Auftragsköpfe
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------

report  zcl_print_fauf_01 .

include ppcoincl.

* Schauen, ob das das richtige Include ist .....
include codrgt10.

*TYPES
*ITAB
data: itab_items_fauf type table of zcl_pdm_objects_fa_int.
*WA
data: wa_default_data type /cideon/plot_defaultdata.
data: wa_user_data type /cideon/plot_userdata.
data: wa_item_fauf type zcl_pdm_objects_fa_int.
*NORMAL



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




perform print_sub.


*---------------------------------------------------------------------*
*       FORM PRINT_SUB                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form print_sub.

* Document-tables
  include lcodrinc.

* eigene Druckroutinen hinhängen....
* Lesen in welchen Verteiler gedruckt werden soll ?
* Defaultkopien
* etc. am besten alles Lesen lassen.

  "Kopf lesen
  read table caufvd_tab index 1.


  loop at afdld_tab.
    clear wa_item_fauf.

    move-corresponding afdld_tab to wa_item_fauf.

* Testen, ob für Fertigungswerk ein Verteiler vorliegt
* sonst Verteiler des Nutzers benutzen
    data: wa_fauf_werk_ve type zcl_fauf_werk_ve.

    clear wa_fauf_werk_ve.
    select single * from zcl_fauf_werk_ve
      into wa_fauf_werk_ve
      where werks = print_co-werks
      .
    if sy-subrc ne 0.
      wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.
    else.
      wa_item_fauf-verteiler = wa_fauf_werk_ve-verteiler.
    endif.

    "wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.
    wa_item_fauf-folnr = afdld_tab-folnr.
    wa_item_fauf-vornr = afdld_tab-vornr.
    wa_item_fauf-aufnr_pp = afdld_tab-aufnr.

*   Druckinformationen
    wa_item_fauf-drtxt = print_co-drtxt.

    wa_item_fauf-psteu = print_co-psteu.
    wa_item_fauf-samlt = print_co-samlt.
    wa_item_fauf-pmode = print_co-pmode.
    wa_item_fauf-drart = print_co-drart.
    wa_item_fauf-ktext = print_co-ktext.
    wa_item_fauf-selpr = print_co-selpr.
    wa_item_fauf-tcode = print_co-tcode.

*   Projektsystem Informationen
    wa_item_fauf-projn = caufvd_tab-projn.
*   mglw. Nachlesen der ID
    if wa_item_fauf-projn is initial.
      data: wa_afpo type afpo.
      select single projn
        into wa_item_fauf-projn
        from afpo
        where aufnr = print_co-aufnr
        .
      if sy-subrc ne 0.
      else.
      endif.
    else.
    endif.


    append wa_item_fauf to itab_items_fauf.

  endloop.


* Aufruf des FBs
  if itab_items_fauf[] is initial.
  else.
    call function 'Z_CL_INT_WRITE_PLOT_PSB_NO_STR'
         exporting
              f_aut_process = wa_user_data-knz_auto_fauf
         tables
              i_itab_items  = itab_items_fauf
         exceptions
              error         = 1
              others        = 2.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
  endif.
endform.


*INCLUDE codrif01.          "PSFC-Form-Routinen: Druck-Parts lesen
*INCLUDE codrif02.          "PSFC-Form-Routinen: Open/Close Form
*INCLUDE codrif03.          "PSFC-Form-Routinen: print_prodnet_info
*INCLUDE codrif04.          "PSFC-Form-Routinen: read_mat
*INCLUDE codrif05.          "PSFC-Form-Routinen: print_activities
*INCLUDE codrif06.          "PSFC-Form-Routinen: print_prod_note
*INCLUDE codrif07.          "PSFC-Form-Routinen: print_ord_text
*INCLUDE codrif08.          "PSFC-Form-Routinen: print_configuration
*INCLUDE codrif09.          "PSFC-Form-Routinen: print_prt_to_opr
**                          "                    (+ Include CODRIF12)
*INCLUDE codrif10.          "PSFC-Form-Routinen: print_opr_text
*INCLUDE codrif14.          "PSFC-Form-Routinen: print_cmp_to_opr
**                          "                    (+ Include CODRIF13)
*INCLUDE codrif15.          "PSFC-Form-Routinen: get_components
*INCLUDE codrif16.          "PSFC-Form-Routinen: print_seq_header
**                          "                    (+ Include CODRIF11)
*INCLUDE codrif17.          "PSFC-Form-Routinen: std_init_operation
*INCLUDE codrif18.          "PSFC-Form-Routinen: print_routing_text




include codrgett.
