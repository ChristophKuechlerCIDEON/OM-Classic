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
* 06.09.2005 - Kopie
*              Anpassungen auf Karl Mayer Konventionen
*-----------------------------------------------------------------------
* Vorgehen:
* Fertigungsauftrag -> Material -> verknüpfte Dokumente
* falls innerhalb der Dokumente das Merkmal "DVS_SHWS" mit "JA"
* belegt ist, dann soll die Dokumentenstückliste zu diesem DIS
* einstufig aufgelöst werden und die gefundenen Dokumente auch zur
* Ausgabe benutzt werden
*
* scheinbar werden kein Dokumentenverknüpfungen zum Fertigungsauftrag
* benutzt, deshalb die Auflösung über das Material fahren....
*-----------------------------------------------------------------------
* to do
*
*-----------------------------------------------------------------------


report  zcl_print_fauf_01 .

include ppcoincl.

* Schauen, ob das das richtige Include ist .....
include codrgt10.

*TYPES
*ITAB
data: itab_items_fauf type table of zcl_pdm_objects_fa_int.
data: itab_char type table of bapi_characteristic_values.
data: itab_draw_result type table of draw.
data: itab_draw_tmp type table of draw.
data: itab_draw type table of draw.
data: itab_drad type table of drad.
data: itab_structure type table of bapi_doc_structure.
*WA
data: wa_default_data type /cideon/plot_defaultdata.
data: wa_user_data type /cideon/plot_userdata.
data: wa_item_fauf type zcl_pdm_objects_fa_int.
data: wa_afpo type afpo.
data: return type bapiret2.
data: wa_char type bapi_characteristic_values.
data: wa_caufvd type caufvd.
data: wa_draw type draw.
data: wa_drad type drad.
data: wa_structure type bapi_doc_structure.
*NORMAL
data: objky type drad-objky.
data: f_found.



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

* Tabellen
*         CAUFVD_TAB "headers
*         AFPOD_TAB  "positions
*         AFFLD_TAB  "sequences
*         AFVGD_TAB  "operations/suboperations
*         RESBD_TAB  "components
*         AFFHD_TAB  "PRTs
*         WORK_TAB   "workcenters sorted by arbid werks
*         MV_TAB     "material view sorted by matnr werks
*         CHARAC_TAB "configuration sorted by cuobj
*         COBL
*         KBEDP_TAB  "capacity request sorted by bedid bedzl
*         COLORD_TAB "collective order info sorted by aufnr
*         TTL_TAB    "activities sorted by aufpl aplzl
*         SEROB_TAB  "serialnumbers sorted by ppaufnr ppposnr sernr
*         AFDLD_TAB  "document links

  clear wa_caufvd.
  clear itab_draw.
  clear itab_drad.

  loop at caufvd_tab into wa_caufvd.
* Auflösungen über das Material fahren
    clear wa_item_fauf.

*   Material und verknüpfte Dokumente holen
    if wa_caufvd-matnr is initial.
    else.
*     Links holen
      clear objky.
      objky = wa_caufvd-matnr.
      call function 'CV200_GET_DRAD_LINK'
        exporting
          key                 = objky
          objekt              = 'MARA'
*       MANDT               = SY-MANDT
        tables
          doktab              = itab_drad
*       INTDRAD_TAB         =
        exceptions
          kein_dokument       = 1
          others              = 2
                .
      if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      else.
        clear wa_drad.
        clear wa_draw.
        loop at itab_drad into wa_drad.
          move-corresponding wa_drad to wa_draw.
          append wa_draw to itab_draw.
        endloop.
      endif.

    endif.

