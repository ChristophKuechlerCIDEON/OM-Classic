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
*-----------------------------------------------------------------------
* Journal
* 16.03.2004 - Erstellung
* 17.03.2004 - Mengen
*-----------------------------------------------------------------------
REPORT  /cideon/modell_in_zeichnung   .

*TYPES
TYPES: BEGIN OF t_zeichung,
  dokar TYPE draw-dokar,
  doknr TYPE draw-doknr,
  doktl TYPE draw-doktl,
  dokvr TYPE draw-dokvr,
* untergeordnete DIS
  dokar_sub TYPE draw-dokar,
  doknr_sub TYPE draw-doknr,
  doktl_sub TYPE draw-doktl,
  dokvr_sub TYPE draw-dokvr,
  quantity TYPE kmpmg_bi,
  aennr TYPE draw-aennr,
  dokst TYPE draw-dokst,
  description	TYPE dktxt,
  dostx TYPE tdwst-dostx,
  END OF t_zeichung.
*ITAB
DATA: itab_documentstructure TYPE TABLE OF bapi_doc_structure.
DATA: itab_zeichnung_to_model TYPE TABLE OF t_zeichung.
DATA: itab_zeichnung_to_model_out TYPE TABLE OF t_zeichung.
DATA: itab_whereusedlist TYPE TABLE OF bapi_doc_structure.
*WA
DATA: return TYPE bapiret2.
DATA: wa_documentstructure TYPE bapi_doc_structure.
DATA: wa_zeichnung_to_model TYPE t_zeichung.
DATA: wa_zeichnung_to_model_old TYPE t_zeichung.
DATA: wa_whereusedlist TYPE bapi_doc_structure.
DATA: documentdata TYPE bapi_doc_draw2.

*NORMAL
DATA: res4 TYPE resdraw.
DATA: document TYPE csap_dbom-doknr.
DATA: doc_type TYPE csap_dbom-dokar.
DATA: doc_vers TYPE csap_dbom-dokvr.
DATA: doc_part TYPE csap_dbom-doktl.
DATA: dokar TYPE draw-dokar.
DATA: doknr TYPE draw-doknr.
DATA: doktl TYPE draw-doktl.
DATA: dokvr TYPE draw-dokvr.
DATA: laenge TYPE i.
DATA: char25(25).
DATA: anzahl TYPE i.
DATA: aennr TYPE aennr.
DATA: ccdat TYPE ccdat.

DATA: index TYPE i.
DATA: f_first(1).


*SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-010.
*PARAMETERS: p_do TYPE char1 RADIOBUTTON GROUP r1 DEFAULT 'X'.
*PARAMETERS: p_dont TYPE char1 RADIOBUTTON GROUP r1.
*SELECTION-SCREEN END OF BLOCK bl1.



INITIALIZATION.

START-OF-SELECTION.


* Eingabe der übergeordneten Baugruppe
* Auflösung der Stückliste
* Zuordnung der IDWS

*  IF p_do = 'X'.
*   Daten abfragaen
  CLEAR document.
  CLEAR doc_type.
  CLEAR doc_vers.
  CLEAR doc_part.
  CLEAR aennr.
  CLEAR ccdat.

  CALL FUNCTION '/CIDEON/ASK_DOCUMENT_NR'
       IMPORTING
            o_doknr = document
            o_dokar = doc_type
            o_dokvr = doc_vers
            o_doktl = doc_part
            o_aennr = aennr
            o_ccdat = ccdat
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

*   Struktur holen
  dokar = doc_type.
  doknr = document.
  doktl = doc_part.
  dokvr = doc_vers.

  CLEAR return.
  CLEAR itab_documentstructure.
  CALL FUNCTION 'BAPI_DOCUMENT_GETSTRUCTURE'
    EXPORTING
      documenttype              = dokar
      documentnumber            = doknr
      documentpart              = doktl
      documentversion           = dokvr
      multilevelexplosion       = 'X'
      docbomchangenumber        = aennr
      docbomvalidfrom           = ccdat
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

*   Dokumentenstruktur durchlaufen und Zeichungen holen
*   Zeichungen in Tabelle ablegen
*   oberste Ebene hinzufügen
  CLEAR wa_documentstructure.
  wa_documentstructure-documenttype = dokar.
  wa_documentstructure-documentnumber = doknr.
  wa_documentstructure-documentpart = doktl.
  wa_documentstructure-documentversion = dokvr.
  INSERT wa_documentstructure INTO itab_documentstructure
    INDEX 1.

  CLEAR wa_zeichnung_to_model.
  CLEAR itab_zeichnung_to_model.
  LOOP AT itab_documentstructure INTO wa_documentstructure.

    CLEAR return.
    CLEAR itab_whereusedlist.
    CLEAR documentdata.
    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_documentstructure-documenttype
        documentnumber             =
                                wa_documentstructure-documentnumber
        documentpart               = wa_documentstructure-documentpart
        documentversion            =
                                wa_documentstructure-documentversion
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
*       GETACTIVEFILES             = 'X'
*       GETCLASSIFICATION          = ' '
*       GETSTRUCTURE               = ' '
        getwhereused               = 'X'
