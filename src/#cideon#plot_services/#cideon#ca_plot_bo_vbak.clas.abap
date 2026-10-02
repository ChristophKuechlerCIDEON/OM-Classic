class /CIDEON/CA_PLOT_BO_VBAK definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  abstract
  create public .

*"* public components of class /CIDEON/CA_PLOT_BO_VBAK
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~DISPLAY
    redefinition .
*"* protected components of class /CIDEON/CA_PLOT_BO_VBAK
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2030
*"* do not include other source files here!!!
private section.

  data VBELNR type VBELN .
ENDCLASS.



CLASS /CIDEON/CA_PLOT_BO_VBAK IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects .
************************************************************************
* Beschreibung: Ermittlung der selektierten Positionen des Verkaufsbe-
*               leges sowie der zugehörigen Matierialien
*
* Autor:        Heiko Hänsel
* Angelegt am:  11.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  31.05,2005   HAENSEL  Weitergabe der Zusatzdaten an die Positionen
************************************************************************

  DATA: objkey       TYPE swo_typeid,
        colkey       TYPE string,
        child_level  TYPE i,
        tree_item    TYPE REF TO /cideon/cl_ui_tree_item,
        vbel_position TYPE REF TO /cideon/cl_plot_bo_vbak_pos.

  FIELD-SYMBOLS:  <l_position_selection> TYPE /cideon/t_vbel_sel,
                  <l_positionen>         TYPE va_vbapvb_t,
                  <l_position_entry>     TYPE vbapvb,
                  <l_position>           TYPE /cideon/s_vbel_sel.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING
      current_level  = current_level
      selection_tree = selection_tree
      parent_item    = parent_item
      display        = display.

* Level der nächsten Ebene berechnen
  child_level = current_level - 1.

* Soll das aktuelle Objekt "Bestellanforderung" im Selektionsbaum
* erscheinen?
  IF display = seox_true.
*   TODO: Noch nicht implementiert, da die Bestellanforderung bisher nur
*         Einstiegsobjekt ist.
  ELSE.
    tree_item = parent_item.    " Parent item ist INITIAL
  ENDIF.


* Zugriff auf die selektierten Positionen
  ASSIGN ('(SAPMV45A)IVBAP[]') TO <l_position_selection>.
  READ TABLE <l_position_selection>
    TRANSPORTING NO FIELDS
    WITH KEY selkz = seox_true.
  IF sy-subrc > 3.
*   Wurden keine selektierten Positionen gefunden, dann beende die
*   Verabeitung mit einer entsprechenden Meldung
    MESSAGE e000(/cideon/plot_service)
    RAISING nothing_found.
  ENDIF.
  ASSIGN ('(SAPMV45A)XVBAP[]') TO <l_positionen>.

  LOOP AT <l_position_selection> ASSIGNING <l_position>.

*   Positonsobjekt erzeugen und in die Liste der Objekte aufnehmen.
    CREATE OBJECT vbel_position
      EXPORTING
        io_additional_data = mo_additional_data.
    CONCATENATE me->vbelnr <l_position>-posnr
      INTO objkey.
    CALL METHOD vbel_position->/cideon/if_plot_bo~set_key( objkey ).

    READ TABLE <l_positionen> ASSIGNING <l_position_entry>
      WITH KEY vbeln = me->vbelnr
               posnr = <l_position>-posnr
      BINARY SEARCH.

    CALL METHOD vbel_position->set_material
      EXPORTING
        materialno  = <l_position_entry>-matnr
        description = <l_position_entry>-arktx.
    .

    colkey = objkey.
    CALL METHOD /cideon/if_plot_bo~related_objects->add
      EXPORTING
        key = colkey
        obj = vbel_position.

*   Ermitteln von untergeordneten Objekten
    CALL METHOD vbel_position->/cideon/if_plot_bo~acquire_objects
      EXPORTING
        current_level  = child_level
        selection_tree = selection_tree
        parent_item    = tree_item
      EXCEPTIONS
        nothing_found  = 1.

  ENDLOOP.

ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects .
*& Beschreibung: Ermittelt die Positionen des Verkaufsbeleges.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  09.09.2005   HAENSEL Das Material wird nur an die Position übergeben
*&                       wenn es auch ein Material ist.
*&----------------------------------------------------------------------

  DATA: lc_objkey        TYPE swo_typeid,
        lc_colkey        TYPE string,
        lo_vbel_position TYPE REF TO /cideon/cl_plot_bo_vbak_pos.

  FIELD-SYMBOLS:  <lt_position_selection> TYPE /cideon/t_vbel_sel,
                  <lt_positionen>         TYPE va_vbapvb_t,
                  <ls_position_entry>     TYPE vbapvb,
                  <ls_position>           TYPE /cideon/s_vbel_sel.

  CALL METHOD super->/cideon/if_plot_bo~acquire_related_objects.


