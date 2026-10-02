FUNCTION-POOL /cideon/audit_trail.          "MESSAGE-ID ..

CONSTANTS: c_plot_log_entry_created TYPE char2 VALUE '00'.
CONSTANTS: c_plot_log_entry_confirmed TYPE char2 VALUE '20'.


DATA: ok_code LIKE sy-ucomm.

DATA: f_exit VALUE ''.
DATA: f_dont_ask VALUE ''.

DATA: ausgabe(5).
