*&---------------------------------------------------------------------*
*& Report  ZCL_MAINTAIN_STAMPS_USER                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  ZCL_MAINTAIN_STAMPS_USER     .


*CLASSES
CLASS lcl_event_handler_alv DEFINITION DEFERRED.
DATA : alv_event_handler TYPE REF TO lcl_event_handler_alv.

*CONTROLS
DATA: obj_docking_container TYPE REF TO cl_gui_docking_container,
      obj_alv_grid          TYPE REF TO cl_gui_alv_grid.

*LAYOUT
DATA: g_layo_alv TYPE lvc_s_layo.

CONSTANTS : c_spras(2) VALUE 'EN'.

*TABS
CONTROLS tabstripcontrol_001 TYPE TABSTRIP.

*ITAB
DATA : itab_stamp_user          TYPE TABLE OF zcl_stamp_user,
       itab_selected_stamp_user TYPE TABLE OF zcl_stamp_user,
       itab_func_exclude        TYPE TABLE OF rsexfcode,
       itab_fieldcat            TYPE TABLE OF lvc_s_fcat.

*WA
DATA: wa_stamp_user          TYPE zcl_stamp_user,
      wa2_stamp_user         TYPE zcl_stamp_user,
      wa_selected_stamp_user TYPE zcl_stamp_user.

*  LVC_ROW
data : lv_index_itab_lvc_t_row TYPE lvc_t_row,
       lv_index_wa_lvc_s_row   TYPE lvc_s_row,
       lv_index                LIKE lvc_s_row-index.


*NORMAL
DATA: lv_index_itab_stamp_USER TYPE i.

* Containerdefinitionen und ALV-Variablen
DATA: ref_container_101     TYPE REF TO cl_gui_custom_container,
      ref_alv_101           TYPE REF TO cl_gui_alv_grid,
      wa_layout             TYPE lvc_s_layo,
      wa_variant            TYPE disvariant,
      wa_fieldcat           LIKE LINE OF itab_fieldcat,
      wa_func_exclude       LIKE LINE OF itab_func_exclude.

DATA: ok_code LIKE sy-ucomm.
DATA: save_ok_code LIKE ok_code.

DATA : lv_flag_toggle_edit   TYPE c VALUE '0',
       lv_flag_modifications TYPE c ,
       lv_flag_toggle_sname  TYPE c .


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_uname  FOR wa_stamp_user-UNAME. " DEFAULT sy-uname.
SELECT-OPTIONS: s_sname  FOR wa_stamp_user-STEMPEL_NAME.
SELECT-OPTIONS: s_fmname FOR wa_stamp_user-FM_NAME.
SELECT-OPTIONS: s_status FOR wa_stamp_user-STATUS.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: sinsname FOR wa_stamp_user-zclinsname.
SELECT-OPTIONS: sinsdate FOR wa_stamp_user-zclinsdate.
SELECT-OPTIONS: sinstime FOR wa_stamp_user-zclinstime.
SELECT-OPTIONS: sinsprog FOR wa_stamp_user-zclinsprog.
SELECT-OPTIONS: supdname FOR wa_stamp_user-zclinsname.
SELECT-OPTIONS: supddate FOR wa_stamp_user-zclupddate.
SELECT-OPTIONS: supdtime FOR wa_stamp_user-zclupdtime.
SELECT-OPTIONS: supdprog FOR wa_stamp_user-zclupdprog.
SELECTION-SCREEN END OF BLOCK bl2.

PERFORM get_data.

CALL SCREEN 100.

INCLUDE ZCL_MAINTAIN_STAMPS_USER_C01.

INCLUDE ZCL_MAINTAIN_STAMPS_USER_CL1.

INCLUDE ZCL_MAINTAIN_STAMPS_USER_F01.

INCLUDE ZCL_MAINTAIN_STAMPS_USER_O01.

INCLUDE ZCL_MAINTAIN_STAMPS_USER_I01.
