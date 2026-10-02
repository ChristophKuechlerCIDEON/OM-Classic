FUNCTION z_cl_show_versions_info_screen.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(ID) TYPE  C DEFAULT 'PLOT_001'
*"     VALUE(I_WA_INFO) TYPE  ZCL_S_INFO OPTIONAL
*"  EXPORTING
*"     REFERENCE(O_URL) TYPE  C
*"  TABLES
*"      I_ITAB_INFO STRUCTURE  ZCL_S_LINE_255 OPTIONAL
*"      I_ITAB_INFO_PA STRUCTURE  ZCL_S_LINE_255 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------


  wa_info = i_wa_info.
  REFRESH itab_info.
  REFRESH itab_info_pa.
  itab_info[] = i_itab_info[].
  itab_info_pa[] = i_itab_info_pa[].

* set versions typ

* get user count

  SELECT COUNT( * ) FROM usr02
    into anzahl_nutzer
    WHERE ustyp = 'A'
    .
  IF sy-subrc NE 0.
  ELSE.
  ENDIF.

  CALL SCREEN 550 STARTING AT 10 10 ENDING AT 78 24.

ENDFUNCTION.
