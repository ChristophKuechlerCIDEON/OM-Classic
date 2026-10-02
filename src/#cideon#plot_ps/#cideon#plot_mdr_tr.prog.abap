*&---------------------------------------------------------------------*
*& Modulpool         /CIDEON/PLOT_MDR_TR                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:
*           Andrzej Rosinski
*           Dr. Peter Rabe
*-----------------------------------------------------------------------
* Journal
* 17.07.2007 - Erstellung
* 20.07.2007 - Recherche PSP etc.
* 23.07.2007 - Layout, Dokumentverknüpfungen holen
* 24.07.2007 - Merkmalswerte
*              BADI Vorbereitung für Merkmalswerte recherchieren
*              Memory ID
*              PRO  für PSPID benutzen
*              Ablage DIS anzeigen
*              Berücksichtigung der Klassifikation bei TR
* 25.07.2007 -
*              Ablage des TR am DIS
* 31.07.2007 - Layoutänderungen
*              Ersetzen der WSA im Ablage DIS
*              TOC DIS integriert
*            - DIS für TOC Cust.
* 07.08.2007 - SP 45
*            - MDR
* 08.08.2007 -
* 13.08.2007 - Mauerbau
*              MDR DIS integrieren
*              Layoutanpassungen
*              Anzeige der Dokumentationsstruktur über den CAD Desktop
*              Zeichnungsverzeichnis MDR
*              Zeichnungen für MDR Verzeichnis
* 22.08.2007 - dynamisches Inhaltsverzeichnis
* 24.08.2007 - Anzeige des zulestzt erstellten TR / Layoutänderungen
*              Problem bei Falscheingabe (nicht vorhandenes Projekt)
* 02.09.2007 - SP 47
*            - dyn. Startseite
* 03.09.2007 - weitere Integration dyn. Startseite
* 05.09.2007 - Conversion Exit für PSPNR
*              BADI für Erstellung des DIS für MDR / TR
* 06.09.2007 - Klassifikation interne / externe Werte
*-----------------------------------------------------------------------
* INFO
*-----------------------------------------------------------------------
* toDo

*    - bessere Auswahlmöglichkeit für MDR / TR DIS
*      CV100_DOC_SEARCH
*
*    - TR Einhängen in Struktur
*      -
*    - Klassifikationen MDR

* Smartforms
*    - Layout gestaltung

* Defaultwertanpassung
* BADI vorsehen


*    - Rückgabe des MDR in das SAP per RFC Server
*      Übergabe der Daten des MDR / Root Folders
*-----------------------------------------------------------------------
*TABLES
*ITAB
*WA
*NORMAL


include /cideon/plot_mdr_tr_top                 .                      "

* INCLUDE /CIDEON/PLOT_MDR_TR_O01                 .                    *
* INCLUDE /CIDEON/PLOT_MDR_TR_I01                 .                    *
* INCLUDE /CIDEON/PLOT_MDR_TR_F01                 .                    *

include /cideon/plot_mdr_tr_pbo01.

include /cideon/plot_mdr_tr_pai01.

include /cideon/plot_mdr_tr_fb01.

include /cideon/plot_mdr_tr_fb02.
