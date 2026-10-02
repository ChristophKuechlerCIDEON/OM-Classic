*&---------------------------------------------------------------------*
*& Report  /CIDEON/MODELL_IN_ZEICHNUNG                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*           Dr. Peter Rabe
*           Peter.Rabe@cideon.de
*-----------------------------------------------------------------------
* Journal
* 16.03.2004 - Erstellung
* 17.03.2004 - Mengen
* 24.03.2004 - Überarbeitung als Version 02:
*            - Selektionsbild
*            - /CIDEON/BAPI_DOC_GET_STRUC
*              Holen Dokumentenstruktur mit Standard-FB
*              erweitert um Table DOC_BOM mit Hirarchiestufe
* 18.10.2005 - Button "Material prüfen?" auf neue Zeile, da die MatNr
*              auf DIMP Systemen 40 Zeichen lang ist. Dann läßt sich
*              der SelScreen nicht mehr generieren.
*-----------------------------------------------------------------------
report  /cideon/modell_in_zeichnung
        no standard page heading.

*TYPES
types: begin of t_zeichung,
  dokar type draw-dokar,
  doknr type draw-doknr,
  doktl type draw-doktl,
  dokvr type draw-dokvr,
* untergeordnete DIS
  dokar_sub type draw-dokar,
  doknr_sub type draw-doknr,
  doktl_sub type draw-doktl,
  dokvr_sub type draw-dokvr,
  quantity type kmpmg_bi,
  aennr type draw-aennr,
  dokst type draw-dokst,
  description	type dktxt,
  dostx type tdwst-dostx,
  stufe type histu,
  valid type ccdat,
  revlv type revlv,
  end of t_zeichung.
*ITAB
data: itab_documentstructure type table of bapi_doc_structure.
data: itab_zeichnung_to_model type table of t_zeichung.
data: itab_zeichnung_to_model_out type table of t_zeichung.
data: itab_whereusedlist type table of bapi_doc_structure.
*WA
data: return type bapiret2.
data: wa_documentstructure type bapi_doc_structure.
data: wa_zeichnung_to_model type t_zeichung.
data: wa_zeichnung_to_model_old type t_zeichung.
data: wa_whereusedlist type bapi_doc_structure.
data: documentdata type bapi_doc_draw2.

*NORMAL
data: res4 type resdraw.
data: quantity type i.
data: index type i.
data: f_first(1).
data  linesize type sy-linsz.
data  linepos type sy-linsz.

tables   draw.
tables   sscrfields.

types:   s_vbeln type vbeln,
         s_aufnr type aufnr.


data     lt_doc_bom type table of stpox with header line.


* Eingabe der übergeordneten Baugruppe
* Auflösung der Stückliste
* Zuordnung der IDWS

selection-screen begin of block bl1 with frame title text-009.
parameters:
  p_matnr type zcl_s_plotlist-matnr.
*SELECTION-SCREEN PUSHBUTTON 58(15) ch_matnr USER-COMMAND ch_nr.
*                                    "#EC NEEDED
  selection-screen begin of line.
  selection-screen pushbutton 33(15) ch_matnr user-command ch_nr.
  selection-screen end of line.
parameters:
  p_maktx type makt-maktg,
  p_vbeln type zcl_s_plotlist-vbeln memory id aun,
  p_aufnr type zcl_s_plotlist-aufnr memory id anr,
  p_prdat like sy-datum default sy-datum.
selection-screen end of block bl1.
selection-screen begin of block bl2 with frame title text-010.
parameters:
  p_dokar like draw-dokar obligatory memory id cv2,
  p_doknr like draw-doknr obligatory memory id cv1,
  p_doktl like draw-doktl obligatory memory id cv4,
  p_dokvr like draw-dokvr obligatory memory id cv3,
  p_dokst like draw-dokst,
  p_aennr like draw-aennr,
  p_revle like bapi_doc_draw2-revlevel,
  p_valfr like bapi_doc_draw2-validfromdate.
selection-screen end of block bl2.
selection-screen begin of block bl3 with frame title text-008.
selection-screen begin of line.
selection-screen comment 1(30) text-041 for field r_norm.
parameters  r_norm radiobutton group rb1 default 'X'.
selection-screen comment 40(18) text-042 for field r_erwe.
parameters r_erwe radiobutton group rb1.
selection-screen comment 62(15) text-043 for field r_sond.
parameters r_sond radiobutton group rb1.
selection-screen end of line.
selection-screen end of block bl3.
selection-screen begin of block bl4 with frame title text-029.
parameters:
  p_stufe type c as checkbox default 'X',
  p_descr type c as checkbox default 'X',
  p_quant type c as checkbox default 'X',
  p_dostx type c as checkbox default 'X'.
