FUNCTION /cideon/pli_get_dist.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_URL) TYPE  CHAR255
*"     VALUE(I_CFG) TYPE  CHAR255
*"     VALUE(I_USER) TYPE  CHAR255
*"     VALUE(I_PASSWORD) TYPE  CHAR255
*"  TABLES
*"      ITAB_VERTEILER STRUCTURE  /CIDEON/STRING
*"      ITAB_DESCRIPTION STRUCTURE  /CIDEON/STRING
*"  EXCEPTIONS
*"      ERROR
*"      HTTP_ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:
*           Heiko Hänsel
*           Heiko.Haensel@cideon.de
*-----------------------------------------------------------------------
* Journal
* 14.11.2005 - Erstellungen
* 13.12.2005 - Rückgabe der Fehlermeldungen
* 27.03.2006 - Anpassung auf Änderungen PlotInfo 6.0.0.24
* 23.06.2006 - Fehler:
*              lo_array_iter nicht initialisiert
* 17.12.2008 - SP87
*              Abfrage des Beschreibung...
*-----------------------------------------------------------------------
* Lesen der Verteiler über PlotInfoServer
*
*-----------------------------------------------------------------------

INTERFACE /cideon/if_xmlrpc_types LOAD.

  TYPE-POOLS: abap.

  DATA: go_xmlrpc_cl  TYPE REF TO /cideon/cl_xmlrpc_client.

  DATA: gc_uri(80) TYPE c VALUE 'HTTP://192.168.10.192:8080/'.


  DATA: lc_url         TYPE string,
        lo_request     TYPE REF TO /cideon/cl_xmlrpc_request,
        lo_response    TYPE REF TO /cideon/cl_xmlrpc_response,
        lc_version     TYPE string,
        lo_xmlrpc_val  TYPE REF TO /cideon/cl_xmlrpc_parameter,
        li_user_id     TYPE i,
        li_conf_id     TYPE i,
        lo_array_iter  TYPE REF TO /cideon/if_oo_iterator,
        lo_structure   TYPE REF TO /cideon/cl_oo_collection,
        lo_distr_desc  TYPE REF TO /cideon/cl_xmlrpc_parameter,
        lo_distr_name  TYPE REF TO /cideon/cl_xmlrpc_parameter,
        lc_distr_name  TYPE string,
        lc_distr_desc  TYPE string.

*WA
  DATA: wa_verteiler LIKE itab_verteiler.
  DATA: wa_description LIKE itab_description.

*Initialisierung
  CLEAR itab_verteiler.

  IF i_url IS INITIAL.
  ELSE.
    gc_uri = i_url.
  ENDIF.

  lc_url = gc_uri.
  CREATE OBJECT go_xmlrpc_cl
    EXPORTING
      url = lc_url.

* Variablen umbelegen
  gc_uri = i_url.


* Request für die Versionsabfrage erzeugen und ausführen
*  WRITE: / 'Starte: PlotInfoService.GetVersion'.
  CREATE OBJECT lo_request
    EXPORTING
      method = 'PlotInfoService.GetVersion'.
  CALL METHOD go_xmlrpc_cl->execute
    EXPORTING
      request = lo_request
    RECEIVING
      response = lo_response
    EXCEPTIONS
      http_error = 1.
  IF sy-subrc = 0.
    IF lo_response->is_fault( ) = abap_true.
*      PERFORM trace_fault USING lo_response->fault.
      MESSAGE e055(/cideon/plot_admin)
        WITH '' '' '' ''
        RAISING http_error.
      RAISE error.
    ELSE.
      lc_version = lo_response->value->value_as_string( ).
*      WRITE:/ 'Version', lc_version.
    ENDIF.
  ELSE.
    MESSAGE e055(/cideon/plot_admin)
      WITH '' '' '' ''
      RAISING http_error.
*    RAISE http_error.
*    WRITE: / 'HTTP Fehler'.
    EXIT.
  ENDIF.

* Login am Plot Server durchführen
*  WRITE: / 'Starte: PlotInfoService.Login'.
  CREATE OBJECT lo_request
    EXPORTING
      method = 'PlotInfoService.Login'.
