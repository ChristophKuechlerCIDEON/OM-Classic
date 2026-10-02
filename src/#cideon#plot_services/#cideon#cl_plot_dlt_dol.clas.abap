class /CIDEON/CL_PLOT_DLT_DOL definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_DLT_DOL
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_PLOT_DLT .

  methods CONSTRUCTOR
    importing
      !OBJTYPE type DOKOB
      !OBJKEY type OBJKY .
  methods SET_OBJKEY
    importing
      !OBJKEY type OBJKY .
*"* protected components of class /CIDEON/CL_PLOT_DLT_DOL
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_DLT_DOL
*"* do not include other source files here!!!
private section.

  data OBJTYPE type DOKOB .
  data OBJKEY type OBJKY .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_DLT_DOL IMPLEMENTATION.


METHOD /cideon/if_plot_dlt~acquire_documents.
************************************************************************
* Beschreibung: Ermittelt die mit dem Objekt direkt verknüpften
*               Dokumente über die Tabelle DRAD
*
* Autor:        Heiko Hänsel
* Angelegt am:  04.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  13.05.2005  HAENSEL  Objekttyp des Objektes mit an die PDM_EXP_
*                       OBJECTS übergeben
************************************************************************

  DATA: drad_data TYPE TABLE OF drad,
        pdm_obj   TYPE zcl_pdm_exp_objects.

  FIELD-SYMBOLS: <drad_entry> TYPE drad.

  CALL FUNCTION 'DOKUMENTE_ZU_OBJEKT'
    EXPORTING
      key                       = objkey
      objekt                    = objtype
*     MANDT                     = SY-MANDT
*     CHECK_BUFFER_AND_DB       = ' '
   TABLES
     doktab                    = drad_data
   EXCEPTIONS
     kein_dokument             = 1
     OTHERS                    = 2.

  LOOP AT drad_data
    ASSIGNING <drad_entry>.

    pdm_obj-object_type = 'DOCUMENT'.
    pdm_obj-dokar = <drad_entry>-dokar.
    pdm_obj-doknr = <drad_entry>-doknr.
    pdm_obj-dokvr = <drad_entry>-dokvr.
    pdm_obj-doktl = <drad_entry>-doktl.

*   Objekttyp in zsätzliches Feld übergeben
    pdm_obj-object_type_original = objtype.
    pdm_obj-object_key_original = objkey.

    APPEND pdm_obj TO documents.

  ENDLOOP.

ENDMETHOD.


method /CIDEON/IF_PLOT_DLT~GET_DOCUMENTS.
* ...
endmethod.


METHOD constructor.
************************************************************************
* Beschreibung: Initialisierung der direkten Objektverknüpfung
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  18.08.2005   HAENSEL  Erzeugung der Spaltendefinition
************************************************************************
  DATA: lc_text    TYPE string,
        lc_tooltip TYPE string.

  me->objtype = objtype.
  me->objkey  = objkey.

  lc_text = text-001.
  lc_tooltip = text-002.
  CREATE OBJECT /cideon/if_plot_dlt~column
    EXPORTING
      ic_name = 'DLD'
      ic_text = lc_text
      ii_width = 8
      ic_tooltip = lc_tooltip.
ENDMETHOD.


method SET_OBJKEY.
************************************************************************
* Beschreibung: Übermittelt den Objektschlüssel des verknüpften Objektes
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  me->objkey = objkey.
endmethod.
ENDCLASS.
