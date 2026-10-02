class /CIDEON/CL_PLOT_BO_BUS2012 definition
  public
  inheriting from /CIDEON/CA_PLOT_BO_EKKO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2012
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  methods CONSTRUCTOR .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2012
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2012
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2012 IMPLEMENTATION.


METHOD constructor.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 17:03:03
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CALL METHOD super->constructor.

  me->/cideon/if_plot_bo~name = 'BUS2012'.
ENDMETHOD.
ENDCLASS.
