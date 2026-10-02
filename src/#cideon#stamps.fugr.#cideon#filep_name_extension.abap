FUNCTION /cideon/filep_name_extension.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"       EXPORTING
*"             VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Dateiname und Extension
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
* 15.09.2009 - Kopie
*-----------------------------------------------------------------------
  DATA: pf_path TYPE char255.
  DATA: pfx_file TYPE filep.


  CLEAR pf_path.
  CLEAR pfx_file.

  pf_path = i_wa_plotjobs-filep.

  CALL FUNCTION 'CV120_SPLIT_PATH'
    EXPORTING
      pf_path        = pf_path
    IMPORTING
*     PFX_PATH       =
      pfx_file       = pfx_file
            .




  o_stempel_wert = pfx_file.


ENDFUNCTION.
