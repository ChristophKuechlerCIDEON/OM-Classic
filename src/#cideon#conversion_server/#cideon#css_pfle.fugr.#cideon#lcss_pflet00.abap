*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10.06.2004 at 06:10:38 by user KUECHLER
*---------------------------------------------------------------------*
*...processing: /CIDEON/CSS_CLAS................................*
DATA:  BEGIN OF STATUS_/CIDEON/CSS_CLAS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/CIDEON/CSS_CLAS              .
CONTROLS: TCTRL_/CIDEON/CSS_CLAS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */CIDEON/CSS_CLAS              .
TABLES: /CIDEON/CSS_CLAS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
