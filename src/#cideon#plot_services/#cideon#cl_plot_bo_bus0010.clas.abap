class /CIDEON/CL_PLOT_BO_BUS0010 definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS0010
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .
  methods SET_DESCRIPTION
    importing
      !DESCRIPTION type PLTXT .

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_ICON
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS0010
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS0010
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@AO@' .
  data TPLNR type TPLNR .
  data DESCRIPTION type PLTXT .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS0010 IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects .
************************************************************************
* Beschreibung: Die Equipmentnummer wird in die Baumstruktur eingehangen
*               und nach weiteren in Beziehung stehenden Objekten
*               gesucht.
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: text    TYPE string,
        tree_item    TYPE REF TO /cideon/cl_ui_tree_item,
        child_level  TYPE i,
        equihier     TYPE TABLE OF rihequi,
        objkey       TYPE swo_typeid,
        obj          TYPE REF TO object,
        keystr       TYPE string,
        methname     TYPE string,
        equi_view    TYPE v_equi,
        iter         TYPE REF TO /cideon/if_oo_iterator,
        plotbo       TYPE REF TO /cideon/if_plot_bo,
        submat       TYPE REF TO /cideon/cl_plot_bo_bus1001,
        eqst_entry   TYPE eqstb,
        eqst_tab     TYPE TABLE OF eqstb,
        subequi      TYPE REF TO /cideon/cl_plot_bo_equi.

  FIELD-SYMBOLS: <l_equi> TYPE rihequi,
                 <l_eqst> TYPE eqstb.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* Tree Item für die Position einfügen
*  CONCATENATE tplnr description INTO text SEPARATED BY space.
*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = text
*              io_parent  = parent_item
*              if_enabled = seox_true
*              if_visible = seox_true
*              iv_image   =
*                 /cideon/cl_plot_bo_bus0010=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_bus0010=>icon
*              io_ext_key = me
*     RECEIVING ro_item   = tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING tree_item = tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

* Nächste Ebene
  child_level = current_level - 1.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Für alle ermittelten Objekte auf der nächste Ebene nach
* Objekten suchen.
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


METHOD /cideon/if_plot_bo~get_icon .
*& Beschreibung: Icon für Technische Plätze liefern
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_icon = icon.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_KEY .
************************************************************************
* Beschreibung: Erstellung des Objektschlüssels
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  key = tplnr.

endmethod.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Liefert den angezeigten Text für Technische Plätze
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CONCATENATE tplnr description INTO rc_text SEPARATED BY space.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key .
************************************************************************
* Beschreibung: Übermittlung des Objektschlüssels
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  30.08.2005   HAENSEL  Objektschlüssel muss nicht mehr an die
*                        Dokumentverknüpfungsart weitergegeben werden.
************************************************************************
  DATA: ls_itob  TYPE bapi_itob.

  me->tplnr = objkey.

  CALL FUNCTION 'BAPI_FUNCLOC_GETDETAIL'
    EXPORTING
      functlocation    = me->tplnr
    IMPORTING
      data_general_exp = ls_itob.
  me->description = ls_itob-descript.

ENDMETHOD.


METHOD CONSTRUCTOR .
************************************************************************
* Beschreibung: Initialisierung des Technischen Platzes.
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  30.08.2005   HAENSEL  Die Dokumentverknüpfungsart wird in der Methode
*                        CREATE_SUPPORTED_DLTS() erstellt.
************************************************************************

* Constructor der Basisklasse aufrufen
  CALL METHOD super->constructor.
  me->/cideon/if_plot_bo~name = 'BUS0010'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Technischer Platz unterstützt die direkte
*&               Objektvernküpfung mit Dokumentinfosätzen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lc_obj_key    TYPE objky,
        lo_dlt_dol    TYPE REF TO /cideon/cl_plot_dlt_dol,
        lc_key        TYPE string.

* Die unterstützten Dokumenverknüpfungarten initialisieren
  lc_obj_key = me->/cideon/if_plot_bo~get_key( ).
  CREATE OBJECT lo_dlt_dol
    EXPORTING objtype = 'IFLOT'
              objkey  = lc_obj_key.
  lc_key = lo_dlt_dol->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_dol.

ENDMETHOD.


METHOD set_description.
************************************************************************
* Beschreibung: Startet den Preprozessor für die Plotting Solution ohne
*               Berücksichtigung selektierter Objekte und Queue.
*               Es ist nur der pure Absprung in den Preprozessor.
*
* Autor:        Heiko Hänsel
* Angelegt am:  01.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  me->description = description.
ENDMETHOD.
ENDCLASS.
