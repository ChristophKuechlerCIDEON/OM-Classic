DATA: ls_draw TYPE draw.
CLEAR gc_objky.
CASE wa_mat_bom-objic.
  WHEN 'D'.

    SPLIT wa_mat_bom-dobjt AT space
    INTO ls_draw-doknr ls_draw-dokar
         ls_draw-doktl ls_draw-dokvr.

    CALL FUNCTION 'CONV_UTIL_DOCNR_EXT_TO_INT'
         EXPORTING
              i_documentnumber = ls_draw-doknr
         IMPORTING
              e_documentnumber = ls_draw-doknr.

    CALL FUNCTION '/CIDEON/DMS_CREATE_OBJECTKEY'
         EXPORTING
              draw      = ls_draw
         IMPORTING
              objectkey = gc_objky.
  WHEN 'T'.
  WHEN OTHERS.
    MOVE wa_mat_bom-dobjt TO gc_objky.
ENDCASE.
























