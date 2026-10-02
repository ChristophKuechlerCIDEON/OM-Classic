FUNCTION /cideon/wv_last_nx_kf.
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
    WHERE statusintern = 'N1'
      OR statusintern = 'N2'
      OR statusintern = 'N3'
      OR statusintern = 'N4'
      OR statusintern = 'N5'
      OR statusintern = 'N6'
      OR statusintern = 'N7'
      OR statusintern = 'N8'
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
    IF wa_status_rang-statusintern = 'N1'
      OR wa_status_rang-statusintern = 'N2'
      OR wa_status_rang-statusintern = 'N3'
      OR wa_status_rang-statusintern = 'N4'
      OR wa_status_rang-statusintern = 'N5'
      OR wa_status_rang-statusintern = 'N6'
      OR wa_status_rang-statusintern = 'N7'
      OR wa_status_rang-statusintern = 'N8'
      .
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



  o_stempel_wert = wa_status_rang_save-username.

* Falls Wert gefüllt, dann soll auch der feste Text erscheinen
  IF o_stempel_wert IS INITIAL.
  ELSE.
    o_stempel_wert = text-004.
  ENDIF.


ENDFUNCTION.
