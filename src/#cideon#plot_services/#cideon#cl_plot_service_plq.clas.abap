class /CIDEON/CL_PLOT_SERVICE_PLQ definition
  public
  inheriting from /CIDEON/CL_PLOT_SERVICE_SELDEP
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_SERVICE_PLQ
*"* do not include other source files here!!!
public section.

  methods EXECUTE
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_SERVICE_PLD
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_SERVICE_PLD
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_SERVICE_PLQ IMPLEMENTATION.


METHOD execute .
************************************************************************
* Beschreibung: Ruft die EXECUTE Methode der Basisklasse auf, um die
*               Dokumente zu ermitteln und übergibt diese dann an die
*               Plot-Queue
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  18.04.2005   HAENSEL  Unterstützung von Zusatzdaten aus den Business
*                        objekten z.B. Lieferantennr.
************************************************************************

  DATA: document_count TYPE i.

* Dokumente ermitteln
  CALL METHOD super->execute
    EXPORTING io_container = io_container
    EXCEPTIONS execution_failed  = 1
               container_ignored = 2.
  IF sy-subrc = 1.
    RAISE execution_failed.
  ELSEIF sy-subrc = 2.
    RAISE container_ignored.
  ENDIF.

* TODO: Dokumente besorgen.

* Dokumente in die Plot-Queue eintragen
  CALL FUNCTION 'Z_CL_PSBRW_CALL_PLOT_ADD_ITEMZ'
       EXPORTING
            function         = ''
       TABLES
            selected_objects = documents
       EXCEPTIONS
            error            = 1
            OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

*     Erfolgsmeldung zur Info
    DESCRIBE TABLE documents LINES document_count.
    MESSAGE s006(/cideon/plot_service)
      WITH document_count.

  ENDIF.

ENDMETHOD.
ENDCLASS.
