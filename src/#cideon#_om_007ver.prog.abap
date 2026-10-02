*----------------------------------------------------------------------*
*   INCLUDE ZCL_PLINT_DESIGN_007VER                                    *
*----------------------------------------------------------------------*
* Versionsinformationen

FORM set_data_version_info.

  CLEAR itab_info.

  g_version = text-v00.
  g_prog_name = text-v01.
  g_use_till = text-v02.
  g_versions_typ = text-v03.


  CLEAR wa_info.
  wa_info-version = g_version.
  wa_info-prog_name = g_prog_name.
  wa_info-gueltig_bis = g_use_till.
  wa_info-versions_typ = g_versions_typ.

  REFRESH itab_info.
  SELECT * FROM zcl_prog_info INTO wa_prog_info
    WHERE tcode = sy-tcode
    AND langu = sy-langu
    ORDER BY counter
    .
    wa_itab_info-line = wa_prog_info-line.
    APPEND wa_itab_info TO itab_info.
  ENDSELECT.
  IF sy-subrc NE 0.
    PERFORM appl_log_write USING
      'W' '107' 'ZCL_PLINT_TOOLS'
      sy-tcode
      sy-langu 'ZCL_PROG_INFO' '' .
    SELECT * FROM zcl_prog_info INTO wa_prog_info
      WHERE tcode = sy-tcode
      .
      wa_itab_info-line = wa_prog_info-line.
      APPEND wa_itab_info TO itab_info.
    ENDSELECT.
    IF sy-subrc NE 0.
      PERFORM appl_log_write USING
        'W' '108' 'ZCL_PLINT_TOOLS'
        sy-langu 'ZCL_PROG_INFO' '' ''.
    ELSE.
    ENDIF.

  ELSE.
  ENDIF.

* PATCH INfo
  REFRESH itab_info_pa.
  SELECT * FROM zcl_prog_info_pa INTO wa_prog_info_pa
    WHERE tcode = sy-tcode
    AND langu = sy-langu
    ORDER BY counter
    .
    wa_itab_info_pa-line = wa_prog_info_pa-line.
    APPEND wa_itab_info_pa TO itab_info_pa.
  ENDSELECT.
  IF sy-subrc NE 0.
    PERFORM appl_log_write USING
      'W' '107' 'ZCL_PLINT_TOOLS'
      sy-tcode
      sy-langu 'ZCL_PROG_INFO_pa' '' .
    SELECT * FROM zcl_prog_info_pa INTO wa_prog_info_pa
      WHERE tcode = sy-tcode
      .
      wa_itab_info_pa-line = wa_prog_info_pa-line.
      APPEND wa_itab_info_pa TO itab_info_pa.
    ENDSELECT.
    IF sy-subrc NE 0.
      PERFORM appl_log_write USING
        'W' '108' 'ZCL_PLINT_TOOLS'
        sy-langu 'ZCL_PROG_INFO_pa' '' ''.
    ELSE.
    ENDIF.

  ELSE.
  ENDIF.


ENDFORM.