*  CALL METHOD lo_request->add_parameter( value = 'testcfg' ).
*  CALL METHOD lo_request->add_parameter( value = 'test' ).
*  CALL METHOD lo_request->add_parameter( value = 'test' ).
  CALL METHOD lo_request->add_parameter( value = i_cfg ).
  CALL METHOD lo_request->add_parameter( value = i_user ).
  CALL METHOD lo_request->add_parameter( value = i_password ).
  CALL METHOD lo_request->add_parameter(
* 27.03.2006 CKR
* Tab, ob Pre, Post, Out, Pre SAP ist
*    value = 1
    value = 4
* 27.03.2006 /CKR
    type = /cideon/if_xmlrpc_types=>integer
  ).
  CALL METHOD go_xmlrpc_cl->execute
    EXPORTING
      request = lo_request
    RECEIVING
      response = lo_response
    EXCEPTIONS
      http_error = 1.
  IF sy-subrc = 0.
    IF lo_response->is_fault( ) = abap_true.
*      PERFORM trace_fault USING lo_response->fault.
*     Meldung holen
      MESSAGE e057(/cideon/plot_admin)
        WITH lo_response->fault->string '' '' ''
        RAISING error.
*      MESSAGE e055(/cideon/plot_admin)
*        WITH '' '' '' ''
*        RAISING http_error.
*      RAISE error.
    ELSE.
*     Login war erfolgreich, dann die Rückgabewerte merken
*     (1) UserID
      lo_xmlrpc_val ?= lo_response->value->array->get_by_index( 1 ).
      li_user_id = lo_xmlrpc_val->value_as_integer( ).
*     (2) ConfID
      lo_xmlrpc_val ?= lo_response->value->array->get_by_index( 2 ).
      li_conf_id = lo_xmlrpc_val->value_as_integer( ).

    ENDIF.
  ELSE.
    MESSAGE e055(/cideon/plot_admin)
      WITH '' '' '' ''
      RAISING http_error.
*    RAISE http_error.
*    WRITE: / 'HTTP Fehler'.
    EXIT.
  ENDIF.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Verteiler der Konfiguration besorgen
*  WRITE: / 'Starte: PlotInfoService.GetDistributorList'.
  CREATE OBJECT lo_request
    EXPORTING
      method = 'PlotInfoService.GetDistributorList'.
  CALL METHOD lo_request->add_parameter(
    value = li_user_id
    type = /cideon/if_xmlrpc_types=>integer
  ).
  CALL METHOD lo_request->add_parameter(
    value = li_conf_id
    type = /cideon/if_xmlrpc_types=>integer
  ).

  CALL METHOD go_xmlrpc_cl->execute
    EXPORTING
      request = lo_request
    RECEIVING
      response = lo_response
    EXCEPTIONS
      http_error = 1.
  IF sy-subrc = 0.
    IF lo_response->is_fault( ) = abap_true.
*      PERFORM trace_fault USING lo_response->fault.
      MESSAGE e057(/cideon/plot_admin)
        WITH lo_response->fault->string '' '' ''
        RAISING error.
*      MESSAGE e055(/cideon/plot_admin)
*        WITH '' '' '' ''
*        RAISING http_error.
*      RAISE error.
    ELSE.
*     Aufruf war erfolgreich Ergebnis auswerten
*      WRITE: / 'Verteiler:'.

      lo_array_iter = lo_response->value->array->create_iterator( ).
      WHILE lo_array_iter->has_next( ) = abap_true.
        lo_xmlrpc_val ?= lo_array_iter->get_next( ).
        IF lo_xmlrpc_val->is_structure( ) = abap_true.

*         Strukturelement 'name' lesen
          lo_distr_name =
            lo_xmlrpc_val->get_structure_element( 'name' ).
          lc_distr_name = lo_distr_name->value_as_string( ).

*         Strukturelement 'desc' lesen
          lo_distr_desc =
            lo_xmlrpc_val->get_structure_element( 'desc' ).
          lc_distr_desc = lo_distr_desc->value_as_string( ).
          wa_description-line = lc_distr_desc.
          APPEND wa_description TO itab_description.

*          WRITE: / lc_distr_name, '                 ', lc_distr_desc.
          CLEAR wa_verteiler.
          wa_verteiler-line = lc_distr_name.
          APPEND wa_verteiler TO itab_verteiler.
        ELSE.
*          WRITE: / 'Struktur wurde erwartet'.
        ENDIF.
      ENDWHILE.
    ENDIF.
  ELSE.
    MESSAGE e055(/cideon/plot_admin)
      WITH '' '' '' ''
      RAISING http_error.
*    RAISE http_error.
*    WRITE: / 'HTTP Fehler'.
    EXIT.
  ENDIF.



ENDFUNCTION.
