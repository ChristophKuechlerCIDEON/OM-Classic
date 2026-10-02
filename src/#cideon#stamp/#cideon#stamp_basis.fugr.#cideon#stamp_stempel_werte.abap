FUNCTION /cideon/stamp_stempel_werte.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_APPL_TYPE) TYPE  TDWX-APPTP OPTIONAL
*"     VALUE(I_DRAW) TYPE  DRAW OPTIONAL
*"     VALUE(I_TARGET_FILE) TYPE  DMS_DOC_FILE OPTIONAL
*"     VALUE(I_DOCFILE) TYPE  DMS_REC_FILE OPTIONAL
*"     VALUE(I_DRAZ) TYPE  DMS_TBL_DRAZ OPTIONAL
*"  TABLES
*"      O_STEMPEL_WERTE STRUCTURE  ZCL_S_STEMPEL_VALUE
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 15.07.2002 creation
*
*-----------------------------------------------------------------------
* TYPES
* ITAB
  DATA: itab_stempel TYPE TABLE OF zcl_s_stempel_value.
* WA
  DATA: wa_stempel TYPE zcl_s_stempel_value.
* NORMAL

* Stempeltabelle füllen
  CLEAR itab_stempel.
  CLEAR wa_stempel.

  wa_stempel-zeile_plotjob = 1.

* Draw Felder mappen
  wa_stempel-stempel_name = 'DRAW-MANDT'.
  wa_stempel-stempel_wert = i_draw-mandt.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKAR'.
  wa_stempel-stempel_wert = i_draw-dokar.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKNR'.
  wa_stempel-stempel_wert = i_draw-doknr.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKVR'.
  wa_stempel-stempel_wert = i_draw-dokvr.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKTL'.
  wa_stempel-stempel_wert = i_draw-doktl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DWNAM'.
  wa_stempel-stempel_wert = i_draw-dwnam.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKST'.
  wa_stempel-stempel_wert = i_draw-dokst.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-LABOR'.
  wa_stempel-stempel_wert = i_draw-labor.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-AENNR'.
  wa_stempel-stempel_wert = i_draw-aennr.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-WERKA'.
  wa_stempel-stempel_wert = i_draw-werka.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-LOEDK'.
  wa_stempel-stempel_wert = i_draw-loedk.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-CADKZ'.
  wa_stempel-stempel_wert = i_draw-cadkz.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-PRENR'.
  wa_stempel-stempel_wert = i_draw-prenr.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-PREVR'.
  wa_stempel-stempel_wert = i_draw-prevr.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-PRETL'.
  wa_stempel-stempel_wert = i_draw-pretl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-PREAR'.
  wa_stempel-stempel_wert = i_draw-prear.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-BEGRU'.
  wa_stempel-stempel_wert = i_draw-begru.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-FILEP'.
  wa_stempel-stempel_wert = i_draw-filep.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DTTRG'.
  wa_stempel-stempel_wert = i_draw-dttrg.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DAPPL'.
  wa_stempel-stempel_wert = i_draw-dappl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-FILEP1'.
  wa_stempel-stempel_wert = i_draw-filep1.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DTTRG1'.
  wa_stempel-stempel_wert = i_draw-dttrg1.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DAPPL1'.
  wa_stempel-stempel_wert = i_draw-dappl1.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-VRLDAT'.
  wa_stempel-stempel_wert = i_draw-vrldat.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-VPRIOR'.
  wa_stempel-stempel_wert = i_draw-vprior.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-RES1'.
  wa_stempel-stempel_wert = i_draw-res1.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-RES2'.
  wa_stempel-stempel_wert = i_draw-res2.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-RES3'.
  wa_stempel-stempel_wert = i_draw-res3.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-RES4'.
  wa_stempel-stempel_wert = i_draw-res4.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-MRK_FILEP'.
  wa_stempel-stempel_wert = i_draw-mrk_filep.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-MRK_DTTRG'.
  wa_stempel-stempel_wert = i_draw-mrk_dttrg.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-MRK_FILEP1'.
  wa_stempel-stempel_wert = i_draw-mrk_filep1.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-MRK_DTTRG1'.
  wa_stempel-stempel_wert = i_draw-mrk_dttrg1.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-ADATUM'.
  wa_stempel-stempel_wert = i_draw-adatum.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKNR_VL'.
  wa_stempel-stempel_wert = i_draw-doknr_vl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKTL_VL'.
  wa_stempel-stempel_wert = i_draw-doktl_vl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-DOKVR_VL'.
  wa_stempel-stempel_wert = i_draw-dokvr_vl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-FILELEN'.
  wa_stempel-stempel_wert = i_draw-filelen.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-FILELEN1'.
  wa_stempel-stempel_wert = i_draw-filelen1.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-CM_RELEVANCE'.
  wa_stempel-stempel_wert = i_draw-cm_relevance.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DRAW-CM_FIXED'.
  wa_stempel-stempel_wert = i_draw-cm_fixed.
  APPEND wa_stempel TO itab_stempel.

* Target_FILE
  wa_stempel-stempel_name = 'TARGET_FILE-FILENO'.
  wa_stempel-stempel_wert = i_target_file-fileno.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-LANGU'.
  wa_stempel-stempel_wert = i_target_file-langu.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-REVISION'.
  wa_stempel-stempel_wert = i_target_file-revision.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-DTTRG'.
  wa_stempel-stempel_wert = i_target_file-dttrg.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-FILENAME'.
  wa_stempel-stempel_wert = i_target_file-filename.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-DAPPL'.
  wa_stempel-stempel_wert = i_target_file-dappl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-PH_OBJID'.
  wa_stempel-stempel_wert = i_target_file-ph_objid.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-URL'.
  wa_stempel-stempel_wert = i_target_file-url.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'TARGET_FILE-DESCRIPTION'.
  wa_stempel-stempel_wert = i_target_file-description.
  APPEND wa_stempel TO itab_stempel.

*
* DOCFILE
  wa_stempel-stempel_name = 'DOCFILE-UPDATEFLAG'.
  wa_stempel-stempel_wert = i_docfile-updateflag.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-PROTECTED'.
  wa_stempel-stempel_wert = i_docfile-protected.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-LO_IS_REF'.
  wa_stempel-stempel_wert = i_docfile-lo_is_ref.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-LO_INDEX'.
  wa_stempel-stempel_wert = i_docfile-lo_index.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-LO_OBJID'.
  wa_stempel-stempel_wert = i_docfile-lo_objid.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-LO_KEY'.
  wa_stempel-stempel_wert = i_docfile-lo_key.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-DAPPL'.
  wa_stempel-stempel_wert = i_docfile-dappl.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-DTTRG'.
  wa_stempel-stempel_wert = i_docfile-dttrg.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-DESCRIPTION'.
  wa_stempel-stempel_wert = i_docfile-description.
  APPEND wa_stempel TO itab_stempel.
  wa_stempel-stempel_name = 'DOCFILE-STORAGE_CAT'.
  wa_stempel-stempel_wert = i_docfile-storage_cat.
  APPEND wa_stempel TO itab_stempel.
*  wa_stempel-stempel_name = 'DOCFILE-TBL_PHIOS'.
*  wa_stempel-stempel_wert = i_docfile-tbl_phios.
*  APPEND wa_stempel TO itab_stempel.

  CLEAR o_stempel_werte.
  o_stempel_werte[] = itab_stempel[].

ENDFUNCTION.
