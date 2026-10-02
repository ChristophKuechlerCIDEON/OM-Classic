*"* components of interface /CIDEON/IF_EX_MAT_BOM_PRIN
interface /CIDEON/IF_EX_MAT_BOM_PRIN
  public .


  methods CHANGE_TABLE
    importing
      !BOM_PRINT type ANY optional
    changing
      !MAT_BOM_TAB type ANY optional
      !HEAD_MAT_STRUC type ANY optional
    exceptions
      ERROR .
endinterface.
