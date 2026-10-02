************************************************************************
*        Druckroutinen für Einkaufsbelege                              *
************************************************************************
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:

*-----------------------------------------------------------------------
* Journal
* 20.09.2006 - Erstellung / Kopie
* 23.02.2007 - Expressmail verschicken nach dem Druck
* 28.02.2007 - Übergabe von Lieferantendaten
*              Integration der Mahnung
*              Integration der Mahnung der Auftragsbestätigung
* 20.03.2007 - Integration Markierung / BADIs
* 22.03.2007 - SP 32
*              Übergabe der Materialnummern
* 23.03.2007 - SP 33
*              Umbau auf Forms / FBs für
*              NEU, Mahnung, Lieferantenbestätigung
*-----------------------------------------------------------------------
* Bitte berücksichtigen, daß die FORMS
* - ENTRY_NEU
* - ENTRY_MAHN
* - ENTRY_AUFB
* angepaßt werden müssen
*----------------------------------------------------------------------*
* Datenteil
*----------------------------------------------------------------------*
include fm06ptop.

*----------------------------------------------------------------------*
* Datenbeschaffung
*----------------------------------------------------------------------*
include fm06pf01.

*----------------------------------------------------------------------*
* Formularausgabe
*----------------------------------------------------------------------*
*
include fm06pf02.
*INCLUDE /CIDEON/fm06pf02.

*----------------------------------------------------------------------*
* Sonstige PERFORM-Routinen
*----------------------------------------------------------------------*
include fm06pf03.

*----------------------------------------------------------------------*
* Dienstleistungsabwicklung
*----------------------------------------------------------------------*
include fm06pf04.

*----------------------------------------------------------------------*
* Matrixdruck für Varianten
*----------------------------------------------------------------------*
include fm06pfva.

*----------------------------------------------------------------------*
* Entries
*----------------------------------------------------------------------*
include fm06pe01.

include fm06pf05.

include fm06pf06.

include fm06pf07.

include fm06pf08.

include fm06pf09.

* Include koppieren
* include fm06pe02.
include /cideon/fm06pe02.
