*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_007_CLASS_T                               *
*----------------------------------------------------------------------*


*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_tree DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_tree DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:

    handle_node_double_click
      FOR EVENT node_double_click
      OF cl_simple_tree_model
      IMPORTING node_key
  ,
    handle_node_context_menu_req
      FOR EVENT node_context_menu_request
      OF cl_simple_tree_model
      IMPORTING node_key menu
  ,
    handle_node_context_menu_sel
      FOR EVENT node_context_menu_select
      OF cl_simple_tree_model
      IMPORTING node_key fcode


  .


ENDCLASS.


*---------------------------------------------------------------------*
*       CLASS lcl_event_handler_tree IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_handler_tree IMPLEMENTATION.

  METHOD handle_node_double_click.
    g_event = 'NODE_DOUBLE_CLICK'.
    g_node_key = node_key.
  ENDMETHOD.

  METHOD handle_node_context_menu_req.
    g_event = 'NODE_MENU_REQ'.
    g_node_key = node_key.
    "DATA: text TYPE gui_text.
    "text = 'Löschen'.                                 "#EC NOTEXT
    "CONCATENATE text node_key INTO text SEPARATED BY ' '.
    "CALL METHOD menu->add_function
    "  EXPORTING text = text fcode = 'DELETE_NODE_BLATT'.
    CALL METHOD cl_ctmenu=>load_gui_status
      EXPORTING
        program    = g_repid
        status     = 'ZCL_CTMENU_PLOTTREE'
*        DISABLE    =
        menu       = menu
      EXCEPTIONS
        read_error = 1
        OTHERS     = 2
            .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF f_paste IS INITIAL.
      REFRESH l_disable.
      APPEND 'PASTE_TREE' TO l_disable.
      CALL METHOD menu->disable_functions
        EXPORTING
          fcodes = l_disable
          .
    ELSE.
      REFRESH l_disable.
      APPEND 'PASTE_TREE' TO l_disable.
      CALL METHOD menu->enable_functions
        EXPORTING
          fcodes = l_disable
          .
    ENDIF.

  ENDMETHOD.

  METHOD handle_node_context_menu_sel.
    g_event = 'NODE_MENU_SEL'.
    g_node_key = node_key.
    g_ctx_fcode = fcode.
  ENDMETHOD.


ENDCLASS.
