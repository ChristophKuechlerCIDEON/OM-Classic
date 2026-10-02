*----------------------------------------------------------------------*
*   INCLUDE /CIDEON/FM06PF02                                           *
*----------------------------------------------------------------------*
************************************************************************
*        Druckausgabe Einkaufsbelege                                   *
************************************************************************
*  89494  ??.??.1997  3.1I  TK  Probedruck: Nicht optisch archivieren!
*  91419  22.12.1997  3.1I  CF  Probedruck: Anzahl Kopien = 1
*  88301  26.01.1998  3.1I  RB  Geänderten Liefertermin auf Position
*  99282  24.03.1998  4.0C  CF  Immer neuer Spoolauftrag

  include fm06pf02_ausgabe_kopf .  " AUSGABE_KOPF

  include fm06pf02_ausgabe_pos_ueb .  " AUSGABE_POS_UEB

  include fm06pf02_ausgabe_pos .  " AUSGABE_POS

  include fm06pf02_ausgabe_eint .  " AUSGABE_EINT
  include fm06pf02_ausgabe_anhang .  " AUSGABE_ANHANG

*  include fm06pf02_ende .  " ENDE
  include /CIDEON/fm06pf02_ende.

  include fm06pf02_ausgabe_stammkonditio .  " AUSGABE_STAMMKONDITIONEN

  include fm06pf02_ausgabe_comp .  " AUSGABE_COMP
