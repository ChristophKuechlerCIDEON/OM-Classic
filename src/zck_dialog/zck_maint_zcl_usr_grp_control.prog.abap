*----------------------------------------------------------------------*
*   INCLUDE ZCK_MAINT_ZCL_USR_GRP_CONTROL                              *
*----------------------------------------------------------------------*

* >>> BILDSCHIRM-MODI <<<
* Anzeigen  - show   - ('0')
* Editieren - edit   - ('1')
* Einfügen  - insert - ('2')
CONSTANTS co_show_mode          VALUE '0'.
CONSTANTS co_edit_mode          VALUE '1'.
CONSTANTS co_insr_mode          VALUE '2'.

* >>> TRANSPORT <<<
* nie('0'):    Im Dialog ist "Einträge transportieren" inaktiv
* kann('1'):   "Einträge transportieren" ist aktiv
* fragen('2'): Beim Speichern und Löschen fragen, ob transportiert
*              werden soll
* muß('3'):    Beim Speichern und Löschen muß an einen Transportauftrag
*              übergeben werden
CONSTANTS co_trans_never        VALUE '0'.
CONSTANTS co_trans_could        VALUE '1'.
CONSTANTS co_trans_ask          VALUE '2'.
CONSTANTS co_trans_must         VALUE '3'.


* Grid parameter

* variant
CONSTANTS co_variant_user       VALUE 'U'.
CONSTANTS co_variant_global     VALUE 'X'.
CONSTANTS co_variant_both       VALUE 'A'.
