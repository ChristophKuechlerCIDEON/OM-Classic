*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/CIDEON/CSS_PFLE
*   generation date: 10.06.2004 at 06:10:37 by user KUECHLER
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/CIDEON/CSS_PFLE   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
