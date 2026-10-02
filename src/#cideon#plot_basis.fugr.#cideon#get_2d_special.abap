FUNCTION /cideon/get_2d_special.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_USER_DATA) TYPE  /CIDEON/PLOT_USERDATA
*"  TABLES
*"      IO_ITAB_DRAW STRUCTURE  DRAW
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
* 06.08.2007 - SP 45
*            - Test auf Klassifikationswerte
*              Übergabe der Klassifikationswerte
*-----------------------------------------------------------------------
* to do
*            - Ranges beachten / Intervalle etc.
*              (scheint zu funktionieren)
*-----------------------------------------------------------------------

*RANGES
  DATA: so_dokar TYPE rsdsselopt OCCURS 0.

*ITAB
  DATA: itab_split TYPE TABLE OF char3.
  DATA: itab_documentstructure TYPE TABLE OF bapi_doc_structure.
  DATA: itab_whereusedlist TYPE TABLE OF bapi_doc_structure.
  DATA: itab_whereusedlist_result TYPE TABLE OF bapi_doc_structure.
  DATA: itab_whereusedlist_cleared TYPE TABLE OF bapi_doc_structure.
  DATA: itab_objectlinks TYPE TABLE OF bapi_doc_drad.
  DATA: itab_draw TYPE TABLE OF draw.
*WA
  DATA: wa_split TYPE char3.
  DATA: wa_so_dokar TYPE rsdsselopt.
  DATA: wa_documentstructure TYPE bapi_doc_structure.
  DATA: return TYPE bapiret2.
  DATA: wa_whereusedlist TYPE bapi_doc_structure.
  DATA: wa_objectlinks TYPE bapi_doc_drad.
  DATA: wa_draw TYPE draw.
  DATA: wa_doc_keys TYPE mcdokob.
*NORMAL
  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.

  DATA: aennr TYPE aennr.
  DATA: ccdat TYPE ccdat.

  DATA: links(1).

  DATA: index TYPE i.

  CLEAR io_itab_draw.

  CLEAR document.
  CLEAR doc_type.
  CLEAR doc_part.
  CLEAR doc_vers.

  CLEAR aennr.
  CLEAR ccdat.

  CLEAR links.

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

  CALL FUNCTION '/CIDEON/ASK_DOCUMENT_NR_SO'
       IMPORTING
            o_doknr     = document
            o_dokar     = doc_type
            o_dokvr     = doc_vers
            o_doktl     = doc_part
            o_aennr     = aennr
            o_ccdat     = ccdat
            o_links     = links
       TABLES
            io_so_dokar = so_dokar
            io_charval  = it_charval
       EXCEPTIONS
            error       = 1
            OTHERS      = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    IF sy-subrc = 1.
*     Unvollständiger Schlüssel
      EXIT.
    ELSE.
    ENDIF.
  ENDIF.

* Stückliste auflösen
  REFRESH itab_documentstructure.
  CLEAR wa_documentstructure.
  CALL FUNCTION 'BAPI_DOCUMENT_GETSTRUCTURE'
    EXPORTING
      documenttype              = doc_type
      documentnumber            = document
      documentpart              = doc_part
      documentversion           = doc_vers
      multilevelexplosion       = 'X'
*     DOCBOMCHANGENUMBER        =
*     DOCBOMVALIDFROM           =
*     DOCBOMREVISIONLEVEL       =
    IMPORTING
      return                    = return
    TABLES
      documentstructure         = itab_documentstructure
    .
  IF return IS INITIAL.
  ELSE.
    EXIT.
  ENDIF.

* Startpunkt einfügen
  wa_documentstructure-documenttype = doc_type.
  wa_documentstructure-documentnumber = document.
  wa_documentstructure-documentpart = doc_part.
  wa_documentstructure-documentversion = doc_vers.
  INSERT wa_documentstructure
    INTO itab_documentstructure INDEX 1.


* 2D Ableitung recherchieren
* Verwendungsnachweis
  CLEAR itab_whereusedlist_result.
  LOOP AT itab_documentstructure INTO wa_documentstructure.
    CLEAR return.
    CLEAR itab_whereusedlist.

    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_documentstructure-documenttype
        documentnumber             = wa_documentstructure-documentnumber
        documentpart               = wa_documentstructure-documentpart
        documentversion            =
                wa_documentstructure-documentversion
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
    ENDIF.

    LOOP AT itab_whereusedlist INTO wa_whereusedlist.
      APPEND wa_whereusedlist TO itab_whereusedlist_result.
    ENDLOOP.

  ENDLOOP.

