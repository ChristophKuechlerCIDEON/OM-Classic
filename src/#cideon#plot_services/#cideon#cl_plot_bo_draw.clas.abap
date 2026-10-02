class /CIDEON/CL_PLOT_BO_DRAW definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_DRAW
*"* do not include other source files here!!!
public section.

  data DOKAR type DRAW-DOKAR .
  data DOKNR type DRAW-DOKNR .
  data DOKTL type DRAW-DOKTL .
  data DOKVR type DRAW-DOKVR .

  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.

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
*"* protected components of class /CIDEON/CL_PLOT_BO_DRAW
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_DRAW
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@AR@' .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_DRAW IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects .

************************************************************************
* Beschreibung: Fügt die Dokumenteninfosatzschlüssel
*               in die Baumstruktur des Auswahldialoges ein.
*
* Autor:        Dr. Peter Rabe
* Angelegt am:  14.03.2005
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: lc_text         TYPE string,
        lo_tree_item    TYPE REF TO /cideon/cl_ui_tree_item.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING
      current_level  = current_level
      selection_tree = selection_tree
      parent_item    = parent_item
      display        = display.

* Text für die Anzeige im Selektionsbaum erstellen und in die Baum-
* struktur einfügen.
  CONCATENATE dokar doknr doktl dokvr INTO lc_text SEPARATED BY '/'.

*  CALL METHOD selection_tree->add_item
*    EXPORTING
*      iv_text      = lc_text
*      io_parent    = parent_item
*      if_enabled   = abap_true
*      if_visible   = abap_true
*      iv_image     = /cideon/cl_plot_bo_draw=>icon
*      iv_image_exp = /cideon/cl_plot_bo_draw=>icon
*      io_ext_key   = me
*    RECEIVING
*      ro_item      = lo_tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING
      tree_item = lo_tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  CHECK current_level > 1.

ENDMETHOD.


METHOD /cideon/if_plot_bo~get_icon.
  rc_icon = me->icon.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_key .
*&----------------------------------------------------------------------
*& Beschreibung: Verknüpft die Felder des DIS Schlüssels zu eine String
*&               und gibt diesen zurück.
*&
*& Autor:        HAENSEL
*& Angelegt am:  29.03.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CONCATENATE dokar doknr doktl dokvr INTO key.

ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Dokumentenschlüssel als Text im Selektionsdialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CONCATENATE me->dokar '/' me->doknr '/' me->doktl '/' me->dokvr
    INTO rc_text.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key .
*&----------------------------------------------------------------------
*& Beschreibung: Dokumentschlüssel zerlegen und in die einzelenen
*&               Attribute verteilen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  29.03.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  OBJKEY  Objektschlüssel
*&----------------------------------------------------------------------

* Schlüssel in Attributen ablegen
  dokar = objkey(3).
  doknr = objkey+3(25).
  dokvr = objkey+28(2).
  doktl = objkey+30(3).

ENDMETHOD.


METHOD constructor.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 17:30:25
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.

  me->/cideon/if_plot_bo~name = 'DRAW'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Dokumentverknüpfungstyp "DIS".
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lo_dlt_dis  TYPE REF TO /cideon/cl_plot_dlt_dis,
        lc_key      TYPE string.

* Unterstützt die Dokumentverknüpfungsart "DIS"
  CREATE OBJECT lo_dlt_dis.
  lc_key = lo_dlt_dis->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add(
    key = lc_key
    obj = lo_dlt_dis
    ).
  CALL METHOD lo_dlt_dis->set_dis
    EXPORTING
      ic_doknr = me->doknr
      ic_dokar = me->dokar
      ic_doktl = me->doktl
      ic_dokvr = me->dokvr.
ENDMETHOD.
ENDCLASS.
