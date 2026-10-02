*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_ROUTINES                                         *
*----------------------------------------------------------------------*


FORM set_info_werte.
*    FIELD ZCL_PLINT_CONFIG-ZCLINSNAME .
*    FIELD ZCL_PLINT_CONFIG-ZCLINSDATE .
*    FIELD ZCL_PLINT_CONFIG-ZCLINSTIME .
*    FIELD ZCL_PLINT_CONFIG-ZCLINSPROG .
ENDFORM.




*---------------------------------------------------------------------*
*       FORM set_info_werte_USR_TDWP                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_info_werte_usr_tdwp.
  IF zplint_usr_tdwp-zclinsname IS INITIAL.
    zplint_usr_tdwp-zclinsname = sy-uname.
    zplint_usr_tdwp-zclinsdate = sy-datum.
    zplint_usr_tdwp-zclinstime = sy-uzeit.
    zplint_usr_tdwp-zclinsprog = sy-repid.
    zplint_usr_tdwp-zclupdname = sy-uname.
    zplint_usr_tdwp-zclupddate = sy-datum.
    zplint_usr_tdwp-zclupdtime = sy-uzeit.
    zplint_usr_tdwp-zclupdprog = sy-repid.
  ELSE.
    zplint_usr_tdwp-zclupdname = sy-uname.
    zplint_usr_tdwp-zclupddate = sy-datum.
    zplint_usr_tdwp-zclupdtime = sy-uzeit.
    zplint_usr_tdwp-zclupdprog = sy-repid.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM set_info_werte_USR_VW                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_info_werte_usr_vw.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM set_info_werte_cfg_00                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_info_werte_cfg_00.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM set_info_werte_USR_GRP                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_info_werte_usr_grp.
  IF zcl_usr_grp_tab-zclinsname IS INITIAL.
    zcl_usr_grp_tab-zclinsname = sy-uname.
    zcl_usr_grp_tab-zclinsdate = sy-datum.
    zcl_usr_grp_tab-zclinstime = sy-uzeit.
    zcl_usr_grp_tab-zclinsprog = sy-repid.
    zcl_usr_grp_tab-zclupdname = sy-uname.
    zcl_usr_grp_tab-zclupddate = sy-datum.
    zcl_usr_grp_tab-zclupdtime = sy-uzeit.
    zcl_usr_grp_tab-zclupdprog = sy-repid.
  ELSE.
    zcl_usr_grp_tab-zclupdname = sy-uname.
    zcl_usr_grp_tab-zclupddate = sy-datum.
    zcl_usr_grp_tab-zclupdtime = sy-uzeit.
    zcl_usr_grp_tab-zclupdprog = sy-repid.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM set_info_werte_mail_cfg                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_info_werte_mail_cfg..
  IF zcl_mail_cfg-zclinsname IS INITIAL.
    zcl_mail_cfg-zclinsname = sy-uname.
    zcl_mail_cfg-zclinsdate = sy-datum.
    zcl_mail_cfg-zclinstime = sy-uzeit.
    zcl_mail_cfg-zclinsprog = sy-repid.
    zcl_mail_cfg-zclupdname = sy-uname.
    zcl_mail_cfg-zclupddate = sy-datum.
    zcl_mail_cfg-zclupdtime = sy-uzeit.
    zcl_mail_cfg-zclupdprog = sy-repid.
  ELSE.
    zcl_mail_cfg-zclupdname = sy-uname.
    zcl_mail_cfg-zclupddate = sy-datum.
    zcl_mail_cfg-zclupdtime = sy-uzeit.
    zcl_mail_cfg-zclupdprog = sy-repid.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM set_info_werte_comp_tiff                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_info_werte_comp_tiff.
ENDFORM.
