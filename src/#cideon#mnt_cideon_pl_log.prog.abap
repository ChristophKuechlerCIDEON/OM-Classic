*&---------------------------------------------------------------------*
*& Report  /CIDEON/MNT_CIDEON_PL_LOG                              *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON
* Anzeige Plot Log /CIDEON/PL_LOG
*
*
*-----------------------------------------------------------------------
* Author :        C. Küchler  / CKR
*
* Änderungen:
*
* Kontakt über:   HELPDESK@CIDEON-SOFTWARE.DE
*
*-----------------------------------------------------------------------
* Journal
* 12.10.2004 - Erstellung
* 15.10.2004 - Anzeige der DIS Daten + Änderung
*              Refresh Möglichkeit
* 19.10.2004 - Kopie
* 07.01.2005 - Kopie für Plot LOG
* 29.01.2005 - Bestätigungs Button für Audit Trail
* 31.01.2005 - WSAPPLICATION	DAPPL
* 05.02.2005 - Button für fehlerhafte Ausgabe
* 03.03.2005 - JavaGUI Anpassung
* 07.04.2005 - LIFNR / NAME1_GP (30. Geburtstag B.B.)
* 11.04.2005 - LIFNR / NAME1_GP
* 18.04.2005 - EBELN
* 10.05.2005 - MATNR
* 10.01.2006 - ID_PLOTJOB_32 / ID_PLOTJOB
* 17.07.2006 - Jobverwaltung (Sulzer)
*              fällig / Status
*              Zurückbekommen
* 21.07.2006 - optische Änderungen
* 06.09.2006 - PSPID
* 09.08.2007 - KUNNR_WE
*              KINNR_AG
* 15.10.2007 - SP 51 / 3.0.4.2
*              Änderungssnummer innerhalb des Plot LOGs
*              Sprung in Anzeige Änderungsnummer
*              Sprung in Anzeige Kreditor
* 16.10.2007 - Test der Umstellung auf mehrere Tabs
* 13.11.2007 - SP 56
*              Sendedatum, Datum der ersten Mahnung
*              Datum der zweiten Mahnung
* 15.11.2007 - Senden von Mahnungen
*              Mahnstufe erkennen
* 19.11.2007 - SP 58 / 4.3.8.5
*              Info Schaltfläche
*              schaltflächen aus Status in ALV bringen
* 20.11.2007 - SP 59 / 4.3.8.6
*              BUG Notizschaltflächen
* 03.01.2008 - SP 62 / 3.0.4.7
*              Vorbereitungen für Erstellen von DIS aus Spooleinträgen
*              für die Integration in Einkaufstransaktionen
*              /CIDEON/MNT_CIDEON_PL_LOG Anpassungen für Bestätigung
*              eines gesamten Jobs
*              Doppelklick selektiert ganzen Job (wieder ausgebaut)
*              Abfrage ob Aktion für gesamten Job durchgeführt
*              werden soll
* 22.01.2008 - SP 63 / 3.0.4.11
*              Anpassung ganze Jobs bestätigen, mahnen
*              Vorselektion ()
*              Menü mit Defaulteintrag
* 23.09.2008 - SP 77 / 7.0.0.1
*              Erweiterungen für kontrollierten Ausdruck
*              Corden Pharma
* 29.09.2008 - SP 78
*              Anbindung der neuen Felder innerhalb der SELECT-OPTIONS
*
* 05.10.2008- SP 79
*             experimentelles Programm
* SP 132
* 7.0.132.1
*             Erneutes Starten von Ausgaben aus dem LOG
*
* SP 134
* 7.0.134.4 - Erneutes Starten von Ausgaben aus dem LOG
*
* SP 139
* 04.11.2010 - CKR
* 7.0.139.1    Erweiterung /CIDEON/S_ENHC_TRANSFER_01
*              SERNR
*              EMITEC
*
* SP 140
* 05.11.2010 - CKR
*              Reihenfolge Menüeintrag im LOG
*
* SP 147
* 17.03.2011 - CKR
*              Einbau /CIDEON/PL_LOG2
*              Feld LIF_SMTP_ADDR
*
* -> Notwendigkeit des Umbaus, um die Tabellen /CIDEON/PL_LOG und
* /CIDEON/PL_LOG2 zu berücksichtigen!!!
* -> Struktur -> LEFT OUTER JOIN und Anpassung des Dialoges
*
* 7.0.150.1
* 06.05.2011 - CKR
*              Integration des Dokumentenstatus in PlotLOG
*              -> HST -
*-----------------------------------------------------------------------
* toDo
*  - Schaltflächen aus dem Status nehmen wegen Übersicht
*
*
*  - Visualisierungen / Ampeln
*    - Status
*    - Verhältnis DUE Date zu Received back Date etc.
*  allgemein
*    - nach Änderungen im ALV ist die Seletion wieder zu setzen
*    - Lesen der Keys und dann setzen im ALV, falls die Keys noch
*      vorhanden
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------

