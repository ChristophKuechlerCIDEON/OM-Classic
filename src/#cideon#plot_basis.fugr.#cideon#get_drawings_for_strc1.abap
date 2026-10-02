FUNCTION /CIDEON/GET_DRAWINGS_FOR_STRC1.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_DOKAR) TYPE  DOKAR
*"             VALUE(I_DOKNR) TYPE  DOKNR
*"             VALUE(I_DOKTL) TYPE  DOKTL_D
*"             VALUE(I_DOKVR) TYPE  DOKVR
*"             VALUE(I_KNZ_MULTILEVEL) TYPE  CHAR1
*"             VALUE(I_AENNR) TYPE  AENNR OPTIONAL
*"             VALUE(I_CCDAT) TYPE  CCDAT OPTIONAL
*"       TABLES
*"              O_ITAB_DRAW STRUCTURE  DRAW
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   -  holt Zeichnungen für die Elemente einer Stückliste
*   -
*-----------------------------------------------------------------------
* Journal
* 03.11.2003
*-----------------------------------------------------------------------

*TABLES
*TYPES
*ITAB
  DATA: itab_documentstructure TYPE TABLE OF bapi_doc_structure.
  DATA: itab_draw_work TYPE TABLE OF draw.
  DATA: itab_draw_drawing TYPE TABLE OF draw.
  DATA: itab_whereusedlist TYPE TABLE OF bapi_doc_structure.
*WA
  DATA: return TYPE bapiret2.
  DATA: wa_documentstructure TYPE bapi_doc_structure.
  DATA: wa_draw_work TYPE draw.
  DATA: wa_draw_drawing TYPE draw.
  DATA: wa_whereusedlist TYPE bapi_doc_structure.
*NORMAL
  DATA: res4 TYPE resdraw.
  DATA: akt_index TYPE i.

  CLEAR return.
  CLEAR itab_documentstructure.
  CLEAR wa_documentstructure.


  CALL FUNCTION 'BAPI_DOCUMENT_GETSTRUCTURE'
    EXPORTING
      documenttype              = i_dokar
      documentnumber            = i_doknr
      documentpart              = i_doktl
      documentversion           = i_dokvr
      multilevelexplosion       = i_knz_multilevel
      docbomchangenumber        = i_aennr
      docbomvalidfrom           = i_ccdat
*     DOCBOMREVISIONLEVEL       =
    IMPORTING
      return                    = return
    TABLES
      documentstructure         = itab_documentstructure
            .
  IF return IS INITIAL.
  ELSE.
  ENDIF.

  CLEAR itab_draw_work.
  CLEAR wa_draw_work.

  wa_draw_work-dokar = i_dokar.
  wa_draw_work-doknr = i_doknr.
  wa_draw_work-doktl = i_doktl.
  wa_draw_work-dokvr = i_dokvr.

  APPEND wa_draw_work TO itab_draw_work.

  LOOP AT itab_documentstructure INTO wa_documentstructure.
    CLEAR wa_draw_work.
    wa_draw_work-dokar = wa_documentstructure-documenttype.
    wa_draw_work-doknr = wa_documentstructure-documentnumber.
    wa_draw_work-doktl = wa_documentstructure-documentpart.
    wa_draw_work-dokvr = wa_documentstructure-documentversion.

    APPEND wa_draw_work TO itab_draw_work.

  ENDLOOP.

* Verwendungen holen
  CLEAR wa_draw_drawing.
  CLEAR itab_draw_drawing.

  LOOP AT itab_draw_work INTO wa_draw_work.
    CLEAR return.
    CLEAR itab_whereusedlist.

    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype               = wa_draw_work-dokar
        documentnumber             = wa_draw_work-doknr
        documentpart               = wa_draw_work-doktl
        documentversion            = wa_draw_work-dokvr
*       GETOBJECTLINKS             = ' '
*       GETCOMPONENTS              = ' '
*       GETSTATUSLOG               = ' '
*       GETLONGTEXTS               = ' '
*       GETACTIVEFILES             = 'X'
*       GETCLASSIFICATION          = ' '
*       GETSTRUCTURE               = ' '
        getwhereused               = 'X'
*       HOSTNAME                   = ' '
      IMPORTING
*       DOCUMENTDATA               =
        return                     = return
      TABLES
*       OBJECTLINKS                =
*       DOCUMENTDESCRIPTIONS       =
*       LONGTEXTS                  =
*       STATUSLOG                  =
*       DOCUMENTFILES              =
*       COMPONENTS                 =
*       CHARACTERISTICVALUES       =
*       CLASSALLOCATIONS           =
*       DOCUMENTSTRUCTURE          =
        whereusedlist              = itab_whereusedlist
              .

    IF return IS INITIAL.
    ELSE.
    ENDIF.

    LOOP AT itab_whereusedlist INTO wa_whereusedlist.
      CLEAR wa_draw_drawing.
      wa_draw_drawing-dokar = wa_whereusedlist-documenttype.
      wa_draw_drawing-doknr = wa_whereusedlist-documentnumber.
      wa_draw_drawing-doktl = wa_whereusedlist-documentpart.
      wa_draw_drawing-dokvr = wa_whereusedlist-documentversion.
      APPEND wa_draw_drawing TO itab_draw_drawing.
    ENDLOOP.


  ENDLOOP.


* alles aussortieren, was nicht Zeichnungen sind
  LOOP AT itab_draw_drawing INTO wa_draw_drawing.
    akt_index = sy-tabix.
    CLEAR res4.

    SELECT SINGLE res4 FROM draw INTO res4
      WHERE dokar = wa_draw_drawing-dokar
      AND doknr = wa_draw_drawing-doknr
      AND doktl = wa_draw_drawing-doktl
      AND dokvr = wa_draw_drawing-dokvr
      .
    IF sy-subrc NE 0.
    ELSE.
    ENDIF.

    IF res4+4 = 'D'.

    ELSE.
      DELETE itab_draw_drawing INDEX akt_index.
    ENDIF.

  ENDLOOP.


  CLEAR o_itab_draw.
  o_itab_draw[] = itab_draw_drawing[].

ENDFUNCTION.
