*&---------------------------------------------------------------------*
*& Modulpool         ZCL_PLINT_DESIGN_007                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Anpassungen:
*           Heiko Hänsel
*           Heiko.Haensel@cideon.de
*-----------------------------------------------------------------------
* Journal
* 01.07.2002 - Designstudien usw.
* 19.07.2002 -
* 22.07.2002 - 2D / 3D
* 17.09.2002 - Verteiler
*    Weiche für Ansteuerung PreProzessor / PostProzessor
* 23.09.2002 - Liste
* 15.10.2002 - Nachbearbeitungen / Übersetzungen
* 03.03.2003 - kleinere Änderungen
*              - Defaultansicht
* 14.03.2003 - Pfade beim Neueinlesen der PreProz. INI
*              werden behalten
* 25.03.2003 - Ansicht der Originaldateien aus Suchliste heraus
* 10.04.2003 - eingecheckte Versionen benutzen
* 16.04.2003 - Anpassungen zu Plotten eines Fertigungsauftrages
* 25.04.2003 - Anpassungen zu Plotten eines Fertigungsauftrages
*              - Folgen / Vorgänge
* 28.04.2003 - Anzeigespalte in Suchgrid
* 05.05.2003   - Bug bei Lesen gespeicherter Suche
* 12.05.2003 - BYPASS für Batch bzw. automatischen Betrieb
* 12.06.2003 - BYPASS für Batch bzw. automatischen Betrieb
* 24.06.2003 - Gruppenverhalten bei WSAPP Selection
*            - Logging
*            - Fehlliste -> Button
* 19.07.2003 - Stempel beim Viewen
*            - Pflegedialoge
* 24.07.2003 - Erweiterung für Willy Vogel
*            - Anmeldung an einem SMB Share
* 06.08.2003 - Integration resultierende Stempeldialoge
* 23.08.2003 - Fehlerbeseitigung Pflegedialoge
* 03.09.2003 - Einbau der Kommunikation über RFC Server
* 08.09.2003 - Defaultdata / Userdata über Struktur definiert
* 23.09.2003 - Fehler bei Converter einlesen
* 26.09.2003 - FB für das Einlesen der Defaulteinstellungen
* 29.06.2003 - Änderung der Stellung REFRESH Button in Plotliste
*            - FB für Einlesen der Nutzerdaten
* 01.10.2003 - Integration für Fertigungsauftragsplot
* 08.10.2003 - Italienisch / Französisch
* 20.10.2003 - Weitergabe Materialnummer
* 30.10.2003 - Verbot des Plot von DIS mit bestimmten Merkmalen
* 03.11.2003 - Dokumentenstückliste auflösen verbessert über BAPI
*            - Zeichnungen zum Dokument holen
* 07.11.2003 - Verteiler ändern auf Einzelanzeige / direkte Übernahme
*              ohne zusätzliches ENTER
*            - Benennung der Deteilansicht
* 12.11.2003 - FTP
*            - Eingabebereite Felder für Normalnutzer bei Kopien etc.
* 22.11.2003 - Einbindung der Pflegedialoge um bei
*              bestimmten Merkmalen im DIS nicht zu stempeln
* 01.12.2003 - Neues Rollenkonzept / einzelne Berechtigungen für Felder
* 04.12.2003 - Probleme mit neuen CLFs
* 06.12.2003 - Einbindung ADMIN MODULE
* 11.12.2003 - Spezialdokumente für Deutz bei Anforderung ohne DIS
* 12.01.2004 - Ausblenden der Felder, die nur für PPL-Anbindung von
*              Interesse sind
* 13.01.2004 - Berechtigung für das Ändern von FAUF / VBELN über Dialog
*            - Änderung der Auftragsnummer in ALV wurde nicht aufgerufen
* 26.01.2004 - Aufrischen der Suchliste neue Buttons
* 29.01.2004 - Berechtigungsprüfung auf statusabhängige Dokumenten-
*              berechtigungen (C_DRAW_TCS)
*              Prüfen auf neuere DIS Versionen
*              Prüfen auf neuere freigegbene DIS Versionen
*              Abfrage der Freigabekennzeichen über Customizing (TDWS)
* 04.02.2004 - Ablage ausgewählter Dateien in einem lokalen Verzeichnis
* 05.02.2004 - Starten der Konvertierung für Auswahl in Plotliste
* 06.02.2003 - Refresh nach einer Konvertierung / Fehlblätter
* 09.02.2004 - Zusammenfassung von PLOT-Buttons
* 16.02.2004 - ENTER in Plot-Einzel-Anzeige aktualisiert die ALV nicht
* 17.02.2004 - Probleme mit DOKNR, falls dort Zahlenbereiche durch
*              Leerzeichen getrennt sind (Diehl Avionik)
* 25.02.2004 - DEBUG-Hilfe einbauen
*              neuer Selectionsscreen für WSAPPLICATION
* 03.03.2004 - Überprüfung, ob eingegebener Verteiler auch wirklich
*              für Nutzer benutzt werden darf
* 05.03.2004 - 'Eigenschaften setzen' ignoriert jetzt LEERWERTE
* 08.03.2004 - Priorität in Plot-ALV setzen per Kontext
* 09.03.2004 - PARAMETER DMS_MAX_TMP_FILES aus Nutzdaten lesen
* 24.03.2004 - Integration Fertigungsauftrag / Druck von Spooldateien
* 02.04.2004 - Berechtigung für Ablage in lokalem Verzeichnis
* 05.04.2004 - Report für Auflösung der Beziehung zwischen Zeichnung und
*              Modell (Netstal) -> Inhaltsverzeichnis
* 06.04.2004 - Neue Meldung bei Verlassen des Programmes
* 14.04.2004 - Anzeige der Inhalts von Spoolaufträgen
* 04.05.2004 - Ausblenden von Anzeigen versuch
* 10.05.2004 - Lesen der Freigabe aus Customizing für
*              Optionsdialog in Suchliste
* 11.05.2004 - Erweiterung der Daten aus Fertigungsauftrag
* 12.05.2004 - Anpassung der Ausgaben auf langsame GUI Verbindung
*              siehe Logon -> Heiko Hänsel
* 22.05.2004 - Versuch: Anpassung der PreProcessorzuordnung auf
*              Rollenzugehörigkeit
* 28.05.2004 - Änderungen an der Basis -> WS_DOWNLOAD ->
*              DSVAS_DOC_WS_DOWNLOAD (Gottwald - große CLF)
*              GUI_DOWNLOAD
* 02.07.2004 - CS Integration
* 05.07.2004 - Änderung auf neue Funktionsbausteine / Batch Fähigkeit
*              Fehler bei werksübergreifenden Materialstatus
*              wurde nicht mehr gelesen.....
* 09.07.2004 - Anpassungen auf FBs für allgemeine Integration
* 19.07.2004 - Anpassungen auf FBs für allgemeine Integration
*              TO_JOBLIST
*              SEND
* 20.07.2004 - SAP Verteiler Integration
* 23.08.2004 - CS Integration / Dokumentationsdruck
*              Konvertierung starten mit Auswahl des Konverters
* 25.08.2004 - Übergabe Storagecategory / CLFs Dateien
* 27.08.2004 - Statustexte werden wieder übergeben
*              Applikationsstart verhindern (Viewend)
* 27.09.2004 - Einlesen der Suchliste / Vornullen /
*              Konvertierungsexit
* 28.09.2004 - Ändern der Verteiler angepaßt / F4-Hilfe
* 30.09.2003 - Verteiler können jetzt gelöscht werden für eine Übernahme
*              eine Transportes
*
* 12.10.2004 - Version 2.0.2.0
*              Nutzereinstellungen werden jetzt auch über die Zuordnung
*              zu entsprechenden Rollen gelesen
* 21.10.2004 - Einlesen der Suchliste / Vornullen /
*              Konvertierungsexit auch für DOKTL, DOKVR
* 21.10.2004 - Ansichten Ausblenden in der Suchliste und
*              in der Plotliste
* 01.11.2004 - Vorbelegung Anzeige der Dynpros
*              KNZ_VIEW_DRAW_DETAIL
*              KNZ_VIEW_STRUC_PLOTLIST
*              Speichern der Nutzerdefinierten Einstellungen
* 22.11.2004 - Speichern der gesendenten Einträge in einer LOG
*              Tabelle und im APPL - LOG
* 05.01.2005 - Ansteuerung aus ZCL_CALL_PLOT_AT_STATUS_CHNG
*              bei Statuswechsel innerhalb eines DIS
* 07.01.2005 - Einbindung der Anzeige des Plot Logs
* 18.01.2005 - variables Trennzeichen bei Suchliste
* 18.01.2005 - FBs für Anbindung der Einzelsignatur als Stempel
*              bei der Ausgabe
* 26.01.2005 - neues Berechtigungsobjekt
*              ZCL_PLOTAU / authorisierte Ausgabe
* 29.01.2005 - Einbindung Audit Trail
* 01.02.2005 - Anpassung Audit Trail / keine weitere Nachfrage
* 30.03.2005 - FIXED : bei Übernahme aus CL30N wurden keine Status-
*              texte etc. übergeben
* 31.03.2005 - Übergabe der Dokumentenbeschreibung in die Plotliste
* 11.04.2005 - LIFNR / NAME1_GP / EBELN
* 13.04.2005 - Sprung in den Quelltext bei Pflegedialogen für
*              Stempelanbindung möglich
*            - Nach ausführen von Aktionen innerhalb der Plotliste
*              bleibt nun die Selektion bestehen
*            - Anpassung Titlebar
* 14.04.2005 - DATEINAME_ZIEL Dokumentationsdruck AMMANN
* 18.04.2005 - AO$_MERGE = =0 / 1 / 2
*              kein / 1.Wert / letzter Wert
*              nur innerhalb der neuen CLF
* 26.04.2005 - Anbindung variable 2D Ableitungssuche / MIKRON
* 27.04.2005
* 10.05.2005 - KNZ_CHECK_EBELN / Delta Upgrade für Lieferanten
*              bei Übernahme aus Bestellung etc.
*              CHECK_EBELN_STRATEGY
*              Delta Update bei Lieferantenanbindung
* 12.05.2005 - Lieferantenadresse etc.
* 13.05.2005 - Integration Stücklistendruck / Material BOM
*              Prioritätenliste der Dokumente bei Bestellung ME22N
* 17.05.2005 - Tabstrip für Lieferantendaten
* 19.05.2005 - EBELN / LIF_TELNR_LONG / LIF_FAXNR_LONG
*              LIF_SMTP_ADDR setzen
*
*              MAT_TDDEST
*              MAT_TDPRINTER
* 14.05.2005 - Spezial: Download von Spooldateien jetzt auch möglich
*              innerhalb der Plotliste
* 15.06.2005 - Variable Stücklistenauflösung auf Materialebene
*              siehe Dokumente spezial
* 20.06.2005 - KNZ_USE_VERT_RIGHTS
*              rechteabhängige Verteiler
* 19.07.2005 - DIR_STAT_VERS in Suchliste
*              Anzeige, neuere Versionen existieren und ob diese
*              möglicherweise freigegeben sind (siehe CDESK)
* 28.07.2005 - Problem bei Übernahme aus Fremdtransaktion/
*              Versionsanzeige wurde nicht aktualisiert
* 28.09.2005 - Flag für Eintrag ins Appl.Log. -> Meldung, falls
*              etwas passiert ist
* 14.11.2005 - Vorbereitung auf XML RPC
*            - Status abgeschaltet "INI Datei Einlesen"
* 22.11.2005 - BADI Implementierung
*              /CIDEON/IF_EX_PRE_MAIN_001->CHG_PLOTLIST_BEFORE_SEND
* 06.12.2005 - Voreinstellungsabhängige Stempel ausschalten
* 10.01.2006 - GUID erzeugen und mitgeben
* 24.01.2006 - Übergabe von EBELN usw. auch für Fehlblätter
* 31.01.2006 - verschiedene BADI Implementierungen bei der
*              Übergabe der Einträge über ZCL_PSB_TMP
* 06.03.2006 - G_DMS_MAX_TMP_FILES schon beim Start lesen
* 16.03.2006 - Plotliste und Plottree werden nur generiert, wenn Sie
*              benötigt werden
* 21.03.2006 - Problem WA_SEARCH bei Dokumentenstückliste wurde nicht
*              gelöscht / B. Krone
* 23.03.2006 - TREE Problem -> wegen Geschwindigkeit
* 24.03.2006 - Korrektur / Tree -> Fertigungsauftragsdruck
*              automatischer Durchlauf
* 30.03.2006 - Weitergabe Änderungsnummer
* 31.03.2006 - Weitergabe Stücklistennummer
* 07.04.2006 - 31. Geburtstag Birgit W.
*              Integration in CC07 (Änderungsdienst Informationssystem)
* 06.07.2006 - BUG:
*              Spooldokumente werden bei Bereinigung (letzte freigebene
*              Versionen anzeigen) aus der Suchliste gelöscht
* 24.07.2006 - Integration von Spooldokumenten / Stücklistenansichten
*              in "Dokumente spezial"
* 01.08.2006 - Geburtstag Anne
*              Übergabe von der Stücklistennummer STLNR bei Recherche
*              über die Auflösung der Stückliste innerhalb der SPSO
* 09.08.2006 - Erweiterung auf Stücklisten Übergabe
*              DIS Schlüssel der obersten Elementes der Dokumenten-
*              Stückliste werden übergeben
*              Kunde: DIEHL Avionik
* 10.08.2006 - neue BADI Methode um die Stempelwerte zu manipulieren
* 16.08.2006 - neue Werte in Konfiguration
*                - KNZ_CREATE_TOC
*                - KNZ_SEND_TOC
* 23.08.2006   weitere Arbeit daran
* 28.08.2006 - Konvertierungen in der Plotliste starten nach Eingabe
*              einer Regel
* 31.08.2006 - Wahlweises Anschalten / Ausschalten des ADMIN Moduls
* 11.09.2006 - 5 Jahre Anschlag auf World Trade Center in NY
*              Erweiterungen:
*              TOC erstellen, Senden, eMail mitgeben,
*              erstmal die eMail Adresse des aktuellen Nutzers
*              Ikonen in den Tabs
* 18.09.2006 - Übergabe der Spool ID in die DOKNR
* 20.09.2006 - Übergabe ohne Setzen der ID .... Batch / Verbuchung
*              manuelles Lesen der Queue
* 17.10.2006 - PSE: K. Mayer
*              Datum der ECN des DIS
*              Gültig ab / Anlage / letzte Änderung
* 03.11.2006 - Anbindung der Eingabe von globalen Notizen über Editfeld
* 06.11.2006 - Lesen der Änderungsnummer bei Übergabe beispoielsweise
*              aus CSMB
* 20.11.2006 - Geburtstag Anja 2x
*              AutoORG -> CIDEON
* 29.11.2006 - Übergabe der Inhalte aus dem Notizeditor
* 08.02.2007 - Übergabe von Informationen für das Fax bei Lieferanten
*              LIF_TEL_NUMBER
*              LIF_TEL_EXTENS
*              LIF_TELNR_LONG
*              LIF_FAX_NUMBER
*              LIF_FAX_EXTENS
*              LIF_FAXNR_LONG
*              LIF_SMTP_ADDR
*              LIF_SMTP_SRCH
*              in den globalen Teil der CLF
*
*            - Fertigungsauftragsintegration
*              Verteiler können werksabhängig benutzt werden
* 12.02.2007 - Integration der Möglichkeit ganze Strukturen
*              auf dem Plotserver auszugeben (Checkout mit Struktur)
*              Hintergrund: Borealis - native Konvertierung vor dem
*              Plotten mit AutoCAD Dateien+X-Refs
*            - Pflegedialog für Z_MAINT_ZCL_FAUF_WERK_VE
*              werksabhängige Verteiler im Fertigungsauftrag
*            - Pflegedailog für /CIDEON/MAINT_WSA_DOWN
*              Ausgabe von ganzen Strukturen siehe BOREALIS
*
* Version 3.0.4.1
*            - Auslieferung wegen der Verzahnung der Pakete
*              mit Fertigungsauftrag
*
* 13.02.2007 - Integration der Pflegedialog
*              - Z_MAINT_ZCL_FAUF_WERK_VE
*              - /CIDEON/MAINT_WSA_DOWN
*              Einlesen von Verteilern ohne Reprocl.ini und
*              Verbindung zum PLotInfo Server ->
*                Notfallmodus
* 23.02.2007 - Versenden von Expressmails nach dem Druck von Bestell
*              Papieren
*            - KNZ_EBELN_EXPRESSMAIL
*            - KNZ_EBELN_POS
*            - KNZ_EBELN_MAT
*            - KNZ_EBELN_BOM
*            - KNZ_EBELN_DIALOG
*              Übergabe der Positionsnummer aus dem Druck der
*              Einkaufsbelege
* 20.03.2007 - Übergabe von Markierungen für Selektion
*              Realisierung über BADI
* 07.05.2007 - SP 38
*              Integration von Verkaufsbelegdaten
*              Eigenener Reiter
*              - VBELN
*              - Type der VBELN
*              - VBELN - Debitor etc.
* 07.06.2007 - SP 40
*              Update Integration Berechtigungsobjekte DMS
* 14.07.2007 - SP 42
*              Vermessungsintegration
* 19.06.2007 - C_DRAW_STA aus /CIDEON/CLEAN_UP_DOCUMENTS_2
*              wieder ausbauen
* 01.08.2007 - SP 44
*              Integration VBELN POSNR
* 03.08.2007 - Layout für SD Partnerliste speicherbar und
*              als Default zu setzen ..
*            - Falls keine DIS in Suchliste markierte sind, so werden
*              bei der Auswahl alle in die Plotliste übergeben
*              Analog dazu wird auch die Plotliste verarbeitet
*            - BUG mit Lieferantenupdate beseitigt
* 06.08.2007 - SP 45
*              Erweiterung der Stücklisten/ Material Auflösungs
*              dialog
*              Suchdialog für Dokumente über CV04N innerhalb der
*              Auflösung der Dokumentenstückliste
*              DEFAULT_VERTEILER_MDR
* 09.08.2007 - Laden von Dokumenten aus der Zuordnung zu einer
*              Materialliste
* 14.08.2007 - SP 46
*            - Plotten ohne DIS - Einfügen des Eintrages nach der
*              Markierung in der Suchliste
* 15.08.2007 - Notiz DIS erstellen
* 22.08.2007 - F_DYN_TOC
*              Ausgabe aus Suchliste - Schnellausgabe
* 19.09.2007 - SP 50
*              Prio bei WSA / Übernahme in Plotliste
* 15.10.2007 - SP 51 / 3.0.4.2
*              Änderungssnummer innerhalb des Plot LOGs
* 17.10.2007 - 3.0.4.3
*              Abfrage beim Verlassen auf NEIN gesetzt und Hinweis
*              auf den Verlust der Selektion in der Suchliste
* 06.11.2007 - SP 53 /
*              Speichern der Plotliste umgestellt
*              lesen über Komponentenzuordnungen...
* 13.11.2007 - SP 56
*              Update Tracking
* 12.12.2007 - SP 61 / 3.0.4.6
* 03.01.2008 - SP 62 / 3.0.4.7
*              Vorbereitungen für Erstellen von DIS aus Spooleinträgen
*              für die Integration in einkaufstransaktionen
*              /CIDEON/MNT_CIDEON_PL_LOG Anpassungen für Bestätigung
*              eines gesamten Jobs
*              Doppelklick selektiert ganzen Job (wieder ausgebaut)
*              Abfrage ob Aktion für gesamten Job durchgeführt
*              werden soll
* 09.01.2007 - 3.0.4.8
*              Noske/Kaeser
*              Verlust der Markierung nach Ansicht eines DIS
* 17.01.2008 - 3.0.4.9 / Walter AG
*              /CIDEON/S_ENHC_TRANSFER_01 Erweiterung um 4
*              freie Parameter
*              Selektion für Suchliste setzen / Merken bei Übergabe
*              ALV Buttons mit Menü und Default Button
* 21.01.2008 - 3.0.4.10
*              Separieren von Ausgaben nach EBENL, VBELN
*              BADI Verkauf VBELN  analog EBELN
* 23.01.2008 - SP 64   3.0.4.12
*              BUG ALV-> Buttons nicht mehr ausklappbar
* 06.02.2008 - SP 65   3.0.5.1
*              Umbau auf CIDEON Namensraum
*-----------------------------------------------------------------------
* to do
*             - Transaktion für Parameterdialog
*               - Tabstrips /
*
*             - KNZ_EBELN_DIALOG
*             - KNZ_EBELN_BOM richtig integrieren
*
*             - Beschreibung der Parameter ergänzen
*             - Erfolgsmeldungen einfügen
*                * Erfolgsmeldung
*                  MESSAGE s000(/cideon/plot_basis)
*                    WITH '' '' '' ''.
*                   Änderung ist erfolgt. & & & &


