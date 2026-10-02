*----------------------------------------------------------------------*
*   INCLUDE Z_SIMPLE_TREE1_C01                                         *
*----------------------------------------------------------------------*

CLASS lcl_application DEFINITION.

  PUBLIC SECTION.
    METHODS :

      handle_node_double_click FOR EVENT
          node_double_click OF cl_simple_tree_model
                                      IMPORTING node_key.

ENDCLASS.


*---------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.

  METHOD handle_node_double_click.

    g_event = 'NODE_DOUBLE_CLICK'.
    g_node_key = node_key.

  ENDMETHOD.

ENDCLASS.
