FUNCTION Z_CL_MAKE_INI_TAB_STAMPS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      I_ITAB_INI_DATA
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

  DATA: wa_line TYPE t_ini_data_tab.
  DATA: wa_itab_ini TYPE t_itab_ini.
  data: laenge type i.

*  data: itab_ini type table of t_itab_ini.

  REFRESH itab_ini.
  LOOP AT i_itab_ini_data INTO wa_line.
    CLEAR wa_itab_ini.
    SPLIT wa_line AT '=' INTO wa_itab_ini-key wa_itab_ini-value.
    condense wa_itab_ini-value.
    APPEND wa_itab_ini TO itab_ini.
  ENDLOOP.
* Tabelle bereinigen
  loop at itab_ini into wa_itab_ini.
    if wa_itab_ini-key is initial.
      delete itab_ini index sy-tabix.
    else.
    endif.

  endloop.




ENDFUNCTION.
