FUNCTION /cideon/chk_doc_charvalue.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(WA_CHARVALUE) TYPE  BAPI_CHARACTERISTIC_VALUES
*"     REFERENCE(WA_DRAW) TYPE  DRAW
*"  EXCEPTIONS
*"      ERROR
*"      FOUND
*"      NOT_FOUND
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 06.08.2007 - SP 45
*              Erstellung
*-----------------------------------------------------------------------
* toDo
*   auf initiale Werte achten
*-----------------------------------------------------------------------
*ITAB
  DATA: it_char TYPE TABLE OF bapi_characteristic_values.
*WA
  DATA: return TYPE bapiret2.
  DATA: wa_char TYPE bapi_characteristic_values.
*NORMAL
  DATA: f_found.


  CLEAR return.
  CLEAR it_char.
  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = wa_draw-dokar
      documentnumber             = wa_draw-doknr
      documentpart               = wa_draw-doktl
      documentversion            = wa_draw-dokvr
*   GETOBJECTLINKS             = ' '
*   GETCOMPONENTS              = ' '
*   GETSTATUSLOG               = ' '
*   GETLONGTEXTS               = ' '
    getactivefiles             = ''
    getdocdescriptions         = ''
    getdocfiles                = ''
    getclassification          = 'X'
*   GETSTRUCTURE               = ' '
*   GETWHEREUSED               = ' '
*   HOSTNAME                   = ' '
    IMPORTING
*   DOCUMENTDATA               =
      return                     = return
  TABLES
*   OBJECTLINKS                =
*   DOCUMENTDESCRIPTIONS       =
*   LONGTEXTS                  =
*   STATUSLOG                  =
*   DOCUMENTFILES              =
*   COMPONENTS                 =
    characteristicvalues       = it_char
*   CLASSALLOCATIONS           =
*   DOCUMENTSTRUCTURE          =
*   WHEREUSEDLIST              =
            .

  IF return IS INITIAL.
  ELSE.
    RAISE error.
  ENDIF.

  CLEAR f_found.

  LOOP AT it_char INTO wa_char
    WHERE charname = wa_charvalue-charname
    .
  ENDLOOP.
  IF sy-subrc NE 0.
*   nicht gefunden
    IF wa_charvalue-charvalue IS INITIAL.
      RAISE found.
    ELSE.
      RAISE not_found.
    ENDIF.
  ELSE.
*   gefunden
    IF wa_char-charvalue = wa_charvalue-charvalue.
      RAISE found.
    ELSE.
      RAISE not_found.
    ENDIF.
  ENDIF.



ENDFUNCTION.