*             - statische Suchliste
*             - Suchliste (Einfügen, Verschieben)
*             - Klassifikationsintegration
*             - Gruppenabhängige Stempel

*             - 0125
*                   LIFNR / NAME_LIFNR in die Screenattribute bringen
*             - Materialstücklistendruck direkt einfügen


*             - Anpassung des Views für Plot Operator durchführen
*               4096 Grenze / LIF-Felder
*

*              - Stücklistendruck in
*	          - PSB
*	          - Plot Interface
*              - Rangfolge
*	           - was soll passieren, wenn nur Dokumente vorhanden,
*                   die nicht in der Rangfolgeliste stehen
*		        - ignorieren
*		        - übernehmen
*              - BADI an verschiedenen Stellen integrieren lassen
*                (vor dem Senden, vor der Plotliste, etc.)
*             - Plotten in cFolders

*             - Plotten in Tabelle und holen der Informationen von Außen
*               siehe neuer Konvertierungsserver
*             - NO-CHECKOUT
*-----------------------------------------------------------------------



*TOP Include
include zcl_plint_design_007top.
*INCLUDE <icon>.
include zcl_plint_design_007ver.


* Klassenvereinbarungen
include zcl_plint_design_007_classes.
include zcl_plint_design_007_class_s.
include zcl_plint_design_007_class_p.
include zcl_plint_design_007_class_t.



*PBO
include zcl_plint_design_007o01.
include zcl_plint_design_007o101.
include zcl_plint_design_007o102.

*PAI
include zcl_plint_design_007i01.


*Tools
include zcl_plint_design_007_tools.

*FUNCTIONS
include zcl_plint_design_007f01.
include zcl_plint_design_007f02.
include zcl_plint_design_007f03.
include zcl_plint_design_007i04.
include zcl_plint_design_007f04.
include zcl_plint_design_007o02.
include zcl_plint_design_007f05.
include zcl_plint_design_007f06.
include zcl_plint_design_007f07.
include zcl_plint_design_007f08.
include zcl_plint_design_007f09.
include zcl_plint_design_007f10.
include zcl_plint_design_007f11.
include zcl_plint_design_007f12.

include zcl_plint_design_007f13.

include zcl_plint_design_007f13_pbo.

include zcl_plint_design_007f14.

include zcl_plint_design_007f15.
