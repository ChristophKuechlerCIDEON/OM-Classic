FUNCTION z_get_sig_madaus_gueltig_ab.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
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
* 01.02.2005 - Erstellung
*              Freigabedatum von 70 / 80
*              zusätzlich Statustext des entsprechenden
*              Status
*              Datum / Madaus
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_signs_dms_tab TYPE TABLE OF rc77b.
  DATA: it_statuslog TYPE TABLE OF bapi_doc_drap.
*WA
  DATA: wa_draw TYPE draw.
  DATA: wa_plotjob TYPE zcl_s_plotlist.

  DATA: wa_statuslog TYPE bapi_doc_drap.
  DATA: return TYPE bapiret2.
  DATA: wa_tdwst TYPE tdwst.
*NORMAL
  DATA: f_found.
  DATA: index TYPE i.
  DATA: index_found_80 TYPE i.
  DATA: f_found_35.
  DATA: datum(10).


  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

* Statuslog holen
  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = wa_plotjob-dokar
      documentnumber             = wa_plotjob-doknr
      documentpart               = wa_plotjob-doktl
      documentversion            = wa_plotjob-dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
      getstatuslog               = 'X'
*     GETLONGTEXTS               = ' '
*     GETACTIVEFILES             = 'X'
*     GETDOCDESCRIPTIONS         = 'X'
*     GETDOCFILES                = 'X'
*     GETCLASSIFICATION          = ' '
*     GETSTRUCTURE               = ' '
*     GETWHEREUSED               = ' '
*     HOSTNAME                   = ' '
    IMPORTING
*     DOCUMENTDATA               =
      return                     = return
    TABLES
*     OBJECTLINKS                =
*     DOCUMENTDESCRIPTIONS       =
*     LONGTEXTS                  =
      statuslog                  = it_statuslog
*     DOCUMENTFILES              =
*     COMPONENTS                 =
*     CHARACTERISTICVALUES       =
*     CLASSALLOCATIONS           =
*     DOCUMENTSTRUCTURE          =
*     WHEREUSEDLIST              =
            .

* Tabelle sortieren
* jüngster Eintrag an erster Stelle
  SORT it_statuslog BY logdate DESCENDING logtime DESCENDING.

* ersten Eintrag für Status 80 suchen / STATUSINTERN
  CLEAR f_found.
  LOOP AT it_statuslog INTO wa_statuslog
    WHERE statusintern = '80'
    OR statusintern = '70'
    .
    index = sy-tabix.
    f_found = 'X'.
    EXIT.
  ENDLOOP.

  IF f_found = 'X'.
  ELSE.
    CLEAR o_stempel_wert.
    EXIT.
  ENDIF.

* Testen, es davor einen Status gab, welcher 35 war
* (zurückgewiesen)
  CLEAR index_found_80.
  index_found_80 = index.
  CLEAR f_found_35.

  LOOP AT it_statuslog INTO wa_statuslog
    TO index_found_80.
    IF wa_statuslog-statusintern = '35'.
      f_found_35 = 'X'.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.

  IF f_found_35 = 'X'.
    CLEAR o_stempel_wert.
    EXIT.
  ELSE.
  ENDIF.

* Eintrag für Status 80 lesen und Rückgabewert zusammensetzen
  READ TABLE it_statuslog INTO wa_statuslog INDEX index_found_80.

  CLEAR datum.
  CALL FUNCTION 'DATUMSAUFBEREITUNG'
    EXPORTING
*     FLAGM                 = ' '
*     FLAGW                 = ' '
      idate                 = wa_statuslog-logdate
*     IMONT                 = ' '
*     IWEEK                 = ' '
    IMPORTING
*     MDAT4                 =
*     MDAT6                 =
*     TDAT4                 =
*     TDAT6                 =
      tdat8                 = datum
*     WDAT4                 =
*     WDAT6                 =
    EXCEPTIONS
      datfm_ungueltig       = 1
      datum_ungueltig       = 2
      OTHERS                = 3
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Dokumentenstatustext lesen
  SELECT SINGLE * FROM tdwst
    INTO wa_tdwst
    WHERE cvlang = sy-langu
    AND dokst = wa_statuslog-statusintern
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CONCATENATE datum wa_tdwst-dostx
    INTO o_stempel_wert
    SEPARATED BY space.

*  o_stempel_wert = datum.



ENDFUNCTION.
