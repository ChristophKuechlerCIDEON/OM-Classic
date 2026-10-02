FUNCTION /cideon/wv_last_ex_date.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* ET aus Statuslog DIS / Datum
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
*-----------------------------------------------------------------------
* Abteilungsleiter aus Statuslog DIS / Datum
*
*-----------------------------------------------------------------------


*ITAB
  DATA: itab_status TYPE TABLE OF bapi_doc_drap.
  DATA: it_status_rang TYPE TABLE OF /cideon/_s_stmp_rng_drap.
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: return TYPE bapiret2.
  DATA: wa_status TYPE bapi_doc_drap.
  DATA: wa_status_rang TYPE /cideon/_s_stmp_rng_drap.
  DATA: wa_status_rang_next TYPE /cideon/_s_stmp_rng_drap.
  DATA: wa_status_rang_last TYPE /cideon/_s_stmp_rng_drap.
  DATA: wa_status_rang_save TYPE /cideon/_s_stmp_rng_drap.
  DATA: wa_status_rang_akt TYPE /cideon/_s_stmp_rng_drap.
*NORMAL
  DATA: index TYPE i.
  DATA: index_check TYPE i.
  DATA: f_found.
  DATA: f_ok.

  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.
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

* AL suchen
  CLEAR f_found.
  LOOP AT itab_status INTO wa_status
    WHERE statusintern = 'E1'
      OR statusintern = 'E2'
      OR statusintern = 'E3'
      OR statusintern = 'E4'.
    .
    f_found = 'X'.
  ENDLOOP.

  IF f_found = 'X'.
  ELSE.
*   Verlassen des FB
    CLEAR o_stempel_wert.
    EXIT.
  ENDIF.

  CALL FUNCTION '/CIDEON/MERGE_DRAP_RANG'
       EXPORTING
            i_dokar          = wa_plotjob-dokar
       TABLES
            i_it_status      = itab_status
            o_it_status_rang = it_status_rang
       EXCEPTIONS
            error            = 1
            OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   Verlassen des FB
    CLEAR o_stempel_wert.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR f_found.
  CLEAR f_ok.
  CLEAR wa_status_rang_last.
  CLEAR wa_status_rang_next.
  CLEAR wa_status_rang_save.
  CLEAR wa_status_rang_akt.
  LOOP AT it_status_rang INTO wa_status_rang.
    index = sy-tabix.
    IF wa_status_rang-statusintern = 'E1'
      OR wa_status_rang-statusintern = 'E2'
      OR wa_status_rang-statusintern = 'E3'
      OR wa_status_rang-statusintern = 'E4'.
*     nächsten Eintrag lesen
      index_check = index + 1.
      CLEAR wa_status_rang_next.
      READ TABLE it_status_rang INTO wa_status_rang_next
        INDEX index_check.
      IF sy-subrc NE 0.
*       nicht gefunden
      ELSE.
        IF wa_status_rang_next-rang > wa_status_rang-rang.
*         OK, nächster Status ist positiv
* CKR 20.02.06
*          wa_status_rang_save = wa_status_rang.
          wa_status_rang_save = wa_status_rang_next.
* CKR 20.02.06 ENDE
        ELSE.

        ENDIF.
      ENDIF.
    ELSE.
    ENDIF.
  ENDLOOP.


* Datum noch konvertieren
* Datum umrechnen
  DATA: datum_char TYPE char10.
  DATA: datum LIKE sy-datum.

  CLEAR datum_char.
  datum = wa_status_rang_save-logdate.

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
