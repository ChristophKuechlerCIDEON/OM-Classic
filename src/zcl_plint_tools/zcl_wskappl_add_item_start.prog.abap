*&---------------------------------------------------------------------*
*& Report  ZCL_WSKAPPL_ADD_ITEM_START                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 02.12.2002 Umarbeitung
*-----------------------------------------------------------------------
REPORT  zcl_wskappl_add_item_start    .

*ITAB
DATA: itab_objects TYPE TABLE OF pdm_exp_objects.
*WA
DATA: wa_objects TYPE pdm_exp_objects.
*NORMAL
TABLES: draw.

DATA: BEGIN OF intdraz OCCURS 0.
        INCLUDE STRUCTURE draz.
DATA: END OF intdraz.
DATA: pfad(140).
DATA: textname LIKE thead-tdname.
DATA: applikationsnummer.
DATA: applikationstyp.
DATA: display.

IMPORT draw intdraz pfad applikationsnummer applikationstyp
FROM MEMORY ID 'SAP_APPLICATION'.

* Tabelle füllen
REFRESH itab_objects.
CLEAR wa_objects.

wa_objects-object_type = 'DOCUMENT'.
wa_objects-doknr = draw-doknr.
wa_objects-dokar = draw-dokar.
wa_objects-dokvr = draw-dokvr.
wa_objects-doktl = draw-doktl.

APPEND wa_objects TO itab_objects.


* CALL PSB Funktionalität

CALL FUNCTION 'Z_CL_PSBRW_CALL_PLOT_ADD_ITEM'
  EXPORTING
    function               = 'ZCL_WSKAPPL_ADD_ITEM_START'
  TABLES
    selected_objects       = itab_objects
 EXCEPTIONS
   ERROR                  = 1
   OTHERS                 = 2
          .
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ELSE.
  CALL FUNCTION 'Z_CL_PSBRW_CALL_PLOT_ALONE_QUE'
    EXPORTING
      function               = 'ZCL_WSKAPPL_ADD_ITEM_START'
    TABLES
      selected_objects       = itab_objects
 EXCEPTIONS
   ERROR                  = 1
   OTHERS                 = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDIF.
