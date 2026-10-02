
process before output.

  module status_0100.

  call subscreen tab1_ref1 including sy-repid g_search_list_dynpro.
  call subscreen tab2_ref1 including sy-repid g_plot_list_dynpro.

*  CALL SUBSCREEN TAB1_REF1 including sy-repid '0101'.
*  CALL SUBSCREEN tab2_ref1 INCLUDING sy-repid '0102'.

  module bypass.
  module bypass2.

process after input.
  call subscreen tab1_ref1.
  call subscreen tab2_ref1.

  module user_command_0100.

