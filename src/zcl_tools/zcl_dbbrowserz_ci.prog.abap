*----------------------------------------------------------------------*
*   INCLUDE ZCL_DBBROWSERZ_CI                                          *
*----------------------------------------------------------------------*
* Beschreibung: Klassenimplementierungen für lokale Klassen des
*               Programms.
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.11.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
TYPE-POOLS: icon.

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* LCL_EVENT_ALV_DDIC
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CLASS lcl_event_alv_ddic IMPLEMENTATION.

  METHOD handle_double_click.
    DATA ls_index_rows TYPE LINE OF lvc_t_row.
    DATA lt_index_rows TYPE lvc_t_row.
    DATA lv_indxdata  TYPE indx_srtfd.
* get selected row
    CALL METHOD go_alv_ddic->get_selected_rows
      IMPORTING
        et_index_rows = lt_index_rows.
    READ TABLE lt_index_rows INTO ls_index_rows INDEX 1.

    IF sy-subrc = 0.
* Start Dynamic Select
      READ TABLE gt_alv_ddic INTO gs_alv_ddic
        INDEX ls_index_rows-index.
      gf_table  = gs_alv_ddic-tabname.
      gf_ddtext = gs_alv_ddic-ddtext.
      PERFORM create_alv.
    ENDIF.
  ENDMETHOD.                    "handle_double_click

ENDCLASS.               "lcl_event_alv_ddic


* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* LCL_RESULT_EVENT_RECEIVER
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CLASS lcl_result_event_receiver IMPLEMENTATION.

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

    " Separator an den Standard Toolbar anhängen
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    " 'Ändern' Button hinzufügen
    CLEAR ls_toolbar.
    MOVE cc_fc_change_mode TO ls_toolbar-function.
    MOVE icon_change  TO ls_toolbar-icon.
    MOVE text-000   TO ls_toolbar-quickinfo.
    ls_toolbar-disabled = abap_false.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.

*   Funktionscode auslesen und entsprechende Aktion auslösen.
    CASE e_ucomm.
      WHEN cc_fc_change_mode.
        CALL METHOD switch_mode.
    ENDCASE.

  ENDMETHOD.

  METHOD handle_data_changed.

    mb_error_in_data = abap_false.

*   Im Einfügemodus prüfen, ob der Key vollständig ist und es keine
*   Duplikate gibt
*    IF NOT er_data_changed->mt_inserted_rows IS INITIAL.
*      CALL METHOD check_key
*        EXPORTING
*          io_data_changed = er_data_changed
*        EXCEPTIONS
*          missing_key   = 1
*          duplicate_key = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        EXIT.
*      ENDIF.
*    ENDIF.

*   Änderungen Einfügen, Ändern, Löschen merken
    CALL METHOD update_delta_tables(
      er_data_changed
    ).

*   Egal, ob gerade ein Datensatz eingefügt oder ein vorhandener ge-
*   ändert wurde, jetzt gehen wir in den Updatemodus, d.h. Schlüssel-
*   sind gesperrt.
    "mi_edit_mode = cc_edit_mode_update.

*   Die editierbaren Zellen, eingabebereit setzen
*    CALL METHOD go_alv_result->set_ready_for_input
*                       EXPORTING i_ready_for_input = 1.

*   ALV Grid aktualisieren
*    CALL METHOD go_alv_result->refresh_table_display.

    IF mb_error_in_data = abap_true.
      CALL METHOD er_data_changed->display_protocol.
    ENDIF.

  ENDMETHOD.

  METHOD update_delta_tables.

    DATA: lr_record           TYPE REF TO data,
          lb_new_record       TYPE abap_bool,
          lb_modified_record  TYPE abap_bool,
          lb_deleted_row      TYPE abap_bool,
          lr_insmod_record    TYPE REF TO data,
          lr_outtab_record    TYPE REF TO data,
*          lr_copy_target      type ref to data,
          lc_fieldname        TYPE lvc_fname,
          li_rowid            TYPE int4,
          li_table            TYPE i.    " Tabelle, in der der Datensatz
                                         " gefunden wurde.

    FIELD-SYMBOLS: <lt_modified_rows>  TYPE table,
                   <lt_inserted_rows>  TYPE table,
                   <lt_deleted_rows>   TYPE table,
                   <ls_row>            TYPE lvc_s_moce,
                   <ls_record>         TYPE ANY,
                   <ls_good_cell>      TYPE lvc_s_modi,
                   <ls_record_field>   TYPE ANY,
                   <ls_outtab_record>  TYPE ANY,
                   <ls_deleted_record> TYPE ANY,
                   <ls_modified_row>   TYPE ANY,
                   <lt_modified_tmp_rows> type table,
                   <lt_inserted_tmp_rows> type table.

*   Datenreferenzen der Änderungstabelle dereferenzieren
    ASSIGN me->mr_inserted_rows->* TO <lt_inserted_rows>.
    ASSIGN me->mr_modified_rows->* TO <lt_modified_rows>.
    ASSIGN me->mr_deleted_rows->* TO <lt_deleted_rows>.
    assign me->mr_inserted_tmp_rows->* to <lt_inserted_tmp_rows>.
    assign me->mr_modified_tmp_rows->* to <lt_modified_tmp_rows>.

    CREATE DATA lr_record LIKE LINE OF <lt_inserted_rows>.

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*   1. Verarbeitung der gelöschen Zeilen

    LOOP AT io_data_changed->mt_deleted_rows ASSIGNING <ls_row>.

*     Wenn die Zeile in INSERTED oder MODIFIED ROWS zu finden ist,
*     dann muss sie dort gelöscht werden.
      CALL METHOD find_insmod_record
        EXPORTING
          ii_row_id = <ls_row>-row_id
          ib_delete_row = abap_true
        CHANGING
          cr_record         = lr_record
          ci_table          = li_table.

