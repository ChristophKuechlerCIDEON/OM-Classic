*&---------------------------------------------------------------------*
*& Report  ZCL_CL30N_ADD_ITEM_TO_PSB_TMP                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 11.11.2002 Umarbeitung
*-----------------------------------------------------------------------
REPORT  zcl_cl30n_add_item_to_psb_tmp .

*ITAB
DATA: itab_drad TYPE TABLE OF drad.
DATA: itab_mara TYPE TABLE OF mara.
DATA: itab_objects TYPE TABLE OF pdm_exp_objects.
DATA: itab_stored_search TYPE TABLE OF zcl_psb_tmp.
*WA
DATA: wa_drad TYPE drad.
DATA: wa_mara TYPE mara.
DATA: wa_objects TYPE pdm_exp_objects.
DATA: wa_stored_search TYPE zcl_psb_tmp.
*NORMAL


* MATERIAL
* BOMITEM
* BILLOFMAT
* BILLOFDOC
* DOCUMENT

* Annahme : ITEM IST MATERIAL


CLEAR wa_objects.

SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD 'X'.

GET PARAMETER ID 'CV2' FIELD wa_objects-dokar.
GET PARAMETER ID 'CV1' FIELD wa_objects-doknr.
GET PARAMETER ID 'CV3' FIELD wa_objects-dokvr.
GET PARAMETER ID 'CV4' FIELD wa_objects-doktl.

IF ( wa_objects-dokar IS INITIAL )
  OR ( wa_objects-doknr IS INITIAL )
  OR ( wa_objects-dokvr IS INITIAL )
  OR ( wa_objects-doktl IS INITIAL ).
ELSE.
  wa_objects-object_type = 'DOCUMENT'.
  APPEND wa_objects TO itab_objects.
ENDIF.

CALL FUNCTION 'Z_CL_PSBRW_WRITE_PSB_TMP'
     TABLES
          i_itab_objects = itab_objects
     EXCEPTIONS
          error          = 1
          OTHERS         = 2.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.


CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.
