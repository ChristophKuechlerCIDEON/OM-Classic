*"* components of interface /CIDEON/IF_PLOT_DLT
interface /CIDEON/IF_PLOT_DLT
  public .


  data DESCRIPTION type STRING read-only .
  data COLUMN type ref to /CIDEON/CL_UI_TABLE_COLUMN read-only .

  methods ACQUIRE_DOCUMENTS
    returning
      value(DOCUMENTS) type /CIDEON/T_PDM_OBJECTS .
endinterface.