* Schweißbaugruppen behandeln
* Merkmal "DVS_SHWS"
    clear itab_draw_result.
    clear itab_draw_tmp.
    loop at itab_draw into wa_draw.
      append wa_draw to itab_draw_result.
      clear return.
      clear itab_char.
      clear wa_char.
      call function 'BAPI_DOCUMENT_GETDETAIL2'
        exporting
          documenttype               = wa_draw-dokar
          documentnumber             = wa_draw-doknr
          documentpart               = wa_draw-doktl
          documentversion            = wa_draw-dokvr
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
*       GETACTIVEFILES             = ''
*       GETDOCDESCRIPTIONS         = ''
*       GETDOCFILES                = ''
          getclassification          = 'X'
*       GETSTRUCTURE               = ' '
*       GETWHEREUSED               = ' '
*       HOSTNAME                   = ' '
        importing
*       DOCUMENTDATA               =
          return                     = return
        tables
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
*       DOCUMENTFILES              =
*       COMPONENTS                 =
          characteristicvalues       = itab_char
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
*       WHEREUSEDLIST              =
                .
      if return is initial.
      else.
        continue.
      endif.

      clear f_found.
      loop at itab_char into wa_char.
        if wa_char-charname = 'DVS_SHWS'
          and wa_char-charvalue = 'Ja'.
          f_found = 'X'.
          exit.
        else.
        endif.
      endloop.

      if f_found = 'X'.
*     Auflösung durchführen
        clear itab_draw_tmp.
        clear return.
        call function 'BAPI_DOCUMENT_GETSTRUCTURE'
          exporting
            documenttype              = wa_draw-dokar
            documentnumber            = wa_draw-doknr
            documentpart              = wa_draw-doktl
            documentversion           = wa_draw-dokvr
            multilevelexplosion       = ''
*         DOCBOMCHANGENUMBER        =
*         DOCBOMVALIDFROM           =
*         DOCBOMREVISIONLEVEL       =
          importing
            return                    = return
          tables
            documentstructure         = itab_structure
                  .
        if return is initial.
        else.
          continue.
        endif.
        loop at itab_structure into wa_structure.
          clear wa_draw.
          wa_draw-dokar = wa_structure-documenttype.
          wa_draw-doknr = wa_structure-documentnumber.
          wa_draw-doktl = wa_structure-documentpart.
          wa_draw-dokvr = wa_structure-documentversion.
          append wa_draw to itab_draw_result.
        endloop.

      else.
      endif.
    endloop. "Dokumente

*   Übergabe der kombinierten Tabelle
    itab_draw[] = itab_draw_result[].


*   Dokumente dem Ausgabesystem übergeben
    loop at itab_draw into wa_draw.
      clear wa_item_fauf.

      move-corresponding wa_draw to wa_item_fauf.

      wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.
*      wa_item_fauf-folnr = afdld_tab-folnr.
*      wa_item_fauf-vornr = afdld_tab-vornr.
      wa_item_fauf-aufnr_pp = wa_caufvd-aufnr.
      wa_item_fauf-matnr = wa_caufvd-matnr.

*     Druckinformationen
      wa_item_fauf-drtxt = print_co-drtxt.

      wa_item_fauf-psteu = print_co-psteu.
      wa_item_fauf-samlt = print_co-samlt.
      wa_item_fauf-pmode = print_co-pmode.
      wa_item_fauf-drart = print_co-drart.
      wa_item_fauf-ktext = print_co-ktext.
      wa_item_fauf-selpr = print_co-selpr.
      wa_item_fauf-tcode = print_co-tcode.

*     Projektsystem Informationen
      wa_item_fauf-projn = wa_caufvd-projn.
*     mglw. Nachlesen der ID
      if wa_item_fauf-projn is initial.
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
    endloop. "Dokumente
  endloop. "Aufträge


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



************************************************************************
* normale Linkbehandlung
  clear itab_items_fauf.
  loop at afdld_tab.
    clear wa_item_fauf.

    move-corresponding afdld_tab to wa_item_fauf.
    wa_item_fauf-verteiler = wa_user_data-default_verteiler_fauf.
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
endform.                    "print_sub


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
