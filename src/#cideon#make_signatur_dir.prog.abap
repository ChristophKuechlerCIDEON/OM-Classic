REPORT /cideon/make_signatur_dir .
*
* CIDEON
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*           Christoph.Kuechler@cideon.com
*
*-----------------------------------------------------------------------





PARAMETERS: p_dokar TYPE draw-dokar.
PARAMETERS: p_doknr TYPE draw-doknr.
PARAMETERS: p_doktl TYPE draw-doktl.
PARAMETERS: p_dokvr TYPE draw-dokvr.

PARAMETERS: p_sig TYPE tc85-signstrat.
PARAMETERS: p_txt TYPE rc71-reason_ktxt.

PARAMETERS: p_stzae TYPE rc77-stzae DEFAULT '16'.



DATA: ls_key_dms_imp TYPE rc77.

CLEAR ls_key_dms_imp.

ls_key_dms_imp-sign_obj = '60'.

ls_key_dms_imp-dokar = p_dokar.
ls_key_dms_imp-doknr = p_doknr.
ls_key_dms_imp-doktl = p_doktl.
ls_key_dms_imp-dokvr = p_dokvr.

DATA: ls_draw TYPE draw.
CLEAR ls_draw.

SELECT SINGLE * FROM draw
  INTO ls_draw
  WHERE dokar = ls_key_dms_imp-dokar
  AND doknr = ls_key_dms_imp-doknr
  AND doktl = ls_key_dms_imp-doktl
  AND dokvr = ls_key_dms_imp-dokvr
  .
IF sy-subrc NE 0.
ELSE.
ENDIF.

ls_key_dms_imp-dokst = ls_draw-dokst.

ls_key_dms_imp-dokst = 'PT'.
*ls_key_dms_imp-stzae = p_stzae.


*CALL FUNCTION 'SIGN_BUFFER_INITIALIZE'
*  EXPORTING
*    object_imp           = '60'
**   KEY_EBR_IMP          =
**   I_CLEAR_GLOBAL       = ' '
.


CALL FUNCTION 'SIGN_CREATE'
  EXPORTING
    object_imp                        = '60' " Dokument
*   KEY_CHORD_IMP                     =
*   KEY_LOT_IMP                       =
*   KEY_SHEET_IMP                     =
*   KEY_EBR_IMP                       =
*   KEY_CHOBJ_IMP                     =
    key_dms_imp                       = ls_key_dms_imp
*   KEY_PNNR_IMP                      =
*   SIGNER_IMP                        = SY-UNAME
    signstrat_imp                     = p_sig
*   FLG_COMMENT_REQ_IMP               = ' '
*   FLG_SIGNER_CHANGEABLE_IMP         = ' '
*   FLG_SYNC_IMP                      = ' '
    sign_reason_ktxt                  = p_txt
* IMPORTING
*   END_OF_SIGN_PROC                  =
 EXCEPTIONS
   key_for_object_incomplete         = 1
   cancelled_by_user                 = 2
   signer_not_given                  = 3
   pse_info_not_found                = 4
   password_wrong_3_times            = 5
   no_authority                      = 6
   no_authority_auth_grp             = 7
   duplicate_signature               = 8
   strat_info_not_found              = 9
   strat_info_error                  = 10
   signing_procedure_cancelled       = 11
   synch_proc_error                  = 12
   sign_method_not_found             = 13
   no_domvalues                      = 14
   user_address_not_found            = 15
   text_error                        = 16
   OTHERS                            = 17
          .
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  WRITE sy-subrc.
  EXIT.
ENDIF.

DATA: lf_save_flg TYPE rc70d-flg_esc.
CLEAR lf_save_flg.

CALL FUNCTION 'SIGN_SAVE_CHECK'
      EXPORTING: object_imp   = '60'
                 key_dms_imp  = ls_key_dms_imp
      IMPORTING: flg_save_exp = lf_save_flg
      EXCEPTIONS: key_for_object_incomplete = 1
                  OTHERS                    = 2.
.

"IF lf_save_flg = 'X'.
CALL FUNCTION 'SIGN_SAVE'
     EXPORTING: object_imp  = '60'
                key_dms_imp = ls_key_dms_imp
     EXCEPTIONS: key_for_object_incomplete = 1
                 OTHERS                    = 2.
WRITE sy-subrc.
"ELSE.
"ENDIF.


COMMIT WORK AND WAIT.




*