selection-screen comment /1(79) text-030.
parameters:
  p_aendn type c as checkbox default ' ',
  p_valid type c as checkbox default ' ',
  p_revlv type c as checkbox default ' ',
  p_linsz type /cideon/linsz default '132'.
selection-screen end of block bl4.

initialization.
  move text-035 to ch_matnr.
  import p_matnr from memory id 'man'.
  if not p_matnr is initial.
    import p_maktx from memory id 'max'.
  endif.

at selection-screen.
  if sscrfields-ucomm = 'CH_NR'.
* prüfen ob Material vorhanden
    select single matnr from mara into p_matnr
          where matnr = p_matnr.
    if sy-subrc <> 0.
      message s001(/cideon/plot_basis) with p_matnr.
      "MATNR nicht vorhanden !
      clear: p_matnr, p_maktx.
      free memory id 'man'.
      free memory id 'max'.
    else.
      clear p_maktx.
      select single maktx from makt into p_maktx
            where matnr = p_matnr
            and spras   = sy-langu.
      if sy-subrc <> 0.
        p_maktx = text-033.
        "kein Kurztext in Anmeldesprache
      else.
        export  p_matnr to memory id 'man'.
        export  p_maktx to memory id 'max'.
      endif.
    endif.
  endif.

  if p_linsz > 132.
    message i003(/cideon/plot_basis) with p_linsz.
    p_linsz = 132.
  elseif p_linsz < 81.
    message i002(/cideon/plot_basis) with p_linsz.
    p_linsz = 81.
  endif.

start-of-selection.

*   Struktur holen

  clear return.
  clear itab_documentstructure.

  call function 'SAPGUI_PROGRESS_INDICATOR'
       exporting
            percentage = '15'
            text       = 'Holen Dokumentenstruktur'.

  call function '/CIDEON/BAPI_DOC_GETSTRUC'
       exporting
            documenttype        = p_dokar
            documentnumber      = p_doknr
            documentpart        = p_doktl
            documentversion     = p_dokvr
            multilevelexplosion = 'X'
            docbomchangenumber  = p_aennr
            docbomvalidfrom     = p_valfr
            docbomrevisionlevel = p_revle
       importing
            return              = return
       tables
            documentstructure   = itab_documentstructure
            doc_bom             = lt_doc_bom.
  if return is initial.
  else.
    message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    exit.
  endif.

*   Dokumentenstruktur durchlaufen und Zeichungen holen
*   Zeichungen in Tabelle ablegen
*   oberste Ebene hinzufügen
  clear wa_documentstructure.
  wa_documentstructure-documenttype    = p_dokar.
  wa_documentstructure-documentnumber  = p_doknr.
  wa_documentstructure-documentpart    = p_doktl.
  wa_documentstructure-documentversion = p_dokvr.
  insert wa_documentstructure into itab_documentstructure
    index 1.

  clear wa_zeichnung_to_model.
  clear itab_zeichnung_to_model.

  loop at itab_documentstructure into wa_documentstructure.

    clear return.
    clear itab_whereusedlist.
    clear documentdata.

    call function 'SAPGUI_PROGRESS_INDICATOR'
         exporting
              percentage = '15'
              text       = 'Holen Dokumentendaten'.

    call function 'BAPI_DOCUMENT_GETDETAIL2'
         exporting
              documenttype    = wa_documentstructure-documenttype
              documentnumber  = wa_documentstructure-documentnumber
              documentpart    = wa_documentstructure-documentpart
              documentversion = wa_documentstructure-documentversion
              getwhereused    = 'X'
         importing
              documentdata    = documentdata
              return          = return
         tables
              whereusedlist   = itab_whereusedlist.
    if return is initial.
    else.
      exit.
    endif.


    clear wa_zeichnung_to_model.
    wa_zeichnung_to_model-dokar_sub
      = wa_documentstructure-documenttype.
    wa_zeichnung_to_model-doknr_sub
      = wa_documentstructure-documentnumber.
    wa_zeichnung_to_model-doktl_sub
      = wa_documentstructure-documentpart.
    wa_zeichnung_to_model-dokvr_sub =
      wa_documentstructure-documentversion.
    wa_zeichnung_to_model-quantity =
      wa_documentstructure-quantity.
    wa_zeichnung_to_model-aennr =
      documentdata-ecnumber.
    wa_zeichnung_to_model-description =
      documentdata-description.
    wa_zeichnung_to_model-dokst =
      documentdata-statusintern.
    wa_zeichnung_to_model-valid =
       documentdata-validfromdate.
    wa_zeichnung_to_model-revlv =
       documentdata-revlevel.

    read table lt_doc_bom
        with key dokar = wa_zeichnung_to_model-dokar_sub
                 doknr = wa_zeichnung_to_model-doknr_sub
                 doktl = wa_zeichnung_to_model-doktl_sub
                 dokvr = wa_zeichnung_to_model-dokvr_sub.

    wa_zeichnung_to_model-stufe = lt_doc_bom-stufe.

    loop at itab_whereusedlist into wa_whereusedlist.

      clear res4.
      select single res4 from draw into res4
        where dokar = wa_whereusedlist-documenttype
        and doknr = wa_whereusedlist-documentnumber
        and doktl = wa_whereusedlist-documentpart
        and dokvr = wa_whereusedlist-documentversion
        .
      if sy-subrc ne 0.
      else.
      endif.

      if res4+4 = 'D'.
