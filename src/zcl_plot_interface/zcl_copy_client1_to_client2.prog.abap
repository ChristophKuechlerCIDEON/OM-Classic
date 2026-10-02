REPORT zcl_copy_client1_to_client2 .
*WA
DATA: wa_00 TYPE zcl_plint_cfg_00.
DATA: wa_cfg_usr TYPE zcl_plint_config.
DATA: wa_usr_view TYPE zcl_plint_usr_vw.
DATA: wa_pr_info TYPE zcl_prog_info.
DATA: wa_skel_clf TYPE zcl_skel_clf.
DATA: wa_skel_clf_lin TYPE zcl_skel_clf_lin.
DATA: wa_skeleton TYPE zcl_skeleton.
DATA: wa_skel_lines TYPE zcl_skel_lines.
DATA: wa_param_name_u TYPE zcl_param_name_u.
DATA: wa_param_name TYPE zcl_param_name.
DATA: wa_prog_info_pa TYPE zcl_prog_info_pa.

*NORMA
DATA: source_mandat TYPE sy-mandt.
DATA: destination_mandat TYPE sy-mandt.


PARAMETERS: client_1 TYPE mandt DEFAULT '100'.
PARAMETERS: client_2 TYPE mandt DEFAULT '200'.

PARAMETERS: p_00 TYPE c AS CHECKBOX.
PARAMETERS: p_cfgusr TYPE c AS CHECKBOX.
PARAMETERS: p_usr_vw TYPE c AS CHECKBOX.
PARAMETERS: p_prinfo TYPE c AS CHECKBOX.
PARAMETERS: p_clf TYPE c AS CHECKBOX.
PARAMETERS: p_clflin TYPE c AS CHECKBOX.
PARAMETERS: p_ppl TYPE c AS CHECKBOX.
PARAMETERS: p_ppllin TYPE c AS CHECKBOX.
PARAMETERS: p_para TYPE c AS CHECKBOX.
PARAMETERS: p_para_u TYPE c AS CHECKBOX.
* ZCL_PROG_INFO_PA
PARAMETERS: p_inf_pa TYPE c AS CHECKBOX.

START-OF-SELECTION.

  CHECK NOT client_1 IS INITIAL.
  CHECK NOT client_2 IS INITIAL.


  IF p_00 = 'X'.
    SELECT * FROM zcl_plint_cfg_00 CLIENT SPECIFIED INTO wa_00
      WHERE mandt = client_1 .
      wa_00-mandt = client_2.
      MODIFY zcl_plint_cfg_00 CLIENT SPECIFIED  FROM wa_00 .
      WRITE: / wa_00.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

  IF p_cfgusr = 'X'.
    SELECT * FROM zcl_plint_config CLIENT SPECIFIED INTO wa_cfg_usr
      WHERE mandt = client_1 .
      wa_cfg_usr-mandt = client_2.
      MODIFY zcl_plint_config CLIENT SPECIFIED  FROM wa_cfg_usr .
      WRITE: / wa_cfg_usr.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

  IF p_usr_vw = 'X'.
    SELECT * FROM zcl_plint_usr_vw CLIENT SPECIFIED INTO wa_usr_view
      WHERE mandt = client_1 .
      wa_usr_view-mandt = client_2.
      MODIFY zcl_plint_usr_vw CLIENT SPECIFIED  FROM wa_usr_view .
      WRITE: / wa_usr_view.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

  IF p_inf_pa = 'X'.
    SELECT * FROM zcl_prog_info_pa
      CLIENT SPECIFIED INTO wa_prog_info_pa
      WHERE mandt = client_1 .
      wa_prog_info_pa-mandt = client_2.
      MODIFY zcl_prog_info_pa CLIENT SPECIFIED  FROM wa_prog_info_pa.
      WRITE: / wa_prog_info_pa.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

  IF p_clf = 'X'.
    SELECT * FROM zcl_skel_clf CLIENT SPECIFIED INTO wa_skel_clf
      WHERE mandt = client_1 .
      wa_skel_clf-mandt = client_2.
      MODIFY zcl_skel_clf CLIENT SPECIFIED  FROM wa_skel_clf.
      WRITE: / wa_skel_clf.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

  IF p_clflin = 'X'.
   SELECT * FROM zcl_skel_clf_lin CLIENT SPECIFIED INTO wa_skel_clf_lin
         WHERE mandt = client_1 .
      wa_skel_clf_lin-mandt = client_2.
      MODIFY zcl_skel_clf_lin CLIENT SPECIFIED  FROM wa_skel_clf_lin.
      WRITE: / wa_skel_clf_lin.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

  IF p_ppl = 'X'.
    SELECT * FROM zcl_skeleton CLIENT SPECIFIED INTO wa_skeleton
      WHERE mandt = client_1 .
      wa_skeleton-mandt = client_2.
      MODIFY zcl_skeleton CLIENT SPECIFIED  FROM wa_skeleton.
      WRITE: / wa_skeleton.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

  IF p_ppllin  = 'X'.
    SELECT * FROM zcl_skel_lines CLIENT SPECIFIED INTO wa_skel_lines
      WHERE mandt = client_1 .
      wa_skel_lines-mandt = client_2.
      MODIFY zcl_skel_lines CLIENT SPECIFIED  FROM wa_skel_lines.
      WRITE: / wa_skel_lines.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

*  p_pARA
  IF p_para  = 'X'.
    SELECT * FROM zcl_param_name
      CLIENT SPECIFIED INTO wa_param_name
      WHERE mandt = client_1 .
      wa_param_name-mandt = client_2.
      MODIFY zcl_param_name CLIENT SPECIFIED  FROM wa_param_name.
      WRITE: / wa_param_name.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

*  p_pARA_U
  IF p_para_u  = 'X'.
    SELECT * FROM zcl_param_name_u
      CLIENT SPECIFIED INTO wa_param_name_u
      WHERE mandt = client_1 .
      wa_param_name_u-mandt = client_2.
      MODIFY zcl_param_name_u CLIENT SPECIFIED
        FROM wa_param_name_u.
      WRITE: / wa_param_name_u.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.

* ZCL_PROG_INFO_PA
  IF p_para_u  = 'X'.
    SELECT * FROM zcl_param_name_u
      CLIENT SPECIFIED INTO wa_param_name_u
      WHERE mandt = client_1 .
      wa_param_name_u-mandt = client_2.
      MODIFY zcl_param_name_u CLIENT SPECIFIED
        FROM wa_param_name_u.
      WRITE: / wa_param_name_u.
      WRITE: / sy-subrc.
    ENDSELECT.
  ELSE.
  ENDIF.
