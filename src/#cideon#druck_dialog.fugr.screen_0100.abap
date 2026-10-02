PROCESS BEFORE OUTPUT.

 MODULE STATUS_0100.

 CALL SUBSCREEN TAB1_REF1 including sy-repid '0101'.
 CALL SUBSCREEN TAB2_REF1 including sy-repid '0102'.
 CALL SUBSCREEN TAB3_REF1 including sy-repid '0103'.

*
PROCESS AFTER INPUT.

 call subscreen Tab1_Ref1.
 call subscreen Tab2_Ref1.
 call subscreen Tab3_Ref1.

 MODULE USER_COMMAND_0100.
