class /CIDEON/CL_PLOT_BO_BUS1001 definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS1001
*"* do not include other source files here!!!
public section.

  data MATERIALNR type CSAP_MBOM-MATNR read-only .
  data MATERIALBEZ type TXZ01 read-only .

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR
    importing
      !MATERIALNR type MATNR optional
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.
  methods SET_MATERIALBEZ
    importing
      !MATERIALBEZ type TXZ01 .
  methods GET_MARA_MATNR
    returning
      value(RO_MARA_MATNR) type MARA-MATNR .

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_ICON
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS
    redefinition .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS1001
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS1001
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS1001 IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
************************************************************************
* Beschreibung: Das Material wird in die Baumstruktur
*               eingehangen und die Suche nach weiteren Verknüpfungen
*               (Materialstücklisten) fortgestzt.
*               Das hängt davon ab, wie tief in der Verlinkung gesucht
*               werden soll.
*
* Autor:        Heiko Hänsel
* Angelegt am:  29.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
* 06.04.2005 - Christoph Küchler - Anpassung auf DIMP, wegen MATNTR von
*              40 Zeichnen, statt von 18 Zeichen
* 25.05.2005  HAENSEL  Bei DIMP ist die Materialnummer 40-stellig. Der
*                      Funktionsbaustein CSAP_MAT_BOM_SELECT arbeitet
*                      aber nur mit 18-stelliger Materialnr. korrekt
*                      --> Konvertierung in 18-stellige vor FB Aufruf.
************************************************************************

  DATA: text         TYPE string,
        tree_item    TYPE REF TO /cideon/cl_ui_tree_item,
        boms         TYPE TABLE OF mast_api02,
        plot_bom     TYPE REF TO /cideon/cl_plot_bo_bom,
        plant_tmp    TYPE werks,
        child_level  TYPE i,
        key          TYPE string,
        lc_matnr18   type MARA-MATNR,
        lc_matnr     type CSAP_MBOM-MATNR.
        .

  FIELD-SYMBOLS: <l_bom> TYPE mast_api02.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING
      current_level  = current_level
      selection_tree = selection_tree
      parent_item    = parent_item
      display        = display.

* Text für das Item im Selektionsdialog erstellen und das Item in die
* Struktur einfügen.
  CONCATENATE materialnr materialbez
    INTO text SEPARATED BY space.
*  CALL METHOD selection_tree->add_item
*    EXPORTING
*      iv_text    = text
*      io_parent  = parent_item
*      if_enabled = seox_true
*      if_visible = seox_true
*      iv_image   =
*         /cideon/cl_plot_bo_bus1001=>icon
*      iv_image_exp =
*         /cideon/cl_plot_bo_bus1001=>icon
*      io_ext_key = me
*    RECEIVING
*      ro_item   = tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING
      tree_item = tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

* Nächste Ebene
  child_level = current_level - 1.

* Suche nach Stücklisten zum Material
  lc_matnr18 = me->get_mara_matnr( ).  " Fest auf 18-stellige Materialnr
  lc_matnr = lc_matnr18.
  CALL FUNCTION 'CSAP_MAT_BOM_SELECT'
    EXPORTING
      material                   = lc_matnr
*     PLANT                      = '*   '
*     BOM_USAGE                  =
      fl_material_check          = ' '
      fl_foreign_key_check       = ' '
    TABLES
      t_mast                     = boms
    EXCEPTIONS
      error                      = 1
      OTHERS                     = 2.
  IF sy-subrc <> 0.
*   Exception ERROR wird auch erzeugt, wenn keine Stücklisten
*   zum Material existieren.
  ENDIF.

* Stücklistenobjekte erstellen
  LOOP AT boms ASSIGNING <l_bom>.
    plant_tmp = <l_bom>-plant.
    CREATE OBJECT plot_bom
      EXPORTING
        material    = me
        usage       = <l_bom>-bom_usage
        alternative = <l_bom>-bom_alt
        plant       = plant_tmp
        number      = <l_bom>-bom_no
        io_additional_data = mo_additional_data.

    key = plot_bom->/cideon/if_plot_bo~get_key( ).
    CALL METHOD /cideon/if_plot_bo~related_objects->add(
      key = key
      obj = plot_bom
    ).

