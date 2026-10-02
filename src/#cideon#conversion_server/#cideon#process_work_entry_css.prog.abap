*&---------------------------------------------------------------------*
*& Report  /CIDEON/PROCESS_WORK_ENTRY_CSS                              *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT  /cideon/process_work_entry_css.
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
* Journal
* 14.06.2004 - Erstellung
*-----------------------------------------------------------------------
*TYPES
*ITAB
*WA
*NORMAL

CALL FUNCTION '/CIDEON/PROCESS_WORK_ENTRY_CSS'
     EXCEPTIONS
          kein_eintrag = 1
          error        = 2
          gesperrt     = 3
          OTHERS       = 4.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
