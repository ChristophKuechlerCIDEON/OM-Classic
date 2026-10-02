class /CIDEON/CL_XMLRPC_XMLPROCESSOR definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_XMLRPC_XMLPROCESSOR
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .
  methods PROCESS_REQUEST
    importing
      !REQUEST type ref to /CIDEON/CL_XMLRPC_REQUEST
    returning
      value(XML) type STRING .
  methods PROCESS_RESPONSE
    importing
      !XML type STRING
    returning
      value(RESPONSE) type ref to /CIDEON/CL_XMLRPC_RESPONSE
    exceptions
      WRONG_XML_FORMAT .
*"* protected components of class /CIDEON/CL_XMLRPC_XMLPROCESSOR
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_XMLRPC_XMLPROCESSOR
*"* do not include other source files here!!!
private section.

  data M_IXML type ref to IF_IXML .
  data M_ENCODING type ref to IF_IXML_ENCODING .
  data M_STREAM_FACTORY type ref to IF_IXML_STREAM_FACTORY .

  methods GETTYPETAG
    importing
      !TYPE type I
    returning
      value(TAG) type STRING .
  methods CREATE_PARAMETER_FROM_XML
    importing
      !XML_ELEMENT type ref to IF_IXML_NODE
    returning
      value(PARAMETER) type ref to /CIDEON/CL_XMLRPC_PARAMETER
    exceptions
      WRONG_XML_FORMAT .
  methods GETTYPEFROMTAG
    importing
      !TAG type STRING
    returning
      value(TYPE) type I
    exceptions
      UNKNOWN_TYPE .
  methods CREATE_STRUCTURE_FROM_XML
    importing
      !XML_NODE type ref to IF_IXML_NODE
    returning
      value(STRUCTURE) type ref to /CIDEON/CL_OO_COLLECTION
    exceptions
      WRONG_XML_FORMAT .
  methods CREATE_ARRAY_FROM_XML
    importing
      !XML_NODE type ref to IF_IXML_NODE
    returning
      value(ARRAY) type ref to /CIDEON/CL_OO_ARRAY
    exceptions
      WRONG_XML_FORMAT .
ENDCLASS.



CLASS /CIDEON/CL_XMLRPC_XMLPROCESSOR IMPLEMENTATION.


METHOD constructor.
*&----------------------------------------------------------------------
*& Beschreibung: Initialisierung des XML Frameworks
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
  CLASS cl_ixml DEFINITION LOAD.

  DATA: lc_encoding_type TYPE string.

  m_ixml = cl_ixml=>create( ).

* Encoding erzeugen
  lc_encoding_type = 'ISO-8859-1'.
  m_encoding = m_ixml->create_encoding(
    character_set = lc_encoding_type
    byte_order = 0
  ).

* Stream Factory erzeugen
  m_stream_factory = m_ixml->create_stream_factory( ).

ENDMETHOD.


METHOD create_array_from_xml.
*& Beschreibung: Extrahiert die Array Daten aus dem XML Modell und
*&               liefert das entsprechende Array zurück.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_node_data   TYPE REF TO if_ixml_node,
        lo_node_value  TYPE REF TO if_ixml_node,
        lo_values      TYPE REF TO if_ixml_node_list,
        lo_value_iter TYPE REF TO if_ixml_node_iterator,
        lo_parameter   TYPE REF TO /cideon/cl_xmlrpc_parameter.

  CHECK NOT xml_node IS INITIAL.
  CREATE OBJECT array.

* <data> Element holen
  lo_node_data = xml_node->get_first_child( ).
  IF lo_node_data IS INITIAL
    OR NOT lo_node_data->get_name( ) = 'data'.
    RAISE wrong_xml_format.
  ENDIF.

* Alle <value> Elemente lesen und die Parameter erzeugen
  lo_values = lo_node_data->get_children( ).
  IF lo_values IS INITIAL.
    RAISE wrong_xml_format.
  ENDIF.
  lo_value_iter = lo_values->create_iterator( ).
  DO.
    lo_node_value = lo_value_iter->get_next( ).
    IF lo_node_value IS INITIAL
      OR NOT lo_node_value->get_name( ) = 'value'.
      EXIT.
    ENDIF.

*   Aus dem <value> Tag den Parameter erzeugen
    CALL METHOD create_parameter_from_xml
      EXPORTING
        xml_element = lo_node_value
      RECEIVING
        parameter = lo_parameter
      EXCEPTIONS
        wrong_xml_format = 1.
    IF sy-subrc = 1.
      RAISE wrong_xml_format.
    ENDIF.

    CALL METHOD array->add( io_object = lo_parameter ).
  ENDDO.
ENDMETHOD.


