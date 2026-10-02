FUNCTION /cideon/select_user_data2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2
*"     VALUE(BOM_USR) TYPE  /CIDEON/BOM_USR
*"----------------------------------------------------------------------

  DATA  ls_bom_user TYPE /cideon/bom_usr.
  DATA: lt_parameter TYPE TABLE OF bapiparam,
        ls_parameter TYPE bapiparam.
  DATA: lt_return TYPE TABLE OF bapiret2,
        actvt(2)   TYPE c VALUE '03'.


  CALL FUNCTION '/CIDEON/BOM_USER_READ2'
       EXPORTING
            uname    = sy-uname  " default = 'DEFAULT'
       IMPORTING
            bom_usr  = ls_bom_user
       EXCEPTIONS
            no_entry = 1
            OTHERS   = 2.
  IF sy-subrc <> 0 OR ls_bom_user-capid IS INITIAL
    OR ls_bom_user-bomtype IS INITIAL.

    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
         EXPORTING
              username  = sy-uname
         TABLES
              parameter = lt_parameter
              return    = lt_return.

    CLEAR ls_parameter.
    LOOP AT lt_parameter INTO ls_parameter
      WHERE parid = '/CIDEON/CAPID'.
      ls_bom_user-capid = ls_parameter-parva.
    ENDLOOP.
    IF sy-subrc <> 0  OR ls_bom_user-capid IS INITIAL.
      ls_bom_user-capid = 'PP01'.
    ENDIF.
    CLEAR ls_parameter.
    LOOP AT lt_parameter INTO ls_parameter
      WHERE parid = '/CIDEON/BOMTYPE'.
      ls_bom_user-bomtype = ls_parameter-parva.
    ENDLOOP.
    IF sy-subrc <> 0 OR ls_bom_user-bomtype IS INITIAL.
      ls_bom_user-bomtype = 'CS03'.
      ls_bom_user-bomausp = 'A'.
    ENDIF.
    CLEAR ls_parameter.
    LOOP AT lt_parameter INTO ls_parameter
      WHERE parid = '/CIDEON/BOMAUSP'.
      ls_bom_user-bomausp = ls_parameter-parva.
    ENDLOOP.
    IF sy-subrc <> 0  OR ls_bom_user-bomausp IS INITIAL.
      ls_bom_user-bomausp = 'A'.
    ENDIF.
    IF ls_bom_user-stlan IS INITIAL.
      ls_bom_user-stlan = '1'.
    ENDIF.
    IF ls_bom_user-explv IS INITIAL.
      ls_bom_user-explv = 1.
    ENDIF.
  ENDIF.

  IF NOT ls_bom_user-werks IS INITIAL.
    AUTHORITY-CHECK OBJECT 'C_STUE_WRK'
    ID 'ACTVT' FIELD actvt
    ID 'CSWRK' FIELD ls_bom_user-werks.
    IF sy-subrc <> 0.
      return-type = 'E'.
      MESSAGE e111(/cideon/caddesktop).
      EXIT.
    ENDIF.
  ENDIF.
  IF ls_bom_user-explv IS INITIAL.
    ls_bom_user-explv = '1'.
  ENDIF.
  MOVE ls_bom_user TO bom_usr.

ENDFUNCTION.
