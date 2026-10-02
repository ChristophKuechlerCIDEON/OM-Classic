*&---------------------------------------------------------------------*
*& Report  /CIDEON/SEL_TO_CONVERT                                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 17.03.2004 - Kopie
* 08.03.2005 - Integration Konvertierungsregel / DAPPL
* 18.04.2005 - Konvertierung mit Dokumentenstückliste / CONV04
*-----------------------------------------------------------------------


REPORT  /cideon/sel_to_convert       .

* CONTROLS
DATA: custom_control_alv TYPE REF TO cl_gui_custom_container.
* ALV
DATA: alv_ergebnisse TYPE REF TO cl_gui_alv_grid.
*LAYOUT
DATA: g_layo_alv_ergebnisse TYPE lvc_s_layo.
*LVC_T_ROW
DATA: itab_et_index_rows_ergebnisse TYPE lvc_t_row.

DATA: wa_et_index_rows_ergebnisse TYPE lvc_s_row.

* KLassen
CLASS lcl_event_handler_alv DEFINITION DEFERRED.
* HANDLER
DATA: alv_handler TYPE REF TO lcl_event_handler_alv.

* TABLES

* TYPES
* ITAB
DATA: itab_ptx_draw TYPE TABLE OF draw.
DATA: itab_ptx_draw_sel TYPE TABLE OF draw.

* WA
DATA: wa_ptx_draw TYPE draw.
DATA: wa_ptx_draw_sel TYPE draw.
* NORMAL
DATA: ok_code LIKE sy-ucomm.
DATA: anzahl_ergebnisse TYPE i.

DATA:  gs_layout_searchlist TYPE disvariant.
DATA:  x_save_searchlist VALUE 'A'.

DATA: index_itab_alv TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-010.
PARAMETERS: rcv04n RADIOBUTTON GROUP rsel DEFAULT 'X'.
PARAMETERS: rnorm RADIOBUTTON GROUP rsel.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-011.
PARAMETERS: ralv RADIOBUTTON GROUP rtab DEFAULT 'X'.
PARAMETERS: rdb RADIOBUTTON GROUP rtab .
SELECTION-SCREEN END OF BLOCK bl2.


SELECTION-SCREEN BEGIN OF BLOCK bl4 WITH FRAME TITLE text-016.
PARAMETERS: rconv02 RADIOBUTTON GROUP rcnv DEFAULT 'X'.
PARAMETERS: rconv04 RADIOBUTTON GROUP rcnv .
SELECTION-SCREEN END OF BLOCK bl4.


SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-015.
PARAMETERS: rconv AS CHECKBOX DEFAULT ''.
PARAMETERS: wsappl   TYPE tdwp-dappl DEFAULT 'PDF'.
PARAMETERS: convers  TYPE convert_spec-name.
SELECTION-SCREEN END OF BLOCK bl3.


DATA: r_in_itb(1) VALUE 'X'.
DATA: r_in_db(1) VALUE ''.

INITIALIZATION.

  CLEAR itab_ptx_draw.
  CLEAR wa_ptx_draw.


START-OF-SELECTION.


* Suche über DRAW
  IF rcv04n = 'X'.
*   Standardsuche
    PERFORM call_cv04n.
  ELSE.
*   Suche nach eigenen Kriterien
    PERFORM call_cv04n.

  ENDIF.


  DESCRIBE TABLE itab_ptx_draw LINES anzahl_ergebnisse .

  IF anzahl_ergebnisse > 0.
*   Anzeige / Übernahme in Ergebnistabelle
    IF ralv = 'X'.
      CALL SCREEN 100.
    ELSE.
*     Tabelle komplett übernehmen
      CLEAR itab_ptx_draw_sel.
      itab_ptx_draw_sel[] = itab_ptx_draw[].
    ENDIF.

*   Tabellen freigeben -> Speicher
    CLEAR itab_ptx_draw.


*   Konvertierung starten
    LOOP AT itab_ptx_draw_sel INTO wa_ptx_draw_sel.

      IF rconv02 = 'X'.
*       normale Konvertierung über CONV02
        IF rconv = 'X'.
          SUBMIT conv_convert_document AND RETURN
            WITH dokar = wa_ptx_draw_sel-dokar
            WITH doknr = wa_ptx_draw_sel-doknr
            WITH doktl = wa_ptx_draw_sel-doktl
            WITH dokvr = wa_ptx_draw_sel-dokvr
*          WITH dokst = wa_ptx_draw_sel-dokst
            WITH wsappl =  wsappl
            WITH convers = convers
            .
        ELSE.
          SUBMIT conv_convert_document AND RETURN
            WITH dokar = wa_ptx_draw_sel-dokar
            WITH doknr = wa_ptx_draw_sel-doknr
            WITH doktl = wa_ptx_draw_sel-doktl
            WITH dokvr = wa_ptx_draw_sel-dokvr
            WITH dokst = wa_ptx_draw_sel-dokst
            .
        ENDIF.
      ELSE.
*       Konvertierung über CONV04
        SUBMIT conv_convert_doc_structure
          AND RETURN
          WITH dokar = wa_ptx_draw_sel-dokar
          WITH doknr = wa_ptx_draw_sel-doknr
          WITH doktl = wa_ptx_draw_sel-doktl
          WITH dokvr = wa_ptx_draw_sel-dokvr.
      ENDIF.

    ENDLOOP.


  ELSE.
    MESSAGE s024(/cideon/tools)
      WITH '' '' '' ''.
*   keine Einträge bei Suche gefunden & & & &

  ENDIF.

  INCLUDE /cideon/sel_to_convert_class.

  INCLUDE /cideon/sel_to_convert_const.
  INCLUDE /cideon/sel_to_convert_f1.
  INCLUDE /cideon/sel_to_convert_pbo100.
  INCLUDE /cideon/sel_to_convert_pai100.
  INCLUDE /cideon/sel_to_convert_pbo200.
  INCLUDE /cideon/sel_to_convert_pai200.
  INCLUDE /cideon/sel_to_convert_f2.
