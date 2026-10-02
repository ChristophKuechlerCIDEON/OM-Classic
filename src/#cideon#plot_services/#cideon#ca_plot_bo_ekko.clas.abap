class /CIDEON/CA_PLOT_BO_EKKO definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  abstract
  create public .

*"* public components of class /CIDEON/CA_PLOT_BO_EKKO
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  methods CONSTRUCTOR .

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~DISPLAY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
*"* protected components of class /CIDEON/CA_PLOT_BO_EKKO
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CA_PLOT_BO_EKKO
*"* do not include other source files here!!!
private section.

  data PURDOCNO type EBELN .

  methods CREATE_POSITION
    importing
      !POSNO type EBELP
      !MATNO type MATNR
      !MATTXT type TXZ01
    returning
      value(RO_POSITION) type ref to /CIDEON/CL_PLOT_BO_EKKO_POS .
ENDCLASS.



CLASS /CIDEON/CA_PLOT_BO_EKKO IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects .
*& Beschreibung: Ermittlung der selektierten Positionen für Einkaufs-
*&               belege.
*&
*& Autor:        HAENSEL
*& Angelegt am:  27.05.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: objkey       TYPE swo_typeid,
        colkey       TYPE string,
        child_level  TYPE i,
        li_tcode     TYPE i,
        tree_item    TYPE REF TO /cideon/cl_ui_tree_item,

        selected_models    TYPE mmpur_models,
        order_pos_view     TYPE REF TO cl_screen_view_mm,
        mm_framework       TYPE REF TO cl_framework_mm,
        lo_model           TYPE REF TO object,
        lc_methname        TYPE string,
        ls_pos_data        TYPE ekpo,
        lo_position        TYPE REF TO /cideon/cl_plot_bo_ekko_pos.
  .

  FIELD-SYMBOLS:  <l_position_selection> TYPE /cideon/t_ekko_sel,
                  <l_positionen>         TYPE mmpur_bekpo,
                  <l_position_entry>     TYPE bekpo,
                  <l_position>           TYPE /cideon/s_ekko_sel,
                  <l_model>              TYPE mmpur_model_type
                  .

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING
      current_level  = current_level
      selection_tree = selection_tree
      parent_item    = parent_item
      display        = display.

* Level der nächsten Ebene berechnen
  child_level = current_level - 1.

* Soll das aktuelle Objekt im Selektionsbaum
* erscheinen?
  IF display = seox_true.
*   TODO: Noch nicht implementiert, da die Bestellanforderung bisher nur
*         Einstiegsobjekt ist.
  ELSE.
    tree_item = parent_item.    " Parent item ist INITIAL
  ENDIF.

* Zugriff auf die selektierten Positionen, abhängig davon ob das neue
* Framework im MM zum Einsatz kommt oder die alten Transaktionen
  li_tcode = STRLEN( syst-tcode ).
  IF li_tcode = 5 AND syst-tcode+4(1) = 'N'.

*   ********************************************************************
*   Neue Transaktion mit Framework MExxN.

*   Zugriff auf das MM GUI Framework
    CALL METHOD cl_framework_mm=>get_instance
      IMPORTING
        ex_instance = mm_framework.

*   Referenz auf den GRID View für die Positionen besorgen
    CALL METHOD mm_framework->get_view
      EXPORTING
        im_prog  = 'SAPLMEGUI'
        im_dynnr = '1211'
      IMPORTING
        ex_view  = order_pos_view.

*   Hole die selektierten Positionen
    CALL METHOD
    order_pos_view->('IF_MULTIPLE_MODEL_HOLDER_MM~GET_SELECTED_MODELS')
      RECEIVING
        re_models = selected_models.

*   Prüfen, ob mindestens eine Position selektiert wurde.
    IF selected_models IS INITIAL.
      MESSAGE i000(/cideon/plot_service) RAISING nothing_found.
    ENDIF.

*   Aus den Positionen die Materialnummern extrahieren.
    LOOP AT selected_models ASSIGNING <l_model>.
*     Jedes Element ist ein Objekt der Klasse (MEREQ)LCL_REQ_ITEM
      lo_model = <l_model>-model.

*     Positionsdaten holen
      lc_methname = 'IF_PURCHASING_DOCUMENT_ITEM~GET_EKPO'.
      CALL METHOD lo_model->(lc_methname)
        RECEIVING
          re_ekpo = ls_pos_data.

*     Positonsobjekt erzeugen und in die Liste der Objekte aufnehmen.
      CALL METHOD me->create_position
        EXPORTING
          posno       = ls_pos_data-ebelp
          matno       = ls_pos_data-matnr
          mattxt      = ls_pos_data-txz01
        RECEIVING
          ro_position = lo_position.

