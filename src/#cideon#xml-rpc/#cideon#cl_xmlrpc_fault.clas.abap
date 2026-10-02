class /CIDEON/CL_XMLRPC_FAULT definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_XMLRPC_FAULT
*"* do not include other source files here!!!
public section.

  data CODE type I read-only .
  data STRING type STRING read-only .

  methods CONSTRUCTOR
    importing
      !PARAMETER type ref to /CIDEON/CL_XMLRPC_PARAMETER
    exceptions
      INVALID_FAULT_FORMAT .
*"* protected components of class /CIDEON/CL_XMLRPC_FAULT
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_XMLRPC_FAULT
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_XMLRPC_FAULT IMPLEMENTATION.


METHOD constructor.
*& Beschreibung: Es werden die Fehlerinformationen aus dem übergebenen
*&               XML-RPC Parameter extrahiert. Dieser muß laut
*&               Spezifikation eine Struktur sein, die die Werte
*&               'faultCode' und 'faultString' enthält.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_param   TYPE REF TO /cideon/cl_xmlrpc_parameter.

  IF parameter->is_structure( ) = abap_true.

*   Strukturelement 'faultCode' auslesen
    CALL METHOD parameter->get_structure_element
      EXPORTING
        name = 'faultCode'
      RECEIVING
        element = lo_param
      EXCEPTIONS
        element_not_exists = 1
        no_structure       = 2.
    IF sy-subrc > 0.
      RAISE invalid_fault_format.
    ENDIF.
    me->code = lo_param->value_as_integer( ).

*   Strukturelement 'faultString' auslesen
    CALL METHOD parameter->get_structure_element
      EXPORTING
        name = 'faultString'
      RECEIVING
        element = lo_param
      EXCEPTIONS
        element_not_exists = 1
        no_structure       = 2.
    IF sy-subrc > 0.
      RAISE invalid_fault_format.
    ENDIF.
    me->string = lo_param->value_as_string( ).
  ELSE.
    RAISE invalid_fault_format.
  ENDIF.
ENDMETHOD.
ENDCLASS.
