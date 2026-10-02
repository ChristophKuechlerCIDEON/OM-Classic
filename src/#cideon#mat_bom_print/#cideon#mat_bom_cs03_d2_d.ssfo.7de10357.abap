DATA: ls_draw TYPE draw,
      lc_objky TYPE objky.
MOVE-CORRESPONDING wa_mat_bom TO ls_draw.

CALL FUNCTION '/CIDEON/DMS_CREATE_OBJECTKEY'
     EXPORTING
          draw      = ls_draw
     IMPORTING
          objectkey = lc_objky.
gc_objky = lc_objky.















