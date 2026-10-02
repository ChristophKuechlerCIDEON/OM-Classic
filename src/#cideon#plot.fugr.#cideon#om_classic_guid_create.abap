FUNCTION /cideon/om_classic_guid_create.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(EV_GUID_16) TYPE  GUID_16
*"     VALUE(EV_GUID_22) TYPE  GUID_22
*"     VALUE(EV_GUID_32) TYPE  GUID_32
*"----------------------------------------------------------------------
* CIDEON Software GmbH
* Chris Küchler
* christoph.kuechler@cideon.com
* Erstellung 2014/10/02
* Anpassung 2014/11/25
* auch die 16 und 22 GUIDs werden jetzt unterstützt
*

**********************************************************************

**** siehe SAP Hinweis: http://service.sap.com/sap/support/notes/1721670
  DATA: lo_class        TYPE REF TO object,
        lo_error        TYPE REF TO cx_root,
        lc_fmname       TYPE rs38l_fnam,
        ls_methode32    TYPE tmdir,
        ls_methode22    TYPE tmdir,
        ls_methode16    TYPE tmdir,
*        lv_sysuuid(32) TYPE c,
        lv_sysuuid32    TYPE sysuuid_c,
        lv_sysuuid22    TYPE sysuuid_22,
        lv_sysuuid16    TYPE sysuuid_x,
        ls_parameter    TYPE abap_parmbind,
        ls_fm_para      TYPE abap_func_parmbind,
        lt_parameters32 TYPE abap_parmbind_tab,
        lt_parameters22 TYPE abap_parmbind_tab,
        lt_parameters16 TYPE abap_parmbind_tab,
        lt_fm_para      TYPE abap_func_parmbind_tab,
        lt_exceptions   TYPE abap_excpbind_tab .

  FIELD-SYMBOLS:  <fs_val>  TYPE ANY.

  ls_parameter-name = 'UUID'.
  ls_parameter-kind = cl_abap_objectdescr=>receiving.

  ls_fm_para-kind = abap_func_importing.

  IF ev_guid_32 IS SUPPLIED.
    ls_fm_para-name   = 'EV_GUID_32'.
    GET REFERENCE OF lv_sysuuid32 INTO ls_fm_para-value.
    INSERT ls_fm_para INTO TABLE lt_fm_para.

    GET REFERENCE OF lv_sysuuid32 INTO ls_parameter-value.
    INSERT ls_parameter INTO TABLE lt_parameters32.
  ENDIF.

  IF ev_guid_22 IS SUPPLIED.
    ls_fm_para-name   = 'EV_GUID_22'.
    GET REFERENCE OF lv_sysuuid22 INTO ls_fm_para-value.
    INSERT ls_fm_para INTO TABLE lt_fm_para.

    GET REFERENCE OF lv_sysuuid22 INTO ls_parameter-value.
    INSERT ls_parameter INTO TABLE lt_parameters22.
  ENDIF.

  IF ev_guid_16 IS SUPPLIED.
    ls_fm_para-name   = 'EV_GUID_16'.
    GET REFERENCE OF lv_sysuuid16 INTO ls_fm_para-value.
    INSERT ls_fm_para INTO TABLE lt_fm_para.

    GET REFERENCE OF lv_sysuuid16 INTO ls_parameter-value.
    INSERT ls_parameter INTO TABLE lt_parameters16.
  ENDIF.

  ls_methode32-classname  = 'CL_SYSTEM_UUID'.
  ls_methode22-classname  = 'CL_SYSTEM_UUID'.
  ls_methode16-classname  = 'CL_SYSTEM_UUID'.

  ls_methode32-methodname = 'IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32'.
  ls_methode22-methodname = 'IF_SYSTEM_UUID_STATIC~CREATE_UUID_C22'.
  ls_methode16-methodname = 'IF_SYSTEM_UUID_STATIC~CREATE_UUID_X16'.

  lc_fmname               = 'GUID_CREATE'.

  TRY.
      IF ev_guid_32 IS SUPPLIED.
        CALL METHOD (ls_methode32-classname)=>(ls_methode32-methodname)
          PARAMETER-TABLE
            lt_parameters32
          EXCEPTION-TABLE
            lt_exceptions.
      ENDIF.

      IF ev_guid_22 IS SUPPLIED.
        CALL METHOD (ls_methode22-classname)=>(ls_methode22-methodname)
          PARAMETER-TABLE
            lt_parameters22
          EXCEPTION-TABLE
            lt_exceptions.
      ENDIF.

      IF ev_guid_16 IS SUPPLIED.
        CALL METHOD (ls_methode16-classname)=>(ls_methode16-methodname)
          PARAMETER-TABLE
            lt_parameters16
          EXCEPTION-TABLE
            lt_exceptions.
      ENDIF.

    CATCH cx_sy_dyn_call_error INTO lo_error.

      CALL FUNCTION lc_fmname
        PARAMETER-TABLE
          lt_fm_para.

      LOOP AT lt_fm_para INTO ls_fm_para.
        CASE ls_fm_para-name.
          WHEN 'EV_GUID_32'.
            ASSIGN ls_fm_para-value->* TO <fs_val>.
            IF <fs_val> IS ASSIGNED.
              ev_guid_32 = <fs_val>.
            ENDIF.
          WHEN 'EV_GUID_22'.
            ASSIGN ls_fm_para-value->* TO <fs_val>.
            IF <fs_val> IS ASSIGNED.
              ev_guid_22 = <fs_val>.
            ENDIF.
          WHEN 'EV_GUID_16'.
            ASSIGN ls_fm_para-value->* TO <fs_val>.
            IF <fs_val> IS ASSIGNED.
              ev_guid_16 = <fs_val>.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
*      ec_message = lo_error->if_message~get_text( ).
      EXIT.
  ENDTRY.

  LOOP AT lt_parameters32 INTO ls_parameter.
    CASE ls_parameter-name.
      WHEN 'UUID'.
        ASSIGN ls_parameter-value->* TO <fs_val>.
        IF <fs_val> IS ASSIGNED.
          ev_guid_32 = <fs_val>.
          EXIT.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
  LOOP AT lt_parameters22 INTO ls_parameter.
    CASE ls_parameter-name.
      WHEN 'UUID'.
        ASSIGN ls_parameter-value->* TO <fs_val>.
        IF <fs_val> IS ASSIGNED.
          ev_guid_22 = <fs_val>.
          EXIT.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
  LOOP AT lt_parameters16 INTO ls_parameter.
    CASE ls_parameter-name.
      WHEN 'UUID'.
        ASSIGN ls_parameter-value->* TO <fs_val>.
        IF <fs_val> IS ASSIGNED.
          ev_guid_16 = <fs_val>.
          EXIT.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFUNCTION.
