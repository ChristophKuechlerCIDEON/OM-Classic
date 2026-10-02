FUNCTION z_cl_psbrw_mat_dok_prio_check.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_MAT_DOKAR_PRIO_LIST) TYPE  CHAR50
*"  TABLES
*"      I_SELECTED_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"      O_SELECTED_OBJECTS STRUCTURE  ZCL_PDM_EXP_OBJECTS
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_mat_dokar_prio_list TYPE TABLE OF dokar.
  DATA: itab_objects TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: itab_objects_rest TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: itab_objects_verarb TYPE TABLE OF zcl_pdm_exp_objects.
  DATA: itab_objects_result TYPE TABLE OF zcl_pdm_exp_objects.
*WA
  DATA: wa_objects TYPE zcl_pdm_exp_objects.
  DATA: wa_objects_first TYPE zcl_pdm_exp_objects.
  DATA: wa_dokar TYPE dokar.
  DATA: f_dokar.
  DATA: index TYPE i.
  DATA: f_rest.

* Tabelle erstellen
  CLEAR itab_mat_dokar_prio_list.
  SPLIT i_mat_dokar_prio_list
    AT '/'
    INTO TABLE itab_mat_dokar_prio_list.

* erste zusammenhängende Gruppe ermitteln
  CLEAR itab_objects.
  itab_objects[] = i_selected_objects[].

  CLEAR itab_objects_rest.
  CLEAR itab_objects_verarb.

* Rücksprung
  IF itab_objects[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR wa_objects_first.
  READ TABLE itab_objects INTO wa_objects_first INDEX 1.

  CLEAR wa_objects.
  CLEAR f_rest.
  LOOP AT itab_objects INTO wa_objects.
    index = sy-tabix.
    IF f_rest = 'X'.
*     Verarbeiten des Rests nach einem Wechsel
      APPEND wa_objects TO itab_objects_rest.
      CONTINUE.
    ELSE.
    ENDIF.

    IF wa_objects-object_type_original =
        wa_objects_first-object_type_original
      AND wa_objects-object_key_original =
        wa_objects_first-object_key_original.
*     zur Tabelle hinzufügen
      APPEND wa_objects TO itab_objects_verarb.
    ELSE.
*     geändert
      APPEND wa_objects TO itab_objects_rest.
      f_rest = 'X'.
    ENDIF.
  ENDLOOP.

* zur Bearbeitung übergeben
  CLEAR itab_objects.
  CLEAR itab_objects_result.
*  itab_objects[] = itab_objects_verarb[].

  CLEAR f_dokar.
  LOOP AT itab_mat_dokar_prio_list INTO wa_dokar.
*   Dokumentart enthalten ?
    LOOP AT itab_objects_verarb INTO wa_objects
      WHERE dokar = wa_dokar.
      f_dokar = 'X'.
      EXIT.
    ENDLOOP.
    IF f_dokar = 'X'.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.

  CLEAR itab_objects.
  IF f_dokar = 'X'.
*   MARA testen, andere übernehmen
    LOOP AT itab_objects_verarb INTO wa_objects.
      IF wa_objects-object_type_original = 'MARA'.
        IF wa_objects-dokar = wa_dokar.
*         Übernehmen
          APPEND wa_objects TO itab_objects.
        ELSE.
*         Vergessen
        ENDIF.
      ELSE.
        APPEND wa_objects TO itab_objects.
      ENDIF.
    ENDLOOP.
  ELSE.
*   kein Treffer
*   alles Löschen, was direkter Materiallink ist.
    LOOP AT itab_objects_verarb INTO wa_objects.
      index = sy-tabix.
      IF wa_objects-object_type_original = 'MARA'.
        DELETE itab_objects_verarb INDEX index.
      ELSE.
      ENDIF.
    ENDLOOP.
    itab_objects[] = itab_objects_verarb[].
  ENDIF.


  CLEAR itab_objects_verarb.
  itab_objects_verarb[] = itab_objects[].

* weitere Bearbeitung des Rests
  CALL FUNCTION 'Z_CL_PSBRW_MAT_DOK_PRIO_CHECK'
       EXPORTING
            i_mat_dokar_prio_list = i_mat_dokar_prio_list
       TABLES
            i_selected_objects    = itab_objects_rest
            o_selected_objects    = itab_objects_result
       EXCEPTIONS
            error                 = 1
            OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



* Gruppe zurückgeben
* Result
  LOOP AT itab_objects_result INTO wa_objects.
*    APPEND wa_objects TO o_selected_objects.
    INSERT wa_objects INTO o_selected_objects INDEX 1.
  ENDLOOP.

* Verarbeit
  LOOP AT itab_objects_verarb INTO wa_objects.
*    APPEND wa_objects TO o_selected_objects.
    INSERT wa_objects INTO o_selected_objects INDEX 1.
  ENDLOOP.



ENDFUNCTION.