* Zugriff auf die selektierten Positionen
  ASSIGN ('(SAPMV45A)IVBAP[]') TO <lt_position_selection>.
  READ TABLE <lt_position_selection>
    TRANSPORTING NO FIELDS
    WITH KEY selkz = abap_true.

* Nur weitermachen, wenn Positionen selektiert sind.
  CHECK sy-subrc = 0.

  ASSIGN ('(SAPMV45A)XVBAP[]') TO <lt_positionen>.
  LOOP AT <lt_position_selection> ASSIGNING <ls_position>.

*   Positonsobjekt erzeugen und in die Liste der Objekte aufnehmen.
    CREATE OBJECT lo_vbel_position
      EXPORTING
        io_additional_data = mo_additional_data.
    CONCATENATE me->vbelnr <ls_position>-posnr
      INTO lc_objkey.
    CALL METHOD lo_vbel_position->/cideon/if_plot_bo~set_key(
      lc_objkey
      ).

    READ TABLE <lt_positionen> ASSIGNING <ls_position_entry>
      WITH KEY vbeln = me->vbelnr
               posnr = <ls_position>-posnr
      BINARY SEARCH.

    IF NOT <ls_position_entry>-matnr IS INITIAL.
      CALL METHOD lo_vbel_position->set_material
        EXPORTING
          materialno  = <ls_position_entry>-matnr
          description = <ls_position_entry>-arktx.
    ENDIF.

    lc_colkey = lc_objkey.
    CALL METHOD /cideon/if_plot_bo~related_objects->add
      EXPORTING
        key = lc_colkey
        obj = lo_vbel_position.

  ENDLOOP.
ENDMETHOD.


METHOD /cideon/if_plot_bo~display.
*& Beschreibung: Verkaufsbeleg wird selbst nicht im Selektionsdialog
*&               angezeigt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  08.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rb_display = abap_false.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_KEY .
************************************************************************
* Beschreibung: Liefert den Objektschlüssel des Verkaufsbeleges
*
* Autor:        Heiko Hänsel
* Angelegt am:  10.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  key = me->vbelnr.
endmethod.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Liefert die Belegnummer als Text für den Verkaufsbeleg
*&               im Selektionsdialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = me->vbelnr.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key .
************************************************************************
* Beschreibung: Übernahme der Nummer des Verkaufsbeleges.
*
* Autor:        Heiko Hänsel
* Angelegt am:  10.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  31.05.2005   HAENSEL Zudatzdaten aus dem Belegkopf werden ermittelt.
************************************************************************

  DATA: lo_vbelnr  TYPE REF TO /cideon/cl_oo_string.

  me->vbelnr = objkey.

* Details zum Verkaufsbeleg auslesen und anschließend als Zusatzdaten
* für den Pre Processor speichern.
*  CALL FUNCTION 'SD_SALES_DOCUMENT_READ'
*    EXPORTING
*      document_number                  = me->vbelnr
*     PROCESSING_MODIFICATION          = ' '
*     PROCESSING_BUFFERREAD            = ' '
*     RESULTS_INSERT                   = ' '
*     SUPPRESS_AVAILIBILITY_DIA        = 'X'
*     SUPPRESS_TEXT_POPUP              = 'X'
*     I_BLOCK                          = 'X'
*     STATUS_BUFFER_REFRESH            = 'X'
*     REQUISITION_BUFFER_REFRESH       = 'X'
*     CALL_ACTIVE                      = ' '
*     I_NO_AUTHORITY_CHECK             = ' '
*     I_CALL_BAPI                      = ' '
*     I_CRM_LOCK_MODE                  = ' '
*   IMPORTING
*     EKUAGV                           =
*     EKURGV                           =
*     EKUWEV                           =
*     EVBAK                            =
*     EVBAKKOM                         =
*     EVBKD                            =
*     ETVAK                            =
  .

  CREATE OBJECT lo_vbelnr
    EXPORTING
      ic_string = me->vbelnr.
  CALL METHOD mo_additional_data->add
    EXPORTING
      key           = 'VBELN'
      obj           = lo_vbelnr
    EXCEPTIONS
      duplicate_key = 1.

ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Es werden keine Dokumentverknüpfungen unterstützt
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
ENDMETHOD.
ENDCLASS.