*  Stückliste in die Struktur einhängen und ggf. Elemente
*  der Stückliste ermitteln.
    CALL METHOD plot_bom->/cideon/if_plot_bo~acquire_objects
      EXPORTING
        current_level  = child_level
        selection_tree = selection_tree
        parent_item    = tree_item
        display        = seox_true
      EXCEPTIONS
        nothing_found  = 1.
  ENDLOOP.
ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects.
*& Beschreibung: Ermittelt die Stückliste zum Material, wenn eine vor-
*&               handen ist. Die Positonen der Stückliste werden als
*&               untergeordnete Element gespeichert.
*&
*& Autor:        HAENSEL
*& Angelegt am:  01.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  07.09.2005  HAENSEL Die Materialnummer wird im internen Format an
*&                      CSAP_MAT_BOM_SELECT übergeben. Das führte auf
*&                      manchen Systemen zu einem ERROR, deshalb nun
*&                      zusätzlich Übergabe im externen Format.
*&----------------------------------------------------------------------
  DATA: lc_matnr18   TYPE mara-matnr,
        lc_matnr     TYPE csap_mbom-matnr,
        lt_boms      TYPE TABLE OF mast_api02,
        lo_plot_bom  TYPE REF TO /cideon/cl_plot_bo_bom,
        lc_plant     TYPE werks,
        lc_key       TYPE string.

  FIELD-SYMBOLS: <ls_bom> TYPE mast_api02.

  lc_matnr18 = me->get_mara_matnr( ).  " Fest auf 18-stellige Materialnr

* Materialnummer in externes Format konvertieren
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = lc_matnr18
    IMPORTING
      output = lc_matnr.

  CALL FUNCTION 'CSAP_MAT_BOM_SELECT'
    EXPORTING
      material                   = lc_matnr
*     PLANT                      = '*   '
*     BOM_USAGE                  =
      fl_material_check          = ' '
      fl_foreign_key_check       = ' '
    TABLES
      t_mast                     = lt_boms
    EXCEPTIONS
      error                      = 1
      OTHERS                     = 2.
  CHECK sy-subrc = 0.

  " CKR - 2012-08-27
  " Integration BADI
  " ROFI SM wegen Ausklammerung von bestimmten BOM
  DATA lo_badi TYPE REF TO /cideon/if_ex_pls_main01.
  CLEAR lo_badi.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = lo_badi.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF lo_badi IS INITIAL.
  ELSE.
    "
    CALL METHOD lo_badi->after_bom_aqquired
      EXPORTING
        lo_plot_bo = me
      CHANGING
        lt_bom     = lt_boms.


  ENDIF.

* Stücklistenobjekte erstellen
  LOOP AT lt_boms ASSIGNING <ls_bom>.
    lc_plant = <ls_bom>-plant.
    CREATE OBJECT lo_plot_bom
      EXPORTING
        material           = me
        usage              = <ls_bom>-bom_usage
        alternative        = <ls_bom>-bom_alt
        plant              = lc_plant
        number             = <ls_bom>-bom_no
        io_additional_data = mo_additional_data.

    lc_key = lo_plot_bom->/cideon/if_plot_bo~get_key( ).
    CALL METHOD /cideon/if_plot_bo~related_objects->add(
      key = lc_key
      obj = lo_plot_bom
      ).
  ENDLOOP.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_ICON .
*& Beschreibung: Liefert das Icon, mit dem das Material im Auswahl-
*&               dialog angezeigt wird.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_icon = me->icon.
endmethod.


method /CIDEON/IF_PLOT_BO~GET_KEY.
************************************************************************
* Beschreibung: Schlüssel für das Material erzeugen.
*
* Autor:        Heiko Hänsel
* Angelegt am:  30.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  key = materialnr.
endmethod.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Liefert den Text des Materials, so wie er im Auswahl-
*&               dialog angezeigt wird.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  29.09.2005   HAENSEL  Konvertierungsexit für die Ausgabe aufrufen.
*&----------------------------------------------------------------------
  DATA: lc_materialnr TYPE string.