*     Ermitteln von untergeordneten Objekten
      CALL METHOD lo_position->/cideon/if_plot_bo~acquire_objects
        EXPORTING
          current_level  = child_level
          selection_tree = selection_tree
          parent_item    = tree_item
        EXCEPTIONS
          nothing_found  = 1.
    ENDLOOP.

  ELSE.

*   ********************************************************************
*   Alte Transaktion ME2x

*   Zugriff auf die selektierten Positionen
    ASSIGN ('(SAPMM06E)SEL[]') TO <l_position_selection>.
    IF <l_position_selection> IS INITIAL.
*     Wenn keine Positionen selektiert wurden, beende die Verarbeitung.
      MESSAGE e000(/cideon/plot_service)
      RAISING nothing_found.
    ENDIF.
    ASSIGN ('(SAPMM06E)POT[]') TO <l_positionen>.

    LOOP AT <l_position_selection> ASSIGNING <l_position>.

*     Details zur Position ermitteln
      READ TABLE <l_positionen> ASSIGNING <l_position_entry>
        WITH KEY ebeln = me->purdocno
                 ebelp = <l_position>-ebelp
        BINARY SEARCH.

*     Positonsobjekt erzeugen und in die Liste der Objekte aufnehmen.
      CALL METHOD me->create_position
        EXPORTING
          posno       = <l_position>-ebelp
          matno       = <l_position_entry>-matnr
          mattxt      = <l_position_entry>-txz01
        RECEIVING
          ro_position = lo_position.

*     Ermitteln von untergeordneten Objekten
      CALL METHOD lo_position->/cideon/if_plot_bo~acquire_objects
        EXPORTING
          current_level  = child_level
          selection_tree = selection_tree
          parent_item    = tree_item
        EXCEPTIONS
          nothing_found  = 1.
*    CONCATENATE me->purdocno <l_position>-ebelp
*      INTO objkey.
*    CALL METHOD ekko_position->/cideon/if_plot_bo~set_key( objkey ).
*
*    READ TABLE <l_positionen> ASSIGNING <l_position_entry>
*      WITH KEY ebeln = me->purdocno
*               ebelp = <l_position>-ebelp
*      BINARY SEARCH.
*
*    CALL METHOD ekko_position->set_material
*      EXPORTING
*        materialno  = <l_position_entry>-matnr
*        description = <l_position_entry>-txz01.

*    colkey = objkey.
*    CALL METHOD /cideon/if_plot_bo~related_objects->add
*      EXPORTING
*        key = colkey
*        obj = ekko_position.

**   Ermitteln von untergeordneten Objekten
*    CALL METHOD ekko_position->/cideon/if_plot_bo~acquire_objects
*      EXPORTING
*        current_level  = child_level
*        selection_tree = selection_tree
*        parent_item    = tree_item
*      EXCEPTIONS
*        nothing_found  = 1.

    ENDLOOP.
  ENDIF.
ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects.
*& Beschreibung: Ermittlung der Positionen des Einkaufsbeleges
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: li_tcode  TYPE i,
        mm_framework       TYPE REF TO cl_framework_mm,
        selected_models    TYPE mmpur_models,
        order_pos_view     TYPE REF TO cl_screen_view_mm,
        lo_model           TYPE REF TO object,
        lc_methname        TYPE string,
        ls_pos_data        TYPE ekpo,
        lo_position        TYPE REF TO /cideon/cl_plot_bo_ekko_pos.

  FIELD-SYMBOLS:  <l_position_selection> TYPE /cideon/t_ekko_sel,
                  <l_positionen>         TYPE mmpur_bekpo,
                  <l_position_entry>     TYPE bekpo,
                  <l_position>           TYPE /cideon/s_ekko_sel,
                  <l_model>              TYPE mmpur_model_type
                  .

  CALL METHOD super->/cideon/if_plot_bo~acquire_related_objects.

* Zugriff auf die selektierten Positionen, abhängig davon ob das neue
* Framework im MM zum Einsatz kommt oder die alten Transaktionen
  li_tcode = STRLEN( syst-tcode ).
  IF li_tcode = 5 AND syst-tcode+4(1) = 'N'.

*   ********************************************************************
*   Neue Transaktion mit Framework MExxN.

*   Zugriff auf das MM GUI Framework
    CALL METHOD cl_framework_mm=>get_instance
      IMPORTING
        ex_instance = mm_framework.

