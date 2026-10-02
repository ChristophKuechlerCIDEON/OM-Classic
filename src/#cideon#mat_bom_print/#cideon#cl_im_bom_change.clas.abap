class /CIDEON/CL_IM_BOM_CHANGE definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_IM_BOM_CHANGE
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_EX_MAT_BOM_PRIN .
*"* protected components of class /CIDEON/CL_IM_BOM_CHANGE
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_IM_BOM_CHANGE
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_IM_BOM_CHANGE IMPLEMENTATION.


method /CIDEON/IF_EX_MAT_BOM_PRIN~CHANGE_TABLE.

*  Schnittstelle:
*  CHANGING
*    mat_bom_tab type any abhängig von gewählter Ausprägung:
*       /cideon/stpos_cs03_a,
*       /cideon/stpos_cs03_d,
*       /cideon/stpos_cs03_m,
*       /cideon/stpos_cs11,
*       /cideon/stpos_cs12,
*       /cideon/stpos_cs13.
*    head_mat_struc type any (= rc29k)
*  EXCEPTION
*    error





endmethod.
ENDCLASS.
