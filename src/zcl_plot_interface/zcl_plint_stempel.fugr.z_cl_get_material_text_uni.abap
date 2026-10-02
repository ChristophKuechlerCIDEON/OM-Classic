FUNCTION z_cl_get_material_text_uni.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

*ITAB
  DATA: itab_mat TYPE TABLE OF matnr.
*WA
  DATA: wa_mat TYPE matnr.
*NORMAL
  DATA: objectkey TYPE drad-objky.
  DATA: char18(18).
  DATA: maktx TYPE maktx.
  DATA: spras TYPE spras.

*get the materials for this document
*it could be more than one... ;-)
* try to find it depending logon language

*  Spras = 'DE'.
  spras = sy-langu.

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
*    PERFORM appl_log_write USING
*      'W' '010' 'ZCL_PLINT_TOOLS'
*      i_wa_plotjobs-dokar i_wa_plotjobs-doknr
*      i_wa_plotjobs-dokvr i_wa_plotjobs-doktl.
  ELSE.
  ENDIF.

  LOOP AT itab_mat INTO wa_mat.
    CLEAR maktx.
    SELECT SINGLE maktx FROM makt INTO maktx
      WHERE matnr = wa_mat
      AND spras = spras
      .
    IF sy-subrc NE 0.
      PERFORM appl_log_write USING
        'W' '011' 'ZCL_PLINT_TOOLS'
        wa_mat spras
        '' ''.
    ELSE.
      CONCATENATE o_stempel_wert maktx '  ' INTO o_stempel_wert.
    ENDIF.

  ENDLOOP.


*   vornullen
*  IF wa_stpo_api02-document CO ' 0123456789'.
*    laenge = strlen( wa_stpo_api02-document ).
*    IF laenge < 25.
*      char25 = '0000000000000000000000000'.
*      "anzahl = 25 - laenge.
*      anzahl = laenge.
*      SHIFT char25 BY anzahl PLACES RIGHT.
*      CONDENSE char25 NO-GAPS.
*      CONCATENATE char25 wa_stpo_api02-document
*        INTO wa_stpo_api02-document.
*    ELSE.
*    ENDIF.
*  ELSE.
*  ENDIF.



ENDFUNCTION.
