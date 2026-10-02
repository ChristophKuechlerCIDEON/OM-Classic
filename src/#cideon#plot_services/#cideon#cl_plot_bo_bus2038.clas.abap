class /CIDEON/CL_PLOT_BO_BUS2038 definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2038
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
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2038
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2038
*"* do not include other source files here!!!
private section.

  data NUMBER type VIQMEL-QMNUM .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2038 IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
*& Beschreibung: Es werden die Daten der Instandhaltungsmeldung
*&               ermittelt.
*&               Zusätzlich werden verknüpfter Technischer Platz,
*&               Equipment und Material ermittelt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  15.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lb_objects_found TYPE abap_bool,
        lo_material      TYPE REF TO /cideon/cl_plot_bo_bus1001,
        lo_floc          TYPE REF TO /cideon/cl_plot_bo_bus0010,
        lo_equi          TYPE REF TO /cideon/cl_plot_bo_equi,
        lc_objkey        TYPE swo_typeid,
        lc_keystr        TYPE string,
        lo_tree_item     TYPE REF TO /cideon/cl_ui_tree_item,
        lo_plotbo        TYPE REF TO /cideon/if_plot_bo,
        lo_iter          TYPE REF TO /cideon/if_oo_iterator,
        li_child_level   TYPE i.


  FIELD-SYMBOLS: <l_tplnr> TYPE tplnr,
                 <l_tplbez> TYPE pltxt,
                 <l_equnr> TYPE equnr,
                 <l_eqbez> TYPE ktx01,
                 <l_matnr> TYPE matnr,
                 <l_matbez> TYPE bautx.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* Nummer und Bezeichnung des Technischen Platzes ermitteln
  ASSIGN ('(SAPLIQS0)RIWO1-TPLNR') TO <l_tplnr>.
  ASSIGN ('(SAPLIQS0)RIWO1-PLTXT') TO <l_tplbez>.

* Equipmentnummer und Bezeichung ermitteln
  ASSIGN ('(SAPLIQS0)RIWO1-EQUNR') TO <l_equnr>.
  ASSIGN ('(SAPLIQS0)RIWO1-EQTXT') TO <l_eqbez>.

* Baugruppe und Bezeichnung ermitteln
  ASSIGN ('(SAPLIQS0)RIWO1-BAUTL') TO <l_matnr>.
  ASSIGN ('(SAPLIQS0)RIWO1-BAUTX') TO <l_matbez>.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Die ermittelten Objekte erzeugen

  IF NOT <l_tplnr> IS INITIAL.
    lb_objects_found = abap_true.

    CREATE OBJECT lo_floc.
    lc_objkey = <l_tplnr>.
    CALL METHOD lo_floc->/cideon/if_plot_bo~set_key( lc_objkey ).
    CALL METHOD lo_floc->set_description( <l_tplbez> ).
    lc_keystr = <l_tplnr>.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_keystr
      obj = lo_floc
    ).

  ENDIF.

  IF NOT <l_equnr> IS INITIAL.
    lb_objects_found = abap_true.

    CREATE OBJECT lo_equi.
    lc_objkey = <l_equnr>.
    CALL METHOD lo_equi->/cideon/if_plot_bo~set_key( lc_objkey ).
    CALL METHOD lo_equi->set_description( <l_eqbez> ).
    lc_keystr = <l_equnr>.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_keystr
      obj = lo_equi
    ).

  ENDIF.

  IF NOT <l_matnr> IS INITIAL.
    lb_objects_found = abap_true.

    CREATE OBJECT lo_material
      EXPORTING
        materialnr = <l_matnr>
        io_additional_data = mo_additional_data.

    CALL METHOD lo_material->set_materialbez( <l_matbez> ).
    lc_keystr = <l_matnr>.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_keystr
      obj = lo_material ).
  ENDIF.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Falls keine Objekte gefunden wurden, gib dem Anwender bescheid.
  IF lb_objects_found = abap_false.
    MESSAGE e007(/cideon/plot_service)
      RAISING nothing_found.
  ENDIF.

* Zu den referenzierten Objekten weitere Objekte ermitteln,
* bis die maximale Anzeigetiefe erreicht ist.
  li_child_level = current_level - 1.

