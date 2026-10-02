class /CIDEON/CL_PLOT_BO_RECORD definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_RECORD
*"* do not include other source files here!!!
public section.

  data OBJECTID type BAPIGUID .
  data DOCCLASS type BAPIDCLASS .

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
*"* protected components of class /CIDEON/CL_PLOT_BO_RECORD
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_RECORD
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@FH@' .
  data TEXT type STRING .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_RECORD IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects .

  DATA: text    TYPE string,
        child_level  TYPE i,
        l_line TYPE i,
        tree_item TYPE REF TO /cideon/cl_ui_tree_item,
        lt_elements TYPE TABLE OF bapisrmrec_element,
        lt_elements_ident TYPE TABLE OF bapisrmrec_element_ident,
        lt_elements_ident_tmp TYPE TABLE OF bapisrmrec_element_ident,
        ls_elements_ident TYPE bapisrmrec_element_ident,
        ls_elements_ident_tmp TYPE bapisrmrec_element_ident,
        lt_element_properties TYPE TABLE OF bapipropelement,
        lt_element_visibility TYPE TABLE OF bapipropelement,
        lt_element_relations TYPE TABLE OF bapipropelement,
        lt_properties TYPE TABLE OF bapiproptb,
        ls_properties TYPE bapiproptb,
        l_return TYPE bapiret2,
        sub_record TYPE REF TO /cideon/cl_plot_bo_record,
        objkey       TYPE swo_typeid,
        colkey       TYPE string.

  DATA:  BEGIN OF ls_diskey,
           lf_dokar TYPE dokar,
           lf_doknr TYPE doknr,
           lf_doktl TYPE doktl_d,
           lf_dokvr TYPE dokvr,
           END OF ls_diskey.
  DATA: lf_diskey TYPE cdesk_diskeys,
        key          TYPE string,
        lf_nodis,
        lf_nosubrecords.


* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING
      current_level  = current_level
      selection_tree = selection_tree
      parent_item    = parent_item
      display        = display.

  CALL FUNCTION 'BAPI_RECORD_GETPROPERTIES'
    EXPORTING
      objectid             = objectid
      documentclass        = docclass
*   WHOLE_DOCUMENT       = ' '
   IMPORTING
     return               = l_return
    TABLES
      properties           = lt_properties.

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


* Tree Item für die Position einfügen
  READ TABLE lt_properties INTO ls_properties
  WITH KEY name = 'DESCRIPTION'.
  text = ls_properties-value.

*  CALL METHOD selection_tree->add_item
*    EXPORTING
*      iv_text      = text
*      io_parent    = parent_item
*      if_enabled   = seox_true
*      if_visible   = seox_true
*      iv_image     = /cideon/cl_plot_bo_record=>icon
*      iv_image_exp = /cideon/cl_plot_bo_record=>icon
*      io_ext_key   = me
*    RECEIVING
*      ro_item      = tree_item.

* Checkboxen für die auszuwählenden Akten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING
      tree_item = tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

* Nächste Ebene ?
*  Auf Vorhandensein von Unterakten prüfen:
  LOOP AT lt_elements_ident_tmp INTO ls_elements_ident_tmp
  WHERE name = 'DOC_ID'.
    IF sy-subrc <> 0.
      lf_nosubrecords = 'X'.
      EXIT.
    ELSE.
      APPEND ls_elements_ident_tmp TO lt_elements_ident.
    ENDIF.
  ENDLOOP.

  IF lf_nosubrecords IS INITIAL.
    child_level = current_level - 1.

    LOOP AT lt_elements_ident INTO ls_elements_ident.

*   Subakte erzeugen und in die Liste der Objekte aufnehmen.
      CREATE OBJECT sub_record.
      MOVE ls_elements_ident-value TO objkey.
      CALL METHOD sub_record->/cideon/if_plot_bo~set_key( objkey ).

      colkey = objkey.

      CALL METHOD /cideon/if_plot_bo~related_objects->add
        EXPORTING
          key = colkey
          obj = sub_record.

