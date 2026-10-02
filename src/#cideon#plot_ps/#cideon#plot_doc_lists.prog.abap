*&---------------------------------------------------------------------*
*& Modulpool         /CIDEON/PLOT_DOC_LISTS*
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
* 10.08.2007 - Kopie / Anpassungen für CONCAST
* 20.09.2007 - Strukturausgabe
* 02.11.2007 - SP 52 /2.1.0.14
*              Anpassung auf CONCAST Erfordernisse
*              Anzeige Projektstücklisten
* 05.11.2007 - Materialien holen / Dokumente holen
* 06.11.2007 - BADI
*-----------------------------------------------------------------------
* INFO
*-----------------------------------------------------------------------
* toDo
*
* Auflösung der PSP Hierachie, dann WBS-BOM für PSPs holen?
* nicht unbedingt, denn dann manuelle Auswahl der WBS-BOMS notwendig

* Smartforms
* Defaultwertanpassung
* BADI vorsehen

*-----------------------------------------------------------------------
*TABLES
*ITAB
*WA
*NORMAL



include /cideon/plot_doc_lists_top.

include /cideon/plot_doc_list_cls.


*include /cideon/plot_mdr_tr_top                 .

* INCLUDE /CIDEON/PLOT_MDR_TR_O01                 .                    *
* INCLUDE /CIDEON/PLOT_MDR_TR_I01                 .                    *
* INCLUDE /CIDEON/PLOT_MDR_TR_F01                 .                    *

include /cideon/plot_doc_lists_pbo01.
*include /cideon/plot_mdr_tr_pbo01.

include /cideon/plot_doc_lists_pai01.
*include /cideon/plot_mdr_tr_pai01.

include /cideon/plot_doc_lists_fb01.
*include /cideon/plot_mdr_tr_fb01.

include /cideon/plot_doc_lists_fb02.
*INCLUDE /CIDEON/PLOT_MDR_TR_FB02.

include /cideon/plot_doc_lists_fb03.