report  /cideon/maint_cideon_cadm_par.

include /cideon/mnt_cideon_pl_log_ctrl.

* control
controls tabstr type tabstrip.

*********
* Predefine a local class for event handling to allow the
* declaration of a reference variable.
class lcl_event_handler definition deferred.
*********

* tables
tables: /cideon/pl_log.
tables: /cideon/pl_log2.
tables sscrfields.


* types
types: begin of ty_.
        include structure /cideon/pl_log.
types: end of ty_.

types: begin of ty_2.
        include structure /cideon/pl_log2.
types: end of ty_2.

data: tabname type tabname value '/CIDEON/PL_LOG'.

*Toolbars
data: log_toolbar  type stb_button.

data: ok_code like sy-ucomm,
        returncode like bdcmsgcoll,



* Exclude table
      it_excl type table of rsexfcode,
      wa_excl like line of it_excl,

* reference variables
      ref_container     type ref to cl_gui_docking_container,
        "cl_gui_custom_container,
      ref_alv           type ref to cl_gui_alv_grid,

* layout variable of alv grid
      wa_s_layo         type lvc_s_layo,

* variant structure
      wa_s_variant      type disvariant,

* field catalog
      it_field_cat      type table of lvc_s_fcat,
      wa_field_cat      type lvc_s_fcat,

* internal table
      it          type table of ty_,
      it2          type table of ty_2,
      it_det      type table of ty_,

* working area
      wa                like line of it,
      wa2                like line of it2,
      index             type i,
      max_lines         type i,
      wa_edit_mode,
      wa_save_neccessary,
      answer,
      dynp(4).
data: count_lines type i. "Anzahl der Einträge

data: cursor_field like trdir-name,
      cursor_value like trdir-name.

data: f_whole_job.

data: it_objects type table of zcl_pdm_exp_objects.


*FIELD SYMBOLS
field-symbols <wa> type ty_.

* authority check
* Berechtigungscheck
*AUTHORITY-CHECK OBJECT 'ZCL_PLOT_2'
*         ID 'ZCL_TA' FIELD sy-tcode
*         ID 'ACTVT' FIELD '16'
**           id 'ZDPH_KLIEN' dummy
**           id 'ZDPH_LAGER' dummy
*.
*IF sy-subrc > 0.
*  MESSAGE s099(zcl_plint_tools)
*    WITH '' '' '' ''.  "Sie haben keine Berechtigung ..
*  LEAVE PROGRAM.
*ELSE.
*ENDIF.


selection-screen begin of screen 1100 title seltitle.

selection-screen begin of tabbed block tabbl for 20 lines.
selection-screen tab (20) tabs1 user-command ucomm1
                      default screen 1200.

selection-screen tab (20) tabs2 user-command ucomm2
                      default screen 1300.


selection-screen end of block tabbl.
selection-screen function key 1.
selection-screen end of screen 1100.



initialization.
  tabs1 = text-003.
  tabs2 = text-004.
*  tabs3 = text-005.
*  tabs4 = text-006.
*  tabs5 = text-007.

  selection-screen begin of screen 1200 as subscreen.
**KEY
*  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-010.
*  SELECT-OPTIONS:
*    s_id FOR /cideon/pl_log-id
*    .
*  SELECTION-SCREEN END OF BLOCK bl1.
  selection-screen end of screen 1200.



  selection-screen begin of screen 1300 as subscreen.
  selection-screen begin of block bllo1 with frame title text-lo1.
*  SELECT-OPTIONS:  s_status FOR /cideon/pl_log-status.
*  SELECT-OPTIONS:  s_notiz FOR /cideon/pl_log-notiz.
  selection-screen end of block bllo1.

  selection-screen end of screen 1300.



* selection screen


*WERTE
  selection-screen begin of block bl2 with frame title text-011.

  selection-screen begin of block bsta with frame title text-sta.
  select-options:  s_status for /cideon/pl_log-status.
  selection-screen end of block bsta.


  selection-screen begin of block blver with frame title text-ver.
  select-options:  s_matnr for /cideon/pl_log-matnr.
  select-options:  s_aennr for /cideon/pl_log-aennr.
  select-options:  s_pspid for /cideon/pl_log-pspid.
  selection-screen end of block blver.


  selection-screen begin of block bldis with frame title text-dis.
  select-options:  s_dokar for /cideon/pl_log-dokar.
  select-options:    s_doknr for /cideon/pl_log-doknr.
  select-options:    s_doktl for /cideon/pl_log-doktl.
  select-options:    s_dokvr for /cideon/pl_log-dokvr.
  select-options:    s_dokst for /cideon/pl_log-dokst.
  selection-screen end of block bldis.

  selection-screen begin of block bljob with frame title text-job.
  select-options:    s_jid for /cideon/pl_log-id_plotjob.
  select-options:    s_jid_32 for /cideon/pl_log-id_plotjob_32.
  select-options:  s_dappl for /cideon/pl_log-wsapplication.
  select-options:  s_filep for /cideon/pl_log-filep.
  select-options:  s_kopien for /cideon/pl_log-kopien.
  select-options:  s_vertei for /cideon/pl_log-verteiler.
  select-options:  s_notiz for /cideon/pl_log-notiz.
  selection-screen end of block bljob.

  selection-screen begin of block bllo with frame title text-log.
  select-options:  s_vbeln for /cideon/pl_log-vbeln.
  select-options:  s_aufnr for /cideon/pl_log-aufnr.
  select-options:  s_lifnr for /cideon/pl_log-lifnr.
  select-options:  s_name1 for /cideon/pl_log-name1_lifnr.
  select-options:  s_ebeln for /cideon/pl_log-ebeln.
  select-options:  s_ku_we for /cideon/pl_log-kunnr_we.
  select-options:  s_ku_ag for /cideon/pl_log-kunnr_ag.
  select-options:  s_sernr for /cideon/pl_log-sernr.
  selection-screen end of block bllo.

