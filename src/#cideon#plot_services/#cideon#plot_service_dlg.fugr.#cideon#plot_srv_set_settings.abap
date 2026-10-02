FUNCTION /cideon/plot_srv_set_settings.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IB_EXPAND_ALL) TYPE  ABAP_BOOL
*"     REFERENCE(IT_OBJ_SETTINGS) TYPE  /CIDEON/PLSRVSET_T
*"----------------------------------------------------------------------
*& Beschreibung: <Zweck/Funktionsbeschreibung>
*&
*& Autor:        HAENSEL
*& Angelegt am:  07.09.2006 07:13:08
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*
*
* 30.11.2008 - CKR
*              Lesen der Nutzerparameter, um bei dem BAPI_USER_CHANGE
*              nicht unbetroffene Parameter zu löschen
*              -> Kunde Rofin (A. Schaller)
*&----------------------------------------------------------------------
  DATA: lt_ins_objtypes TYPE /cideon/plsrvset_t,
        lt_upd_objtypes TYPE /cideon/plsrvset_t,
        lt_del_objtypes TYPE /cideon/plsrvset_t,
        lt_usr05 TYPE TABLE OF usr05,
        lt_user_params TYPE TABLE OF bapiparam,
        lt_gs_comm_return TYPE TABLE OF bapiret2.

  DATA: ls_user_params_temp TYPE bapiparam,
        ls_usr05 TYPE usr05,
        ls_user_paramsx TYPE bapiparamx.

  FIELD-SYMBOLS <ls_objtype_setting> TYPE /cideon/plsrvset.
  FIELD-SYMBOLS <fs_lt_user_params> TYPE bapiparam.


*  Änderung Rosinski 10.09.2007
*  SET PARAMETER ID '/CIDEON/PLOTDLG_EXPA' FIELD ib_expand_all.

  REFRESH lt_user_params.
  "CKR 2008/11/30
  SELECT * FROM usr05 INTO CORRESPONDING FIELDS OF
    TABLE lt_user_params
    WHERE bname = sy-uname
    .

  REFRESH lt_usr05.
  SELECT * FROM usr05 INTO TABLE lt_usr05
          WHERE bname = sy-uname AND parid = '/CIDEON/PLOTDLG_EXPA'.


*       Struktur für Parameteränderung füllen
  ls_user_paramsx-parid = 'X'.
  ls_user_paramsx-parva = 'X'.
  ls_user_paramsx-partxt = 'X'.

  IF sy-subrc EQ 4.
    ls_usr05-mandt = sy-mandt.
    ls_usr05-bname = sy-uname.
    ls_usr05-parid = '/CIDEON/PLOTDLG_EXPA'.
    ls_usr05-parva = ''.
    INSERT INTO usr05 VALUES ls_usr05.
    COMMIT WORK AND WAIT.
    ls_user_params_temp-parid = '/CIDEON/PLOTDLG_EXPA'.
    ls_user_params_temp-parva = ''.
    ls_user_params_temp-partxt = ''.

    APPEND ls_user_params_temp TO lt_user_params.
  ENDIF.

  LOOP AT lt_user_params ASSIGNING <fs_lt_user_params>.
    CASE <fs_lt_user_params>-parid.
      WHEN '/CIDEON/PLOTDLG_EXPA'.
        <fs_lt_user_params>-parva = ib_expand_all.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'BAPI_USER_CHANGE'
    EXPORTING
      username   = sy-uname
      parameterx = ls_user_paramsx
    TABLES
      parameter  = lt_user_params
      return     = lt_gs_comm_return.


  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.









* Benutzer und Mandant fest eintragen
  LOOP AT gt_objtype_settings ASSIGNING <ls_objtype_setting>.
    <ls_objtype_setting>-mandt = sy-mandt.
    <ls_objtype_setting>-uname = sy-uname.
  ENDLOOP.

* INSERTs, UPDATEs und DELETEs ermitteln
  PERFORM getchanges
    CHANGING
        gt_objtype_sett_buf
        gt_objtype_settings
        lt_ins_objtypes
        lt_upd_objtypes
        lt_del_objtypes.