METHOD create_parameter_from_xml.
*& Beschreibung: Es muß ein XML Element des Types <VALUE> übergeben
*&               werden. Daraus wird dann das entspr. XML-RPC Parameter
*&               Objekt erzeugt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
INTERFACE /cideon/if_xmlrpc_types LOAD.

  DATA: lo_el_child  TYPE REF TO if_ixml_node,
        lo_node_value TYPE REF TO if_ixml_node,
        li_node_type TYPE i,
        lc_value     TYPE string,
        lc_type      TYPE string,
        li_type      TYPE i,
        lo_structure TYPE REF TO /cideon/cl_oo_collection,
        lo_array     TYPE REF TO /cideon/cl_oo_array.

* Erstes untergeordneten Knoten und dessen Typ ermitteln
  lo_el_child ?= xml_element->get_first_child( ).
  IF lo_el_child IS INITIAL.
*   Wenn kein untergeordneter Knoten, dann ist es ein leerer String
    CREATE OBJECT parameter
      EXPORTING
        value = ''.
    EXIT.
  ENDIF.
  li_node_type = lo_el_child->get_type( ).
  CASE li_node_type.
    WHEN if_ixml_node=>co_node_text.
*     Es wurde direkt ein String als Wert zurückgeliefert.
      lc_value = lo_el_child->get_value( ).
      CREATE OBJECT parameter
        EXPORTING
          value = lc_value.
    WHEN if_ixml_node=>co_node_element.
*     Weiteres Element innerhalb des <VALUE> Tags, das den
*     Typ spezifiziert.
      lc_type = lo_el_child->get_name( ).
      li_type = gettypefromtag( lc_type ).
      IF li_type = /cideon/if_xmlrpc_types=>structure.
*       Parameter ist eine Struktur
        CALL METHOD create_structure_from_xml
          EXPORTING
            xml_node = lo_el_child
          RECEIVING
            structure = lo_structure
          EXCEPTIONS
            wrong_xml_format = 1.
        IF sy-subrc = 1.
          RAISE wrong_xml_format.
        ENDIF.

        CREATE OBJECT parameter
          EXPORTING
            value = lo_structure
            type = /cideon/if_xmlrpc_types=>structure.

      ELSEIF li_type = /cideon/if_xmlrpc_types=>array.
*       Parameter ist ein Array
        CALL METHOD create_array_from_xml
          EXPORTING
            xml_node = lo_el_child
          RECEIVING
            array = lo_array
          EXCEPTIONS
            wrong_xml_format = 1.
        IF sy-subrc = 1.
          RAISE wrong_xml_format.
        ENDIF.

        CREATE OBJECT parameter
          EXPORTING
            value = lo_array
            type = /cideon/if_xmlrpc_types=>array.
      ELSE.
*       Parameter ist ein einfacher Datentyp
        lo_node_value = lo_el_child->get_first_child( ).
        lc_value = lo_node_value->get_value( ).
        CREATE OBJECT parameter
          EXPORTING
            value = lc_value
            type  = li_type.
      ENDIF.
  ENDCASE.
ENDMETHOD.


METHOD create_structure_from_xml .
*& Beschreibung: Ermittelt die Daten aus dem übergebenen XML Node
*&               <STRUCT> die Strukturdaten und erzeugt eine Collection
*&               mit /CIDEON/CL_XMLRPC_PARAMETER Objekten.
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_members     TYPE REF TO if_ixml_node_list,
        lo_member_iter TYPE REF TO if_ixml_node_iterator,
        lo_member_children TYPE REF TO if_ixml_node_list,
        lo_node_member TYPE REF TO if_ixml_node,
        lo_node_name TYPE REF TO if_ixml_node,
        lc_name        TYPE string,
        lo_node_value  TYPE REF TO if_ixml_node,
        lo_parameter   TYPE REF TO /cideon/cl_xmlrpc_parameter.

  CHECK NOT xml_node IS INITIAL.
  CREATE OBJECT structure.

* Alle <member> Elemente holen
  lo_members = xml_node->get_children( ).
  lo_member_iter = lo_members->create_iterator( ).
  DO.
    lo_node_member = lo_member_iter->get_next( ).
    IF lo_node_member IS INITIAL. EXIT. ENDIF.

    lo_member_children = lo_node_member->get_children( ).
    IF lo_member_children IS INITIAL.
      RAISE wrong_xml_format.
    ENDIF.

*   <Name> Element
    lo_node_name = lo_member_children->get_item( 0 ).
    IF lo_node_name IS INITIAL OR
       NOT lo_node_name->get_name( ) = 'name'.
      RAISE wrong_xml_format.
    ENDIF.
    lc_name = lo_node_name->get_value( ).

