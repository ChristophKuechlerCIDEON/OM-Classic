FUNCTION z_cl_update_format_values.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 23.09.2002 Erstellung
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_format_werte TYPE TABLE OF zcl_format_werte.
  DATA: itab_paper_format TYPE TABLE OF zcl_format_types.
 "zcl_paper_format.
*WA
  DATA: wa_format_werte TYPE zcl_format_werte.
  DATA: wa_paper_format TYPE zcl_format_types.
*NORMAL
  DATA: numc(3)  TYPE n.
  DATA: f_cancel(1).

  CLEAR wa_format_werte.
  REFRESH itab_format_werte.
  CLEAR wa_paper_format.
  REFRESH itab_paper_format.

  SELECT * FROM zcl_format_types "zcl_paper_format
    INTO TABLE itab_paper_format
    .
  IF sy-subrc NE 0.
    MESSAGE e002(zcl_plint_tools) WITH 'zcl_paper_format' ''
      '' '' RAISING error.
  ELSE.
  ENDIF.

  LOOP AT itab_paper_format INTO wa_paper_format.
    SELECT SINGLE * FROM zcl_format_werte
      INTO wa_format_werte
      WHERE formatname = wa_paper_format-paper_format
      .
    IF sy-subrc NE 0.
      CLEAR wa_format_werte.
      wa_format_werte-formatname = wa_paper_format-paper_format.
      wa_format_werte-zclinsname = sy-uname.
      wa_format_werte-zclinsdate = sy-datum.
      wa_format_werte-zclinstime = sy-uzeit.
      wa_format_werte-zclinsprog = sy-repid.
      wa_format_werte-zclupdname = sy-uname.
      wa_format_werte-zclupddate = sy-datum.
      wa_format_werte-zclupdtime = sy-uzeit.
      wa_format_werte-zclupdprog = sy-repid.
      INSERT INTO zcl_format_werte VALUES wa_format_werte .
      IF sy-subrc NE 0.
        MESSAGE e003(zcl_plint_tools) WITH 'zcl_format_werte'
          wa_format_werte-formatname '' ''
          RAISING error.
      ELSE.
      ENDIF.
    ELSE.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
