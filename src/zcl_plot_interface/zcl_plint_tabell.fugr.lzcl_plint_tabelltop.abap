*---------------------------------------------------------------------*
*    generated viewmaintenance function pool top
*   generation date: 09.07.2002 at 08:41:05 by user KUECHLER
*---------------------------------------------------------------------*
FUNCTION-POOL zcl_plint_tabell           MESSAGE-ID sv.

INCLUDE lsvimdat                                . "general data decl.
INCLUDE lzcl_plint_tabellt00                    . "view rel. data dcl.


INCLUDE zcl_plint_routines.
INCLUDE zcl_plint_routines_pai.
*&---------------------------------------------------------------------*
*&      Module  ZCL_PLINT_ROUTINES_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
DATA table_name(40).

*---------------------------------------------------------------------*
*       MODULE ZCL_PLINT_ROUTINES_PAI INPUT                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_plint_routines_pai INPUT.
  IF ok_code = 'SAVE'.
    IF table_name = 'ZCL_PLINT_CONFIG'.
      PERFORM set_info_werte.
    ENDIF.
    IF table_name = 'ZPLINT_USR_TDWP'.
      PERFORM set_info_werte_usr_tdwp.
    ENDIF.
    IF table_name = 'ZCL_PLINT_USR_VW'.
      PERFORM set_info_werte_usr_vw.
    ENDIF.
    IF table_name = 'ZCL_PLINT_CFG_00'.
      PERFORM set_info_werte_cfg_00.
    ENDIF.
    IF table_name = 'ZCL_USR_GRP_TAB'.
      PERFORM set_info_werte_usr_grp.
    ENDIF.
    IF table_name = 'ZCL_MAIL_CFG'.
      PERFORM set_info_werte_mail_cfg.
    ENDIF.
    IF table_name = 'ZCL_COMP_TIFF'.
      PERFORM set_info_werte_comp_tiff.
    ENDIF.
  ENDIF.
ENDMODULE.                 " ZCL_PLINT_ROUTINES_PAI  INPUT

*---------------------------------------------------------------------*
*       MODULE ZCL_PLINT_CONFIG INPUT                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_plint_config INPUT.
  table_name = 'ZCL_PLINT_CONFIG'.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE ZCL_PLINT_USR_TDWP INPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_plint_usr_tdwp INPUT.
  table_name = 'ZPLINT_USR_TDWP'.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE ZCL_PLINT_USR_VW INPUT                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_plint_usr_vw INPUT.
  table_name = 'ZCL_PLINT_USR_VW'.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE ZCL_PLINT_CFG_00 INPUT                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_plint_cfg_00 INPUT.
  table_name = 'ZCL_PLINT_CFG_00'.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE ZCL_PLINT_USR_GRP_TAB INPUT                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_plint_usr_grp_tab INPUT.
  table_name = 'ZCL_USR_GRP_TAB'.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE ZCL_PLINT_MAIL_CFG INPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_plint_mail_cfg INPUT.
  table_name = 'ZCL_MAIL_CFG'.
ENDMODULE.



*---------------------------------------------------------------------*
*       MODULE ZCL_COMP_TIFF INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE zcl_comp_tiff INPUT.
  table_name = 'ZCL_COMP_TIFF'.
ENDMODULE.
