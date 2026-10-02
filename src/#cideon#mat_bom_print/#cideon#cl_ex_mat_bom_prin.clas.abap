class /CIDEON/CL_EX_MAT_BOM_PRIN definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_EX_MAT_BOM_PRIN
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_EX_MAT_BOM_PRIN .
  type-pools SEEX .
*"* protected components of class /CIDEON/CL_EX_MAT_BOM_PRIN
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_EX_MAT_BOM_PRIN
*"* do not include other source files here!!!
private section.

  type-pools SEEX .
  data INSTANCE_BADI_TABLE type SEEX_EXIT_TAB .
ENDCLASS.



CLASS /CIDEON/CL_EX_MAT_BOM_PRIN IMPLEMENTATION.


method /CIDEON/IF_EX_MAT_BOM_PRIN~CHANGE_TABLE.
CLASS CL_EXIT_MASTER DEFINITION LOAD.
DATA: EXIT_OBJ_TAB TYPE SEEX_EXIT_TAB,
      EXIT_OBJ TYPE SEEX_EXIT_TAB_STRUCT.

DATA: EXITINTF TYPE REF TO /CIDEON/IF_EX_MAT_BOM_PRIN.


  LOOP AT INSTANCE_BADI_TABLE INTO EXIT_OBJ WHERE
       INTER_NAME = '/CIDEON/IF_EX_MAT_BOM_PRIN' AND
       FLT_VAL    = SPACE.
    APPEND EXIT_OBJ TO EXIT_OBJ_TAB.
  ENDLOOP.

  IF SY-SUBRC = 4.
    CALL METHOD CL_EXIT_MASTER=>CREATE_OBJ_BY_INTERFACE_FILTER
       EXPORTING
          INTER_NAME   = '/CIDEON/IF_EX_MAT_BOM_PRIN'
          FLT_VAL      = SPACE
       IMPORTING
          EXIT_OBJ_TAB = EXIT_OBJ_TAB.

    APPEND LINES OF EXIT_OBJ_TAB TO INSTANCE_BADI_TABLE.
  ENDIF.

  LOOP AT EXIT_OBJ_TAB INTO EXIT_OBJ.

    CHECK NOT EXIT_OBJ-OBJ IS INITIAL.
    CHECK EXIT_OBJ-ACTIVE = SEEX_TRUE.


    EXITINTF ?= EXIT_OBJ-OBJ.

    CALL FUNCTION 'PF_ASTAT_OPEN'
       EXPORTING
           OPENKEY = 'sLDXyNhiq4opCenEHpsy00'
           TYP     = 'UE'.

    CALL METHOD EXITINTF->CHANGE_TABLE
       EXPORTING
         BOM_PRINT = BOM_PRINT
       CHANGING
         MAT_BOM_TAB = MAT_BOM_TAB
         HEAD_MAT_STRUC = HEAD_MAT_STRUC
       EXCEPTIONS
         ERROR =  1.
    case sy-subrc.
      when  1.
        raise ERROR.
    endcase.

    CALL FUNCTION 'PF_ASTAT_CLOSE'
       EXPORTING
           OPENKEY = 'sLDXyNhiq4opCenEHpsy00'
           TYP     = 'UE'.

  ENDLOOP.


ENDMETHOD.
ENDCLASS.