*   Referenz auf den GRID View für die Positionen besorgen
    CALL METHOD mm_framework->get_view
      EXPORTING
        im_prog  = 'SAPLMEGUI'
        im_dynnr = '1211'
      IMPORTING
        ex_view  = order_pos_view.

*   Hole die selektierten Positionen
    CALL METHOD
      order_pos_view->('IF_MULTIPLE_MODEL_HOLDER_MM~GET_SELECTED_MODELS')
      RECEIVING
        re_models = selected_models.

*   Prüfen, ob mindestens eine Position selektiert wurde.
    CHECK NOT selected_models IS INITIAL.
*      MESSAGE i000(/cideon/plot_service) RAISING nothing_found.
*    ENDIF.

*   Aus den Positionen die Materialnummern extrahieren.
    LOOP AT selected_models ASSIGNING <l_model>.
*     Jedes Element ist ein Objekt der Klasse (MEREQ)LCL_REQ_ITEM
      lo_model = <l_model>-model.

*     Positionsdaten holen
      lc_methname = 'IF_PURCHASING_DOCUMENT_ITEM~GET_EKPO'.
      CALL METHOD lo_model->(lc_methname)
        RECEIVING
          re_ekpo = ls_pos_data.

*     Positonsobjekt erzeugen und in die Liste der Objekte aufnehmen.
      CALL METHOD me->create_position
        EXPORTING
          posno       = ls_pos_data-ebelp
          matno       = ls_pos_data-matnr
          mattxt      = ls_pos_data-txz01
        RECEIVING
          ro_position = lo_position.

*     Ermitteln von untergeordneten Objekten
*      CALL METHOD lo_position->/cideon/if_plot_bo~acquire_objects
*        EXPORTING
*          current_level  = child_level
*          selection_tree = selection_tree
*          parent_item    = tree_item
*        EXCEPTIONS
*          nothing_found  = 1.
    ENDLOOP.

  ELSE.

*   ********************************************************************
*   Alte Transaktion ME2x

*   Zugriff auf die selektierten Positionen
    ASSIGN ('(SAPMM06E)SEL[]') TO <l_position_selection>.
    CHECK NOT <l_position_selection> IS INITIAL.
**     Wenn keine Positionen selektiert wurden, beende die Verarbeitung.
*      MESSAGE e000(/cideon/plot_service)
*      RAISING nothing_found.
*    ENDIF.
    ASSIGN ('(SAPMM06E)POT[]') TO <l_positionen>.

    LOOP AT <l_position_selection> ASSIGNING <l_position>.

*     Details zur Position ermitteln
      READ TABLE <l_positionen> ASSIGNING <l_position_entry>
        WITH KEY ebeln = me->purdocno
                 ebelp = <l_position>-ebelp
        BINARY SEARCH.

*     Positonsobjekt erzeugen und in die Liste der Objekte aufnehmen.
      CALL METHOD me->create_position
        EXPORTING
          posno       = <l_position>-ebelp
          matno       = <l_position_entry>-matnr
          mattxt      = <l_position_entry>-txz01
        RECEIVING
          ro_position = lo_position.

**     Ermitteln von untergeordneten Objekten
*      CALL METHOD lo_position->/cideon/if_plot_bo~acquire_objects
*        EXPORTING
*          current_level  = child_level
*          selection_tree = selection_tree
*          parent_item    = tree_item
*        EXCEPTIONS
*          nothing_found  = 1.
*    CONCATENATE me->purdocno <l_position>-ebelp
*      INTO objkey.
*    CALL METHOD ekko_position->/cideon/if_plot_bo~set_key( objkey ).
*
*    READ TABLE <l_positionen> ASSIGNING <l_position_entry>
*      WITH KEY ebeln = me->purdocno
*               ebelp = <l_position>-ebelp
*      BINARY SEARCH.
*
*    CALL METHOD ekko_position->set_material
*      EXPORTING
*        materialno  = <l_position_entry>-matnr
*        description = <l_position_entry>-txz01.

*    colkey = objkey.
*    CALL METHOD /cideon/if_plot_bo~related_objects->add
*      EXPORTING
*        key = colkey
*        obj = ekko_position.

**   Ermitteln von untergeordneten Objekten
*    CALL METHOD ekko_position->/cideon/if_plot_bo~acquire_objects
*      EXPORTING
*        current_level  = child_level
*        selection_tree = selection_tree
*        parent_item    = tree_item
*      EXCEPTIONS
*        nothing_found  = 1.

    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD /cideon/if_plot_bo~display.
