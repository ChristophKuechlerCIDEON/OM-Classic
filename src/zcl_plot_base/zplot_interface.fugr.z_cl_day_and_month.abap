FUNCTION z_cl_day_and_month.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(HEUTE) TYPE  SY-DATUM DEFAULT SY-DATUM
*"     REFERENCE(TAG) TYPE  SY-FDAYW DEFAULT SY-FDAYW
*"  EXPORTING
*"     REFERENCE(DATUM) TYPE  C
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : day TYPE sy-fdayw,
         date TYPE sy-datum,
         aaj(15) TYPE c,  " AAJ(Indisch) = HEUTE(Deutsch)
         month(2) TYPE c,
         maheney(15) TYPE c, " MAHENEY(Indisch) = MONAT(Deutsch)
         year(4) TYPE c,
         today(2) TYPE c,
         full_day_format(30) TYPE c.

  MOVE heute TO date.

  MOVE tag TO day.

  CASE day.
    WHEN '1'.
      aaj = 'Montag'.
    WHEN '2'.
      aaj = 'Dienstag'.
    WHEN '3'.
      aaj = 'Mittwoch'.
    WHEN '4'.
      aaj = 'Donnerstag'.
    WHEN '5'.
      aaj = 'Freitag'.
    WHEN '6'.
      aaj = 'Samstag'.
    WHEN '7'.
      aaj = 'Sonntag'.
  ENDCASE.

  year   = date(4).
  month  = date+4(2).
  today  = date+6(2).

  CASE month.
    WHEN '01'.
      maheney = 'Januar'.
    WHEN '02'.
      maheney = 'Februar'.
    WHEN '03'.
      maheney = 'März'.
    WHEN '04'.
      maheney = 'April'.
    WHEN '05'.
      maheney = 'Mai'.
    WHEN '06'.
      maheney = 'Juni'.
    WHEN '07'.
      maheney = 'Juli'.
    WHEN '08'.
      maheney = 'August'.
    WHEN '09'.
      maheney = 'September'.
    WHEN '10'.
      maheney = 'Oktober'.
    WHEN '11'.
      maheney = 'November'.
    WHEN '12'.
      maheney = 'Dezember'.
  ENDCASE.

  CONCATENATE aaj ',' today '.' maheney year INTO full_day_format.

  MOVE full_day_format TO datum .

ENDFUNCTION.
