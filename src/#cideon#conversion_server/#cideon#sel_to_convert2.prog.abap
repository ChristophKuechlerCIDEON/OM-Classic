*&---------------------------------------------------------------------*
*& Report  /CIDEON/SEL_TO_CONVERT                                      *
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
* Durchsuchen des Applikations LOGs
*-----------------------------------------------------------------------
*
* Journal
* 17.03.2004 - Kopie
* 08.03.2005 - Integration Konvertierungsregel / DAPPL
* 18.04.2005 - Konvertierung mit Dokumentenstückliste / CONV04
*            - Kopie
* 05.07.2006 - BUG:
*              Beim Durchsuchen des LOG gibt es Probleme, falls der
*              Status einstellig ist (Leerzeichen)
*              Reaktion auf Leerzeichen / Unterstrich bei Version
* 11.01.2007 - Bereinigen mit allen Einträgen, die später erfolgreich
*              konvertiert wurden
*              Rücksicht auf Konvertierungsregel nehmen
*              der Zeitraum ist der gleiche Selektionszeitraum
* 12.01.2007 -
*-----------------------------------------------------------------------


report  /cideon/sel_to_convert       .

* CONTROLS
data: custom_control_alv type ref to cl_gui_custom_container.
* ALV
data: alv_ergebnisse type ref to cl_gui_alv_grid.
*LAYOUT
data: g_layo_alv_ergebnisse type lvc_s_layo.
*LVC_T_ROW
data: itab_et_index_rows_ergebnisse type lvc_t_row.

data: wa_et_index_rows_ergebnisse type lvc_s_row.

* KLassen
class lcl_event_handler_alv definition deferred.
* HANDLER
data: alv_handler type ref to lcl_event_handler_alv.

* TABLES
tables: balhdr.
* TYPES
* ITAB
data: itab_ptx_draw type table of draw.
data: itab_ptx_draw_sel type table of draw.
data: it_ptx_draw_success type table of draw.
data: itab_balhdr type table of balhdr.
data: it_balhdr_success type table of balhdr.

* WA
data: wa_ptx_draw type draw.
data: wa_ptx_draw_sel type draw.
data: wa_ptx_draw_success type draw.
data: wa_balhdr type balhdr.
data: wa_balhdr_success type balhdr.

* NORMAL
data: ok_code like sy-ucomm.
data: anzahl_ergebnisse type i.

data:  gs_layout_searchlist type disvariant.
data:  x_save_searchlist value 'A'.

data: index_itab_alv type i.
data: index type i.
data: f_found.



*SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-010.
*PARAMETERS: rcv04n RADIOBUTTON GROUP rsel DEFAULT 'X'.
*PARAMETERS: rnorm RADIOBUTTON GROUP rsel.
*SELECTION-SCREEN END OF BLOCK bl1.
*
selection-screen begin of block bl2 with frame title text-011.
parameters: ralv radiobutton group rtab default 'X'.
parameters: rdb radiobutton group rtab .
selection-screen end of block bl2.
*
*

selection-screen begin of block bl5 with frame title text-017.
select-options:
  s_user for balhdr-aluser,
  s_date for balhdr-aldate,
  s_time for balhdr-altime
  .
selection-screen end of block bl5.

selection-screen begin of block bl6 with frame title text-018.
* doppelte Einträge bereinigen
parameters: rdentry as checkbox default ''.
* Check auf erfolgreiche Konvertierungen im gleichen Zeitraum
parameters: rchkscc as checkbox default ''.
selection-screen end of block bl6.


selection-screen begin of block bl4 with frame title text-016.
parameters: rconv02 radiobutton group rcnv default 'X'.
parameters: rconv04 radiobutton group rcnv .
selection-screen end of block bl4.


selection-screen begin of block bl3 with frame title text-015.
parameters: rconv as checkbox default ''.
parameters: wsappl   type tdwp-dappl default 'PDF'.
parameters: convers  type convert_spec-name.
selection-screen end of block bl3.


data: r_in_itb(1) value 'X'.
data: r_in_db(1) value ''.

