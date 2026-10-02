class /CIDEON/CL_PLOT_BO_BUS2105_POS definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2105_POS
*"* do not include other source files here!!!
public section.

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR
    importing
      !POSITION type BNFPO
      !BANFNR type BANFN .
  methods SET_MATERIAL
    importing
      !MATERIALNR type MATNR
      !MATERIALBEZ type TXZ01 .

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_ICON
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2105_POS
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2105_POS
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE .
  data POSITION type BNFPO .
  data BANFNR type BANFN .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2105_POS IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
************************************************************************
* Beschreibung: Die aktuelle Position wird in die Baumstruktur
*               eingehangen und die Suche nach weiteren Objekten im
*               zugehörigen Material fortgestzt.
*               Das hängt davon ab, wie tief in der Verlinkung gesucht
*               werden soll.
*
* Autor:        Heiko Hänsel
* Angelegt am:  28.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: matitem      TYPE REF TO object,
        material     TYPE REF TO /cideon/cl_plot_bo_bus1001,
        child_level  TYPE i,
        tree_item    TYPE REF TO /cideon/cl_ui_tree_item,
        text         TYPE string
        .

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* Tree Item für die Position einfügen
  text = position.
*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = text
*              io_parent  = parent_item
*              if_enabled = seox_true
*              if_visible = seox_true
*              iv_image   =
*                 /cideon/cl_plot_bo_bus2105_pos=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_bus2105_pos=>icon
*              io_ext_key = me
*     RECEIVING ro_item   = tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING tree_item = tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

* Material lesen.
  CALL METHOD /cideon/if_plot_bo~related_objects->get_by_index
    EXPORTING index = 1
    RECEIVING item  = matitem
    EXCEPTIONS index_out_of_bounds = 1.
  IF sy-subrc = 1.
    RAISE nothing_found.
  ENDIF.
  material ?= matitem.

* Objekte ermitteln
  child_level = current_level - 1.
  CALL METHOD material->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level = child_level
              selection_tree = selection_tree
              parent_item = tree_item
    EXCEPTIONS nothing_found = 1.
  IF sy-subrc = 1.
    RAISE nothing_found.
  ENDIF.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS .
*CALL METHOD SUPER->/CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS
*    .
endmethod.


METHOD /cideon/if_plot_bo~get_icon.
  rc_icon = me->icon.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_key.
************************************************************************
* Beschreibung: Erstellung des Schlüssels für die Bestellanforderungs-
*               position.
*
* Autor:        Heiko Hänsel
* Angelegt am:  30.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  CONCATENATE banfnr position INTO key.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text .
  rc_text = me->position.
ENDMETHOD.


METHOD class_constructor.
************************************************************************
* Beschreibung: Die Ikone für die Bestellposition wird statisch
*               definiert.
*
* Autor:        Heiko Hänsel
* Angelegt am:  29.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  /cideon/cl_plot_bo_bus2105_pos=>icon = '@3Y@'.
ENDMETHOD.


METHOD constructor.
************************************************************************
* Beschreibung: Initialisiert die unterstützten
*               Dokumentverknüpfungstypen und verknüpfte Objekte
*
* Autor:        Heiko Hänsel
* Angelegt am:  01.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

* Konstruktor der Basisklasse ausführen
  CALL METHOD super->constructor.

* Positionsnummer speichern
  me->position = position.
  me->banfnr   = banfnr.

  me->/CIDEON/if_plot_bo~name = 'BUS2009'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Nur die Direktverknüpfung von Dokumenten wird bei den
*&               Positionen der Bestellanforderung beachtet.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_dlt_dol    TYPE REF TO /cideon/cl_plot_dlt_dol,
        lc_obj_key    TYPE objky,
        lc_key_str    TYPE string.

* Dokumentverknüpfungsart "Direkte Objektvernküpfung"
  CONCATENATE me->banfnr me->position INTO lc_obj_key.
  CREATE OBJECT lo_dlt_dol
    EXPORTING
      objtype = 'EBAN'
      objkey  = lc_obj_key.
  lc_key_str = lo_dlt_dol->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key_str
      obj = lo_dlt_dol.
ENDMETHOD.


METHOD set_material.
************************************************************************
* Beschreibung: Legt die Referenz auf das zu der Position gehörende
*               Material an. Diese Methode wird von der Bestellanforder-
*               ung aus aufgerufen, um beim ACQUIRE_OBJECTS Datenbank-
*               last durch Selektion der Daten zu vermeiden.
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  09.05.2005   HAENSEL Übergabe der Materialnummer als Zusatzdatenfeld
*  13.05.2005   HAENSEL DUPLICATE_KEY Exception abfangen
************************************************************************

  DATA: material    TYPE REF TO /cideon/cl_plot_bo_bus1001,
        key         type string,
        lo_matnr    type ref to /cideon/cl_oo_string.

* Materialnummer als Zusatzdatenfeld aufnehmen
  CREATE OBJECT lo_matnr
    EXPORTING
      ic_string = materialnr.
  CALL METHOD mo_additional_data->add
    EXPORTING
      key = 'MATNR'
      obj = lo_matnr
    EXCEPTIONS
      duplicate_key = 1.    " Materialnummer kann schon da sein

* Neues Materialobjekt erzeugen
  CREATE OBJECT material
    EXPORTING materialnr = materialnr
              io_additional_data = mo_additional_data.
  CALL METHOD material->set_materialbez( materialbez ).

* Beziehung zwischen Bestellposition und Material herstellen
  key = materialnr.
  CALL METHOD /cideon/if_plot_bo~related_objects->add(
    key = key obj = material ).
ENDMETHOD.
ENDCLASS.