* Dokumente bereinigen, nur die Dokumentarten benutzen, die in der
* Range stehen
  CLEAR itab_whereusedlist_cleared.
  LOOP AT itab_whereusedlist_result INTO wa_whereusedlist
    WHERE documenttype IN so_dokar.
    APPEND wa_whereusedlist TO itab_whereusedlist_cleared.
  ENDLOOP.


* verlinkte Dokumente recherchieren
* das sind Links der 2D Ableitungen zu anderen Dokumenten
  CLEAR itab_draw.
  IF links = 'X'.
    LOOP AT itab_whereusedlist_cleared INTO wa_whereusedlist.
      CLEAR return.
      CLEAR wa_objectlinks.
      CLEAR itab_objectlinks.
      CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
        EXPORTING
          documenttype               = wa_whereusedlist-documenttype
          documentnumber             = wa_whereusedlist-documentnumber
          documentpart               = wa_whereusedlist-documentpart
          documentversion            = wa_whereusedlist-documentversion
          getobjectlinks             = 'X'
        IMPORTING
*         DOCUMENTDATA               =
          return                     = return
        TABLES
          objectlinks                = itab_objectlinks
                .
      IF return IS INITIAL.
      ELSE.
      ENDIF.

*     resultierende Tabelle erstellen
*     Basiseintrag hinzufügen
      CLEAR wa_draw.
      wa_draw-dokar = wa_whereusedlist-documenttype.
      wa_draw-doknr = wa_whereusedlist-documentnumber.
      wa_draw-doktl = wa_whereusedlist-documentpart.
      wa_draw-dokvr = wa_whereusedlist-documentversion.

      APPEND wa_draw TO itab_draw.

*     Objecktlinks verarbeiten.
      LOOP AT itab_objectlinks INTO wa_objectlinks
        WHERE objecttype = 'DRAW'.
        CLEAR wa_doc_keys.
        CALL FUNCTION '/CIDEON/ANALYZE_DOCU_OBJECT'
             EXPORTING
                  object_key        = wa_objectlinks-objectkey
                  object_type       = wa_objectlinks-objecttype
             IMPORTING
                  object_key_fields = wa_doc_keys.

        CLEAR wa_draw.
        MOVE-CORRESPONDING wa_doc_keys TO wa_draw.
        APPEND wa_draw TO itab_draw.
      ENDLOOP.

    ENDLOOP.
  ELSE.
*   resultierende Tabelle erstellen
    CLEAR itab_draw.
    LOOP AT itab_whereusedlist_cleared INTO wa_whereusedlist.
      CLEAR wa_draw.
      wa_draw-dokar = wa_whereusedlist-documenttype.
      wa_draw-doknr = wa_whereusedlist-documentnumber.
      wa_draw-doktl = wa_whereusedlist-documentpart.
      wa_draw-dokvr = wa_whereusedlist-documentversion.

      APPEND wa_draw TO itab_draw.
    ENDLOOP.
  ENDIF.


* Tabelle mit Klassifikation bereinigen
* Es wird von einer UND Verknüpfung ausgegangen

  CLEAR wa_charval.
*  CLEAR it_charval.

  READ TABLE it_charval INTO wa_charval INDEX 1.
  IF sy-subrc NE 0.
  ELSE.
    IF wa_charval-charname IS INITIAL.
    ELSE.
*     Verarbeitung
      CLEAR wa_draw.
      LOOP AT itab_draw INTO wa_draw.
        index = sy-tabix.
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
              DELETE itab_draw INDEX index.
            WHEN '2'.
            WHEN '3'.
              DELETE itab_draw INDEX index.
            WHEN OTHERS.
              DELETE itab_draw INDEX index.
          ENDCASE.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.

  READ TABLE it_charval INTO wa_charval INDEX 2.
  IF sy-subrc NE 0.
  ELSE.
    IF wa_charval-charname IS INITIAL.
    ELSE.
*     Verarbeitung
      CLEAR wa_draw.
      LOOP AT itab_draw INTO wa_draw.
        index = sy-tabix.
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
              DELETE itab_draw INDEX index.
            WHEN '2'.
            WHEN '3'.
              DELETE itab_draw INDEX index.
            WHEN OTHERS.
              DELETE itab_draw INDEX index.
          ENDCASE.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.


* Rückgabetabelle füllen
  io_itab_draw[] = itab_draw[].

  IF io_itab_draw[] IS INITIAL.
    MESSAGE w011(/cideon/plot_basis).
  ELSE.
  ENDIF.

ENDFUNCTION.
