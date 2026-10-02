*----------------------------------------------------------------------*
*   INCLUDE ZCL_KONSTANTEN                                             *
*----------------------------------------------------------------------*

DATA: c_status_created(2) VALUE '00'.
DATA: c_status_aktiv(2) VALUE '10'.

DATA: c_ja(2) VALUE 'JA'.
DATA: c_nein(4) VALUE 'NEIN'.
DATA: c_aus(3) VALUE 'AUS'.
DATA: c_ein(3) VALUE 'EIN'.


CONSTANTS: c_sl_object_type TYPE object_type VALUE 'STUECKLIST'.
CONSTANTS: c_lk_object_type TYPE object_type VALUE 'LINK'.
CONSTANTS: c_hr_object_type TYPE object_type VALUE 'HIERACHIE'.
CONSTANTS: c_fg_object_type TYPE object_type VALUE 'FOLGE'.
CONSTANTS: c_vg_object_type TYPE object_type VALUE 'VORGANG'.

CONSTANTS: c_user_group_wsapp_selection TYPE zcl_usr_grp VALUE 'SELECT'.


DATA: c_status_created_plot(2) VALUE '00'.
DATA: c_status_work_plot(2) VALUE '10'.
DATA: c_status_processed_plot(2) VALUE '20'.
DATA: c_status_error_created_plot(2) VALUE '30'.
DATA: c_status_locked_created_plot(2) VALUE '40'.


DATA: c_draw_detail_dynpro(4) VALUE '0101'.
DATA: c_draw_no_detail_dynpro(4) VALUE '2101'.

DATA: c_plot_struktur_dynpro(4) VALUE '0102'.
DATA: c_plot_no_struktur_dynpro(4) VALUE '2102'.
