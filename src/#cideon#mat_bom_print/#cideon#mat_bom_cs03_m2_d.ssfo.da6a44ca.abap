DATA: ls_draw TYPE draw,
      lc_objky TYPE objky.

clear gc_objky.

CASE wa_mat_bom-postp.
  WHEN 'D'.
  WHEN 'T'.
  WHEN OTHERS.
  CALL FUNCTION 'CONV_UTIL_MATNR_INT_TO_EXT'
    EXPORTING
      i_material       = wa_mat_bom-idnrk
   IMPORTING
     E_MATERIAL       = wa_mat_bom-idnrk.

    gc_objky = wa_mat_bom-idnrk.
ENDCASE.
















































