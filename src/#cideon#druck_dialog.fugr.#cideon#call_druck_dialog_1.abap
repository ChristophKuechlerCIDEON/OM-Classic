FUNCTION /cideon/call_druck_dialog_1.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  TABLES
*"      O_LT_RECIPIENT STRUCTURE  /CIDEON/S_RECIPIENT OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      ABORT
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 17.03.2003 - Erstellung
* 01.02.2005 - Übersetzung
* 11.04.2005 - LIFNR / NAME1_GP / EBELN
* 31.07.2008 - SP 075
*              Anpassungen Layout etc.
*              Beschriftung der Schaltflächen
* 29.09.2008 - SP 78
*              kontrollierter Druck / Nachdruck
* 30.09.2008 - Test auf Nutzer/ doppelte Einträge
* 14.10.2008 - SP 82
*              erste Tab wird auch bei mehrmaligen Aufruf als
*              erstes benutzt
*              BUG 5247
*              Verteiler wird auf INITIAL geprüft
* 11.12.2008 - 7.0.0.8
*              Sortieren den Verteiler in der Auswahl
* 7.0.165.1
* 2012/08/17 CKR
* Anpassung kleiner Druckdialog für DEMAG CRANES
* FB /CIDEON/CALL_DRUCK_DIALOG_1
* keine ANgabe eines nicht Existenten Verteilers mehr möglich
*
*-----------------------------------------------------------------------

  wa_akt_plotjobs = i_wa_plotjobs.
  CLEAR lt_recipient.

  CLEAR g_f_code.

  tabstripcontrol_001-activetab = 'TAB1'.


  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 81 23.

  CASE g_f_code.
    WHEN 'OK'.
      "Setzen der Druckarten
      IF rb_k_d = 'X'.
        wa_akt_plotjobs-print_type = 'K'.
      ELSE.
      ENDIF.
      IF rb_n_d = 'X'.
        wa_akt_plotjobs-print_type = 'N'.
      ELSE.
      ENDIF.
      IF rb_charge = 'X'.
        wa_akt_plotjobs-print_type = 'C'.
      ELSE.
      ENDIF.
      IF rb_u_d = 'X'.
        wa_akt_plotjobs-print_type = 'U'.
      ELSE.
      ENDIF.

      o_lt_recipient[] = lt_recipient[].

      o_wa_plotjobs = wa_akt_plotjobs.
    WHEN 'CANC'.
      RAISE abort.
    WHEN OTHERS.
      RAISE error.
  ENDCASE.

ENDFUNCTION.
