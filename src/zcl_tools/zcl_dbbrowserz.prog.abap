*&---------------------------------------------------------------------*
*& Report  Z_DBBROWSER                                                 *
*&---------------------------------------------------------------------*
*& SE16 light                                                          *
*& Erstellt im April 2001 von Ralf Rubel                               *
*& Änderungen                                                          *
*& 20011010 Neues UI (Left Docking)                                    *
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
* angepaßt von
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
* 26.11.2004  Heiko Hänsel Editierfunktionalität für Tabelleninhalte
*-----------------------------------------------------------------------

REPORT  z_dbbrowser.

CLASS /cideon/cl_alv_grid_helper DEFINITION LOAD.

TABLES: dd02t.

TYPES: BEGIN OF ddic_tab,
         tabname TYPE tabname,
         ddtext  TYPE as4text,
       END OF ddic_tab.

TYPE-POOLS abap.

* Globale Daten
DATA:  gf_table         TYPE tabname,
       gf_ddtext        TYPE as4text,
       container        TYPE REF TO cl_gui_custom_container,
       easpl_container  TYPE REF TO cl_gui_easy_splitter_container,
       docking_left     TYPE REF TO cl_gui_docking_container,

       go_alv_ddic       TYPE REF TO cl_gui_alv_grid,
       gt_alv_ddic       TYPE TABLE OF ddic_tab,
       gs_alv_ddic       LIKE LINE OF gt_alv_ddic,


       go_alv_result    TYPE REF TO cl_gui_alv_grid,
       go_alv_structure TYPE REF TO cl_gui_alv_grid,
       gt_alv_structure TYPE TABLE OF lvc_s_fcat,

*      Globale Daten für Result View ALV Grid
       gt_alv_result_fcat TYPE lvc_t_fcat,       " Feldkatalog
       gc_alv_style_fname TYPE lvc_fname,        " Name der Styletabelle
       gt_table_structure TYPE dd03ttyp,   " Tabellenstruktur

       okcode TYPE syucomm,
       gv_okcode TYPE syucomm,

*      Tabelle mit inaktiven GUI Status
       gt_status_excl    TYPE TABLE OF rsmpe-func.

DATA:          ds_table TYPE REF TO data.
FIELD-SYMBOLS  <fs> TYPE ANY.
FIELD-SYMBOLS: <co> TYPE ANY.

*DATA:          go_sdescr TYPE REF TO cl_abap_structdescr.

FIELD-SYMBOLS  <components>       TYPE abap_compdescr.
FIELD-SYMBOLS  <gt_alv_result>    TYPE table.

* Einbindung lokaler Klassendefinitionen und Implementierungen
INCLUDE zcl_dbbrowserz_cd.
INCLUDE zcl_dbbrowserz_ci.

DATA: go_event_alv_ddic TYPE REF TO lcl_event_alv_ddic,
      go_result_event  TYPE REF TO lcl_result_event_receiver.

* Select-Options / Parameters
SELECT-OPTIONS:
  so_table FOR dd02t-tabname.
PARAMETERS:
  gf_maxln TYPE i DEFAULT '200'.

INITIALIZATION.
  PERFORM set_save_enabled USING abap_false.

* Start
START-OF-SELECTION.
  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Module  user_command  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE gv_okcode.
    WHEN 'BACK'.
      SET SCREEN 0.
    WHEN 'PB_EXECUTE'.
      LEAVE TO LIST-PROCESSING.
      PERFORM create_alv.
    WHEN 'SAVE'.
      PERFORM save.
  ENDCASE.
ENDMODULE.                 " user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  save_okcode  INPUT
*&---------------------------------------------------------------------*
MODULE save_okcode INPUT.
  gv_okcode = okcode.
  CLEAR okcode.
ENDMODULE.                 " save_okcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  status  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS 'MAIN' EXCLUDING gt_status_excl.
  SET TITLEBAR  'MAIN'.
ENDMODULE.                 " status  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  CASE okcode.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      SET SCREEN 0.
  ENDCASE.
ENDMODULE.                 " exit  INPUT

