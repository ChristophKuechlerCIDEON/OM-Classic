
PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE set_cb.

 CALL SUBSCREEN TAB1_REF1 including sy-repid '0101'.
 CALL SUBSCREEN TAB2_REF1 including sy-repid '0102'.
 CALL SUBSCREEN TAB3_REF1 including sy-repid '0103'.
 CALL SUBSCREEN TAB4_REF1 including sy-repid '0104'.

*



PROCESS AFTER INPUT.

 call subscreen Tab1_Ref1.
 call subscreen Tab2_Ref1.
 call subscreen Tab3_Ref1.
 call subscreen Tab4_Ref1.


  MODULE get_cb.
  MODULE user_command_0100 AT EXIT-COMMAND.

*  FIELD cb_knz_stl_aufl MODULE check_input.
*  MODULE check_input.
*  FIELD cb_knz_stl_aufl MODULE check_input AT CURSOR-SELECTION.



  MODULE user_command_0100.
