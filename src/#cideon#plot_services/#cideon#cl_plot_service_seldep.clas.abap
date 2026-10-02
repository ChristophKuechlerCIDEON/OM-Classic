class /CIDEON/CL_PLOT_SERVICE_SELDEP definition
  public
  inheriting from /CIDEON/CL_PLOT_SERVICE
  abstract
  create public .

*"* public components of class /CIDEON/CL_PLOT_SERVICE_SELDEP
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .

  methods EXECUTE
    redefinition .
  type-pools SEOX .
*"* protected components of class /CIDEON/CL_PLOT_SERVICE_SELDEP
*"* do not include other source files here!!!
protected section.

  data SELECTION_TREE type ref to /CIDEON/CL_UI_TREE_SELECTION .
  data DOCUMENTS type /CIDEON/T_PDM_OBJECTS .
  data SELECTED_COL_VALUES type ref to /CIDEON/CL_OO_COLLECTION .
*"* private components of class /CIDEON/CL_PLOT_SERVICE_SELDEP
*"* do not include other source files here!!!
private section.

  data MO_NODE_CT_MGR type ref to /CIDEON/CL_UI_CT_MENU_MANAGER .
  data EVENT_RECEIVER type ref to OBJECT .
  data MO_COLUMN_CT_MGR type ref to /CIDEON/CL_UI_CT_MENU_MANAGER .

  methods INITIALIZE_CT_MENU .
  type-pools SEOX .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_SERVICE_SELDEP IMPLEMENTATION.


METHOD constructor.
*& Beschreibung: Initialisierung der Auswahlabhängigen Dienste.
*&
*& Autor:        HAENSEL
*& Angelegt am:  06.09.2006 21:50:32
*&----------------------------------------------------------------------
*& Änderungen:
*&
*&----------------------------------------------------------------------

* Konstruktor der Basisklasse aufrufen
  CALL METHOD super->constructor.
* Referenz auf den Selektionsdialog holen
*  CALL METHOD /cideon/cl_ui_tree_selection=>get_reference
*                  RECEIVING eo_tree_selection = selection_tree.


* Mehrfachselektion erlauben
*  call method selection_tree->set_node_selection_mode(
*    /cideon/cl_ui_tree_selection=>node_sel_mode_multiple
*  ).

  CREATE OBJECT selected_col_values.
ENDMETHOD.


METHOD execute.
************************************************************************
* Beschreibung: Dient als Basis EXECUTE Methode, die von den
*               generalisierteren Diensten verwendet wird. Es werden
*               gemeinsame Aktivitäten für das Ausführen des Dienstes
*               bei selektionsabhängigen Diensten durchgeführt.
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  15.04.2005   HAENSEL  Unterstützung von Zusatzdaten aus Business
*                        Objekten
*  30.08.2005   HAENSEL  Umstellung auf neues View Framework mit
*                        Content- und Labelprovider.
*  01.09.2005   HAENSEL  Maximale Tiefe für den Selektionsbaum ist 10
*  06.09.2006   HAENSEL  Action für persönliche Einstellungen einbinden.
*  01.02.2007   HAENSEL  Das CHECKBOX_CHANGE Ereignis vor dem SET_INPUT
*                        Methodenaufruf, da sonst bei der Vorbelegung
*                        das Ereignis nicht behandelt wird.
* 12.11.2008 - CKR
*              BADI Implementierungen für PLOT_BO und DLT
*
************************************************************************

  DATA:  selected_items TYPE /cideon/object_array,
         lo_objects     TYPE REF TO /cideon/cl_oo_custom_map,
         lo_iter        TYPE REF TO /cideon/if_oo_iterator,
         lo_columns     TYPE REF TO /cideon/cl_oo_collection,
         column_value   TYPE REF TO /cideon/cl_ui_tree_col_value,
         lo_dlts        TYPE REF TO /cideon/cl_oo_array,
         lo_dlt_iter    TYPE REF TO /cideon/if_oo_iterator,
         ls_event       TYPE cntl_simple_event,
         lo_event_handler TYPE REF TO lcl_event_receiver,
         lt_events      TYPE cntl_simple_events,
         lc_key         TYPE string,
         lt_tmp_docdata TYPE /cideon/t_pdm_objects,
         lt_bo_documents TYPE /cideon/t_pdm_objects,
         lo_plot_bo     TYPE REF TO /cideon/if_plot_bo,
         lo_dlt         TYPE REF TO /cideon/if_plot_dlt,
         lo_addt_data   TYPE REF TO /cideon/cl_oo_collection,
         lo_addt_data_iter TYPE REF TO /cideon/if_oo_iterator,
         lo_addt_data_rec TYPE REF TO /cideon/cl_oo_string,
         lc_addt_data_fname  TYPE string,
         lo_settings_action  TYPE REF TO lcl_settings_action,
         lo_selall_action    TYPE REF TO lcl_selall_action,
         lo_deselall_action    TYPE REF TO lcl_deselall_action,
         lb_expand_all       TYPE abap_bool.


  DATA: lo_hierarchy_column   TYPE REF TO /cideon/cl_ui_table_column,
        lc_text               TYPE string,
        lo_plot_bo_provider   TYPE REF TO /cideon/cl_plot_bo_provider,
        lo_plot_bo_label_prov TYPE REF TO /cideon/cl_plot_bo_label_prov.


  FIELD-SYMBOLS: <ls_bo_document> TYPE zcl_pdm_exp_objects,
                 <lc_tmp_doc_field> TYPE ANY.


