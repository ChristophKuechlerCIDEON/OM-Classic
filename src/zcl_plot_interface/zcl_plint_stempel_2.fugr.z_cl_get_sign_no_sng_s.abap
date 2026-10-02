FUNCTION z_cl_get_sign_no_sng_s.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
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
* 18.01.2005 - Erstellung
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_signs_dms_tab TYPE TABLE OF rc77b.
*WA
  DATA: wa_draw TYPE draw.
  DATA: wa_plotjob TYPE zcl_s_plotlist.
  DATA: wa_key_dms_imp TYPE rc77.
  DATA: wa_signs_dms_tab TYPE rc77b.

  CLEAR wa_plotjob.
  wa_plotjob = i_wa_plotjobs.

  CLEAR wa_key_dms_imp.
  wa_key_dms_imp-dokar = wa_plotjob-dokar.
  wa_key_dms_imp-doknr = wa_plotjob-doknr.
  wa_key_dms_imp-doktl = wa_plotjob-doktl.
  wa_key_dms_imp-dokvr = wa_plotjob-dokvr.

  CLEAR itab_signs_dms_tab.

  CALL FUNCTION 'SIGN_READ'
    EXPORTING
      object_imp                      = '60'
*     KEY_CHORD_IMP                   =
*     KEY_LOT_IMP                     =
*     KEY_SHEET_IMP                   =
*     KEY_EBR_IMP                     =
*     KEY_CHOBJ_IMP                   =
      key_dms_imp                     = wa_key_dms_imp
*     KEY_PNNR_IMP                    =
*     FLG_READ_MODE_IMP               =
    TABLES
*     SIGNS_CHORD_TAB                 =
*     SIGNS_LOT_TAB                   =
*     SIGNS_SHEET_TAB                 =
*     SIGNS_EBR_TAB                   =
*     SIGNS_CHOBJ_TAB                 =
      signs_dms_tab                   = itab_signs_dms_tab
*     SIGNS_PNNR_TAB                  =
    EXCEPTIONS
      key_for_object_incomplete       = 1
      no_signatures_found             = 2
      OTHERS                          = 3
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF itab_signs_dms_tab[] IS INITIAL.
    CLEAR o_stempel_wert.
    EXIT.
  ELSE.
  ENDIF.

  READ TABLE itab_signs_dms_tab INTO wa_signs_dms_tab INDEX 1.

  o_stempel_wert = wa_signs_dms_tab-sign_no.


ENDFUNCTION.
