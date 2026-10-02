FUNCTION /cideon/check_item_to_confirm.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  SYUNAME
*"  EXCEPTIONS
*"      ERROR
*"      EXIT
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 29.01.2005 - Erstellung
*
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_pl_log TYPE TABLE OF /cideon/pl_log.
*WA
  DATA: wa_pl_log TYPE /cideon/pl_log.
*NORMAL
  DATA: lines_itab_pl_log TYPE i.

* testen, ob für angegebenen Nutzer noch zu
* bestätigende Einträge vorhanden sind.
  CLEAR itab_pl_log.
  CLEAR wa_pl_log.

  SELECT * FROM /cideon/pl_log INTO TABLE itab_pl_log
    WHERE  zclinsname = i_uname
    AND status = c_plot_log_entry_created
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  IF itab_pl_log[] IS INITIAL.
    EXIT.
  ELSE.
  ENDIF.

  CLEAR ausgabe.
  CLEAR lines_itab_pl_log.
  DESCRIBE TABLE itab_pl_log LINES lines_itab_pl_log.
  ausgabe = lines_itab_pl_log.

* Anzeige
  CLEAR f_exit.
  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 60 17.

* Möglichkeit der Bestätigung
*  IF f_exit = 'X'.
*    RAISE exit.
*  ELSE.
*  ENDIF.
  IF f_dont_ask = 'X'.
    RAISE exit.
  ELSE.
  ENDIF.


ENDFUNCTION.
