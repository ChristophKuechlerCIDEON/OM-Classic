class /CIDEON/CL_PLOT_BO_PROVIDER definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_PROVIDER
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_UI_COLUMN_PROVIDER .
  interfaces /CIDEON/IF_UI_CONTENT_PROVIDER .
  interfaces /CIDEON/IF_UI_STRUCT_CONT_PROV .
  interfaces /CIDEON/IF_UI_TREE_CONT_PROV .
*"* protected components of class /CIDEON/CL_PLOT_BO_PROVIDER
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_BO_PROVIDER
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_PROVIDER IMPLEMENTATION.


METHOD /cideon/if_ui_column_provider~get_columns.
*& Beschreibung: In dieser Methode werden die benötigten Spalten für das
*&               Plot Objekt ermittelt. Dafür werden die Dokument-
*&               verknüpfungstypen ermittelt und die Spaltendefinition
*&               geholt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  18.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lo_plot_bo   TYPE REF TO /cideon/if_plot_bo,
        lo_dlts      TYPE REF TO /cideon/cl_oo_array,
        lo_iter      TYPE REF TO /cideon/if_oo_iterator,
        lo_dlt       TYPE REF TO /cideon/if_plot_dlt.

* Das übergebene Element muss ein Plot Objekt sein.
  lo_plot_bo ?= io_element.

* Die unterstützten Dokumentverknüpfungstypen holen
  lo_dlts = lo_plot_bo->get_supported_dlts( ).
  CHECK NOT lo_dlts IS INITIAL.

  CREATE OBJECT ro_columns.
  lo_iter = lo_dlts->create_iterator( ).
  WHILE lo_iter->has_next( ) = abap_true.
    lo_dlt ?= lo_iter->get_next( ).
    CALL METHOD ro_columns->add( io_object = lo_dlt->column ).

  ENDWHILE.
ENDMETHOD.


method /CIDEON/IF_UI_CONTENT_PROVIDER~INPUT_CHANGED .
endmethod.


METHOD /cideon/if_ui_struct_cont_prov~get_elements.
*& Beschreibung: Liefert die verbundenen Plot BOs zum übergebenen
*&               Plot BO, sofern welche existieren.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lo_plot_bo    TYPE REF TO /cideon/if_plot_bo.

* Das Input Objekt muss ein Plot Objekt sein.
  lo_plot_bo ?= io_input.

* Wenn das aktuelle Plot Business Objekt angezeigt werden soll,
* dann wird nur dieses zurückgeliefert,
  IF lo_plot_bo->display( ) = abap_true.
    CREATE OBJECT ro_elements.
    CALL METHOD ro_elements->add
      EXPORTING
        io_object = lo_plot_bo.
  ELSE.
*   ... sonst untergeordnete Objekte zurückliefern
    ro_elements = /cideon/if_ui_tree_cont_prov~get_children( lo_plot_bo ).
  ENDIF.
ENDMETHOD.


METHOD /cideon/if_ui_tree_cont_prov~get_children.
*& Beschreibung: Liefert die mit dem aktuellen Plot Business Objekt
*&               verknüpften Objekte zurück.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_plot_bo    TYPE REF TO /cideon/if_plot_bo.

* Das Eltern-Objekt muss ein Plot Objekt sein
  lo_plot_bo ?= io_parent.

* Die mit diesem Plot Business Objekt in Verbindung stehenden Objekte
* zurückliefern
  IF /cideon/if_ui_tree_cont_prov~has_children( io_parent ) = abap_true.
    ro_children = lo_plot_bo->related_objects->to_array( ).
  ENDIF.
ENDMETHOD.


METHOD /cideon/if_ui_tree_cont_prov~has_children.
*& Beschreibung: Prüft, ob das übergebene Plot Objekt Referenzen zu
*&               anderen Objekten aufweist.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  data: lo_plot_bo    type ref to /cideon/if_plot_bo.

* Sicherstellen, dass es sich bei dem übergebenen Element um ein Plot-
* objekt handelt.
  lo_plot_bo ?= io_element.

* Prüfen, ob es Referenzen gibt
  rb_has_children = lo_plot_bo->has_related_objects( ).
ENDMETHOD.
ENDCLASS.
