FUNCTION /cideon/make_sel_for_original.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOT_ITEM) LIKE  /CIDEON/_S_ADM_01 STRUCTURE
*"        /CIDEON/_S_ADM_01
*"  EXPORTING
*"     VALUE(O_WA_PLOT_ITEM) LIKE  /CIDEON/_S_ADM_01 STRUCTURE
*"        /CIDEON/_S_ADM_01
*"  EXCEPTIONS
*"      ERROR
*"      NO_SELECTION
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 10.12.2003 - Erstellung
* 10.07.2006 - Änderungen wegen Länge des Views auf UNICODE
*-----------------------------------------------------------------------

*TYPES
*TABLES
*ITAB

*WA
  DATA: return TYPE bapiret2.
*NORMAL



* für den DIS verfügbare Originale anzeigen.
  CLEAR return.
  CLEAR itab_documentfiles.

  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = i_wa_plot_item-dokar
      documentnumber             = i_wa_plot_item-doknr
      documentpart               = i_wa_plot_item-doktl
      documentversion            = i_wa_plot_item-dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
*     GETSTATUSLOG               = ' '
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
*     STATUSLOG                  =
      documentfiles              = itab_documentfiles
*     COMPONENTS                 =
*     CHARACTERISTICVALUES       =
*     CLASSALLOCATIONS           =
*     DOCUMENTSTRUCTURE          =
*     WHEREUSEDLIST              =
            .

  IF return IS INITIAL.
  ELSE.
    RAISE error.
  ENDIF.

* Aufbereiten der Tabelle mit Dokumentenschlüsseln
  LOOP AT itab_documentfiles INTO wa_documentfiles.
    wa_documentfiles-documenttype = i_wa_plot_item-dokar.
    wa_documentfiles-documentnumber = i_wa_plot_item-doknr.
    wa_documentfiles-documentpart = i_wa_plot_item-doktl.
    wa_documentfiles-documentversion = i_wa_plot_item-dokvr.
    MODIFY itab_documentfiles FROM wa_documentfiles INDEX sy-tabix.
  ENDLOOP.

  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 80 20 .

  IF wa_documentfiles IS INITIAL.
    CLEAR o_wa_plot_item.
    RAISE no_selection.
  ELSE.
    CLEAR o_wa_plot_item.
    o_wa_plot_item-checked = wa_documentfiles-checkedin.
    o_wa_plot_item-filep = wa_documentfiles-docfile.
    o_wa_plot_item-filename = wa_documentfiles-docfile .
    o_wa_plot_item-description = wa_documentfiles-description.
    CLEAR o_wa_plot_item-knz_fehl_blatt.
    o_wa_plot_item-wsapplication = wa_documentfiles-wsapplication .
    o_wa_plot_item-application_id = wa_documentfiles-application_id .
    o_wa_plot_item-file_id = wa_documentfiles-file_id .
    o_wa_plot_item-originaltype = wa_documentfiles-originaltype.
  ENDIF.


ENDFUNCTION.
