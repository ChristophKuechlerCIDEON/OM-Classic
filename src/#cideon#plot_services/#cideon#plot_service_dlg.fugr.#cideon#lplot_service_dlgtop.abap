FUNCTION-POOL /cideon/plot_service_dlg.     "MESSAGE-ID ..

TYPE-POOLS: abap.

* Globale Vatiablen für Dynprofelder
DATA: gb_collapse_all TYPE abap_bool,
      gb_expand_all   TYPE abap_bool.

* Control Objekte
DATA: go_objlist_container TYPE REF TO cl_gui_custom_container,
      go_objlist_control   TYPE REF TO cl_gui_alv_grid,
      gt_objlist_fcat      TYPE lvc_t_fcat,
      gs_objlist_layout    TYPE lvc_s_layo,
      gt_toolbar_excluding TYPE ui_functions.

DATA: gt_objtype_settings TYPE /cideon/plsrvset_t,

*     Puffer Tabelle für Datenabgleich beim Laden und Speichern
*     der Einstellungen für die Objekttypen.
*     !!! Nur in den FBs /CIDEON/PLOT_SRV_SET_SETTINGS und
*         /CIDEON/PLOT_SRV_GET_SETTINGS verändern.
      gt_objtype_sett_buf TYPE /cideon/plsrvset_t.
