
PROCESS BEFORE OUTPUT.

  MODULE status_0675.
*
PROCESS AFTER INPUT.
* field zcl_s_draw01-doknr .
  MODULE user_command_0675 AT EXIT-COMMAND.

  MODULE user_command_0675.


PROCESS ON VALUE-REQUEST.
  FIELD g_smartform_cs02_spr MODULE spras_cs02.
  FIELD g_smartform_cs11_spr MODULE spras_cs11.
  FIELD g_smartform_cs12_spr MODULE spras_cs12.
  FIELD g_smartform_cs13_spr MODULE spras_cs13.