*   <Value> Element
    lo_node_value = lo_member_children->get_item( 1 ).
    IF lo_node_value IS INITIAL OR
      NOT lo_node_value->get_name( ) = 'value'.
      RAISE wrong_xml_format.
    ENDIF.
    lo_parameter = create_parameter_from_xml( lo_node_value ).

*   Eintrag in die Struktur Collection erzeugen
    CALL METHOD structure->add
      EXPORTING
        key = lc_name
        obj = lo_parameter.
  ENDDO.
ENDMETHOD.


METHOD gettypefromtag.
*& Beschreibung: Ermittelt aus dem Wert des XML Tags, das den Datentyp
*&               enthält den XML-RPC Datentyp. Es werden die Konstanten
*&               der Schnittstelle /CIDEON/IF_XMLRPC_TYPES verwendet.
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
INTERFACE /cideon/if_xmlrpc_types LOAD.

  CASE tag.
    WHEN 'string'.
      type = /cideon/if_xmlrpc_types=>string.
    WHEN 'int' OR 'i4'.
      type = /cideon/if_xmlrpc_types=>integer.
    WHEN 'boolean'.
      type = /cideon/if_xmlrpc_types=>boolean.
    WHEN 'double'.
      type = /cideon/if_xmlrpc_types=>double.
    WHEN 'struct'.
      type = /cideon/if_xmlrpc_types=>structure.
    WHEN 'array'.
      type = /cideon/if_xmlrpc_types=>array.
    WHEN OTHERS.
      RAISE unknown_type.
  ENDCASE.

ENDMETHOD.


METHOD gettypetag.
*&----------------------------------------------------------------------
*& Beschreibung: Liefert das Tag für den Parametertyp
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
      tag = 'int'.
    WHEN /cideon/if_xmlrpc_types=>boolean.
      tag = 'boolean'.
    WHEN /cideon/if_xmlrpc_types=>double.
      tag = 'double'.
    WHEN /cideon/if_xmlrpc_types=>structure.
      tag = 'struct'.
    WHEN /cideon/if_xmlrpc_types=>array.
      tag = 'array'.
    WHEN OTHERS.
      tag = 'string'.
  ENDCASE.
ENDMETHOD.


METHOD process_request.
*&----------------------------------------------------------------------
*& Beschreibung: Erzeugt aus dem übergebenen XML-RPC Request einen XML
*&               String.
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
  TYPES:  xmlline(1024) TYPE  c.

  DATA: lo_document  TYPE REF TO if_ixml_document,
        lo_element   TYPE REF TO if_ixml_element,
        lo_el_methn  TYPE REF TO if_ixml_element,
        lo_el_params TYPE REF TO if_ixml_element,
        lc_methodname TYPE string,
        lo_iter      TYPE REF TO /cideon/if_oo_iterator,
        lo_el_param  TYPE REF TO if_ixml_element,
        lo_el_value  TYPE REF TO if_ixml_element,
        lo_el_type   TYPE REF TO if_ixml_element,
        lc_type_tag  TYPE string,
        lo_parameter TYPE REF TO /cideon/cl_xmlrpc_parameter,
        lo_outstream TYPE REF TO if_ixml_ostream,
        lc_value     TYPE string,
        lt_data      TYPE TABLE OF xmlline,
        lo_renderer   TYPE REF TO if_ixml_renderer,
        li_size      TYPE i,
        li_length    TYPE i.

  FIELD-SYMBOLS: <ls_data> TYPE xmlline.

  lo_document = m_ixml->create_document( ).

* Tag <methodCall>
  CALL METHOD lo_document->create_element
    EXPORTING
      name = 'methodCall'
    RECEIVING
      rval = lo_element.
  CALL METHOD lo_document->append_child
    EXPORTING
      new_child = lo_element.

* Tag <methodName>
  lc_methodname = request->getmethodname( ).
  CALL METHOD lo_document->create_element
    EXPORTING
      name = 'methodName'
    RECEIVING
      rval = lo_el_methn.
  CALL METHOD lo_el_methn->set_value(
    value = lc_methodname
  ).
  CALL METHOD lo_element->append_child( new_child = lo_el_methn ).

