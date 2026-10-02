class /CIDEON/CL_PLOT_BO_LABEL_PROV definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_PLOT_BO_LABEL_PROV
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_UI_BASE_LABEL_PROV .
  interfaces /CIDEON/IF_UI_LABEL_PROVIDER .
  interfaces /CIDEON/IF_UI_TABLE_LABEL_PROV .

  methods CONSTRUCTOR .
*"* protected components of class /CIDEON/CL_PLOT_BO_LABEL_PROV
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_PLOT_BO_LABEL_PROV
*"* do not include other source files here!!!
private section.

  data MT_OBJTYPE_SETTINGS type OBJTYPE_SET_T .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_BO_LABEL_PROV IMPLEMENTATION.


METHOD /cideon/if_ui_label_provider~get_icon.
*& Beschreibung: Liefert das Icon des Plot Business Objektes, sofern
*&               es eines gibt.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lo_plot_bo  TYPE REF TO /cideon/if_plot_bo.

* Sicherstellen, dass es sich um ein Plotobjekt handelt.
  lo_plot_bo ?= io_element.
  rc_icon = lo_plot_bo->get_icon( ).
ENDMETHOD.


METHOD /cideon/if_ui_label_provider~get_text.
*& Beschreibung: Liefert den anzuzeigenden Text des Plot Business
*&               Objektes.
*&
*& Autor:        HAENSEL
*& Angelegt am:  17.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

  DATA: lo_plot_bo  TYPE REF TO /cideon/if_plot_bo.

* Sicherstellen, dass es sich um ein Plotobjekt handelt.
  lo_plot_bo ?= io_element.
  rc_text = lo_plot_bo->get_text( ).
ENDMETHOD.


METHOD /cideon/if_ui_table_label_prov~get_column_value.
*& Beschreibung: Liefert die Checkboxen für die jeweiligen unterstützten
*&               Dokumentverknüpfungstypen
*&
*& Autor:        HAENSEL
*& Angelegt am:  29.08.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  11.09.2006 HAENSEL Vorgabewerte mit einbeziehen.
*&----------------------------------------------------------------------

  DATA: lo_plot_bo  TYPE REF TO /cideon/if_plot_bo,
        lo_dlts     TYPE REF TO /cideon/cl_oo_array,
        lo_iter     TYPE REF TO /cideon/if_oo_iterator,
        lo_dlt      TYPE REF TO /cideon/if_plot_dlt,
        lb_chosen   TYPE abap_bool,
        lc_dlt      TYPE string.

  FIELD-SYMBOLS: <ls_objtype_setting> TYPE /cideon/plsrvset.

* Sicherstellen, dass es sich um ein Plotobjekt handelt.
  lo_plot_bo ?= io_element.

* Dokumentverknüpfungstypen besorgen
  lo_dlts = lo_plot_bo->get_supported_dlts( ).
  CHECK NOT lo_dlts IS INITIAL.
  lo_iter = lo_dlts->create_iterator( ).
  WHILE lo_iter->has_next( ) = abap_true.
    lo_dlt ?= lo_iter->get_next( ).
    IF lo_dlt->column = io_column.
*     Dokumentverknüpfungstyp wird unterstützt, also wird eine Checkbox
*     eingefügt.

*     Auf Vorgabewert prüfen
      lc_dlt = lo_dlt->column->name.
      READ TABLE mt_objtype_settings ASSIGNING <ls_objtype_setting>
        WITH TABLE KEY mandt = sy-mandt
                       uname = sy-uname
                       bo_type = lo_plot_bo->name
                       dlt     = lc_dlt.
      IF sy-subrc = 0.
        lb_chosen = <ls_objtype_setting>-value.
      ENDIF.

      CREATE OBJECT ro_column_value
        EXPORTING
          column_name = io_column->name
          class       = cl_item_tree_model=>item_class_checkbox
          font        = cl_item_tree_model=>item_font_default
          visible     = abap_true
          editable    = abap_true
          txtisqinfo  = abap_true
          text        = io_column->tooltip
          chosen      = lb_chosen.
    ENDIF.
  ENDWHILE.
ENDMETHOD.


METHOD constructor.
*& Beschreibung: Liest die Vorgabewerte aus der Einstellungstabelle
*&               und speichert die Daten für später zwischen
*&
*& Autor:        HAENSEL
*& Angelegt am:  11.09.2006 14:52:17
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
  DATA: lt_objtype_settings TYPE /cideon/plsrvset_t.

* Lesen der Daten
  CALL FUNCTION '/CIDEON/PLOT_SRV_GET_SETTINGS'
    IMPORTING
      et_objtype_settings = lt_objtype_settings.
* Hashtabelle füllen
  mt_objtype_settings[] = lt_objtype_settings.


ENDMETHOD.
ENDCLASS.
