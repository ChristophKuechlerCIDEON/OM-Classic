*&---------------------------------------------------------------------*
*& Report  /CIDEON/PLOT_ADMIN_TOOL_001                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :        C. Küchler  / CKR
*
* Änderungen:
*                 Dr. P. Rabe  / PRE
*
* Kontakt über:   https://service.cideon.com
*                 HELPDESK@CIDEON-SOFTWARE.DE
*-----------------------------------------------------------------------
* Journal
* 06.12.2003 - Erstellung
* 09.12.2003 -
* 10.12.2003 - Weiterverarbeitung
* 11.12.2003 - Fehlblattverarbeitung
*            - Spezialdokumente
* 15.12.2003 - Fehler bei Selektion
* 19.12.2003 - Beschreibung des Originals wurde nicht mitgegeben
* 12.01.2004 - Vorbelegungswerte
* 13.01.2004 - F4 Hilfen
* 27.01.2004 - eingabefähiges ALV -
*              Änderung Kopienanzahl und PreProcessor/Verteiler
* 28.01.2004 - weitere Information für PreProcessorauswahl
*              Pfade, FTP, Kennzeichen
*            - AO$_PATH, AO$_NAMING bei Kommunikation SMB
*            - Button um automatischen Durchlauf zu schalten
* 03.02.2004 - Darstellungsfehler / Tooltip
*            - Maximale Selektion / Anzahl der Einträge
* 05.02.2004 - Spezialfunktionen / Ablage in lokalem Verzeichnis
* 23.02.2004 - Konvertierung starten
* 24.03.2004 - Erweiterung auf eine 3. Tabelle /CIDEON//cideon/pl_jobs3
* 01.04.2004 - Anpassung des Operator auf Spezialeinträge
*              vom Typ 'Spool'
* 02.04.2004 - Berechtigungsobjekt für Ablage in lokalem Verzeichnis
* 14.04.2004 - Anzeige der Inhalts von Spoolaufträgen
* 02.07.2004 - CS Integration
* 28.09.2004 - Änderungen an Textelementen
* 10.07.2006 - Reaktion auf Probleme mit langen Views unter UNICODE
* 10.08.2006 - leere Stempel zulassen
* 16.08.2006 - KNZ_CREATE_TOC
*              KNZ_SEND_TOC
* 17.20.2006 - Daten der Änderungsnummer
* 04.10.2010 - CKR
*              PL4
*
* 20.05.2011 - CKR
* 7.0.151.1
* 20.05.2011 - Anpassungen Plot Operator
*              Einbau von Ikonen, welche den Status des Jobs anzeigen
*              Anzeige des Originales per Hotspot
*
** 7.0.151.2     Satzanzahl editierbar in Plot Operator
*
* 7.0.152.3
* 07.06.2011 - CKR
*              Anpassungen PlotOperator /CIDEON/PLOT_ADMIN_TOOL_000
*              Parameter editierbar im ALV
*-----------------------------------------------------------------------

report  /cideon/plot_admin_tool_001   .

tables sscrfields.

class lcl_event_handler_alv_plot definition deferred.
class lcl_alv_prepr_event_receiver definition deferred.

data: alv_plot_handler type ref to lcl_event_handler_alv_plot.
data: g_event_receiver type ref to lcl_event_handler_alv_plot.
data: prepr_event_receiver type ref to lcl_alv_prepr_event_receiver.

data: frontend_service type ref to cl_gui_frontend_services.

* CONTROLS
data: custom_control_alv type ref to cl_gui_custom_container,
      dialogbox_container  type ref to cl_gui_dialogbox_container.
* ALV
data: alv_plotjobs type ref to cl_gui_alv_grid,
      alv_preprocessor  type ref to cl_gui_alv_grid.

*LAYOUT
data: g_layo_alv_plotjobs type lvc_s_layo,
      ch_layout_prepr     type lvc_s_layo,
      lt_excl_func        type ui_functions.

*DISVARIANT
data:  x_save_alv_plotjobs value 'A'.
data:  gs_layout_alv_plotjobs type disvariant.

*LVC_T_ROW
data: itab_et_index_rows_plotjobs type lvc_t_row.

