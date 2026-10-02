FUNCTION-POOL /cideon/druck_dialog.             "MESSAGE-ID ..

* Einbinden des TOP Includes des Plot Interfaces


INCLUDE <icon>.
INCLUDE /cideon/_konstanten.
*include zcl_konstanten.

INCLUDE /cideon/_variablen_plot.
*include zcl_variablen_plot.


DATA: g_f_code(30).


"Kontrollierter Druck

DATA: rb_k_d.
DATA: rb_n_d.
DATA: rb_charge.
DATA: rb_u_d.

DATA: lt_recipient TYPE TABLE OF /CIDEON/S_RECIPIENT.
DATA: ls_recipient TYPE /CIDEON/S_RECIPIENT.


*ALV
DATA: cont_alv_recipient TYPE REF TO cl_gui_custom_container.
DATA: alv_recipient TYPE REF TO cl_gui_alv_grid.
* layout variable of alv grid
DATA:       recipient_s_layo         TYPE lvc_s_layo.

* variant structure
DATA:       recipient_s_variant      TYPE disvariant.

DATA: lc_tb_ex TYPE ui_func.
data: it_tb_ex_recipient type ui_functions.