*         Zeichungseintrag erzeugen
        wa_zeichnung_to_model-dokar =
          wa_whereusedlist-documenttype.
        wa_zeichnung_to_model-doknr =
          wa_whereusedlist-documentnumber.
        wa_zeichnung_to_model-doktl =
          wa_whereusedlist-documentpart.
        wa_zeichnung_to_model-dokvr =
          wa_whereusedlist-documentversion.
        append wa_zeichnung_to_model  to itab_zeichnung_to_model.
      else.
      endif.

    endloop.
  endloop.

*   Sortieren der Zeichungen
  sort itab_zeichnung_to_model
    by dokar doknr doktl dokvr.

*   für Ausgabe aufbereiten
  clear itab_zeichnung_to_model_out.
  itab_zeichnung_to_model_out[] = itab_zeichnung_to_model[].

* Dokumentenstatustext holen
  clear index.
  loop at itab_zeichnung_to_model_out into wa_zeichnung_to_model.
    index = sy-tabix.
    select single dostx from tdwst into wa_zeichnung_to_model-dostx
    where cvlang = sy-langu
    and dokst = wa_zeichnung_to_model-dokst.
    if sy-subrc ne 0.
    else.
      modify itab_zeichnung_to_model_out from wa_zeichnung_to_model
        index index.
    endif.
  endloop.

  new-page line-size p_linsz.

*   Ausgabe der Verlinkungen
  f_first = 'X'.
  clear wa_zeichnung_to_model_old.
  loop at itab_zeichnung_to_model_out into wa_zeichnung_to_model.

    if f_first is initial.
      if wa_zeichnung_to_model_old-dokar =
        wa_zeichnung_to_model-dokar
      and wa_zeichnung_to_model_old-doknr =
        wa_zeichnung_to_model-doknr
      and wa_zeichnung_to_model_old-doktl =
        wa_zeichnung_to_model-doktl
      and wa_zeichnung_to_model_old-dokvr =
        wa_zeichnung_to_model-dokvr
        .
        clear wa_zeichnung_to_model-dokar.
        clear wa_zeichnung_to_model-doknr.
        clear wa_zeichnung_to_model-doktl.
        clear wa_zeichnung_to_model-dokvr.
      else.
      endif.
    else.
    endif.
* Umsetzen Menge wegen Darstellung
    move wa_zeichnung_to_model-quantity to quantity.
