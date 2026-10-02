class /CIDEON/CLA_PLOT_BO_BILL definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  abstract
  create public .

*"* public components of class /CIDEON/CLA_PLOT_BO_BILL
*"* do not include other source files here!!!
public section.

  data NUMBER type STNUM read-only .
  data ALTERNATIVE type STALT read-only .

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR
    importing
      !NUMBER type STNUM
      !ALTERNATIVE type STALT
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_ICON
    redefinition .
*"* protected components of class /CIDEON/CLA_PLOT_BO_BILL
*"* do not include other source files here!!!
protected section.

  class-data ICON type TV_IMAGE .
*"* private components of class /CIDEON/CLA_PLOT_BO_BILL
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CLA_PLOT_BO_BILL IMPLEMENTATION.


method /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

endmethod.


METHOD /cideon/if_plot_bo~get_icon.
*& Beschreibung: Icon für Stücklisten
*&
*& Autor:        HAENSEL
*& Angelegt am:  01.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_icon = me->icon.
ENDMETHOD.


METHOD class_constructor.
************************************************************************
* Beschreibung: Ikone für Stücklisten statisch definieren.
*
* Autor:        Heiko Hänsel
* Angelegt am:  29.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  /cideon/cla_plot_bo_bill=>icon = '@AP@'.
ENDMETHOD.


METHOD constructor.
************************************************************************
* Beschreibung: Initialisiert die allgemeinen Attribute einer Stückliste
*
* Autor:        Heiko Hänsel
* Angelegt am:  29.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  15.04.2005   HAENSEL  Übernahme von Zusatzdaten
************************************************************************

* Konstruktor der Basisklasse
  CALL METHOD super->constructor
    exporting
      io_additional_data = io_additional_data.

  me->number      = number.
  me->alternative = alternative.
ENDMETHOD.
ENDCLASS.
