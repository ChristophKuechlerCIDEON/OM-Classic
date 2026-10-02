FUNCTION Z_CL_GET_DOSTXT_MATXT_IT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
* falls keine Dokumentbeschreibung gepflegt, dann die Beschreibung des
* Materials benutzen
*
*-----------------------------------------------------------------------
*ITAB
  DATA: itab_mat TYPE TABLE OF matnr.
*WA
  DATA: wa_mat TYPE matnr.
*NORMAL
  DATA: objectkey TYPE drad-objky.
  DATA: char18(18).
  DATA: maktx TYPE maktx.
  DATA: spras TYPE spras.

  DATA: wa_drat TYPE drat.

  Spras = 'FR'.
*  spras = sy-langu.

  REFRESH itab_mat.
  CLEAR wa_mat.
  CLEAR objectkey.

  SELECT SINGLE * FROM drat INTO wa_drat
    WHERE dokar = i_wa_plotjobs-dokar
    AND doknr = i_wa_plotjobs-doknr
    AND dokvr = i_wa_plotjobs-dokvr
    AND doktl = i_wa_plotjobs-doktl
    AND langu = sy-langu
    .
  IF sy-subrc NE 0.
    SELECT objky FROM drad INTO TABLE itab_mat
      WHERE
        dokar = i_wa_plotjobs-dokar
        AND doknr = i_wa_plotjobs-doknr
        AND dokvr = i_wa_plotjobs-dokvr
        AND doktl = i_wa_plotjobs-doktl
        AND dokob = 'MARA'
      .
    IF sy-subrc NE 0.
*      PERFORM appl_log_write USING
*        'W' '010' 'ZCL_PLINT_TOOLS'
*        i_wa_plotjobs-dokar i_wa_plotjobs-doknr
*        i_wa_plotjobs-dokvr i_wa_plotjobs-doktl.
    ELSE.
    ENDIF.
    LOOP AT itab_mat INTO wa_mat.
      CLEAR maktx.
      SELECT SINGLE maktx FROM makt INTO maktx
        WHERE matnr = wa_mat
        AND spras = spras
        .
      IF sy-subrc NE 0.
*        PERFORM appl_log_write USING
*          'W' '011' 'ZCL_PLINT_TOOLS'
*          wa_mat spras
*          '' ''.
      ELSE.
        o_stempel_wert = maktx.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    o_stempel_wert = wa_drat-dktxt.
  ENDIF.

ENDFUNCTION.
