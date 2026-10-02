
PROCESS BEFORE OUTPUT.

  MODULE modify_screen_0201.
  MODULE set_position.
  MODULE set_screen_focus.

PROCESS AFTER INPUT.

  CHAIN.
    FIELD mara-matnr MODULE check_mat_exist ON INPUT.
    FIELD stpo-meins MODULE check_meins ON INPUT.
    FIELD stpo-menge MODULE check_menge ON INPUT.
  ENDCHAIN.

  MODULE check_position_fcmat.
