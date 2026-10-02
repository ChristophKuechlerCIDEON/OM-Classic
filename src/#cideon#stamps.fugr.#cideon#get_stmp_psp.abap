FUNCTION /CIDEON/GET_STMP_PSP .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* Autor: Christoph Küchler
*        chris@christoph-kuechler.de
*"----------------------------------------------------------------------
* 20.10.2006 - Geburtstag Marco Peschel 33
*              Kopie
*
*"----------------------------------------------------------------------
  DATA: it_objectlinks TYPE TABLE OF bapi_doc_drad.
  DATA: wa_objectlinks TYPE bapi_doc_drad.
  DATA: wa_prps TYPE prps.

  DATA: return TYPE bapiret2.


  CLEAR return.
  CLEAR it_objectlinks.
  CLEAR wa_objectlinks.

  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = i_wa_plotjobs-dokar
      documentnumber             = i_wa_plotjobs-doknr
      documentpart               = i_wa_plotjobs-doktl
      documentversion            = i_wa_plotjobs-dokvr
      getobjectlinks             = 'X'
*     GETCOMPONENTS              = ' '
*     GETSTATUSLOG               = ' '
*     GETLONGTEXTS               = ' '
      getactivefiles             = ' '
      getdocdescriptions         = ' '
      getdocfiles                = ' '
*     GETCLASSIFICATION          = ' '
*     GETSTRUCTURE               = ' '
*     GETWHEREUSED               = ' '
*     HOSTNAME                   = ' '
    IMPORTING
*     DOCUMENTDATA               =
      return                     = return
    TABLES
      objectlinks                = it_objectlinks
*     DOCUMENTDESCRIPTIONS       =
*     LONGTEXTS                  =
*     STATUSLOG                  =
*     DOCUMENTFILES              =
*     COMPONENTS                 =
*     CHARACTERISTICVALUES       =
*     CLASSALLOCATIONS           =
*     DOCUMENTSTRUCTURE          =
*     WHEREUSEDLIST              =
            .

  IF return IS INITIAL.
  ELSE.
    CLEAR o_stempel_wert.
    EXIT.
  ENDIF.

* alles Rauswerfen, was nicht PRPS ist
  LOOP AT it_objectlinks INTO wa_objectlinks.
    IF wa_objectlinks-objecttype = 'PRPS'.
    ELSE.
      DELETE it_objectlinks INDEX sy-tabix.
    ENDIF.
  ENDLOOP.


* mit Objektschlüssel aus der PRPS die POSKI holen
  CLEAR o_stempel_wert.
  LOOP AT it_objectlinks INTO wa_objectlinks.
    SELECT SINGLE * FROM prps INTO wa_prps
      WHERE pspnr = wa_objectlinks-objectkey
      .

    IF sy-subrc NE 0.
    ELSE.
      CONCATENATE o_stempel_wert
        wa_prps-poski
        '/'
        INTO o_stempel_wert.
    ENDIF.

  ENDLOOP.

*  o_stempel_wert = .


ENDFUNCTION.
