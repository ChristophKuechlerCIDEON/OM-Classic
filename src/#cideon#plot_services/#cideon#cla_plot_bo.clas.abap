class /CIDEON/CLA_PLOT_BO definition
  public
  abstract
  create public .

*"* public components of class /CIDEON/CLA_PLOT_BO
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_PLOT_BO .

  aliases RELATED_OBJECTS
    for /CIDEON/IF_PLOT_BO~RELATED_OBJECTS .
  aliases SUPPORTED_DLTS
    for /CIDEON/IF_PLOT_BO~GET_SUPPORTED_DLTS .

  methods INSERT_CHECKBOXES
    importing
      !TREE_ITEM type ref to /CIDEON/CL_UI_TREE_ITEM
    exceptions
      COLUMN_NOT_EXIST .
  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.
  methods SET_ADDITIONAL_DATA
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION .
  type-pools ABAP .
*"* protected components of class /CIDEON/CLA_PLOT_BO
*"* do not include other source files here!!!
protected section.

  data MO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION .

  methods CREATE_SUPPORTED_DLTS
  abstract .
*"* private components of class /CIDEON/CLA_PLOT_BO
*"* do not include other source files here!!!
private section.
  type-pools ABAP .
ENDCLASS.



CLASS /CIDEON/CLA_PLOT_BO IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
************************************************************************
* Beschreibung: Diese Methode ist abstrakt und muss in den abgeleiteten
*               Klassen implementiert werden, um die zugehörigen
*               Objekte m. Dokumenten zu ermitteln.
*
* Autor:        Heiko Hänsel
* Angelegt am:  28.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  03.05.2004   HAENSEL  Als allgemeine Aktion sichert die abstrakte
*                        Methode ab, das die Spalten im Baum für die
*                        Dokumentverknüpfungsarten erstellt wird.
************************************************************************

  DATA: dlt_it    TYPE REF TO /cideon/if_oo_iterator,
        itm       TYPE REF TO object,
        dlt       TYPE REF TO /cideon/if_plot_dlt,
        exists    TYPE seox_boolean,
        width     TYPE i,
        meth_name TYPE string.

* Dyn. Aufruf wegen Zeilenlängenbegrenzung
  meth_name = '/CIDEON/IF_OO_AGGREGATE~CREATE_ITERATOR'.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->(meth_name)
    RECEIVING iterator = dlt_it.

  DO.
    CALL METHOD dlt_it->get_next
      RECEIVING item = itm
      EXCEPTIONS index_out_of_bounds = 1.
    IF sy-subrc = 1.
      EXIT.
    ENDIF.
    dlt ?= itm.

*   Prüfen, ob schon eine Spalte für den Dokumentverknüpfungstyp
*   vorhanden ist.
*    CALL METHOD selection_tree->column_exists
*      EXPORTING column_name = dlt->column_name
*      RECEIVING exists = exists.
*    IF exists = seox_false.
*      width = strlen( dlt->column_title ).
*      width = width * 2.
*      CALL METHOD selection_tree->add_column
*        EXPORTING name = dlt->column_name
*                  width = width
*                  alignment   = cl_column_tree_model=>align_center
*                  header_text = dlt->column_title
*                  header_tooltip = dlt->column_tooltip.
*    ENDIF.
  ENDDO.

ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects.
*& Beschreibung: In den abgeleiteten Klassen müssen in dieser Methode
*&               die referenzierten Plot Objekte ermittelt werden und
*&               der Collection MO_RELATED_OBJECTS hinzugefügt werden.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CALL METHOD /cideon/if_plot_bo~related_objects->remove_all( ).
ENDMETHOD.


METHOD /cideon/if_plot_bo~display.
*& Beschreibung: Standardmäßig werden alle Objekte im Auswahldialog
*&               angezeigt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rb_display = abap_true.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_additional_data .
*& Beschreibung: Liefert die Auflistung mit den Zusatzdaten des Objektes
*&               zurück. Im Key der Einträge steht der Name des Feldes
*&               und der Wert ist ein /CIDEON/CL_OO_STRING Objekt
*&
*& Autor:        HAENSEL
*& Angelegt am:  15.04.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  ro_additional_data = me->mo_additional_data.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_icon.
*& Beschreibung: Damit das Plot Objekt im Auswahldialog ein Icon hat,
*&               muss diese Methode in den abgeleiteten Klassen über-
*&               schrieben werden.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_icon = 'BNONE'.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_KEY.

endmethod.


