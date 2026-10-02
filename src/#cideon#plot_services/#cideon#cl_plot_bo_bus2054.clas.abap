class /CIDEON/CL_PLOT_BO_BUS2054 definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_BUS2054
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.

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
  type-pools ABAP .
*"* protected components of class /CIDEON/CL_PLOT_BO_BUS2054
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_BUS2054
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@ED@' .
  data OBJNR type PS_POSNR .
  data POSID type PS_POSID .
  data DESCRIPTION type PS_POST1 .
  type-pools ABAP .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_BUS2054 IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects.
*&----------------------------------------------------------------------
*& Beschreibung: Das PSP-Element wird in die Baumstruktur eingefügt und
*&               nach weiteren in Beziehung stehenden Objekten gesucht.
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

  DATA: lc_text         TYPE string,
        lc_description  TYPE string,
        li_child_level  TYPE i,
        lo_tree_item    TYPE REF TO /cideon/cl_ui_tree_item.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* PSP Element in die Baumstruktur einhängen
*  CONCATENATE me->posid lc_description INTO
*    lc_text SEPARATED BY space.
*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = lc_text
*              io_parent  = parent_item
*              if_enabled = abap_true
*              if_visible = abap_true
*              iv_image   =
*                 /cideon/cl_plot_bo_bus2054=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_bus2054=>icon
*              io_ext_key = me
*     RECEIVING ro_item   = lo_tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING tree_item = lo_tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

* Nächste Ebene
  li_child_level = current_level - 1.

ENDMETHOD.


METHOD /cideon/if_plot_bo~get_icon.
*& Beschreibung: Liefert das Icon für PSP Element
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
************************************************************************
* Beschreibung: Liefert den Objektschlüssel des PSP-Elementes zurück.
*
* Autor:        HAENSEL
* Angelegt am:  02.02.2005
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  key = me->objnr.

endmethod.


METHOD /cideon/if_plot_bo~get_text .
*& Beschreibung: Liefert den Text des PSP Elementes (Kurztext).
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_text = me->description.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
************************************************************************
* Beschreibung: Übermittlung des Objektschlüssels
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  30.08.2005  HAENSEL  Schlüssel muss nicht mehr an DLT übergeben
*                       werden.
************************************************************************
  DATA:  lt_psp_elements  TYPE TABLE OF bapi_wbs_elements,
         ls_psp_element   TYPE bapi_wbs_elements,
         lt_psp_element_info TYPE TABLE OF bapi_wbs_element_exp.

  FIELD-SYMBOLS: <ls_psp_element_info> TYPE bapi_wbs_element_exp.

* ObjektID übernehmen
  me->objnr = objkey.

* POSID mit Hilfe des Konvertierungsexits ermitteln
  CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
    EXPORTING
      input  = me->objnr
    IMPORTING
      output = me->posid.

* Beschreibung des PSP ermitteln
  ls_psp_element-wbs_element = me->posid.
  APPEND ls_psp_element TO lt_psp_elements.
  CALL FUNCTION 'BAPI_PROJECT_GETINFO'
*    EXPORTING
*      PROJECT_DEFINITION           = lc_pspid
*     WITH_ACTIVITIES              =
*     WITH_MILESTONES              =
*     WITH_SUBTREE                 =
*    IMPORTING
*      E_PROJECT_DEFINITION         = ls_project_def_e
*     RETURN                       =
    TABLES
      i_wbs_element_table          = lt_psp_elements
      e_wbs_element_table          = lt_psp_element_info
*     E_WBS_MILESTONE_TABLE        =
*     E_WBS_HIERARCHIE_TABLE       =
*     E_ACTIVITY_TABLE             =
*     E_MESSAGE_TABLE              =
            .
  IF NOT lt_psp_element_info IS INITIAL.
    READ TABLE lt_psp_element_info ASSIGNING <ls_psp_element_info>
      INDEX 1.
    me->description = <ls_psp_element_info>-description.
  ENDIF.
ENDMETHOD.


method CONSTRUCTOR.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 17:27:06
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  CALL METHOD SUPER->CONSTRUCTOR
     EXPORTING
       IO_ADDITIONAL_DATA = io_additional_data.

  me->/CIDEON/if_plot_bo~name = 'BUS2054'.
endmethod.


METHOD create_supported_dlts.
*& Beschreibung: PSP Element unterstützt Direkt verknüpfte Dokumente
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lo_dlt_dol  TYPE REF TO /cideon/cl_plot_dlt_dol,
        lc_key      TYPE string,
        lc_objkey   TYPE objky.

* (1) Direktverknüpfte Dokumenteninfosätze
  lc_objkey = me->objnr.
  CREATE OBJECT lo_dlt_dol
    EXPORTING objtype = 'PRPS'
              objkey  = lc_objkey.
  lc_key = lo_dlt_dol->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_dol.

ENDMETHOD.
ENDCLASS.
