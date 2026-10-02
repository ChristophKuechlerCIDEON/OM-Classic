*"* components of interface /CIDEON/IF_PLOT_BO
interface /CIDEON/IF_PLOT_BO
  public .


  data SUPPORTED_DLTS type ref to /CIDEON/CL_OO_COLLECTION read-only .
  data RELATED_OBJECTS type ref to /CIDEON/CL_OO_COLLECTION read-only .
  data NAME type STRING read-only .

  type-pools SEOX .
  methods ACQUIRE_OBJECTS
    importing
      !CURRENT_LEVEL type I default 0
      !SELECTION_TREE type ref to /CIDEON/CL_UI_TREE_SELECTION
      !PARENT_ITEM type ref to /CIDEON/CL_UI_TREE_ITEM optional
      !DISPLAY type SEOX_BOOLEAN optional
    exceptions
      NOTHING_FOUND .
  methods REMOVE_ALL_OBJECTS .
  methods GET_KEY
    returning
      value(KEY) type STRING .
  methods SET_KEY
    importing
      !OBJKEY type SWO_TYPEID .
  methods GET_ADDITIONAL_DATA
    returning
      value(RO_ADDITIONAL_DATA) type ref to /CIDEON/CL_OO_COLLECTION .
  type-pools ABAP .
  methods DISPLAY
    returning
      value(RB_DISPLAY) type ABAP_BOOL .
  methods GET_TEXT
    returning
      value(RC_TEXT) type STRING .
  methods GET_ICON
    returning
      value(RC_ICON) type TV_IMAGE .
  methods HAS_RELATED_OBJECTS
    returning
      value(RB_HAS_RELATED_OBJECTS) type ABAP_BOOL .
  methods ACQUIRE_RELATED_OBJECTS .
  methods GET_SUPPORTED_DLTS
    returning
      value(RO_DLTS) type ref to /CIDEON/CL_OO_ARRAY .
endinterface.
