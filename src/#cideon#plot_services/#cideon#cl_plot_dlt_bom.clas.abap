class /CIDEON/CL_PLOT_DLT_BOM definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_DLT_BOM
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_PLOT_DLT .

  methods CONSTRUCTOR
    importing
      !BOM type ref to /CIDEON/CL_PLOT_BO_BOM .
*"* protected components of class /CIDEON/CL_PLOT_DLT_BOM
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_DLT_BOM
*"* do not include other source files here!!!
private section.

  data BOM type ref to /CIDEON/CL_PLOT_BO_BOM .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_DLT_BOM IMPLEMENTATION.


METHOD /cideon/if_plot_dlt~acquire_documents.
************************************************************************
* Beschreibung: Dokumente zur Materialstückliste ermitteln
*
* Autor:        Heiko Hänsel
* Angelegt am:  05.05.2004
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
  append pdm_obj to documents.

ENDMETHOD.


METHOD constructor.
************************************************************************
* Beschreibung: Initialisierung des Dokumentverknüpfungstypes
*
* Autor:        Heiko Hänsel
* Angelegt am:  05.05.2004
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
      ic_name    = 'BMX'
      ic_text    = lc_text
      ii_width   = 8
      ic_tooltip = lc_tooltip.

  me->bom = bom.
ENDMETHOD.
ENDCLASS.