* Nachverfolgung
  selection-screen begin of block bltrac with frame title text-tra.
  select-options:  s_rcdate for /cideon/pl_log-recdate.
  select-options:  s_dudate for /cideon/pl_log-duedate.
  select-options:  s_sedate for /cideon/pl_log-senddate.
  select-options:  s_m1date for /cideon/pl_log-m1date.
  select-options:  s_m2date for /cideon/pl_log-m2date.
  selection-screen end of block bltrac.

* kontrollierte Ausgabe
  selection-screen begin of block bl_co with frame title text-cto.
  select-options:  s_pr_ty for /cideon/pl_log-print_type.
  select-options:  s_reci for /cideon/pl_log-recipient.
  select-options:  s_nr_cop for /cideon/pl_log-nr_copies.
  select-options:  s_pr_cau for /cideon/pl_log-print_cause.
  select-options:  s_charg for /cideon/pl_log-charg.

  selection-screen begin of block bl_ex with frame title text-ext.
  select-options:  s_date_x for /cideon/pl_log-date_exterm.
  select-options:  s_time_x for /cideon/pl_log-time_exterm.
  select-options:  s_user_x for /cideon/pl_log-user_exterm.
  select-options:  s_caus_x for /cideon/pl_log-cause_exterm.
  selection-screen end of block bl_ex.

  selection-screen end of block bl_co.


* Kostenstellen
  selection-screen begin of block bland with frame title text-and.
  select-options:  s_kostl for /cideon/pl_log-kostl.
  selection-screen end of block bland.

*KEY
  selection-screen begin of block bl1 with frame title text-010.
  select-options:
    s_id for /cideon/pl_log-id
    .
  selection-screen end of block bl1.


  selection-screen end of block bl2.

*INFO
  selection-screen begin of block bl3 with frame title text-012.
  select-options:
     sinsname for /cideon/pl_log-zclinsname,
     sinsdate for /cideon/pl_log-zclinsdate,
     sinstime for /cideon/pl_log-zclinstime,
     sinsprog for /cideon/pl_log-zclinsprog,
     supdname for /cideon/pl_log-zclupdname,
     supddate for /cideon/pl_log-zclupddate,
     supdtime for /cideon/pl_log-zclupdtime,
     supdprog for /cideon/pl_log-zclupdprog .
  selection-screen end of block bl3.

*ZUSATZ
  selection-screen begin of block bl4 with frame title text-013.
  parameters:
  list_bre like rseumod-tblistbr default '250' no-display,
  max_sel  like rseumod-tbmaxsel default '500'. " NO-DISPLAY.
  selection-screen end of block bl4.

  selection-screen: function key 1.

initialization.
  sscrfields-functxt_01 = text-020.
*  SET TITLEBAR 'COUNT_LINES'.

*  CALL SELECTION-SCREEN 1100.


start-of-selection.

at selection-screen.
* set edit mode to show (= '0')
  wa_edit_mode = co_show_mode.

  case sscrfields-ucomm.
      when'FC01'.
* Anzahl der Einträge
      perform get_data_count.
      set titlebar 'COUNT_LINES' with count_lines '' '' '' ''.
    when 'ONLI' or 'CRET'.
* get selected data
      perform get_data.
* call first screen
*      IF it[] IS INITIAL.
*      ELSE.
      call screen 100.
*      ENDIF.
  endcase.

*AT SELECTION-SCREEN ON EXIT-COMMAND.
*  CASE sscrfields-ucomm.
*    WHEN 'CBAC' OR 'CCAN' OR 'CEND'.
*      LEAVE PROGRAM.
*  ENDCASE.

  include <icon>.

* Include files
  include /cideon/mnt_cideon_pl_log_cl.
  include /cideon/mnt_cideon_pl_log_pbo.
  include /cideon/mnt_cideon_pl_log_pai.
  include /cideon/mnt_cideon_pl_log_fm.

  include /cideon/mnt_cideon_pl_log_fm02.
