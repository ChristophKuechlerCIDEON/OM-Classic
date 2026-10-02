FUNCTION /cideon/get_stmp_longtxt_1.
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
* 02.10.2006 - Erstellung
*-----------------------------------------------------------------------
* Langtexte holen
*
*-----------------------------------------------------------------------


*ITAB
  DATA: it_longtext TYPE TABLE OF bapi_doc_text.
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: return TYPE bapiret2.
  DATA: wa_longtext TYPE bapi_doc_text.
*NORMAL
  DATA: anzahl TYPE i.
  DATA: count TYPE i.

  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  CLEAR o_stempel_wert.

  CLEAR return.
  CLEAR it_longtext.

  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = wa_plotjob-dokar
      documentnumber             = wa_plotjob-doknr
      documentpart               = wa_plotjob-doktl
      documentversion            = wa_plotjob-dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
*     GETSTATUSLOG               = ' '
      getlongtexts               = 'X'
      getactivefiles             = ''
      getdocdescriptions         = 'X'
      getdocfiles                = ''
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
      longtexts                  = it_longtext
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


* Zeile x zurückgeben
* alles rauswerfen, was nicht der benutzten Sprach entspricht

  DELETE it_longtext
    WHERE NOT language = sy-langu.

  CLEAR anzahl.
  DESCRIBE TABLE it_longtext LINES anzahl.

  count = 1.

  IF anzahl < count.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_longtext.
  READ TABLE it_longtext INTO wa_longtext INDEX count.

  o_stempel_wert = wa_longtext-textline.


ENDFUNCTION.
