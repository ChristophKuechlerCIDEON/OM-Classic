
PROCESS BEFORE OUTPUT.

  MODULE status_0101.
*
PROCESS AFTER INPUT.

  FIELD: wa_akt_plotjobs-seite_von
      MODULE check_values.

  FIELD:
    wa_akt_plotjobs-seite_bis
      MODULE check_values.

  FIELD:
      wa_akt_plotjobs-verteiler
        MODULE check_values_verteiler.

  MODULE user_command_0101  .

PROCESS ON VALUE-REQUEST.
  FIELD wa_akt_plotjobs-verteiler MODULE verteiler.
