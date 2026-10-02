FUNCTION z_cl_upd_preprozessor_scan.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PREPROZESSOR) TYPE  ZCL_NAME_PREPROZESSOR
*"     VALUE(I_SCAN_PFAD_PRE) TYPE  ZCL_KLIENT_SCAN_PFAD
*"     VALUE(I_DOWN_PFAD_PRE) TYPE  ZCL_KLIENT_DOWN_PFAD
*"     REFERENCE(I_PRE_PROCESSOR_RFC) TYPE  /CIDEON/_S_PRE_PREOCESSOR
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
* 01.08.2002 Erstellung
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_preprozessor TYPE TABLE OF zcl_preprozessor.
* WA
  DATA: wa_preprozessor LIKE zcl_preprozessor.
* NORMAL
  DATA: count TYPE i.
  DATA: tmp_str(10).
  DATA: tmp_keyname(30).


  CLEAR wa_preprozessor.
  CLEAR itab_preprozessor.

  wa_preprozessor-preprozessor = i_preprozessor.

  SELECT * FROM zcl_preprozessor
    INTO TABLE itab_preprozessor
    WHERE preprozessor = i_preprozessor.
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  LOOP AT itab_preprozessor INTO wa_preprozessor.

    wa_preprozessor-klient_scan_pfad = i_scan_pfad_pre.
    wa_preprozessor-klient_down_pfad = i_down_pfad_pre.

    wa_preprozessor-knz_use_converte =
      i_pre_processor_rfc-knz_use_converter.
    wa_preprozessor-converter_name =
      i_pre_processor_rfc-converter_name .
    wa_preprozessor-converter_number =
      i_pre_processor_rfc-converter_number .

    wa_preprozessor-ftp_destination =
      i_pre_processor_rfc-ftp_destination .
    wa_preprozessor-ftp_user =
      i_pre_processor_rfc-ftp_user .
    wa_preprozessor-ftp_passwd =
      i_pre_processor_rfc-ftp_passwd .
    wa_preprozessor-ftp_down =
      i_pre_processor_rfc-ftp_down .

    wa_preprozessor-zclupdname  = sy-uname.
    wa_preprozessor-zclupddate = sy-datum.
    wa_preprozessor-zclupdtime = sy-uzeit.
    wa_preprozessor-zclupdprog = sy-repid.

*   Update zcl_preprozessor
    MODIFY zcl_preprozessor FROM wa_preprozessor.
    IF sy-subrc NE 0.
      MESSAGE i051(zcl_plint_tools)
        WITH 'zcl_preprozessor' i_preprozessor
        wa_preprozessor-verteiler ''
        RAISING error.
    ELSE.
    ENDIF.

  ENDLOOP.

  COMMIT WORK AND WAIT.
  MESSAGE s054(zcl_plint_tools) WITH '' '' '' ''.

ENDFUNCTION.