*   Ermitteln von untergeordneten Objekten
      CALL METHOD sub_record->/cideon/if_plot_bo~acquire_objects
        EXPORTING
          current_level  = child_level
          selection_tree = selection_tree
          parent_item    = tree_item
        EXCEPTIONS
          nothing_found  = 1.

    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects.
*& Beschreibung: Ermittlung weiterer untergeordneter Akten
*&
*& Autor:        HAENSEL
*& Angelegt am:  01.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA:
         lt_elements TYPE TABLE OF bapisrmrec_element,
         lt_elements_ident TYPE TABLE OF bapisrmrec_element_ident,
         lt_element_properties TYPE TABLE OF bapipropelement,
         lt_element_visibility TYPE TABLE OF bapipropelement,
         lt_element_relations  TYPE TABLE OF bapipropelement,
         lc_colkey             TYPE string,
         lc_objkey             TYPE swo_typeid,
         ls_return             TYPE bapiret2,
         lo_sub_record         TYPE REF TO /cideon/cl_plot_bo_record.

  FIELD-SYMBOLS: <ls_element_ident> TYPE bapisrmrec_element_ident.

  CALL FUNCTION 'BAPI_RECORD_GETELEMENTS'
    EXPORTING
      objectid               = me->objectid
      documentclass          = me->docclass
    IMPORTING
      return                 = ls_return
    TABLES
      element                = lt_elements
      element_identification = lt_elements_ident
      element_properties     = lt_element_properties
      element_visibility     = lt_element_visibility
      element_relations      = lt_element_relations.

* Auf Unterakten prüfen, und diese erzeugen
  LOOP AT lt_elements_ident ASSIGNING <ls_element_ident>
    WHERE name = 'DOC_ID'.

    CREATE OBJECT lo_sub_record.
    lc_objkey = <ls_element_ident>-value.
    CALL METHOD lo_sub_record->/cideon/if_plot_bo~set_key( lc_objkey ).
    lc_colkey = <ls_element_ident>-value.

    CALL METHOD /cideon/if_plot_bo~related_objects->add
      EXPORTING
        key = lc_colkey
        obj = lo_sub_record.

  ENDLOOP.

ENDMETHOD.


METHOD /cideon/if_plot_bo~get_icon .
  rc_icon = me->icon.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_key .

  CONCATENATE docclass objectid INTO key.

ENDMETHOD.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Liefert den Text für die Akte
*&
*& Autor:        HAENSEL
*& Angelegt am:  01.09.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = me->text.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
*& Beschreibung: Schlüssel der Akte speichern und den Kurztext anhand
*&               der BAPI Funktion ermitteln.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lt_properties TYPE TABLE OF bapiproptb,
        ls_return     TYPE bapiret2.

  field-symbols: <ls_property> TYPE bapiproptb.

  docclass = objkey(10).
  objectid = objkey+10(32).

* Kurztext der Akte ermitteln
  CALL FUNCTION 'BAPI_RECORD_GETPROPERTIES'
    EXPORTING
      objectid             = me->objectid
      documentclass        = me->docclass
    IMPORTING
      return               = ls_return
    TABLES
      properties           = lt_properties.
  READ TABLE lt_properties assigning <ls_property>
    WITH KEY name = 'DESCRIPTION'.
  me->text = <ls_property>-value.

ENDMETHOD.


method CREATE_SUPPORTED_DLTS.
*& Beschreibung: Eine Akte benötigt einen spezielle Art der Dokument-
*&               verknüpfung.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  data: lo_dlt_rec  TYPE REF TO /cideon/cl_plot_dlt_rec,
        lc_keystr   TYPE string.

* Dokumentverknüpfungsart "Dokumentverknüpfung im Records Management"
  CREATE OBJECT lo_dlt_rec
    EXPORTING
      docclass = me->docclass
      objectid = me->objectid.

  lc_keystr = lo_dlt_rec->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_keystr
      obj = lo_dlt_rec.
endmethod.
ENDCLASS.
