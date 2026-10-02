class /CIDEON/CL_PLOT_BO_VBAK_POS definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_VBAK_POS
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
      !DESCRIPTION type ARKTX .

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
*"* protected components of class /CIDEON/CL_PLOT_BO_VBAK_POS
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_VBAK_POS
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@3Y@' .
  data POSITION type POSNR_VA .
  data VBELNR type VBELN .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_VBAK_POS IMPLEMENTATION.


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
  text = position.
*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = text
*              io_parent  = parent_item
*              if_enabled = seox_true
*              if_visible = seox_true
*              iv_image   =
*                 /cideon/cl_plot_bo_vbak_pos=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_vbak_pos=>icon
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
  rc_icon = me->icon.
ENDMETHOD.


METHOD /CIDEON/IF_PLOT_BO~GET_KEY .
************************************************************************
* Beschreibung: Erstellung des Schlüssels für die Verkaufsbelegposition.
*
* Autor:        Heiko Hänsel
* Angelegt am:  11.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  CONCATENATE vbelnr position INTO key.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Positionsnummer als Text.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  11.01.2007  HAENSEL  Positionsnummer anstatt Belegnummer zurück-
*&                       liefern.
*&----------------------------------------------------------------------
*  rc_text = me->vbelnr.
  rc_text = me->position.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key .
************************************************************************
* Beschreibung: Übernimmt den Objektschlüssel für die Positon, bestehend
*               aus der Belegnummer und der Positionsnummer

* Autor:        Heiko Hänsel
* Angelegt am:  11.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  31.05.2005   HAENSEL  Die Positionsnummer mit in die Zusatzdaten auf-
*                        genommen.
*  08.09.2005   HAENSEL  Dokumentverknüpfungstypen werden in der Methode
*                        CREATE_SUPPORTED_DLTS bereitgestellt.
************************************************************************
  DATA: lo_vbpos  TYPE REF TO /cideon/cl_oo_string.

  vbelnr    = objkey(10).
  position  = objkey+11(5).

* Positionsnummer in die Zusatzdaten aufnehmen
  CREATE OBJECT lo_vbpos
    EXPORTING
      ic_string = me->position.
  CALL METHOD mo_additional_data->add
    EXPORTING
      key           = 'VBPOS'
      obj           = lo_vbpos
    EXCEPTIONS
      duplicate_key = 1.

ENDMETHOD.


METHOD constructor.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 18:01:08
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.

  me->/cideon/if_plot_bo~name = 'VBAP'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Ezeugt den Dokumentverknüpfungstyp für Verkaufsbeleg-
*&               positionen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
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
      objtype = 'VBAP'
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


METHOD set_material .
************************************************************************
* Beschreibung: Übernimmt das Material, dass der Position zugeordnet ist
*
*
* Autor:        Heiko Hänsel
* Angelegt am:  10.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  09.05.2005   HAENSEL  Materialnummer als Zusatzdatenfeld aufgenommen
************************************************************************
  DATA: material    TYPE REF TO /cideon/cl_plot_bo_bus1001,
        key         TYPE string,
        lo_matnr    TYPE REF TO /cideon/cl_oo_string.

* Materialnummer als Zusatzdatenfeld in die Position übernehmen
  CREATE OBJECT lo_matnr
    EXPORTING
      ic_string = materialno.
  CALL METHOD mo_additional_data->add
    EXPORTING
      key           = 'MATNR'
      obj           = lo_matnr
    EXCEPTIONS
      duplicate_key = 1.

* Neues Materialobjekt erzeugen
  CREATE OBJECT material
    EXPORTING materialnr = materialno
              io_additional_data = mo_additional_data.
  CALL METHOD material->set_materialbez( description ).

* Beziehung zwischen Bestellposition und Material herstellen
  key = materialno.
  CALL METHOD /cideon/if_plot_bo~related_objects->add(
    key = key obj = material ).
ENDMETHOD.
ENDCLASS.
