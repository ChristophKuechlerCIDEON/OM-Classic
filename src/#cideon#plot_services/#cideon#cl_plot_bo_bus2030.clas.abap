class /CIDEON/CL_PLOT_BO_BUS2030 definition
  public
  inheriting from /CIDEON/CA_PLOT_BO_VBAK
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2030
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2030
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2030
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2030 IMPLEMENTATION.


METHOD constructor.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 17:07:52
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.

  me->/cideon/if_plot_bo~name = 'BUS2030'.
ENDMETHOD.
ENDCLASS.
