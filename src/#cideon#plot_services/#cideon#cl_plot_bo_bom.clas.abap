class /CIDEON/CL_PLOT_BO_BOM definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO_BILL
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BOM
*"* do not include other source files here!!!
public section.

  data USAGE type STLAN read-only .
  data PLANT type WERKS read-only .
  data MATERIALNR type MATNR read-only .

  methods CONSTRUCTOR
    importing
      !MATERIAL type ref to /CIDEON/CL_PLOT_BO_BUS1001
      !PLANT type WERKS
      !USAGE type STLAN
      !NUMBER type STNUM
      !ALTERNATIVE type STALT
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_BO_BOM
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BOM
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BOM IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
************************************************************************
* Beschreibung: Fügt die Materialstückliste in die Baumstruktur ein
*               und ermittelt die Positionen der Materialstückliste.
*
* Autor:        Heiko Hänsel
* Angelegt am:  30.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: text         TYPE string,
        tree_item    TYPE REF TO /cideon/cl_ui_tree_item.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* Text für die Anzeige im Selektionsbaum erstellen und in die Baum-
* struktur einfügen.
  CONCATENATE materialnr plant usage alternative
    INTO text SEPARATED BY space.

*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = text
*              io_parent  = parent_item
*              if_enabled = seox_true
*              if_visible = seox_true
*              iv_image   =
*                 /cideon/cl_plot_bo_bom=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_bom=>icon
*              io_ext_key = me
*     RECEIVING ro_item   = tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING tree_item = tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

ENDMETHOD.


METHOD /cideon/if_plot_bo~get_key.
************************************************************************
* Beschreibung: Schlüssel für die Materialstückliste erzeugen.
*
* Autor:        Heiko Hänsel
* Angelegt am:  30.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  CONCATENATE materialnr plant usage number alternative INTO key.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Liefert den Text für Materialstücklisten im
*&               Selektionsdialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  01.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  29.09.2005   HAENSEL  Konvertierungsexit für die Ausgabe aufrufen.
*&----------------------------------------------------------------------
  DATA: lc_materialnr TYPE string.

* Interne Materialnummer für die Ausgabe aufbereiten, d.h. führende
* Nullen abschneiden.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = me->materialnr
    IMPORTING
      output = lc_materialnr.

  CONCATENATE lc_materialnr plant usage alternative
    INTO rc_text SEPARATED BY space.
ENDMETHOD.


METHOD constructor.
************************************************************************
* Beschreibung: Initialisiert eine Materialstückliste
*
* Autor:        Heiko Hänsel
* Angelegt am:  30.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  15.04.2005   HAENSEL  Übernahme von Zusatzdaten
*  13.05.2005   HAENSEL  Zusätzliche Dokumentverknüpfungstypen
*                         - Materialstücklistenpositionen
*                         - Stücklistenbaukasten
*                         - Stücklistenstruktur mehrstufig
*                         - Mengenübersicht mehrstufig
*  01.09.2005   HAENSEL  Die Dokumentverknüpfungstypen werden in CREATE_
*                        SUPPORTED_DLTS() erzeugt.
************************************************************************

* Konstruktor der Basisklasse
  CALL METHOD super->constructor
    EXPORTING number      = number
              alternative = alternative
              io_additional_data = io_additional_data.

* Attribute speichern
  me->materialnr = material->materialnr.
  me->plant      = plant.
  me->usage      = usage.
  me->/cideon/if_plot_bo~name = 'STPO'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Erzeugung der Dokumentverknüpfungsarten für Material-
*&               stücklisten.
*&
*& Autor:        HAENSEL
*& Angelegt am:  01.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_dlt_bom      TYPE REF TO /cideon/cl_plot_dlt_bom,
        lo_dlt_bom_cs03 TYPE REF TO /cideon/cl_plot_dlt_bom_cs03,
        lo_dlt_bom_cs11 TYPE REF TO /cideon/cl_plot_dlt_bom_cs11,
        lo_dlt_bom_cs12 TYPE REF TO /cideon/cl_plot_dlt_bom_cs12,
        lo_dlt_bom_cs13 TYPE REF TO /cideon/cl_plot_dlt_bom_cs13,
        lc_key          TYPE string.

  CREATE OBJECT lo_dlt_bom
    EXPORTING
      bom = me.
  lc_key = lo_dlt_bom->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_bom.

  CREATE OBJECT lo_dlt_bom_cs03
    EXPORTING
      bom = me.
  lc_key = lo_dlt_bom_cs03->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_bom_cs03.

  CREATE OBJECT lo_dlt_bom_cs11
    EXPORTING
      bom = me.
  lc_key = lo_dlt_bom_cs11->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_bom_cs11.

  CREATE OBJECT lo_dlt_bom_cs12
    EXPORTING
      bom = me.
  lc_key = lo_dlt_bom_cs12->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_bom_cs12.

  CREATE OBJECT lo_dlt_bom_cs13
    EXPORTING
      bom = me.
  lc_key = lo_dlt_bom_cs13->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_bom_cs13.

ENDMETHOD.
ENDCLASS.
