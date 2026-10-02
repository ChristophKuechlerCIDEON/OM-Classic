FUNCTION /cideon/merge_drap_rang.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOKAR) TYPE  DOKAR
*"  TABLES
*"      I_IT_STATUS STRUCTURE  BAPI_DOC_DRAP
*"      O_IT_STATUS_RANG STRUCTURE  /CIDEON/_S_STMP_RNG_DRAP
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Erstellung eine DRAP Tabelle mit Rangfolge
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 15.02.2006 - Erstellung
*-----------------------------------------------------------------------
*ITAB

*WA
  DATA: wa_status LIKE i_it_status.
  DATA: wa_status_rang LIKE o_it_status_rang.
  DATA: wa_rang TYPE /cideon/stmp_rng.
*NORMAL


  IF i_dokar IS INITIAL.
    RAISE error.
  ELSE.
  ENDIF.

  clear o_it_status_rang.

* Suchen Tabelle und Übergabe
  LOOP AT i_it_status INTO wa_status.
    CLEAR wa_rang.
    CLEAR wa_status_rang.
    MOVE-CORRESPONDING wa_status TO wa_status_rang.
    SELECT SINGLE * FROM /cideon/stmp_rng
      INTO wa_rang
      WHERE dokar = i_dokar
      AND dokst = wa_status-statusintern
      .
    IF sy-subrc NE 0.
*     nicht gefunden -> RANG 000
      wa_status_rang-rang = '000'.
      APPEND wa_status_rang TO o_it_status_rang.
    ELSE.
      wa_status_rang-rang = wa_rang-rang.
      APPEND wa_status_rang TO o_it_status_rang.
    ENDIF.
  ENDLOOP.




ENDFUNCTION.