*&----------------------------------------------------------------------
*& Beschreibung: Erstellt die ALV Grid Objekte auf dem Dynpro und initi-
*&               alisiert die Ereignisbehandlung
*&
*& Autor:        ???
*& Angelegt am:  ???
*&----------------------------------------------------------------------
*& Änderungen:
*&  26.11.2004 Heiko Hänsel Zusätzliche Toolbar Buttons für die Änderung
*&                          von Tabelleninhalten.
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
FORM create_alv.
  DATA: ls_alv_lay TYPE lvc_s_layo,
        lr_table TYPE REF TO data,

        lr_result_outtab_rec TYPE REF TO data,
        li_struct_size       TYPE i.

  FIELD-SYMBOLS: <ls_result_outtab_rec> TYPE ANY,
                 <ls_table_field>       TYPE dd03p,
                 <ls_fcat_entry>        TYPE lvc_s_fcat.

* Instanz auf ALV-Grid
  IF container IS INITIAL.
    CREATE OBJECT container
      EXPORTING container_name = 'CONTAINER'.

    CREATE OBJECT easpl_container
      EXPORTING
        parent = container
        orientation =
          cl_gui_easy_splitter_container=>orientation_vertical.

    CREATE OBJECT go_alv_result
      EXPORTING
        i_parent = easpl_container->bottom_right_container.

    " Event Handler für go_alv_result.
    CREATE OBJECT go_result_event.

    CREATE OBJECT go_alv_structure
      EXPORTING
        i_parent = easpl_container->top_left_container.
  ELSE.
    CALL METHOD go_alv_result->free.
    CALL METHOD go_alv_structure->free.

    REFRESH <gt_alv_result>.

    " REFRESH lt_alv_cat.
    CREATE OBJECT go_alv_result
      EXPORTING
        i_parent = easpl_container->bottom_right_container.
    CREATE OBJECT go_alv_structure
      EXPORTING
        i_parent = easpl_container->top_left_container.
  ENDIF.

* Infos über den Aufbau der Tabelle aus dem DDIC besorgen und global
* ablegen.
  CALL FUNCTION 'DD_TBFD_GET'
   EXPORTING
*     GET_STATE           = 'M'
*     LANGU               = SY-LANGU
*     PRID                = 0
     tabl_name           = gf_table
     withtext            = abap_true    " Feldbez. für Fehlermeldungen
*     ADD_TYPEINFO        = 'X'
*     USE_CACHE           = ' '
*     TRACELEVEL          = 0
*   IMPORTING
*     GOT_STATE           =
   TABLES
     dd03p_tab_a         = gt_table_structure
*     DD03P_TAB_N         =
   EXCEPTIONS
     illegal_value       = 1
     op_failure          = 2
     OTHERS              = 3
          .

* Erzeugen der Strukturreferenz + Dereferenzierung an Feldsymbol
  CREATE DATA ds_table TYPE (gf_table).
  ASSIGN ds_table->* TO <fs>.

* Feldkatalog aufbauen
  CLEAR gt_alv_result_fcat.
  gt_alv_result_fcat =
    /cideon/cl_alv_grid_helper=>create_fieldcat_dynamic(
    is_data = <fs>
  ).
* Schlüsselfelder markieren
  LOOP AT gt_table_structure ASSIGNING <ls_table_field>.
    READ TABLE gt_alv_result_fcat ASSIGNING <ls_fcat_entry>
      WITH KEY fieldname = <ls_table_field>-fieldname.
    IF sy-subrc = 0.
      IF <ls_table_field>-keyflag = abap_true.
        <ls_fcat_entry>-key = abap_true.
      ENDIF.
      <ls_fcat_entry>-edit = abap_true.
    ENDIF.
  ENDLOOP.

* Ausgabetabelle aufbauen
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = gt_alv_result_fcat
      i_style_table   = abap_true
    IMPORTING
      ep_table = lr_table
      e_style_fname = gc_alv_style_fname.
  ASSIGN lr_table->* TO <gt_alv_result>.

* Ereignishandler initialisieren
  CALL METHOD go_result_event->initialize(
    ic_table_name    = gf_table
    it_field_catalog = gt_alv_result_fcat
    it_table_structure = gt_table_structure
  ).

* Struktur aus Ausgabetabelle für Transfer aus Datenbanktabelle erzeugen
  CREATE DATA lr_result_outtab_rec LIKE LINE OF <gt_alv_result>.
  ASSIGN lr_result_outtab_rec->* TO <ls_result_outtab_rec>.

