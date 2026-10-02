FUNCTION /cideon/bk_status_30_datum.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Normung aus Statuslog DIS / Nutzer - Fester Text
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.04.2005 - Erstellung
* 12.11.2005 - Kopie
* 15.02.2006 - Kopie
* 20.02.2006 - Kopie
* 27.03.2006 - Kopie
*-----------------------------------------------------------------------

*ITAB
  DATA: itab_status TYPE TABLE OF bapi_doc_drap.
  DATA: it_status_rang TYPE TABLE OF /cideon/_s_stmp_rng_drap.
  DATA: it_merkmale TYPE TABLE OF bapi_characteristic_values.
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: return TYPE bapiret2.
  DATA: wa_status TYPE bapi_doc_drap.
*  DATA: wa_status_rang TYPE /cideon/_s_stmp_rng_drap.
*  DATA: wa_status_rang_next TYPE /cideon/_s_stmp_rng_drap.
*  DATA: wa_status_rang_last TYPE /cideon/_s_stmp_rng_drap.
*  DATA: wa_status_rang_save TYPE /cideon/_s_stmp_rng_drap.
*  DATA: wa_status_rang_akt TYPE /cideon/_s_stmp_rng_drap.
  DATA: wa_merkmal TYPE bapi_characteristic_values.
*NORMAL
  DATA: index TYPE i.
  DATA: index_check TYPE i.
  DATA: f_found.
  DATA: f_ok.

  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  CLEAR o_stempel_wert.


* Test auf erlaubte Dokumentarten
  IF wa_plotjob-dokar = 'D10'
    OR wa_plotjob-dokar = 'D11'
    OR wa_plotjob-dokar = 'D14'
    .
  ELSE.
    EXIT.
  ENDIF.

  CLEAR return.
  CLEAR itab_status.

* Status LOG holen
  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = wa_plotjob-dokar
      documentnumber             = wa_plotjob-doknr
      documentpart               = wa_plotjob-doktl
      documentversion            = wa_plotjob-dokvr
      getstatuslog               = 'X'
      getactivefiles             = ''
      getdocdescriptions         = ''
      getdocfiles                = ''
    IMPORTING
*     DOCUMENTDATA               =
      return                     = return
    TABLES
      statuslog                  = itab_status
            .
  IF return IS INITIAL.
  ELSE.
    CLEAR o_stempel_wert.
    EXIT.
  ENDIF.


* kein Sortieren notwendig / Tabelle wird in Reihenfolge
* geliefert
  CLEAR wa_status.
  LOOP AT itab_status INTO wa_status
    WHERE statusintern = '30'.
  ENDLOOP.
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
  ENDIF.

* letztes Freigabedatum (Status 30) nach dem 12.08.2005 ?
* dann kein Stempeln notwendig
  IF wa_status-logdate > '20050812'.
    EXIT.
  ELSE.
  ENDIF.

* erweiterter Test auf D14 und CADAM Zeichnungen
  IF wa_plotjob-dokar = 'D14'.
*   Klassifikation auswerten
    CLEAR return.
    CLEAR it_merkmale.
    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_plotjob-dokar
        documentnumber             = wa_plotjob-doknr
        documentpart               = wa_plotjob-doktl
        documentversion            = wa_plotjob-dokvr
        getstatuslog               = ''
        getactivefiles             = ''
        getdocdescriptions         = ''
        getdocfiles                = ''
        getclassification          = 'X'
      IMPORTING
*     DOCUMENTDATA               =
        return                     = return
      TABLES
        characteristicvalues       = it_merkmale
              .
    IF return IS INITIAL.
    ELSE.
      CLEAR o_stempel_wert.
      EXIT.
    ENDIF.

    IF it_merkmale[] IS INITIAL.
      CLEAR o_stempel_wert.
      EXIT.
    ELSE.
    ENDIF.

    CLEAR wa_merkmal.
    LOOP AT it_merkmale INTO wa_merkmal
      WHERE charname = 'PLM_112'
      .
    ENDLOOP.
    IF sy-subrc NE 0.
      CLEAR o_stempel_wert.
      EXIT.
    ELSE.
    ENDIF.

*   Erzeugungssystem "CADAM"
    IF wa_merkmal-charvalue = 'CADAM'.
      o_stempel_wert = 'X'.
    ELSE.
    ENDIF.

  ELSE.
    o_stempel_wert = 'X'.
  ENDIF.


*  o_stempel_wert = 'X'.


ENDFUNCTION.