* Speichern der Daten
  IF NOT lt_del_objtypes IS INITIAL.
    DELETE /cideon/plsrvset FROM TABLE lt_del_objtypes.
  ENDIF.
  IF NOT lt_upd_objtypes IS INITIAL.
    UPDATE /cideon/plsrvset FROM TABLE lt_upd_objtypes.
  ENDIF.
  IF NOT lt_ins_objtypes IS INITIAL.
    INSERT /cideon/plsrvset FROM TABLE lt_ins_objtypes.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  getchanges
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_REF_TABLE  text
*      -->IT_MOD_TABLE  text
*----------------------------------------------------------------------*
FORM getchanges CHANGING
      it_ref_table TYPE /cideon/plsrvset_t
      it_mod_table TYPE /cideon/plsrvset_t
      et_inserts   TYPE /cideon/plsrvset_t
      et_updates   TYPE /cideon/plsrvset_t
      et_deletes   TYPE /cideon/plsrvset_t.

  DATA: li_mod_counter TYPE i VALUE 1,         " Zähler
        li_ref_counter TYPE i VALUE 1,
        lb_eot     TYPE abap_bool.  " End Of Tables

  FIELD-SYMBOLS: <ls_mod_line> TYPE /cideon/plsrvset,
                 <ls_ref_line> TYPE /cideon/plsrvset.

* Beide Tabellen sortieren
  SORT it_mod_table BY bo_type dlt.
  SORT it_ref_table BY bo_type dlt.

  WHILE lb_eot = abap_false.
    UNASSIGN <ls_mod_line>.
    UNASSIGN <ls_ref_line>.

    " Zeile aus der geänderten Tabelle lesen
    READ TABLE it_mod_table ASSIGNING <ls_mod_line>
      INDEX li_mod_counter.
    " Zeile aus der Referenztabelle lesen
    READ TABLE it_ref_table ASSIGNING <ls_ref_line>
      INDEX li_ref_counter.
    IF sy-subrc = 4.
*     Keine Zeile mehr gefunden -- Eintrag in modifizierter Tabelle
*     ist ein neuer.
      IF <ls_mod_line> IS ASSIGNED.
        APPEND <ls_mod_line> TO et_inserts.
        li_mod_counter = li_mod_counter + 1.
      ELSE.
*       Wenn es da auch keinen Eintrag mehr gibt, dann Ende des
*       Abgleichs erreicht.
        lb_eot = abap_true.
      ENDIF.
    ELSE.
      " Zeile in der Referenztabelle vorhanden.
      " --> Prüfem, ob überhaupt eine Zeile in der geänderten Tabelle
      "     Prüfen, ob der Schlüssel der gleiche ist wie in der mod.
      "     Tabelle. Wenn JA und ein Wertattribut geändert, dann UPDATE
      "     Sonst ist es ein DELETE
      IF <ls_mod_line> IS ASSIGNED.
        IF <ls_mod_line>-bo_type = <ls_ref_line>-bo_type AND
           <ls_mod_line>-dlt = <ls_ref_line>-dlt.
          " Gleicher Schlüssel
          " --> Nichtschlüsselfelder auf Änderung prüfen.
          IF NOT <ls_mod_line>-value = <ls_ref_line>-value.
            " UPDATE, da Wert geändert.
            APPEND <ls_mod_line> TO et_updates.
          ENDIF.
          li_mod_counter = li_mod_counter + 1.
          li_ref_counter = li_ref_counter + 1.
        ELSEIF <ls_mod_line>-bo_type LT <ls_ref_line>-bo_type OR
               <ls_mod_line>-dlt LT <ls_ref_line>-dlt.
          " Modifizierter Schlüssel ist kleiner
          " --> Neuer Datensatz eingefügt
          APPEND <ls_mod_line> TO et_inserts.
          li_mod_counter = li_mod_counter + 1.
        ELSE.
          " Modifizierter Schlüssel ist größer
          " --> Eintrag wurde gelöscht
          APPEND <ls_ref_line> TO et_deletes.
          li_ref_counter = li_ref_counter + 1.
        ENDIF.
      ELSE.
        " <ls_mod_line> nicht ASSIGNED
        " --> Zeile wurde gelöscht.
        APPEND <ls_ref_line> TO et_deletes.
        li_ref_counter = li_ref_counter + 1.
      ENDIF.
    ENDIF.
  ENDWHILE.
ENDFORM.                    "getchanges
