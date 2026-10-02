class /CIDEON/CL_PLOT_BO_BUS2007 definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2007
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
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2007
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2007
*"* do not include other source files here!!!
private section.

  data AUFTRNR type AUFNR .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2007 IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
************************************************************************
* Beschreibung: Ermittelt folgende Objekte zum Instandhaltungsauftrag
*               - Technischer Platz
*               - Equipement
*               - Material
*
* Autor:        Heiko Hänsel
* Angelegt am:  01.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA:  material      TYPE REF TO /cideon/cl_plot_bo_bus1001,
         equipment     TYPE REF TO /cideon/cl_plot_bo_equi,
         technical_place type ref to /cideon/cl_plot_bo_bus0010,
         objkey        TYPE swo_typeid,
         objects_found TYPE seox_boolean,
         keystr        TYPE string,
         obj           TYPE REF TO object,
         plotbo        TYPE REF TO /cideon/if_plot_bo,
         iter          TYPE REF TO /cideon/if_oo_iterator,
         tree_item     TYPE REF TO /cideon/cl_ui_tree_item,
         methname      TYPE string,
         child_level   TYPE i.

  FIELD-SYMBOLS: <l_tplnr> TYPE tplnr,
                 <l_tplbez> TYPE PLTXT,
                 <l_equnr> TYPE equnr,
                 <l_eqbez> type KTX01,
                 <l_matnr> TYPE matnr,
                 <l_matbez> TYPE bautx.


* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

  objects_found = seox_false.

* ~~~~~~~~~~~~~~~~~~~~~~~~~
* Auslesen der Dynprodaten

* Nummer des Technischen Platzes
  ASSIGN ('(SAPLCOIH)CAUFVD-TPLNR') TO <l_tplnr>.
  ASSIGN ('(SAPLCOIH)RIOT-PLTXT')   TO <l_tplbez>.

* Equipmentnummer
  ASSIGN ('(SAPLCOIH)CAUFVD-EQUNR') TO <l_equnr>.
  ASSIGN ('(SAPLCOIH)RIOT-EQTXT')   TO <l_eqbez>.

* Materialnummer
  ASSIGN ('(SAPLCOIH)CAUFVD-BAUTL') TO <l_matnr>.
  ASSIGN ('(SAPLCOIH)RIOT-BAUTX')   TO <l_matbez>.
* ~~~~~~~~~~~~~~~~~~~~~~~~~

* Referenzierte Business Objekte erzeugen
  IF NOT <l_matnr> IS INITIAL.
    objects_found = seox_true.

    CREATE OBJECT material
      EXPORTING materialnr = <l_matnr>.
    CALL METHOD material->set_materialbez( <l_matbez> ).
    keystr = <l_matnr>.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = keystr
      obj = material ).
  ENDIF.

  IF NOT <l_equnr> IS INITIAL.
    objects_found = seox_true.

    CREATE OBJECT equipment.
    objkey = <l_equnr>.
    call method equipment->/cideon/if_plot_bo~set_key( objkey ).
    call method equipment->set_description( <l_eqbez> ).
    keystr = <l_equnr>.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = keystr
      obj = equipment ).

  ENDIF.

  IF NOT <l_tplnr> IS INITIAL.
    objects_found = seox_true.

    create object technical_place.
    objkey = <l_tplnr>.
    call method technical_place->/cideon/if_plot_BO~set_key(
      objkey ).
    call method technical_place->set_description( <l_tplbez> ).
    keystr = <l_tplnr>.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = keystr
      obj = technical_place ).

  ENDIF.

* Falls keine Objekte gefunden wurden, gib dem Anwender bescheid.
  IF objects_found = seox_false.
    MESSAGE e007(/cideon/plot_service)
      RAISING nothing_found.
  ENDIF.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Zu den referenzierten Objekten weitere Objekte ermitteln,
* bis die maximale Anzeigetiefe erreicht ist.
  child_level = current_level - 1.

* Soll das aktuelle Objekt "Bestellanforderung" im Selektionsbaum
* erscheinen?
  IF display = seox_true.
