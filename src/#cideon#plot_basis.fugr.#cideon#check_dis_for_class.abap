FUNCTION /cideon/check_dis_for_class.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_DRAW) TYPE  DRAW
*"  TABLES
*"      I_ITAB_CLASS_DATA_NO_USE STRUCTURE  ZCL_V_UG_CL_N_U
*"  EXCEPTIONS
*"      ERROR
*"      DO_NOT_USE_DIS
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Hinweise:
*   -  überprüft DIS auf nicht zugelasssen Merkmalsdaten
*   -
*-----------------------------------------------------------------------
* Journal
* 30.10.2003  Erstellung
*-----------------------------------------------------------------------

*TYPES
*ITAB
  DATA: itab_characteristicvalues TYPE
    TABLE OF bapi_characteristic_values.
*WA
  DATA: wa_class_data_no_use TYPE zcl_v_ug_cl_n_u.
  DATA: return TYPE bapiret2.
  DATA: wa_characteristicvalues TYPE bapi_characteristic_values.
*NORMAL
  DATA: f_found(1).


  CLEAR wa_class_data_no_use.
  CLEAR itab_characteristicvalues.
  CLEAR wa_characteristicvalues.

* Merkmalsdaten für DIS holen

  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype               = i_wa_draw-dokar
      documentnumber             = i_wa_draw-doknr
      documentpart               = i_wa_draw-doktl
      documentversion            = i_wa_draw-dokvr
*     GETOBJECTLINKS             = ' '
*     GETCOMPONENTS              = ' '
*     GETSTATUSLOG               = ' '
*     GETLONGTEXTS               = ' '
      getactivefiles             = 'X'
      getclassification          = 'X'
*     GETSTRUCTURE               = ' '
*     GETWHEREUSED               = ' '
*     HOSTNAME                   = ' '
    IMPORTING
*     DOCUMENTDATA               =
      return                     = return
    TABLES
*     OBJECTLINKS                =
*     DOCUMENTDESCRIPTIONS       =
*     LONGTEXTS                  =
*     STATUSLOG                  =
*     DOCUMENTFILES              =
*     COMPONENTS                 =
      characteristicvalues       = itab_characteristicvalues
*     CLASSALLOCATIONS           =
*     DOCUMENTSTRUCTURE          =
*     WHEREUSEDLIST              =
            .

  IF return IS INITIAL.
  ELSE.
    RAISE error.
  ENDIF.

  CLEAR f_found.
  LOOP AT itab_characteristicvalues INTO wa_characteristicvalues.
    LOOP AT i_itab_class_data_no_use INTO wa_class_data_no_use.
      IF wa_characteristicvalues-charname = wa_class_data_no_use-atnam.
        IF wa_characteristicvalues-charvalue =
          wa_class_data_no_use-atwrt.
          f_found = 'X'.
          EXIT.
        ELSE.
        ENDIF.
      ELSE.
      ENDIF.
    ENDLOOP.

    IF f_found = 'X'.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.

  IF f_found = 'X'.
    RAISE do_not_use_dis.
  ELSE.
  ENDIF.

* Testen auf Prüfung, falls ein Test auf einen Leeren Merkmalswert
* erfolgen soll.
  LOOP AT i_itab_class_data_no_use INTO wa_class_data_no_use.
    IF wa_class_data_no_use-atwrt IS INITIAL.
*     testen, ob dafür ein Merkmal vorhanden
*     falls nicht, dann Exception
      CLEAR f_found.
      LOOP AT itab_characteristicvalues INTO wa_characteristicvalues.
        IF wa_characteristicvalues-charname =
          wa_class_data_no_use-atnam.
          f_found = 'X'.
          IF wa_characteristicvalues-charvalue IS INITIAL.
            RAISE do_not_use_dis.
          ELSE.
          ENDIF.
        ELSE.
        ENDIF.
      ENDLOOP.
      IF f_found IS INITIAL.
        RAISE do_not_use_dis.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
  ENDLOOP.







ENDFUNCTION.