* Soll das aktuelle Objekt "Instandhaltungsmeldung" im Selektionsbaum
* erscheinen?
  IF display = abap_true.
*   TODO: Noch nicht implementiert, da die Instandhaltungsmeldung bisher
*         nur Einstiegsobjekt ist.
  ELSE.
    lo_tree_item = parent_item.    " Parent item ist INITIAL
  ENDIF.
  CALL METHOD me->related_objects->create_iterator
    RECEIVING iterator = lo_iter.
  WHILE lo_iter->has_next( ) = abap_true.
    lo_plotbo ?= lo_iter->get_next( ).
    CALL METHOD lo_plotbo->acquire_objects
      EXPORTING current_level = li_child_level
                selection_tree = selection_tree
                parent_item = lo_tree_item
      EXCEPTIONS nothing_found = 1.

  ENDWHILE.

ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects .
*& Beschreibung: Ermittlung des Techn. Platz, Equipment oder Baugruppe,
*&               die in der Meldung eingegebenen werden können
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  19.09.2005  HAENSEL Zusatzdaten weitergeben
*&----------------------------------------------------------------------

  DATA: ls_header    TYPE bapi2080_nothdre,
        lo_floc      TYPE REF TO /cideon/cl_plot_bo_bus0010,
        lc_key       TYPE string,
        lc_objkey    TYPE swo_typeid,
        lo_material  TYPE REF TO /cideon/cl_plot_bo_bus1001,
        lo_equi      TYPE REF TO /cideon/cl_plot_bo_equi.

  CALL METHOD super->/cideon/if_plot_bo~acquire_related_objects.

  CALL FUNCTION 'BAPI_ALM_NOTIF_GET_DETAIL'
    EXPORTING
      number                   = me->number
    IMPORTING
      notifheader_export       = ls_header
*     NOTIFHDTEXT              =
*   TABLES
*     NOTLONGTXT               =
*     NOTITEM                  =
*     NOTIFCAUS                =
*     NOTIFACTV                =
*     NOTIFTASK                =
*     NOTIFPARTNR              =
*     RETURN                   =
            .
* Technischen Platz erzeugen, wenn angegeben
  IF NOT ls_header-funct_loc IS INITIAL.
    CREATE OBJECT lo_floc.
    CALL METHOD lo_floc->set_additional_data
      EXPORTING
        io_additional_data = mo_additional_data.
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
    CALL METHOD lo_equi->set_additional_data
      EXPORTING
        io_additional_data = mo_additional_data.
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
        materialnr = ls_header-assembly
        io_additional_data = mo_additional_data.
    lc_key = lo_material->/cideon/if_plot_bo~get_key( ).
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_key
      obj = lo_material ).
  ENDIF.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_key.
*& Beschreibung: Liefert den Schlüssel des Objektes, die Nummer der
*&               Instandhaltungsmeldung.
*&
*& Autor:        HAENSEL
*& Angelegt am:  15.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  key = me->number.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Liefert die Nummer der Instandhaltungsmeldung als Text
*&               für den Selektionsdialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = me->number.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
*& Beschreibung: Es wird der Schlüssel, die Nummer der Instandhaltungs-
*&               meldung übernommen und im Attribut NUMBER abgelegt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  15.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  MOVE objkey TO me->number.
ENDMETHOD.


METHOD constructor.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 17:25:13
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.

  me->/CIDEON/if_plot_bo~name = 'BUS2038'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Instandhaltungsmeldungen besitzt die Möglichkeit der
*&               Direktverknüpfung über die DRAD - OBJTYPE: PMQMEL.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_dlt_dol    TYPE REF TO /cideon/cl_plot_dlt_dol,
        lc_obj_key    TYPE objky,
        lc_key        TYPE string.

  lc_obj_key = me->/cideon/if_plot_bo~get_key( ).
  CREATE OBJECT lo_dlt_dol
    EXPORTING
      objtype = 'PMQMEL'
      objkey  = lc_obj_key.

  lc_key = lo_dlt_dol->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_dol.
ENDMETHOD.
ENDCLASS.
