class /CIDEON/CL_EX_PLS_MAIN01 definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_EX_PLS_MAIN01
*"* do not include other source files here!!!
public section.

  interfaces /CIDEON/IF_EX_PLS_MAIN01 .

  constants VERSION type VERSION value 000001. "#EC NOTEXT
  type-pools SXRT .
*"* protected components of class /CIDEON/CL_EX_PLS_MAIN01
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_EX_PLS_MAIN01
*"* do not include other source files here!!!
private section.

  type-pools SXRT .
  data INSTANCE_BADI_TABLE type SXRT_EXIT_TAB .
  data INSTANCE_FLT_CACHE type SXRT_FLT_CACHE_TAB .
ENDCLASS.



CLASS /CIDEON/CL_EX_PLS_MAIN01 IMPLEMENTATION.


method /CIDEON/IF_EX_PLS_MAIN01~AFTER_BOM_AQQUIRED.
  CLASS CL_EXIT_MASTER DEFINITION LOAD.
  DATA: EXIT_OBJ_TAB TYPE SXRT_EXIT_TAB.

  DATA: exitintf TYPE REF TO /CIDEON/IF_EX_PLS_MAIN01,
        wa_flt_cache_line TYPE REF TO sxrt_flt_cache_struct,
        flt_name TYPE FILTNAME.


  FIELD-SYMBOLS:
    <exit_obj>       TYPE SXRT_EXIT_TAB_STRUCT,
    <flt_cache_line> TYPE sxrt_flt_cache_struct.

  READ TABLE INSTANCE_FLT_CACHE
         WITH KEY flt_name    = flt_name
                  method_name = 'AFTER_BOM_AQQUIRED'
         TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.

    CREATE DATA wa_flt_cache_line TYPE sxrt_flt_cache_struct.
    ASSIGN wa_flt_cache_line->* TO <flt_cache_line>.
    <flt_cache_line>-flt_name    = flt_name.
    <flt_cache_line>-method_name = 'AFTER_BOM_AQQUIRED'.


      LOOP AT INSTANCE_BADI_TABLE ASSIGNING <exit_obj>
           WHERE METHOD_NAME  = 'AFTER_BOM_AQQUIRED'.
        APPEND <exit_obj> TO EXIT_OBJ_TAB.
      ENDLOOP.
      IF sy-subrc ne 0.
        CALL METHOD CL_EXIT_MASTER=>CREATE_OBJ_BY_INTERFACE_FILTER
           EXPORTING
              CALLER       = me
              INTER_NAME   = '/CIDEON/IF_EX_PLS_MAIN01'
              METHOD_NAME  = 'AFTER_BOM_AQQUIRED'

              delayed_instance_creation    = sxrt_true
           IMPORTING
               exit_obj_tab = exit_obj_tab.

        APPEND LINES OF exit_obj_tab TO INSTANCE_BADI_TABLE.
      ENDIF.

      <flt_cache_line>-valid = sxrt_false.

      LOOP at exit_obj_tab ASSIGNING <exit_obj>
          WHERE ACTIVE   = SXRT_TRUE.

        <flt_cache_line>-valid = sxrt_true.



          <flt_cache_line>-obj =
               CL_EXIT_MASTER=>instantiate_imp_class(
                        CALLER       = me
                        imp_name  = <exit_obj>-imp_name
                        imp_class = <exit_obj>-imp_class ).
          MOVE <exit_obj>-imp_class to <flt_cache_line>-imp_class.
          MOVE <exit_obj>-imp_switch to <flt_cache_line>-imp_switch.
          MOVE <exit_obj>-order_num to <flt_cache_line>-order_num.
          INSERT <flt_cache_line> INTO TABLE INSTANCE_FLT_CACHE.


      ENDLOOP.
      IF <flt_cache_line>-valid = sxrt_false.
        INSERT <flt_cache_line> INTO TABLE INSTANCE_FLT_CACHE.
      ENDIF.
  ENDIF.

  LOOP AT INSTANCE_FLT_CACHE ASSIGNING <flt_cache_line>
       WHERE flt_name    = flt_name
         AND valid       = sxrt_true
         AND method_name = 'AFTER_BOM_AQQUIRED'.


    CALL FUNCTION 'PF_ASTAT_OPEN'
       EXPORTING
           OPENKEY = 'uV16oOevv}68H00CAJYZX0'
           TYP     = 'UE'.

    CASE <flt_cache_line>-imp_switch.
      WHEN 'VSR'.
        DATA: exc        TYPE sfbm_xcptn,                  "#EC NEEDED
              data_ref   TYPE REF TO DATA.

        IF <flt_cache_line>-eo_object is initial.
          CALL METHOD ('CL_FOBU_METHOD_EVALUATION')=>load
               EXPORTING
                  im_class_name     = <flt_cache_line>-imp_class
                  im_interface_name = '/CIDEON/IF_EX_PLS_MAIN01'
                  im_method_name    = 'AFTER_BOM_AQQUIRED'
               RECEIVING
                  re_fobu_method    = <flt_cache_line>-eo_object
               EXCEPTIONS
                  not_found         = 1
                  OTHERS            = 2.
          IF sy-subrc = 2.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          CHECK sy-subrc = 0.
        ENDIF.


        CLEAR data_ref.
        GET REFERENCE OF LO_PLOT_BO INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'LO_PLOT_BO'
            im_value    = data_ref ).

        CLEAR data_ref.
        GET REFERENCE OF LT_BOM INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'LT_BOM'
            im_value    = data_ref ).

        CALL METHOD <flt_cache_line>-eo_object->evaluate
             IMPORTING
                ex_exception    = exc
             EXCEPTIONS
                raise_exception = 1
                OTHERS          = 2.
        IF sy-subrc = 2.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.
      WHEN OTHERS.
        EXITINTF ?= <flt_cache_line>-OBJ.
        CALL METHOD EXITINTF->AFTER_BOM_AQQUIRED
           EXPORTING
             LO_PLOT_BO = LO_PLOT_BO
           CHANGING
             LT_BOM = LT_BOM.


    ENDCASE.

    CALL FUNCTION 'PF_ASTAT_CLOSE'
       EXPORTING
           OPENKEY = 'uV16oOevv}68H00CAJYZX0'
           TYP     = 'UE'.
  ENDLOOP.


