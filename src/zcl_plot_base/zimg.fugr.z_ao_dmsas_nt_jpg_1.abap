FUNCTION Z_AO_DMSAS_NT_JPG_1.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
* Allgemein
  DATA: RET TYPE N,
        DOKNR LIKE DRAW-DOKNR.
*-----------------------------------------------------------------------
* Dokumentendaten holen ...

*  break-point.
  IMPORT DRAW INTDRAZ PFAD APPLIKATIONSNUMMER APPLIKATIONSTYP
                          FROM MEMORY ID 'SAP_APPLICATION'.

  IMPORT OBJECTLINKS FROM MEMORY ID 'ZZ_OBJECTLINKS'.

  CALL FUNCTION 'DOCUMENT_DATA_GET'
       TABLES
            IN_DELDRAD = IN_DELDRAD
            IN_INTDRAD = IN_INTDRAD
            IN_MRKDRAD = IN_MRKDRAD
            IN_UPDDRAD = IN_UPDDRAD
            IN_UPDDRAP = IN_UPDDRAP
            IN_DRAP    = IN_DRAP
            IN_TEXTTAB = IN_TEXTTAB.

* Zurücksetzen aller Aufrufparameter ...
  CLEAR: PROGRAM, COMMANDLINE.

* Dokumentenstatus lesen ...
  SELECT SINGLE * FROM TDWS WHERE DOKAR = DRAW-DOKAR AND
                                  DOKST = DRAW-DOKST.
  SELECT SINGLE * FROM TDWAT WHERE DOKAR = DRAW-DOKAR AND
                                   CVLANG = SY-LANGU.

* In Dokumentennummer führende Nullen eliminieren ...
  MOVE DRAW-DOKNR TO DOKNR.
*  SHIFT DOKNR LEFT DELETING LEADING 0.
  SHIFT DOKNR LEFT DELETING LEADING '0'.
*break-point.
* Ermitteln des Datenträgertyps ...
  CALL FUNCTION 'WS_QUERY'
       EXPORTING
            ENVIRONMENT    = 'hostname'
            QUERY          = 'EN'
       IMPORTING
            RETURN         = *TDWD-DTTRG
       EXCEPTIONS
            INV_QUERY      = 1
            NO_BATCH       = 2
            FRONTEND_ERROR = 3
            OTHERS         = 4.

  CASE SY-SUBRC.
    WHEN 1 OR 2 OR 3 OR 4.
      MESSAGE E011(ZC).
  ENDCASE.

  IF *TDWD-DTTRG = ''.
    MOVE 'DEFAULT' TO *TDWD-DTTRG.
  ENDIF.

* Datenträgertyp ermitteln ...
  SELECT SINGLE * FROM TDWD WHERE DTTRG = *TDWD-DTTRG.

  IF SY-SUBRC NE 0.
    MESSAGE E023(ZC) WITH *TDWD-DTTRG.
  ELSE.
    MOVE TDWD TO *TDWD.
    select single * from tdwe into *tdwe where typdt = tdwd-typdt.
  ENDIF.

program = 'D:\Programme\AutoOrg\FOCUS\focus.exe'.
concatenate '/VIEW' pfad into commandline separated by space.
* -> Aufruf der Anwendung ...

  IF NOT PROGRAM = ''.                 "Anwendung unterstützt ?
    CALL FUNCTION 'WS_EXECUTE'
         EXPORTING
              DOCUMENT    = ' '
              INFORM      = ' '
              PROGRAM     = program
              COMMANDLINE = commandline.
  ELSE.
    MESSAGE I022(zc) WITH APP_NAM.
  ENDIF.

ENDFUNCTION.
