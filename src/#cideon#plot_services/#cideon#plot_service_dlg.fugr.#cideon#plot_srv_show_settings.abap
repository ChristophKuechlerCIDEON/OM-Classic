FUNCTION /CIDEON/PLOT_SRV_SHOW_SETTINGS .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
*& Beschreibung: Startet den Dialog zur pflege der persönlichen Ein-
*&               stellungen.
*&
*& Autor:        HAENSEL
*& Angelegt am:  06.09.2006 22:23:21
*&----------------------------------------------------------------------
*& Änderungen:
*&  TT.MM.JJJJ <Änderer> <Änderungsbeschreibung>
*&----------------------------------------------------------------------

* Werte initialisiern
  CALL FUNCTION '/CIDEON/PLOT_SRV_GET_SETTINGS'
    IMPORTING
      eb_expand_all = gb_expand_all
      et_objtype_settings = gt_objtype_settings.

  IF gb_expand_all = abap_false.
    gb_collapse_all = abap_true.
  ENDIF.

  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 79 25.

ENDFUNCTION.