initialization.

  clear itab_ptx_draw.
  clear wa_ptx_draw.


start-of-selection.


** Suche über DRAW
*  IF rcv04n = 'X'.
**   Standardsuche
*    PERFORM call_cv04n.
*  ELSE.
**   Suche nach eigenen Kriterien
*    PERFORM call_cv04n.
*
*  ENDIF.

* Einträge in BALDHDR suchen
  clear itab_balhdr.
  clear wa_balhdr.
  clear itab_ptx_draw.
  clear wa_ptx_draw.

  clear it_balhdr_success.

  perform read_log.

* für den Test auf Erfolg
* Nummern splitten
* LOG Nummer merken in PRENR


* gefundene Einträge nach itab_ptx_draw (DRAW)
* konvertieren



* EXT_NUMBER splitten
  loop at itab_balhdr into wa_balhdr.
    clear wa_ptx_draw.
    split wa_balhdr-extnumber at '_'
      into
      wa_ptx_draw-doknr wa_ptx_draw-dokar
      wa_ptx_draw-doktl wa_ptx_draw-dokvr
      wa_ptx_draw-res1
      wa_ptx_draw-dappl
      wa_ptx_draw-res2
      wa_ptx_draw-res3
      wa_ptx_draw-res4
      wa_ptx_draw-filep
      wa_ptx_draw-filep1
      .
    wa_ptx_draw-prenr = wa_balhdr-lognumber.
    concatenate wa_balhdr-aldate wa_balhdr-altime
      into wa_ptx_draw-mrk_filep.

    append wa_ptx_draw to itab_ptx_draw.
  endloop.

* doppelte Einträge löschen
  if rdentry = 'X'.
    sort itab_ptx_draw by dokar doknr doktl dokvr
      dappl filep.
    delete adjacent duplicates from itab_ptx_draw.
  else.
  endif.


  loop at it_balhdr_success into wa_balhdr_success.
    clear wa_ptx_draw_success.
    split wa_balhdr_success-extnumber at '_'
      into
      wa_ptx_draw_success-doknr wa_ptx_draw_success-dokar
      wa_ptx_draw_success-doktl wa_ptx_draw_success-dokvr
      wa_ptx_draw_success-res1
      wa_ptx_draw_success-dappl
      wa_ptx_draw_success-res2
      wa_ptx_draw_success-res3
      wa_ptx_draw_success-res4
      wa_ptx_draw_success-filep
      wa_ptx_draw-filep1
      .
    wa_ptx_draw_success-prenr = wa_balhdr_success-lognumber.
    concatenate wa_balhdr_success-aldate wa_balhdr_success-altime
      into wa_ptx_draw_success-mrk_filep.


    append wa_ptx_draw_success to it_ptx_draw_success.
  endloop.






* Bereinigen, falls notwendig, wenn zeitlich später
* erfolgreiche Konvertierungen erfolgten
  if rchkscc = 'X'.
    loop at itab_ptx_draw into wa_ptx_draw.
      index = sy-tabix.
*     Suchen in der Erfolgstabelle
      clear wa_ptx_draw_success.
      clear f_found.
*      LOOP AT it_ptx_draw_success INTO wa_ptx_draw_success
*        WHERE dokar = wa_ptx_draw-dokar
*        AND doknr = wa_ptx_draw-doknr
*        AND doktl = wa_ptx_draw-doktl
*        AND dokvr = wa_ptx_draw-dokvr
*        AND dappl = wa_ptx_draw-dappl
*        AND filep = wa_ptx_draw-filep
*        .
*      ENDLOOP.
      loop at it_ptx_draw_success into wa_ptx_draw_success.
        if wa_ptx_draw-dokar = wa_ptx_draw_success-dokar
          and wa_ptx_draw-doknr = wa_ptx_draw_success-doknr
          and wa_ptx_draw-doktl = wa_ptx_draw_success-doktl
          and wa_ptx_draw-dokvr = wa_ptx_draw_success-dokvr
          and wa_ptx_draw-dappl = wa_ptx_draw_success-dappl
          and wa_ptx_draw-filep = wa_ptx_draw_success-filep
            .
          f_found = 'X'.