data: wa_et_index_rows_plotjobs type lvc_s_row.

*FieldKatalog
data: g_fc_grid_plotjobs type  lvc_t_fcat.
data: wa_fc_grid_plotjobs type  lvc_s_fcat,
      fc_alv_preprocessor type lvc_t_fcat.

* TYPES
types: begin of t_count,
  id_plotjob type /cideon/pl_jobsc,
  end of t_count.

* TABLES
tables:
  /cideon/pl_jobs1
  , /cideon/pl_jobs2,
  /cideon/pl_jobs3,
    /cideon/pl_jobs4,
 /cideon/pl_jobss,
 /cideon/pl_jobsc
*,/cideon/v_adm_01
 , /cideon/v_adm_02

 .

* ITAB
*DATA: itab_v_adm_01 TYPE TABLE OF /cideon/v_adm_01.
*
*DATA: itab_count TYPE TABLE OF t_count.
*DATA: itab_v_adm_01_item TYPE TABLE OF /cideon/v_adm_01.
*DATA: itab_plot_item TYPE TABLE OF /cideon/v_adm_01.
*DATA: itab_preprocessor TYPE TABLE OF zcl_preprozessor.

data: itab_v_adm_01 type table of /cideon/_s_adm_01.

data: itab_count type table of t_count.
data: itab_v_adm_01_item type table of /cideon/_s_adm_01.
data: itab_plot_item type table of /cideon/_s_adm_01.
data: itab_preprocessor type table of zcl_preprozessor.

* WA
*DATA: wa_v_adm_01 TYPE /cideon/v_adm_01.
*DATA: wa_tmp_v_adm_01 TYPE /cideon/v_adm_01.
*DATA: wa_count TYPE t_count.
*DATA: wa_v_adm_01_item TYPE /cideon/v_adm_01.
*DATA: wa_plot_item TYPE /cideon/v_adm_01.
*DATA: wa_preprocessor TYPE zcl_preprozessor.
data: wa_v_adm_01 type /cideon/_s_adm_01.
data: wa_tmp_v_adm_01 type /cideon/_s_adm_01.
data: wa_count type t_count.
data: wa_v_adm_01_item type /cideon/_s_adm_01.
data: wa_plot_item type /cideon/_s_adm_01.
data: wa_preprocessor type zcl_preprozessor.


* NORMAL
data: anzahl_items type i.
data: anzahl_jobs type i.
data: index type i.
data: index2 type i.
data: dbcnt like sy-dbcnt.
include /cideon/_konstanten.
*include zcl_konstanten.

include <icon>.

include /cideon/_variablen_plot.
*include zcl_variablen_plot.





*SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-010.
*SELECT-OPTIONS: p_id FOR /cideon/v_adm_01-id_plotjob
*  MEMORY ID /cideon/id_plotjob.
*SELECT-OPTIONS: p_un FOR /cideon/v_adm_01-uname
*  MEMORY ID /cideon/nutzer.
*SELECT-OPTIONS: p_note FOR /cideon/v_adm_01-notiz.
*SELECT-OPTIONS: p_prepro FOR /cideon/v_adm_01-preprocessor
*  MEMORY ID /cideon/preprocessor.
*SELECT-OPTIONS: p_status FOR /cideon/v_adm_01-status
*  MEMORY ID /cideon/status.
*SELECTION-SCREEN END OF BLOCK bl1.

selection-screen begin of block bl1 with frame title text-010.
select-options: p_id for /cideon/pl_jobs1-id_plotjob
  memory id /cideon/id_plotjob.
select-options: p_un for /cideon/pl_jobs1-uname
  memory id /cideon/nutzer.
select-options: p_note for /cideon/pl_jobs1-notiz.
select-options: p_prepro for /cideon/pl_jobs2-preprocessor
  memory id /cideon/preprocessor.
select-options: p_status for /cideon/pl_jobs2-status
  memory id /cideon/status.
selection-screen end of block bl1.

selection-screen begin of block bl2 with frame title text-014.

select-options: p_para1 for /cideon/pl_jobs4-para1.
select-options: p_para2 for /cideon/pl_jobs4-para2.
select-options: p_para3 for /cideon/pl_jobs4-para3.
select-options: p_para4 for /cideon/pl_jobs4-para4.

