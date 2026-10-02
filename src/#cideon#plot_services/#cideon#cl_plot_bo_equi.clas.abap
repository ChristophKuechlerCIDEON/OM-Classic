class /CIDEON/CL_PLOT_BO_EQUI definition
  public
  inheriting from /CIDEON/CLA_PLOT_BO
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_EQUI
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !IO_ADDITIONAL_DATA type ref to /CIDEON/CL_OO_COLLECTION optional
.
  methods SET_DESCRIPTION
    importing
      !DESCRIPTION type KTX01 .

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
*"* protected components of class /CIDEON/CL_PLOT_BO_EQUI
*"* do not include other source files here!!!
protected section.

  methods CREATE_SUPPORTED_DLTS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_BO_EQUI
*"* do not include other source files here!!!
private section.

  class-data ICON type TV_IMAGE value '@AN@' .
  data EQUI_NUMBER type EQUNR .
  data DESCRIPTION type EQTXT .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_EQUI IMPLEMENTATION.


METHOD /cideon/if_plot_bo~acquire_objects .
************************************************************************
* Beschreibung: Die Equipmentnummer wird in die Baumstruktur eingehangen
*               und nach weiteren in Beziehung stehenden Objekten
*               gesucht.
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  DATA: text    TYPE string,
        tree_item    TYPE REF TO /cideon/cl_ui_tree_item,
        child_level  TYPE i,
        equihier     TYPE TABLE OF rihequi,
        objkey       TYPE swo_typeid,
        obj          TYPE REF TO object,
        keystr       TYPE string,
        methname     TYPE string,
        equi_view    TYPE v_equi,
        iter         TYPE REF TO /cideon/if_oo_iterator,
        plotbo       TYPE REF TO /cideon/if_plot_bo,
        submat       TYPE REF TO /cideon/cl_plot_bo_bus1001,
        eqst_entry   TYPE eqstb,
        eqst_tab     TYPE TABLE OF eqstb,
        subequi      TYPE REF TO /cideon/cl_plot_bo_equi.

  FIELD-SYMBOLS: <l_equi> TYPE rihequi,
                 <l_eqst> TYPE eqstb.

* Methode der Basisklasse wegen Spaltenverfügbarkeit.
  CALL METHOD super->/cideon/if_plot_bo~acquire_objects
    EXPORTING current_level  = current_level
              selection_tree = selection_tree
              parent_item    = parent_item
              display        = display.

* Tree Item für die Position einfügen
  CONCATENATE equi_number description INTO
    text SEPARATED BY space.
*  CALL METHOD selection_tree->add_item
*    EXPORTING iv_text    = text
*              io_parent  = parent_item
*              if_enabled = seox_true
*              if_visible = seox_true
*              iv_image   =
*                 /cideon/cl_plot_bo_equi=>icon
*              iv_image_exp =
*                 /cideon/cl_plot_bo_equi=>icon
*              io_ext_key = me
*     RECEIVING ro_item   = tree_item.

* Checkboxen für unterstützte Dokumentverknüpfungsarten einfügen
  CALL METHOD insert_checkboxes
    EXPORTING tree_item = tree_item.

* Prüfen, ob die nächste Ebene noch eingelesen werden soll.
  IF current_level = 1.
    EXIT.
  ENDIF.

* Nächste Ebene
  child_level = current_level - 1.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Unterequipments ermitteln
  CALL FUNCTION 'EQUI_HIERARCHY_READ'
    EXPORTING
      equipment        = equi_number
      level_down       = 1
*   IMPORTING
*     EQUI_COUNT       =
    TABLES
      hier_tab         = equihier.
  LOOP AT equihier ASSIGNING <l_equi>
    WHERE NOT equnr = equi_number.

    CREATE OBJECT subequi.
    objkey = <l_equi>-equnr.
    CALL METHOD subequi->/cideon/if_plot_bo~set_key( objkey ).

    keystr = <l_equi>-equnr.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = keystr
      obj = subequi ).

  ENDLOOP.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Material ermitteln
  CALL FUNCTION 'EQUIPMENT_READ_VIEW'
    EXPORTING
*     I_HANDLE              =
*     I_LOCK                =
      equi_no               = equi_number
*     I_CHECK_AUTH          = ' '
*     I_TCODE               = ' '
*     READING_DATE          = '99991231'
*     I_ACTIVITY_TYPE       = ' '
*     I_KILL_BUF            = ' '
    IMPORTING
     view                  = equi_view
    EXCEPTIONS
      equi_not_found        = 1
      lock_user             = 2
      lock_unknown          = 3
      auth_no_begrp         = 4
      auth_no_iwerk         = 5
      auth_no_swerk         = 6
      auth_no_ingrp         = 7
      auth_no_kostl         = 8
      auth_no_badi          = 9
      OTHERS                = 10.
  IF NOT equi_view-submt IS INITIAL.
    CREATE OBJECT submat.
    objkey = equi_view-submt.
    CALL METHOD submat->/cideon/if_plot_bo~set_key( objkey ).

    keystr = equi_view-submt.
    CALL METHOD me->/cideon/if_plot_bo~related_objects->add(
      key = keystr
      obj = submat ).

  ENDIF.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Equipmentstücklisten ermitteln
  eqst_entry-equnr = equi_number.
  eqst_entry-werks = '*'.
  CALL FUNCTION 'GET_EQST_AOV'
