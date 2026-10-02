FUNCTION z_get_sig_madaus_60_sign.
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
* 31.01.2005 - Erstellung
*              Prüfer / setzt Status 60
*              Datum + Name / Madaus
* 28.02.1005 - Lesen aus Signatur
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_signs_dms_tab TYPE TABLE OF rc77b.
  DATA: it_statuslog TYPE TABLE OF bapi_doc_drap.
  DATA: it_signs_dms_tab TYPE TABLE OF rc77b.
*WA
  DATA: wa_draw TYPE draw.
  DATA: wa_plotjob TYPE zcl_s_plotlist.

  DATA: wa_statuslog TYPE bapi_doc_drap.
  DATA: return TYPE bapiret2.
  DATA: wa_signs_dms_tab TYPE rc77b.
  DATA: wa_signs_dms_tab2 TYPE rc77b.
  DATA: wa_key_dms_imp TYPE rc77.

*NORMAL
  DATA: f_found.
  DATA: index TYPE i.
  DATA: index_found_60 TYPE i.
  DATA: f_found_35.
  DATA: datum(10).

  DATA: lines TYPE i.
  DATA: delta_zeit TYPE tims.
  DATA: delta_zeit2 TYPE tims.
  DATA: f_first.


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

* ersten Eintrag für Status 60 suchen / STATUSINTERN
  CLEAR f_found.
  LOOP AT it_statuslog INTO wa_statuslog
    WHERE statusintern = '60'
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
  CLEAR index_found_60.
  index_found_60 = index.
  CLEAR f_found_35.

  LOOP AT it_statuslog INTO wa_statuslog
    TO index_found_60.
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

* Eintrag für Status 60 lesen und Rückgabewert zusammensetzen
  READ TABLE it_statuslog INTO wa_statuslog INDEX index_found_60.

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


  CONCATENATE datum wa_statuslog-username
    INTO o_stempel_wert
    SEPARATED BY space.

*  o_stempel_wert = datum.

* Signatur lesen / Signator mglw. unterschiedlich zu Benutzer
* der Statuslog setzt
  CLEAR wa_key_dms_imp.
  wa_key_dms_imp-dokar = wa_plotjob-dokar.
  wa_key_dms_imp-doknr = wa_plotjob-doknr.
  wa_key_dms_imp-doktl = wa_plotjob-doktl.
  wa_key_dms_imp-dokvr = wa_plotjob-dokvr.

  CLEAR it_signs_dms_tab.

  CALL FUNCTION 'SIGN_READ'
    EXPORTING
      object_imp                      = '60'
*     KEY_CHORD_IMP                   =
*     KEY_LOT_IMP                     =
*     KEY_SHEET_IMP                   =
*     KEY_EBR_IMP                     =
*     KEY_CHOBJ_IMP                   =
      key_dms_imp                     = wa_key_dms_imp
*     KEY_PNNR_IMP                    =
*     FLG_READ_MODE_IMP               =
    TABLES
*     SIGNS_CHORD_TAB                 =
*     SIGNS_LOT_TAB                   =
*     SIGNS_SHEET_TAB                 =
*     SIGNS_EBR_TAB                   =
*     SIGNS_CHOBJ_TAB                 =
      signs_dms_tab                   = it_signs_dms_tab
*     SIGNS_PNNR_TAB                  =
    EXCEPTIONS
      key_for_object_incomplete       = 1
      no_signatures_found             = 2
      OTHERS                          = 3
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* nach Eintrag für diesen Status und Tag suchen.
* Sign Zeit sollte immer größer sein, als LOG Zeit
  LOOP AT it_signs_dms_tab INTO wa_signs_dms_tab.
    index = sy-tabix.
    IF wa_signs_dms_tab-dokst = wa_statuslog-statusintern
      AND wa_signs_dms_tab-sign_date = wa_statuslog-logdate
      AND wa_signs_dms_tab-sign_time >= wa_statuslog-logtime.
    ELSE.
      DELETE it_signs_dms_tab INDEX index.
    ENDIF.
  ENDLOOP.

* Anzahl der Einträge überprüfen
  CLEAR lines.
  DESCRIBE TABLE it_signs_dms_tab LINES lines.

  IF it_signs_dms_tab[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  IF lines = '1'.
*   eindeutig gefunden
    CLEAR o_stempel_wert.
    CLEAR datum.
    READ TABLE it_signs_dms_tab INTO wa_signs_dms_tab INDEX 1.
    datum = wa_signs_dms_tab-sign_date.
    CALL FUNCTION 'DATUMSAUFBEREITUNG'
         EXPORTING
              idate           = wa_signs_dms_tab-sign_date
         IMPORTING
              tdat8           = datum
         EXCEPTIONS
              datfm_ungueltig = 1
              datum_ungueltig = 2
              OTHERS          = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CONCATENATE datum wa_signs_dms_tab-signer
      INTO o_stempel_wert
      SEPARATED BY space.
    EXIT.
  ELSE.
  ENDIF.

* mehrere Einträge -> über Uhrzeit vereinzeln
  CLEAR delta_zeit.
  CLEAR delta_zeit2.
  CLEAR wa_signs_dms_tab.
  CLEAR wa_signs_dms_tab2.
  CLEAR f_first.
  f_first = 'X'.

  LOOP AT it_signs_dms_tab INTO wa_signs_dms_tab.
    IF f_first = 'X'.
      delta_zeit = wa_signs_dms_tab-sign_time - wa_statuslog-logtime.
      delta_zeit2 = delta_zeit.
      wa_signs_dms_tab2 = wa_signs_dms_tab.
      CLEAR f_first.
      CONTINUE.
    ELSE.
    ENDIF.

    delta_zeit = wa_signs_dms_tab-sign_time - wa_statuslog-logtime.

    IF delta_zeit <= delta_zeit2.
*     Updaten
      wa_signs_dms_tab2-sign_time = wa_signs_dms_tab-sign_time.
      delta_zeit2 = delta_zeit.
    ELSE.
    ENDIF.
  ENDLOOP.

  wa_signs_dms_tab = wa_signs_dms_tab2.

  CLEAR o_stempel_wert.
  CLEAR datum.
  datum = wa_signs_dms_tab-sign_date.
  CALL FUNCTION 'DATUMSAUFBEREITUNG'
       EXPORTING
            idate           = wa_signs_dms_tab-sign_date
       IMPORTING
            tdat8           = datum
       EXCEPTIONS
            datfm_ungueltig = 1
            datum_ungueltig = 2
            OTHERS          = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CONCATENATE datum wa_signs_dms_tab-signer
    INTO o_stempel_wert
    SEPARATED BY space.


ENDFUNCTION.
