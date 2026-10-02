FUNCTION /cideon/get_2d_special_matnr.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      IO_ITAB_DRAW STRUCTURE  ZCL_S_DOCSEARCH
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 26.04.2005 - Erstellung
* 27.04.2005 - Dokumentenstückliste etc.
* 14.06.2005 - Kopie
* 24.07.2006 - Integration des Drucks der Stücklistenübersichten
* 18.10.2006 - Sprachintegration
* 30.11.2006 - Bereinigung um doppelte Einträge
*              Abschalten der Suche über Verwendungsnachweis
* 04.10.2007 - SP 51
*              Fehler, falls Hinweis innerhalb der Merkmalsnamen
*              gepflegt, dann wird dieer Hinweise als Merkmal
*              interpretiert
* 07.10.2008 - SP 81
*              Nutzerparameter für
*              cb_links, b_where_used, cb_delete_duplicates
* 31.12.2008 - SP 87
*              BUG 5690 - Dubblettenbereinigung -> ROFIN
*
* SP 92
* 07.05.2009 - Beachtung von ECN und Gültigkeiten, falls diese gefüllt
*              sind -> Manz
*
* SP 94
* 2009/06/22 - Problem mit Löschen interner Tabelle und Index
* 2009/06/23 - Netzsch
*              Positionstyp 'S'  :-((
*
* SP 104
* 25.09.2009 - Mitgabe der Materialnummer -> Rademaker
*
* 29.09.2009 - Übergabe des Gültigkeitsdatums für Auflösung innerhalb
*              der Materialstückliste
*
* SP 124
* 05.05.2010
*             DELETEVALUE Löschenkennzeichen bei doppelten Einträgen
*             SR 8463
*             Aktivieren von "doppelte Einträge entfernen" bei
*             "Zeichnungen laden (variabel) / Material" führt zum
*             Verschwinden kompletter Einträge
*-----------------------------------------------------------------------
* to do
*            - Ausgabe von Stücklistenfunktionalität
*              siehe ME23N
*
*            - Ranges beachten / Intervalle etc.
*              (scheint zu funktionieren)
*            - lesen der Einstellungen in den unteren
*              Funktionsbausteine ausbauen, wegen
*              Geschwindigkeit
*-----------------------------------------------------------------------

*RANGES
  DATA: so_dokar TYPE rsdsselopt OCCURS 0.
  DATA: so_dokar_links TYPE rsdsselopt OCCURS 0.

*ITAB
  DATA: itab_split TYPE TABLE OF char3.
  DATA: itab_documentstructure TYPE TABLE OF bapi_doc_structure.
  DATA: itab_whereusedlist TYPE TABLE OF bapi_doc_structure.
  DATA: itab_whereusedlist_result TYPE TABLE OF bapi_doc_structure.
  DATA: itab_whereusedlist_cleared TYPE TABLE OF bapi_doc_structure.
  DATA: itab_objectlinks TYPE TABLE OF bapi_doc_drad.
  DATA: itab_draw TYPE TABLE OF draw.
  DATA: itab_draw2 TYPE TABLE OF draw.
  DATA: itab_mast TYPE TABLE OF mast.
  DATA: itab_stb TYPE TABLE OF stpox.
  DATA: itab_drad TYPE TABLE OF drad.

*WA
  DATA: wa_split TYPE char3.
  DATA: wa_so_dokar TYPE rsdsselopt.
  DATA: wa_documentstructure TYPE bapi_doc_structure.
  DATA: return TYPE bapiret2.
  DATA: wa_whereusedlist TYPE bapi_doc_structure.
  DATA: wa_objectlinks TYPE bapi_doc_drad.
  DATA: wa_draw TYPE draw.
  DATA: wa_doc_keys TYPE mcdokob.
  DATA: wa_mast TYPE mast.
  DATA: wa_stb TYPE stpox.
  DATA: wa_drad TYPE drad.

*NORMAL
  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.

  DATA: aennr TYPE aennr.
  DATA: ccdat TYPE ccdat.

  DATA: links(1).

  DATA: matnr TYPE matnr.
  DATA: capid TYPE capid.
  DATA: stufe TYPE histu.

  DATA: lines TYPE i.
  DATA: index TYPE i.
  DATA: index2 TYPE i.
  DATA: key TYPE drad-objky.
  DATA: anzahl.

  DATA: f_cs03.
  DATA: f_cs11.
  DATA: f_cs12.
  DATA: f_cs13.

  DATA: tmp_name TYPE zcl_pname.
  DATA: tmp_wert TYPE zcl_pwert.

  DATA: g_smartform_cs02_spr TYPE /cideon/smartform_cs02_spr.
  DATA: g_smartform_cs11_spr TYPE /cideon/smartform_cs11_spr.
  DATA: g_smartform_cs12_spr TYPE /cideon/smartform_cs12_spr.
  DATA: g_smartform_cs13_spr TYPE /cideon/smartform_cs13_spr.

  DATA: g_where_used.
  DATA: g_delete_duplicates.
  DATA: g_f_valid_docs.

  CLEAR g_where_used.
  CLEAR g_delete_duplicates.

  CLEAR g_smartform_cs02_spr.
  CLEAR g_smartform_cs11_spr.
  CLEAR g_smartform_cs12_spr.
  CLEAR g_smartform_cs13_spr.

  CLEAR io_itab_draw.

  CLEAR g_f_valid_docs.

  CLEAR aennr.
  CLEAR ccdat.

  CLEAR links.

  CLEAR matnr.
  CLEAR capid.
  CLEAR stufe.

* Range füllen
  CLEAR wa_split.
  CLEAR itab_split.

  SPLIT i_user_data-2d_derivation_list AT '/' INTO TABLE itab_split.

  LOOP AT itab_split INTO wa_split.
    CLEAR wa_so_dokar.
    wa_so_dokar-sign = 'I'.
    wa_so_dokar-option = 'EQ'.
    wa_so_dokar-low = wa_split.
    APPEND wa_so_dokar TO so_dokar.
  ENDLOOP.

  CLEAR f_cs03.
  CLEAR f_cs11.
  CLEAR f_cs12.
  CLEAR f_cs13.

* Klassifikationsinformationen mappen
  DATA: it_charval TYPE TABLE OF bapi_characteristic_values.
  DATA: wa_charval TYPE bapi_characteristic_values.

  CLEAR wa_charval.
  CLEAR it_charval.

  wa_charval-charname = i_user_data-src_flag_name.
  wa_charval-charvalue = i_user_data-src_flag_val.
  APPEND wa_charval TO it_charval.

  wa_charval-charname = i_user_data-src_flag_name_2.
  wa_charval-charvalue = i_user_data-src_flag_val_2.
  APPEND wa_charval TO it_charval.

  cb_links = i_user_data-knz_links.
  cb_where_used = i_user_data-knz_where_used.
  cb_delete_duplicates = i_user_data-knz_delete_duplicates.

  cb_valid_docs = i_user_data-valid_docs.
  g_f_valid_docs = i_user_data-valid_docs.

  CALL FUNCTION '/CIDEON/ASK_MATNR_SO'
       IMPORTING
            o_aennr              = aennr
            o_ccdat              = ccdat
            o_links              = links
            o_matnr              = matnr
            o_capid              = capid
            o_stufe              = stufe
            o_f_cs03             = f_cs03
            o_f_cs11             = f_cs11
            o_f_cs12             = f_cs12
            o_f_cs13             = f_cs13
            o_smartform_cs02     = i_user_data-smartform_cs02
            o_smartform_cs11     = i_user_data-smartform_cs11
            o_smartform_cs12     = i_user_data-smartform_cs12
            o_smartform_cs13     = i_user_data-smartform_cs13
            o_smartform_cs02_spr = g_smartform_cs02_spr
            o_smartform_cs11_spr = g_smartform_cs11_spr
            o_smartform_cs12_spr = g_smartform_cs12_spr
            o_smartform_cs13_spr = g_smartform_cs13_spr
            o_where_used         = g_where_used
            o_delete_duplicates  = g_delete_duplicates
            o_f_valid_docs       = g_f_valid_docs
       TABLES
            io_so_dokar          = so_dokar
            io_so_dokar_links    = so_dokar_links
            io_charval           = it_charval
       EXCEPTIONS
            error                = 1
            OTHERS               = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    IF sy-subrc = 1.
*     Unvollständiger Schlüssel
      EXIT.
    ELSE.
    ENDIF.
  ENDIF.


  "MAT_CAPID,
  CLEAR tmp_name.
  CLEAR tmp_wert.
  tmp_name = 'MAT_CAPID'.
  tmp_wert = capid.

  CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
       EXPORTING
            i_pname = tmp_name
            i_pwert = tmp_wert
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "cb_links,
  i_user_data-knz_links = cb_links.
  CLEAR tmp_name.
  CLEAR tmp_wert.
  tmp_name = 'KNZ_LINKS'.
  tmp_wert = i_user_data-knz_links.

  CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
       EXPORTING
            i_pname = tmp_name
            i_pwert = tmp_wert
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "cb_where_used,
  i_user_data-knz_where_used = cb_where_used.
  CLEAR tmp_name.
  CLEAR tmp_wert.
  tmp_name = 'KNZ_WHERE_USED'.
  tmp_wert = i_user_data-knz_where_used.

  CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
       EXPORTING
            i_pname = tmp_name
            i_pwert = tmp_wert
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "cb_delete_duplicates
  i_user_data-knz_delete_duplicates = cb_delete_duplicates.
  CLEAR tmp_name.
  CLEAR tmp_wert.
  tmp_name = 'KNZ_DELETE_DUPLICATES'.
  tmp_wert = i_user_data-knz_delete_duplicates.

  CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
       EXPORTING
            i_pname = tmp_name
            i_pwert = tmp_wert
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "cb_valid_docs
  cb_valid_docs = g_f_valid_docs.
  i_user_data-valid_docs = cb_valid_docs.
  CLEAR tmp_name.
  CLEAR tmp_wert.
  tmp_name = 'VALID_DOCS'.
  tmp_wert = i_user_data-valid_docs.

  CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
       EXPORTING
            i_pname = tmp_name
            i_pwert = tmp_wert
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


* Speichern der zu verwendenden Layouts
* Testen, ob etwas geändert wurde
  IF f_cs03 = 'X'.
    CLEAR tmp_name.
    CLEAR tmp_wert.
    tmp_name = 'SMARTFORM_CS02'.
    tmp_wert = i_user_data-smartform_cs02.

    CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
         EXPORTING
              i_pname = tmp_name
              i_pwert = tmp_wert
         EXCEPTIONS
              error   = 1
              OTHERS  = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.

  IF f_cs11 = 'X'.
    CLEAR tmp_name.
    CLEAR tmp_wert.
    tmp_name = 'SMARTFORM_CS11'.
    tmp_wert = i_user_data-smartform_cs11.

    CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
         EXPORTING
              i_pname = tmp_name
              i_pwert = tmp_wert
         EXCEPTIONS
              error   = 1
              OTHERS  = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.

  IF f_cs12 = 'X'.
    CLEAR tmp_name.
    CLEAR tmp_wert.
    tmp_name = 'SMARTFORM_CS12'.
    tmp_wert = i_user_data-smartform_cs12.

    CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
         EXPORTING
              i_pname = tmp_name
              i_pwert = tmp_wert
         EXCEPTIONS
              error   = 1
              OTHERS  = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.

  IF f_cs13 = 'X'.
    CLEAR tmp_name.
    CLEAR tmp_wert.
    tmp_name = 'SMARTFORM_CS13'.
    tmp_wert = i_user_data-smartform_cs13.

    CALL FUNCTION '/CIDEON/MOD_USER_PARAM'
         EXPORTING
              i_pname = tmp_name
              i_pwert = tmp_wert
         EXCEPTIONS
              error   = 1
              OTHERS  = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
  ENDIF.




* Materialstücklisten recherchieren
* falls mehrere vorhanden, dann Auswahldialog benutzen
  CLEAR itab_mast.
  SELECT * FROM mast INTO TABLE itab_mast
    WHERE matnr = matnr.
  IF sy-subrc NE 0.
    MESSAGE e020(/cideon/plot_basis) WITH '&' '&' '&' '&'.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR lines.
  DESCRIBE TABLE itab_mast LINES lines.
  IF lines > '1'.
*   Anzeige des Dialoges / Auswahl eines Eintrages
    CLEAR wa_mast.
    CALL FUNCTION '/CIDEON/ASK_FOR_MAST'
         IMPORTING
              o_wa_mast    = wa_mast
         TABLES
              io_itab_mast = itab_mast
         EXCEPTIONS
              error        = 1
              OTHERS       = 2.
    IF sy-subrc <> 0.
      RAISE error.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
    ENDIF.

  ELSE.
    CLEAR wa_mast.
    READ TABLE itab_mast INTO wa_mast
      INDEX 1.
  ENDIF.

                                                            "2008/10/07
  "CKR
  IF ccdat IS INITIAL.
    ccdat = sy-datum.
  ELSE.
  ENDIF.

  IF aennr IS INITIAL.
  ELSE.
    DATA: ls_aenr TYPE aenr.
    CLEAR ls_aenr.
    SELECT SINGLE * FROM aenr
      INTO ls_aenr
      WHERE aennr = aennr.
    IF sy-subrc NE 0.
    ELSE.
      ccdat = ls_aenr-datuv.
    ENDIF.
  ENDIF.

* Materialstückliste auflösen
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
   EXPORTING
     ftrel                       = ' '
     altvo                       = ' '
     aufsw                       = ' '
     aumgb                       = ' '
     aumng                       = 0
     auskz                       = ' '
     amind                       = ' '
     bagrp                       = ' '
     beikz                       = ' '
     bessl                       = ' '
     bgixo                       = ' '
     brems                       = ' '
     capid                       = capid
     chlst                       = ' '
     cospr                       = ' '
     cuobj                       = 000000000000000
     cuovs                       = 0
     cuols                       = ' '
     datuv                       = ccdat "sy-datum
     delnl                       = ' '
     drldt                       = ' '
     ehndl                       = '1'
     emeng                       = 1
     erskz                       = ' '
     erssl                       = ' '
     fbstp                       = ' '
     knfba                       = ' '
     ksbvo                       = ' '
     mbwls                       = ' '
     mktls                       = 'X'
     mdmps                       = ' '
     mehrs                       = 'X' "' '
     mkmat                       = ' '
     mmaps                       = ' '
     salww                       = ' '
     splww                       = ' '
     mmory                       = '1' "' '
     mtnrv                       = matnr
     nlink                       = ' '
     postp                       = ' '
     rndkz                       = ' '
     rvrel                       = ' '
     sanfr                       = ' '
     sanin                       = ' '
     sanka                       = ' '
     sanko                       = ' '
     sanvs                       = ' '
     schgt                       = ' '
     stkkz                       = ' '
     stlal                       = wa_mast-stlal
     stlan                       = wa_mast-stlan
     stpst                       = stufe
     svwvo                       = 'X'
     werks                       = wa_mast-werks
     norvl                       = ' '
     mdnot                       = ' '
     panot                       = ' '
     qverw                       = ' '
     verid                       = ' '
     vrsvo                       = 'X'
*   IMPORTING
*     TOPMAT                      =
*     DSTST                       =
    TABLES
      stb                         = itab_stb
*     MATCAT                      =
   EXCEPTIONS
     alt_not_found               = 1
     call_invalid                = 2
     material_not_found          = 3
     missing_authorization       = 4
     no_bom_found                = 5
     no_plant_data               = 6
     no_suitable_bom_found       = 7
     conversion_error            = 8
     OTHERS                      = 9
            .
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    raise error.
  ENDIF.


* Dokumente zu Baugruppenkopf einfügen
* Kopf-Material einfach an erster Stelle einfügen
  CLEAR wa_stb.
  wa_stb-postp = 'L'.
  wa_stb-idnrk = matnr.
  INSERT wa_stb INTO itab_stb INDEX 1.

* Dokumente recherchieren und an Position einfügen
* falls es sich um Materialpositionen handelt
  CLEAR itab_draw.

  DATA: ls_doc_s TYPE zcl_s_docsearch.
  DATA: lt_doc_s TYPE TABLE OF zcl_s_docsearch.
  DATA: lt_doc_s2 TYPE TABLE OF zcl_s_docsearch.

  CLEAR ls_doc_s.
  CLEAR lt_doc_s.

  LOOP AT itab_stb INTO wa_stb
*    WHERE postp = 'L'
*      OR postp = 'N'
      .
*   Unterscheidungen zwischen verschiedenen Positionstypen
    CASE wa_stb-postp.
      WHEN 'L' OR 'N'.
*       normale Verarbeitung, da Material
      WHEN 'D'.
        IF links = 'X'.
*         Dokumenteinträge abtesten
          IF so_dokar_links[] IS INITIAL.
*           alle Dokumentarten zulassen
            CLEAR wa_draw.
            MOVE-CORRESPONDING wa_stb TO wa_draw.
            APPEND wa_draw TO itab_draw.
          ELSE.
*           Aussortieren
            IF wa_stb-dokar IN so_dokar_links.
              CLEAR wa_draw.
              MOVE-CORRESPONDING wa_stb TO wa_draw.
              APPEND wa_draw TO itab_draw.
            ELSE.
            ENDIF.
          ENDIF.
        ELSE.
        ENDIF.
        CONTINUE.
      WHEN OTHERS.
        " 2009/06/23
        "Test auf andere Positionstypen mit Materialnummern
        IF wa_stb-idnrk IS INITIAL.
          "keine Materialnummer
          CONTINUE.
        ELSE.
          "normale Verarbeitung unter der Annahme, daß es ein Material
          "ist

        ENDIF.

        "CONTINUE.
    ENDCASE.

    index = sy-tabix.
    CLEAR key.
    key = wa_stb-idnrk.
    CLEAR itab_drad.
    CALL FUNCTION 'DOKUMENTE_ZU_OBJEKT'
      EXPORTING
        key                       = key
        objekt                    = 'MARA'
*       MANDT                     = SY-MANDT
*       CHECK_BUFFER_AND_DB       = ' '
      TABLES
        doktab                    = itab_drad
      EXCEPTIONS
        kein_dokument             = 1
        OTHERS                    = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      CONTINUE.
    ELSE.
    ENDIF.

*   Bereinigen
    IF links = 'X'.
*     Dokumenteinträge abtesten
      IF so_dokar_links[] IS INITIAL.
*       alle Dokumentarten zulassen
      ELSE.
*       Aussortieren
        LOOP AT itab_drad INTO wa_drad.
          index2 = sy-tabix.
*         selbst schon eine Zeichnung
          IF wa_drad-dokar IN so_dokar.
            CONTINUE.
          ELSE.
          ENDIF.
          IF wa_drad-dokar IN so_dokar_links.
          ELSE.
            "DELETE itab_drad INDEX index2.
            wa_drad-delflag = 'X'.
            MODIFY itab_drad FROM wa_drad INDEX index2.
          ENDIF.
        ENDLOOP.
        DELETE itab_drad WHERE delflag = 'X'.
      ENDIF.
    ELSE.
    ENDIF.
*   Einfügen
    LOOP AT itab_drad INTO wa_drad.
      CLEAR wa_draw.
      MOVE-CORRESPONDING wa_drad TO wa_draw.
      APPEND wa_draw TO itab_draw.
    ENDLOOP.

                                                            "2009/09/25
    "CKR
    "Mitgabe der Materialnummer
    CLEAR ls_doc_s.

    LOOP AT itab_drad INTO wa_drad.
      CLEAR ls_doc_s.
      MOVE-CORRESPONDING wa_drad TO ls_doc_s.
      ls_doc_s-matnr = wa_drad-objky.

      APPEND ls_doc_s TO lt_doc_s.
    ENDLOOP.
    " / CKR



  ENDLOOP.


* Dokumente bereinigen
* Zeichnungen holen

*  CLEAR itab_draw2.
*  LOOP AT itab_draw INTO wa_draw.
**   2D Ableitungen dazu besorgen
**   falls Eintrag schon selbst 2D Ableitung, dann schon mit
**   übernehmen
*    IF wa_draw-dokar IN so_dokar.
*      APPEND wa_draw TO itab_draw2.
*    ELSE.
*    ENDIF.
*
**   kein Verwendungsnachweis durchführen
*    IF g_where_used = 'X'.
*    ELSE.
*      CONTINUE.
*    ENDIF.
*
*    CLEAR itab_whereusedlist.
*    CLEAR return.
*    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
*      EXPORTING
*        documenttype               = wa_draw-dokar
*        documentnumber             = wa_draw-doknr
*        documentpart               = wa_draw-doktl
*        documentversion            = wa_draw-dokvr
*        getwhereused               = 'X'
**       HOSTNAME                   = ' '
*      IMPORTING
**       DOCUMENTDATA               =
*        return                     = return
*      TABLES
*        whereusedlist              = itab_whereusedlist
*              .
*    IF return IS INITIAL.
*    ELSE.
*      CONTINUE.
*    ENDIF.
*
*    IF itab_whereusedlist[] IS INITIAL.
*      CONTINUE.
*    ELSE.
*    ENDIF.
*
*    CLEAR wa_whereusedlist.
*    LOOP AT itab_whereusedlist INTO wa_whereusedlist
*      WHERE documenttype IN so_dokar.
*      CLEAR wa_draw.
*      wa_draw-dokar = wa_whereusedlist-documenttype.
*      wa_draw-doknr = wa_whereusedlist-documentnumber.
*      wa_draw-doktl = wa_whereusedlist-documentpart.
*      wa_draw-dokvr = wa_whereusedlist-documentversion.
*      APPEND wa_draw TO itab_draw2.
*    ENDLOOP.
*
*  ENDLOOP.

  CLEAR lt_doc_s2.
  LOOP AT lt_doc_s INTO ls_doc_s.
*   2D Ableitungen dazu besorgen
*   falls Eintrag schon selbst 2D Ableitung, dann schon mit
*   übernehmen
    IF ls_doc_s-dokar IN so_dokar.
      APPEND ls_doc_s TO lt_doc_s2.
    ELSE.
    ENDIF.

*   kein Verwendungsnachweis durchführen
    IF g_where_used = 'X'.
    ELSE.
      CONTINUE.
    ENDIF.

    CLEAR itab_whereusedlist.
    CLEAR return.
    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = ls_doc_s-dokar
        documentnumber             = ls_doc_s-doknr
        documentpart               = ls_doc_s-doktl
        documentversion            = ls_doc_s-dokvr
        getwhereused               = 'X'
*       HOSTNAME                   = ' '
      IMPORTING
*       DOCUMENTDATA               =
        return                     = return
      TABLES
        whereusedlist              = itab_whereusedlist
              .
    IF return IS INITIAL.
    ELSE.
      CONTINUE.
    ENDIF.

    IF itab_whereusedlist[] IS INITIAL.
      CONTINUE.
    ELSE.
    ENDIF.

    CLEAR wa_whereusedlist.
    LOOP AT itab_whereusedlist INTO wa_whereusedlist
      WHERE documenttype IN so_dokar.
      CLEAR ls_doc_s.
      ls_doc_s-dokar = wa_whereusedlist-documenttype.
      ls_doc_s-doknr = wa_whereusedlist-documentnumber.
      ls_doc_s-doktl = wa_whereusedlist-documentpart.
      ls_doc_s-dokvr = wa_whereusedlist-documentversion.
      APPEND ls_doc_s TO lt_doc_s2.
    ENDLOOP.

  ENDLOOP.



* Links besorgen ? (entffällt?)



* Rückgabetabelle füllen
*  io_itab_draw[] = itab_draw2[].
  DATA: wa_io_itab_draw TYPE zcl_s_docsearch.
  DATA: wa_io_itab_draw2 TYPE zcl_s_docsearch.

  CLEAR io_itab_draw.

*  LOOP AT itab_draw2 INTO wa_draw.
*    CLEAR wa_io_itab_draw.
*    MOVE-CORRESPONDING wa_draw
*      TO wa_io_itab_draw.
*    APPEND wa_io_itab_draw TO io_itab_draw.
*  ENDLOOP.



  "CKR 2009/09/25
  LOOP AT lt_doc_s2 INTO ls_doc_s.
    CLEAR wa_io_itab_draw.
    MOVE-CORRESPONDING ls_doc_s
      TO wa_io_itab_draw.
    APPEND wa_io_itab_draw TO io_itab_draw.
  ENDLOOP.
  "/CKR 2009/09/25

  IF f_cs03 = 'X'
    OR f_cs11 = 'X'
    OR f_cs12 = 'X'
    OR f_cs13 = 'X'.
    .
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
              percentage = '45'  " Balkenanzeige
              text       = text-011.
  ELSE.
  ENDIF.

* Materialstücklisten Drucks holen
  DATA: it_sel_objects TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: wa_sel_objects TYPE zcl_pdm_exp_objects.


  CLEAR it_sel_objects.
  CLEAR wa_sel_objects.

  MOVE-CORRESPONDING wa_mast TO wa_sel_objects.
  wa_sel_objects-object_type = 'BILLOFMAT'.

* spezialanbindung wegen Übergabe / kein Speichern
  wa_sel_objects-ktext = 'NO SAVE CKR'.

  IF f_cs03 = 'X'.
    wa_sel_objects-f_cs03 = 'X'.
    wa_sel_objects-f_cs11 = ''.
    wa_sel_objects-f_cs12 = ''.
    wa_sel_objects-f_cs13 = ''.
    wa_sel_objects-cs03_spras = g_smartform_cs02_spr.
    wa_sel_objects-ccdat = ccdat.
    APPEND wa_sel_objects TO it_sel_objects.
  ELSE.
  ENDIF.

  IF f_cs11 = 'X'.
    wa_sel_objects-f_cs03 = ''.
    wa_sel_objects-f_cs11 = 'X'.
    wa_sel_objects-f_cs12 = ''.
    wa_sel_objects-f_cs13 = ''.
    wa_sel_objects-cs11_spras = g_smartform_cs11_spr.
    wa_sel_objects-ccdat = ccdat.
    APPEND wa_sel_objects TO it_sel_objects.
  ELSE.
  ENDIF.

  IF f_cs12 = 'X'.
    wa_sel_objects-f_cs03 = 'X'.
    wa_sel_objects-f_cs11 = ''.
    wa_sel_objects-f_cs12 = 'X'.
    wa_sel_objects-f_cs13 = ''.
    wa_sel_objects-cs12_spras = g_smartform_cs12_spr.
    wa_sel_objects-ccdat = ccdat.
    APPEND wa_sel_objects TO it_sel_objects.
  ELSE.
  ENDIF.

  IF f_cs13 = 'X'.
    wa_sel_objects-f_cs03 = 'X'.
    wa_sel_objects-f_cs11 = ''.
    wa_sel_objects-f_cs12 = ''.
    wa_sel_objects-f_cs13 = 'X'.
    wa_sel_objects-cs13_spras = g_smartform_cs13_spr.
    wa_sel_objects-ccdat = ccdat.
    APPEND wa_sel_objects TO it_sel_objects.
  ELSE.
  ENDIF.


  IF it_sel_objects[] IS INITIAL.
  ELSE.
    CALL FUNCTION '/CIDEON/PSBRW_OBJ_RELEASE_FRTA'
         EXPORTING
              function         = '/CIDEON/GET_2D_SPECIAL_MATNR'
              fm_name          = '/CIDEON/GET_2D_SPECIAL_MATNR'
         TABLES
              selected_objects = it_sel_objects
         EXCEPTIONS
              error            = 1
              OTHERS           = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      IF it_sel_objects[] IS INITIAL.
      ELSE.
        LOOP AT it_sel_objects INTO wa_sel_objects.
          CLEAR wa_io_itab_draw.

          MOVE-CORRESPONDING wa_sel_objects TO wa_io_itab_draw.


          wa_io_itab_draw-knz_spez_dok = 'X'.
          wa_io_itab_draw-dokar = 'SPZ'.

*        wa_io_itab_draw-doknr = wa_io_itab_draw-object_type.

          IF wa_io_itab_draw-doknr IS INITIAL.
            wa_io_itab_draw-doknr = wa_sel_objects-object_type.
          ELSE.
            wa_io_itab_draw-doknr = wa_sel_objects-doknr.
          ENDIF.

          wa_io_itab_draw-doktl = '000'.
          wa_io_itab_draw-dokvr = '00'.

          APPEND wa_io_itab_draw TO io_itab_draw.

        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDIF.

* Bereinigung um doppelte Einträge
  IF g_delete_duplicates = 'X'.
* 2010/05/05
    DATA: lt_draw TYPE TABLE OF zcl_s_docsearch.
    DATA: lc_draw TYPE zcl_s_docsearch.

    CLEAR lt_draw.
    LOOP AT io_itab_draw INTO wa_io_itab_draw.
      IF wa_io_itab_draw-deletevalue = 'X'.
        CONTINUE.
      ELSE.
      ENDIF.

      APPEND wa_io_itab_draw TO lt_draw.
      "Löschen der doppelten Einträge
      LOOP AT io_itab_draw INTO lc_draw
        WHERE dokar = wa_io_itab_draw-dokar
        AND doknr = wa_io_itab_draw-doknr
        AND doktl = wa_io_itab_draw-doktl
        AND dokvr = wa_io_itab_draw-dokvr
        .
        index = sy-tabix.
        "DELETE io_itab_draw INDEX index.
        lc_draw-deletevalue = 'X'.
        MODIFY io_itab_draw FROM lc_draw INDEX index.
      ENDLOOP.
    ENDLOOP.
    io_itab_draw[] = lt_draw[].


*   2008/12/31
    "CKR
*    DATA: lt_draw TYPE TABLE OF zcl_s_docsearch.
*    DATA: lc_draw TYPE zcl_s_docsearch.
*
*    CLEAR lt_draw.
*    LOOP AT io_itab_draw INTO wa_io_itab_draw.
*      APPEND wa_io_itab_draw TO lt_draw.
*      "Löschen der doppelten Einträge
*      LOOP AT io_itab_draw INTO lc_draw
*        WHERE dokar = wa_io_itab_draw-dokar
*        AND doknr = wa_io_itab_draw-doknr
*        AND doktl = wa_io_itab_draw-doktl
*        AND dokvr = wa_io_itab_draw-dokvr
*        .
*        index = sy-tabix.
*        DELETE io_itab_draw INDEX index.
*      ENDLOOP.
*    ENDLOOP.
*    io_itab_draw[] = lt_draw[].

*    LOOP AT io_itab_draw INTO wa_io_itab_draw.
*      index = sy-tabix.
*      CLEAR anzahl.
*      DESCRIBE TABLE io_itab_draw LINES anzahl.
*      CLEAR index2.
*      index2 = index + 1.
*      DO.
*        CLEAR wa_io_itab_draw2.
*        READ TABLE io_itab_draw INTO wa_io_itab_draw2
*          INDEX index2.
*        IF sy-subrc NE 0.
*          EXIT.
*        ELSE.
*        ENDIF.
*
*        IF wa_io_itab_draw-dokar = wa_io_itab_draw2-dokar
*          AND wa_io_itab_draw-doknr = wa_io_itab_draw2-doknr
*          AND wa_io_itab_draw-doktl = wa_io_itab_draw2-doktl
*          AND wa_io_itab_draw-dokvr = wa_io_itab_draw2-dokvr
*          .
**         doppelter Eintrag gefunden
*          DELETE io_itab_draw INDEX index2.
*          index2 = index2 - 1.
*        ELSE.
*          index2 = index2 + 1.
*        ENDIF.
*      ENDDO.
*
*    ENDLOOP.
  ELSE.
  ENDIF.

* Tabelle mit Klassifikation bereinigen
* Es wird von einer UND Verknüpfung ausgegangen

  CLEAR wa_charval.
*  CLEAR it_charval.

* Test, ob das Merkmal existiert
  DATA: wa_cabn TYPE cabn.
  CLEAR wa_cabn.

  LOOP AT it_charval INTO wa_charval.
    SELECT SINGLE * FROM cabn INTO wa_cabn
      WHERE atnam = wa_charval-charname
      .
    IF sy-subrc NE 0.
      "DELETE it_charval INDEX sy-tabix.
      wa_charval-deletevalue = 'X'.
      MODIFY it_charval FROM wa_charval INDEX sy-tabix.
    ELSE.
    ENDIF.
  ENDLOOP.

  DELETE it_charval WHERE deletevalue = 'X'.


  READ TABLE it_charval INTO wa_charval INDEX 1.
  IF sy-subrc NE 0.
  ELSE.
    IF wa_charval-charname IS INITIAL.
    ELSE.
*     Verarbeitung
      CLEAR wa_draw.
      LOOP AT io_itab_draw INTO wa_io_itab_draw.
        IF wa_io_itab_draw-knz_spez_dok = 'X'.
          CONTINUE.
        ELSE.
        ENDIF.

        index = sy-tabix.
        MOVE-CORRESPONDING wa_io_itab_draw TO wa_draw.
        CALL FUNCTION '/CIDEON/CHK_DOC_CHARVALUE'
             EXPORTING
                  wa_charvalue = wa_charval
                  wa_draw      = wa_draw
             EXCEPTIONS
                  error        = 1
                  found        = 2
                  not_found    = 3
                  OTHERS       = 4.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          CASE sy-subrc.
            WHEN '1'.
              "DELETE io_itab_draw INDEX index.
              wa_io_itab_draw-deletevalue = 'X'.
              MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.
            WHEN '2'.
            WHEN '3'.
              "DELETE io_itab_draw INDEX index.
              wa_io_itab_draw-deletevalue = 'X'.
              MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.
            WHEN OTHERS.
              "DELETE io_itab_draw INDEX index.
              wa_io_itab_draw-deletevalue = 'X'.
              MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.
          ENDCASE.
        ENDIF.
      ENDLOOP.
      DELETE io_itab_draw WHERE deletevalue = 'X'.
    ENDIF.
  ENDIF.




  READ TABLE it_charval INTO wa_charval INDEX 2.
  IF sy-subrc NE 0.
  ELSE.
    IF wa_charval-charname IS INITIAL.
    ELSE.
*     Verarbeitung
      CLEAR wa_draw.
      LOOP AT io_itab_draw INTO wa_io_itab_draw.
        IF wa_io_itab_draw-knz_spez_dok = 'X'.
          CONTINUE.
        ELSE.
        ENDIF.

        index = sy-tabix.
        MOVE-CORRESPONDING wa_io_itab_draw TO wa_draw.
        CALL FUNCTION '/CIDEON/CHK_DOC_CHARVALUE'
             EXPORTING
                  wa_charvalue = wa_charval
                  wa_draw      = wa_draw
             EXCEPTIONS
                  error        = 1
                  found        = 2
                  not_found    = 3
                  OTHERS       = 4.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          CASE sy-subrc.
            WHEN '1'.
              "DELETE io_itab_draw INDEX index.
              wa_io_itab_draw-deletevalue = 'X'.
              MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.
            WHEN '2'.
            WHEN '3'.
              "DELETE io_itab_draw INDEX index.
              wa_io_itab_draw-deletevalue = 'X'.
              MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.
            WHEN OTHERS.
              "DELETE io_itab_draw INDEX index.
              wa_io_itab_draw-deletevalue = 'X'.
              MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.
          ENDCASE.
        ENDIF.
      ENDLOOP.
      DELETE io_itab_draw WHERE deletevalue = 'X'.
    ENDIF.
  ENDIF.



  " 2009/05/07
  "CKR
  "Gültigkeiten beachten, falls ECN oder Datum gefüllt ist
  " ccdat / aennr
  IF g_f_valid_docs = 'X'.
    DATA: lc_act_version TYPE draw-dokvr.
    DATA: ls_return TYPE bapiret2.

    IF aennr IS INITIAL.
    ELSE.
      " Datum der Änderungsnummer holen

      CLEAR ls_aenr.
      SELECT SINGLE * FROM aenr INTO ls_aenr
        WHERE aennr = aennr
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      "aenr-datuv benutzen
      LOOP AT io_itab_draw INTO wa_io_itab_draw.
        IF wa_io_itab_draw-knz_spez_dok = 'X'.
          CONTINUE.
        ELSE.
        ENDIF.

        index = sy-tabix.

        "check auf Datum
        CLEAR lc_act_version.
        CLEAR ls_return.

        CALL FUNCTION 'BAPI_DOCUMENT_GETACTVERSION'
             EXPORTING
                  documenttype    = wa_io_itab_draw-dokar
                  documentnumber  = wa_io_itab_draw-doknr
                  documentpart    = wa_io_itab_draw-doktl
                  documentversion = wa_io_itab_draw-dokvr
                  date            = ls_aenr-datuv
                  releaseonly     = 'X'
             IMPORTING
                  return          = ls_return
                  actualversion   = lc_act_version.
        IF ls_return-type CA 'EA'.
          "Fehler
          " 2009/06/22
          wa_io_itab_draw-loedk = 'C'.
          MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.

          "DELETE io_itab_draw INDEX index.
          CONTINUE.
        ELSE.
        ENDIF.

        IF lc_act_version = wa_io_itab_draw-dokvr.
        ELSE.
          "nicht gültig
          " 2009/06/22
          wa_io_itab_draw-loedk = 'C'.
          MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.

          "DELETE io_itab_draw INDEX index.
          CONTINUE.
        ENDIF.

      ENDLOOP.

      " 2009/06/22
      "Löschen der Einträge
      DELETE io_itab_draw WHERE loedk = 'C'.

    ENDIF.

    IF ccdat IS INITIAL.
    ELSE.
      LOOP AT io_itab_draw INTO wa_io_itab_draw.
        IF wa_io_itab_draw-knz_spez_dok = 'X'.
          CONTINUE.
        ELSE.
        ENDIF.

        index = sy-tabix.

        "check auf Datum
        CLEAR lc_act_version.
        CLEAR ls_return.

        CALL FUNCTION 'BAPI_DOCUMENT_GETACTVERSION'
             EXPORTING
                  documenttype    = wa_io_itab_draw-dokar
                  documentnumber  = wa_io_itab_draw-doknr
                  documentpart    = wa_io_itab_draw-doktl
                  documentversion = wa_io_itab_draw-dokvr
                  date            = ccdat
                  releaseonly     = 'X'
             IMPORTING
                  return          = ls_return
                  actualversion   = lc_act_version.
        IF ls_return-type CA 'EA'.
          "Fehler
          " 2009/06/22
          wa_io_itab_draw-loedk = 'C'.
          MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.

          "DELETE io_itab_draw INDEX index.
          CONTINUE.
        ELSE.
        ENDIF.

        IF lc_act_version = wa_io_itab_draw-dokvr.
        ELSE.
          "nicht gültig
          " 2009/06/22
          wa_io_itab_draw-loedk = 'C'.
          MODIFY io_itab_draw FROM wa_io_itab_draw INDEX index.
          "DELETE io_itab_draw INDEX index.
          CONTINUE.
        ENDIF.

      ENDLOOP.

      " 2009/06/22
      "Löschen der Einträge
      DELETE io_itab_draw WHERE loedk = 'C'.

    ENDIF.

  ELSE.
  ENDIF.

  IF io_itab_draw[] IS INITIAL.
    MESSAGE w011(/cideon/plot_basis).
  ELSE.
  ENDIF.

ENDFUNCTION.
