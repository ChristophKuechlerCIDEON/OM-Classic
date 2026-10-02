*"* components of interface /CIDEON/IF_EX_PRE_MAIN_001
interface /CIDEON/IF_EX_PRE_MAIN_001
  public .


  methods CHG_PL_EXCL_BT
    changing
      !IT_BT_EX type UI_FUNCTIONS optional .
  methods CHG_SL_EXCL_BT
    changing
      !IT_BT_EX type UI_FUNCTIONS optional .
  methods CHG_PLOTLIST_BEFORE_SEND
    changing
      value(ITAB_PLOTLIST) type /CIDEON/TTYPE_S_PLOTLIST
      value(RETURN) type BAPIRET2
      value(SHOW_MESSAGE) type CHAR1 optional .
  methods CHG_SEL_OBJ_BEFORE_PROC
    changing
      value(SELECTED_OBJECTS) type /CIDEON/TTYPE_S_SELOBJECTS
      value(RETURN) type BAPIRET2
    exceptions
      CANCEL .
  methods CHG_SEL_OBJ_INIT
    changing
      value(SELECTED_OBJECTS) type /CIDEON/TTYPE_S_SELOBJECTS
      value(RETURN) type BAPIRET2
    exceptions
      CANCEL .
  methods CHG_SEL_OBJ_BEFORE_PRIO
    changing
      value(SELECTED_OBJECTS) type /CIDEON/TTYPE_S_SELOBJECTS
      value(RETURN) type BAPIRET2 .
  methods CHG_DRAD_OBJ_BEFORE_PRIO
    changing
      value(DRAD_OBJECTS) type DMS_TBL_DRAD
      value(RETURN) type BAPIRET2 .
  methods CHG_STPOX_OBJ_BEFORE_PRIO
    changing
      value(STPOX_OBJECTS) type /CIDEON/TTYPE_S_STPOX
      value(RETURN) type BAPIRET2 .
  methods CHG_SEL_OBJ_BEFORE_WRITE
    changing
      value(SELECTED_OBJECTS) type /CIDEON/TTYPE_S_SELOBJECTS
      value(RETURN) type BAPIRET2 .
  methods CHG_OBJ_AFTER_READ_TMP
    changing
      value(SELECTED_OBJECTS) type /CIDEON/TTYPE_S_PSB_TMP
      value(RETURN) type BAPIRET2 .
  methods CHG_OBJ_AFTER_READ_TMP2
    changing
      value(SELECTED_OBJECTS) type /CIDEON/TTYPE_S_DOCSEARCH
      value(RETURN) type BAPIRET2 .
  methods CHG_AFTER_GET_STAMPS
    changing
      !ITAB_PLOTLIST type /CIDEON/TTYPE_S_PLOTLIST
      !RETURN type BAPIRET2
      !ITAB_STAMP_VALUES type /CIDEON/TTYPE_S_STEMPEL_VALUE .
  methods CHG_ME_DOC_EBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CHG_ME_DOC_MAT_EBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CHG_ME_DOC_MATPOS_EBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CHG_ME_DOC_DIALOG_EBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CHG_CLF_GHEAD
    importing
      value(I_PLOTJOB) type ZCL_S_PLOTLIST
    changing
      !IT_GHEAD type /CIDEON/TTYPE_S_LINE_256
      !IT_STAMPS type /CIDEON/TTYPE_S_STEMPEL_VALUE .
  methods CHG_LOG_AT_LOG
    changing
      !PLOT_ITEM type ZCL_S_PLOTLIST
      !LOG_ITEM type /CIDEON/PL_LOG
      !LOG_ITEM_2 type /CIDEON/PL_LOG2 .
  methods CHG_LOG_AT_SET_ID
    changing
      !PLOT_ITEM type ZCL_S_PLOTLIST
      !LOG_ITEM type /CIDEON/PL_LOG
      !LOG_ITEM_2 type /CIDEON/PL_LOG2 .
  methods CHG_SPOOL_DUNNING
    changing
      !LS_OUTPUT_OPTIONS type SSFCOMPOP
      !LS_CONTROL_PARAMETERS type SSFCTRLOP
      !FORMNAME type TDSFNAME .
  methods CHG_DIS_DATA_BEFORE_CREATE
    changing
      !DOCUMENTDATA type BAPI_DOC_DRAW2
      !IT_DOC_FILES type T_BAPI_DOC_FILES2
      !IT_CHAR_VAL type TB_BAPI_CHARACTERISTIC_VALUES
      !IT_CLASS_ALLOC type TB_BAPI_CLASS_ALLOCATION
      !IT_DOC_DESC type TB_BAPI_DOC_DRAT
      !IT_OBJECT_LINKS type T_BAPI_DOC_DRAD
      !ID_PLOTJOB_32 type /CIDEON/ID_PLOTJOB_GUID32 .
  methods CHG_M1_DATE
    changing
      !DATE type SY-DATUM .
  methods CHG_M2_DATE
    changing
      !DATE type SY-DATUM .
  methods STATUS_CHANGE
    importing
      value(STATUS) type STRING .
  methods CHG_SD_DOC_VBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CHG_SD_DOC_MAT_VBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CHG_SD_DOC_MATPOS_VBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CHG_SD_DOC_DIALOG_VBELNP
    changing
      !WA_ITEM type ZCL_PDM_OBJECTS_FA_INT .
  methods CFOLDERS_AUSGABE_01
    changing
      value(I_PLOTJOB) type /CIDEON/TTYPE_S_PLOTLIST
      value(RETURN) type BAPIRET2 .
  methods CHG_ME_START
    changing
      value(ENT_RETCO) type RETCO
      value(L_NAST) type NAST
      value(CANCEL) type CHAR1 .
  methods CHG_DIALOG_2D_SPECIAL
    importing
      value(I_USER_DATA) type /CIDEON/PLOT_USERDATA
    changing
      value(F_SKIP) type CHAR1
      value(LT_DRAW) type /CIDEON/TTYPE_S_DOCSEARCH .
  methods CHG_DIALOG_CV04N
    changing
      value(F_SKIP) type CHAR1
      value(LT_DRAW) type DMS_TBL_DRAW .
  methods CHG_PLOTLIST_BEFORE_SHOW
    changing
      value(ITAB_PLOTLIST) type /CIDEON/TTYPE_S_PLOTLIST
      value(RETURN) type BAPIRET2 .
  methods CHG_CONF_BEFORE_SEND
    changing
      !F_DYN_TOC type CHAR1 optional
      !F_DYN_COV type CHAR1 optional
      !LS_USER_DATA type /CIDEON/PLOT_USERDATA optional
      !LT_PLOTLIST type /CIDEON/TTYPE_S_PLOTLIST optional .
  methods CHG_CLF_GROUP
    changing
      !ITAB_GROUP_CLF10 type /CIDEON/TTYPE_S_LINE_256
      !ITAB_CLFLIST type /CIDEON/TTYPE_S_LINE_256
      !ITAB_PLOTLIST type /CIDEON/TTYPE_S_PLOTLIST .
  methods CHG_CLF_VF
    changing
      !ITAB_GROUP_CLF10 type /CIDEON/TTYPE_S_LINE_256
      !ITAB_CLFLIST type /CIDEON/TTYPE_S_LINE_256
      !ITAB_PLOTLIST type /CIDEON/TTYPE_S_PLOTLIST .
  methods ADD_CUSTOMER_FIELDS_SEARCHLIST
    changing
      !LT_SEARCHLIST type /CIDEON/TTYPE_S_DOCSEARCH optional .
  methods CHG_PLOTLIST_AFTER_SEND
    changing
      value(ITAB_PLOTLIST) type /CIDEON/TTYPE_S_PLOTLIST
      value(RETURN) type BAPIRET2 .
  methods CHG_FAUF_CHARGE
    importing
      !AUFNR type AUFNR optional
    changing
      !CHARG type CHARG_D .
  methods CHG_SPOOL_PROCESSING
    importing
      !I_PFAD type STRING optional
      !I_TDSPOOLID type RSPOID optional
      !I_TDOTFTYPE type TDOTFTYPE optional
    changing
      !O_FILEP type FILEP
      !F_PROCESSED type CHAR1
    exceptions
      ERROR
      NO_SPOOL .
  methods CHK_AUTH_C_DRAW_BGR
    changing
      value(F_USE_STANDARD) type CHAR1 default 'X'
      value(F_SUCCESS) type CHAR1 default ''
      !LS_DOCSEARCH type ZCL_S_DOCSEARCH .
  methods CHK_AUTH_SPECIAL
    changing
      value(F_SUCCESS) type CHAR1 default ''
      !LS_DOCSEARCH type ZCL_S_DOCSEARCH .
  methods CHG_PL_GLOBAL
    changing
      !LT_PL_GLOBAL type /CIDEON/TTYPE_PL_GBL .
  methods CHG_PLOTLIST_AFTER_SEND2
    changing
      !ITAB_PLOTLIST type /CIDEON/TTYPE_S_PLOTLIST
      !ITAB_SEARCHLIST type /CIDEON/TTYPE_S_DOCSEARCH
    exceptions
      CANCEL .
  methods SKIP_MESSAGE_AFTER_SEND
    changing
      !ITAB_PLOTLIST type /CIDEON/TTYPE_S_PLOTLIST
      !ITAB_SEARCHLIST type /CIDEON/TTYPE_S_DOCSEARCH
      !F_SKIP_MESSAGE type CHAR1
    exceptions
      CANCEL .
  methods CHG_STOR_SRC_ITEM
    changing
      !WA_STORED_SEARCH type ZCL_PSB_TMP
      !WA_SEARCH type ZCL_S_DOCSEARCH .
  methods CHG_CLF_DOWNLOAD_URL
    changing
      !LS_JOB type ZCL_S_PLOTLIST
      !LC_DOWN_PATH type STRING
      !LC_SKIP type CHAR1 default '' .
  methods CHG_AT_AUTH_CHECK
    changing
      !ITAB_SEARCH_TMP type /CIDEON/TTYPE_S_DOCSEARCH .
  methods SEND_TO_BADI
    changing
      !IS_USER_DATA type /CIDEON/PLOT_USERDATA
      !IS_DEFAULT_DATA type /CIDEON/PLOT_DEFAULTDATA
      !IC_PROGRAM type PROGRAMM
      !IC_ID_PLOTJOB type ZCL_S_PLOTLIST-ID_PLOTJOB
      !IC_STR_DOWN_PATH type STRING
      !IC_STR_PPL_DOWN_PATH type STRING
      !IT_PLOTJOBS type /CIDEON/TTYPE_S_PLOTLIST
      !IT_STEMPEL_WERT type /CIDEON/TTYPE_S_STEMPEL_VALUE
      !IT_NOTIZ type /CIDEON/TTYPE_S_STEMPEL_WERT
    exceptions
      ERROR .
endinterface.
