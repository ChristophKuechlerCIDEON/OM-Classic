class /CIDEON/CL_XMLRPC_CLIENT definition
  public
  create public .

*"* public components of class /CIDEON/CL_XMLRPC_CLIENT
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !URL type STRING .
  methods EXECUTE
    importing
      !REQUEST type ref to /CIDEON/CL_XMLRPC_REQUEST
    returning
      value(RESPONSE) type ref to /CIDEON/CL_XMLRPC_RESPONSE
    exceptions
      HTTP_ERROR .
*"* protected components of class /CIDEON/CL_XMLRPC_CLIENT
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_XMLRPC_CLIENT
*"* do not include other source files here!!!
private section.

  data M_URL type URL .
  data M_XML_PROCESSOR type ref to /CIDEON/CL_XMLRPC_XMLPROCESSOR .

  methods SEND_HTML_REQUEST
    importing
      !XML type STRING
    returning
      value(RESPONSE) type STRING
    exceptions
      HTTP_ERROR .
ENDCLASS.



CLASS /CIDEON/CL_XMLRPC_CLIENT IMPLEMENTATION.


METHOD constructor.
*& Beschreibung: Erstellt einen neuen Client und speichert die über-
*&               gebene URL des XML-RPC Servers.
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  m_url = url.

  CREATE OBJECT m_xml_processor.
ENDMETHOD.


METHOD execute.
*&----------------------------------------------------------------------
*& Beschreibung: Führt den Request aus und liefert das Ergebnis zurück.
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
  DATA: lc_xml   TYPE string,
        lc_response TYPE string.

* XML für den Request erzeugen
  CALL METHOD m_xml_processor->process_request
    EXPORTING
      request = request
    RECEIVING
      xml = lc_xml.

* HTML Request erzeugen und verschicken
  CALL METHOD send_html_request
    EXPORTING
      xml = lc_xml
    RECEIVING
      response = lc_response
    EXCEPTIONS
      http_error = 1.
  IF sy-subrc = 1.
    RAISE http_error.
  ENDIF.

* Wenn kein HTML fehler, dann das zurückgelieferte XML parsen
  CALL METHOD m_xml_processor->process_response
    EXPORTING
      xml = lc_response
    RECEIVING
      response = response.
ENDMETHOD.


METHOD send_html_request.
*&----------------------------------------------------------------------
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  10.11.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  21.09.2006 HAENSEL Auf Unicode Systemen ist die HTTP Response nur
*&                     halb so lang wie auf Non-Unicode Systemen.
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
  DATA: li_body_length      TYPE i,
        lc_status      TYPE c,
        lc_status_text TYPE c,
        li_response_length  TYPE i,
        ls_request          TYPE sbcbody,
        lt_request          TYPE TABLE OF sbcbody,
        lc_xml              TYPE string,
        li_xml_len          TYPE i,
        lt_response_header  TYPE TABLE OF sbcheader,
        lt_response         TYPE TABLE OF sbcbody,
        lb_unicode          type abap_bool.

  FIELD-SYMBOLS: <lc_response_header>  TYPE sbcheader,
                 <lc_response>         TYPE sbcbody.

  li_body_length = strlen( xml ).


* XML String in eine Tabelle schieben
  lc_xml = xml.
  li_xml_len = strlen( lc_xml ).
  WHILE li_xml_len > 0.
    IF li_xml_len >= 1000.
      ls_request-body = lc_xml(1000).
      SHIFT lc_xml BY 1000 PLACES.
    ELSE.
      ls_request-body = lc_xml(li_xml_len).
      SHIFT lc_xml BY li_xml_len PLACES.
    ENDIF.
    APPEND ls_request TO lt_request.
    li_xml_len = strlen( lc_xml ).
  ENDWHILE.


  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                      = m_url
      request_entity_body_length        = li_body_length
*      RFC_DESTINATION                   = l_RFC_DESTINATION
*     PROXY                             =
*     PROXY_USER                        =
*     PROXY_PASSWORD                    =
*     USER                              =
*     PASSWORD                          =
*     BLANKSTOCRLF                      =
   IMPORTING
     status_code                       = lc_status
     status_text                       = lc_status_text	
     response_entity_body_length       = li_response_length
   TABLES
     request_entity_body               = lt_request
     response_entity_body              = lt_response
     response_headers                  = lt_response_header
*     REQUEST_HEADERS                   = lt_REQUEST_HEADER
   EXCEPTIONS
     connect_failed                    = 1
     timeout                           = 2
     internal_error                    = 3
     tcpip_error                       = 4
     system_failure                    = 5
     communication_failure             = 6
     OTHERS                            = 7.
  IF sy-subrc <> 0.
    RAISE http_error.
  ENDIF.

* Prüfen, ob der HTTP Returncode 200 zurückgeliefert wurde.
  READ TABLE lt_response_header INDEX 1
    ASSIGNING <lc_response_header>.
  IF sy-subrc = 0.
    IF NOT <lc_response_header> CS '200 OK'.
      RAISE http_error.
    ENDIF.
  ENDIF.

* Response in einen String verpacken
  LOOP AT lt_response ASSIGNING <lc_response>.
    CONCATENATE response <lc_response> INTO response.
  ENDLOOP.

* Überflüssigen Schwanz abschneiden.
  CALL FUNCTION '/CIDEON/UNICODE_SYSTEM'
       IMPORTING
            eb_unicode = lb_unicode.
  IF lb_unicode = abap_true.
    li_response_length = li_response_length div 2.
  ENDIF.
  IF NOT response IS INITIAL.
    response = response(li_response_length).
  ENDIF.

ENDMETHOD.
ENDCLASS.
