class /CIDEON/CL_PLOT_BO_BUS2105 definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2105
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~DISPLAY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2105
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2105
*"* do not include other source files here!!!
private section.

  data BANFNR type BANFN .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2105 IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
************************************************************************
* Beschreibung: Ermittlung der Objekte einer Bestellanforderung. Der
*               Benutzer kann Bestellpositionen selektiert haben.
*
* Autor:        Heiko Hänsel
* Angelegt am:  29.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: ln_tcode      TYPE i,
        lt_models     TYPE mmpur_models,
        ls_obj_key    TYPE pdm_exp_objects,
        lt_obj_key    TYPE /cideon/t_pdm_objects,
        lo_framework  TYPE REF TO cl_framework_mm,
        lo_req_view   TYPE REF TO cl_screen_view_mm,
        lo_model      TYPE REF TO object,
        banfpos       TYPE REF TO /cideon/cl_plot_bo_bus2105_pos,
        banfposnr     TYPE bnfpo,
        materialnr    TYPE matnr,
        materialbez   TYPE txz01,
        poskey        TYPE string,
        purreq_data   TYPE mereq_header,
        purreq        TYPE REF TO if_purchase_requisition,
        tree_item     TYPE REF TO /cideon/cl_ui_tree_item,
        child_level   TYPE i.

  FIELD-SYMBOLS:
        <l_model>   TYPE mmpur_model_type,
        <l_selection> TYPE /cideon/t_banf_sel,
        <l_sel_entry> TYPE /cideon/s_banf_sel,
        <l_positions> TYPE /cideon/t_banf_pos,
        <l_pos_entry> TYPE ebanw.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* Level der nächsten Ebene berechnen
  child_level = current_level - 1.

* Soll das aktuelle Objekt "Bestellanforderung" im Selektionsbaum
* erscheinen?
  IF display = seox_true.
*   TODO: Noch nicht implementiert, da die Bestellanforderung bisher nur
*         Einstiegsobjekt ist.
  ELSE.
    tree_item = parent_item.    " Parent item ist INITIAL
  ENDIF.

* Abhängig von der Transaktion die Objekte der Banf ermitteln.
  ln_tcode = strlen( syst-tcode ).
  IF ln_tcode = 5.
*   ********************************************************************
*   Neue Transaktion mit Framework ME5xN.

*   Referenz auf das MM GUI Framework holen
    CALL METHOD cl_framework_mm=>get_instance
                  IMPORTING ex_instance = lo_framework.

*   Referenz auf den GRID View für die Bestellpositionen besorgen
    CALL METHOD lo_framework->get_view
                  EXPORTING im_prog  = 'SAPLMEGUI'
                            im_dynnr = '3212'
                  IMPORTING ex_view  = lo_req_view.

*   Hole die selektierten Bestellpositionen
    CALL METHOD
        lo_req_view->('IF_MULTIPLE_MODEL_HOLDER_MM~GET_SELECTED_MODELS')
          RECEIVING re_models = lt_models.

*   Prüfen, ob mindestens eine Bestellposition selektiert wurde.
    IF lt_models IS INITIAL.
      MESSAGE i000(/cideon/plot_service) RAISING nothing_found.
    ENDIF.

*   Aus den Bestellpositionen die Materialnummern extrahieren.
    LOOP AT lt_models ASSIGNING <l_model>.
*     Jedes Element ist ein Objekt der Klasse (MEREQ)LCL_REQ_ITEM
      lo_model = <l_model>-model.

*     Attribute der Position besorgen
      CALL METHOD lo_model->('GET_BNFPO')
                    RECEIVING re_bnfpo = banfposnr.

      CALL METHOD
        lo_model->('IF_PURCHASE_REQUISITION_ITEM~GET_REQUISITION')
                    RECEIVING re_requisition = purreq.
      CALL METHOD purreq->get_data
                    RECEIVING re_data = purreq_data.

*     Business Objekt für Bestellposition erzeugen
      CREATE OBJECT banfpos
        EXPORTING banfnr = purreq_data-banfn
                  position = banfposnr.

*     Zugehöriges Material gleich mit übergeben
      CALL METHOD lo_model->('GET_MATNR')
                    RECEIVING re_matnr = materialnr.
      CALL METHOD lo_model->('GET_TXZ01')
                    RECEIVING re_txz01 = materialbez.
      CALL METHOD banfpos->set_material
        EXPORTING materialnr = materialnr
                  materialbez = materialbez.

*     Position als referenziertes Objekt merken
      poskey = banfpos->/cideon/if_plot_bo~get_key( ).
      CALL METHOD /cideon/if_plot_bo~related_objects->add
        EXPORTING key = poskey
                  obj = banfpos.

*     Untergeordnete Objekte ermitteln
      CALL METHOD banfpos->/cideon/if_plot_bo~acquire_objects
        EXPORTING current_level = child_level
                  selection_tree = selection_tree
                  parent_item = tree_item.
    ENDLOOP.
  ELSE.
