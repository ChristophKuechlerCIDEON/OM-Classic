class /CIDEON/CL_XMLRPC_PARAMETER definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_XMLRPC_PARAMETER
*"* do not include other source files here!!!
public section.

  data TYPE type I read-only .
  data ARRAY type ref to /CIDEON/CL_OO_ARRAY read-only .

  methods CONSTRUCTOR
    importing
      !VALUE type ANY
      !TYPE type I default 0
    exceptions
      UNKNOWN_TYPE .
  methods VALUE_AS_STRING
    returning
      value(VALUE) type STRING .
  methods VALUE_AS_INTEGER
    returning
      value(VALUE) type INT4 .
  type-pools ABAP .
  methods IS_STRUCTURE
    returning
      value(STRUCTURE) type ABAP_BOOL .
  methods GET_STRUCTURE
    returning
      value(STRUCTURE) type ref to /CIDEON/CL_OO_COLLECTION .
  methods GET_STRUCTURE_ELEMENT
    importing
      !NAME type STRING
    returning
      value(ELEMENT) type ref to /CIDEON/CL_XMLRPC_PARAMETER
    exceptions
      ELEMENT_NOT_EXISTS
      NO_STRUCTURE .
  methods IS_ARRAY
    returning
      value(IS_ARRAY) type ABAP_BOOL .
  methods GET_ARRAY
    returning
      value(ARRAY) type ref to /CIDEON/CL_OO_ARRAY .
*"* protected components of class /CIDEON/CL_XMLRPC_PARAMETER
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_XMLRPC_PARAMETER
*"* do not include other source files here!!!
private section.

  data VALUE_STRING type STRING .
  data VALUE_INT type INT4 .
  data STRUCTURE type ref to /CIDEON/CL_OO_COLLECTION .
ENDCLASS.



CLASS /CIDEON/CL_XMLRPC_PARAMETER IMPLEMENTATION.


METHOD constructor.
*&----------------------------------------------------------------------
*& Beschreibung: Übernimmt den Wert und speichert ihn typgerecht.
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
INTERFACE /cideon/if_xmlrpc_types LOAD.

  CASE type.
    WHEN /cideon/if_xmlrpc_types=>string.
      value_string = value.
    WHEN /cideon/if_xmlrpc_types=>integer.
      value_int = value.
    WHEN /cideon/if_xmlrpc_types=>structure.
      me->structure ?= value.
    when /cideon/if_xmlrpc_types=>array.
      me->array ?= value.
    when others.
      raise unknown_type.
  ENDCASE.
  me->type = type.
ENDMETHOD.


METHOD get_array.
*& Beschreibung: Liefert das Array zurück, wenn es sich bei dem Wert
*&               um ein Array handelt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  IF is_array( ) = abap_true.
    array = me->array.
  ENDIF.
ENDMETHOD.


METHOD get_structure.
*& Beschreibung: Liefert die Struktur als Collection, wenn es eine
*&               Struktur ist.
*&
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  IF is_structure( ) = abap_true.
    structure = me->structure.
  ENDIF.
ENDMETHOD.


METHOD get_structure_element.
*& Beschreibung: Es wird versucht das Element anhand des Namens aus der
*&               Struktur zu lesen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_structure TYPE REF TO /cideon/cl_oo_collection,
        lo_obj       TYPE REF TO object.

  IF me->is_structure( ) = abap_true.
    lo_structure = me->get_structure( ).
    CALL METHOD lo_structure->get_by_key
      EXPORTING
        key = name
      RECEIVING
        item = lo_obj
      EXCEPTIONS
        invalid_key = 1.
    IF sy-subrc = 1.
      RAISE element_not_exists.
    ENDIF.
    element ?= lo_obj.
  ELSE.
    RAISE no_structure.
  ENDIF.
ENDMETHOD.


METHOD is_array.
*& Beschreibung: Prüft, ob es sich bei dem Parameter um ein Array
*&               handelt und liefert True zurück, wenn es eins ist.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  IF me->array IS INITIAL.
    is_array = abap_false.
  ELSE.
    is_array = abap_true.
  ENDIF.
ENDMETHOD.


METHOD is_structure.
*& Beschreibung: Liefert True, wenn der XML-RPC Parameter eine Struktur
*&               ist.
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  IF me->structure IS INITIAL.
    structure = abap_false.
  ELSE.
    structure = abap_true.
  ENDIF.
ENDMETHOD.


METHOD value_as_integer.
*&----------------------------------------------------------------------
*& Beschreibung: Liefert den Parameterwert als Integer.
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
INTERFACE /cideon/if_xmlrpc_types LOAD.

  CASE type.
    WHEN /cideon/if_xmlrpc_types=>integer.
      value = value_int.
  ENDCASE.
ENDMETHOD.


METHOD value_as_string .
*&----------------------------------------------------------------------
*& Beschreibung: Liefert den Parameterwert untypisiert.
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
INTERFACE /cideon/if_xmlrpc_types LOAD.

  CASE type.
    WHEN /cideon/if_xmlrpc_types=>string.
      value = value_string.
    when /cideon/if_xmlrpc_types=>integer.
      value = value_int.
  ENDCASE.
ENDMETHOD.
ENDCLASS.