endmethod.


method /CIDEON/IF_EX_PLS_MAIN01~AFTER_BO_AQQURIRED.
  CLASS CL_EXIT_MASTER DEFINITION LOAD.
  DATA: EXIT_OBJ_TAB TYPE SXRT_EXIT_TAB.

  DATA: exitintf TYPE REF TO /CIDEON/IF_EX_PLS_MAIN01,
        wa_flt_cache_line TYPE REF TO sxrt_flt_cache_struct,
        flt_name TYPE FILTNAME.


  FIELD-SYMBOLS:
    <exit_obj>       TYPE SXRT_EXIT_TAB_STRUCT,
    <flt_cache_line> TYPE sxrt_flt_cache_struct.

  READ TABLE INSTANCE_FLT_CACHE
         WITH KEY flt_name    = flt_name
                  method_name = 'AFTER_BO_AQQURIRED'
         TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.

    CREATE DATA wa_flt_cache_line TYPE sxrt_flt_cache_struct.
    ASSIGN wa_flt_cache_line->* TO <flt_cache_line>.
    <flt_cache_line>-flt_name    = flt_name.
    <flt_cache_line>-method_name = 'AFTER_BO_AQQURIRED'.


      LOOP AT INSTANCE_BADI_TABLE ASSIGNING <exit_obj>
           WHERE METHOD_NAME  = 'AFTER_BO_AQQURIRED'.
        APPEND <exit_obj> TO EXIT_OBJ_TAB.
      ENDLOOP.
      IF sy-subrc ne 0.
        CALL METHOD CL_EXIT_MASTER=>CREATE_OBJ_BY_INTERFACE_FILTER
           EXPORTING
              CALLER       = me
              INTER_NAME   = '/CIDEON/IF_EX_PLS_MAIN01'
              METHOD_NAME  = 'AFTER_BO_AQQURIRED'

              delayed_instance_creation    = sxrt_true
           IMPORTING
               exit_obj_tab = exit_obj_tab.

        APPEND LINES OF exit_obj_tab TO INSTANCE_BADI_TABLE.
      ENDIF.

      <flt_cache_line>-valid = sxrt_false.

      LOOP at exit_obj_tab ASSIGNING <exit_obj>
          WHERE ACTIVE   = SXRT_TRUE.

        <flt_cache_line>-valid = sxrt_true.



          <flt_cache_line>-obj =
               CL_EXIT_MASTER=>instantiate_imp_class(
                        CALLER       = me
                        imp_name  = <exit_obj>-imp_name
                        imp_class = <exit_obj>-imp_class ).
          MOVE <exit_obj>-imp_class to <flt_cache_line>-imp_class.
          MOVE <exit_obj>-imp_switch to <flt_cache_line>-imp_switch.
          MOVE <exit_obj>-order_num to <flt_cache_line>-order_num.
          INSERT <flt_cache_line> INTO TABLE INSTANCE_FLT_CACHE.


      ENDLOOP.
      IF <flt_cache_line>-valid = sxrt_false.
        INSERT <flt_cache_line> INTO TABLE INSTANCE_FLT_CACHE.
      ENDIF.
  ENDIF.

  LOOP AT INSTANCE_FLT_CACHE ASSIGNING <flt_cache_line>
       WHERE flt_name    = flt_name
         AND valid       = sxrt_true
         AND method_name = 'AFTER_BO_AQQURIRED'.


    CALL FUNCTION 'PF_ASTAT_OPEN'
       EXPORTING
           OPENKEY = 'uV16oOevs}68H00CAJYZX0'
           TYP     = 'UE'.

    CASE <flt_cache_line>-imp_switch.
      WHEN 'VSR'.
        DATA: exc        TYPE sfbm_xcptn,                  "#EC NEEDED
              data_ref   TYPE REF TO DATA.

        IF <flt_cache_line>-eo_object is initial.
          CALL METHOD ('CL_FOBU_METHOD_EVALUATION')=>load
               EXPORTING
                  im_class_name     = <flt_cache_line>-imp_class
                  im_interface_name = '/CIDEON/IF_EX_PLS_MAIN01'
                  im_method_name    = 'AFTER_BO_AQQURIRED'
               RECEIVING
                  re_fobu_method    = <flt_cache_line>-eo_object
               EXCEPTIONS
                  not_found         = 1
                  OTHERS            = 2.
          IF sy-subrc = 2.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          CHECK sy-subrc = 0.
        ENDIF.


        CLEAR data_ref.
        GET REFERENCE OF LO_PLOT_BO INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'LO_PLOT_BO'
            im_value    = data_ref ).

        CLEAR data_ref.
        GET REFERENCE OF DOCUMENTS INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'DOCUMENTS'
            im_value    = data_ref ).

        CALL METHOD <flt_cache_line>-eo_object->evaluate
             IMPORTING
                ex_exception    = exc
             EXCEPTIONS
                raise_exception = 1
                OTHERS          = 2.
        IF sy-subrc = 2.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.
      WHEN OTHERS.
        EXITINTF ?= <flt_cache_line>-OBJ.
        CALL METHOD EXITINTF->AFTER_BO_AQQURIRED

           CHANGING
             LO_PLOT_BO = LO_PLOT_BO
             DOCUMENTS = DOCUMENTS.


    ENDCASE.

    CALL FUNCTION 'PF_ASTAT_CLOSE'
       EXPORTING
           OPENKEY = 'uV16oOevs}68H00CAJYZX0'
           TYP     = 'UE'.
  ENDLOOP.


