*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 17.12.2003 at 08:22:57 by user KUECHLER
*---------------------------------------------------------------------*
*...processing: ZCL_BEDINGUNG...................................*
DATA:  BEGIN OF STATUS_ZCL_BEDINGUNG                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_BEDINGUNG                 .
CONTROLS: TCTRL_ZCL_BEDINGUNG
            TYPE TABLEVIEW USING SCREEN '0025'.
*...processing: ZCL_BEDING_SET..................................*
DATA:  BEGIN OF STATUS_ZCL_BEDING_SET                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_BEDING_SET                .
CONTROLS: TCTRL_ZCL_BEDING_SET
            TYPE TABLEVIEW USING SCREEN '0027'.
*...processing: ZCL_MAIL_CFG....................................*
DATA:  BEGIN OF STATUS_ZCL_MAIL_CFG                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_MAIL_CFG                  .
CONTROLS: TCTRL_ZCL_MAIL_CFG
            TYPE TABLEVIEW USING SCREEN '0015'.
*...processing: ZCL_PLINT_INI_CF................................*
DATA:  BEGIN OF STATUS_ZCL_PLINT_INI_CF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_PLINT_INI_CF              .
CONTROLS: TCTRL_ZCL_PLINT_INI_CF
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZCL_SCHLUESSEL..................................*
DATA:  BEGIN OF STATUS_ZCL_SCHLUESSEL                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_SCHLUESSEL                .
CONTROLS: TCTRL_ZCL_SCHLUESSEL
            TYPE TABLEVIEW USING SCREEN '0023'.
*...processing: ZCL_USR_GRP_TAB.................................*
DATA:  BEGIN OF STATUS_ZCL_USR_GRP_TAB               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_USR_GRP_TAB               .
CONTROLS: TCTRL_ZCL_USR_GRP_TAB
            TYPE TABLEVIEW USING SCREEN '0017'.
*...processing: ZCL_USR_HOST_CFG................................*
DATA:  BEGIN OF STATUS_ZCL_USR_HOST_CFG              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_USR_HOST_CFG              .
CONTROLS: TCTRL_ZCL_USR_HOST_CFG
            TYPE TABLEVIEW USING SCREEN '0031'.
*...processing: ZCL_VERTEILER...................................*
DATA:  BEGIN OF STATUS_ZCL_VERTEILER                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCL_VERTEILER                 .
CONTROLS: TCTRL_ZCL_VERTEILER
            TYPE TABLEVIEW USING SCREEN '0021'.
*...processing: ZPLINT_USR_TDWP.................................*
DATA:  BEGIN OF STATUS_ZPLINT_USR_TDWP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPLINT_USR_TDWP               .
CONTROLS: TCTRL_ZPLINT_USR_TDWP
            TYPE TABLEVIEW USING SCREEN '0005'.
*.........table declarations:.................................*
TABLES: *ZCL_BEDINGUNG                 .
TABLES: *ZCL_BEDING_SET                .
TABLES: *ZCL_MAIL_CFG                  .
TABLES: *ZCL_PLINT_INI_CF              .
TABLES: *ZCL_SCHLUESSEL                .
TABLES: *ZCL_USR_GRP_TAB               .
TABLES: *ZCL_USR_HOST_CFG              .
TABLES: *ZCL_VERTEILER                 .
TABLES: *ZPLINT_USR_TDWP               .
TABLES: ZCL_BEDINGUNG                  .
TABLES: ZCL_BEDING_SET                 .
TABLES: ZCL_MAIL_CFG                   .
TABLES: ZCL_PLINT_INI_CF               .
TABLES: ZCL_SCHLUESSEL                 .
TABLES: ZCL_USR_GRP_TAB                .
TABLES: ZCL_USR_HOST_CFG               .
TABLES: ZCL_VERTEILER                  .
TABLES: ZPLINT_USR_TDWP                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
