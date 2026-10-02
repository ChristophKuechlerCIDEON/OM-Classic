FUNCTION z_get_project_zidms_history.
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
  DATA: project TYPE ps_pspid.
  DATA: tabname TYPE tabname.


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
    CLEAR project.
    SELECT SINGLE project FROM (tabname)
      INTO project
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

    o_stempel_wert = project.
    EXIT.
  ELSE.
* falls QMNUM gefüllt ist
    CLEAR project.
    SELECT SINGLE project FROM (tabname)
      INTO project
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

    o_stempel_wert = project.
    EXIT.
  ENDIF.





*  o_stempel_wert = wa_plotjob-ebeln.


ENDFUNCTION.
