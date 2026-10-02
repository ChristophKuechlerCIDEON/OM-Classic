
PROCESS BEFORE OUTPUT.

  MODULE status_0900.

  CALL SUBSCREEN tab1_ref1 INCLUDING sy-repid '9001'.
  CALL SUBSCREEN tab2_ref1 INCLUDING sy-repid '9002'.

*
PROCESS AFTER INPUT.

 call subscreen Tab1_Ref1.
 call subscreen Tab2_Ref1.

  MODULE user_command_0900.