* Vorher ermittelte Objekte löschen, da das Objekt bei mehrerem Starten
* des Dienstes nicht neu erzeugt wird.
  CALL METHOD business_object->remove_all_objects.
*  CALL METHOD selection_tree->delete_all_nodes.
* Liste der ermittelten Dokumente initialisieren.
  REFRESH documents.

* Hierarchiespaltendefinition erzeugen
  lc_text = text-001.
  CREATE OBJECT lo_hierarchy_column
    EXPORTING
      ic_name  = 'HIERARCHY'
      ii_width = 100
      ic_text  = lc_text.

* Selektionsdialog Objekt erzeugen
  CREATE OBJECT selection_tree
    EXPORTING
      ii_selection_mode = cl_gui_simple_tree=>node_sel_mode_multiple
      io_hierarchy_column = lo_hierarchy_column.

* Maximale Tiefe 2 Ebenen
  CALL METHOD selection_tree->set_max_expansion_level( 10 ).

* Content Provider und Label Provider erzeugen und dem Selektions-
* dialog übermitteln
  CREATE OBJECT lo_plot_bo_provider.
  CALL METHOD selection_tree->set_content_provider
    EXPORTING
      io_content_provider = lo_plot_bo_provider.
  CALL METHOD selection_tree->set_column_provider
    EXPORTING
      io_column_provider = lo_plot_bo_provider.
  CREATE OBJECT lo_plot_bo_label_prov.
  CALL METHOD selection_tree->set_label_provider
    EXPORTING
      io_label_provider = lo_plot_bo_label_prov.

* Kontextmenu initialisieren
  CALL METHOD initialize_ct_menu.


* Menümanager für Spalten übergeben
  CALL METHOD selection_tree->set_column_ct_menu_mgr
    EXPORTING
      io_context_menu_mgr = mo_column_ct_mgr.

* Menümanager für Knoten übergeben
  CALL METHOD selection_tree->set_node_ct_menu_mgr
    EXPORTING
      io_context_menu_mgr = mo_node_ct_mgr.


* Ereignis CHECKBOX_CHANGE registrieren
  CREATE OBJECT lo_event_handler.
  ls_event-eventid = cl_item_tree_model=>eventid_checkbox_change.
  APPEND ls_event TO lt_events.
  CALL METHOD selection_tree->set_registered_events
    EXPORTING
      it_events = lt_events.
  SET HANDLER lo_event_handler->handle_checkbox_change
    FOR selection_tree.

* Plot Business Objekt an den Selektionsdialog übergeben
  CALL METHOD selection_tree->set_input
    EXPORTING
      io_input = business_object.

* Actions zum Dialog hinzufügen
  CREATE OBJECT lo_selall_action
    EXPORTING io_selection_tree = selection_tree.
  CALL METHOD selection_tree->add_action( lo_selall_action ).
  CREATE OBJECT lo_deselall_action
    EXPORTING io_selection_tree = selection_tree.
  CALL METHOD selection_tree->add_action( lo_deselall_action ).
  CREATE OBJECT lo_settings_action.
  CALL METHOD selection_tree->add_action( lo_settings_action ).

* Persönliche Einstellugen verarbeiten
  CALL FUNCTION '/CIDEON/PLOT_SRV_GET_SETTINGS'
    IMPORTING
      eb_expand_all = lb_expand_all.

* Selektionsdialog anzeigen
  CALL METHOD selection_tree->show
    EXPORTING
      iv_title          = text-002
*      ii_left           = 5
*      ii_top            = 5
       ii_width          = 80
*      ii_height         = 30
       ib_expand_all     = lb_expand_all
    RECEIVING
      rt_selected_items = selected_items
    EXCEPTIONS
      user_canceled     = 1.
  IF sy-subrc = 1.
    MESSAGE i001(/cideon/plot_service) RAISING execution_failed.
    EXIT.
  ENDIF.

  "CKR 2008/11/12
  DATA: exit TYPE REF TO /cideon/if_ex_pls_main01.

  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = exit.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.


* Event Handler nach den Elementen befragen
  lo_objects = lo_event_handler->get_checked_objects( ).
  lo_iter = lo_objects->create_iterator( ).
  WHILE lo_iter->has_next( ) = abap_true.
    lo_columns ?= lo_iter->get_next( ).

