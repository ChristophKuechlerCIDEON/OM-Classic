REPORT ZCL_CALL_PLOT_AT_STATUS_CHNG.
*&---------------------------------------------------------------------*
*&  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON Software GmbH
* Peterstraße 1
* Görlitz
* 02628
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* to do:    - eigenen Verteiler, Einstellungen einführen, und nicht
*             eine Wiedernutzung der FAUF Einstellungen ...
*-----------------------------------------------------------------------
* Journal
* 01.01.2004 - Reaktion auf das Setzen eines Status innerhalb des
*              DMS
* 06.01.2005 - Kopie und Anpassung für den Aufruf des Plot Interf.
* 11.04.2006 - Anpassung auf .include in Tabelle
*-----------------------------------------------------------------------
TABLES: draw.

*TYPES
*ITAB
*WA
*NORMAL
*        documenttype               = documenttype
*        documentnumber             = documentnumber
*        documentpart               = documentpart
*        documentversion            = documentversion
*        documentdata               = documentdata
*        documentdatax              = documentdatax
*

INCLUDE ZCL_CALL_PLOT_AT_STATUS_INC001.
INCLUDE ZCL_CALL_PLOT_AT_STATUS_VAR.