* füllen Materialkurztext, falls nicht im Sel-Screen vorbelegt
    select single matnr from mara into p_matnr
          where matnr = p_matnr.
    if sy-subrc <> 0.
      clear: p_matnr, p_maktx.
      free memory id 'man'.
      free memory id 'max'.
    else.
      clear p_maktx.
      select single maktx from makt into p_maktx
            where matnr = p_matnr
            and spras   = sy-langu.
      if sy-subrc <> 0.
        p_maktx = text-033.
        "kein Kurztext in Anmeldesprache
      else.
        export  p_matnr to memory id 'man'.
        export  p_maktx to memory id 'max'.
      endif.
    endif.


    data: a type i,
          b type i,
          c type i,
          d type i.
    if r_norm = 'X'.
      a = wa_zeichnung_to_model-stufe + 40.
      b = wa_zeichnung_to_model-stufe + 45.
      c = wa_zeichnung_to_model-stufe + 72.
      d = wa_zeichnung_to_model-stufe + 76.
    elseif r_erwe = 'X'.
      a = 41.
      b = 46.
      c = 73.
      d = 77.
    elseif r_sond = 'X'.
      a = wa_zeichnung_to_model-stufe * 2 + 40.
      b = wa_zeichnung_to_model-stufe * 2 + 45.
      c = wa_zeichnung_to_model-stufe * 2 + 72.
      d = wa_zeichnung_to_model-stufe * 2 + 76.
    endif.

    clear linesize.

    write: /
      wa_zeichnung_to_model-dokar(3)  under text-016,
      wa_zeichnung_to_model-doknr(25) under text-017,
      wa_zeichnung_to_model-doktl(3) under text-018,
      wa_zeichnung_to_model-dokvr(2) under text-019,
   at a wa_zeichnung_to_model-dokar_sub(3),
   at b wa_zeichnung_to_model-doknr_sub(25),
   at c wa_zeichnung_to_model-doktl_sub(3),
   at d wa_zeichnung_to_model-dokvr_sub(2).
    linesize = 84.

    linepos = p_linsz.
    if p_stufe = 'X'.
      linepos = p_linsz - 3.
      if linesize > linepos.
        linesize = 4.
        new-line.
        write at linesize  wa_zeichnung_to_model-stufe(2).
        linesize = linesize + 3.
      else.
        write at linesize  wa_zeichnung_to_model-stufe(2).
        linesize = linesize + 3.
      endif.
    endif.
    if p_descr = 'X'.
      linepos = p_linsz - 21.
      if linesize > linepos.
        clear linesize.
        new-line.
        write at linesize wa_zeichnung_to_model-description(20).
        linesize = linesize + 21.
      else.
        write at linesize wa_zeichnung_to_model-description(20).
        linesize = linesize + 21.
      endif.
    endif.
    if p_quant = 'X'.
      linepos = p_linsz - 7.
      if linesize > linepos.
        clear linesize.
        new-line.
        write at linesize quantity no-zero centered.
        linesize = linesize + 7.
      else.
        write at linesize quantity no-zero centered.
        linesize = linesize + 7.
      endif.
    endif.
    if p_dostx = 'X'.
      linepos = p_linsz - 16.
      if linesize > linepos.
        clear linesize.
        new-line.
        write at linesize wa_zeichnung_to_model-dostx(15).
        linesize = linesize + 16.
      else.
        write at linesize wa_zeichnung_to_model-dostx(15).
        linesize = linesize + 16.
      endif.
    endif.
    if p_aendn = 'X'.
      linepos = p_linsz - 16.
      if linesize > linepos.
        clear linesize.
        new-line.
        write at linesize wa_zeichnung_to_model-aennr(12).
        linesize = linesize + 16.
      else.
        write at linesize wa_zeichnung_to_model-aennr(12).
        linesize = linesize + 16.
      endif.
    endif.
    if p_valid = 'X'.
      linepos = p_linsz - 11.
      if linesize > linepos.
        clear linesize.
        new-line.
        write at linesize wa_zeichnung_to_model-valid(8) no-zero.
        linesize = linesize + 11.
      else.
        write at linesize wa_zeichnung_to_model-valid(8) no-zero.
        linesize = linesize + 11.
      endif.
    endif.
    if p_revlv = 'X'.
      linepos = p_linsz - 9.
      if linesize > linepos.
        clear linesize.
        new-line.
        write at linesize wa_zeichnung_to_model-revlv(2).
        linesize = linesize + 9.
      else.
        write at linesize wa_zeichnung_to_model-revlv(2).
        linesize = linesize + 9.
      endif.
    endif.

    clear f_first.
    wa_zeichnung_to_model_old = wa_zeichnung_to_model.
  endloop.


*  Ausgabe Kopfdaten
top-of-page.

  write:  / text-001,
          / text-002.
  write:  / text-003, p_matnr,
          / text-004, p_maktx,
          / text-005, p_vbeln,
          / text-006, p_aufnr,
          / text-007, p_prdat.
  uline.
  write:  / text-014,
            text-015.
  uline.
  write:  /
            text-016,
            text-017,
            text-018,
            text-019,
            text-020,
            text-021,
            text-022,
            text-023.
  if p_stufe = 'X'.
    write text-028.
  endif.
  if p_descr = 'X'.
    write text-024.
  endif.
  if p_quant = 'X'.
    write text-025.
  endif.
  if p_dostx = 'X'.
    write text-026.
  endif.
  if p_aendn = 'X'.
    write text-027.
  endif.
  if p_valid = 'X'.
    write text-031.
  endif.
  if p_revlv = 'X'.
    write text-032.
  endif.

  uline.