*   Anhand der selektierten Checkboxen, die benötigten Dokumentver-
*   knüpfungen ermitteln.
    lo_plot_bo ?= lo_objects->get_key_by_value( lo_columns ).
    lo_dlts = lo_plot_bo->get_supported_dlts( ).
    lo_dlt_iter = lo_dlts->create_iterator( ).
    REFRESH lt_bo_documents.
    WHILE lo_dlt_iter->has_next( ) = abap_true.
      lo_dlt ?= lo_dlt_iter->get_next( ).
      lc_key = lo_dlt->column->name.
      IF lo_columns->exists( lc_key ) = abap_true.
        REFRESH lt_tmp_docdata.
        lt_tmp_docdata = lo_dlt->acquire_documents( ).

        "CKR 2008/11/12
        IF exit IS INITIAL.
        ELSE.
          CALL METHOD exit->after_doc_aqquired
            CHANGING
              lo_plot_bo     = lo_plot_bo
              lo_dlt         = lo_dlt
              lt_tmp_docdata = lt_tmp_docdata.
        ENDIF.

        INSERT LINES OF lt_tmp_docdata INTO TABLE lt_bo_documents.
      ENDIF.
    ENDWHILE.

*   Zusatzdaten aus dem Business Objekt ind die Dokumente einstreuen.
    IF NOT lt_bo_documents IS INITIAL.
      lo_addt_data = lo_plot_bo->get_additional_data( ).
      IF NOT lo_addt_data IS INITIAL.
        lo_addt_data_iter =
          lo_addt_data->/cideon/if_oo_aggregate~create_iterator( ).
        DO.
          IF lo_addt_data_iter->has_next( ) = abap_false. EXIT. ENDIF.
          lo_addt_data_rec ?= lo_addt_data_iter->get_next( ).
          lc_addt_data_fname = lo_addt_data->get_object_key(
            lo_addt_data_rec
          ).
          LOOP AT lt_bo_documents ASSIGNING <ls_bo_document>.
            ASSIGN COMPONENT lc_addt_data_fname OF STRUCTURE
              <ls_bo_document> TO <lc_tmp_doc_field>.
            IF sy-subrc = 0.
              <lc_tmp_doc_field> = lo_addt_data_rec->string.
            ENDIF.
          ENDLOOP.
        ENDDO.
      ENDIF.
      INSERT LINES OF lt_bo_documents INTO TABLE documents.
    ENDIF.

  ENDWHILE.

  "CKR 2008/11/12
  IF exit IS INITIAL.
  ELSE.
    CALL METHOD exit->after_bo_aqqurired
      CHANGING
        lo_plot_bo = lo_plot_bo
        documents  = documents.
  ENDIF.



  IF documents IS INITIAL.
    MESSAGE e008(/cideon/plot_service) RAISING execution_failed.
*   Es konnten keine Dokumente zum Plotten ermittelt werden!
  ENDIF.
ENDMETHOD.


method INITIALIZE_CT_MENU .
data: lo_col_sel_all_action type ref to lcl_sel_all_action,
      lo_col_desel_all_action type ref to lcl_desel_all_action,
      lo_row_desel_all_action TYPE REF TO lcl_row_desel_all_action,
      lo_row_sel_all_action TYPE REF TO lcl_row_sel_all_action.

CREATE OBJECT MO_COLUMN_CT_MGR
  EXPORTING IC_ID = 'PLOT_SERV_COLUMN_MGR'.

CREATE OBJECT MO_NODE_CT_MGR
  EXPORTING IC_ID = 'PLOT_SERV_NODE_MGR'.

* Spaltenactions
CREATE OBJECT lo_col_sel_all_action
  EXPORTING io_selection_tree = selection_tree.
CREATE OBJECT lo_col_desel_all_action
  EXPORTING io_selection_tree = selection_tree.

CALL METHOD MO_COLUMN_CT_MGR->ADD_ACTION
  EXPORTING
    IO_ACTION = lo_col_sel_all_action.

CALL METHOD MO_COLUMN_CT_MGR->ADD_ACTION
  EXPORTING
    IO_ACTION = lo_col_desel_all_action.

* Knotenactions
CREATE OBJECT lo_row_sel_all_action
  EXPORTING io_selection_tree = selection_tree.
CREATE OBJECT lo_row_desel_all_action
  EXPORTING io_selection_tree = selection_tree.

CALL METHOD MO_NODE_CT_MGR->ADD_ACTION
  EXPORTING
    IO_ACTION = lo_row_sel_all_action.

CALL METHOD MO_NODE_CT_MGR->ADD_ACTION
  EXPORTING
    IO_ACTION = lo_row_desel_all_action.


endmethod.
ENDCLASS.