* Interne Materialnummer für die Ausgabe aufbereiten, d.h. führende
* Nullen abschneiden.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = me->materialnr
    IMPORTING
      output = lc_materialnr.

  CONCATENATE lc_materialnr materialbez INTO rc_text SEPARATED BY space.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
************************************************************************
* Beschreibung: Materialnummer übernehmen
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  11.04.2005   HAENSEL  Konvertierungsexit, wegen Distinct Industries
*                        Erweiterung.
************************************************************************
  DATA: lo_matnr  TYPE REF TO /cideon/cl_oo_string.

  me->materialnr = objkey.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = me->materialnr
    IMPORTING
      output = me->materialnr.

* Materialnummer in die Zusatzdaten aufnehmen
  CREATE OBJECT lo_matnr
    EXPORTING
      ic_string = me->materialnr.
  CALL METHOD mo_additional_data->add
    EXPORTING
      key           = 'MATNR'
      obj           = lo_matnr
    EXCEPTIONS
      duplicate_key = 1.

ENDMETHOD.


method CLASS_CONSTRUCTOR.
************************************************************************
* Beschreibung: Die Ikone für das Material wird statisch
*               definiert.
*
* Autor:        Heiko Hänsel
* Angelegt am:  29.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  /cideon/cl_plot_bo_bus1001=>icon = '@A6@'.
endmethod.


METHOD constructor.
************************************************************************
* Beschreibung: Legt das Plot-Business Objekt Material an. Wird das
*               Material von einem anderen Objekt referenziert, kann
*               die Materialnummer mit übergeben werden.
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  15.04.2005   HAENSEL  Übernahme von Zusatzdaten
*  09.05.2005   HAENSEL  Zum Speichern der Materialnr, die SET_KEY
*                        Methode verwenden
*  25.05.2005   HAENSEL  Bei DIMP Systemen ist die Länge des Objekt-
*                        schlüssels in der DRAD für Materialien nur
*                        18-stellig, deshalb ist hier eine Konvertierung
*                        notwendig.
*  18.08.2005   HAENSEL  Die Dokumentverknüpfungsart wird in der Methode
*                        CREATE_SUPPORTED_DLTS() erstellt.
************************************************************************
  DATA: lc_matnr   TYPE swo_typeid,
        key_str    TYPE string.

* Konstruktor der Basisklasse
  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.

* Übergebene Materialnummer übernehmen
  IF NOT materialnr IS INITIAL.
    lc_matnr = materialnr.
    CALL METHOD /cideon/if_plot_bo~set_key( lc_matnr ).
*    me->materialnr = materialnr.
  ENDIF.

  me->/cideon/if_plot_bo~name = 'BUS1001'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Material unterstützt die direkte Objektvernküpfung mit
*&               Dokumentinfosätzen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  18.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lc_obj_key    TYPE objky,
        lo_dlt_dol    TYPE REF TO /cideon/cl_plot_dlt_dol,
        lc_key        TYPE string.

* Dokumentverknüpfungsart "Direkte Objektvernküpfung"
  lc_obj_key = me->get_mara_matnr( ).
  CREATE OBJECT lo_dlt_dol
    EXPORTING
      objtype = 'MARA'
      objkey  = lc_obj_key.

  lc_key = lo_dlt_dol->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_dol.
ENDMETHOD.


METHOD get_mara_matnr .
*& Beschreibung: Konvertiert die interne Nummer, die in DIMP Systemen z.
*&               B. 40-stellig ist, in die Länge des Attributes MATNR
*&               aus der Tabelle MARA
*&
*& Autor:        HAENSEL
*& Angelegt am:  25.05.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = me->materialnr
    IMPORTING
      output = ro_mara_matnr.

ENDMETHOD.


METHOD set_materialbez.
************************************************************************
* Beschreibung: Materialbezeichnung festlegen.
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  me->materialbez = materialbez.

ENDMETHOD.
ENDCLASS.