* Tag <params>
  CALL METHOD lo_document->create_element
    EXPORTING
      name = 'params'
    RECEIVING
      rval = lo_el_params.
  CALL METHOD lo_element->append_child( new_child = lo_el_params ).

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* <PARAM> Tag für jeden übergebenen Parameter erzeugen
  lo_iter = request->create_param_iterator( ).
  IF NOT lo_iter IS INITIAL.
    WHILE lo_iter->has_next( ) = abap_true.
      lo_parameter ?= lo_iter->get_next( ).

      CALL METHOD lo_document->create_element
        EXPORTING
          name = 'param'
        RECEIVING
          rval = lo_el_param.
      CALL METHOD lo_document->create_element
        EXPORTING
          name = 'value'
        RECEIVING
          rval = lo_el_value.

      lc_type_tag = gettypetag( lo_parameter->type ).
      CALL METHOD lo_document->create_element
        EXPORTING
          name = lc_type_tag
        RECEIVING
          rval = lo_el_type.
      lc_value = lo_parameter->value_as_string( ).
      CALL METHOD lo_el_type->set_value(
        value = lc_value
      ).
      CALL METHOD lo_el_value->append_child( new_child = lo_el_type ).
      CALL METHOD lo_el_param->append_child( new_child = lo_el_value ).
      CALL METHOD lo_el_params->append_child( new_child = lo_el_param ).
    ENDWHILE.
  ENDIF.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Aus dem DOM einen XML String generieren
  lo_outstream = m_stream_factory->create_ostream_itable(
    lt_data
  ).
  CALL METHOD lo_outstream->set_encoding( encoding = m_encoding ).
  CALL METHOD lo_outstream->set_pretty_print( ).

  CALL METHOD lo_document->render( ostream = lo_outstream ).
  li_size = lo_outstream->get_num_written_raw( ).

  LOOP AT lt_data ASSIGNING <ls_data>.
    li_length = strlen( <ls_data> ).
    IF li_size >= li_length.
*     Komplette Zeile nehmen und an das Ergebnis anhängen
      CONCATENATE xml <ls_data> INTO xml.
    ELSE.
*     Nur die Anzahl li_size noch anhängen.
      CONCATENATE xml <ls_data>(li_size) INTO xml.
    ENDIF.
    li_size = li_size - li_length.
  ENDLOOP.
ENDMETHOD.


METHOD process_response.
*& Beschreibung: Aus dem Response XML, das vom Server gesendet wurde,
*&               wird jetzt ein entsprechendes Objekt erstellt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_response_doc  TYPE REF TO if_ixml_document,
        lo_instream      TYPE REF TO if_ixml_istream,
        ls_response      TYPE sbcbody,
        lt_response      TYPE TABLE OF sbcbody,
        li_stream_len    TYPE i,
        lc_xml           TYPE string,
        li_xml_len       TYPE i,
        lo_parser        TYPE REF TO if_ixml_parser,
        lo_parameter     TYPE REF TO /cideon/cl_xmlrpc_parameter,
        lo_el_param      TYPE REF TO if_ixml_element,
        lo_el_fault      TYPE REF TO if_ixml_element,
        li_rval          type i.

* XML String in eine Tabelle schieben
  lc_xml = xml.
  li_xml_len = strlen( lc_xml ).
  li_stream_len = li_xml_len.
  WHILE li_xml_len > 0.
    IF li_xml_len >= 1000.
      ls_response-body = lc_xml(1000).
      SHIFT lc_xml BY 1000 PLACES.
    ELSE.
      ls_response-body = lc_xml(li_xml_len).
      SHIFT lc_xml BY li_xml_len PLACES.
    ENDIF.
    APPEND ls_response TO lt_response.
    li_xml_len = strlen( lc_xml ).
  ENDWHILE.

* XML Document und einen Stream erzeugen
  lo_response_doc = m_ixml->create_document( ).
  lo_instream = m_stream_factory->create_istream_itable(
    size  = li_stream_len
    table = lt_response
  ).
*  li_stream_len = lo_instream->get_num_read_raw( ).

* Parser erzeugen und den Stream parsen
  lo_parser = m_ixml->create_parser(
    stream_factory  = m_stream_factory
    istream         = lo_instream
    document        = lo_response_doc
  ).
  li_rval = lo_parser->parse( ).
  if not li_rval = 0.
    raise wrong_xml_format.
  endif.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Auf ein Fault Element in der Antwort prüfen
  lo_el_fault = lo_response_doc->find_from_path(
    path = '/methodResponse/fault/value'
  ).
  IF NOT lo_el_fault IS INITIAL.
    lo_parameter = create_parameter_from_xml(
      xml_element = lo_el_fault
    ).
  else.

*   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*   Rückgabeparameter extrahieren, sofern vorhanden
    lo_el_param = lo_response_doc->find_from_path(
      path = '/methodResponse/params/param/value'
    ).
    IF NOT lo_el_param IS INITIAL.
*     Parameter gefunden
      lo_parameter = create_parameter_from_xml(
        xml_element = lo_el_param
      ).
    ENDIF.

  ENDIF.

* XML-RPC Response Objekt erstellen
  CREATE OBJECT response
    EXPORTING
      parameter = lo_parameter.
ENDMETHOD.
ENDCLASS.