*   TODO: Noch nicht implementiert, da die Bestellanforderung bisher nur
*         Einstiegsobjekt ist.
  ELSE.
    tree_item = parent_item.    " Parent item ist INITIAL
  ENDIF.
  methname = '/CIDEON/IF_OO_AGGREGATE~CREATE_ITERATOR'.
  CALL METHOD /cideon/if_plot_bo~related_objects->(methname)
    RECEIVING iterator = iter.
  DO.
    CALL METHOD iter->get_next
      RECEIVING item = obj
      EXCEPTIONS index_out_of_bounds = 1.
    IF sy-subrc = 1.
      EXIT.
    ENDIF.

    plotbo ?= obj.
    CALL METHOD plotbo->acquire_objects
      EXPORTING current_level = child_level
                selection_tree = selection_tree
                parent_item = tree_item
      EXCEPTIONS nothing_found = 1.

  ENDDO.

ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects .
*& Beschreibung: Ermittelt den Technischen Platz, Equipment oder eine
*&               verknüpfte Baugruppe
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: ls_header    TYPE bapi_alm_order_header_e,
        lt_partner    TYPE TABLE OF bapi_alm_order_partner,
        lt_operations TYPE TABLE OF bapi_alm_order_operation_e,
        lt_components TYPE TABLE OF bapi_alm_order_component_e,
        lt_relations  TYPE TABLE OF bapi_alm_order_relation_export,
        lt_texts      TYPE TABLE OF bapi_alm_text,
        lt_text_lines TYPE TABLE OF bapi_alm_text_lines,
        lt_prts       TYPE TABLE OF bapi_alm_order_prt_e,
        lt_costs_sum  TYPE TABLE OF bapi_alm_order_costs_sum_e,
        lt_costs_details TYPE TABLE OF bapi_alm_order_costs_detail_e,
        lt_return     TYPE TABLE OF bapiret2,
        lc_key       TYPE string,
        lc_objkey     TYPE swo_typeid,
        lo_material  TYPE REF TO /cideon/cl_plot_bo_bus1001,  "Material
        lo_equi       TYPE REF TO /cideon/cl_plot_bo_equi,   "Equipment
        lo_floc      TYPE REF TO /cideon/cl_plot_bo_bus0010. "TechPlatz

  CALL METHOD super->/cideon/if_plot_bo~acquire_related_objects.

* Details des Instandhaltungsauftrages lesen
  CALL FUNCTION 'BAPI_ALM_ORDER_GET_DETAIL'
    EXPORTING
      number           = me->auftrnr
    IMPORTING
      es_header        = ls_header
    TABLES
      et_partner       = lt_partner
      et_operations    = lt_operations
      et_components    = lt_components
      et_relations     = lt_relations
      et_texts         = lt_texts
      et_text_lines    = lt_text_lines
      et_prts          = lt_prts
      et_costs_sum     = lt_costs_sum
      et_costs_details = lt_costs_details
      return           = lt_return.

* Technischen Platz erzeugen, wenn angegeben
  IF NOT ls_header-funct_loc IS INITIAL.
    CREATE OBJECT lo_floc.
    lc_objkey = ls_header-funct_loc.
    CALL METHOD lo_floc->/cideon/if_plot_bo~set_key(
      lc_objkey
      ).
    lc_key = lo_floc->/cideon/if_plot_bo~get_key( ).
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_key
      obj = lo_floc ).
  ENDIF.

* Equipment erzeugen, wenn angegeben
  IF NOT ls_header-equipment IS INITIAL.
    CREATE OBJECT lo_equi.
    lc_objkey = ls_header-equipment.
    CALL METHOD lo_equi->/cideon/if_plot_bo~set_key(
      lc_objkey
      ).
    lc_key = lo_equi->/cideon/if_plot_bo~get_key( ).
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_key
      obj = lo_equi ).
  ENDIF.

* Material Objekt erzeugen, wenn Baugruppe angegeben
  IF NOT ls_header-assembly IS INITIAL.
    CREATE OBJECT lo_material
      EXPORTING
        materialnr = ls_header-assembly.
    lc_key = lo_material->/cideon/if_plot_bo~get_key( ).
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_key
      obj = lo_material ).
  ENDIF.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_KEY.
************************************************************************
* Beschreibung: Liefert den Objektschlüssel
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  key = me->auftrnr.

endmethod.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Liefert die Auftragsnummer als Text
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = me->auftrnr.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
************************************************************************
* Beschreibung: Übernahme der Auftragsnummer
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  me->auftrnr = objkey.

ENDMETHOD.


method CONSTRUCTOR.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 16:02:12
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  CALL METHOD SUPER->CONSTRUCTOR
    EXPORTING
      IO_ADDITIONAL_DATA = io_additional_data.
  me->/CIDEON/if_plot_bo~name = 'BUS2007'.
endmethod.


METHOD create_supported_dlts.
*& Beschreibung: Der Instandhaltungsauftrag selbst unterstützt keine
*&               Dokumentvernküpfungen
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
ENDMETHOD.
ENDCLASS.
