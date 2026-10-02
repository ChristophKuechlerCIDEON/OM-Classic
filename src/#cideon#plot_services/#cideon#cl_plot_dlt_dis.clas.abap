class /CIDEON/CL_PLOT_DLT_DIS definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_DLT_DIS
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_PLOT_DLT .

  methods CONSTRUCTOR .
  methods SET_DIS
    importing
      !IC_DOKAR type DRAW-DOKAR
      !IC_DOKNR type DRAW-DOKNR
      !IC_DOKTL type DRAW-DOKTL
      !IC_DOKVR type DRAW-DOKVR .
*"* protected components of class /CIDEON/CL_PLOT_DLT_DIS
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_DLT_DIS
*"* do not include other source files here!!!
private section.

  data MC_DOKAR type DOKAR .
  data MC_DOKNR type DOKNR .
  data MC_DOKTL type DOKTL .
  data MC_DOKVR type DOKVR .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_DLT_DIS IMPLEMENTATION.


METHOD /cideon/if_plot_dlt~acquire_documents .
*&----------------------------------------------------------------------
*& Beschreibung: Liefert den Schlüssel des zugehörigen Dokumentinfosatz
*&               zurück. Da es sich um eine pseudo Implementierung
*&               handelt, wird hier nur der Schlüssel zurückgegeben, der
*&               mit der Methode SET_DIS gesetzt wurde.
*&
*& Autor:        HAENSEL
*& Angelegt am:  29.03.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
  DATA: ls_pdm_object TYPE zcl_pdm_exp_objects.

  ls_pdm_object-object_type = 'DOCUMENT'.
  ls_pdm_object-dokar = mc_dokar.
  ls_pdm_object-doknr = mc_doknr.
  ls_pdm_object-doktl = mc_doktl.
  ls_pdm_object-dokvr = mc_dokvr.
  APPEND ls_pdm_object TO documents.
ENDMETHOD.


METHOD constructor .
************************************************************************
* Beschreibung: Initialisierung der Verknüpfung über Selbstreferenz
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2005
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
      ic_name = 'DIR'
      ic_text = lc_text
      ii_width = 8
      ic_tooltip = lc_tooltip.
ENDMETHOD.


METHOD set_dis.
*&----------------------------------------------------------------------
*& Beschreibung: Übergabe des Dokumenteninfosatzschlüssels
*&
*& Autor:        HAENSEL
*& Angelegt am:  29.03.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&   siehe Signatur
*&----------------------------------------------------------------------

  mc_dokar = ic_dokar.
  mc_doknr = ic_doknr.
  mc_doktl = ic_doktl.
  mc_dokvr = ic_dokvr.

ENDMETHOD.
ENDCLASS.
