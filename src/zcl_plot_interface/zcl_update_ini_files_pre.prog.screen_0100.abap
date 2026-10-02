
PROCESS BEFORE OUTPUT.

  MODULE status_0100.

  MODULE set_checkboxen.

*  Module set_data.

*
PROCESS AFTER INPUT.

  MODULE get_checkboxen.

*  MODULE get_data.

  MODULE user_command_0100 AT EXIT-COMMAND.

  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD wa_work_normal-preprozessor MODULE preprocessor.