*   ********************************************************************
*   Alte Transaktion ME5x

*   Tabellen aus dem aufrufendem Rahmenprogramm holen
    ASSIGN ('(SAPMM06B)SEL[]') TO <l_selection>." Selektierte Positionen
    ASSIGN ('(SAPMM06B)BSN[]') TO <l_positions>." Alle Positionen
    IF <l_selection> IS INITIAL.
*     Falls keine Positionen markiert wurden, Nachricht anzeigen.
      MESSAGE i000(/cideon/plot_service) RAISING nothing_found.
    ENDIF.

*   Detaildaten zu den selektierten Einträgen lesen
    LOOP AT <l_selection> ASSIGNING <l_sel_entry>.
      READ TABLE <l_positions> ASSIGNING <l_pos_entry>
        WITH KEY bnfpo = <l_sel_entry>-bnfpo.

*     Business Objekt für Bestellposition erzeugen
      CREATE OBJECT banfpos
        EXPORTING banfnr = <l_pos_entry>-banfn
                  position = <l_pos_entry>-bnfpo.

*     Zugehöriges Material gleich mit übergeben
      CALL METHOD banfpos->set_material
        EXPORTING materialnr = <l_pos_entry>-matnr
                  materialbez = <l_pos_entry>-txz01.

*     Position als referenziertes Objekt merken
      poskey = banfpos->/cideon/if_plot_bo~get_key( ).
      CALL METHOD /cideon/if_plot_bo~related_objects->add
        EXPORTING key = poskey
                  obj = banfpos.

*     Untergeordnete Objekte ermitteln
      CALL METHOD banfpos->/cideon/if_plot_bo~acquire_objects
        EXPORTING current_level = child_level
                  selection_tree = selection_tree
                  parent_item = tree_item.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects.
*& Beschreibung: Positionen der Bestellanforderung ermitteln
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  09.09.2005   HAENSEL  Material nur an die Position übergeben, wenn
*&                        es wirklich ein Material und keine Dienstl.
*&                        ist.
*&----------------------------------------------------------------------

  DATA: lt_items TYPE TABLE OF bapieban,
        lc_key   TYPE string,
        lo_item  TYPE REF TO /cideon/cl_plot_bo_bus2105_pos.

  FIELD-SYMBOLS: <ls_item>  TYPE bapieban.

  CALL FUNCTION 'BAPI_REQUISITION_GETDETAIL'
    EXPORTING
      number                               = me->banfnr
*     ACCOUNT_ASSIGNMENT                   = ' '
*      ITEM_TEXTS                           = abap_bool
*     SERVICES                             = ' '
*     SERVICE_TEXTS                        = ' '
    TABLES
      requisition_items                    = lt_items.

  LOOP AT lt_items ASSIGNING <ls_item>.
    CREATE OBJECT lo_item
      EXPORTING
        banfnr    = me->banfnr
        position  = <ls_item>-preq_item.

*   Wenn eine Dienstleistung statt einem Material in der Position
*   eingetragen ist, dann gibt es unter der Position keine weiteren
*   Objekte.
    IF NOT <ls_item>-material IS INITIAL.
      CALL METHOD lo_item->set_material
        EXPORTING
          materialnr  = <ls_item>-material
          materialbez = <ls_item>-short_text.
    ENDIF.

    lc_key = <ls_item>-preq_item.
    CALL METHOD related_objects->add
      EXPORTING
        key = lc_key
        obj = lo_item.
  ENDLOOP.

ENDMETHOD.


method /CIDEON/IF_PLOT_BO~AQUIRE_OBJECTS.
* ...
endmethod.


METHOD /cideon/if_plot_bo~display.
*& Beschreibung: Da die Bestellanforderung selbst keine Dokumentver-
*&               knüpfungen hat, brauch sie auch nicht mit im
*&               Selektionsdialog angezeigt werden.
*&
*& Autor:        HAENSEL
*& Angelegt am:  08.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rb_display = abap_false.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_key.
************************************************************************
* Beschreibung: Erstellung des Schlüssels für die Bestellanforderung
*
* Autor:        Heiko Hänsel
* Angelegt am:  30.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  key = banfnr.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_OBJECTS.
* ...
endmethod.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Als angezeigter Text wird die Bestellanforderungsnr.
*&               verwendet.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = me->banfnr.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
************************************************************************
* Beschreibung: Übernahme der Bestellanforderungsnummer
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  me->banfnr = objkey.

ENDMETHOD.


METHOD constructor .
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 16:08:53
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.

  me->/cideon/if_plot_bo~name = 'BUS2105'.

ENDMETHOD.


method CREATE_SUPPORTED_DLTS.
*& Beschreibung: Es werden keine Dokumentverknüpfungen unterstüzt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
endmethod.
ENDCLASS.