*       HOSTNAME                   = ' '
      IMPORTING
        documentdata               = documentdata
        return                     = return
      TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
*       DOCUMENTFILES              =
*       COMPONENTS                 =
*       CHARACTERISTICVALUES       =
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
        whereusedlist              = itab_whereusedlist
              .

    IF return IS INITIAL.
    ELSE.
      EXIT.
    ENDIF.

    CLEAR wa_zeichnung_to_model.
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

    LOOP AT itab_whereusedlist INTO wa_whereusedlist.

      CLEAR res4.
      SELECT SINGLE res4 FROM draw INTO res4
        WHERE dokar = wa_whereusedlist-documenttype
        AND doknr = wa_whereusedlist-documentnumber
        AND doktl = wa_whereusedlist-documentpart
        AND dokvr = wa_whereusedlist-documentversion
        .
      IF sy-subrc NE 0.
      ELSE.
      ENDIF.

      IF res4+4 = 'D'.
*         Zeichungseintrag erzeugen
        wa_zeichnung_to_model-dokar =
          wa_whereusedlist-documenttype.
        wa_zeichnung_to_model-doknr =
          wa_whereusedlist-documentnumber.
        wa_zeichnung_to_model-doktl =
          wa_whereusedlist-documentpart.
        wa_zeichnung_to_model-dokvr =
          wa_whereusedlist-documentversion.
        APPEND wa_zeichnung_to_model  TO itab_zeichnung_to_model.
      ELSE.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

*   Sortieren der Zeichungen
  SORT itab_zeichnung_to_model
    BY dokar doknr doktl dokvr.

*   für Ausgabe aufbereiten
  CLEAR itab_zeichnung_to_model_out.
  itab_zeichnung_to_model_out[] = itab_zeichnung_to_model[].

* Dokumentenstatustext holen
  CLEAR index.
  LOOP AT itab_zeichnung_to_model_out INTO wa_zeichnung_to_model.
    index = sy-tabix.
    SELECT SINGLE dostx FROM tdwst INTO wa_zeichnung_to_model-dostx
    WHERE cvlang = sy-langu
    AND dokst = wa_zeichnung_to_model-dokst.
    IF sy-subrc NE 0.
    ELSE.
      MODIFY itab_zeichnung_to_model_out FROM wa_zeichnung_to_model
        INDEX index.
    ENDIF.
  ENDLOOP.

*   Ausgabe der Verlinkungen
  f_first = 'X'.
  CLEAR wa_zeichnung_to_model_old.
  LOOP AT itab_zeichnung_to_model_out INTO wa_zeichnung_to_model.

    IF f_first IS INITIAL.
      IF wa_zeichnung_to_model_old-dokar =
        wa_zeichnung_to_model-dokar
      AND wa_zeichnung_to_model_old-doknr =
        wa_zeichnung_to_model-doknr
      AND wa_zeichnung_to_model_old-doktl =
        wa_zeichnung_to_model-doktl
      AND wa_zeichnung_to_model_old-dokvr =
        wa_zeichnung_to_model-dokvr
        .
        CLEAR wa_zeichnung_to_model-dokar.
        CLEAR wa_zeichnung_to_model-doknr.
        CLEAR wa_zeichnung_to_model-doktl.
        CLEAR wa_zeichnung_to_model-dokvr.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
    WRITE: / wa_zeichnung_to_model-dokar,
      wa_zeichnung_to_model-doknr,
     20 wa_zeichnung_to_model-doktl,
      wa_zeichnung_to_model-dokvr,

      wa_zeichnung_to_model-dokar_sub,
      wa_zeichnung_to_model-doknr_sub,
      wa_zeichnung_to_model-doktl_sub,
      wa_zeichnung_to_model-dokvr_sub,
      wa_zeichnung_to_model-description,
     80 wa_zeichnung_to_model-quantity,
      wa_zeichnung_to_model-dostx,
      wa_zeichnung_to_model-aennr


    .

    CLEAR f_first.
    wa_zeichnung_to_model_old = wa_zeichnung_to_model.
  ENDLOOP.


*  ELSE.
*  ENDIF.

*
