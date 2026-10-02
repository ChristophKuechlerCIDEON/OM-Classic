FUNCTION z_cl_check_for_uname.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_UNAME) TYPE  XUBNAME
*"  EXPORTING
*"     VALUE(O_UNAME) TYPE  XUBNAME
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
* 29.07.2002 Erstellung
*-----------------------------------------------------------------------

  IF i_uname = ''.
*   try to get the default username
    CLEAR tmp_str.
    pname = 'DEFAULT_NUTZER'.
    SELECT pwert FROM zcl_plint_cfg_00
      INTO tmp_str
      WHERE pname = pname
      .
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i001(zcl_plint_tools)
        WITH 'DEFAULT_NUTZER' 'zcl_plint_cfg_00' '' '' RAISING error.
    ELSE.
      o_uname = tmp_str.
    ENDIF.
  ELSE.
*   if is necessary check against USR02
    o_uname = i_uname.

  ENDIF.




ENDFUNCTION.
