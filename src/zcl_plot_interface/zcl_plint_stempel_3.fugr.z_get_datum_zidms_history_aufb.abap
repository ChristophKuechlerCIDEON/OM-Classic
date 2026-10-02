FUNCTION z_get_datum_zidms_history_aufb.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.04.2005 - Erstellung
* 19.09.2005 - Kopie
*-----------------------------------------------------------------------
* Erweiterung für Sask / Rücksichtnahme auf entsprechende Zurdnung
* zu Instandhaltungsmeldungen
*-----------------------------------------------------------------------


*ITAB
*WA
  DATA: wa_plotjob TYPE zcl_s_plotlist.
*NORMAL
  DATA: datum	TYPE datum.
  DATA: tabname TYPE tabname.
  DATA: datum10(10).

  wa_plotjob = i_wa_plotjobs.
  CLEAR o_stempel_wert.

  CLEAR tabname.
  tabname = 'ZIDMS_HISTORY'.

* Test, ob Tabelle vorhanden ist
  DATA: wa_tadir TYPE tadir.
  SELECT SINGLE * FROM tadir INTO wa_tadir
    WHERE pgmid = 'R3TR'
    AND object = 'TABL'
    AND obj_name = tabname
    .
  IF sy-subrc NE 0.
    CONCATENATE text-010 tabname
    INTO o_stempel_wert.
    EXIT.
  ELSE.
  ENDIF.



  IF wa_plotjob-qmnum IS INITIAL.
* falls QMNUM nicht gefüllt ist
    CLEAR o_stempel_wert.
    CLEAR datum.
    SELECT SINGLE datum FROM (tabname)
      INTO datum
      WHERE dokar = wa_plotjob-dokar
      AND doknr = wa_plotjob-doknr
      AND doktl = wa_plotjob-doktl
      AND dokvr = wa_plotjob-dokvr
*      AND qmnum = wa_plotjob-qmnum
      .
    IF sy-subrc NE 0.
      CLEAR o_stempel_wert.
      EXIT.
    ELSE.
    ENDIF.

    CALL FUNCTION 'DATUMSAUFBEREITUNG'
      EXPORTING
*     FLAGM                 = ' '
*     FLAGW                 = ' '
        idate                 = datum
*     IMONT                 = ' '
*     IWEEK                 = ' '
      IMPORTING
*     MDAT4                 =
*     MDAT6                 =
*     TDAT4                 =
*      tdat6                 = datum
        tdat8                 = datum10
*     WDAT4                 =
*     WDAT6                 =
      EXCEPTIONS
        datfm_ungueltig       = 1
        datum_ungueltig       = 2
        OTHERS                = 3
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    o_stempel_wert = datum10.
    EXIT.
  ELSE.
* falls QMNUM gefüllt ist
    CLEAR datum.
    SELECT SINGLE datum FROM (tabname)
      INTO datum
      WHERE dokar = wa_plotjob-dokar
      AND doknr = wa_plotjob-doknr
      AND doktl = wa_plotjob-doktl
      AND dokvr = wa_plotjob-dokvr
      AND qmnum = wa_plotjob-qmnum
      .
    IF sy-subrc NE 0.
      CLEAR o_stempel_wert.
      EXIT.
    ELSE.
    ENDIF.

    CALL FUNCTION 'DATUMSAUFBEREITUNG'
      EXPORTING
*     FLAGM                 = ' '
*     FLAGW                 = ' '
        idate                 = datum
*     IMONT                 = ' '
*     IWEEK                 = ' '
      IMPORTING
*     MDAT4                 =
*     MDAT6                 =
*     TDAT4                 =
*      tdat6                 = datum
        tdat8                 = datum10
*     WDAT4                 =
*     WDAT6                 =
      EXCEPTIONS
        datfm_ungueltig       = 1
        datum_ungueltig       = 2
        OTHERS                = 3
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


    o_stempel_wert = datum10.
    EXIT.
  ENDIF.





*  o_stempel_wert = wa_plotjob-ebeln.


ENDFUNCTION.
