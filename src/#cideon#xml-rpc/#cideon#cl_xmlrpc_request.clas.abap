class /CIDEON/CL_XMLRPC_REQUEST definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_XMLRPC_REQUEST
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !METHOD type STRING
      !PARAMS type ref to /CIDEON/CL_OO_ARRAY optional .
  methods GETMETHODNAME
    returning
      value(METHODNAME) type STRING .
  methods ADD_PARAMETER
    importing
      !VALUE type ANY
      !TYPE type I default 0 .
  methods CREATE_PARAM_ITERATOR
    returning
      value(ITERATOR) type ref to /CIDEON/IF_OO_ITERATOR .
*"* protected components of class /CIDEON/CL_XMLRPC_REQUEST
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_XMLRPC_REQUEST
*"* do not include other source files here!!!
private section.

  data M_PARAMETERS type ref to /CIDEON/CL_OO_ARRAY .
  data M_METHOD type STRING .
ENDCLASS.



CLASS /CIDEON/CL_XMLRPC_REQUEST IMPLEMENTATION.


METHOD add_parameter.
*&----------------------------------------------------------------------
*& Beschreibung: Fügt einen Parameterwert zum Request hinzu. Es können
*&               beliebige einfache Datentypen übergeben werden.
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
  DATA: lo_parameter TYPE REF TO /cideon/cl_xmlrpc_parameter.

  CREATE OBJECT lo_parameter
    EXPORTING
      value     = value
      type      = type.
  CALL METHOD m_parameters->add( io_object = lo_parameter ).

ENDMETHOD.


METHOD constructor.
*&----------------------------------------------------------------------
*& Beschreibung: Initialisierung des Requests
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------

  m_method = method.

* Parameter übernehmen, sofern vorhanden
  IF params IS INITIAL.
    CREATE OBJECT m_parameters.
  ELSE.
    m_parameters = params.
  ENDIF.

ENDMETHOD.


METHOD create_param_iterator.
*&----------------------------------------------------------------------
*& Beschreibung: Erzeugt einen Iterator über das Parameter Array
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
  iterator = m_parameters->create_iterator( ).
ENDMETHOD.


METHOD getmethodname.
*&----------------------------------------------------------------------
*& Beschreibung: Liefert den Namen der Methode des Requests
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
  methodname = m_method.
ENDMETHOD.
ENDCLASS.
