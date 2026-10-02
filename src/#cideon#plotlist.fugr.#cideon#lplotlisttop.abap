FUNCTION-POOL /cideon/plotlist.             "MESSAGE-ID ..



DATA: f_init(1) VALUE 'X'.




DATA: ok_code LIKE sy-ucomm.
DATA: save_code LIKE sy-ucomm.


*CL Coustom Controls
DATA: alv_files TYPE REF TO cl_gui_alv_grid.
DATA: custom_control_files TYPE REF TO cl_gui_custom_container.


DATA: layo_files TYPE lvc_s_layo.

data:  dv_files type disvariant.
data:  x_save_files value 'A'.

*LVC_T_ROW
DATA: lt_sel_rows TYPE lvc_t_row.

DATA: lc_sel_rows TYPE lvc_s_row.

DATA: lt_files_internal TYPE TABLE OF zori_doc_files.
DATA: lc_files_internal TYPE zori_doc_files.
