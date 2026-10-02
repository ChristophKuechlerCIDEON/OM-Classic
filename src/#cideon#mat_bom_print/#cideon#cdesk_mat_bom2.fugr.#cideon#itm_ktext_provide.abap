FUNCTION /cideon/itm_ktext_provide.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_POSTP) LIKE  ITM_CLASS_DATA-POSTP
*"     REFERENCE(I_POTPR) LIKE  ITM_CLASS_DATA-POTPR OPTIONAL
*"     REFERENCE(I_OBJTY) LIKE  ITM_CLASS_DATA-OBJTY
*"     REFERENCE(I_IDNRK) LIKE  ITM_CLASS_DATA-IDNRK OPTIONAL
*"     REFERENCE(I_DOKAR) LIKE  ITM_CLASS_DATA-DOKAR OPTIONAL
*"     REFERENCE(I_DOKNR) LIKE  ITM_CLASS_DATA-DOKNR OPTIONAL
*"     REFERENCE(I_DOKTL) LIKE  ITM_CLASS_DATA-DOKTL OPTIONAL
*"     REFERENCE(I_DOKVR) LIKE  ITM_CLASS_DATA-DOKVR OPTIONAL
*"     REFERENCE(I_KLART) LIKE  ITM_CLASS_DATA-KLART OPTIONAL
*"     REFERENCE(I_CLASS) LIKE  ITM_CLASS_DATA-CLASS OPTIONAL
*"     REFERENCE(I_POTX1) LIKE  ITM_CLASS_DATA-POTX1 OPTIONAL
*"     REFERENCE(I_ROMS1) LIKE  ITM_CLASS_DATA-ROMS1 OPTIONAL
*"     REFERENCE(I_ROMS2) LIKE  ITM_CLASS_DATA-ROMS2 OPTIONAL
*"     REFERENCE(I_ROMS3) LIKE  ITM_CLASS_DATA-ROMS3 OPTIONAL
*"     REFERENCE(I_ROMEI) LIKE  ITM_CLASS_DATA-ROMEI OPTIONAL
*"     REFERENCE(I_RFORM) LIKE  ITM_CLASS_DATA-RFORM OPTIONAL
*"     REFERENCE(I_SPRAS) TYPE  SPRAS DEFAULT SY-LANGU
*"  EXPORTING
*"     REFERENCE(E_OBKTX) LIKE  ITM_CLASS_DATA-OBKTX
*"     REFERENCE(E_KTEXT) LIKE  ITM_CLASS_DATA-KTEXT
*"----------------------------------------------------------------------

  DATA: ls_t418 LIKE t418,
        l_flg_itm_check_aborted LIKE csdata-xfeld,
        l_flg_cls_item          LIKE csdata-xfeld.

  PERFORM itm_category_read
              USING
                 i_postp
                 i_potpr
                 const-flg_no
              CHANGING
                 l_flg_itm_check_aborted
                 l_flg_cls_item
                 ls_t418.

  PERFORM itm_comp_text_get
              USING
                 i_objty
                 i_idnrk
                 i_klart
                 i_class
                 i_dokar
                 i_doknr
                 i_doktl
                 i_dokvr
                 i_potx1
                 i_roms1
                 i_roms2
                 i_roms3
                 i_romei
                 i_rform
                 ls_t418
                 sy-datum
                 i_spras
              CHANGING
                 e_obktx
                 e_ktext.

ENDFUNCTION.
