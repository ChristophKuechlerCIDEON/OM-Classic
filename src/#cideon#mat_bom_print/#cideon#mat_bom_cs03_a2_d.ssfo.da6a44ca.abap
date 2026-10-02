DATA: ls_draw TYPE draw,
      lc_objky TYPE objky.

clear gc_objky.

CASE wa_mat_bom-postp.
  WHEN 'D'.
    MOVE wa_mat_bom-bomob+0(3) TO ls_draw-dokar.
    MOVE wa_mat_bom-bomob+4(25) TO ls_draw-doknr.
    MOVE wa_mat_bom-bomob+30(3) TO ls_draw-doktl.
    MOVE wa_mat_bom-bomob+34(2) TO ls_draw-dokvr.

    CALL FUNCTION 'CONV_UTIL_DOCNR_EXT_TO_INT'
         EXPORTING
              i_documentnumber = ls_draw-doknr
         IMPORTING
              e_documentnumber = ls_draw-doknr.

    CALL FUNCTION '/CIDEON/DMS_CREATE_OBJECTKEY'
         EXPORTING
              draw      = ls_draw
         IMPORTING
              objectkey = lc_objky.
    gc_objky = lc_objky.
  WHEN 'T'.
  WHEN OTHERS.
    gc_objky = wa_mat_bom-bomob.
ENDCASE.


























