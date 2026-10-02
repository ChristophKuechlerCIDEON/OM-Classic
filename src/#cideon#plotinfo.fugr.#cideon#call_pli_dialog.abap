FUNCTION /cideon/call_pli_dialog.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_URL) TYPE  CHAR255
*"     REFERENCE(I_CFG) TYPE  CHAR255
*"     REFERENCE(I_USER) TYPE  CHAR255
*"     REFERENCE(I_PASSWORD) TYPE  CHAR255
*"  EXPORTING
*"     VALUE(O_URL) TYPE  CHAR255
*"     VALUE(O_CFG) TYPE  CHAR255
*"     VALUE(O_USER) TYPE  CHAR255
*"     VALUE(O_PASSWORD) TYPE  CHAR255
*"  EXCEPTIONS
*"      ERROR
*"      ABORT
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
*-----------------------------------------------------------------------
* Journal
* 14.11.2005 - Erstellungen
* 17.11.2005 - Meldungen
* 05.12.2005 - Memory ID / Paßwwort / Paßwortdialog
*-----------------------------------------------------------------------
* Logondaten für PlotInfoServer erfragen
*
*-----------------------------------------------------------------------


  CLEAR wa_logon.
  wa_logon-url = i_url.
  wa_logon-cfg = i_cfg.
  wa_logon-user_pli = i_user.
  wa_logon-password = i_password.

  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 75 15.

  IF ok_code = 'CANC'.
    MESSAGE w050(/cideon/plot_admin)
      WITH '' '' '' ''
      RAISING abort.
  ELSE.
  ENDIF.

* Übergabe der geänderten Werte.
  o_url = wa_logon-url.
  o_cfg = wa_logon-cfg.
  o_user = wa_logon-user_pli.
  o_password = wa_logon-password.

  MESSAGE s051(/cideon/plot_admin)
    WITH '' '' '' ''.


ENDFUNCTION.
