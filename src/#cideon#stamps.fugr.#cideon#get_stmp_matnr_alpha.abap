FUNCTION /cideon/get_stmp_matnr_alpha.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Normung aus Statuslog DIS / Nutzer - Fester Text
*
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.04.2005 - Erstellung
* 12.11.2005 - Kopie
* 15.02.2006 - Kopie
* 20.02.2006 - Kopie
* 27.03.2006 - Kopie
* 09.03.2010 - Kopie
*              Anregung DHE
*
*-----------------------------------------------------------------------

*ITAB
  DATA: itab_mat TYPE TABLE OF matnr.
*WA
  DATA: wa_mat TYPE matnr.
*NORMAL
  DATA: objectkey TYPE drad-objky.
  DATA: char18(18).


  REFRESH itab_mat.
  CLEAR wa_mat.
  CLEAR objectkey.

  SELECT objky FROM drad INTO TABLE itab_mat
    WHERE
      dokar = i_wa_plotjobs-dokar
      AND doknr = i_wa_plotjobs-doknr
      AND dokvr = i_wa_plotjobs-dokvr
      AND doktl = i_wa_plotjobs-doktl
      AND dokob = 'MARA'
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CLEAR wa_mat.
  READ TABLE itab_mat INTO wa_mat INDEX 1.
  IF sy-subrc NE 0.
    CLEAR o_stempel_wert.
  ELSE.
    o_stempel_wert = wa_mat.
  ENDIF.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
            input  = o_stempel_wert
       IMPORTING
            output = o_stempel_wert.
  .




ENDFUNCTION.