* Dynamischer Select
  DATA: lf_tabclass TYPE tabclass.
  SELECT SINGLE tabclass FROM  dd02l INTO lf_tabclass
    WHERE  tabname   = gf_table
    AND    as4local  = 'A'
    AND    as4vers   = '0000'.

  FIELD-SYMBOLS: <ls_test> TYPE ANY.
  li_struct_size = 467.

  IF lf_tabclass EQ 'TRANSP'  OR
     lf_tabclass EQ 'POOL'    OR
     lf_tabclass EQ 'CLUSTER'.
    SELECT * FROM (gf_table) UP TO gf_maxln ROWS
      INTO <fs>.
      CALL FUNCTION '/CIDEON/MOVE_CORRESPONDING'
           EXPORTING
                is_source = <fs>
           CHANGING
                es_target = <ls_result_outtab_rec>.

      " Felder gegen Änderungen sperren, da zu Beginn Anzeigemodus
      " aktiv ist.
      "      perform set_editable using abap_false
      "                                abap_false
      "                         changing <ls_result_outtab_rec>.

      APPEND <ls_result_outtab_rec> TO <gt_alv_result>.
    ENDSELECT.
  ENDIF.

  DATA: lf_anzln(15),
        lf_limited(10).
  DESCRIBE TABLE <gt_alv_result>.
  lf_anzln = sy-tfill.
  IF sy-tfill = gf_maxln.
    lf_limited = ' limitiert'.
  ENDIF.
* Layout
  CONCATENATE gf_table ' - ' gf_ddtext ', Anzahl Sätze: '
    lf_anzln lf_limited INTO ls_alv_lay-grid_title.
  CONDENSE ls_alv_lay-grid_title.
  ls_alv_lay-zebra      = abap_true.
  ls_alv_lay-cwidth_opt = abap_true.
  ls_alv_lay-stylefname = gc_alv_style_fname.

* Anzeige ALV-Grid für Suchergebniss
  CALL METHOD go_alv_result->set_table_for_first_display
    EXPORTING
      is_layout                     = ls_alv_lay
    CHANGING
      it_outtab                     = <gt_alv_result>
      it_fieldcatalog               = gt_alv_result_fcat.
  SET HANDLER go_result_event->handle_toolbar FOR
    go_alv_result.
  SET HANDLER go_result_event->handle_user_command FOR
    go_alv_result.
  SET HANDLER go_result_event->handle_data_changed FOR
    go_alv_result.
  SET HANDLER go_result_event->handle_data_changed_finished FOR
    go_alv_result.

* Beim Start -> Anzeigemodus
  CALL METHOD go_result_event->switch_mode( 0 ).

* ENTER als Edit Ereignis registrieren, damit bei ENTER Taste das
* Ereignis DATA_CHANGED ausgelöst wird.
  CALL METHOD go_alv_result->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

* Toolbar festlegen
  CALL METHOD go_alv_result->set_toolbar_interactive.

* Komplettierte Struktur besorgen
  CALL METHOD go_alv_result->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = gt_alv_structure.

* Layout
  CONCATENATE 'Struktur von' gf_table ', Tabclass:' lf_tabclass
    INTO ls_alv_lay-grid_title SEPARATED BY space.
  ls_alv_lay-zebra      = abap_true.
  ls_alv_lay-cwidth_opt = abap_true.

* Die editierbaren Zellen, eingabebereit setzen
  CALL METHOD go_alv_result->set_ready_for_input
                     EXPORTING i_ready_for_input = 0.

* Anzeige ALV-Grid für Struktur
  CALL METHOD go_alv_structure->set_table_for_first_display
    EXPORTING
      i_structure_name             = 'lvc_s_fcat'
      is_layout                     = ls_alv_lay
    CHANGING
      it_outtab                     = gt_alv_structure.

ENDFORM.                    " create_alv
*&---------------------------------------------------------------------*
*&      Module  create_docking_left  OUTPUT
*&---------------------------------------------------------------------*
MODULE create_docking_left OUTPUT.
  PERFORM pbo_create_docking_left.
