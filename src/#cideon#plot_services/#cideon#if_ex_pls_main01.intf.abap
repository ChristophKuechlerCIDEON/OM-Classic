*"* components of interface /CIDEON/IF_EX_PLS_MAIN01
interface /CIDEON/IF_EX_PLS_MAIN01
  public .


  methods AFTER_BO_AQQURIRED
    changing
      !LO_PLOT_BO type ref to /CIDEON/IF_PLOT_BO
      !DOCUMENTS type /CIDEON/T_PDM_OBJECTS .
  methods AFTER_DOC_AQQUIRED
    changing
      !LO_PLOT_BO type ref to /CIDEON/IF_PLOT_BO
      !LO_DLT type ref to /CIDEON/IF_PLOT_DLT
      !LT_TMP_DOCDATA type /CIDEON/T_PDM_OBJECTS .
  methods AFTER_BOM_AQQUIRED
    importing
      !LO_PLOT_BO type ref to /CIDEON/IF_PLOT_BO
    changing
      !LT_BOM type /CIDEON/TT_MAST_API02 .
endinterface.
