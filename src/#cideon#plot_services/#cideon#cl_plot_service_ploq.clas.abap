class /CIDEON/CL_PLOT_SERVICE_PLOQ definition
  public
  inheriting from /CIDEON/CL_PLOT_SERVICE
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_SERVICE_PLOQ
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .

  methods EXECUTE
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_SERVICE_PLOQ
*"* do not include other source files here!!!
protected section.
*"* private components of class ZHH_PLOTT_SERVICE_PLOTT
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_PLOT_SERVICE_PLOQ IMPLEMENTATION.


method CONSTRUCTOR .

  call method super->constructor.

endmethod.


METHOD execute.
************************************************************************
* Beschreibung: Startet den Preprozessor für die Plotting Solution ohne
*               Berücksichtigung selektierter Objekte und Queue.
*               Es ist nur der pure Absprung in den Preprozessor.
*
* Autor:        Heiko Hänsel
* Angelegt am:  01.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: lt_objects TYPE /cideon/t_pdm_objects.

  CALL FUNCTION 'Z_CL_PSBRW_CALL_PLOT_ALONE'
       EXPORTING
            function         = ''
       TABLES
            selected_objects = lt_objects
       EXCEPTIONS
            error            = 1
            OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMETHOD.
ENDCLASS.
