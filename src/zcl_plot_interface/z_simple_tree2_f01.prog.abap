*----------------------------------------------------------------------*
*   INCLUDE Z_SIMPLE_TREE2_F01                                         *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  create_and_init_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_and_init_tree.

  DATA : event TYPE cntl_simple_event,
         events TYPE cntl_simple_events.


  CREATE OBJECT g_tree
          EXPORTING
node_selection_mode = cl_simple_tree_model=>node_sel_mode_single
*node_selection_mode = cl_simple_tree_model=>node_sel_mode_multiple
          EXCEPTIONS
  illegal_node_selection_mode = 1.

  IF sy-subrc <> 0.

  ENDIF.


  CREATE OBJECT g_docking_container
    EXPORTING
*    PARENT                      =
*    REPID                       =
      dynnr                       = '0100'
      side = cl_gui_docking_container=>dock_at_left
      extension                   = 300
*    STYLE                       =
*    LIFETIME                    = lifetime_default
*    CAPTION                     =
*    METRIC                      = 0
*    RATIO                       =
*    NO_AUTODEF_PROGID_DYNNR     =
*    NAME                        =
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      others                      = 6
      .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



******
  CALL METHOD g_tree->create_tree_control
    EXPORTING
*      LIFETIME                     =
      parent                       = g_docking_container
*      SHELLSTYLE                   =
*    IMPORTING
*      CONTROL                      =
    EXCEPTIONS
      lifetime_error               = 1
      cntl_system_error            = 2
      create_error                 = 3
      failed                       = 4
      tree_control_already_created = 5
      OTHERS                       = 6
          .
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*******

  event-eventid = cl_simple_tree_model=>eventid_node_double_click.

  event-appl_event = 'X'.

  APPEND event TO events.

  CALL METHOD g_tree->set_registered_events
    EXPORTING
      events                    = events
    EXCEPTIONS
      illegal_event_combination = 1
      unknown_event             = 2
      OTHERS                    = 3
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SET HANDLER g_application->handle_node_double_click FOR g_tree.

  PERFORM add_nodes.

  CALL METHOD g_tree->expand_node
    EXPORTING
      node_key            = 'Root'
*      EXPAND_PREDECESSORS =
*      EXPAND_SUBTREE      =
*      LEVEL_COUNT         =
    EXCEPTIONS
      node_not_found      = 1
      OTHERS              = 2
          .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " create_and_init_tree


*&---------------------------------------------------------------------*
*&      Form  add_nodes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_nodes.

  CALL METHOD g_tree->add_node
    EXPORTING
      node_key                = 'Root'
*    RELATIVE_NODE_KEY       =
*    RELATIONSHIP            =
      isfolder                = 'X'
      text                    = 'ROOT'
*    HIDDEN                  =
*    DISABLED                =
*    STYLE                   =
*    NO_BRANCH               =
*    EXPANDER                =
*    IMAGE                   =
*    EXPANDED_IMAGE          =
*    DRAG_DROP_ID            =
*    USER_OBJECT             =
    EXCEPTIONS
      node_key_exists         = 1
      illegal_relationship    = 2
      relative_node_not_found = 3
      node_key_empty          = 4
      OTHERS                  = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  CALL METHOD g_tree->add_node
    EXPORTING
      node_key                = 'Child1'
      relative_node_key       = 'Root'
      relationship            = cl_simple_tree_model=>relat_last_child
      isfolder                = 'X'
      text                    = 'Child1'
*    HIDDEN                  =
*    DISABLED                =
*    STYLE                   =
*    NO_BRANCH               =
*    EXPANDER                =
*    IMAGE                   =
*    EXPANDED_IMAGE          =
*    DRAG_DROP_ID            =
*    USER_OBJECT             =
    EXCEPTIONS
      node_key_exists         = 1
      illegal_relationship    = 2
      relative_node_not_found = 3
      node_key_empty          = 4
      OTHERS                  = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD g_tree->add_node
    EXPORTING
      node_key                = 'Child2'
    relative_node_key       = 'Child1'
    relationship            = cl_simple_tree_model=>relat_last_child
      isfolder                = ''
      text                    = 'Child2'
*    HIDDEN                  =
*    DISABLED                =
*    STYLE                   =
*    NO_BRANCH               =
*    EXPANDER                =
*    IMAGE                   =
*    EXPANDED_IMAGE          =
*    DRAG_DROP_ID            =
*    USER_OBJECT             =
    EXCEPTIONS
      node_key_exists         = 1
      illegal_relationship    = 2
      relative_node_not_found = 3
      node_key_empty          = 4
      OTHERS                  = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD g_tree->add_node
    EXPORTING
      node_key                = 'New1'
      relative_node_key       = 'Child1'
      relationship            = cl_simple_tree_model=>relat_last_child
      isfolder                = ''
      text                    = 'New1'
*    HIDDEN                  =
*    DISABLED                =
*    STYLE                   =
*    NO_BRANCH               =
*    EXPANDER                =
*    IMAGE                   =
*    EXPANDED_IMAGE          =
*    DRAG_DROP_ID            =
*    USER_OBJECT             =
    EXCEPTIONS
      node_key_exists         = 1
      illegal_relationship    = 2
      relative_node_not_found = 3
      node_key_empty          = 4
      OTHERS                  = 5
          .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
