class /CIDEON/CL_PLOT_BO_EKKO_POS definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_EKKO_POS
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.
  methods SET_MATERIAL
    importing
      !MATERIALNO type MATNR
      !DESCRIPTION type MAKTX .

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_ICON
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_BO_EKKO_POS
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_EKKO_POS
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@3Y@' .
  data POSITION type EBELP .
  data PURDOCNO type EBELN .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_EKKO_POS IMPLEMENTATION.


METHOD /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS .
************************************************************************
* Beschreibung: Die aktuelle Position wird in die Baumstruktur
*               eingehangen und die Suche nach weiteren Objekten im
*               zugehörigen Material fortgestzt.
*               Das hängt davon ab, wie tief in der Verlinkung gesucht
*               werden soll.
*
* Autor:        Heiko Hänsel
* Angelegt am:  10.05.2004
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
*  text = position.
*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = text
*              io_parent  = parent_item
*              if_enabled = seox_true
*              if_visible = seox_true
*              iv_image   =
*                 /cideon/cl_plot_bo_ekko_pos=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_ekko_pos=>icon
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


METHOD /cideon/if_plot_bo~get_icon.
*& Beschreibung: Liefert das Icon für Einkaufsbelegposition im
*&               Selektionsdialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_icon = icon.
ENDMETHOD.


METHOD /CIDEON/IF_PLOT_BO~GET_KEY .
************************************************************************
* Beschreibung: Erstellung des Schlüssels für die Einkaufbelegposition.
*
* Autor:        Heiko Hänsel
* Angelegt am:  27.05.2005
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  CONCATENATE purdocno position INTO key.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Positionsnummer als Text im Selektionsdialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = position.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key .
************************************************************************
* Beschreibung: Übernimmt den Objektschlüssel für die Positon, bestehend
*               aus der Einkaufsbelegnummer und der Positionsnummer

* Autor:        Heiko Hänsel
* Angelegt am:  10.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  08.09.2005   HAENSEL Schlüsselweitergabe an Direkte Dokumentverknüpfg
*                       nicht mehr notwendig.
* 08.10.2008 - CKR
*              Übergabe der Einkaufsbelegnummer
*
************************************************************************
  DATA: lo_ebelp    TYPE REF TO /cideon/cl_oo_string.

  purdocno = objkey(10).
  position     = objkey+11(5).

* Positionsnummer als Zusatzdatenfeld aufnehmen
  CREATE OBJECT lo_ebelp
    EXPORTING
      ic_string = position.

  CALL METHOD mo_additional_data->add
    EXPORTING
      key           = 'EBELP'
      obj           = lo_ebelp
    EXCEPTIONS
      duplicate_key = 1.

ENDMETHOD.


METHOD CONSTRUCTOR .
************************************************************************
* Beschreibung: Initialisierung der Einkaufsbelegposition
*
* Autor:        Heiko Hänsel
* Angelegt am:  10.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  15.04.2005   HAENSEL  Übernahme von Zusatzdaten
*  18.08.2005   HAENSEL  Die Dokumentverknüpfungstypen werden in
*                        CREATE_SUPPORTED_DLTS()  erstellt.
************************************************************************

* Konstruktor der Basisklasse ausführen
  CALL METHOD super->constructor( io_additional_data ).

  me->/CIDEON/if_plot_bo~name = 'EKPO'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Ezeugt den Dokumentverknüpfungstyp für Einkaufsbeleg-
*&               positionen
*&
*& Autor:        HAENSEL
*& Angelegt am:  18.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lo_dlt_dol TYPE REF TO /cideon/cl_plot_dlt_dol,
        lc_key     TYPE string,
        intobjkey  TYPE objky.

* Dokumentverknüpfungsart "Direkte Objektvernküpfung"
  CREATE OBJECT lo_dlt_dol
    EXPORTING
      objtype = 'EKPO'
      objkey = ''.
  lc_key = lo_dlt_dol->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_dol.

* Der Objektschlüssel muss noch an die Direkte Dokumentverknüpfung
* weitergegeben werden.
  intobjkey = /cideon/if_plot_bo~get_key( ).
  CALL METHOD lo_dlt_dol->set_objkey( intobjkey ).
ENDMETHOD.


method SET_MATERIAL .
************************************************************************
* Beschreibung: Übernimmt das Material, dass der Position zugeordnet ist
*
*
* Autor:        Heiko Hänsel
* Angelegt am:  10.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  15.04.2005   HAENSEL  Übergabe von Zusatzdaten an das Material
*  09.05.2005   HAENSEL  Materialnummer aus der Position in die Zusatz-
*                        daten übernehmen.
*  13.05.2005   HAENSEL  DUPLICATE_KEY Exception abfangen
************************************************************************
  DATA: material    TYPE REF TO /cideon/cl_plot_bo_bus1001,
        key         TYPE string,
        lo_matnr    TYPE REF TO /cideon/cl_oo_string.


* Materialnummer als Zusatzdatenfeld aufnehmen
  CREATE OBJECT lo_matnr
    EXPORTING
      ic_string = materialno.
  CALL METHOD mo_additional_data->add
    EXPORTING
      key = 'MATNR'
      obj = lo_matnr
    EXCEPTIONS
      duplicate_key = 1.    " Materialnummer kann schon da sein

* Neues Materialobjekt erzeugen
  CREATE OBJECT material
    EXPORTING
      materialnr = materialno
      io_additional_data = mo_additional_data.
  CALL METHOD material->set_materialbez( description ).


* Beziehung zwischen Bestellposition und Material herstellen
  key = materialno.
  CALL METHOD /cideon/if_plot_bo~related_objects->add(
    key = key obj = material ).
endmethod.
ENDCLASS.
