*----------------------------------------------------------------------*
*   INCLUDE Z_SIMPLE_TREE1_O01                                         *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'SIMPLE_OTPUT'.
*  SET TITLEBAR 'xxx'.
  IF g_application IS INITIAL.
    CREATE OBJECT g_application.
  ELSE.
  ENDIF.
  IF g_tree IS INITIAL.
    PERFORM create_and_init_tree.
  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
