REPORT z_update_param_user .
* ITAB
DATA: itab_param_name TYPE TABLE OF zcl_param_name.
DATA: itab_param_name_u TYPE TABLE OF zcl_param_name_u.
* WA
DATA: wa_param_name TYPE zcl_param_name.
DATA: wa_param_name_u TYPE zcl_param_name_u.



SELECT * FROM zcl_param_name
  INTO TABLE itab_param_name.
IF sy-subrc NE 0.
ELSE.
ENDIF.

LOOP AT itab_param_name INTO wa_param_name.
  MODIFY zcl_param_name_u FROM wa_param_name.

ENDLOOP.