*         Datumsvergleich
          if wa_ptx_draw_success-mrk_filep >
            wa_ptx_draw-mrk_filep.
            "OK dann löschen
            delete itab_ptx_draw index index.
            exit.
          else.
          endif.
        else.
        endif.
      endloop.
    endloop.
  else.
  endif.

* DOKST lesen
  clear index.
  loop at itab_ptx_draw into wa_ptx_draw.

*   Version testen, auf Unterstrich / mit Leerzeichen
*   ersetzen
    if wa_ptx_draw-dokvr cs '_'.
      " break kuechler.
      replace '_' with space into wa_ptx_draw-dokvr.
    else.
    endif.

    index = sy-tabix.
    select single dokst from draw into wa_ptx_draw-dokst
      where dokar = wa_ptx_draw-dokar
      and doknr = wa_ptx_draw-doknr
      and doktl = wa_ptx_draw-doktl
      and dokvr = wa_ptx_draw-dokvr
      .
    if sy-subrc ne 0.
    else.
    endif.

    modify itab_ptx_draw from wa_ptx_draw index index.
  endloop.

  describe table itab_ptx_draw lines anzahl_ergebnisse .

  if anzahl_ergebnisse > 0.
*   Anzeige / Übernahme in Ergebnistabelle
    if ralv = 'X'.
      call screen 100.
    else.
*     Tabelle komplett übernehmen
      clear itab_ptx_draw_sel.
      itab_ptx_draw_sel[] = itab_ptx_draw[].
    endif.

*   Tabellen freigeben -> Speicher
    clear itab_ptx_draw.


*   Konvertierung starten
    loop at itab_ptx_draw_sel into wa_ptx_draw_sel.

      if rconv02 = 'X'.
*       normale Konvertierung über CONV02
        if rconv = 'X'.
          submit conv_convert_document and return
            with dokar = wa_ptx_draw_sel-dokar
            with doknr = wa_ptx_draw_sel-doknr
            with doktl = wa_ptx_draw_sel-doktl
            with dokvr = wa_ptx_draw_sel-dokvr
*          WITH dokst = wa_ptx_draw_sel-dokst
            with wsappl =  wsappl
            with convers = convers
            .
        else.
          submit conv_convert_document and return
            with dokar = wa_ptx_draw_sel-dokar
            with doknr = wa_ptx_draw_sel-doknr
            with doktl = wa_ptx_draw_sel-doktl
            with dokvr = wa_ptx_draw_sel-dokvr
            with dokst = wa_ptx_draw_sel-dokst
            .
        endif.
      else.
*       Konvertierung über CONV04
        submit conv_convert_doc_structure
          and return
          with dokar = wa_ptx_draw_sel-dokar
          with doknr = wa_ptx_draw_sel-doknr
          with doktl = wa_ptx_draw_sel-doktl
          with dokvr = wa_ptx_draw_sel-dokvr.
      endif.

    endloop.


  else.
    message s024(/cideon/tools)
      with '' '' '' ''.
*   keine Einträge bei Suche gefunden & & & &

  endif.

  include /cideon/sel_to_conv_class_2.
*  INCLUDE /cideon/sel_to_convert_class.

  include /cideon/sel_to_conv_const_2.
*  INCLUDE /cideon/sel_to_convert_const.
  include /cideon/sel_to_conv_f1_2.
*  INCLUDE /cideon/sel_to_convert_f1.
  include /cideon/sel_to_conv_pbo100_2.
*  INCLUDE /cideon/sel_to_convert_pbo100.
  include /cideon/sel_to_conv_pai100_2.
*  INCLUDE /cideon/sel_to_convert_pai100.
  include /cideon/sel_to_conv_pbo200_2.
*  INCLUDE /cideon/sel_to_convert_pbo200.
  include /cideon/sel_to_conv_pai200_2.
*  INCLUDE /cideon/sel_to_convert_pai200.
  include /cideon/sel_to_conv_f2_2.
*  INCLUDE /cideon/sel_to_convert_f2.
