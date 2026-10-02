*"* components of interface /CIDEON/IF_EX_OM_PS_01
interface /CIDEON/IF_EX_OM_PS_01
  public .


  methods CHG_TR_CLASSDATA
    changing
      !IT_DRAW_ITEM_TR type /CIDEON/T_DRAW_ITEM_TR .
  methods CHG_WA_MDR_TR_DATA_INIT
    changing
      !WA_MDR_TR type /CIDEON/S_MDR_TR .
  methods CHG_TR_DIS_DATA_BEFORE_CREATE
    changing
      !DOCUMENTDATA type BAPI_DOC_DRAW2
      !IT_DOC_FILES type T_BAPI_DOC_FILES2
      !IT_CHAR_VAL type TB_BAPI_CHARACTERISTIC_VALUES
      !IT_CLASS_ALLOC type TB_BAPI_CLASS_ALLOCATION
      !IT_DOC_DESC type TB_BAPI_DOC_DRAT .
  methods CHG_MDR_IT_OBJECTS
    changing
      !IT_OBJECTS type /CIDEON/TTYPE_S_SELOBJECTS
      !WA_MDR_TR type /CIDEON/S_MDR_TR .
  methods CHG_MDR_DIS_DATA_BEFORE_CREATE
    changing
      !DOCUMENTDATA type BAPI_DOC_DRAW2
      !IT_DOC_FILES type T_BAPI_DOC_FILES2
      !IT_CHAR_VAL type TB_BAPI_CHARACTERISTIC_VALUES
      !IT_CLASS_ALLOC type TB_BAPI_CLASS_ALLOCATION
      !IT_DOC_DESC type TB_BAPI_DOC_DRAT .
  methods CHG_INSERT_DIS_TR
    changing
      !WA_MDR_TR type /CIDEON/S_MDR_TR
      !INSERT_DIS type DRAW .
  type-pools SOI .
  methods CHG_MDF_DATA
    changing
      !SHEET type ref to I_OI_SPREADSHEET
      !DOCUMENT type ref to I_OI_DOCUMENT_PROXY
      !LT_RANGE_DEF type SOI_DIMENSION_TABLE
      !LT_CONTENTS type SOI_GENERIC_TABLE
      !WA_MDR_TR type /CIDEON/S_MDR_TR
      !IT_DOC type /CIDEON/TTYPE_S_STPOX .
endinterface.
