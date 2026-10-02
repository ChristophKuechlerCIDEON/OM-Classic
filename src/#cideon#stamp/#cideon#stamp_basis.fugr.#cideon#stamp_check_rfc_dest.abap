FUNCTION /cideon/stamp_check_rfc_dest.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DEST) TYPE  RFCDES-RFCDEST OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      NO_DESTINATION
*"      ABBRUCH
*"      VERBINDUNGSFEHLER
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 13.11.2002 creation
*
*-----------------------------------------------------------------------

  FREE rfctab.



  CLEAR dest.
  dest = i_dest.


  IF dest(1) = '/'.
    sy-subrc = 0.
    rfcdes-rfcdest = dest.
    rfcdes-rfctype = '3'.
  ELSE.
    SELECT SINGLE * FROM rfcdes WHERE rfcdest = dest.
  ENDIF.
  IF syst-subrc = 0.
    CASE rfcdes-rfctype.
      WHEN 'I'. tytext = 'interne Verbindung'(tyi).
      WHEN '3'. tytext = 'R/3-Verbindung'(ty3).
      WHEN '2'. tytext = 'R/2-Verbindung'(ty2).
      WHEN 'S'. tytext = 'SNA/CPI-C-Verbindung'(tys).
      WHEN 'T'. tytext = 'TCP/IP-Verbindung'(tyt).
      WHEN 'L'. tytext = 'logische Destination'(tyl).
      WHEN 'X'. tytext = 'ABAP/4 Treiber'(tyx).
      WHEN 'M'. tytext = 'CMC-Verbindung'(tym).
    ENDCASE.
  ELSE.
    RAISE no_destination.
  ENDIF.

  rfctest-rfcfloat = '-1'.
  rfctest-rfcdate  = sy-datum.

  pitext = 'Verbindungstest & ....'(pic).
  REPLACE '&' WITH dest INTO pitext.
  CONDENSE pitext.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            text = pitext.
  PERFORM parameter_check.
  PERFORM send USING -1.

  pitext = 'Verbindung & o.k. ....'(pit).
  REPLACE '&' WITH dest INTO pitext.
  CONDENSE pitext.
  DO blocks TIMES.
    IF rfcerror = 0.
      lines = ( sy-index - 1 ) * 102.
      piperc = ( 100 * sy-index ) / blocks.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                text       = pitext
                percentage = piperc.
      PERFORM send USING lines.
    ENDIF.
  ENDDO.




ENDFUNCTION.
