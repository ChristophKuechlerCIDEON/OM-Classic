class /CIDEON/CL_PLOT_DLT_BOM_CS11 definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_DLT_BOM_CS11
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  interfaces /CIDEON/IF_PLOT_DLT .

  methods CONSTRUCTOR
    importing
      !BOM type ref to /CIDEON/CL_PLOT_BO_BOM .
*"* protected components of class /CIDEON/CL_PLOT_DLT_DOL
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_DLT_BOM_CS03
*"* do not include other source files here!!!
private section.

  data BOM type ref to /CIDEON/CL_PLOT_BO_BOM .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_DLT_BOM_CS11 IMPLEMENTATION.


METHOD /CIDEON/IF_PLOT_DLT~ACQUIRE_DOCUMENTS .
************************************************************************
* Beschreibung: Dokumente zur Materialstückliste ermitteln. Hier das
*               Flag für das Drucken des Stücklistenbaukastens setzen
*
* Autor:        Heiko Hänsel
* Angelegt am:  13.05.2005
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: pdm_obj   TYPE zcl_pdm_exp_objects.

  pdm_obj-object_type = 'BILLOFMAT'.
  pdm_obj-matnr = bom->materialnr.
  pdm_obj-stlan = bom->usage.
  pdm_obj-stlal = bom->alternative.
  pdm_obj-werks = bom->plant.

* Flag für Plot des Stücklistenbaukasten setzen
  pdm_obj-f_cs11 = abap_true.

  APPEND pdm_obj TO documents.

ENDMETHOD.


method /CIDEON/IF_PLOT_DLT~GET_DOCUMENTS .
* ...
endmethod.


METHOD constructor .
************************************************************************
* Beschreibung: Initialisierung des Dokumentverknüpfungstypes
*
* Autor:        Heiko Hänsel
* Angelegt am:  13.05.2005
*-----------------------------------------------------------------------
* Änderungen:
*  18.08.2005   HAENSEL  Erzeugung der Spaltendefinition
************************************************************************
  DATA: lc_text    TYPE string,
        lc_tooltip TYPE string.

  lc_text = text-001.
  lc_tooltip = text-002.
  CREATE OBJECT /cideon/if_plot_dlt~column
    EXPORTING
      ic_name    = 'BML'
      ic_text    = lc_text
      ii_width   = 8
      ic_tooltip = lc_tooltip.

  me->bom = bom.
ENDMETHOD.
ENDCLASS.
