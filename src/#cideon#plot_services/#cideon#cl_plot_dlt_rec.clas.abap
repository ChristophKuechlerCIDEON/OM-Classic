class /CIDEON/CL_PLOT_DLT_REC definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_DLT_REC
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  interfaces /CIDEON/IF_PLOT_DLT .

  methods CONSTRUCTOR
    importing
      !DOCCLASS type BAPIDCLASS
      !OBJECTID type BAPIGUID .
  methods SET_OBJKEY
    exporting
      !DOCCLASS type BAPIDCLASS
      !OBJECTID type BAPIGUID .
*"* protected components of class /CIDEON/CL_PLOT_DLT_DOL
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_DLT_REC
*"* do not include other source files here!!!
private section.

  data DOCCLASS type BAPIDCLASS .
  data OBJECTID type BAPIGUID .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_DLT_REC IMPLEMENTATION.


METHOD /cideon/if_plot_dlt~acquire_documents .
************************************************************************
* Beschreibung: Ermittelt die mit dem Objekt direkt verknüpften
*               Dokumente über die Akteninhalte
*
* Autor:        Dr. Peter Rabe
* Angelegt am:  15.03.2005
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: pdm_obj   TYPE pdm_exp_objects,
        lt_elements TYPE TABLE OF bapisrmrec_element,
        lt_elements_ident TYPE TABLE OF bapisrmrec_element_ident,
        lt_elements_ident_tmp TYPE TABLE OF bapisrmrec_element_ident,
        ls_elements_ident TYPE bapisrmrec_element_ident,
        ls_elements_ident_tmp TYPE bapisrmrec_element_ident,
        lt_element_properties TYPE TABLE OF bapipropelement,
        lt_element_visibility TYPE TABLE OF bapipropelement,
        lt_element_relations TYPE TABLE OF bapipropelement,
                l_return TYPE bapiret2.
  DATA:  BEGIN OF ls_diskey,
           lf_dokar TYPE dokar,
           lf_doknr TYPE doknr,
           lf_doktl TYPE doktl_d,
           lf_dokvr TYPE dokvr,
           END OF ls_diskey.

  CALL FUNCTION 'BAPI_RECORD_GETELEMENTS'
    EXPORTING
      objectid               = objectid
      documentclass          = docclass
    IMPORTING
      return                 = l_return
    TABLES
      element                = lt_elements
      element_identification = lt_elements_ident_tmp
      element_properties     = lt_element_properties
      element_visibility     = lt_element_visibility
      element_relations      = lt_element_relations.

* DIS'e vorhanden ?
  LOOP AT lt_elements_ident_tmp INTO ls_elements_ident_tmp
  WHERE name = 'BOR_OBJECT_TYPE'
  AND  value = 'DRAW'.
    IF sy-subrc <> 0.
      EXIT.
    ELSE.
      READ TABLE lt_elements_ident_tmp INTO ls_elements_ident
      WITH KEY element_id = ls_elements_ident_tmp-element_id
               name = 'BOR_OBJECT_ID'.
      IF sy-subrc = 0.
        APPEND ls_elements_ident TO lt_elements_ident.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_elements_ident INTO ls_elements_ident.
    MOVE ls_elements_ident-value TO ls_diskey.

    pdm_obj-object_type = 'DOCUMENT'.
    pdm_obj-dokar = ls_diskey-lf_dokar.
    pdm_obj-doknr = ls_diskey-lf_doknr.
    pdm_obj-dokvr = ls_diskey-lf_dokvr.
    pdm_obj-doktl = ls_diskey-lf_doktl.
    APPEND pdm_obj TO documents.

  ENDLOOP.

ENDMETHOD.


method /CIDEON/IF_PLOT_DLT~GET_DOCUMENTS .
* ...
endmethod.


METHOD constructor .
************************************************************************
* Beschreibung: Initialisierung der direkten Objektverknüpfung
*
* Autor:        Dr. Peter Rabe
* Angelegt am:  15.03.2005
*-----------------------------------------------------------------------
* Änderungen:
*  18.08.2005   HAENSEL  Erzeugung der Spaltendefinition
*  01.09.2005   HAENSEL  OBJKEY entfernt, da überflüssig
************************************************************************
  DATA: lc_text    TYPE string,
        lc_tooltip TYPE string.

* Objektschlüssel speichern
  me->docclass = docclass.
  me->objectid = objectid.

* Spaltendefinition erzeugen
  lc_text = text-003.
  lc_tooltip = text-002.
  CREATE OBJECT /cideon/if_plot_dlt~column
    EXPORTING
      ic_name = 'REC'
      ii_width = 8
      ic_text = lc_text
      ic_tooltip = lc_tooltip.
ENDMETHOD.


METHOD set_objkey.
*& Beschreibung: Übernahme und Speicherung des Objektschlüssels des
*&               zugehörigen Records Management Objektes.
*&
*& Autor:        HAENSEL
*& Angelegt am:  01.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  docclass = docclass.
  objectid = objectid.
ENDMETHOD.
ENDCLASS.
