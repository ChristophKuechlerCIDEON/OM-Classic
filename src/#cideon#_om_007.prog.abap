*&---------------------------------------------------------------------
*
*& Modulpool         /CIDEON/_OM_007
*
*&
*
*&---------------------------------------------------------------------
*
*&---------------------------------------------------------------------
*
* CIDEON SAP Plotting Interface
*
*----------------------------------------------------------------------
* Author :  C. Küchler
*
* Anpassungen:
*           H. Hänsel
*           Dr. P. Rabe
*           M. Bartsch
*
* Kontakt über:   https://service.cideon.com
*                 HELPDESK@CIDEON-SOFTWARE.DE
*
*----------------------------------------------------------------------
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
*            - Änderung der Auftragsnummer in ALV wurde nicht
*              aufgerufen
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
* 05.04.2004 - Report für Auflösung der Beziehung zwischen Zeichnung
*              und
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
* 30.09.2003 - Verteiler können jetzt gelöscht werden für eine
*              Übernahme
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
* 24.01.2006 - Übergabe vosn EBELN usw. auch für Fehlblätter
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
* 08.02.2008 - SP 66 3.0.5.2
*              weiterer Umbau
* 14.03.2008 - 3.0.5.3
*              cFolders Integration
* 15.03.2008 - cFolders in BADI
* 08.04.2008 - SP 72  3.0.5.4
*              Einkauf
*              BADI Integration in /CIDEON/PLOT_ME_FM06PE02
* 12.06.2008   SP 075 3.0.5.5
*            - Test mit vorausgewählter Option
* 16.06.2008   3.0.5.6
*              bei KNZ_COPY_ORIGINAL = 'X' keine Prüfung auf
*              DMS_MAX_TMP_FILES
* 16.07.2008 - 3.0.5.7
*              Setzen des Verteiler, trotz leerer WA
* 13.09.2008   3.0.5.8
*            - Anzeige der Dateien aus der Plotliste über das Standard-
*              Customizing
*              Möglichkeit doppelte Einträge innerhalb der Plotliste zu
*              bereinigen
* 18.09.2008 - SP 76
*              7.0.0.1
*              BUG: 5082
*              Übergabe KNZ_USE_MULTIPAGE
*              7.0.0.2
*              Anzeige über Original Viewer
*              KNZ_PL_NO_DOUBLE
*              keine Dupplikate innerhalb der Plotliste bei der
*              Übernahme aus der Suchliste in die Plotliste
* 27.10.2008 - SP 84
*              7.0.0.3
*              BADI Einsprung für erweiterte Such über Materialnummer
* 10.11.2008 - SP 85
*              7.0.0.4
*              BADI für Bearbeitung der Plotliste bei Übergabe
* 11.11.2008 - SP 86
*              7.0.0.5
*              BUG 4543
*              Problem beim Speichern der Fehlblattliste
* 05.12.2008 - SP 87
*              7.0.0.6
*              Ausblenden von IKONEN im ALV fest im Quelltext
* 11.12.2008 - 7.0.0.8
*              Sortieren den Verteiler in der Auswahl
* 27.01.2008 - SP 88
*              7.0.0.9
*              Integration f_bypass_to_plotlist um in Plotliste
*              stehen zu bleiben bei f_bypass
* 02.03.2009 - SP 89
*              7.0.0.10
*              Parameter setzen von Außen:
*              /CIDEON/OM_use_filt
*              /CIDEON/OM_lt_wsa
*
*              SP 90
*              7.0.0.11
*              BUG: Laden des Status in Plotliste
* 23.04.2009 - SP 92
*              7.0.0.12
*              Unterscheidung zwischen SAP Konvertierung und CE
*              Konvertierung
*              Beauftragung von Konvertierung durch CE
*                - aktueller Status
* 07.05.2009 - Beachtung von gültigen Versionen auf Grund von
*              Änderungsnummer und Datum / Freigegebene in Menü
*              Optionen
* SP 93
*              Faxnummer verschlang Vornullen
*
* 24.07.2009 - SP 97
*              BADI chg_conf_before_send
*
* SP 100
*            - Seitenzahlen
* SP 102
* 14.08.2009 - Problem: KNZ_SINGLE_CLF -> gleicher Timestamp für
*              CLF Dateien, weil Erstellung < 1 Sekunde
* SP 103
* 02.09.2009 - /CIDEON/MATNR_MAT_BOM_PRINT
*              Übergabe der Fehlermeldung
* BUG   7267
*
*              BADI Anbindung kleiner Druckdialog / Sulzer
* SP 104
* 07.09.2009 - Satzanzahl in CLF
*              ZCL_PROC_SKEL_GHEAD_CLF10
*              Parameter DEFAULT_SATZ_ANZAHL
*              DEFAULT_KOPIEN als Nutzervariable
*              DEFAULT_PRIO als Nutzervariable
*
*              Zusammenfügen der Dateien zurücknehmen
*
* 08.09.2009 - ZCL_UPDATE_INI_FILES_PRE
*              IP Adresse vorbelegen
*
* 11.09.2009 -
*
* SP 104
* 25.09.2009 - Mitgabe der Materialnummer -> Rademaker
*
* 28.09.2009 - /CIDEON/MAT_BOM_POSITION2
*              Auflösung der Materialstückliste auf mehr als
*              3 Ebenen freigegeben -> Rademaker
*              Beachtnun der im OM konfigurierten Anzahl der Ebenen
*
*              Satzanzahl für Druck
*
* 29.09.2009 - /CIDEON/PSBRW_OBJ_RELEASE_FRTA
*              ccdat in der Übergabestruktur /CIDEON/S_ENHC_TRANSFER_01
*              "Dokumente spezial" beachtet jetzt auch für die
*              Stücklistenausgaben das Gültigkeitsdatum
*
* SP 105
* 01.10.2009 - KNZ_COPY_ORIGINAL
*              ZCL_GET_DOC_CLF10_DETAIL_DLOAD auf GUID umgestellt
*
* 02.10.2009 - BADI /CIDEON/PRE_MAIN_001
*              ADD_CUSTOMER_FIELDS_SEARCHLIST
*              Kundeneigene Felder in der Suchliste integrieren
*
* 05.10.2009 - /CIDEON/MAT_BOM_POSITION2
*              CS03 - Benutzung der Verwendung
*
*              BADI /CIDEON/PRE_MAIN_001
*              CHG_PLOTLIST_AFTER_SEND
*              -> Corden Pharma
*
*              BADI /CIDEON/PRE_MAIN_001
*              CHG_FAUF_CHARGE
*              -> Corden Pharma
* SP 104
* 06.10.2009 - Umstellung auf Anzeige des Journales über INFO Menü
*
* SP 107
* 09.10.2009 - /CIDEON/PSBRW_OBJ_RELEASE_FRTA
*              Freigabe für Lieferplan ME38
*              -> B. Krone
* SP 108
* 12.10.2009 - chg_plotlist_after_send
*              Problem beim Ändern der Plotliste
*              -> Corden Pharma
* SP 109
* 27.10.2009
*            - SEND
*              chg_plotlist_before_send
*              um Rückmeldung erweitern
*              und Abbruch ermöglichen
*
* SP 110
* 28.10.2009
*            - SEND
*              chg_plotlist_before_send
*              Flag, ob Message ausgegeben werden soll
* SP 111
* 29.10.2009
*            - SEND
*              chg_plotlist_before_send
*              Flag, ob Message ausgegeben werden soll
*              Fehlerbeseitigung / Optional Flag
* SP 112
* 30.10.2009 - Verteiler Multipage
*              Tabelle: /CIDEON/VERT_MP
* 02.11.2009 - Pflegedialog /CIDEON/MAINT_VERT_MP
*              Einbau ins OM unter Konfiguration 3
*
* 04.11.2009 - Stempelwert
*              /CIDEON/GUID32 erstellt Stempel mit 32 GUID
*
* SP 113
* 27.11.2009 -
*              ZCL_PROCESS_CLF_DLOAD
*              Anpassungen, daß falls AO$_MERGE gesetzt ist,
*              daß dann dieses in die
*              Gruppe übernommen wird
* SP 114
* 7.0.0.13
* 10.12.2009 - Satzanzahl
* 16.12.2009 - PDF Spool berücksichtigen
*              /CIDEON/OTF_2_PDF
*              BADI /CIDEON/PRE_MAIN_001
*              Methode CHG_SPOOL_PROCESSING
* 18.12.2009
*
* SP 115
* 11.01.2010 - /CIDEON/GET_LIFNR_DATA
*              Übernahme der normalen Faxnummer, falls
*              lange Faxnummer nicht vorhanden
*
* 12.01.2010   /CIDEON/DRUCK_ANSTEUERUNG
*            - Multipage
*              - für einzelne Intervalle
*              - Nutzerdefaults
*              - Tabelle mit Verteilern
*
* 13.01.2010 - Anpassung der Seitenverarbeitung auf
*              analoge Verarbeitung, wie innerhalb des
*              kleinen Druckdialoges
*              -> nur noch SEITE_VON / SEITE_BIS
*
*              - SR 4527
*
* 7.0.1.13
* 18.01.2010 - Invertieren der Reihenfolge innerhalb der
*              Plotliste
*              -> CONCAST
*
* SP 116
* 7.0.1.14
* 22.01.2010 - RGG / Welser
*              /CIDEON/ASK_FOR_LIF_FAXNR_LONG
*              FAX Nummer nicht mehr in internes Format konvertieren
*              Externes Format für DOKNR in Plotliste
*
* SP 117
* 7.0.1.15
* 25.01.2010 - SR
*              Borg Warner
*              Problem, daß hier das Auschecken mit Struktur, wegen
*              einer nicht vorhandenen Berechtigung auf die Stückliste
*              fehlschlägt.
*              Für diesen Kunden ist die Stücklliste nicht notwendig.
*              Änderung der Checkoutparameter
*              0 = nur angegebene Datei
*              1 = angegebene Datei + erste Ebene unter Datei
*              2 = angegebene Datei + alle Ebenen darunter
* 7.0.1.16
* 27.01.2010 - Änderung des Operationsmodus in der Plotliste möglich
*              Umschalten zwischen normalem Modus und Plotoperator
*              -> Idee USZ
* 7.0.1.17
* 28.01.2010 - AO$_JOBCOUNT
*              ZCL_PROC_SKEL_GHEAD_CLF10
*              PrePro 7.6.0.48 notwendig
*
*              Zuordnung zum OM Ändern
*
* SP 118
* 7.0.1.18
* 02.02.2010 - KNZ_MULTIPAGE
*              JLN:
*              KNZ_MULTIPAGE wird nach Benutzung von
*              verteilerabhängigen
*              Einstellungen nicht wieder auf den Default zurückgesetzt
*
*              Verteiler über Schaltfläche in der Plotliste Ändern
*
* SP119
* 7.0.1.19
* 16.02.2010 - CONCAST
*              Reaktion auf nicht zugreifbare Dateien aus dem CS
*              -> Fehlblattgenerierung
*
* 7.0.1.20
* 18.02.2010 - Übergabe der Materialnummer aus dem PSB
*              Umbau auf /CIDEON/PSBRW_WRT_PSB_TMP_FRTA
*              in Z_CL_PSBRW_WRITE_PSB_TMP
*              KMO
*
*              Einbau der Auflösung mit Stufe
*              -> Dokumente Spezial -> Zeichnungen laden (Standard)
*
* SP120 / 121
* 7.0.1.21
* 22.02.2010 - /CIDEON/LPLOT_TOOLSF01
*              form get_local_work_path
*              Problem bei Aufruf CALL TRANSACTION mit MODE
*              -> GUI Services schlagen fehl
*              -> Service ausgebaut
*              Trumpf
*
* SP122
* 7.0.1.22
*            - Verschieben der Schlatflächen in der Plotliste:
*              Reihenfolge invertieren
*              OP Modus
*              nach "Spezial"
*
* 7.0.1.23   - SR 8516 - Purchase Order - Default Distributor
*              HST
*            - /CIDEON/PSBRW_OBJ_RELEASE_FRTA
*
* SP 124
* 7.0.124.1
* 05.05.2010
*             DELETEVALUE Löschenkennzeichen bei doppelten Einträgen
*             SR 8463
*             Aktivieren von "doppelte Einträge entfernen" bei
*             "Zeichnungen laden (variabel) / Material" führt zum
*             Verschwinden kompletter Einträge
*
* 7.0.124.2
* 10.05.2010 - CKR
*              Problem bei KEY für /CIDEON/VERT_MP
*
* SP 125
* 7.0.125.1
* 27.05.2010 - CKR
*              J.K. / UGR / Metso
*              Berechtigungsprüfung für DIS ausschalten
*              FB /CIDEON/CLEAN_UP_DOCUMENTS_2
*              -> BADI
*              CHK_AUTH_C_DRAW_BGR    Check auf C_DRAW_BGR
*              CHK_AUTH_SPECIAL  Check auf Spezialberechtigungen
*
* SP 127
* 7.0.127.1
* 16.06.2010 - CKR
*              RELIANCE -> BADI für Schaltflächen in ALV
*              Suchliste / Plotliste
*              BADI /CIDEON/PRE_MAIN_001
*                CHG_PL_EXCL_BT
*                CHG_SL_EXCL_BT
*
* 7.0.127.2
*                CHG_PL_GLOBAL  Ändern Plotliste GLOBAL -> Splitten
*
* 7.0.127.3
*             FILE_SIZE integriert, um Behandlung, wie beispielsweise
*             das Splitten nach Dateigröße zu ermöglichen
*
* 17.06.2010 - CKR
* 7.0.127.4    Meldung beim Senden unterdrücken, falls der BADI
*              mehrmals
*              durchlaufen wird
*
*              Anpassung des Journales
* SP 128
* 7.0.128.1  - CKR
*              Nummerierung in der Plotliste falsch nach BADI
*              -> Manz / RGG
* SP 130
* 02.07.2010
* 7.0.130.1  - Anpassungen nach Änderung von /CIDEON/_VARIABLEN_PLOT
*              an den abhängigen Programmen
*
* SP 131
* 7.0.131.1
* 14.07.2010  - CLF Counter -> Problem mit Timing
*              sehr schnelles SAP System / Bennennung des
*              Jobs mit Sekunden + Zähler reicht nicht aus
*              da Zähler durch Splitting auf 1 verbleibt
*              RGG / Rössler
* SP 132
* 7.0.132.1
*
* 23.08.2010  - CKR
* 7.0.132.2
*              PF only_free_version nach only_released_version
*
* 13.09.2010 - CKR
* 7.0.132.3    VORNR übertragen aus Fertigungsauftrag ->
*              für Spooldokumente
*              -> RGG / KUMBA
*              /CIDEON/READ_STORED_SEARCH
*
* 21.09.2010 - CKR
* 7.0.132.4    TCODE Übergabe
*              /CIDEON/PSBRW_WRT_PSB_TMP_FRTA
*
* 04.10.2010  -  MBH
* 7.0.132.5      BAdI Implementierung nach dem Senden
*                Löschen der Such- und PLotliste, Verlassen des Programs
*
* SP 133
* 07.10.2010 - CKR
* 7.0.133.1    CLF gerät bei mehr als 1000 Einträgen / DIS durcheinander
*              MANZ /
* SP 134
* 7.0.134.1  - CKR
*              Erweiterung /CIDEON/S_ENHC_TRANSFER_01
*              Rademaker
*              PARA 5 - 8 / CUSTOMER / PROJ_NR
*
* 7.0.134.2  - MBH
*              Beim Update der VerteilerListe im Emergency Mode kann
*              jetzt auch die Beschreibung des Verteilers editiert
*              werden.
*
*              Erweiterung der Suchhilfe zur Auswahl des Preprozessors
*              um die Beschreibung des Verteilers
*
* 7.0.134.3 - CKR
* 21.10.2010  Übergabe der Daten bei erneutem Druck aus PlotLOG
*             FUNCTION '/CIDEON/READ_STORED_SEARCH'
*
*             ID_REF  /CIDEON/ID_PLOTLOG_REF
*             ID_PLOTJOB_REF  /CIDEON/ID_PLOTJOB_REF
*             ID_PLOTJOB_32_RE  /CIDEON/ID_PLOTJOB_GUID32_REF
*
*              SR 10377 - erneuter Start der Ausgabe aus dem PlotLOG
*
* 7.0.134.4 - MBH
*
* 7.0.134.5 - CKR
*             Anpassung von Feldübergaben aus PlotListe
*             FB /CIDEON/PSBRW_WRT_PSB_TMP_FRTA
*
* 7.0.135.1 - CKR
*
* SP 136
* 26.10.2010 - CKR
* 7.0.136.1    Übergabe von Informationen
*              /CIDEON/MAP_INFORMATION
*              /CIDEON/MAP_INFORMATION_FAIL_D
*              Einführung eines MOVE-CORRESPONDING
*              Teile der ZORI_DOC_FILES wegspeichern
*
* SP 137
* 26.10.2010 - CKR
* 7.0.137.1    BADI für Ausblenden der Erfolgsmeldung
*              KUMBA
*              /CIDEON/PRE_MAIN_001
*              SKIP_MESSAGE_AFTER_SEND
*
* SP 138
* 29.10.2010 - CKR
* 7.0.138.1    ZCL_UPDATE_INI_FILES_PRE
*              beim Verteilereinlesen wir die temp. Tabelle
*              ReproCl.ini nicht mehr benutzt
*              Ein Update wird direkt ausgeführt
*
*              Die Beschreibung der Verteiler wird automatisch
*              übernommen.
*
* SP 139
* 04.11.2010 - CKR
* 7.0.139.1    Erweiterung /CIDEON/S_ENHC_TRANSFER_01
*              SERNR
*              EMITEC
* 7.0.139.2  - CKR
*              SR 10462  Titel für INI PreProcessor
*              MP ZCL_UPDATE_INI_FILES_PRE
*
*
* SP 141
* 09.11.2010 - CKR
* 7.0.141.1    BADI für Übergabe von Kundeneingenen Feldern
*              ZAPPEND in /CIDEON/S_ENHC_TRANSFER_01
*
*              BADI
*                /CIDEON/PRE_MAIN_001
*                CHG_STOR_SRC_ITEM
*              Änderung des Eintrages bei Lesen der Übergabe
*
* SP 142
* 30.11.2010 - CKR
* 7.0.141.2    Berechtigung für Spezialdokumente SPZ
*              ausschalten
*              /CIDEON/MAKE_AUTH_CHECK_WS
*
* 15.12.2010 - CKR
* 7.0.142.3    Integration der /CIDEON/S_ENHC_TRANSFER_02
*              Zugriff auf Dokumente per URL
*              DEMAG Cranes
*
* 16.12.2010 - CKR
* 7.0.142.4    Integration der /CIDEON/S_ENHC_TRANSFER_02
*              /CIDEON/READ_STORED_SEARCH
*
* 22.12.2010 - CKR
* 7.0.142.5    URL Integration in ZCL_GET_DOC_CLF10_DETAIL_DLOAD
*
* 14.01.2011 - CKR
* 7.0.144.1    URL Integration in ZCL_GET_DOC_CLF10_DETAIL_DLOAD
*              Reaktion auf URL wo keine Datei angegeben ist1
*              ... dds.getPDF?IdentNr=12423
*              BADI Integration
*              Umstieg auf GUID
*
* 18.01.2011 - CKR
* 7.0.145.1    Anpassung
*              /CIDEON/_WRT_PSB_TMP_SD_CS
*              Übergabe eines gesonderten Verteilers
*
* SP 146
* 24.01.2011 - CKR
* 7.0.146.1
*              /CIDEON/TMP_GUI_GET_FILE_EXIST
*              Test für Zugriffsbeschleunigung über
*              CL_GUI_FRONTEND_SERVICES
*
* 7.0.146.2
*              SR 11098 "PreProcessor löschen" ohne Funktion
*              ZCL_UPDATE_INI_FILES_PRE
*
* 7.0.146.3
*              SR 11048 Deutsche Menutexte Spezial - Output to cFolders
*              FB /CIDEON/CFX_EXPORT_OM_01
*
* 08.02.2011 - CKR
* 7.0.146.4
*             BSTYP
*             BSART aus der EKKO integrieren
*
* 7.0.146.5
*             Löschen in Tabelle ZCL_PSB_TMP2
*             FB /CIDEON/READ_STORED_SEARCH
*
* SP 147
* 25.02.2011 - CKR
* 7.0.147.1   /CIDEON/DRUCK_ANSTEUERUNG
*             Übergabe der Materialnummer im kleinen Druckdialog
*             SR 11211 Beim kleinen Druckdialog wird keine verknüpfte
*             Materialnummber übergeben
*
* 07.03.2011 - CKR
* 7.0.147.2   SH ZCL_SH_PARAMETER_WERTE
*             SR 10939 Kurzdump bei Ausführen der F4 Hilfe in Parametern
*             PRG ZCK_MAINT_ZCL_PLINT_CFG_00
*
* 7.0.147.3    SR 11142 Empty Spool ID tranferred to OCC
*              bei leere ID, wird jetzt der Eintrag in die Tabelle
*              verweigert
*              FB Z_CL_INT_WRITE_PLOT_PSB_SPOOL
*
* 17.03.2011 - CKR
* 7.0.147.4    Anpassung für Jindal im Plotlog
*               LIF_SMTP_ADDR  AD_SMTPADR in
*
* 7.0.147.5   - CKR
* 12.04.2011   FB /CIDEON/DRUCK_ANSTEUERUNG
*              Satzanzahl
*              Kopienanzahl
*
* 7.0.148.1  - CKR
* 14.04.2011   /CIDEON/S_ENHC_TRANSFER_02 Erweiterung
*              PZLFH und PSNFH
*
* 7.0.148.2  - CKR
* 18.04.2011   Setzen der Satzanzahl in FB /CIDEON/_WRT_PSB_TMP_SD_CS
*
* 7.0.148.3    Übergabe von NR_COPIES aus Baustein
*              FB /CIDEON/ADD_TO_PLOTLIST
*              Mapping auf Feld Kopien, falls gefüllt
*
* 7.0.148.4
* 19.04.2011 - CKR
*              Notiz Feld in ZCL_PDM_EXP_OBJECTS
*              Übergabe jetzt möglich aus Schnittstelle
*
* 7.0.148.5    Felder in /CIDEON/_S_ADM_01 integriert zur Anzeige
*              PMODE DRART KTEXT SELPR TCODE
*
* 7.0.150.1
* 06.05.2011 - CKR
*              Integration des Dokumentenstatus in PlotLOG
*              -> HST -
*
* 7.0.151.1    CKR
* 20.05.2011 - Anpassungen Plot Operator
*              Einbau von Ikonen, welche den Status des Jobs anzeigen
*              Anzeige des Originales per Hotspot
* 7.0.151.2     Satzanzahl editierbar in Plot Operator
*
* 23.05.2011 - CKR
* 7.0.151.3    /CIDEON/CLEAN_UP_DOCUMENTS_2
*              Einbau einer BADI Implementierung, welche eine nutzer
*              definierte Berechtigungsprüfung zuläßt und einen
*              Austausch von Positionen
*              BADI /CIDEON/PRE_MAIN_001
*              Methode CHG_AT_AUTH_CHECK
*              Manz IP Konzept
*
* 7.0.152.1
* 7.0.152.2 - CKR
*             FB /CIDEON/OTF_2_PDF
*             Setzen des Status eines Spoolsjobs auf Verarbeitet
*
* 7.0.152.3
* 07.06.2011 - CKR
*              Anpassungen PlotOperator /CIDEON/PLOT_ADMIN_TOOL_000
*              Parameter editierbar im ALV
*
* 7.0.153.1
* 14.06.2011 - CKR
*              /CIDEON/S_ENHC_TRANSFER_02 REVLV
*              Anzeige der Revision HST
* 7.0.153.2
* 24.06.2011 - CKR
*              Dokumentenstatus und Beschreibung auch in kleinem
*              Druckdialog
*
* 7.0.154.1
* 26.06.2011 - CKR
*              Einbau des Sendens der CLF über einen BADI parallel zu
*              dem Senden zum Plot Operator
*              Möglichkeit der Anbindung an OM 7.5 / 8.0
*              BADI /CIDEON/PRE_MAIN_001
*              Methode SEND_TO_BADI
*
* 7.0.155.1
* 28.06.2011 - CKR
*              Integration in Kleinen Druckdialog
*              FB /CIDEON/DRUCK_ANSTEUERUNG
*              Einbau des Sendens der CLF über einen BADI parallel zu
*              dem Senden zum Plot Operator
*              Möglichkeit der Anbindung an OM 7.5 / 8.0
*              BADI /CIDEON/PRE_MAIN_001
*              Methode SEND_TO_BADI
*
* 7.0.156.1
* 08.07.2011 - CKR
*              SM 8000002953
*              Manz
*              FB /CIDEON/OTF_2_PDF Vermeidung der Abfrage, bei einer
*              Ausgabe von mehr als 99 Seiten im PDF
*
* 7.0.157.1
*              FB /CIDEON/OTF_2_PDF
*
* 04.08.2011
* 7.0.158.1
* SR 8000003051  ADD_CUSTOMER_FIELDS_SEARCHLIST
*
* 7.0.159.1
* 2012/02/15
* BUG 8046
* Nicht alle Originale werden im Control Center von der Such
* in die Plotliste übernommen
* FB Z_DMS_PROC_DOC_FILES
*
* 7.0.160.1
* 2012/03/01
* BUG 8046
* Nicht alle Originale werden im Control Center von der Such
* in die Plotliste übernommen
* FB Z_DMS_PROC_DOC_FILES
*
* 7.0.161.1
* 2012/05/15
* Anpassung der Plotliste nach dem Senden, BUG, daß nach dem Senden die
* Liste unnötigerweise bereinigt wird
*
* 7.0.163.1
* 2012/08/07 CKR und MBH
* Z_DMS_PROC_DOC_PLOT_NEW1 SM  8000008762 DEUTZ
* Anpassung für ECC 6.0 EHP 6
*
* 7.0.164.1
* 2012/08/08 CKR und MBH
* Anpassung für ECC 6.0 EHP 6
* Alle SHIFT xxxx LEFT DELETE LEADING 0 auf
*      SHIFT xxxx LEFT DELETE LEADING '0' geändert
*
* 7.0.165.1
* 2012/08/17 CKR
* Anpassung kleiner Druckdialog für DEMAG CRANES
* FB /CIDEON/CALL_DRUCK_DIALOG_1
* keine Angabe eines nicht Existenten Verteilers mehr möglich
*
* 7.0.165.2
* 2012/08/27
* Rofin SM 8000009382 Abbruch bei Stücklistenauflösung FB#5698
* Erweiterung Klasse /CIDEON/CL_PLOT_BO_BUS1001
* Methode ACQUIRE_RELATED_OBJECTS um den BADI
* /CIDEON/PLS_MAIN01 Methode AFTER_BOM_AQQUIRED, um auf die Menge der
* zu einem Material gefundenen Stücklisten Einfluß nehmen zu können
* in diesem Fall werden Stücklisten einer bestimmten Verwendung
* ausgeschlossen
*
* 7.0.166.1
* 2012/11/01 CKR / B. Krone
* Übergabe von Defaultstrukturen in Funktionsbereiche
* FB /CIDEON/GET_VERTEILER
* Anpassung OM und Kleiner Druckdialog
*
* 7.0.167.1
* 2013/05/27 SM 8000014441 - Rofin
* Dateipfad länger als 128 Zeichen
* FB ZCL_GET_DOC_CLF10_DETAIL_DLOAD
*
* 7.0.168.2
* 2013/11/21 Madaus
* Kleiner Druckdialog - Prüfung auf Ausgabeberechtigung schlägt fehlt
* trotzdem erfolgt Ausgabe
* FB /CIDEON/CLEAN_UP_DOCUMENTS_2
*
* 7.0.169.1
* 2014/08/04 Sulzer
" EHP 7 - Ausbau FB DSVAS_DOC_WS_DOWNLOAD_50
*         DSVAS_DOC_FILENAME_SPLIT
" FB /CIDEON/ANMELDUNG_AN_SERVER
" FB /CIDEON/STAMP_CALL_STAMP_TOOL
" FB /CIDEON/STAMP_BEFORE_VIEW
" FB /CIDEON/STAMP_CALL_STMP_TOOL_R
*
* 7.0.170.1
* 2014/10/02 - APEX
* Anpassung der Sourcen auf Ersetzung von FB GUID_CREATE
* FB /CIDEON/READ_STORED_SEARCH
* FB ZCL_GET_DOC_CLF10_DETAIL_DLOAD
* FB  /CIDEON/GUID32
* FB /CIDEON/DRUCK_ANSTEUERUNG
* INC: ZCL_PLINT_DESIGN_007F03 Form SEND
*
*7.0.171.1
*2014/10/10 - SM 8000028753 NETZSCH Feinmahltechnik GmbH, Parameterfeld
* zu8 kurz ZCL_PLOTINTERFACE
* Anpassung innerhalb Struktur /CIDEON/PLOT_USERDATA
* /CIDEON/PLOT_USERDATA
*
*7.0.172.1
*2014/11/10 -
* Vattenfall
* Integration eines Flags für das Laden aus der Suchliste
* und der Plotliste
*
*7.0.173.1
*2014/11/18 -
*2015/02/06 - B. Krone Anpassung der Recherche der Änderungsnummer zur Stückliste
*           FB /CIDEON/MATNR_MAT_BOM_CHK_SLK
*
*7.0.174.1
*C15K915166       KUECHLER     S-PSO / Änderungen 174
*2015/05/28
* SM 8000033972 Spezial Dokumente ablegen
* Netstal
* Erweiterung um hier mit und ohne Stückliste lokal ablegen zu können
*
*
*7.0.175.1
* C15K915845       KUECHLER     S-PSO / Änderungen 175
*
" 7.0.176.1
" C17K910225       CKR          S-PSO / Änderungen 176
" Umzug C17
" ABAPgit
" Strukturierung in Unterpakete
"
"
*----------------------------------------------------------------------

