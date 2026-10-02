*&---------------------------------------------------------------------*
*& Report  /CIDEON/_PRINT_CS_START_PLOT  *
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
* 29.09.2003 - Erstellung
* 01.10.2003 - Einstellungen lesen
* to do
* 01.07.2004 - Kopie aus Fertigungsauftragsplotten
* 23.08.2004 - Vermeiden des Abbruch-Rausschmisses PR
*-----------------------------------------------------------------------

report  /cideon/_print_cs_start_plot .

data:  gf_nodrad.

*&---------------------------------------------------------------------*
*&      Form  PRINT_PAPER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form print_paper.

**********************************************************************
*   Start des Plot-Interface ohne Daten fürhrt zu Abbruchmeldung
*   und Rausschmiß !! -> sollten wir diese brutale Art vermeiden ??
*   -> dann muß ein Parameter her, der das verhindert !
**********************************************************************
  data: lf_no_doc.

*TYPES
*ITAB
*WA
  data: wa_default_data type /cideon/plot_defaultdata.
  data: wa_user_data type /cideon/plot_userdata.
*NORMAL

* Einstellungen lesen
  clear wa_user_data.
  clear wa_default_data.

  call function '/CIDEON/READ_DEFAULTDATA'
       exporting
            i_batch        = ''
       importing
            o_default_data = wa_default_data.


  call function '/CIDEON/READ_USERDATA'
       exporting
            i_default_data = wa_default_data
       importing
            o_user_data    = wa_user_data.

***************************************************
*  Wenn automatisches Löschen der Duplikate gewünscht:
*  im FB 'Z_CL_READ_ZCL_PSB_TMP' Funktion freischalten!

  if wa_user_data-read_tmp_search = 'X'.
  call function 'Z_CL_READ_ZCL_PSB_TMP'
   importing
     no_doc        = lf_no_doc.
            .
  if lf_no_doc is initial.

* mglw. automatischer Durchlauf durch PlotInterface
      if wa_user_data-knz_auto_cs = 'X'.
        set parameter id 'Z_PL_BYPASS' field 'X'.
      else.
        set parameter id 'Z_PL_BYPASS' field ''.
      endif.

* Aufruf des PlotInterfaces
      set parameter id 'Z_PL_READ_AKT_QUEUE' field 'X'.
      call transaction 'ZCL_PLOT_INTERFACE'.


* Einstellungen zurücksetzen
      set parameter id 'Z_PL_BYPASS' field ''.
      set parameter id 'Z_PL_READ_AKT_QUEUE' field ''.

    else.
*    break schulte.
      message s001(/cideon/plot_cs).
    endif.
  endif.

endform.                    " PRINT_PAPER
