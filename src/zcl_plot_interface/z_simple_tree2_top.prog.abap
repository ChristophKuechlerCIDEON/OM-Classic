*&---------------------------------------------------------------------*
*& Include Z_SIMPLE_TREE1_TOP                                          *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  z_simple_tree1 MESSAGE-ID tree_model_msg.


CLASS lcl_application DEFINITION DEFERRED.

CLASS cl_gui_cfw DEFINITION LOAD.

DATA : g_application      TYPE REF TO lcl_application,
*       g_custom_container TYPE REF TO cl_gui_custom_container,
       g_tree             TYPE REF TO cl_simple_tree_model,
       g_container        TYPE REF TO cl_gui_container,
       g_docking_container type ref to cl_gui_docking_container.

DATA : g_event(30)    TYPE c,
       g_node_key(30) TYPE c,
       g_ok_code      TYPE sy-ucomm.


* Data for PAI.
DATA  : return_code TYPE i.
