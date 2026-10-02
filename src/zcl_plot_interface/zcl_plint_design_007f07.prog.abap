*----------------------------------------------------------------------*
***INCLUDE ZCL_PLINT_DESIGN_007F07 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  maintain_ST_R_USR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_st_r_usr.

  CALL TRANSACTION 'Z_CL_MNTN_USR_GRP_RS'.

ENDFORM.                    " maintain_ST_R_USR
*&---------------------------------------------------------------------*
*&      Form  maintain_ST_R_GRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM maintain_st_r_grp.

  CALL TRANSACTION 'Z_CL_MNTN_GRP_RES_S1'.

ENDFORM.                    " maintain_ST_R_GRP
*&---------------------------------------------------------------------*
*&      Form  get_result_stamp_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_result_stamp_values.
* besorgt die resultierenden Stempeldaten, welche aus den normalen
* Stempelwerten und den Klassifizierungswerten gebildet werden können

  DATA: itab_res_data TYPE TABLE OF zcl_s_stempel_value.
  DATA: wa_res_data TYPE zcl_s_stempel_value.
  DATA: wa_stempel_wert TYPE zcl_s_stempel_value..
*
*  CLEAR itab_class_data.

  CALL FUNCTION '/CIDEON/GET_RESULT_STAMP_DATA'
       EXPORTING
            i_nutzer          = sy-uname
            i_default_nutzer  = default_data-default_nutzer
       TABLES
            i_itab_plotjobs   = itab_tmp_plotjobs_2
            i_itab_stamp_data = itab_stempel_wert
            o_itab_stamp_data = itab_res_data
       EXCEPTIONS
            error             = 1
            OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Anhängen, dann Sortieren
  LOOP AT itab_res_data INTO wa_res_data.
    CLEAR wa_stempel_wert.
    MOVE-CORRESPONDING wa_res_data TO wa_stempel_wert.
    APPEND wa_stempel_wert TO itab_stempel_wert.
  ENDLOOP.

  SORT itab_stempel_wert BY zeile_plotjob stempel_name ASCENDING.
*  DELETE ADJACENT DUPLICATES FROM itab_class_data.

* /CIDEON/GET_RESULT_STAMP_DATA
* View ZCL_V_USR_GRP_RS

ENDFORM.                    " get_result_stamp_values
