FUNCTION z_cl_psbrw_mat_stl_voll.
*"---------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*----------------------------------------------------------------------
* Journal
* 09.10.2002 Erstellung
*----------------------------------------------------------------------

*ITAB
  DATA: itab_stpo TYPE TABLE OF stpo_api02.

  DATA: itab_stpo_api02 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_1 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_2 TYPE TABLE OF stpo_api02.
  DATA: itab_stpo_result TYPE TABLE OF stpo_api02.
*WA
  DATA: wa_stpo_api02 TYPE stpo_api02.
  DATA: document TYPE csap_dbom-doknr.
  DATA: doc_type TYPE csap_dbom-dokar.
  DATA: doc_vers TYPE csap_dbom-dokvr.
  DATA: doc_part TYPE csap_dbom-doktl.
  DATA: wa_dost TYPE dost.
  DATA: laenge TYPE i.
  DATA: char25(25).
  DATA: anzahl TYPE i.

*
**       Stückliste
*  REFRESH itab_stpo_1.
*  REFRESH itab_stpo_2.
*  REFRESH itab_stpo_result.
*
*  wa_stpo_api02-COMPONENT = i_matnr.
**  wa_stpo_api02- = i_stlan.
*  APPEND wa_stpo_api02 TO itab_stpo_1.
*
*  LOOP AT itab_stpo_1 INTO wa_stpo_api02.
*    DELETE itab_stpo_1 INDEX sy-tabix.
*    APPEND wa_stpo_api02 TO itab_stpo_result.
*
*    REFRESH itab_stpo_api02.
*    document = wa_stpo_api02-document.
*    doc_type = wa_stpo_api02-doc_type.
*    doc_vers = wa_stpo_api02-doc_vers.
*    doc_part = wa_stpo_api02-doc_part.
*
*    CALL FUNCTION 'CSAP_DOC_BOM_READ'
*         EXPORTING
*              document = document
*              doc_type = doc_type
*              doc_part = doc_part
*              doc_vers = doc_vers
*         TABLES
*              t_stpo   = itab_stpo_api02
*         EXCEPTIONS
*              error    = 1
*              OTHERS   = 2.
*    IF sy-subrc <> 0.
*    ELSE.
*    ENDIF.
*
*
*    LOOP AT itab_stpo_api02 INTO wa_stpo_api02.
*      APPEND wa_stpo_api02 TO itab_stpo_1.
*    ENDLOOP.
*  ENDLOOP.
*
*  LOOP AT itab_stpo_result INTO wa_stpo_api02.
*    APPEND wa_stpo_api02 TO itab_stpo_api02.
*  ENDLOOP.
*
*  refresh itab_stpo.
*
*  CALL FUNCTION 'CSAP_MAT_BOM_READ'
*    EXPORTING
*      material             = i_matnr
**     PLANT                =
*      bom_usage            = i_stlan
**     ALTERNATIVE          =
**     VALID_FROM           =
**     VALID_TO             =
**     CHANGE_NO            =
**     REVISION_LEVEL       =
**     FL_DOC_LINKS         = ' '
**   IMPORTING
**     FL_WARNING           =
*    TABLES
*      T_STPO               =  itab_stpo
**     T_STKO               =
**     T_DEP_DATA           =
**     T_DEP_DESCR          =
**     T_DEP_ORDER          =
**     T_DEP_SOURCE         =
**     T_DEP_DOC            =
**     T_DOC_LINK           =
**   EXCEPTIONS
**     ERROR                = 1
**     OTHERS               = 2
*            .
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*
*
ENDFUNCTION.