*& Beschreibung: Einkaufsbelege sind Einstiegsobjekte und werden nicht
*&               direkt im Selektionsdialog angezeigt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rb_display = abap_false.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_key .
************************************************************************
* Beschreibung: Liefert den Objektschlüssel des Einkaufsbeleges
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.05.2005
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  key = me->purdocno.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Belegnummer des Einkaufsbeleges ist der Text des
*&               Objektes im Selektionsdialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = purdocno.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
************************************************************************
* Beschreibung: Übernahme der Nummer des Einkaufsbeleges und Ermittlung
*               von Zusatzdaten aus dem Einkaufsbeleg (Belegnr, Liefer-
*               antennr., Lieferantenbezeichnung).
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.05.2005
*-----------------------------------------------------------------------
* Änderungen:
*  26.05.2005   HAENSEL  Neuimplementierung
************************************************************************

  DATA: ls_header    TYPE bapiekkol,
        lt_return    TYPE TABLE OF bapireturn,
        lo_vendor    TYPE REF TO /cideon/cl_oo_string,
        lo_ebeln     TYPE REF TO /cideon/cl_oo_string,
        lo_vendor_name TYPE REF TO /cideon/cl_oo_string,
        lb_error     TYPE abap_bool.

  me->purdocno = objkey.

* Per BAPI die Kopfdaten des Beleges auslesen und die relevanten Felder
*   - Bestellnummer
*   - Lieferantennummer
*   - Lieferantenname
* in die Zusatzdaten übertragen
  CALL FUNCTION 'BAPI_PO_GETDETAIL'
    EXPORTING
      purchaseorder                    = me->purdocno
      items                            = abap_false
      header_texts                     = abap_true
    IMPORTING
      po_header                        = ls_header
    TABLES
      return                           = lt_return.

  LOOP AT lt_return TRANSPORTING NO FIELDS
    WHERE type = 'A' OR type = 'E'.
    lb_error = abap_true.
  ENDLOOP.
  IF lb_error = abap_false.

*   Feldinhalte in die Zusatzdaten übernehmen
    CREATE OBJECT lo_vendor
      EXPORTING
        ic_string = ls_header-vendor.
    CALL METHOD mo_additional_data->add
      EXPORTING
        key = 'LIFNR'
        obj = lo_vendor.

    CREATE OBJECT lo_ebeln
      EXPORTING
        ic_string = ls_header-po_number.
    CALL METHOD mo_additional_data->add
      EXPORTING
        key = 'EBELN'
        obj = lo_ebeln.

    CREATE OBJECT lo_vendor_name
      EXPORTING
        ic_string = ls_header-vend_name.
    CALL METHOD mo_additional_data->add
      EXPORTING
        key = 'NAME1_LIFNR'
        obj = lo_vendor_name.
  ENDIF.

ENDMETHOD.


METHOD constructor.
*& Beschreibung: Dieser Konstruktor muss als parameterloser
*&               Konstuktor definiert sein, da die Klasse dynamisch er-
*&               zeugt wird.
*&
*& Autor:        HAENSEL
*& Angelegt am:  08.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CALL METHOD super->constructor.
  me->/cideon/if_plot_bo~name = 'EKKO'.
ENDMETHOD.


METHOD create_position.
*& Beschreibung: Es wird aus den übergebenen Daten ein Positionsobjekt
*&               erzeugt und dieses der Auflistung von referenzierten
*&               Objekten angehangen.
*&
*&
*& Autor:        HAENSEL
*& Angelegt am:  27.05.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  09.09.2005   HAENSEL Das Material wird nur an die Position übergeben
*&                       wenn es auch ein Material ist.
*&----------------------------------------------------------------------
  DATA: lc_objkey       TYPE swo_typeid,
        lc_colkey       TYPE string,
        lo_position     TYPE REF TO /cideon/cl_plot_bo_ekko_pos.


  CREATE OBJECT lo_position
      EXPORTING
        io_additional_data = me->mo_additional_data.

  CONCATENATE me->purdocno posno INTO lc_objkey.
  CALL METHOD lo_position->/cideon/if_plot_bo~set_key( lc_objkey ).

* Materialdaten übermitteln
  IF NOT matno IS INITIAL.
    CALL METHOD lo_position->set_material
      EXPORTING
        materialno  = matno
        description = mattxt.
  ENDIF.

* In die Referenzierten Objekte aufnehmen
  lc_colkey = lc_objkey.
  CALL METHOD /cideon/if_plot_bo~related_objects->add
    EXPORTING
      key = lc_colkey
      obj = lo_position.

  ro_position = lo_position.

ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Einkaufsbelege selbst haben keine Dokumentverknüpfungen
*&
*& Autor:        HAENSEL
*& Angelegt am:  18.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
ENDMETHOD.
ENDCLASS.
