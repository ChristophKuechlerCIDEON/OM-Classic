*----------------------------------------------------------------------*
*   INCLUDE ZCL_DBBROWSERZ_CD                                          *
*----------------------------------------------------------------------*
* Beschreibung: Klassendefinitionen für lokale Klassen des Programms
*
* Autor:        Heiko Hänsel
* Angelegt am:  26.11.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* LCL_EVENT_ALV_DDIC
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CLASS lcl_event_alv_ddic DEFINITION.
  PUBLIC SECTION.
    METHODS:
    handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
            IMPORTING e_row e_column.
ENDCLASS.                    "lcl_event_alv_ddic DEFINITION


* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* LCL_RESULT_EVENT_RECEIVER
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CLASS lcl_result_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS:
      initialize
        IMPORTING
          ic_table_name       TYPE tabname
          it_field_catalog    TYPE lvc_t_fcat
          it_table_structure  TYPE dd03ttyp,

      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
          e_object
          e_interactive,

      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm,

      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed,

      handle_data_changed_finished FOR EVENT data_changed_finished
        OF cl_gui_alv_grid
        IMPORTING
          e_modified,

      save_changes
        exporting
          EI_INSERTED  type i
          EI_MODIFIED  type i
          EI_DELETED   type i
        exceptions
          error,

      switch_mode
        importing
          ii_mode  type i  default 99.

          .

  PRIVATE SECTION.

    " Funktionscode für neuen Datensatz
    CONSTANTS:
      cc_fc_change_mode    TYPE  sy-ucomm  VALUE 'CHANGE_MODE',
      cc_mode_display  TYPE  i         VALUE 0,
      cc_mode_change   TYPE  i         VALUE 1.

    DATA:
      mb_error_in_data         TYPE abap_bool,

      mc_table_name            TYPE tabname,
      mt_table_structure       TYPE dd03ttyp,    " Tabellenstruktur
      mt_fcat                  TYPE lvc_t_fcat,  " Feldkatalog

      " Referenz auf die interne Datenbanktabelle
      mr_table_content         TYPE REF TO data,

      " Tabellen für Änderungsprotokollierung
      mr_inserted_rows         TYPE REF TO data,
      mr_modified_rows         TYPE REF TO data,
      mr_deleted_rows          TYPE REF TO data,

      " Temporäre Tabellen für die übernahme in die Änderungstabellen
      mr_inserted_tmp_rows     type ref to data,
      mr_modified_tmp_rows     type ref to data,

      mi_mode                  TYPE i,  " Änderungs-/Anzeigemodus

      mi_keylen                TYPE i,  " Länge des Tabellenschlüssels

      mi_insert_index          TYPE i,  " Index des ersten neu
                                        " eingefügten Datensatzes in
                                        " MR_INSERTED_ROWS für die
                                        " Feldsteuerung
      mi_modify_index          TYPE i,  " Index des ersten neu
                                        " eingefügten Datensatzes in
                                        " MR_MODIFIED_ROWS für die
                                        " Feldsteuerung
      mb_insupd                TYPE abap_bool. " Gibt an, ob die INSUPD
                                               " Struktur in der Tabelle
                                               " enthalten ist


    METHODS:
      update_delta_tables
        IMPORTING
          io_data_changed  TYPE REF TO cl_alv_changed_data_protocol,

*      check_key
*        IMPORTING
*          io_data_changed  TYPE REF TO cl_alv_changed_data_protocol
*        EXCEPTIONS
*          missing_key
*          duplicate_key,

       check_key
         IMPORTING
           is_record        TYPE any
         CHANGING
           cb_deleted_row   TYPE abap_bool
         EXCEPTIONS
           duplicate_key
           missing_key,


      find_insmod_record
        IMPORTING
          ii_row_id        TYPE i         OPTIONAL
          is_record        TYPE any       OPTIONAL
          ib_delete_row    TYPE abap_bool DEFAULT abap_false
          ib_use_db        TYPE abap_bool DEFAULT abap_false
        CHANGING
          cb_record_created TYPE abap_bool OPTIONAL
          cr_record         TYPE REF TO data
          ci_table          TYPE i         OPTIONAL,

      compose_where_condition
        importing
          is_record        type any
        returning
          value(rt_where)  type zcl_db_where
        exceptions
          missing_key,                        " Nötiges Schlüsselfeld
                                              " fehlt

      fill_insupd
        importing
          ib_both          type abap_bool
        changing
          cs_record        type any.

      .
ENDCLASS.
