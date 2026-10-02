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
* 27.05.2005 - Erstellungen
* 30.05.2005 - Kopie
*-----------------------------------------------------------------------
* setzt in
*-----------------------------------------------------------------------
* to do
*-----------------------------------------------------------------------
REPORT  /cideon/conv_reset_connection .
*166: RFC-Destination in CONVERTER-CONV_DEST nicht erreibbar
*167: RFC-Destination in CONVERTER-CONV_UTIL_DEST nicht erreibbar
*163: Falsches Programm in RFC-Destination in CONVERTER-CONV_UTIL_DEST

*TABLES
TABLES: converter.
*ITAB
DATA: itab_converter TYPE TABLE OF converter.

*WA
DATA: wa_converter TYPE converter.

"/CIDEON/CONV_RST_CON

AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD '/CIDEON/CONV_RST_CON'.
IF sy-subrc NE 0.
  "keine Berechtigung
  MESSAGE e000(26) WITH text-000.
ELSE.
ENDIF.

START-OF-SELECTION.

  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-010.
  PARAMETERS p_163 TYPE c AS CHECKBOX DEFAULT ''.
  PARAMETERS p_166 TYPE c AS CHECKBOX DEFAULT 'X'.
  PARAMETERS p_167 TYPE c AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN BEGIN OF BLOCK bl11 WITH FRAME TITLE text-011.
  SELECT-OPTIONS s_conv FOR converter-name.
  SELECTION-SCREEN END OF BLOCK bl11.


  SELECT * FROM converter
    INTO TABLE itab_converter
    WHERE name IN s_conv
    ORDER BY NAME

    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

*LOOP AT itab_converter INTO wa_converter.
*  WRITE: / wa_converter-name, wa_converter-status,
*      wa_converter-message_number.
*ENDLOOP.

* Falsches Programm in RFC-Destination in CONVERTER-CONV_UTIL_DEST
  IF p_163 = 'X'.
    LOOP AT itab_converter INTO wa_converter
      WHERE message_number = '163'
      .
*     zurücksetzen
      SUBMIT conv_free_converter
        WITH cname = wa_converter-name
        AND RETURN.
    ENDLOOP.
  ELSE.
  ENDIF.


* Konvertierungsziel nicht erreichbar
  IF p_166 = 'X'.
    LOOP AT itab_converter INTO wa_converter
      WHERE message_number = '166'
      .
*     zurücksetzen
      SUBMIT conv_free_converter
        WITH cname = wa_converter-name
        AND RETURN.
    ENDLOOP.
  ELSE.
  ENDIF.

* RFC-Destination in CONVERTER-CONV_UTIL_DEST nicht erreibbar
  IF p_167 = 'X'.
    LOOP AT itab_converter INTO wa_converter
      WHERE message_number = '167'
      .
*     zurücksetzen
      SUBMIT conv_free_converter
        WITH cname = wa_converter-name
        AND RETURN.
    ENDLOOP.
  ELSE.
  ENDIF.

*
