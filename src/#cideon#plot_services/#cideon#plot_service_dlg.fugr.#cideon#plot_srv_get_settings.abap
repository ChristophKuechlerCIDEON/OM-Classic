FUNCTION /cideon/plot_srv_get_settings.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(EB_EXPAND_ALL) TYPE  ABAP_BOOL
*"     REFERENCE(ET_OBJTYPE_SETTINGS) TYPE  /CIDEON/PLSRVSET_T
*"----------------------------------------------------------------------
*& Beschreibung: Liest die persänlichen Einstellung für den Plot Service
*&               Dialog.
*&
*& Autor:        HAENSEL
*& Angelegt am:  07.09.2006 07:05:30
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

DATA: lt_user_params TYPE TABLE OF bapiparam,
      lt_gs_comm_return TYPE TABLE OF bapiret2.


FIELD-SYMBOLS <fs_lt_user_params> TYPE bapiparam.

REFRESH lt_user_params.

*  Änderung 10.09.2007 Rosinski
*  GET PARAMETER ID '/CIDEON/PLOTDLG_EXPA' FIELD eb_expand_all.

CALL FUNCTION 'BAPI_USER_GET_DETAIL'
     EXPORTING
          username  = sy-uname
     TABLES
          parameter = lt_user_params
          return    = lt_gs_comm_return.

LOOP AT lt_user_params ASSIGNING <fs_lt_user_params>.
  CASE <fs_lt_user_params>-parid.
    WHEN '/CIDEON/PLOTDLG_EXPA'.
      eb_expand_all = <fs_lt_user_params>-parva.
    WHEN OTHERS.
  ENDCASE.
ENDLOOP.



* Alle Einstellungen zu den Objekttypen des Benutzers laden
  SELECT * FROM /cideon/plsrvset INTO TABLE gt_objtype_sett_buf
    WHERE uname = sy-uname.
  gt_objtype_settings[] = gt_objtype_sett_buf[].
  ET_OBJTYPE_SETTINGS[] = gt_objtype_sett_buf[].
ENDFUNCTION.