ENDMODULE.                 " create_docking_left  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  pbo_create_docking_left
*&---------------------------------------------------------------------*
FORM pbo_create_docking_left.
  DATA: lt_alv_cat TYPE TABLE OF lvc_s_fcat,
        ls_alv_cat LIKE LINE OF lt_alv_cat,
        ls_alv_lay TYPE lvc_s_layo,
        lt_toolbar_excl TYPE ui_functions,
        ls_toolbar_excl LIKE LINE OF lt_toolbar_excl.

  IF docking_left IS INITIAL.
    CREATE OBJECT docking_left
      EXPORTING
        side = cl_gui_docking_container=>dock_at_left
        extension = 500.
    CREATE OBJECT go_alv_ddic
      EXPORTING
        i_parent = docking_left.
    SELECT tabname ddtext FROM dd02t
      INTO CORRESPONDING FIELDS OF TABLE gt_alv_ddic
      WHERE tabname IN so_table
      AND   as4local   = 'A'
      AND   ddlanguage   = sy-langu.
* Feldkatalog aufbauen
    ls_alv_cat-fieldname = 'TABNAME'.
    ls_alv_cat-ref_table = 'DD02T'.
    ls_alv_cat-ref_field = 'TABNAME'.
    APPEND ls_alv_cat TO lt_alv_cat.
    ls_alv_cat-fieldname = 'DDTEXT'.
    ls_alv_cat-ref_table = 'DD02T'.
    ls_alv_cat-ref_field = 'DDTEXT'.
    APPEND ls_alv_cat TO lt_alv_cat.
* Layout
    ls_alv_lay-grid_title = 'DDIC Tabellen'.
    ls_alv_lay-zebra      = abap_true.
    ls_alv_lay-cwidth_opt = abap_true.
* Exclude toolbar functions
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_detail.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_sum.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_info.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_graph.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_subtot.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_minimum.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_maximum.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_average.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.
    ls_toolbar_excl   = cl_gui_alv_grid=>mc_fc_auf.
    APPEND ls_toolbar_excl TO lt_toolbar_excl.

* Anzeige ALV-Grid für DDIC-Tabellen
    CALL METHOD go_alv_ddic->set_table_for_first_display
      EXPORTING
        is_layout            = ls_alv_lay
        it_toolbar_excluding = lt_toolbar_excl
      CHANGING
        it_outtab            = gt_alv_ddic
        it_fieldcatalog      = lt_alv_cat.
* event handler for double click
    CREATE OBJECT go_event_alv_ddic.
    SET HANDLER go_event_alv_ddic->handle_double_click
      FOR go_alv_ddic.
* Sonderfall 1 Treffer
    DESCRIBE TABLE gt_alv_ddic.
    IF sy-tfill = 1.
      READ TABLE gt_alv_ddic INTO gs_alv_ddic
        INDEX 1.
      gf_table  = gs_alv_ddic-tabname.
      gf_ddtext = gs_alv_ddic-ddtext.
      PERFORM create_alv.
    ENDIF.
  ENDIF.
ENDFORM.                    " pbo_create_docking_left

*&----------------------------------------------------------------------
*& Beschreibung: Legt einen neuen leeren Datensatz im Result ALV Grid
*&               an. Der Benutzer kann dann die Daten eingeben.
*&
*& Autor:        Heiko Hänsel
*& Angelegt am:  26.11.2004
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
FORM insert_new_record.

  DATA: lr_record    TYPE REF TO data,
        li_record_no TYPE i,
        ls_row_id    TYPE lvc_s_row,
        ls_col_id    TYPE lvc_s_col.

  FIELD-SYMBOLS: <ls_record> TYPE ANY,
                 <ls_field>  TYPE dd03p.

* Neuen Datensatz dynamisch erzeugen
  CREATE DATA lr_record LIKE LINE OF <gt_alv_result>.
  ASSIGN lr_record->* TO <ls_record>.

* Alle Felder dieser neuen Zeile auf Eingabebereitschaft stellen
  PERFORM set_editable USING    abap_true    " Editierbar schalten
                                abap_true    " Schlüsselfelder auch
                       CHANGING <ls_record>. " Datensatz

* Die editierbaren Zellen, eingabebereit setzen
  CALL METHOD go_alv_result->set_ready_for_input
                     EXPORTING i_ready_for_input = 1.


* Datensatz an die Ausgabetabelle anhängen
  APPEND <ls_record> TO <gt_alv_result>.
  DESCRIBE TABLE <gt_alv_result> LINES li_record_no.

* ALV Grid aktualisieren
  CALL METHOD go_alv_result->refresh_table_display.

