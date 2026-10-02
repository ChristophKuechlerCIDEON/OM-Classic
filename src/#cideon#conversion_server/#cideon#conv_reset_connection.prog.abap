*&---------------------------------------------------------------------*
*& Report  /CIDEON/CONV_RESET_CONNECTION                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*
* Änderungen:
*-----------------------------------------------------------------------
* Journal
* 27.05.2005 - Erstellunge
*-----------------------------------------------------------------------
* setzt in
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------
REPORT  /cideon/conv_reset_connection .
*166: RFC-Destination in CONVERTER-CONV_DEST nicht erreibbar
*167: RFC-Destination in CONVERTER-CONV_UTIL_DEST nicht erreibbar
*163: Falsches Programm in RFC-Destination in CONVERTER-CONV_UTIL_DEST

"/CIDEON/CONV_RESET_C

AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD '/CIDEON/CONV_RESET_C'.
IF sy-subrc NE 0.
  "keine Berechtigung
  MESSAGE e000(26) WITH text-000.
ELSE.
ENDIF.

*ITAB
DATA: itab_converter TYPE TABLE OF converter.

*WA
DATA: wa_converter TYPE converter.


SELECT * FROM converter
  INTO TABLE itab_converter
  ORDER BY name
  .
IF sy-subrc NE 0.
ELSE.
ENDIF.

*LOOP AT itab_converter INTO wa_converter.
*  WRITE: / wa_converter-name, wa_converter-status,
*      wa_converter-message_number.
*ENDLOOP.

* Falsches Programm in RFC-Destination in CONVERTER-CONV_UTIL_DEST
LOOP AT itab_converter INTO wa_converter
  WHERE message_number = '163'.
* zurücksetzen
  SUBMIT conv_free_converter
    WITH cname = wa_converter-name
    AND RETURN.
ENDLOOP.


* Konvertierungsziel nicht erreichbar
LOOP AT itab_converter INTO wa_converter
  WHERE message_number = '166'.
* zurücksetzen
  SUBMIT conv_free_converter
    WITH cname = wa_converter-name
    AND RETURN.
ENDLOOP.

* RFC-Destination in CONVERTER-CONV_UTIL_DEST nicht erreibbar
LOOP AT itab_converter INTO wa_converter
  WHERE message_number = '167'.
* zurücksetzen
  SUBMIT conv_free_converter
    WITH cname = wa_converter-name
    AND RETURN.
ENDLOOP.


*
