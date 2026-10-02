*----------------------------------------------------------------------*
*   INCLUDE ZCL_CLASSES_PLOT                                           *
*----------------------------------------------------------------------*

*Classes
CLASS lcl_event_handler_alv DEFINITION DEFERRED.
CLASS lcl_event_handler_alv_plot DEFINITION DEFERRED.
CLASS lcl_event_handler_tree DEFINITION DEFERRED.

DATA: search_handler TYPE REF TO lcl_event_handler_alv.
DATA: plot_handler TYPE REF TO lcl_event_handler_alv_plot.
DATA: tree_handler TYPE REF TO lcl_event_handler_tree.

DATA: frontend_service TYPE REF TO cl_gui_frontend_services.
