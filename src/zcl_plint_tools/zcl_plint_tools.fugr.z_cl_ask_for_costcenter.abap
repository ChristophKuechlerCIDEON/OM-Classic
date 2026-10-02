FUNCTION Z_CL_ASK_FOR_COSTCENTER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_USER) TYPE  SY-UNAME
*"  EXPORTING
*"     VALUE(O_KOSTL) TYPE  KOSTL
*"  EXCEPTIONS
*"      ERROR
*"      PERNR_NOT_FOUND
*"      KOSTL_NOT_FOUND
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 09.08.2002 Erstellung
*-----------------------------------------------------------------------


data: wa_pa0105 type pa0105.
data: wa_pa0001 type pa0001.
data: akt_datum type sy-datum.

  akt_datum = sy-datum.

* get the PERNR
 select single * from pa0105
    into wa_pa0105
    where SUBTY = '0001'
    and usrty = '0001'
    and USRID = i_user
    and begda <= akt_datum
    and endda >= akt_datum
    .
 if sy-subrc ne 0.
   raise PERNR_NOT_FOUND.
 else.
 endif.

 select single * from pa0001
    into wa_pa0001
    where  pernr = wa_pa0105-pernr
    and begda <= akt_datum
    and endda >= akt_datum
    .

  if sy-subrc ne 0.
    raise KOSTL_NOT_FOUND.
  else.
    o_kostl = wa_pa0001-kostl.
  endif.


ENDFUNCTION.