endmethod.


method /CIDEON/IF_EX_PLS_MAIN01~AFTER_DOC_AQQUIRED.
  CLASS CL_EXIT_MASTER DEFINITION LOAD.
  DATA: EXIT_OBJ_TAB TYPE SXRT_EXIT_TAB.

  DATA: exitintf TYPE REF TO /CIDEON/IF_EX_PLS_MAIN01,
        wa_flt_cache_line TYPE REF TO sxrt_flt_cache_struct,
        flt_name TYPE FILTNAME.


  FIELD-SYMBOLS:
    <exit_obj>       TYPE SXRT_EXIT_TAB_STRUCT,
    <flt_cache_line> TYPE sxrt_flt_cache_struct.

  READ TABLE INSTANCE_FLT_CACHE
         WITH KEY flt_name    = flt_name
                  method_name = 'AFTER_DOC_AQQUIRED'
         TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.

    CREATE DATA wa_flt_cache_line TYPE sxrt_flt_cache_struct.
    ASSIGN wa_flt_cache_line->* TO <flt_cache_line>.
    <flt_cache_line>-flt_name    = flt_name.
    <flt_cache_line>-method_name = 'AFTER_DOC_AQQUIRED'.


      LOOP AT INSTANCE_BADI_TABLE ASSIGNING <exit_obj>
           WHERE METHOD_NAME  = 'AFTER_DOC_AQQUIRED'.
        APPEND <exit_obj> TO EXIT_OBJ_TAB.
      ENDLOOP.
      IF sy-subrc ne 0.
        CALL METHOD CL_EXIT_MASTER=>CREATE_OBJ_BY_INTERFACE_FILTER
           EXPORTING
              CALLER       = me
              INTER_NAME   = '/CIDEON/IF_EX_PLS_MAIN01'
              METHOD_NAME  = 'AFTER_DOC_AQQUIRED'

              delayed_instance_creation    = sxrt_true
           IMPORTING
               exit_obj_tab = exit_obj_tab.

        APPEND LINES OF exit_obj_tab TO INSTANCE_BADI_TABLE.
      ENDIF.

      <flt_cache_line>-valid = sxrt_false.

      LOOP at exit_obj_tab ASSIGNING <exit_obj>
          WHERE ACTIVE   = SXRT_TRUE.

        <flt_cache_line>-valid = sxrt_true.



          <flt_cache_line>-obj =
               CL_EXIT_MASTER=>instantiate_imp_class(
                        CALLER       = me
                        imp_name  = <exit_obj>-imp_name
                        imp_class = <exit_obj>-imp_class ).
          MOVE <exit_obj>-imp_class to <flt_cache_line>-imp_class.
          MOVE <exit_obj>-imp_switch to <flt_cache_line>-imp_switch.
          MOVE <exit_obj>-order_num to <flt_cache_line>-order_num.
          INSERT <flt_cache_line> INTO TABLE INSTANCE_FLT_CACHE.


      ENDLOOP.
      IF <flt_cache_line>-valid = sxrt_false.
        INSERT <flt_cache_line> INTO TABLE INSTANCE_FLT_CACHE.
      ENDIF.
  ENDIF.

  LOOP AT INSTANCE_FLT_CACHE ASSIGNING <flt_cache_line>
       WHERE flt_name    = flt_name
         AND valid       = sxrt_true
         AND method_name = 'AFTER_DOC_AQQUIRED'.


    CALL FUNCTION 'PF_ASTAT_OPEN'
       EXPORTING
           OPENKEY = 'uV16oOevuV68H00CAJYZX0'
           TYP     = 'UE'.

    CASE <flt_cache_line>-imp_switch.
      WHEN 'VSR'.
        DATA: exc        TYPE sfbm_xcptn,                  "#EC NEEDED
              data_ref   TYPE REF TO DATA.

        IF <flt_cache_line>-eo_object is initial.
          CALL METHOD ('CL_FOBU_METHOD_EVALUATION')=>load
               EXPORTING
                  im_class_name     = <flt_cache_line>-imp_class
                  im_interface_name = '/CIDEON/IF_EX_PLS_MAIN01'
                  im_method_name    = 'AFTER_DOC_AQQUIRED'
               RECEIVING
                  re_fobu_method    = <flt_cache_line>-eo_object
               EXCEPTIONS
                  not_found         = 1
                  OTHERS            = 2.
          IF sy-subrc = 2.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          CHECK sy-subrc = 0.
        ENDIF.


        CLEAR data_ref.
        GET REFERENCE OF LO_PLOT_BO INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'LO_PLOT_BO'
            im_value    = data_ref ).

        CLEAR data_ref.
        GET REFERENCE OF LO_DLT INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'LO_DLT'
            im_value    = data_ref ).

        CLEAR data_ref.
        GET REFERENCE OF LT_TMP_DOCDATA INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'LT_TMP_DOCDATA'
            im_value    = data_ref ).

        CALL METHOD <flt_cache_line>-eo_object->evaluate
             IMPORTING
                ex_exception    = exc
             EXCEPTIONS
                raise_exception = 1
                OTHERS          = 2.
        IF sy-subrc = 2.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.
      WHEN OTHERS.
        EXITINTF ?= <flt_cache_line>-OBJ.
        CALL METHOD EXITINTF->AFTER_DOC_AQQUIRED

           CHANGING
             LO_PLOT_BO = LO_PLOT_BO
             LO_DLT = LO_DLT
             LT_TMP_DOCDATA = LT_TMP_DOCDATA.


    ENDCASE.

    CALL FUNCTION 'PF_ASTAT_CLOSE'
       EXPORTING
           OPENKEY = 'uV16oOevuV68H00CAJYZX0'
           TYP     = 'UE'.
  ENDLOOP.


endmethod.
ENDCLASS.