* Cursor auf die erste Spalte der neuen Zeile setzen
  ls_row_id-index = li_record_no.
  READ TABLE gt_table_structure ASSIGNING <ls_field>
    INDEX 1.
  ls_col_id-fieldname = <ls_field>-fieldname.
  CALL METHOD go_alv_result->set_current_cell_via_id(
    is_row_id = ls_row_id
    is_column_id = ls_col_id
  ).

ENDFORM.

*&----------------------------------------------------------------------
*& Beschreibung: Setzt die Felder der übergebenen ALV Grid Zeile editier
*&               bar od. sperrt sie. Der Parameter ib_key legt fest, ob
*&               die Schlüsselfelder mit freigeschalten werden sollen.
*&
*& Autor:        Heiko Hänsel
*& Angelegt am:  29.11.2004
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  ib_edit      True...Editierbar machen; False...Sperren
*&  [IN]  ib_key       True...Alle Felder inkl. Schlüssel
*&  [IN]  is_line      Tabellenzeile
*&----------------------------------------------------------------------
FORM set_editable USING ib_edit  TYPE abap_bool
                        ib_key   TYPE abap_bool
                  CHANGING is_line  TYPE any.

  DATA: ls_style  TYPE lvc_s_styl.

  FIELD-SYMBOLS: <lt_styletab>  TYPE lvc_t_styl,
                 <ls_fcat_entry> TYPE lvc_s_fcat,
                 <ls_field>     TYPE dd03p.

* Style Tabelle aus dem Datensatz ziehen
  ASSIGN COMPONENT gc_alv_style_fname OF STRUCTURE is_line TO
    <lt_styletab>.
  CHECK sy-subrc = 0.
  REFRESH <lt_styletab>.

  LOOP AT gt_alv_result_fcat ASSIGNING <ls_fcat_entry>.
    CLEAR ls_style.
    ls_style-fieldname = <ls_fcat_entry>-fieldname.

*   Auf Schlüsselfeld prüfen
    READ TABLE gt_table_structure ASSIGNING <ls_field>
      WITH KEY tabname   = gf_table
               fieldname = <ls_fcat_entry>-fieldname.
    IF sy-subrc = 0.
      IF <ls_field>-keyflag = abap_true.
        IF ib_key = abap_true.
          ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
        ELSE.
          ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
        ENDIF.
      ENDIF.
      IF ib_edit = abap_true.
        IF NOT ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
          ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
        ENDIF.
      ELSE.
        ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
      ENDIF.
    ENDIF.

*   Style Eintrag anhängen
    INSERT ls_style INTO TABLE <lt_styletab>.

  ENDLOOP.

ENDFORM.

*&----------------------------------------------------------------------
*& Beschreibung: Festlegung, ob der SAVE Button aktiv od. inaktiv sein
*&               soll.
*&
*& Autor:        HAENSEL
*& Angelegt am:  04.01.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  IB_ENABLED   TRUE...SAVE Button ist aktiv   (Default)
*&                     FALSE..SAVE Button ist inaktiv
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
FORM set_save_enabled USING ib_enabled TYPE abap_bool.
  IF ib_enabled = abap_true.
    DELETE gt_status_excl WHERE table_line = 'SAVE'.
  ELSE.
    READ TABLE gt_status_excl
      TRANSPORTING NO FIELDS
      WITH KEY table_line = 'SAVE'.
    IF sy-subrc > 0.
      APPEND 'SAVE' TO gt_status_excl.
    ENDIF.
  ENDIF.
  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTE'.
ENDFORM.

*&----------------------------------------------------------------------
*& Beschreibung: Speichert geänderte Datensätze in die Datenbanktabelle
*&               zurück.
*&
*& Autor:        HAENSEL
*& Angelegt am:  04.01.2004
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------
FORM save.

  DATA: li_inserted  TYPE i,
        li_modified  TYPE i,
        li_deleted   TYPE i.

*  Methode zum Speichern im Ereignis Handler des Tabelleninhalts
*  aufrufen.
  CALL METHOD go_result_event->save_changes
    IMPORTING
      ei_inserted = li_inserted
      ei_modified = li_modified
      ei_deleted  = li_deleted
    EXCEPTIONS
      error = 1.
  IF sy-subrc = 0.
    PERFORM set_save_enabled USING abap_false.
    MESSAGE s002(zcl_db_browser) WITH li_inserted li_modified
      li_deleted.
  ENDIF.
ENDFORM.
