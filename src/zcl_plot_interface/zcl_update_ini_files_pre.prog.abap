*&---------------------------------------------------------------------*
*& Modulpool         ZCL_UPDATE_INI_FILES                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 08.04.2003 Transport Eigenschaften
* 03:09:2003 RFC Einträge
* 12.11.2003 FTP
* 30.09.2003 Verteiler können jetzt gelöscht werden für eine Übernahme
*            eine Transportes
* 22.03.2005  - UNICODE
* 17.11.2005 - Anbindung PlotInfoServer via XML RPC
* 02.12.2005 - COMMIT Problem bei SAP DB
* 13.12.2005 - Pfade lesen bei Auswahl PreProcessor
* 14.12.2005 - Sicherheitsabfrage beim Löschen
* 13.02.2007 - Update der Verteiler ohne REPROCL.INI und
*              Verbindung zum PlotInfo Server
*              Änderung Schaltflächen
* SP 134
* 20.10.2010 - CKR
*              Bug 3015
*              Übersetzung
*              Unter INI-Datei einlesen -> Löschen Verteiler vs. Löschen
*              PreProcessor
*
* SP 138
* 29.10.2010 - CKR
*              Umbau der Verteilerlogik / temp. Tabelle übergehen
*
* 7.0.139.2  - CKR
*              SR 10462  Titel für INI PreProcessor
*              MP ZCL_UPDATE_INI_FILES_PRE
*
* 24.01.2011 - CKR
* 7.0.146.2
*              SR 11098 "PreProcessor löschen" ohne Funktion
*              ZCL_UPDATE_INI_FILES_PRE
*
*-----------------------------------------------------------------------


include zcl_update_ini_files_pre_top.

include zcl_update_ini_files_pre_o.

include zcl_update_ini_files_pre_i.



* call screen 100.

include zcl_update_ini_files_pre_f.