*   EXPORTING
*     NO_BUFFER             = ' '
    TABLES
      eqstb_tab             = eqst_tab
    CHANGING
      wa_eqstb_tab          = eqst_entry
   EXCEPTIONS
     call_invalid          = 1
     end_of_table          = 2
     key_incomplete        = 3
     key_invalid           = 4
     no_record_found       = 5
     OTHERS                = 6.
  IF sy-subrc = 0.
    LOOP AT eqst_tab ASSIGNING <l_eqst>.

*     Equipmentstücklisten erzeugen
*      TODO

    ENDLOOP.
  ENDIF.


* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Für alle ermittelten Objekte auf der nächste Ebene nach
* Objekten suchen.
  methname = '/CIDEON/IF_OO_AGGREGATE~CREATE_ITERATOR'.
  CALL METHOD /cideon/if_plot_bo~related_objects->(methname)
    RECEIVING iterator = iter.
  DO.
    CALL METHOD iter->get_next
      RECEIVING item = obj
      EXCEPTIONS index_out_of_bounds = 1.
    IF sy-subrc = 1.
      EXIT.
    ENDIF.

    plotbo ?= obj.
    CALL METHOD plotbo->acquire_objects
      EXPORTING current_level = child_level
                selection_tree = selection_tree
                parent_item = tree_item
      EXCEPTIONS nothing_found = 1.

  ENDDO.


ENDMETHOD.


METHOD /cideon/if_plot_bo~acquire_related_objects .
*& Beschreibung: Am Equipment kann ein Material hinterlegt sein. Dieses
*&               wird hier ermittelt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: ls_general     TYPE bapi_itob,
        lc_key         TYPE string,
        lo_material    TYPE REF TO /cideon/cl_plot_bo_bus1001. "Material

* Details zum Equipment ermitteln
  CALL FUNCTION 'BAPI_EQUI_GETDETAIL'
    EXPORTING
      equipment        = me->equi_number
    IMPORTING
      data_general_exp = ls_general.

  IF NOT ls_general-consttype IS INITIAL.
    CREATE OBJECT lo_material
      EXPORTING
        materialnr = ls_general-consttype.
    lc_key = /cideon/if_plot_bo~get_key( ).
    CALL METHOD related_objects->add(
      key = lc_key
      obj = lo_material
      ).
  ENDIF.
ENDMETHOD.


METHOD /cideon/if_plot_bo~get_icon .
*& Beschreibung: Liefert das Icon für Equipments
*&
*& Autor:        HAENSEL
*& Angelegt am:  30.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  rc_icon = me->icon.
ENDMETHOD.


method /CIDEON/IF_PLOT_BO~GET_KEY .
************************************************************************
* Beschreibung: Erstellung des Objektschlüssels
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

  key = equi_number.

endmethod.


METHOD /cideon/if_plot_bo~get_text.
*& Beschreibung: Liefert die Nummer und die Beschreibung des Equipments
*&               als dargestellten Text
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  CONCATENATE me->equi_number me->description
    INTO rc_text SEPARATED BY space.
ENDMETHOD.


METHOD /cideon/if_plot_bo~set_key.
************************************************************************
* Beschreibung: Übermittlung des Objektschlüssels
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  31.08.2005   HAENSEL  Schlüssel wird nicht mehr an Dokumentverknüpf-
*                        ungstyp weitergegeben.
************************************************************************
  me->equi_number = objkey.
ENDMETHOD.


METHOD constructor.
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 17:57:23
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  CALL METHOD super->constructor
    EXPORTING
      io_additional_data = io_additional_data.

  me->/cideon/if_plot_bo~name = 'EQUI'.
ENDMETHOD.


METHOD create_supported_dlts.
*& Beschreibung: Equipments unterstützen die direkte Verknüpfung mit
*&               Dokumenten.
*&
*& Autor:        HAENSEL
*& Angelegt am:  31.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lc_obj_key    TYPE objky,
        lo_dlt_dol    TYPE REF TO /cideon/cl_plot_dlt_dol,
        lc_key        TYPE string.

* Die unterstützten Dokumenverknüpfungarten initialisieren
  lc_obj_key = me->/cideon/if_plot_bo~get_key( ).
  CREATE OBJECT lo_dlt_dol
    EXPORTING objtype = 'EQUI'
              objkey  = lc_obj_key.
  lc_key = lo_dlt_dol->/cideon/if_plot_dlt~column->name.
  CALL METHOD /cideon/if_plot_bo~supported_dlts->add
    EXPORTING
      key = lc_key
      obj = lo_dlt_dol.
ENDMETHOD.


METHOD set_description.
************************************************************************
* Beschreibung: Übermittelt die Beschreibung des Equipments
*
* Autor:        Heiko Hänsel
* Angelegt am:  06.05.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  me->description = description.
ENDMETHOD.
ENDCLASS.
