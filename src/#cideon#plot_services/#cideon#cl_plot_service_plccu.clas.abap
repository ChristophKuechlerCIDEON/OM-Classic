class /CIDEON/CL_PLOT_SERVICE_PLCCU definition
  public
  inheriting from /CIDEON/CL_PLOT_SERVICE
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_SERVICE_PLCCU
*"* do not include other source files here!!!
public section.

  methods EXECUTE
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_SERVICE_PLCCU
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_SERVICE_PLCCU
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_SERVICE_PLCCU IMPLEMENTATION.


METHOD execute.
************************************************************************
* Beschreibung: Startet die Konfiguration zur Festlegung der Auflösungs-
*               tiefe bei Stücklisten
*
* Autor:        Heiko Hänsel
* Angelegt am:  12.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

*  DATA: it_selected_objects  TYPE /cideon/t_pdm_objects.
*break rabe.

*  CALL FUNCTION 'Z_CL_PSBRW_CHANGE_CAPID_USER'
*       EXPORTING
*            function         = ''
*       TABLES
*            selected_objects = it_selected_objects
*       EXCEPTIONS
*            error            = 1
*            OTHERS           = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

ENDMETHOD.
ENDCLASS.
