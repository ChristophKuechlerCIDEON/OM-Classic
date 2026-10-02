PROCESS BEFORE OUTPUT.
 MODULE STATUS_0120.
*
PROCESS AFTER INPUT.
* MODULE USER_COMMAND_0120.

  field:
      wa_akt_plotjobs-verteiler
        module check_values_verteiler.

process on value-request.
  FIELD WA_AKT_PLOTJOBS-VOREINSTELLUNG MODULE voreinstellung.
  FIELD WA_AKT_PLOTJOBS-VERTEILER MODULE VERTEILER.
