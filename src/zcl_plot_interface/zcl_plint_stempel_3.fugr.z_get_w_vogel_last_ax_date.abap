FUNCTION Z_GET_W_VOGEL_LAST_AX_DATE.
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
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.04.2005 - Erstellung
* 12.11.2005 - Kopie
*-----------------------------------------------------------------------
* A-TEX aus Statuslog DIS / Datum
*
*-----------------------------------------------------------------------


*ITAB
  DATA: itab_status TYPE TABLE OF bapi_doc_drap.
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: return TYPE bapiret2.
  DATA: wa_status TYPE bapi_doc_drap.
*NORMAL
  DATA: index TYPE i.

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

* alles rauswerfen, was nicht GS ist
  LOOP AT itab_status INTO wa_status.
    index = sy-tabix.
    IF wa_status-statusintern = 'A1'
      OR wa_status-statusintern = 'A2'
      OR wa_status-statusintern = 'A3'
      OR wa_status-statusintern = 'A4'
    .
    ELSE.
      DELETE itab_status INDEX index.
    ENDIF.
  ENDLOOP.

* leere Tabelle
  IF itab_status[] IS INITIAL.
    CLEAR o_stempel_wert.
    EXIT.
  ELSE.
  ENDIF.

* Sortieren
  SORT itab_status BY logdate DESCENDING logtime DESCENDING.

* ersten Statuswert lesen
  CLEAR wa_status.
  READ TABLE itab_status INTO wa_status INDEX 1.

  o_stempel_wert = wa_status-logdate.


*  o_stempel_wert = wa_plotjob-ebeln.


ENDFUNCTION.
