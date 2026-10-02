FUNCTION z_cl_get_freigabe_datum_last.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* ITAB
  DATA: itab_tdws TYPE TABLE OF tdws.
  DATA: itab_statuslog TYPE TABLE OF bapi_doc_drap.
* WA
  DATA: wa_tdws TYPE tdws.
  DATA: return TYPE bapiret2.
  DATA: wa_statuslog TYPE bapi_doc_drap.
* NORMAL
  DATA: anzahl_fr_stati TYPE i.
  DATA: anzahl_statuslog TYPE i.
  DATA: counter_statuslog TYPE i.
  DATA: f_gefunden(1) VALUE ''.

* Freigabestatus für Dokumentenart holen
  CLEAR itab_tdws.
  CLEAR wa_tdws.

  SELECT * FROM tdws INTO TABLE itab_tdws
    WHERE dokar = i_wa_plotjobs-dokar
    AND frknz = 'X'
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

* Dokumentdaten holen
  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = i_wa_plotjobs-dokar
      documentnumber             = i_wa_plotjobs-doknr
      documentpart               = i_wa_plotjobs-doktl
      documentversion            = i_wa_plotjobs-dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
      getstatuslog               = 'X'
*     GETLONGTEXTS               = ' '
      getactivefiles             = 'X'
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
      statuslog                  = itab_statuslog
*     DOCUMENTFILES              =
*     COMPONENTS                 =
*     CHARACTERISTICVALUES       =
*     CLASSALLOCATIONS           =
*     DOCUMENTSTRUCTURE          =
*     WHEREUSEDLIST              =
            .

*  LOOP AT itab_statuslog INTO wa_statuslog.
*
*  ENDLOOP.

  DESCRIBE TABLE itab_statuslog LINES anzahl_statuslog.
  counter_statuslog = anzahl_statuslog.

  CLEAR f_gefunden.

  DO.
    IF counter_statuslog = 0.
      CLEAR wa_statuslog.
      EXIT.
    ELSE.
    ENDIF.

    READ TABLE itab_statuslog INTO wa_statuslog INDEX counter_statuslog.

    counter_statuslog = counter_statuslog - 1.

    LOOP AT itab_tdws INTO wa_tdws.
      IF wa_statuslog-statusintern = wa_tdws-dokst.
*       gefunden
        f_gefunden = 'X'.
        EXIT.
      ELSE.
      ENDIF.
    ENDLOOP.

    IF f_gefunden = 'X'.
      EXIT.
    ELSE.
    ENDIF.

    IF counter_statuslog = 0.
      CLEAR wa_statuslog.
      EXIT.
    ELSE.
    ENDIF.
  ENDDO.


* Datum umrechnen
  DATA: datum_char TYPE char10.
  DATA: datum LIKE sy-datum.

  datum = wa_statuslog-logdate .

  CALL FUNCTION 'DATUMSAUFBEREITUNG'
    EXPORTING
*     FLAGM                 = ' '
*     FLAGW                 = ' '
      idate                 = datum
*     IMONT                 = ' '
*     IWEEK                 = ' '
    IMPORTING
*     MDAT4                 =
*     MDAT6                 =
*     TDAT4                 =
*      tdat6                 = datum
      tdat8                 = datum_char
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


  o_stempel_wert = datum_char.


ENDFUNCTION.
