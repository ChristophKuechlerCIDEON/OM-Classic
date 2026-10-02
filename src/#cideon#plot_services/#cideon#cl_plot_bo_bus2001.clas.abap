class /CIDEON/CL_PLOT_BO_BUS2001 definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2001
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.
  methods GET_DESCRIPTION
    returning
      value(RC_DESCRIPTION) type PS_POST1 .

  methods /CIDEON/IF_PLOT_BO~ACQUIRE_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~ACQUIRE_RELATED_OBJECTS
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_ICON
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_KEY
    redefinition .
  methods /CIDEON/IF_PLOT_BO~GET_TEXT
    redefinition .
  methods /CIDEON/IF_PLOT_BO~SET_KEY
    redefinition .
  type-pools ABAP .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2001
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2001
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@EC@' .
  data PROJID type PS_PSPID .
  data DESCRIPTION type PS_POST1 .
  type-pools ABAP .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2001 IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
*&----------------------------------------------------------------------
*& Beschreibung: Die Projektdefinition wird in den Tree eingehangen und
*&               nach weiteren in Beziehung stehenden Objekten gesucht.
*&
*& Autor:        HAENSEL
*& Angelegt am:  02.02.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lc_text       TYPE string,
        lo_tree_item  TYPE REF TO /cideon/cl_ui_tree_item,
        li_child_level TYPE i,
        lc_description TYPE string,
        lc_keystr     TYPE string,
        lc_objkey     TYPE swo_typeid,
        lc_methname   TYPE string,
        lo_obj        TYPE REF TO object,
        lo_iter       TYPE REF TO /cideon/if_oo_iterator,
        lo_plotbo     TYPE REF TO /cideon/if_plot_bo,
        lt_elements   TYPE TABLE OF bapi_wbs_element_exp,  " Prj.-eleme.
        lt_hierarchy  TYPE TABLE OF bapi_wbs_hierarchie,
        lo_psp_element TYPE REF TO /cideon/cl_plot_bo_bus2054.

  FIELD-SYMBOLS: <ls_hierarchy> TYPE bapi_wbs_hierarchie.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* Tree Item für die Position einfügen
*  lc_description = me->get_description( ).
*  CONCATENATE me->projid lc_description INTO
*    lc_text SEPARATED BY space.
*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = lc_text
*              io_parent  = parent_item
*              if_enabled = abap_true
*              if_visible = abap_true
*              iv_image   =
*                 /cideon/cl_plot_bo_bus2001=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_bus2001=>icon
*              io_ext_key = me
*     RECEIVING ro_item   = lo_tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
*  CALL METHOD insert_checkboxes
*    EXPORTING tree_item = tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

* Nächste Ebene
  li_child_level = current_level - 1.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  Untergeordnete PSP Elemente ermitteln

*  ls_bapipr-project_definition = me->projid.
  CALL FUNCTION 'BAPI_PROJECT_GETINFO'
     EXPORTING
       project_definition           = me->projid
*     WITH_ACTIVITIES              =
*     WITH_MILESTONES              =
*     WITH_SUBTREE                 =
*    IMPORTING
*     E_PROJECT_DEFINITION         =
*     RETURN                       =
    TABLES
*     I_WBS_ELEMENT_TABLE          =
      e_wbs_element_table          = lt_elements
*     E_WBS_MILESTONE_TABLE        =
      e_wbs_hierarchie_table       = lt_hierarchy
*     E_ACTIVITY_TABLE             =
*     E_MESSAGE_TABLE              =
          .
  LOOP AT lt_hierarchy ASSIGNING <ls_hierarchy> WHERE up IS initial.

*   Projektstrukturplan Objekt erzeugen und an die Auflistung der
*   Objektbeziehungen anhängen
    CREATE OBJECT lo_psp_element.

*   Internen Schlüssel des PSP Elementes ermitteln
    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
         EXPORTING
              input  = <ls_hierarchy>-wbs_element
         IMPORTING
              output = lc_objkey.

    CALL METHOD lo_psp_element->/cideon/if_plot_bo~set_key( lc_objkey ).
    lc_keystr = lc_objkey.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_keystr
      obj = lo_psp_element ).

  ENDLOOP.




* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Für alle ermittelten Objekte auf der nächste Ebene nach
* Objekten suchen.
  lc_methname = '/CIDEON/IF_OO_AGGREGATE~CREATE_ITERATOR'.
  CALL METHOD /cideon/if_plot_bo~related_objects->(lc_methname)
    RECEIVING iterator = lo_iter.
  DO.
    CALL METHOD lo_iter->get_next
      RECEIVING item = lo_obj
      EXCEPTIONS index_out_of_bounds = 1.
    IF sy-subrc = 1.
      EXIT.
    ENDIF.

    lo_plotbo ?= lo_obj.
    CALL METHOD lo_plotbo->acquire_objects
      EXPORTING current_level = li_child_level
                selection_tree = selection_tree
                parent_item = lo_tree_item
      EXCEPTIONS nothing_found = 1.

  ENDDO.


ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects .
*& Beschreibung: Ermittlung der nächsten Ebene
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lt_elements   TYPE TABLE OF bapi_wbs_element_exp,  " Prj.-eleme.
        lt_hierarchy  TYPE TABLE OF bapi_wbs_hierarchie,
        lo_psp_element TYPE REF TO /cideon/cl_plot_bo_bus2054,
        lc_objkey      TYPE swo_typeid,
        lc_key         TYPE string.

  FIELD-SYMBOLS: <ls_hierarchy>  TYPE bapi_wbs_hierarchie.

  CALL METHOD super->/cideon/if_plot_bo~acquire_related_objects.

*  ls_bapipr-project_definition = me->projid.
  CALL FUNCTION 'BAPI_PROJECT_GETINFO'
     EXPORTING
       project_definition           = me->projid
*     WITH_ACTIVITIES              =
*     WITH_MILESTONES              =
*     WITH_SUBTREE                 =
*    IMPORTING
*     E_PROJECT_DEFINITION         =
*     RETURN                       =
    TABLES
*     I_WBS_ELEMENT_TABLE          =
      e_wbs_element_table          = lt_elements
*     E_WBS_MILESTONE_TABLE        =
      e_wbs_hierarchie_table       = lt_hierarchy
*     E_ACTIVITY_TABLE             =
*     E_MESSAGE_TABLE              =
          .
  LOOP AT lt_hierarchy ASSIGNING <ls_hierarchy> WHERE up IS INITIAL.

*   Projektstrukturplan Objekt erzeugen und an die Auflistung der
*   Objektbeziehungen anhängen
    CREATE OBJECT lo_psp_element.

*   Internen Schlüssel des PSP Elementes ermitteln
    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
      EXPORTING
        input  = <ls_hierarchy>-wbs_element
      IMPORTING
        output = lc_objkey.

    CALL METHOD lo_psp_element->/cideon/if_plot_bo~set_key( lc_objkey ).
    lc_key = lc_objkey.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = lc_key
      obj = lo_psp_element ).

  ENDLOOP.


ENDMETHOD.


METHOD /cideon/if_plot_bo~get_icon .
*& Beschreibung: Liefert das Icon, mit dem das Projekt im Auswahl-
*&               dialog angezeigt wird.
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_icon = me->icon.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_KEY.
*&----------------------------------------------------------------------
*& Beschreibung: Liefert den  Schlüssel des Business Objektes zurück
*&
*& Autor:        HAENSEL
*& Angelegt am:  02.02.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [OUT] KEY  Schlüssel des Objektes als String
*&----------------------------------------------------------------------
  key = me->projid.
endmethod.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Es wird der Kurztext als Text zurückgeliefert.
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = description.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
*&----------------------------------------------------------------------
*& Beschreibung: Festlegung des Objektschlüssels für die Projektdef. u.
*&               Ermittlung der Beschreibung
*&
*& Autor:        HAENSEL
*& Angelegt am:  02.02.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
  DATA: ls_proj_def    TYPE bapi_project_definition_ex,
        lc_projkeyint  type BAPI_PROJ_KEY-PROJ_KEY_INT.

  me->projid = objkey.

  CALL FUNCTION 'BAPI_PROJECTDEF_GETDETAIL'
    EXPORTING
      currentexternalproje          = me->projid
      currentinternalproje          = lc_projkeyint
    IMPORTING
      project_definition_stru       = ls_proj_def
*     RETURN                        =
            .
  me->description = ls_proj_def-description.

ENDMETHOD.


METHOD constructor.
*& Beschreibung: Initialisierung + Festlegung des Namens
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 15:59:20
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.
  me->/cideon/if_plot_bo~name = 'BUS2001'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Die Projektdefinition selbst unterstützt keine Dokument
*&               verknüpfungen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
ENDMETHOD.


METHOD get_description .
*&----------------------------------------------------------------------
*& Beschreibung: Liefert die Beschreibung des Projektes.
*&
*& Autor:        HAENSEL
*& Angelegt am:  02.02.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  IC_DESCRIPTION Beschreibungstext
*&----------------------------------------------------------------------

  DATA: ls_proj    TYPE proj.

  CALL FUNCTION 'CJDW_PROJ_SELECT_SINGLE'
    EXPORTING
      pspid                   = me->projid
*     PSPNR                   = ' '
*     VSNMR                   = ' '
*     MEMORY_ONLY             =
    IMPORTING
      e_proj                  = ls_proj
    EXCEPTIONS
      missing_parameter       = 1
      not_found               = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
*   TODO: Fehlerhandling
    EXIT.
  ENDIF.

* 1. Zeile des Textes als Beschreibung zurückliefern
  me->description = ls_proj-post1.
  rc_description = ls_proj-post1.
ENDMETHOD.
ENDCLASS.