selection-screen end of block bl2.

*SELECTION-SCREEN BEGIN OF BLOCK blins WITH FRAME TITLE text-015.
*SELECT-OPTIONS: p_insn FOR /cideon/v_adm_01-zclinsname.
*SELECT-OPTIONS: p_insd FOR /cideon/v_adm_01-zclinsdate.
*SELECT-OPTIONS: p_inst FOR /cideon/v_adm_01-zclinstime.
*SELECT-OPTIONS: p_insp FOR /cideon/v_adm_01-zclinsprog.
*SELECT-OPTIONS: p_updn FOR /cideon/v_adm_01-zclupdname.
*SELECT-OPTIONS: p_updd FOR /cideon/v_adm_01-zclupddate.
*SELECT-OPTIONS: p_updt FOR /cideon/v_adm_01-zclupdtime.
*SELECT-OPTIONS: p_updp FOR /cideon/v_adm_01-zclupdprog.
*SELECTION-SCREEN END OF BLOCK blins.

selection-screen begin of block blins with frame title text-015.
select-options: p_insn for /cideon/pl_jobsc-zclinsname.
select-options: p_insd for /cideon/pl_jobsc-zclinsdate.
select-options: p_inst for /cideon/pl_jobsc-zclinstime.
select-options: p_insp for /cideon/pl_jobsc-zclinsprog.
select-options: p_updn for /cideon/pl_jobsc-zclupdname.
select-options: p_updd for /cideon/pl_jobsc-zclupddate.
select-options: p_updt for /cideon/pl_jobsc-zclupdtime.
select-options: p_updp for /cideon/pl_jobsc-zclupdprog.
selection-screen end of block blins.

*ZUSATZ
selection-screen begin of block bl4 with frame title text-013.
parameters:
list_bre like rseumod-tblistbr default '250' no-display,
max_sel  like rseumod-tbmaxsel default '500'. " NO-DISPLAY.
selection-screen end of block bl4.


selection-screen: function key 1.

initialization.
  sscrfields-functxt_01 = text-020.


start-of-selection.


at selection-screen.
  case sscrfields-ucomm.
      when'FC01'.
*     Anzahl der Einträge
*      PERFORM get_data_count.
      perform reload_alv.
      set titlebar 'COUNT_LINES' with anzahl_jobs anzahl_items '' '' ''.
    when 'ONLI'.

      call function 'SAPGUI_PROGRESS_INDICATOR'
           exporting
                percentage = '15'  " Balkenanzeige
                text       = text-040.

      perform reload_alv.

*     Lesen der Benutzereinstellungen
      clear default_data.
      call function '/CIDEON/READ_DEFAULTDATA'
           exporting
                i_batch        = ''
           importing
                o_default_data = default_data.


      clear user_data.
      user_data-uname = sy-uname.


      call function '/CIDEON/READ_USERDATA'
           exporting
                i_default_data = default_data
           importing
                o_user_data    = user_data.


      g_repid = sy-repid.

      user_data-modus = 'NORMAL'.
      authority-check object 'ZCL_PLOT_2'
               id 'ZCL_TA' field sy-tcode
               id 'ACTVT' field 'L0'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
      .
      if sy-subrc ne 0.
      else.
        user_data-modus =  'SUPER'.
      endif.

      init = 'X'.

*     Aufrufen der Anzeige
      call screen 100.

  endcase.




* Include files
  include /cideon/plot_admin_tool000_cla.
  include /cideon/plot_admin_tool000_clp.

  include /cideon/plot_admin_tool000_pai.
  include /cideon/plot_admin_tool000_pbo.

  include /cideon/plot_admin_tool000_for.
  include /cideon/plot_admin_tool000_fr2.
  include /cideon/plot_admin_tool000_fr3.
  include /cideon/plot_admin_tool000_fr4.
  include /cideon/plot_admin_tool000_fr5.
  include /cideon/plot_admin_tool000_fr6.

  include /cideon/plot_admin_tool000_fr7.

include /cideon/plot_admin_tool_f00.
