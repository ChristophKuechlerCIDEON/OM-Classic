FUNCTION Z_CL_MAKE_OBJECT_KEY.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_DOKAR) TYPE  DOKAR
*"     VALUE(I_DOKNR) TYPE  DOKNR
*"     VALUE(I_DOKVR) TYPE  DOKVR
*"     VALUE(I_DOKTL) TYPE  DOKTL_D
*"  EXPORTING
*"     REFERENCE(O_OBJKY) TYPE  DRAD-OBJKY
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
* 31.07.2002 Erstellung
*-----------------------------------------------------------------------

  types: begin of t_objectkey,
    DOKAR type DOKAR,          "3
    doknr type doknr,          "
    dokvr type dokvr,          "
    doktl type doktl,          "

  end of t_objectkey.

data: tmp_objectkey type t_objectkey.


  clear tmp_objectkey.

  tmp_objectkey-dokar = i_dokar.
  tmp_objectkey-doknr = i_doknr.
  tmp_objectkey-dokvr = i_dokvr.
  tmp_objectkey-doktl = i_doktl.


  O_OBJKY = tmp_objectkey.



ENDFUNCTION.
