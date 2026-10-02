
PROCESS BEFORE OUTPUT.

  MODULE status_0100.

  CALL SUBSCREEN tab1_ref1 INCLUDING sy-repid g_search_list_dynpro.
  CALL SUBSCREEN tab2_ref1 INCLUDING sy-repid g_plot_list_dynpro.

*  CALL SUBSCREEN TAB1_REF1 including sy-repid '0101'.
*  CALL SUBSCREEN tab2_ref1 INCLUDING sy-repid '0102'.

  MODULE bypass.

PROCESS AFTER INPUT.
  CALL SUBSCREEN tab1_ref1.
  CALL SUBSCREEN tab2_ref1.

  MODULE user_command_0100.