*     Wurde der Datensatz in der INSERTED_ROWS Tabelle gefunden, muss
*     kein Eintrag in die Löschtabelle geschrieben werden, da auf der
*     Datenbank nichts zu löschen ist.
      IF NOT li_table = 1.
        ASSIGN lr_record->* TO <ls_deleted_record>.
        APPEND <ls_deleted_record> TO <lt_deleted_rows>.
      ENDIF.

    ENDLOOP.

*   Datensätze aus der Ausgabetabelle löschen (Geht nicht im vorherigen
*   LOOP, da in FIND_INSMOD_RECORD per Index auf ALV_RESULT zugegriffen
*   wird.
*    LOOP AT io_data_changed->mt_deleted_rows ASSIGNING <ls_row>.
*      DELETE <gt_alv_result> INDEX <ls_row>-row_id.
*    ENDLOOP.

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*   2. Vearbeitung der validierten Zeilen
    LOOP AT io_data_changed->mt_good_cells ASSIGNING <ls_good_cell>.

*     Vor der Verarbeitung der nächsten Zeile, die Zielstruktur
*     initialisieren
      AT NEW ('ROW_ID').

        ASSIGN lr_record->* TO <ls_record>.
        CLEAR <ls_record>.
        lb_new_record = abap_false.
        lb_modified_record = abap_false.

*       Sicherung der Änderungstabellen erzeugen
        <lt_inserted_tmp_rows>[] = <lt_inserted_rows>[].
        <lt_modified_tmp_rows>[] = <lt_modified_rows>[].

*       Wenn die Zeile, in der INSERTED_ROWS steht, dann müssen die
*       Felder Stück für Stück aus den GOOD_CELLS gelesen werden
*       (<ls_record> ist gültig), sonst kann die komplette Zeile aus der
*       <gt_alv_result> gelesen und die geänderten Felder aus den
*       GOOD_CELLS überschrieben werden.
        READ TABLE io_data_changed->mt_inserted_rows
          TRANSPORTING NO FIELDS
          WITH KEY row_id = <ls_good_cell>-row_id.
        IF sy-subrc = 0.
          lb_new_record = abap_true.
        ELSE.
          READ TABLE <gt_alv_result> ASSIGNING <ls_outtab_record>
                   INDEX <ls_good_cell>-row_id.
          CALL FUNCTION '/CIDEON/MOVE_CORRESPONDING'
               EXPORTING
                    is_source              = <ls_outtab_record>
               CHANGING
                    es_target              = <ls_record>
               EXCEPTIONS
                    no_runtime_information = 1
                    OTHERS                 = 2.

        ENDIF.
      ENDAT.

*     Die Feldinhalte werden erstmal in eine Struktur überführt
     ASSIGN COMPONENT <ls_good_cell>-fieldname OF STRUCTURE <ls_record>
                      TO <ls_record_field>.
      IF sy-subrc = 0.
        <ls_record_field> = <ls_good_cell>-value.
      ENDIF.

*     Bei Zeilenwechsel, Die Verarbeitung der Zeile durchführen
      AT END OF ('ROW_ID').

*       Datensatz aus MODIFIED_ROWS oder INSERTED_ROWS lesen
        CALL METHOD find_insmod_record
            EXPORTING
*             ii_row_id = <ls_good_cell>-row_id
              is_record         = <ls_record>
              ib_use_db = abap_true        " Suche auch in der DB
            CHANGING
              cb_record_created = lb_new_record
               cr_record         = lr_insmod_record.

*       Bei neuem Datensatz muss eine Schlüsselprüfung durchgeführt
*       werden
        IF lb_new_record = abap_true.

          CALL METHOD check_key
            EXPORTING
              is_record  = <ls_record>
            CHANGING
              cb_deleted_row = lb_deleted_row  " Zeile vorher gelöscht ?
            EXCEPTIONS
              duplicate_key = 1
              missing_key   = 2.
          IF sy-subrc > 0.
            lc_fieldname = <ls_good_cell>-fieldname.
            li_rowid     = <ls_good_cell>-row_id.
            CALL METHOD io_data_changed->add_protocol_entry
              EXPORTING
                i_msgid = sy-msgid
                i_msgno = sy-msgno
                i_msgty = sy-msgty
                i_msgv1 = sy-msgv1
                i_msgv2 = sy-msgv2
                i_msgv3 = sy-msgv3
                i_msgv4 = sy-msgv4
                i_fieldname = lc_fieldname
                i_row_id    = li_rowid.
            mb_error_in_data = abap_true.
          ENDIF.

        ELSE.
          DATA:           lb_hit            TYPE abap_bool,
                          lr_check_record   TYPE REF TO data,
                          li_index          TYPE i.
          FIELD-SYMBOLS:  <ls_check_record>  TYPE ANY.

*         Selbst wenn es sich nicht um einen neuen Datensatz handelt,
*         muss geprüft werden, ob es diesen Datensatz etwa doppelt in
*         der Ausgabetabelle gibt.
          CREATE DATA lr_check_record LIKE <ls_record>.
          ASSIGN lr_check_record->* TO <ls_check_record>.
          LOOP AT <gt_alv_result> ASSIGNING <ls_outtab_record>.
            li_index = sy-tabix.
            CALL FUNCTION '/CIDEON/MOVE_CORRESPONDING'
                 EXPORTING
                      is_source              = <ls_outtab_record>
                 CHANGING
                      es_target              = <ls_check_record>
                 EXCEPTIONS
                      no_runtime_information = 1
                      OTHERS                 = 2.
            IF <ls_check_record>(mi_keylen) = <ls_record>(mi_keylen).
              IF NOT <ls_good_cell>-row_id = li_index.
                li_rowid     = <ls_good_cell>-row_id.
                lc_fieldname = <ls_good_cell>-fieldname.
                CALL METHOD io_data_changed->add_protocol_entry
                  EXPORTING
                    i_msgid = 'ZCL_DB_BROWSER'
                    i_msgno = '001'
                    i_msgty = 'E'
                    i_fieldname = lc_fieldname
                    i_row_id    = li_rowid.
                mb_error_in_data = abap_true.
                EXIT.
              ENDIF.
              lb_hit = abap_true.
            ENDIF.
          ENDLOOP.

*         Wenn der Eintrag mit dem Schlüssel nicht in der Ausgabetabelle
*         gefunden wurde, dann ist es ein neuer Eintrag.
          IF lb_hit = abap_false.
            lb_new_record = abap_true.
          ENDIF.

        endif.

*       Wenn Prüfungen soweit OK, dann die Zeile in die entsprechende
*       Änderungstabelle übernehmen.
        if mb_error_in_data = abap_false.
*         (1) Neuen Datensatz in die INSERTED_ROWS anhängen (nur wenn
*             nicht er nicht zuvor in der DELETED_ROWS Tabelle stand
          IF lb_new_record = abap_true
          AND lb_deleted_row = abap_false.

*           INSUPD befüllen
            call method fill_insupd
              exporting
                ib_both = abap_true
              changing
                cs_record = <ls_record>.

            APPEND <ls_record> TO <lt_inserted_rows>.
            IF mi_insert_index = 0.
              mi_insert_index = sy-tabix.
            ENDIF.
          ELSEIF NOT lr_insmod_record IS INITIAL.
*         (3) Der Datensatz ist entweder in der INSERTED_ROWS oder in
*             der MODIFIED_ROWS Tabelle vorhanden. Der entsprechende
*             Datensatz wurde von FIND_INSMOD_RECORD als Referenz
*             zurück geliefert. Dieser wird nun überschrieben
            ASSIGN lr_insmod_record->* TO <ls_modified_row>.

*           INSUPD befüllen
            call method fill_insupd
              exporting
                ib_both = abap_false
              changing
                cs_record = <ls_record>.

            MOVE <ls_record> TO <ls_modified_row>.
          ELSEIF lb_deleted_row = abap_true.
*         (4) Ein Datensatz, der zuvor gelöscht wurde, aber mit
*             gleichem Schlüssel neu eingefügt wird. Dieser muss in
*             die MODIFIED_ROWS, sonst gibt es Duplikate inkl.
*             Kurzdump beim Speichern

*           INSUPD befüllen
            call method fill_insupd
              exporting
                ib_both = abap_false
              changing
                cs_record = <ls_record>.

            APPEND <ls_record> TO <lt_modified_rows>.
            IF mi_modify_index = 0.
              mi_modify_index = sy-tabix.
            ENDIF.
          ENDIF.
        else.
*     Bei Fehler werden die Daten nicht weiterverarbeitet, und die
*     Sicherungen der Änderungstabellen aktiviert.
          <lt_inserted_rows>[] = <lt_inserted_tmp_rows>[].
          <lt_modified_rows>[] = <lt_modified_tmp_rows>[].
        endif.
      ENDAT.
    ENDLOOP.

*   SAVE Button aktivieren, wenn alles OK war
    if mb_error_in_data = abap_false.
      PERFORM set_save_enabled USING abap_true.
    else.
*      mi_insert_index = 0.
*      mi_modify_index = 0.

      PERFORM set_save_enabled USING abap_false.
    endif.
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Die Datenprüfungen waren OK. Nun werden die Daten in die
* entsprechenden Änderungstabellen geschrieben

* (1) Löschvorgänge wurden vorher schon bearbeitet

* (2) Neuen Datensatz in die INSERTED_ROWS anhängen (nur wenn nicht er
*     nicht zuvor in der DELETED_ROWS Tabelle stand
*      IF lb_new_record = abap_true AND lb_deleted_row = abap_false.
*        APPEND <ls_record> TO <lt_inserted_rows>.
*        IF mi_insert_index = 0.
*          mi_insert_index = sy-tabix.
*        ENDIF.
*      ELSEIF NOT lr_insmod_record IS INITIAL.
* (3) Der Datensatz ist entweder in der INSERTED_ROWS oder in der
*     MODIFIED_ROWS Tabelle vorhanden. Der entsprechende Datensatz
*     wurde von FIND_INSMOD_RECORD als Referenz zurück geliefert.
*     Dieser wird nun überschrieben
*        ASSIGN lr_insmod_record->* TO <ls_modified_row>.
*        MOVE <ls_record> TO <ls_modified_row>.
*      ELSEIF lb_deleted_row = abap_true.
* (4) Ein Datensatz, der zuvor gelöscht wurde, aber mit gleichem
*     Schlüssel neu eingefügt wird. Dieser muss in die MODIFIED_ROWS,
*     sonst gibt es Duplikate inkl. Kurzdump beim Speichern
*        APPEND <ls_record> TO <lt_modified_rows>.
*        IF mi_modify_index = 0.
*          mi_modify_index = sy-tabix.
*        ENDIF.
*      ENDIF.



*       Ein neuer Datensatz ist es immer dann, wenn sich kein Schlüssel
*       Eintrag in INSERTED_ROWS und MODIFIED_ROWS finden lässt.

*       Hier muss dann auch nochmal bei neuen Datensätzen auf Duplikate
*       bei den Schlüsseln geprüft werden, denn Datzensätze die bei der
*       ersten Neueingabe an der Schlüsselprüfung scheitern schlagen
*       bei der zweiten Eingabe hier auf.

*       Wenn es sich um einen neuen Datensatz handelt, dann in der
*       DELETED_ROWS nachschauen und ggf. den Datensatz löschen.



*        ... Neuer Datensatz?
*        READ TABLE io_data_changed->mt_inserted_rows ASSIGNING <ls_row>
*          WITH KEY row_id = <ls_good_cell>-row_id.
*        IF sy-subrc = 0.
**         --> OK, es ist ein neuer Datensatz
*          lb_new_record = abap_true.
*          ASSIGN lr_record->* TO <ls_record>.
*          CLEAR <ls_record>.
*        ELSE.
**         --> NEIN, der Datensatz ist evtl. schon in LT_MODIFIED_ROWS
**             oder LT_INSERTED_ROWS vorhanden.
*          CALL METHOD find_insmod_record
*            EXPORTING
*              ii_row_id = <ls_good_cell>-row_id
*            CHANGING
*              cb_record_created = lb_modified_record
*              cr_record         = lr_insmod_record.
*
*          lb_new_record = abap_false.
*
*          ASSIGN lr_insmod_record->* TO <ls_record>.
*
*        ENDIF.
*      ENDAT.
*
*     ASSIGN COMPONENT <ls_good_cell>-fieldname OF STRUCTURE <ls_record>
*              TO <ls_record_field>.
*      IF sy-subrc = 0.
*        <ls_record_field> = <ls_good_cell>-value.
*      ENDIF.
*
**     Beim letzen Feld einer Zeile, Datensatz wegschreiben
*      AT END OF ('ROW_ID').
*
**       Neuen Datensatz wegschreiben
*        IF lb_new_record = abap_true.
*          APPEND <ls_record> TO <lt_inserted_rows>.
*          lb_new_record = abap_false.
*
**         Datensatz in die Ausgabetabelle übernehmen
*          CREATE DATA lr_outtab_record LIKE LINE OF <gt_alv_result>.
*          ASSIGN lr_outtab_record->* TO <ls_outtab_record>.
*          CALL FUNCTION '/CIDEON/MOVE_CORRESPONDING'
*               EXPORTING
*                    is_source              = <ls_record>
*               CHANGING
*                    es_target              = <ls_outtab_record>
*               EXCEPTIONS
*                    no_runtime_information = 1
*                    OTHERS                 = 2.
*          IF sy-subrc = 0.
*            PERFORM set_editable USING abap_true
*                                       abap_false
*                                 CHANGING <ls_outtab_record>.
*            APPEND <ls_outtab_record> TO <gt_alv_result>.
*          ENDIF.
*
*        ELSEIF lb_modified_record = abap_true.
**         Modifizierter Datensatz, der an die MODIFIED_ROWS angehangen
**         werden muss.
*          APPEND <ls_record> TO <lt_modified_rows>.
*          lb_modified_record = abap_false.
*        ELSE.
**         Modifizierter Datensatz, zu dem schon ein Datensatz in
**         INSERTED_ROWS oder MODIFIED_ROWS existiert.
**         KEINE AKTION NOTWENDIG!
*        ENDIF.
*      ENDAT.
*
*    ENDLOOP.

    ENDMETHOD.

    METHOD check_key.

      DATA: lc_long_char(1024) TYPE c,
            lt_where       TYPE zcl_db_where,
            lb_not_found   TYPE abap_bool,
            lr_record      TYPE REF TO data.

      FIELD-SYMBOLS: <ls_deleted_row>   TYPE ANY,
                     <lt_deleted_rows>  TYPE table.

*   Der Datensatz, darf nicht in MODIFIED_ROWS und INSERTED_ROWS
*   stehen
      CALL METHOD find_insmod_record
        EXPORTING
          is_record = is_record
        CHANGING
          cr_record         = lr_record
          cb_record_created = lb_not_found.
      IF lb_not_found = abap_false.
        MESSAGE e001(zcl_db_browser)
          RAISING duplicate_key.
      ENDIF.

*   WHERE Bedingung für Selektion dynamisch erzeugen lassen
      CALL METHOD compose_where_condition
        EXPORTING
          is_record = is_record
        RECEIVING
          rt_where  = lt_where
        EXCEPTIONS
          missing_key = 1.
      IF sy-subrc = 1.
        RAISE missing_key.
      ENDIF.

*   Prüfen, ob der eingefügte eintrag in der Tabelle
*   <lt_deleted_rows> steht, dann ist es ein Eintrag der in einem
*   Schritt gelöscht und mit gleichem Schlüssel eingefügt wurde.
      ASSIGN me->mr_deleted_rows->* TO <lt_deleted_rows>.
      LOOP AT <lt_deleted_rows> ASSIGNING <ls_deleted_row>.
        IF <ls_deleted_row>(mi_keylen) = is_record(mi_keylen).
          cb_deleted_row = abap_true.
          DELETE <lt_deleted_rows> INDEX sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.
      CHECK cb_deleted_row = abap_false.

*   Falls der Datensatz nicht in der Löschtabelle gefunden wurde, schaue
*   in der Datenbanktabelle nach
      SELECT SINGLE * INTO lc_long_char
        FROM (mc_table_name) WHERE (lt_where).
      IF sy-subrc = 0.
        " Es gibt schon einen Datensatz mit dem Schlüssel in der
        " Datenbank.
        MESSAGE e001(zcl_db_browser)
          RAISING duplicate_key.
      ENDIF.

    ENDMETHOD.

*&----------------------------------------------------------------------
*& Beschreibung: Baut anhand eines Datensatzes aus den Änderungstabellen
*&               eine WHERE Klausel für die Datenbankselektion zusammen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  04.01.2004
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  IS_RECORD  Datensatz aus den Änderungstabellen
*&  [OUT] RT_WHERE   Tabelle mit der WHERE Bedingung.
*&----------------------------------------------------------------------
    METHOD compose_where_condition.
    DATA: lb_first_loop  TYPE abap_bool,     " Erster Schleifendurchlauf
            lc_where_cond TYPE char80,
            lc_field_content TYPE string.

      FIELD-SYMBOLS: <ls_table_field>   TYPE dd03p,
                     <lc_field_content> TYPE ANY.

      lb_first_loop = abap_true.
      LOOP AT mt_table_structure ASSIGNING <ls_table_field>
          WHERE keyflag = abap_true.

     ASSIGN COMPONENT <ls_table_field>-fieldname OF STRUCTURE is_record
                  TO <lc_field_content>.
        lc_field_content = <lc_field_content>.

*     Bei Mandantenabh. Tabellen muss das Mandantenfeld gefüllt sein
        IF <ls_table_field>-datatype = 'CLNT' AND
           lc_field_content IS INITIAL.
          MESSAGE e000(zcl_db_browser) WITH
             <ls_table_field>-scrtext_m RAISING missing_key.
        ENDIF.

*     Falls Kleinbuchstaben nicht erlaubt, dann mache Großbuchstaben
*     daraus
        IF <ls_table_field>-lowercase = abap_false.
          TRANSLATE lc_field_content TO UPPER CASE.
        ENDIF.

*     Wert des Feldes an den Schlüsselstring anhängen
*      CONCATENATE lc_key_string lc_field_content
*        INTO lc_key_string.

*     Eintrag für die WHERE Tabelle erzeugen
        CLEAR lc_where_cond.
        CONCATENATE '''' lc_field_content '''' INTO lc_where_cond.
        CONCATENATE <ls_table_field>-fieldname '=' lc_where_cond
          INTO lc_where_cond SEPARATED BY space.

        " 'AND' in die WHERE Klausel aufnehmen, für alle ausser der
        " ersten WHERE Bedingung
        IF lb_first_loop = abap_true.
          lb_first_loop = abap_false.
        ELSE.
          CONCATENATE 'AND' lc_where_cond INTO lc_where_cond SEPARATED
            BY space.
        ENDIF.

        APPEND lc_where_cond TO rt_where.
      ENDLOOP.

    ENDMETHOD.

    METHOD initialize.
      DATA: lr_table TYPE REF TO data.

      FIELD-SYMBOLS: <ls_tabstruct> TYPE dd03p.

*   Klassenattribute speichern
      mt_table_structure = it_table_structure.
      mt_fcat            = it_field_catalog.

*   Klassenattribute initialieren
      CLEAR mr_inserted_rows.
      CLEAR mr_modified_rows.
      CLEAR mr_deleted_rows.
      clear mr_inserted_tmp_rows.
      clear mr_modified_tmp_rows.
      CLEAR mr_table_content.
      CLEAR mi_keylen.

      mc_table_name = ic_table_name.

*   Tabellen für Änderungsprotokollierung dynamisch erzeugen
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog = mt_fcat
          i_style_table   = abap_false
        IMPORTING
          ep_table = mr_inserted_rows.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog = mt_fcat
          i_style_table   = abap_false
        IMPORTING
          ep_table = mr_modified_rows.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog = mt_fcat
          i_style_table   = abap_false
        IMPORTING
          ep_table = mr_deleted_rows.

*   Die temporären Tabellen erzeugen
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog = mt_fcat
          i_style_table   = abap_false
        IMPORTING
          ep_table = mr_inserted_tmp_rows.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog = mt_fcat
          i_style_table   = abap_false
        IMPORTING
          ep_table = mr_modified_tmp_rows.

*   Schlüssellänge der Tabelle ermitteln und prüfen, ob in der Tabelle
*   die Struktur /CIDEON/INSUPD inkludiert wird.
      LOOP AT it_table_structure ASSIGNING <ls_tabstruct>.
        if <ls_tabstruct>-keyflag = abap_true.
          mi_keylen = mi_keylen + <ls_tabstruct>-intlen.
        endif.
        if <ls_tabstruct>-fieldname = '.INCLUDE'
            AND <ls_tabstruct>-precfield = '/CIDEON/INSUPD'.
          mb_insupd = abap_true.
        endif.
      ENDLOOP.

    ENDMETHOD.

*  METHOD check_key.
*    DATA:  li_row        TYPE sy-tabix,
*           lb_duplicate  TYPE abap_bool,
*           lt_where_cond TYPE TABLE OF char80,
*           lc_where_cond TYPE char80,
*           lb_first_loop TYPE abap_bool,
*           lc_long_char(1024) TYPE c,
*           lc_key_string  TYPE string,
*           lb_deleted_row TYPE abap_bool.
*
*    FIELD-SYMBOLS: <ls_row>           TYPE lvc_s_moce,
*                   <lt_modified_rows> TYPE table,
*                   <ls_table_field>   TYPE dd03p,
*                   <lc_field_content> TYPE ANY,
*                   <lt_inserted_rows> TYPE table,
*                   <ls_inserted_row>  TYPE ANY,
*                   <ls_deleted_row>   TYPE ANY,
*                   <ls_del_row>       TYPE lvc_s_moce,
*                   <ls_mod_cell>      TYPE lvc_s_modi.
*
*    ASSIGN io_data_changed->mp_mod_rows->* TO <lt_modified_rows>.
*
**   Alle eingefügten Zeilen prüfen
*    LOOP AT io_data_changed->mt_inserted_rows ASSIGNING <ls_row>.
*      CLEAR lc_key_string.
*
*      REFRESH lt_where_cond.
*      lb_first_loop = abap_true.
*
*      " Über alle Schlüsselfelder der Struktur laufen
*      LOOP AT mt_table_structure ASSIGNING <ls_table_field>
*        WHERE keyflag = abap_true.
*
*       READ TABLE io_data_changed->mt_mod_cells ASSIGNING <ls_mod_cell>
*                  WITH KEY row_id = <ls_row>-row_id
*                           fieldname = <ls_table_field>-fieldname.
*
*       "        ASSIGN COMPONENT <ls_table_field>-fieldname OF
*STRUCTURE
*        "          <ls_modified_row> TO <lc_field_content>.
*        IF <ls_table_field>-datatype = 'CLNT' AND
*           <ls_mod_cell>-value IS INITIAL.
*          MESSAGE s000(zcl_db_browser) WITH
*            li_row <ls_table_field>-scrtext_m.
*          RAISE missing_key.
*        ENDIF.
*
**       Falls Kleinbuchstaben nicht erlaubt, dann mache Großbuchstaben
**       daraus
*        IF <ls_table_field>-lowercase = abap_false.
*          TRANSLATE <ls_mod_cell>-value TO UPPER CASE.
*        ENDIF.
*
**       Wert des Feldes an den Schlüsselstring anhängen
*        CONCATENATE lc_key_string <ls_mod_cell>-value
*          INTO lc_key_string.
*
*        " WHERE Bedingung für Prüfung doppelter Einträge in der
*        "Datenbank dynamisch aufbauen
*        CLEAR lc_where_cond.
*        CONCATENATE '''' <ls_mod_cell>-value '''' INTO lc_where_cond.
*        CONCATENATE <ls_table_field>-fieldname '=' lc_where_cond
*          INTO lc_where_cond SEPARATED BY space.
*
*        " 'AND' in die WHERE Klausel aufnehmen, für alle ausser der
*        " ersten WHERE Bedingung
*        IF lb_first_loop = abap_true.
*          lb_first_loop = abap_false.
*        ELSE.
*          CONCATENATE 'AND' lc_where_cond INTO lc_where_cond SEPARATED
*            BY space.
*        ENDIF.
*
*        APPEND lc_where_cond TO lt_where_cond.
*
*      ENDLOOP.  " Schlüsselfeldloop
*
*      " Prüfen, ob der eingefügte eintrag in der Tabelle
*      " <lt_deleted_rows> steht, dann ist es ein Eintrag der in einem
*      " Schritt gelöscht und mit gleichem Schlüssel eingefügt wurde.
*      LOOP AT io_data_changed->mt_deleted_rows
*        ASSIGNING <ls_del_row>.
*        " Daten des gelöschten Datensatzes aus der Ausgabetabelle lesen
*        " und verleichen.
*        READ TABLE <gt_alv_result> ASSIGNING <ls_deleted_row>
*          INDEX <ls_del_row>-row_id.
*
*        IF <ls_deleted_row>(mi_keylen) = lc_key_string.
*          " Die Zeile wurde gelöscht, dann kann mit dem nächsten
*          " Datensatz aus INSERTED_ROWS fortgefahren werden.
*          lb_deleted_row = abap_true.
*          EXIT.
*        ENDIF.
*
*      ENDLOOP.
*      IF lb_deleted_row = abap_true. CONTINUE. ENDIF.
*
**     Im Einfügemodus darf der Datensatz weder in der von der
**     Datenbank gelesenen Tabelle ....
*      SELECT SINGLE * INTO lc_long_char
*        FROM (mc_table_name) WHERE (lt_where_cond).
*      IF sy-subrc = 0.
*        " Es gibt schon einen Datensatz mit dem Schlüssel in der
*        " Datenbank.
*        MESSAGE s001(zcl_db_browser)
*          WITH lc_long_char.
*        RAISE duplicate_key.
*      ENDIF.
*
**     noch in der INSERTED_ROWS Tabelle stehen
*      ASSIGN mr_inserted_rows->* TO <lt_inserted_rows>.
*      IF sy-subrc = 0.
*        LOOP AT <lt_inserted_rows> ASSIGNING <ls_inserted_row>.
*          IF lc_key_string = <ls_inserted_row>(mi_keylen).
*            MESSAGE s001(zcl_db_browser)
*              WITH lc_key_string.
*            RAISE duplicate_key.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*
*    ENDLOOP.
*
*
*  ENDMETHOD.

    METHOD switch_mode.

      DATA: lb_editable TYPE abap_bool.

      FIELD-SYMBOLS: <ls_row> TYPE ANY.

*     Umschalten zwischen Anzeige- und Änderungsmodus
      if ii_mode = 99.
        if mi_mode = cc_mode_display.
          mi_mode = cc_mode_change.
        else.
          mi_mode = cc_mode_display.
        endif.
      else.
        mi_mode = ii_mode.
      endif.
      IF mi_mode = cc_mode_change.
        lb_editable = abap_true.
      ELSE.
        lb_editable = abap_false.
      ENDIF.

      " Die Editierbarkeit für alle Zeilen umschalten
      LOOP AT <gt_alv_result> ASSIGNING <ls_row>.
        PERFORM set_editable USING lb_editable
                                   abap_false
                             CHANGING <ls_row>.
      ENDLOOP.

      CALL METHOD go_alv_result->set_ready_for_input
        EXPORTING i_ready_for_input = mi_mode.

      CALL METHOD go_alv_result->refresh_table_display.

    ENDMETHOD.

*&----------------------------------------------------------------------
*& Beschreibung: Prüft, ob ein Datensatz schon in den Änderungstabellen
*&               INSERTED_ROWS, MODIFIED_ROWS od. DELETED_ROWS vorhanden
*&               ist.
*&
*& Autor:        HAENSEL
*& Angelegt am:  23.12.2004
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  II_ROW_ID    Zu suchender Datensatz wird anhand dieser
*&                     Zeilennummer in der Ausgabetabelle gesucht
*&                     (Optional).
*&  [IN]  IS_RECORD    Der zu suchende Datensatz kann hier direkt über-
*&                     geben werden (Optional).
*&  [IN]  IB_DELETE_ROW Der Datensatz wird aus der Tabelle wo er
*&                      gefunden wird gelöscht (Optional).
*&  [IN]  IB_USE_DB    Sucht einen Datensatz zusätzlich in der Daten-
*&                     bank, wenn er nicht in den Änderungstabellen
*&                     gefunden wurde, und stellt ihn in die Tabelle
*&                     MR_MODIFIED_ROWS (Optional).
*&  [OUT] CB_RECORD_CREATED Der Datensatz wurde in den Tabellen nicht
*&                          gefunden. Die Referenz CR_RECORD enthält
*&                          eine Referenz auf einen neu erstellten
*&                          leeren Datensatz
*&  [OUT] CR_RECORD    Referenz auf den gefundenen Datensatz, oder einen
*&                     leeren Datensatz.
*&  [OUT] CI_TABLE     Gibt an, in welcher Tabelle der Datensatz
*&                     gefunden wurde (Optional).
*&                     1...INSERTED_ROWS
*&                     2...MODIFIED_ROWS
*&----------------------------------------------------------------------
    METHOD find_insmod_record.
      DATA: lb_record_found  TYPE abap_bool,
            lb_deleted       TYPE abap_bool,
            lr_move_target   TYPE REF TO data.

      FIELD-SYMBOLS: <ls_record> TYPE ANY,
                     <ls_fieldinfo> TYPE dd03p,
                     <lc_fieldcontent> TYPE ANY,
                     <ls_inserted_row> TYPE ANY,
                     <ls_move_target>  TYPE ANY,
                     <ls_modified_row> TYPE ANY,
                     <lt_inserted_rows> TYPE table,
                     <lt_modified_rows> TYPE table.

      ASSIGN mr_inserted_rows->* TO <lt_inserted_rows>.

*   Anhand der RowID den Datensatz in der Ausgabetabelle ermitteln...
      IF NOT ii_row_id IS INITIAL.
        READ TABLE <gt_alv_result> ASSIGNING <ls_record>
          INDEX ii_row_id.
        CHECK sy-subrc = 0.

*   ...und die Style Tabelle entfernen, um einen Kurzdump beim Vergleich
*   zu vermeiden.
        CREATE DATA lr_move_target LIKE LINE OF <lt_inserted_rows>.
        ASSIGN lr_move_target->* TO <ls_move_target>.
        CALL FUNCTION '/CIDEON/MOVE_CORRESPONDING'
             EXPORTING
                  is_source              = <ls_record>
             CHANGING
                  es_target              = <ls_move_target>
             EXCEPTIONS
                  no_runtime_information = 1
                  OTHERS                 = 2.
        CHECK sy-subrc = 0.
      ENDIF.

      IF NOT is_record IS INITIAL.
        ASSIGN is_record TO <ls_move_target>.
      ENDIF.

*   Nach Datensatz mit dem Schlüssel in INSERTED_ROWS suchen
      lb_record_found = abap_false.
      LOOP AT <lt_inserted_rows> ASSIGNING <ls_inserted_row>.
        IF <ls_move_target>(mi_keylen) = <ls_inserted_row>(mi_keylen).
*       Datensatz gefunden
          IF ib_delete_row = abap_true.
            DELETE <lt_inserted_rows> INDEX sy-tabix.
            lb_deleted = abap_true.
          ELSE.
            GET REFERENCE OF <ls_inserted_row> INTO cr_record.
          ENDIF.
          lb_record_found = abap_true.
          ci_table = 1.  " INSERTED_ROWS
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lb_record_found = abap_false.
*     In der Tabelle mit dem modifizierten Datensätzen suchen
        ASSIGN me->mr_modified_rows->* TO <lt_modified_rows>.
        LOOP AT <lt_modified_rows> ASSIGNING <ls_modified_row>.
          IF <ls_move_target>(mi_keylen) = <ls_modified_row>(mi_keylen).
*         Datensatz gefunden
            IF ib_delete_row = abap_true.
              DELETE <lt_modified_rows> INDEX sy-tabix.
              lb_deleted = abap_true.
            ELSE.
              GET REFERENCE OF <ls_modified_row> INTO cr_record.
            ENDIF.
            lb_record_found = abap_true.
            ci_table = 2. "MODIFIED_ROWS
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lb_record_found = abap_false AND ib_use_db = abap_true.
        DATA: lt_where  TYPE zcl_db_where,
              lc_long_char(1024) TYPE c.

*     Suche in der Datenbank und stelle den gefundenen Daten-
*     satz in die MODIFIED_ROWS Tabelle.
        CALL METHOD compose_where_condition
          EXPORTING
            is_record = <ls_move_target>
          RECEIVING
            rt_where  = lt_where
          EXCEPTIONS
            missing_key = 1.
        CHECK sy-subrc = 0.

        SELECT SINGLE * INTO lc_long_char
          FROM (mc_table_name) WHERE (lt_where).
        IF sy-subrc = 0.
          APPEND <ls_move_target> TO <lt_modified_rows>.
          READ TABLE <lt_modified_rows> ASSIGNING <ls_modified_row>
            INDEX sy-tabix.
          GET REFERENCE OF <ls_modified_row> INTO cr_record.
          lb_record_found = abap_true.
          ci_table = 2. "MODIFIED_ROWS
        ENDIF.
      ENDIF.

      IF lb_record_found = abap_false OR lb_deleted = abap_true.

*     Wenn der Datensatz in INSERTED_ROWS und MODIFIED_ROWS nicht
*     gefunden wurde, dann gib eine Kopie des Datensatzes aus der
*     Ausgabetabelle nach aussen.
*     !!! Beim löschen wird immer eine Kopie nach aussen gegeben!!
        cb_record_created = abap_true.
        GET REFERENCE OF <ls_move_target> INTO cr_record.
      ENDIF.

    ENDMETHOD.

*&----------------------------------------------------------------------
*& Beschreibung: Wenn die Verarbeitung der geänderten Daten
*&               abgeschlossen ist, muss hier die Steuerung der
*&               Eingabebereitschaft der Schlüsselfelder erfolgen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  04.01.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&---------------------------------------------------------------------
    METHOD handle_data_changed_finished.

      DATA: lr_move_target TYPE REF TO data.

    FIELD-SYMBOLS: <lt_inserted_rows>    TYPE table, " Eingefügte Daten-
                                                       " sätze
                     <lt_modified_rows>    TYPE table, " Modifizierte
                                                       " Datensätze
                     <ls_inserted_row>     TYPE ANY,
                     <ls_modified_row>     TYPE ANY,
                     <ls_result>           TYPE ANY,
                     <ls_move_target>      TYPE ANY.

*   Nur fortfahren, wenn die Daten der Ausgabetabelle geändert wurden
*   und neue Datensätze in die Tabelle MR_INSERTED_ROWS eingefügt wurden
*
      CHECK e_modified = abap_true AND
        ( mi_insert_index > 0 OR mi_modify_index > 0 ).

      ASSIGN me->mr_inserted_rows->* TO <lt_inserted_rows>.
      ASSIGN me->mr_modified_rows->* TO <lt_modified_rows>.

*   Leeren Datensatz für MOVE_CORRESPONDING erzeugen
      CREATE DATA lr_move_target LIKE LINE OF <lt_inserted_rows>.
      ASSIGN lr_move_target->* TO <ls_move_target>.

      LOOP AT <gt_alv_result> ASSIGNING <ls_result>.

        CALL FUNCTION '/CIDEON/MOVE_CORRESPONDING'
             EXPORTING
                  is_source              = <ls_result>
             CHANGING
                  es_target              = <ls_move_target>
             EXCEPTIONS
                  no_runtime_information = 1
                  OTHERS                 = 2.
        CHECK sy-subrc = 0.

        IF mi_insert_index > 0.
          LOOP AT <lt_inserted_rows> ASSIGNING <ls_inserted_row>
            FROM mi_insert_index.
          IF <ls_inserted_row>(mi_keylen) = <ls_move_target>(mi_keylen).
*         Neu eingefügte Zeile. Schlüsselfelder müssen gesperrt werden.
              PERFORM set_editable USING  abap_true
                                         abap_false  " Schlüssel sperren
                                   CHANGING
                                          <ls_result>.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF mi_modify_index > 0.
          LOOP AT <lt_modified_rows> ASSIGNING <ls_modified_row>
            FROM mi_modify_index.
          IF <ls_modified_row>(mi_keylen) = <ls_move_target>(mi_keylen).
*         Neu eingefügte Zeile. Schlüsselfelder müssen gesperrt werden.
              PERFORM set_editable USING  abap_true
                                         abap_false  " Schlüssel sperren
                                   CHANGING
                                          <ls_result>.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

      CALL METHOD go_alv_result->refresh_table_display.

*   Einfügeindizes wieder zurücksetzen
      mi_insert_index = 0.
      mi_modify_index = 0.
    ENDMETHOD.

*&----------------------------------------------------------------------
*& Beschreibung: Speichert die Änderungen am Tabelleninhalt in die
*&               Datenbanktabelle zurück
*&
*& Autor:        HAENSEL
*& Angelegt am:  04.01.2004
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] EI_INSERTED  Anzahl neuer Datensätze
*&  [OUT] EI_MODIFIED  Anzahl geänderter Datensätze
*&  [OUT] EI_DELETED   Anzahl gelöschter Datensätze
*&----------------------------------------------------------------------
    METHOD save_changes.

      FIELD-SYMBOLS: <lt_inserted_rows>  TYPE table,
                     <lt_modified_rows>  TYPE table,
                     <lt_deleted_rows>   TYPE table,
                     <ls_row>            TYPE ANY.

*   Datenreferenzen der Änderungstabelle dereferenzieren
      ASSIGN me->mr_inserted_rows->* TO <lt_inserted_rows>.
      ASSIGN me->mr_modified_rows->* TO <lt_modified_rows>.
      ASSIGN me->mr_deleted_rows->* TO <lt_deleted_rows>.

*   (1) Löschen der zu löschenden Datensätze
      IF NOT <lt_deleted_rows> IS INITIAL.
        DELETE (gf_table) FROM TABLE <lt_deleted_rows>.
        IF sy-subrc > 0.
          RAISE error.
        ENDIF.
        ei_deleted = sy-dbcnt.
      ENDIF.

*   (2) Einfügen der neuen Datensätze
      IF NOT <lt_inserted_rows> IS INITIAL.
        INSERT (gf_table) FROM TABLE <lt_inserted_rows>.
        IF sy-subrc > 0.
          RAISE error.
        ENDIF.
        ei_inserted = sy-dbcnt.
      ENDIF.

*   (3) Änderung der geänderten Datensätze
      IF NOT <lt_modified_rows> IS INITIAL.
        UPDATE (gf_table) FROM TABLE <lt_modified_rows>.
        IF sy-subrc > 0.
          RAISE error.
        ENDIF.
        ei_modified = sy-dbcnt.
      ENDIF.

*   Falls alle Aktionen geklappt haben, werden nun die Änderungstabellen
*   wieder aufgeräumt.
      REFRESH <lt_inserted_rows>.
      REFRESH <lt_modified_rows>.
      REFRESH <lt_deleted_rows>.

    ENDMETHOD.

*&----------------------------------------------------------------------
*& Beschreibung: Füllt die Änderungsprotokollfelder der übergebenen
*&               Struktur, wenn diese vorhanden sind.
*&
*& Autor:        HAENSEL
*& Angelegt am:  06.01.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  IB_BOTH  FALSE...Nur die UPD Felder werden beschrieben
*&                 TRUE....INS und UPD Felder werden beschrieben
*&  [OUT] CS_RECORD Datensatz
*&----------------------------------------------------------------------
    method fill_insupd.

      field-symbols: <lc_fieldcontent> type any.

      check mb_insupd = abap_true.

      if ib_both = abap_true.
*       INSERT Daten füllen
        assign component 'ZCLINSNAME' of structure cs_record
          to <lc_fieldcontent>.
        <lc_fieldcontent> = sy-uname.
        assign component 'ZCLINSDATE' of structure cs_record
          to <lc_fieldcontent>.
        <lc_fieldcontent> = sy-datum.
        assign component 'ZCLINSTIME' of structure cs_record
          to <lc_fieldcontent>.
        <lc_fieldcontent> = sy-uzeit.
        assign component 'ZCLINSPROG' of structure cs_record
          to <lc_fieldcontent>.
        <lc_fieldcontent> = sy-repid.
      endif.

*     MODIFY Daten füllen
      assign component 'ZCLUPDNAME' of structure cs_record
        to <lc_fieldcontent>.
      <lc_fieldcontent> = sy-uname.
      assign component 'ZCLUPDDATE' of structure cs_record
        to <lc_fieldcontent>.
      <lc_fieldcontent> = sy-datum.
      assign component 'ZCLUPDTIME' of structure cs_record
        to <lc_fieldcontent>.
      <lc_fieldcontent> = sy-uzeit.
      assign component 'ZCLUPDPROG' of structure cs_record
        to <lc_fieldcontent>.
      <lc_fieldcontent> = sy-repid.

    endmethod.
  ENDCLASS.
