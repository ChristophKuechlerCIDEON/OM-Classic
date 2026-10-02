class /CIDEON/CL_XMLRPC_RESPONSE definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_XMLRPC_RESPONSE
*"* do not include other source files here!!!
public section.

  data FAULT type ref to /CIDEON/CL_XMLRPC_FAULT read-only .
  data VALUE type ref to /CIDEON/CL_XMLRPC_PARAMETER read-only .

  methods CONSTRUCTOR
    importing
      !PARAMETER type ref to /CIDEON/CL_XMLRPC_PARAMETER .
  type-pools ABAP .
  methods IS_FAULT
    returning
      value(FAULT) type ABAP_BOOL .
*"* protected components of class /CIDEON/CL_XMLRPC_RESPONSE
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_XMLRPC_RESPONSE
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_XMLRPC_RESPONSE IMPLEMENTATION.


METHOD constructor.
*& Beschreibung: Es wird aus dem übergebenen XML-RPC Parameter ein
*&               Response Objekt erzeugt.
*&               Der Parameter kann ein Rückgabeparameter oder ein Fault
*&               sein. Das wird hier analysiert und ist dann abrufbar.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_fault  TYPE REF TO /cideon/cl_xmlrpc_fault.

* Prüfen, ob es sich um einen Fault handelt, der übergeben wurde
  CREATE OBJECT lo_fault
    EXPORTING
      parameter = parameter
    EXCEPTIONS
      invalid_fault_format = 1.
  IF sy-subrc = 0.
*   Es ist ein Fault
    fault = lo_fault.
  ELSE.
*   Kein Fault, also normaler parameter
    value = parameter.
  ENDIF.
ENDMETHOD.


METHOD is_fault.
*& Beschreibung: Prüft, ob die Server Antwort eine Fehlernachricht ent-
*&               hält.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  IF me->fault IS INITIAL.
    fault = abap_false.
  ELSE.
    fault = abap_true.
  ENDIF.
ENDMETHOD.
ENDCLASS.