METHOD /cideon/if_plot_bo~get_supported_dlts.
*& Beschreibung: Es werde die vom Plot Objekt unter-
*&               stützten Dokumentverknüpfungstypen zurückgeliefert.
*&
*& Autor:        HAENSEL
*& Angelegt am:  18.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  IF /cideon/if_plot_bo~supported_dlts->count = 0.
    CALL METHOD create_supported_dlts.
  ENDIF.
  ro_dlts = /cideon/if_plot_bo~supported_dlts->to_array( ).
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Diese Methode muss in den konkreten abgeleiteten
*&               Klassen überschrieben werden.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = text-000.
ENDMETHOD.


METHOD /cideon/if_plot_bo~has_related_objects.
*& Beschreibung: Es wird überprüft, ob es verknüpfte Plot Objekte gibt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08..2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  IF /cideon/if_plot_bo~related_objects->count = 0.
    CALL METHOD /cideon/if_plot_bo~acquire_related_objects.
  ENDIF.
  IF /cideon/if_plot_bo~related_objects->count > 0.
    rb_has_related_objects = abap_true.
  ENDIF.
ENDMETHOD.


METHOD /cideon/if_plot_bo~remove_all_objects.
************************************************************************
* Beschreibung: Löscht alle bereits gefundenen Objekte, die Dokumente
*               enthalten können.
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  CALL METHOD /cideon/if_plot_bo~related_objects->remove_all.

ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.

ENDMETHOD.


METHOD constructor.
************************************************************************
* Beschreibung: Initialisierung der vom Interface zur Verfügung gestell-
*               ten Attribute
*
* Autor:        Heiko Hänsel
* Angelegt am:  29.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  15.04.2005   HAENSEL  Unterstützung von Zusatzdaten für Business
*                        Objekte, die Später an die gefundenen
*                        Dokumente weitergegeben werden.
*  11.07.2005   HAENSEL  Wenn Zusatzdaten übergeben werden, dann muss
*                        die Collection kopiert werden, da sonst die
*                        gleiche Collection von mehreren Business
*                        Objekten verwendet wird.
************************************************************************

  CREATE OBJECT /cideon/if_plot_bo~supported_dlts.
  CREATE OBJECT /cideon/if_plot_bo~related_objects.

* Zusatzdaten übernehmen bzw. eine leere Auflistung erstellen
  IF NOT io_additional_data IS INITIAL.
    CALL METHOD set_additional_data
      EXPORTING
        io_additional_data = io_additional_data.
  ELSE.
    CREATE OBJECT mo_additional_data.
  ENDIF.
ENDMETHOD.


METHOD insert_checkboxes.
************************************************************************
* Beschreibung: Fügt die Checkboxen für das Item abhängig von den
*               unterstützten Verknüpfungstypen ein.
*
* Autor:        Heiko Hänsel
* Angelegt am:  03.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: dlt_it    TYPE REF TO /cideon/if_oo_iterator,
        itm       TYPE REF TO object,
        dlt       TYPE REF TO /cideon/if_plot_dlt,
        exists    TYPE seox_boolean,
        tooltip   type string,
        meth_name TYPE string.

* Dyn. Aufruf wegen Zeilenlängenbegrenzung
  meth_name = '/CIDEON/IF_OO_AGGREGATE~CREATE_ITERATOR'.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->(meth_name)
    RECEIVING iterator = dlt_it.

  DO.

*   Dokumentverknüpfungstyp besorgen
    CALL METHOD dlt_it->get_next
      RECEIVING item = itm
      EXCEPTIONS index_out_of_bounds = 1.
    IF sy-subrc = 1.
      EXIT.
    ENDIF.
    dlt ?= itm.

*    tooltip = dlt->column->tooltip.
*    CALL METHOD tree_item->set_column_value
*      EXPORTING column_name = dlt->column_name
*                class       = cl_column_tree_model=>item_class_checkbox
*                image       = 'BNONE'
*                editable    = seox_true
*                txtisqinfo  = seox_true
*                text        = tooltip
*      EXCEPTIONS column_not_exist = 1.
*    IF sy-subrc = 1.
*      RAISE column_not_exist.
*    ENDIF.

  ENDDO.

ENDMETHOD.


METHOD set_additional_data.
*& Beschreibung: Übernimmt Zusatzdaten von aussen. Vorhandene Zusatz-
*&               daten werden überschrieben.
*&
*& Autor:        HAENSEL
*& Angelegt am:  19.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  mo_additional_data ?= io_additional_data->clone( ).
ENDMETHOD.
ENDCLASS.