* to do
*             - Z-Status durch /CIDEON/ Status ersetzen
*             - Integration in Menü / Pflegedialog /CIDEON/VERT_MP

*----------------------------------------------------------------------
PROGRAM  zcl_plint_design_001.
DATA: version.
version = text-v00.


INCLUDE /cideon/_om_007top.
INCLUDE /cideon/_om_007ver.


* Klassenvereinbarungen
INCLUDE /cideon/_om_007_classes.
INCLUDE /cideon/_om_007_class_s.
INCLUDE /cideon/_om_007_class_p.
INCLUDE /cideon/_om_007_class_t.


*PBO
INCLUDE /cideon/_om_007o01.
INCLUDE /cideon/_om_007o101.
INCLUDE /cideon/_om_007o102.
*PAI
INCLUDE /cideon/_om_007i01.

*Tools
INCLUDE /cideon/_om_007_tools.

*FUNCTIONS
INCLUDE /cideon/_om_007f01.
INCLUDE /cideon/_om_007f02.
INCLUDE /cideon/_om_007f03.
INCLUDE /cideon/_om_007i04.
INCLUDE /cideon/_om_007f04.
INCLUDE /cideon/_om_007o02.
INCLUDE /cideon/_om_007f05.
INCLUDE /cideon/_om_007f06.
INCLUDE /cideon/_om_007f07.
INCLUDE /cideon/_om_007f08.
INCLUDE /cideon/_om_007f09.
INCLUDE /cideon/_om_007f10.
INCLUDE /cideon/_om_007f11.
INCLUDE /cideon/_om_007f12.

INCLUDE /cideon/_om_007f13.
INCLUDE /cideon/_om_007f13_pbo.
INCLUDE /cideon/_om_007f14.
INCLUDE /cideon/_om_007f15.
INCLUDE /cideon/_om_007f16.

INCLUDE /cideon/_om_007f16_pai.

INCLUDE /cideon/_om_007f17.
